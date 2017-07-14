unit TAreaRatioUnit;

interface

// will only ratio a single polarisation angle data at a time and data has to be in x major form
// i.e.  all spectra of x points in Y row 1
//       all spectra of x points in y row 2
//        "     "     " "   "     " "  "  3 etc.

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject ;

type
  TAreaRatio  = class(TObject)
  public
     resultsFileName : string ;

     sampleRange : string ;
     numXPos, numYPos : integer ;

     peak1Range, peak2Range : string ;
     peak1RangeIsPositon : boolean ;
     peak2RangeIsPositon : boolean ;

     actualDepth : single ;
     pixelSpacingX,  pixelSpacingY : single ;
     normaliseDepth : boolean ;
     boneToSurface : boolean ;  // bone to surface = true surface to bone = false

     allXData       : TSpectraRanges ;  // for display in column #2 - The original data set

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc

     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure Free ;

     function  ProcessAreaRatioData( sourceSpecRange : TSpectraRanges; lc : pointer ) : boolean   ;
     function  GetAreaRatioBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
 //    function  ProcessAreaRatioData( lc : pointer ) : boolean ;  // lc is pointer to TGLLineColor object

  private
end;

implementation


constructor TAreaRatio.Create(SDPrec : integer);  // need SDPrec
begin
   bB :=   TBatchBasics.Create ;
   inherited Create ;
end ;


destructor  TAreaRatio.Destroy; // override;
begin
  allXData.Free ;
  bB.Free ;
  inherited Destroy ;
end ;

procedure TAreaRatio.Free;
begin
 if Self <> nil then Destroy;
end;


function  TAreaRatio.ProcessAreaRatioData( sourceSpecRange : TSpectraRanges; lc : pointer ) : boolean   ;
var
  t1, t2 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  t_xVarRange  : string ;
  tPeak1Mat, tPeak2Mat : TMatrix ;
  tPeak1Sum, tPeak2Sum : TMatrix ;
  numberOfSpectra : integer ;
  ratio_s1 : single ;
  ratio_d1 : double ;
begin

result := false ;
try

  // convert peak ranges into variable number ranges
  if peak1RangeIsPositon = false then
  begin
      self.peak1Range :=  bB.ConvertValueStringToPosString(peak1Range, sourceSpecRange.xCoord) ;
      if  self.peak1Range = '' then
      begin
        MessageDlg('TAreaRatio.GetAllXData() Error...'#13'peak1 variable range values not appropriate',mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;
  if peak2RangeIsPositon = false then
  begin
      self.peak2Range :=  bB.ConvertValueStringToPosString(peak2Range, sourceSpecRange.xCoord) ;
      if  self.peak2Range = '' then
      begin
        MessageDlg('TAreaRatio.GetAllXData() Error...'#13'peak2 variable range values not appropriate',mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ;
  end ;



  tPeak1Mat := TMatrix.Create(sourceSpecRange.yCoord.SDPrec div 4)  ;
  tPeak2Mat := TMatrix.Create(sourceSpecRange.yCoord.SDPrec div 4) ;

  numberOfSpectra := tPeak1Mat.GetTotalRowsColsFromString(sampleRange, tPeak1Mat.Fcols) ;
  allXData := TSpectraRanges.Create(1,numYPos,numXPos, lc) ;  // numberOfSpectra is number of x coordinates in graph

  tPeak1Sum := TMatrix.Create2(sourceSpecRange.yCoord.SDPrec div 4, numberOfSpectra, 1)  ;  // single column to hold sums of the rows got from the peak of interest
  tPeak2Sum := TMatrix.Create2(sourceSpecRange.yCoord.SDPrec div 4, numberOfSpectra, 1) ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',sampleRange) = length(sampleRange) then       // sampleRange string is open ended (e.g. '12-')
    sampleRange := sampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  tPeak1Mat.FetchDataFromTMatrix( sampleRange, peak1Range , sourceSpecRange.yCoord ) ;
  tPeak2Mat.FetchDataFromTMatrix( sampleRange, peak2Range , sourceSpecRange.yCoord ) ;

  // for each row of data sum the row (each column data in row)
  tPeak1Sum.F_Mdata.Seek(0,soFromBeginning) ;
  tPeak2Sum.F_Mdata.Seek(0,soFromBeginning) ;
  tPeak1Mat.F_Mdata.Seek(0,soFromBeginning) ;
  tPeak2Mat.F_Mdata.Seek(0,soFromBeginning) ;
  if tPeak1Mat.SDPrec = 4 then
  begin
    for t1 := 1 to tPeak1Mat.numRows do
    begin
      ratio_d1 := 0.0 ;
      for t2 := 1 to  tPeak1Mat.numCols do
      begin
        tPeak1Mat.F_Mdata.Read(s1,4) ;
        ratio_d1 :=  ratio_d1 + s1 ;
      end ;
      ratio_s1 := ratio_d1 ;
      tPeak1Sum.F_Mdata.Write(ratio_s1,4) ;
      ratio_d1 := 0.0 ;
      for t2 := 1 to  tPeak2Mat.numCols do
      begin
        tPeak2Mat.F_Mdata.Read(s1,4) ;
        ratio_d1 :=  ratio_d1 + s1 ;
      end  ;
      ratio_s1 := ratio_d1 ;
      tPeak2Sum.F_Mdata.Write(ratio_s1,4) ;
    end  ;
  end
  else
  if tPeak1Mat.SDPrec = 8 then
  begin
    for t1 := 1 to tPeak1Mat.numRows do
    begin
      ratio_d1 := 0.0 ;
      for t2 := 1 to  tPeak1Mat.numCols do
      begin
        tPeak1Mat.F_Mdata.Read(d1,8) ;
        ratio_d1 :=  ratio_d1 + d1 ;
      end ;
      tPeak1Sum.F_Mdata.Write(ratio_d1,8) ;
      ratio_d1 := 0.0 ;
      for t2 := 1 to  tPeak2Mat.numCols do
      begin
        tPeak2Mat.F_Mdata.Read(d1,8) ;
        ratio_d1 :=  ratio_d1 + d1 ;
      end  ;
      tPeak2Sum.F_Mdata.Write(ratio_d1,8) ;
    end  ;
  end ;

  tPeak1Sum.F_Mdata.Seek(0,soFromBeginning) ;
  tPeak2Sum.F_Mdata.Seek(0,soFromBeginning) ;
  allXData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if sourceSpecRange.xCoord.SDPrec = 4 then
  begin
    for t1 := 1 to numberOfSpectra do
    begin
        tPeak1Sum.F_Mdata.Read(s1, 4) ;
        tPeak2Sum.F_Mdata.Read(s2, 4) ;
        ratio_s1 := s1 / s2 ;
        allXData.yCoord.F_Mdata.Write(ratio_s1,4) ;
    end ;
  end
  else
  if sourceSpecRange.xCoord.SDPrec = 8 then
  begin
    for t1 := 1 to numberOfSpectra do
    begin
        tPeak1Sum.F_Mdata.Read(d1, 8) ;
        tPeak2Sum.F_Mdata.Read(d2, 8) ;
        ratio_d1 := d1 / d2 ;
        allXData.yCoord.F_Mdata.Write(ratio_d1,8) ;
    end ;
  end ;

  // Set X coordinate data
  allXData.xCoord.numCols :=  self.numXPos ;
  allXData.xCoord.numRows := 1 ;
  allXData.xCoord.Filename := resultsFileName ;

  if boneToSurface then
  begin
    s1 := pixelSpacingX * (numXPos-1) ;
    d1 := pixelSpacingX * (numXPos-1) ;
    pixelSpacingX := pixelSpacingX * -1 ;
  end
  else
  begin
    s1 := 0 ;
    d1 := 0 ;
  end ;
  if (actualDepth = 0)  then
  begin
    normaliseDepth := false ;
  end ;

  // actualDepth  normaliseDepth   pixelSpacing   boneToSurface
    allXData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  if sourceSpecRange.xCoord.SDPrec = 4 then
  begin
    for t1 := 0 to numXPos- 1 do
    begin
      s2 := s1 + ( t1 * pixelSpacingX)  ;
      if normaliseDepth then
        s2 := s2 / actualDepth ;
      allXData.xCoord.F_Mdata.Write(s2,4)
    end ;
  end
  else
  if sourceSpecRange.xCoord.SDPrec = 4 then
  begin
    for t1 := 0 to numXPos -1 do
    begin
      d2 := d1 + ( t1 * pixelSpacingX)  ;
      if normaliseDepth then
        d2 := d2 / actualDepth ;
      allXData.xCoord.F_Mdata.Write(d2,8)
    end ;
  end ;

  allXData.xPix := numXPos ;
  allXData.yPix := numYPos ;
  allXData.xPixSpacing := pixelSpacingX ;
  allXData.yPixSpacing := pixelSpacingY ;

  result := true ;
finally
  tPeak1Mat.Free ;
  tPeak2Mat.Free ;
  tPeak1Sum.Free ;
  tPeak2Sum.Free ;
end ;


end ;


 {'type = AREA RATIO  // ratios two band areas (peak1 / peak2)'
 'sample range = 1-  ') ;
 'number of x positions = 17') ;
 'number of y positions = 1') ;
 'peak1 range = 1620-1690 cm-1  // can be variable number or v
 'peak2 range = 1520-1580 cm-1  // can be variable number or v
 'pixel spacing x = 75  // distance between pixels') ;
 'pixel spacing y = 75  // distance between pixels') ;
 'bone to surface = true  // distance between pixels') ;
 'actual depth = 0  // depth in mm') ;
 'normalise depth = false  // 1') ;
 'results file = area_ratio.out') ; }

function  TAreaRatio.GetAreaRatioBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
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

   // ********************** Number of X positions **************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'number of x positions' then
     numXPos :=  strtoint(bB.RightSideOfEqual(tstr1)) ;  //  = 800-1800 cm-1

   // ********************** Number of Y positions  ******************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'number of y positions' then
     numYPos :=  strtoint(bB.RightSideOfEqual(tstr1)) ;

  // ********************** peak1Range range  **************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'peak1 range' then
     peak1Range :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

   if pos(' ',trim(peak1Range)) > 0 then
     peak1RangeIsPositon := false
   else
     peak1RangeIsPositon := true ;

   // ********************** peak2Range range  **************************************
   repeat
     inc(lineNum) ;
     tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
   until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
   if bB.LeftSideOfEqual(tstr1) = 'peak2 range' then
     peak2Range :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

   if pos(' ',trim(peak1Range)) > 0 then
     peak2RangeIsPositon := false
   else
     peak2RangeIsPositon := true ;


  // ********************** Pixel spacing ******************************************
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'pixel spacing x' then
    pixelSpacingX :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.
  repeat
    inc(lineNum) ;
    tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
  until (trim(tstr1) <> '') or (lineNum > tStrList.Count)  ;
  if bB.LeftSideOfEqual(tstr1) = 'pixel spacing y' then
    pixelSpacingY :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.


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
    actualDepth :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.
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


{
function  TAreaRatio.ProcessAreaRatioData( lc : pointer ) : boolean ;  // lc is pointer to TGLLineColor object
begin



end ;   }




end.
 
