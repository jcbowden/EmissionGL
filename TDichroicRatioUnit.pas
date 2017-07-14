unit TDichroicRatioUnit;

interface


uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject ;

type
  TDichroicRatio  = class
  public
     resultsFileName : string ;

     sampleRange : string ;
     numXPos, numYPos : integer ;
     interleaved : boolean ;  // 0 and 90 degree spectra occur in pairs

     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     pixelSpacingX,  pixelSpacingY : single ;
     actualDepth : single ;
     normaliseDepth : boolean ;
     boneToSurface : boolean ;  // bone to surface = true surface to bone = false

     allXData       : TSpectraRanges ;  // for display in column #2 - The original data set
     ratioData      : TSpectraRanges ;  // for the results

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc

     constructor Create(SDPrec : integer) ;  // 
     destructor  Destroy; // override;
     procedure Free ;

     function  GetAllXData(sourceSpecRange : TSpectraRanges ) : boolean ;
     function  ProcessDichroicRatioData( sourceSpecRange : TSpectraRanges; lc : pointer ) : boolean   ;
     function  GetDichroicRatioBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list

  private
end;

implementation


constructor TDichroicRatio.Create(SDPrec : integer);  // need SDPrec
begin
   bB :=   TBatchBasics.Create ;
   allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
   inherited Create ;
end ;


destructor  TDichroicRatio.Destroy; // override;
begin
  allXData.Free ;
  bB.Free ;
  inherited Destroy ;
end ;

procedure TDichroicRatio.Free;
begin
 if Self <> nil then Destroy;
end;

function  TDichroicRatio.GetAllXData(sourceSpecRange : TSpectraRanges ) : boolean ;
var
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := false ;
  try

  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
        MessageDlg('TDichroicRatio.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',sampleRange) = length(trim(sampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    sampleRange := sampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;


  // *****************  This actually retrieves the data  ********************
  allXData.yCoord.FetchDataFromTMatrix( sampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXData.yImaginary := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
    allXData.yImaginary.FetchDataFromTMatrix( sampleRange, xVarRange , sourceSpecRange.yImaginary ) ;
  end ;


//  allXData.xCoord.FetchDataFromTMatrix( '1', xVarRange , sourceSpecRange.yCoord ) ;    // was using code below but this should work

  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allXData.xString := sourceSpecRange.xString ;
  allXData.yString := sourceSpecRange.yString ;
  allXData.xCoord.numCols :=  allXData.yCoord.numCols ;
  allXData.xCoord.numRows := 1 ;
  allXData.xCoord.Filename := resultsFileName ;
  allXData.xCoord.F_Mdata.SetSize(allXData.xCoord.numCols * 1 * allXData.xCoord.SDPrec) ;
  allXData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allXData.xCoord.GetTotalRowsColsFromString(xVarRange, allXData.xCoord.Fcols) ;
  allXData.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allXData.xCoord.numCols do
  begin
     allXData.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allXData.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allXData.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;   

  result := true ;
  finally

  end ;
end ;


function  TDichroicRatio.ProcessDichroicRatioData( sourceSpecRange : TSpectraRanges; lc : pointer ) : boolean   ; 
var
  t1, t2, t3 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  t_xVarRange  : string ;
  numRatios : integer ;

  numberOfSpectra : integer ;
  ratio_s1 : single ;
  ratio_d1 : double ;
begin

  result := false ;
  try
     numRatios := numXPos * numYPos ;
     if (2 * (numRatios)) > allXData.yCoord.numRows then
     begin
       MessageDlg('ProcessDichroicRatioData() error: Number of points greater than number of spectra present. Have to exit' ,mtError, [mbOK], 0)  ;
       exit ;
     end ;

     ratioData := TSpectraRanges.Create(allXData.yCoord.SDPrec div 4, numXPos * numYPos, allXData.yCoord.numCols,nil) ;
     ratioData.xCoord.CopyMatrix(allXData.xCoord) ;
     ratioData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     ratioData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

     if interleaved then
     begin
        for t1 := 0 to (numRatios-1) do   // for each pair of spectra to be ratioed
        begin

           for t2 := 0 to allXData.yCoord.numCols-1 do   // for each wavelength
           begin
             if  allXData.yCoord.SDPrec = 4 then
             begin
              t3 :=  ((t1*2) * allXData.yCoord.SDPrec *  allXData.yCoord.numCols)+(t2*allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek(t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( s1  ,  allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek((allXData.yCoord.SDPrec *  allXData.yCoord.numCols)-allXData.yCoord.SDPrec, soFromCurrent) ;
              allXData.yCoord.F_Mdata.Read( s2  ,  allXData.yCoord.SDPrec) ;
              s1 := s1 / s2 ;
              ratioData.yCoord.F_Mdata.Write(s1, allXData.yCoord.SDPrec) ;
             end
             else
             if  allXData.yCoord.SDPrec = 8 then
             begin
              t3 :=  ((t1*2)  * allXData.yCoord.SDPrec *  allXData.yCoord.numCols)+(t2*allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek(t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( d1  ,  allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek((numRatios* allXData.yCoord.SDPrec *  allXData.yCoord.numCols)- allXData.yCoord.SDPrec, soFromCurrent) ;
              allXData.yCoord.F_Mdata.Read( d2  ,  allXData.yCoord.SDPrec) ;
              d1 := d1 / d2 ;
              ratioData.yCoord.F_Mdata.Write(d1, allXData.yCoord.SDPrec) ;
             end
           end ;

        end ;

     end
     else  // interleaved = false
     begin
        for t1 := 0 to (numRatios-1) do   // for each pair of spectra to be ratioed
        begin

           for t2 := 0 to allXData.yCoord.numCols-1 do   // for each wavelength
           begin
             if  allXData.yCoord.SDPrec = 4 then
             begin
              t3 :=  (t1 * allXData.yCoord.SDPrec *  allXData.yCoord.numCols)+(t2*allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek(t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( s1  ,  allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek((numRatios* allXData.yCoord.SDPrec *  allXData.yCoord.numCols) + t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( s2  ,  allXData.yCoord.SDPrec) ;
              if s2 <> 0.0 then
                s1 := s1 / s2
              else
                s1 := 0.0 ;
              ratioData.yCoord.F_Mdata.Write(s1, allXData.yCoord.SDPrec) ;
             end
             else
             if  allXData.yCoord.SDPrec = 8 then
             begin
              t3 :=  (t1 * allXData.yCoord.SDPrec *  allXData.yCoord.numCols)+(t2*allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek(t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( d1  ,  allXData.yCoord.SDPrec) ;
              allXData.yCoord.F_Mdata.Seek((numRatios* allXData.yCoord.SDPrec *  allXData.yCoord.numCols) + t3, soFromBeginning) ;
              allXData.yCoord.F_Mdata.Read( d2  ,  allXData.yCoord.SDPrec) ;
              if d2 <> 0.0 then
                d1 := d1 / d2
              else
                d1 := 0.0 ;
              ratioData.yCoord.F_Mdata.Write(d1, allXData.yCoord.SDPrec) ;
             end
           end ;

        end ;

     end ;


  except
    result := false ;

  end ;

  result := true ;
end ;


 {'type = DICHROIC RATIO  // ratios two band areas (peak1 / peak2)'
 'sample range = 1-34  ') ;
 'number of x positions = 17') ;  // output wil be 17
 'number of y positions = 1') ;
 'interleaved = false'
 'pixel spacing x = 75  // distance between pixels') ;
 'pixel spacing y = 75  // distance between pixels') ;
 'bone to surface = true  // distance between pixels') ;
 'actual depth = 0  // depth in mm') ;
 'normalise depth = false  // 1') ;
 'results file = dichroic_ratio.out') ; }

function  TDichroicRatio.GetDichroicRatioBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
var
  tstr1 : string ;

begin

   // ********************** Sample range  ******************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'sample range' then
     sampleRange :=  bB.RightSideOfEqual(tstr1) ;

   // ********************** X Variables  ******************************************
    repeat
      inc(lineNum) ;
      tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
    until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
    if bB.LeftSideOfEqual(tstr1) = 'x var range' then
      xVarRange :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

    if pos(' ',trim(xVarRange)) > 0 then
       xVarRangeIsPositon := false
     else
       xVarRangeIsPositon := true ;

   // ********************** Number of X positions **************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'number of x positions' then
     numXPos :=  strtoint(bB.RightSideOfEqual(tstr1)) ;  // 

   // ********************** Number of Y positions  ******************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'number of y positions' then
     numYPos :=  strtoint(bB.RightSideOfEqual(tstr1)) ;

  // ********************** interleaved  ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'interleaved' then
    if bB.RightSideOfEqual(tstr1) = 'true'  then
        interleaved := true
     else
        interleaved :=  false ;
  // ********************** Pixel spacing ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'pixel spacing x' then
    pixelSpacingX :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'pixel spacing y' then
    pixelSpacingY :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;


  // ********************** bone to surface = true surface to bone = false ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'bone to surface' then
    if bB.RightSideOfEqual(tstr1) = 'true'  then
        boneToSurface := true
     else
        boneToSurface :=  false ;
  // ********************** Actual depth ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'actual depth' then
    actualDepth :=  strtofloat(bB.RightSideOfEqual(tstr1)) ; 
  // ********************** normalise Depth ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'normalise depth' then
    if bB.RightSideOfEqual(tstr1) = 'true'  then
        normaliseDepth := true
     else
        normaliseDepth :=  false ;

  // ********************** Get output filename 'resultsFile' ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count) ;
  if bB.LeftSideOfEqual(tstr1) = 'results file' then
    resultsFileName :=  bB.RightSideOfEqual(tstr1) ;

  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum>=tStrList.Count)  ;

  result := lineNum ;
end ;




end.

 