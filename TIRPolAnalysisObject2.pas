unit TIRPolAnalysisObject2 ;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, PCAResultsObject,
  TMatrixObject, TSpectraRangeObject, TBatch, TMaxMinObject ;

type
	TDataModule1= class(TObject)
end ;


type
  TIRPolAnalysis2  = class(TBatchMVA)
  public
     numX, numY : integer ;
     numAngles : integer ;
     angleFloatStrm : TMemoryStream; // contains angles at which polariser was set (in Degrees)
     totalSamples : integer ; // = numX * numY * numAngles
     actualDepth : single ;
     pixelSpacing : single ;
     normaliseDepth : boolean ;
     boneToSurface : boolean ;  // bone to surface = true surface to bone = false

     // these values determine if we should 'flip' the eigenvector and scores
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     // TSpectraRanges objects for graphing. These objects will be stored in StringGrid1.Objects[] cells.
     // For 1D line scan data these are simple X-Y plots of 'value Vs Position'
     anglePlot: TSpectraRanges ;
     rangePlot : TSpectraRanges ;
     offsetPlot : TSpectraRanges ;
     RPlot : TSpectraRanges ;
     integratedAbs : TSpectraRanges ;

     tPCAnalysis : TPCA ;

     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free;

     function  GetIRPolBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ; // get input data from memo1 text. Returns final line number of String list
     function  GetAnglesAsFloatStream(angleStr : string) : TMemoryStream ;  // Used by GetIRPolBatchArguments;

     function  ProcessIRPolData( lc : pointer ) : boolean ;
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : boolean ; override  ; // TBatch virtual method

     // return value is angle of first peak maximum => the angle of maximum absorption
     function FitSineData(xyData : TMatrix; frequency : single; minStep : single) : TMatrix ;
     function SumOfSquaresOfDifferences(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : single ;
     function SumOfSquaresOfDirection(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : integer ;

     function  ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;  // this is identical to  AutoExcludeData()
     function  AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix;
  private
end;


implementation

uses fileinfo { needed for StatusBar1 access };

constructor TIRPolAnalysis2.Create(SDPrec : integer) ;
begin
   angleFloatStrm := TMemoryStream.Create ;
   allXData := TSpectraRanges.Create(SDPrec,0,0,nil) ;
   tPCAnalysis := TPCA.Create(SDPrec) ;
   inherited Create;
end ;

destructor TIRPolAnalysis2.Destroy ;
begin
   angleFloatStrm.Free ;

   anglePlot.Free ;
   rangePlot.Free ;
   offsetPlot.Free ;
   RPlot.Free ;

   tPCAnalysis.Free ;
//   allXData.Free ;
   inherited Destroy;
end ;

procedure TIRPolAnalysis2.Free;
begin
 if Self <> nil then
   Destroy;
end;


function TIRPolAnalysis2.GetAllXData( interleavedOrBlocked : integer; sourceSpecRange : TSpectraRanges ) : boolean ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1 i.e. single angle, all positions) or block structure (interleavedOrBlocked =2, all angles, single position)
var
  t1, t2, t3 : integer ;
  tFirstSpectra, currentSpectra : integer ;
  yVarRangeString : string ;
  tMat : TMatrix ;
  s1 : single ;
  d1 : double ;
begin
//  allXData
  result := false ;
  
  tFirstSpectra := firstSpectra ;
  tMat := TMatrix.Create(allXData.xCoord.SDPrec div 4) ;

  try

  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
        MessageDlg('TIRPolAnalysis2.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ; ;
  end ;


  if interleavedOrBlocked = 1 then   // interleaved (i.e. spectra at single position are seperated)
  begin
  for t1 := 1 to  numY do // for y each pixel
  begin
  for t2 := 1 to  numX do // for x each pixel
  begin
    // *****************   Set which spectra are at same x,y position *****************
    yVarRangeString := '' ;
    currentSpectra := tFirstSpectra ;
    yVarRangeString :=  inttoStr(currentSpectra) ;
    for t3 := 1 to numAngles-1 do
    begin
       currentSpectra := currentSpectra + ( numX * numY ) ;
       yVarRangeString := yVarRangeString +','+ inttoStr(currentSpectra) ;
    end ;
    inc(tFirstSpectra) ;

    // *****************   Get the data and copy to allXData TMatrix *****************
    tMat.FetchDataFromTMatrix( yVarRangeString, xVarRange , sourceSpecRange.yCoord ) ;
    allXData.yCoord.numCols :=  tMat.numCols ;
    allXData.yCoord.AddRowsToMatrix(tMat,1,tMat.numRows) ;
  end ;
  end ;
  end
  else
  if interleavedOrBlocked = 2 then    // just get the block of data 
  begin
     yVarRangeString := inttostr( firstSpectra ) +'-'+ Inttostr(numX * numAngles) ;
     allXData.yCoord.FetchDataFromTMatrix( yVarRangeString, xVarRange, sourceSpecRange.yCoord) ;
  end ;

  allXData.xString := sourceSpecRange.xString ;
  allXData.yString := sourceSpecRange.yString ;
  allXData.xCoord.numCols :=  allXData.yCoord.numCols ;
  allXData.xCoord.numRows := 1 ;
  allXData.xCoord.Filename := resultsFileName ;
  allXData.xCoord.F_Mdata.SetSize(allXData.xCoord.numCols * allXData.xCoord.numRows * allXData.xCoord.SDPrec) ;
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


  if flipRange <> '' then
  begin
      if pos(' ',trim(flipRange)) > 0 then  // check for ' cm-1' or other unit (if no unit the assume it is a variable range - in range of 'xVarRange' (should test for that))
        self.flipRange :=  bB.ConvertValueStringToPosString(flipRange, allXData.xCoord) ;
      if  self.flipRange = '' then
      begin
        MessageDlg('TIRPolAnalysis2.GetAllXData() Error...'#13'flipRange range is out of data range: '+xVarRange,mtError, [mbOK], 0)  ;
        result := false ;
        exit ;
      end ; ;
  end ;

  result := true ;
  finally
  tMat.Free ;
  end ;
end ;


function TIRPolAnalysis2.GetAnglesAsFloatStream(angleStr : string) : TMemoryStream ;
var
  t1, t2, tNumCols, tcol : integer ;
  delimeter, tStr2 : string ;
  ts1 : single ;
begin
    result := TMemoryStream.Create ;

    t1 := pos(',',angleStr) ;  // start choosing delimeter
    if t1 > 0 then
       delimeter :=   ','    // comma
    else
    begin
         t1 := pos(#32,angleStr)  ;
         if t1 > 0  then delimeter :=  #32    // space
         else
         begin
           t1 := pos(#9,angleStr)  ;
           if t1 > 0 then delimeter :=   #9     // tab
           else
           begin
              messagedlg('Delimeter is not comma, space or tab' ,mtError,[mbOK],0) ;
              exit ;  // have to free result TmemoryStream in calling code.
           end ;
          end ;
    end ;   // end choosing delimeter

    tNumCols := 0 ;
    inc(tNumCols) ;
    tStr2 := angleStr ;
    t1 := pos(delimeter,tStr2)+1 ;
    while t1 > 1 do
    begin
       t2 := length(tStr2) ;
       tStr2 := copy(tStr2,t1,t2) ;
       tStr2 := trim(tStr2) ;
       t1 := pos(delimeter,tStr2)+1 ;
       inc(tNumCols) ;
    end ;

    result.SetSize(tNumCols*4) ;

    for tcol := 0 to tNumCols-1 do
      begin
          angleStr := trim(angleStr) ;
          t1 := pos(delimeter,angleStr) ;
          t2 := length(angleStr) ;
          if tcol < tNumCols-1 then
            tStr2 := copy(angleStr,1,t1-1)
          else
            tStr2 := angleStr ;
          angleStr := copy(angleStr,t1+1,t2) ;
          if length(tStr2) > 0 then
          begin
            ts1 := strtofloat(tStr2) ;
            result.Write(ts1,4) ;
          end ;
      end ;
end ;



function TIRPolAnalysis2.GetIRPolBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : integer ;
// lineNum : is the line number of the input batch text list (tStrList) that we are reading in.
// iter : used for code error messages
// tStrList : is the string list we are getting lines from
var
   t2 : integer ;
   tstr1, tstr2, anglesStr  : string ;
   resBool : boolean ;

{File input is of this format:

   type = IRPOL  // Does PCA on each analysis point then fits cos^2 to scores') ;
   number of x positions = 17') ;
   number of y positions = 1') ;
   interleaved = 1  // (or 2)') ;
   start row = 1') ;
   pcs to fit = 1-2') ;
   x var range = 800-1800 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') ;
   num angle = 13') ;
   angles = 0,15,30,45,60,75,90,105,120,135,150,165,180') ;
   pos or neg range = 1200-1260 cm-1  // can be variable number or value found in x coordinate (space essential between value and units) ') 
   positive or negative = negative') ;
   autoexclude = 0.0   // 0.75 ') ;
   exclude from PCs = 0  // 1') ;
   pixel spacing = 75  // distance between pixels') ;
   bone to surface = true  // distance between pixels') ;
   actual depth = 0  // depth in mm') ;
   normalise depth = false  // 1') ;
   mean centre = true') ;
   column standardise = false') ;
   normalised output = false') ;
   results file = IR_pol.out') ;

}
begin
   //messagedlg('the analysis type is: ' + lowerCase(trim(copy(tstr1,pos('=',tstr1)+1,length(tstr1)-length(copy(tstr1,1,pos('=',tstr1)))))) ,mtinformation,[mbOK],0) ;

             // **********************  load data file into TRegression object ******************************************
            { inc(lineNum) ;
             "filename"   has been removed
             tstr1 := tStrList.Strings[lineNum] ;   // should be 'data file = xxxxxxx', where xxxxxxx = data loaded OR xxxxxxx = c:\...\filename.ext
             tFilename := trim(copy(tstr1,pos('=',tstr1)+1,length(tstr1)-length(copy(tstr1,1,pos('=',tstr1))))) ;
              }
             // ********************** load number of x positions (number of 'pixels' in x direction) ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of x positions' then
               numX :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load number of y positions (number of 'pixels' in y direction) ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'number of y positions' then
               numY :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load if source data is interleaved or 'blocked' ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'interleaved' then
               interleaved :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load start row (inputMatStartRow) ************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'start row' then
               firstSpectra :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load number of PCs to fit sine curve to ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pcs to fit' then
               PCsString :=  bB.RightSideOfEqual(tstr1) ;

             // ********************** load x variable range ******************************************
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

             // ********************** load number of angles  ******************************************
             inc(lineNum) ;
             tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             if bB.LeftSideOfEqual(tstr1) = 'num angle' then
               numAngles :=  strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************** load angles of polariser  ******************************************
             inc(lineNum) ;
             tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             if bB.LeftSideOfEqual(tstr1) = 'angles' then
             begin
               anglesStr :=  bB.RightSideOfEqual(tstr1) ;
               if length(anglesStr) > 0 then
                 angleFloatStrm :=  GetAnglesAsFloatStream(anglesStr) ;
               if (angleFloatStrm.Size div 4) <> numAngles then
                 begin
                   messagedlg('Number of angles ('+inttostr(numAngles)+') did not equal number in list ('+ inttostr(angleFloatStrm.Size div 4)+') (iteration = '+inttostr(iter)+')' ,mtinformation,[mbOK],0) ;
                   exit ;
                 end ;
             //  inc(t1) ;
             end ;

             // ********************** flips eigenvectors and scores if section of eigenvector is 'positive' in this range ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pos or neg range' then
               flipRange :=  (bB.RightSideOfEqual(tstr1)) ;  //
             // ********************** positive or negative - if the range above is not this then 'flip' ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'positive or negative' then
             begin
               if bB.RightSideOfEqual(tstr1) = 'positive' then
                positive := true
              else
               if bB.RightSideOfEqual(tstr1) = 'negative' then
                positive := false  ;
             end ;

             // ********************** Auto exclude outliers - proportion of deviation ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'autoexclude' then
               autoExclude :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  //
             // ********************** Auto exclude outliers from specified PCs ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'exclude from pcs' then
               excludePCsStr :=  bB.RightSideOfEqual(tstr1) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.

             // ********************** Pixel spacing ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'pixel spacing' then
               pixelSpacing :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.

             // ********************** bone to surface = true surface to bone = false ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'bone to surface' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   boneToSurface := true
                else
                   boneToSurface :=  false ;
             // ********************** Actual depth ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'actual depth' then
               actualDepth :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  // so, if an outlier exists in any of these PCs, then the spectra are excluded and the PCA redone.
             // ********************** normalise Depth ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'normalise depth' then
               if bB.RightSideOfEqual(tstr1) = 'true'  then
                   normaliseDepth := true
                else
                   normaliseDepth :=  false ;
                    
             // ********************** Mean Centre ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'mean centre' then
             begin
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   meanCentre := true
                else
                   meanCentre :=  false ;
             end ;
             // ********************** Column Centred ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'column standardise' then
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   colStd := true
                else
                   colStd :=  false ;

              // ********************** normalised output of scores and EVects ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'normalised output' then
                if bB.RightSideOfEqual(tstr1) = 'true'  then
                   normalisedEVects := true
                else
                   normalisedEVects :=  false ;
             // ********************** Get output filename 'resultsFile' ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'results file' then
               resultsFileName :=  bB.RightSideOfEqual(tstr1) ;

             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (lineNum>=tStrList.Count)  ;

             // ********************** Do PCA and fit Sine curve - call ProcessIRDaPolData
             totalSamples := numX * numY * numAngles ;

             result := lineNum ;

end ;




function TIRPolAnalysis2.ProcessIRPolData(  lc : pointer ) : boolean ;
// lc : pointer  is pointer to TGLLineColor GLFloat array
{ These are the old input parameters for this function that are now members of the TIRPolAnalysis object:
   numX, numY, firstSpecta : integer; xVarRange, PCsString,
   resultsFileName : string; angleFloatStrm : TMemoryStream; autoExclude : single;
   excludeIter : integer;  meanCentre, colStd : boolean
}
var
  t1, t2, t3, t4, t5, t6, t7, t8: integer ;
  lineNum : integer ;

  currentFirstSpectra : integer ;
  rowsToFetchString : string ;
  exclusionString : string ;
  numIfExcluded : integer ; // return number of spectra to be included in PCA if exclusion is on
  exclusionNumsStrm, exclusionNumsStrm2, tExclusionNumsStrm, cpExclusionNumsStrm : TMemoryStream ;
  PCsToDoExclStrm : TMemoryStream ;
  exclusionInt, PCofInterest : integer ;
  inMatrix : boolean ;

  s1, s2 : single ;
  pcsToFitMemStrm : TMemoryStream ;
  highestPC, numPCs : integer ;

  max_angle, range, offset, r_sqrd : single ;
  tMat, tmat2, autoExMat, resMat : TMatrix ;
  ts1, ts2, angleUsed, avearge1 : single ;
  tstring : string ;
  d1, d2 : double ;
  tjump : integer ;

begin
try
try
  result := false ;
  // ******   Determine number of PCs to create (can not be greater than number of angles at each position)  *******
  pcsToFitMemStrm := TMemoryStream.Create ;
  tMat := TMatrix.Create2(1,numAngles,1) ;  // numAngles is equal to number of spectra in each PCA (= num rows in scores matrix)
  autoExMat :=  TMatrix.Create2(1,numAngles,1) ;

  // t2 is not needed (= total number of numbers in range provided)
  t2 := tMat.GetTotalRowsColsFromString(PCsString, pcsToFitMemStrm) ; // number of PCs to fit

  pcsToFitMemStrm.Seek(-4,soFromEnd) ;
  pcsToFitMemStrm.Read(numPCs,4) ; // read final number in range
  numPCs := numPCs + 1 ;    // add one because the numbers returned are zero based
  if numPcs > numAngles then
  begin
    messagedlg('Function ProcessIRPolData() failed. Have to exit batch process, number of PCs wanted greater than number of spectra' ,mtError,[mbOK],0) ;
    exit ;
  end ;

  if (numX = 1) and (numY > 1) then
  begin
    numX := numY ;
    numY := 1 ;
  end ;


  // ******   Create TSpectraRanges for display of data *******
  // 1/ simple X-Y data : variable Vs Position
  anglePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY*numPCs, numX , lc)  ;   // numX = number of positions data collected from
  rangePlot      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY*numPCs, numX , lc)  ;
  offsetPlot     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY*numPCs, numX , lc)  ;
  RPlot          := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY*numPCs, numX , lc)  ;
  integratedAbs  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numY*numPCs, numX , lc)  ;

  // 2/ 'blocked' multi Y format data
  scoresSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numX * numY * numPCs * 2 , numAngles, lc )  ; // x2 due to scores & fit data being included
  eigenVSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, numX * numY * numPCs     , allXData.yCoord.numCols, lc )  ;


  // *************** SET X DATA ********************
  // 1/ add position value to each 'value-pos' type of TSpectraRanges object
  if boneToSurface then
  begin
    ts1 := pixelSpacing * (numX -1) ; //xxxx   added -1 to the numX bit
    pixelSpacing := pixelSpacing * -1 ;
  end
  else
  begin
    ts1 := 0 ;
  end ;
  if (actualDepth = 0)  then
  begin
    normaliseDepth := false ;
  end ;

  for t1 := 0 to numX -1 do   // need to add multi Y data if numY > 1
  begin
    ts2 := ts1 + ( t1 * pixelSpacing)  ;
    if normaliseDepth then
       ts2 := ts2 / actualDepth ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
      anglePlot.xCoord.F_Mdata.Write(ts2,4) ;
      rangePlot.xCoord.F_Mdata.Write(ts2,4) ;
      offsetPlot.xCoord.F_Mdata.Write(ts2,4) ;
      RPlot.xCoord.F_Mdata.Write(ts2,4) ;
      integratedAbs.xCoord.F_Mdata.Write(ts2,4) ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      d2 :=   ts2 ;
      anglePlot.xCoord.F_Mdata.Write(d2,8) ;
      rangePlot.xCoord.F_Mdata.Write(d2,8) ;
      offsetPlot.xCoord.F_Mdata.Write(d2,8) ;
      RPlot.xCoord.F_Mdata.Write(d2,8) ;
      integratedAbs.xCoord.F_Mdata.Write(d2,8) ;
    end
  end ;

  allXData.SeekFromBeginning(3,1,0) ;
  eigenVSpectra.SeekFromBeginning(3,1,0) ;
  // 2/ add angles x-coord to scores matrix
  angleFloatStrm.Seek(0,soFromBeginning) ;
  for t1 := 1 to numAngles do
  begin
    angleFloatStrm.Read(ts1,4) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
      scoresSpectra.xCoord.F_Mdata.Write(ts1,4) ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      d1 := ts1 ;
      scoresSpectra.xCoord.F_Mdata.Write(d1,8) ;
    end
  end ;
  // add wavelength values as xCoord for EVects matrix storage
  for t1 := 1 to allXData.yCoord.numCols do
  begin
    if self.allXData.xCoord.SDPrec = 4 then
    begin
      allXData.xCoord.F_Mdata.Read(ts1,4) ;
      eigenVSpectra.xCoord.F_Mdata.Write(ts1,4) ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      allXData.xCoord.F_Mdata.Read(d1,8) ;
      eigenVSpectra.xCoord.F_Mdata.Write(d1,8) ;
    end
  end ;

  //  ************  seek from beginning ******************
  anglePlot.SeekFromBeginning(3,1,0) ;
  rangePlot.SeekFromBeginning(3,1,0) ;
  offsetPlot.SeekFromBeginning(3,1,0) ;
  RPlot.SeekFromBeginning(3,1,0) ;
  integratedAbs.SeekFromBeginning(3,1,0) ;
  scoresSpectra.SeekFromBeginning(3,1,0) ;
  eigenVSpectra.SeekFromBeginning(3,1,0) ;



  //  ************  start PCA and Sine fit section ******************
  currentFirstSpectra := 1 ;
  tExclusionNumsStrm := TMemoryStream.Create ;
  exclusionNumsStrm := TMemoryStream.Create ;  // this is filled with integer values of positions of indicated by string 'exclusionString'
  cpExclusionNumsStrm := TMemoryStream.Create ;
  exclusionNumsStrm2 := TMemoryStream.Create ;
  PCsToDoExclStrm := TMemoryStream.Create ;

  for t1 := 1 to  numY do // for y each pixel
  begin
  for t2 := 1 to  numX do // for x each pixel
  begin
    // *****************   Get the data from 'block' formated matrix and do PCA  *****************
    rowsToFetchString := inttostr(currentFirstSpectra) + '-' + inttostr(currentFirstSpectra + self.numAngles - 1) ;

    // **** allXData is a 'position major' matrix ****
    tPCAnalysis.XMatrix.FetchDataFromTMatrix(rowsToFetchString, '1-'+inttostr(self.allXData.yCoord.numCols) ,self.allXData.yCoord) ;  // **** allXData is a 'position major' matrix **** i.e. all angles for a single position are in a 'block'

    // **** write the average of the area that is being analysed into its own SpectraRange
    tPCAnalysis.XMatrix.Average ;
    s2 := 0.0 ;
    tPCAnalysis.XMatrix.F_MAverage.Seek(0,soFromBeginning) ;
    for t3 := 1 to tPCAnalysis.XMatrix.numCols do
    begin
       tPCAnalysis.XMatrix.F_MAverage.Read(s1,4) ;
       s2 := s2 + s1 ;
    end ;
   // s2 := s2 / 100 ;  // normalise it in batchEdit code
    integratedAbs.yCoord.F_Mdata.Write(s2,4) ;
    tPCAnalysis.XMatrix.F_MAverage.Seek(0,soFromBeginning) ;


    // *****************   do PCA on copy of X matrix (i.e. XResiduals) *****************
    tPCAnalysis.XResiduals.CopyMatrix(tPCAnalysis.XMatrix) ;
    tPCAnalysis.PCA(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd) ; // this does PCA

    // Clear data
    tPCAnalysis.XResiduals.ClearData(tPCAnalysis.XResiduals.SDPrec div 4) ;  // clear what is left as we can recalculate them if wanted


    // ***************** EXCLUSION CODE *****************************************************
    numIfExcluded := numAngles ;
    if autoExclude <> 0.0 then
    begin
      t4 := tPCAnalysis.XResiduals.GetTotalRowsColsFromString(excludePCsStr, PCsToDoExclStrm) ; // this is done to pick which PCs to test for exclusion of spectra
      PCsToDoExclStrm.Seek(0,soFromBeginning) ;

      for t3 := 1 to t4 do   // test  PC for exclusion
      begin;
        PCsToDoExclStrm.Read(PCofInterest,4) ;  // T5 is the PC of interest (see part /2 below)
        PCofInterest := PCofInterest + 1 ;
        // ********************  SET UP THE tMat TMatrix **************************
        tMat.Free ; // this holds a single set of Scores at each angle
 //       tMat := TMatrix.Create2(1,numIfExcluded,1) ;  // # of rows =  numIfExcluded (= numAngles on first iteration) => single column vector
        tMat := TMatrix.Create2(1,numAngles,1) ;  // # of rows =  numIfExcluded (= numAngles on first iteration) => single column vector
        tMat.F_Mdata.Seek(0, soFromBeginning) ;

        // 1/ create and add x data (angle, in radians)
        angleFloatStrm.Seek(0, soFromBeginning) ;
        for  t5 := 1 to numAngles do
        begin
          angleFloatStrm.Read(s1,4) ;
          s2 := (s1/180) * Pi ;
          tMat.F_Mdata.Write(s2,4) ;
        end ;
        // 2/ add y data  - the PCA scores for the PC of interest (t3)
        if normalisedEVects = true then  // output to screen can be normalised or unnormalised
          tMat.AddColumnsToMatrix('1-'+inttostr(tPCAnalysis.ScoresNormalised.numRows),  inttostr(PCofInterest),  tPCAnalysis.ScoresNormalised)
        else
          tMat.AddColumnsToMatrix('1-'+inttostr(tPCAnalysis.Scores.numRows),  inttostr(PCofInterest),  tPCAnalysis.Scores) ;

        // ********************  Test for spectra needing to be excluded **************************
        exclusionString := ReturnExclusionString(tMat,autoExclude,2) ;  // autoExclude = number of stddevs that points have to be within not to be excluded
        numIfExcluded := tMat.GetTotalRowsColsFromString(exclusionString, tExclusionNumsStrm) ;  // exclusionNumsStrm is used below to store output in

        exclusionNumsStrm.Seek(0,soFromBeginning) ;
        tExclusionNumsStrm.Seek(0,soFromBeginning) ;

        if t3 = 1 then // first PC of interest
          exclusionNumsStrm.LoadFromStream(tExclusionNumsStrm)
        else
        begin
          for t5 := 1 to tExclusionNumsStrm.Size div 4 do
          begin
            inMatrix := false ;
            tExclusionNumsStrm.Read(t7,4) ;
            for t6 := 1 to exclusionNumsStrm.Size div 4 do
            begin
               exclusionNumsStrm.Read(t8,4) ;
               if (t7 = t8) then
               begin
                  inMatrix := true ;
               end ;
            end ;
            if inMatrix then
            begin
              cpExclusionNumsStrm.SetSize(cpExclusionNumsStrm.Size + 4) ;
              cpExclusionNumsStrm.Write(t7,4) ;
            end ;
            exclusionNumsStrm.Seek(0,soFromBeginning) ;
          end ;
          exclusionNumsStrm.Clear ;
          cpExclusionNumsStrm.Seek(0,soFromBeginning) ;
          exclusionNumsStrm.LoadFromStream(cpExclusionNumsStrm) ;
        end ;

      end  ;  // for each PC of interest

      exclusionString := '' ;
      exclusionNumsStrm.Seek(0,soFromBeginning) ;
      for t4 := 1 to exclusionNumsStrm.Size div 4 do
      begin
        exclusionNumsStrm.Read(t5,4) ;
        exclusionString := exclusionString + inttostr(t5+1) + ',';
      end ;
      // remove last comma
      exclusionString := copy(exclusionString,1,length(exclusionString)-1) ;
      numIfExcluded :=   exclusionNumsStrm.Size div 4 ;


      // ******** IF THERE IS A SPECTRA TO EXCLUDE => REDO PCA WITHOUT SPECTRA *****************
      if numIfExcluded <> numAngles then
      begin
          tPCAnalysis.ClearResults ;
          tPCAnalysis.XResiduals.FetchDataFromTMatrix(exclusionString, '1-'+inttostr(tPCAnalysis.XMatrix.numCols) ,tPCAnalysis.XMatrix) ;  // **** allXData is a 'position major' matrix **** i.e. all angles for a single position are in a 'block'

          // *****************   do PCA on copy of XResiduals without the excluded spectra *****************
          if  (tPCAnalysis.XResiduals.numRows <> 0) and (tPCAnalysis.XResiduals.numCols <> 0) then
            tPCAnalysis.PCA(tPCAnalysis.XResiduals, numPCs, meanCentre, colStd)  // this does PCA
          else
            raise(Exception.Create('error due to auto exclusion - try raising threshold')) ;
          // Clear data
          tPCAnalysis.XResiduals.ClearData(tPCAnalysis.XResiduals.SDPrec div 4) ;  // clear what is left as we can recalculate them if wanted

      end ;

    end
    else
    begin
        // Write all poitions of scores to be included (0 based)
        exclusionNumsStrm.SetSize(tPCAnalysis.XMatrix.SDPrec * numAngles) ;
        exclusionNumsStrm.Seek(0,soFromBeginning) ;
        for t3 := 0 to numAngles-1 do
         begin
           exclusionNumsStrm.Write(t3,4) ;
         end ;
         // numIfExcluded := numAngles ; // this is done above
    end ;


 // set relevent positions to 1 or 0 (in set or out of set)
    exclusionNumsStrm2.LoadFromStream(exclusionNumsStrm) ;
    exclusionNumsStrm2.Seek(0,soFromBeginning) ;
    t6 := 1 ;
    cpExclusionNumsStrm.Clear ;
    cpExclusionNumsStrm.SetSize(4 * numAngles) ;
    cpExclusionNumsStrm.Seek(0,soFromBeginning) ;
    t5 := 0 ;
    for t4 := 1 to numAngles do
    begin
      cpExclusionNumsStrm.Write(t5,4) ;
    end ;
    exclusionNumsStrm.Seek(0,soFromBeginning) ;
    cpExclusionNumsStrm.Seek(0,soFromBeginning) ;
    for t4 := 1 to numIfExcluded do
    begin
      exclusionNumsStrm.Read(t5,4) ;
      cpExclusionNumsStrm.Seek(t5*4,soFromBeginning) ;
      cpExclusionNumsStrm.Write(t6,4) ;
    end ;
    exclusionNumsStrm.Clear ;
    exclusionNumsStrm.LoadFromStream(cpExclusionNumsStrm) ;
    exclusionNumsStrm.Seek(0,soFromBeginning) ;

    // ***************** END EXCLUSION CODE *****************************************************


//    tPCAnalysis.Scores.SaveMatrixDataTxt('pixel2_'+inttostr(t2)+'pre2.csv',',') ;

    // *********** REORGANISE EIGENVECTOR DATA SO THEY ARE ALL THE SAME DIRECTION *****************
    if flipRange <> '' then
    begin
    for t3 := 1 to numPCs do
    begin
      if normalisedEVects = true then
        tmat2 := tPCAnalysis.EVectNormalsied
      else
        tmat2 := tPCAnalysis.EVects ;

      if tmat2.SDPrec  = 4 then
      begin
      tMat := TMatrix.Create(4) ;  // # of rows =  numAngles  => single column vector
      // **** allXData is a 'position major' matrix ****
      tMat.FetchDataFromTMatrix(inttostr(t3), flipRange ,tmat2) ;  // **** allXData is a 'position major' matrix **** i.e. all angles for a single position are in a 'block'
      tMat.Transpose ;
      tMat.Average ;
      tMat.F_MAverage.Seek(0,soFromBeginning) ;
      tMat.F_MAverage.Read(avearge1,4) ; // read the average value

      if ((positive=true) and (avearge1 < 0)) or ((positive=false) and (avearge1 > 0)) then
      begin
         tmat2.F_Mdata.Seek((t3-1)* 4 *tmat2.numCols,soFromBeginning) ;
         for t4 := 1 to tmat2.numCols do   // flip the EVects
         begin
           tmat2.F_Mdata.Read(s1,4) ;
           s1 := s1 * -1.0 ;
           tmat2.F_Mdata.seek(-4,soFromCurrent) ;
           tmat2.F_Mdata.write(s1,4) ;
         end ;

         if normalisedEVects = true then
           tmat2 := tPCAnalysis.ScoresNormalised
         else
           tmat2 := tPCAnalysis.Scores ;

         for t4 := 1 to tPCAnalysis.Scores.numRows do   // flip the scores
         begin

           tmat2.F_Mdata.Seek(((t4-1)* 4 * tmat2.numCols)+ (4 * (t3-1)),soFromBeginning) ;
           tmat2.F_Mdata.Read(s1,4) ;
           s1 := s1 * -1.0 ;
           tmat2.F_Mdata.seek(-4,soFromCurrent) ;
           tmat2.F_Mdata.write(s1,4) ;
         end ;
      end 
      else
      if tPCAnalysis.EVects.SDPrec  = 8 then
      begin
        if normalisedEVects = true then
          tmat2 := tPCAnalysis.EVectNormalsied
        else
          tmat2 := tPCAnalysis.EVects ;

      end ;
      end ;

    end ;
    end ; // flipRange = string
    // *********** END OF REORGANISE DATA  *****************

//    tPCAnalysis.Scores.SaveMatrixDataTxt('pixel2_'+inttostr(t2)+'post2xxx.csv',',') ;
//    tPCAnalysis.ScoresNormalised.SaveMatrixDataTxt('pixel2_'+inttostr(t2)+'post2_normedxxx.csv',',') ;

    currentFirstSpectra := currentFirstSpectra + self.numAngles ;    // increment the first spectra - numAngles is number of spectra in each PCA


    // *****************  For each resulting PC, fit a sine function to the PCA scores *****************
    for t3 := 1 to numPCs do
    begin
       tMat.Free ; // this holds a single set of Scores at each angle
       tMat := TMatrix.Create2(1,numIfExcluded,1) ;  // # of rows =  numAngles  => single column vector
       tMat.F_Mdata.Seek(0, soFromBeginning) ;

       // 1/ create and add x data (angle, in radians)
       angleFloatStrm.Seek(0, soFromBeginning) ;
       exclusionNumsStrm2.Seek(0,soFromBeginning) ;
       for  t4 := 1 to numIfExcluded do
       begin
          exclusionNumsStrm2.Read(t5,4) ;
          angleFloatStrm.Seek(t5*tMat.SDPrec,soFromBeginning) ;
          angleFloatStrm.Read(s1,4) ;
          s2 := (s1/180) * Pi ;
          tMat.F_Mdata.Write(s2,4) ;
       end ;
       // 2/ add y data  - the PCA scores for the PC of interest (t3)

       if normalisedEVects = true then  // output to screen can be normalised or unnormalised
         tMat.AddColumnsToMatrix('1-'+inttostr(tPCAnalysis.ScoresNormalised.numRows),  inttostr(t3),  tPCAnalysis.ScoresNormalised)
       else
         tMat.AddColumnsToMatrix('1-'+inttostr(tPCAnalysis.Scores.numRows),  inttostr(t3),  tPCAnalysis.Scores) ;

       // **************** automatically exclude data points that are greater *************
       // **************** than specified number of stddevs from surrounding points *******
       autoExMat.Free ;

       autoExMat := TMatrix.Create(4) ;
       autoExMat.CopyMatrix(tMat) ;

       if tPCAnalysis.ScoresNormalised.meanCentred then
         autoExMat.meanCentred := true ;


       // **************** Fit the data to cos(angle)^2 curve *****************************
       resMat := self.FitSineData(autoExMat,1.0, 0.0001) ;    // 2.0 = frequency  // autoExMat returns model approx of scores data
       Form4.StatusBar1.Panels[0].Text := 'pixel number = ' + inttostr(((t1-1)*numX)+t2) ;
       Form4.BringToFront ;

       // **************** add data to Scores TSpectrRanges  *************************
       // adds 2 rows to scoresSpectra matrix - row 1 is model data, row 2 is scores data
       // 'blocked' spectra in rank of position and PC : fit data interleaved with Scores data

       exclusionNumsStrm.Seek(0,soFromBeginning) ;
       resMat.F_Mdata.Seek(0,soFromBeginning) ;
       resMat.F_Mdata.Read(s1,4) ;
       resMat.F_Mdata.Seek(0,soFromBeginning) ;
       // numIfExcluded
       for t4 := 1 to numAngles do // write predicted data
       begin
          exclusionNumsStrm.Read(t5,4) ;
          if t5 = 1 then
          begin
            resMat.F_Mdata.Read(s1,4) ;
            scoresSpectra.yCoord.F_Mdata.Write(s1,4) ;
            resMat.F_Mdata.Seek(4,soFromCurrent) ;
          end
          else // t5 = 0, write the last s1 value
          begin
            scoresSpectra.yCoord.F_Mdata.Write(s1,4) ;
          end ;
       end  ;
       exclusionNumsStrm.Seek(0,soFromBeginning) ;
       resMat.F_Mdata.Seek(4,soFromBeginning) ;
       resMat.F_Mdata.Read(s1,4) ;
       resMat.F_Mdata.Seek(0,soFromBeginning) ;
       for t4 := 1 to numAngles do // write scores
       begin
          exclusionNumsStrm.Read(t5,4) ;
          if t5 = 1 then
          begin
            resMat.F_Mdata.Seek(4,soFromCurrent) ;
            resMat.F_Mdata.Read(s1,4) ;
            scoresSpectra.yCoord.F_Mdata.Write(s1,4) ;
          end
          else
          begin
            scoresSpectra.yCoord.F_Mdata.Write(s1,4) ;
          end ;
       end ;


       // **************** add data to output TSpectrRanges  *************************
       resMat.Frows.Seek(0,soFromBeginning) ;
       resMat.Frows.Read(max_angle,4) ;
       resMat.Frows.Read(range,4)  ;
       resMat.Frows.Read(offset,4) ;
       resMat.Frows.Read(r_sqrd,4) ;

       // (XYBoth : integer; spectraNum: integer; offsetBytes: integer) ;

       anglePlot.SeekFromBeginning(2,  ((t3-1)*numY)+t1 , (t2-1)*anglePlot.xCoord.SDPrec) ;    // t3 = PC number, t2 = x position of pixel
       rangePlot.SeekFromBeginning(2,  ((t3-1)*numY)+t1, (t2-1)*anglePlot.xCoord.SDPrec) ;
       offsetPlot.SeekFromBeginning(2, ((t3-1)*numY)+t1, (t2-1)*anglePlot.xCoord.SDPrec) ;
       RPlot.SeekFromBeginning(2,      ((t3-1)*numY)+t1, (t2-1)*anglePlot.xCoord.SDPrec) ;


        anglePlot.yCoord.F_Mdata.Write(max_angle,4) ;
        rangePlot.yCoord.F_Mdata.Write(range,4) ;
       offsetPlot.yCoord.F_Mdata.Write(offset,4) ;
            RPlot.yCoord.F_Mdata.Write(r_sqrd,4) ;


       resMat.Free ; // has to be freed each time FitSine() is called

     //  tjump := (numX+((t1-1)*numY)) * numAngles * 2  *  autoExMat.SDPrec  - ( 2 * numAngles * autoExMat.SDPrec) ;   // #1
       tjump := (numX*numY) * numAngles * 2  *  autoExMat.SDPrec  - ( 2 * numAngles * autoExMat.SDPrec) ;
       scoresSpectra.yCoord.F_Mdata.Seek(tjump , soFromCurrent) ;   // this position is also updated below

    end ;  // end fit data for each PC loop (t3)

    // place EVects in position/PC ranked 'blocks'
    tPCAnalysis.EVectNormalsied.F_Mdata.Seek(0,soFromBeginning) ;
    tPCAnalysis.EVects.F_Mdata.Seek(0,soFromBeginning) ;

    for t3 := 1 to numPCs do
    begin
      for t4 := 1 to tPCAnalysis.EVectNormalsied.numCols do
      begin
        if normalisedEVects = true then
          tPCAnalysis.EVectNormalsied.F_Mdata.Read(s1,4)
        else
          tPCAnalysis.EVects.F_Mdata.Read(s1,4) ;
        eigenVSpectra.yCoord.F_Mdata.Write(s1,4) ;
      end ;
      tjump := (numX*numY) * tPCAnalysis.EVectNormalsied.numCols * autoExMat.SDPrec  - (tPCAnalysis.EVectNormalsied.numCols * autoExMat.SDPrec)  ;
      eigenVSpectra.yCoord.F_Mdata.Seek( tjump , soFromCurrent) ;
    end ;
   //  tjump := (((t1-1)*numY)+t2) * tPCAnalysis.EVectNormalsied.numCols * autoExMat.SDPrec ;
    tjump := (  (  (t1-1)*numX)  +t2) * tPCAnalysis.EVectNormalsied.numCols * autoExMat.SDPrec ;
    eigenVSpectra.yCoord.F_Mdata.Seek( tjump , soFromBeginning) ;
    // tjump := (((t1-1)*numY)+t2) * numAngles * 2 * autoExMat.SDPrec ;  // #1  - works with equal x and y pixels
    tjump := (  (  (t1-1)*numX)  +t2) * numAngles * 2 * autoExMat.SDPrec ;    // #2
    scoresSpectra.yCoord.F_Mdata.Seek( tjump  , soFromBeginning) ;     // this position is also updated above

    tPCAnalysis.ClearResults ;

  end ;
  end ;

finally
begin
  tMat.Free ;
  autoExMat.Free ;
  pcsToFitMemStrm.Free ;
  tExclusionNumsStrm.Free ;
  exclusionNumsStrm.Free ; // this is filled with integer values of positions of indicated by string 'exclusionString'
  cpExclusionNumsStrm.Free ;
  exclusionNumsStrm2.Free ;
  PCsToDoExclStrm.Free ;
end ;
end ;
except

end ;

result := true ;

end ;




// xyData is list of x (= in radians, the angle of the polariser) and y values  (from PCA scores)
// Minimise sum of squares of differences between experimental and model data
function TIRPolAnalysis2.FitSineData(xyData : TMatrix; frequency : single; minStep : single) : TMatrix ;  // return value is angle (in radians) of firt peak maximum => the angle of maximum absorption
var
  t1, t2 : integer ;
  s1, s2 : single ;
//  R_i, R_f : single ;  // only need single precision version of these
  R_pearsons : single ;
  offset_scores, absolute_score, phase, range, pc10_score : single ;
  x_ymax_s, ymax, ymin : single ;
  numData : integer ;
  maxMinValue : TMaxMin ;  // this has to be disposed of at end of function
  R_matrix, modelData : TMatrix ;
  add, sub : integer ;
  iteration : integer ;
  param : integer ;
  paramStrm, paramMinimised : TMemoryStream ;
  step : single ;  // used for step value - starts at (100 * minStep) and then (10* minStep) then = minStep
  step_num : integer ; // fit is done in 3 steps, course step, medium step, fine step - flag for which step is happening
  minimised, allMinimised : boolean ;
  tstrList : TStringList ;
  max_angle : single ;
//  y_int_i, y_int_f : single ;
//  slope_i, slope_f, slope_max : single ;
//  covar_i, covar_f : single ;
  SSDiff_i, SSDiff_f : single ;
begin
  if frequency <> 0 then
  begin
    maxMinValue := xyData.GetMinAndMaxValAndPos(0, 2) ; // 0 means all rows, 2 means 2nd column

    t1 := integer((maxMinValue.GetDataPointer(4)^))-4 ;
    xyData.F_Mdata.Seek(t1 ,soFromBeginning) ; // the -4 is so we get the x data (which preceeds the max Y data position by 4 (or 8 for double) bytes)
    xyData.F_Mdata.Read(x_ymax_s, 4) ;
//    phase :=  x_ymax_s  + ((Pi /2) / frequency) ;
    phase := 0.0 ;
    range :=  (single(maxMinValue.GetDataPointer(2)^) - single(maxMinValue.GetDataPointer(1)^)) / 2  ; // ==  (ymax - ymin) / 2
    pc10_score :=  range * 0.1 ;

    absolute_score :=  single(maxMinValue.GetDataPointer(1)^)  ;
    absolute_score := abs(absolute_score) ;
    xyData.F_Mdata.Seek(4,soFromBeginning) ;
    for t1 := 1 to  xyData.numRows do
    begin                                  // offset scores so cos^2 function will fit OK (cos^2 can not fit negative values)
       xyData.F_Mdata.Read(s1,4) ;
       s1 := s1 + absolute_score + pc10_score;    // add 10% so lowest point not on zero ( take it away later )
       xyData.F_Mdata.Seek(-4,soFromCurrent) ;
       xyData.F_Mdata.Write(s1,4) ;
       xyData.F_Mdata.Seek(4,soFromCurrent) ;
    end ;

    maxMinValue.Free ; // has to be freed after creation in GetMinAndMaxValAndPos() function

    xyData.Average ;
    xyData.F_MAverage.Seek(4,soFromBeginning) ;
    xyData.F_MAverage.Read(offset_scores,4) ;

    // start of iterative minimisation
    iteration := 1 ;
    param := 1 ;
    paramStrm := TMemoryStream.Create ;
    paramStrm.SetSize(xyData.SDPrec * 4)  ;  // change 4 to the number of parameters for model
    paramStrm.Write(phase ,4) ; // was offset
    paramStrm.Write(range,4) ;
    paramStrm.Write(offset_scores,4) ;
    paramStrm.Write(frequency,4) ;
    paramStrm.Seek(0,soFromBeginning) ;
    paramMinimised := TMemoryStream.Create ;
    paramMinimised.SetSize(sizeof(integer) * 2)  ;  // change 3 to the number of parameters for model
    t2 := 0 ;
    for t1 := 1 to 3 do   //
      paramMinimised.Write(t2,4) ;  // set flag for each parameter as NOT minimised (=0)
    minimised := false ;
    step := 100 * minStep ;
    step_num := 1 ;

    SSDiff_i := SumOfSquaresOfDifferences(1,param,0.0,xyData,paramStrm,-1.0) ;

    while (iteration < 1000) and (minimised = false) do
    begin
        add := SumOfSquaresOfDirection(1,param,step,xyData,paramStrm,SSDiff_i) ;
        if add <> 0 then
        begin
          SSDiff_f := SumOfSquaresOfDifferences(add,param,step,xyData,paramStrm,SSDiff_i) ;
          while SSDiff_f < SSDiff_i do
          begin
            SSDiff_i := SSDiff_f ;
            SSDiff_f := SumOfSquaresOfDifferences(add,param,step,xyData,paramStrm,SSDiff_i) ;
          end ;
        end ;

        t2 := 1 ;
        paramMinimised.Seek((param-1)*4,soFromBeginning) ;
        paramMinimised.Write(t2,4) ; // flag this parameter as minimised
        paramMinimised.Seek(0,soFromBeginning) ;
        for t1 := 1 to 3 do  // check if all paramters minimised - changed for mean centred
        begin
           paramMinimised.Read(t2,4) ; // cycle through flags
           if t2 = 1 then
             allMinimised := true
           else
             allMinimised := false ;
        end ;
        if (allMinimised = true) and (step_num = 5) then
        begin
           minimised := true ;  // this means the minimum has been found at the step resolution indicated by minStep input variable
        end
        else  if  (allMinimised = true) then
        begin
           step := step / 10 ;
           inc(step_num) ;
           t2 := 0 ;
           paramMinimised.Seek(0,soFromBeginning) ;
           for t1 := 1 to 3 do  // set all paramters as not minimised
             paramMinimised.Write(t2,4) ;

             // *** ADD TO STOP INVERTED DATA  ******
           paramStrm.Seek(0,soFromBeginning) ;
           paramStrm.Read(phase ,4) ;
           paramStrm.Read(range,4) ;
           paramStrm.Read(offset_scores,4) ;

           xyData.F_Mdata.Seek(0, soFromBeginning) ;  // xydata is <angle (in radians)><PCA score>
           modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;
           modelData.F_Mdata.Seek(0,soFromBeginning) ; // modelData is <predicted data><PCA score> pairs
           for t1 := 1 to xyData.numRows do
           begin
              xyData.F_Mdata.Read(s1,4) ;  // read the angle
              s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
              s2 := range* s2 * s2 ;
              s2 := s2 {- pc10_score} {+ offset_scores - absolute_score } ;               // add the original offset to the model data
              modelData.F_Mdata.Write(s2, 4) ;         // write the model data
              xyData.F_Mdata.Read(s2, 4) ;             // read the original scores data
              s2 := s2 {-pc10_score} { -  absolute_score}  ;
              modelData.F_Mdata.Write(s2, 4) ;         // write the original scores data
           end ;
           xyData.F_Mdata.Seek(0, soFromBeginning) ;
           modelData.F_Mdata.Seek(0, soFromBeginning) ;

           R_matrix := tPCAnalysis.vcv.GetVarCovarMatrix(modelData) ;  // simple matrix multiply to end with symmetric matrix
           tPCAnalysis.vcv.StandardiseVarCovar(R_matrix) ;  // returns 'Pearsons R matrix' or the 'correlation' matrix
           R_pearsons :=  tPCAnalysis.vcv.ReturnPearsonsCoeffFromStandardisedVarCovar(R_matrix,1,2) ; // this is the R value for data
           // ***** THIS IS IMPORTANT BIT ******
           if R_pearsons < 0 then
           begin
              phase := phase + (pi/4) ;
              paramStrm.Seek(0,soFromBeginning) ;
              paramStrm.Write(phase ,4) ;
           end ;
           R_matrix.Free ;
           modelData.Free ;
           // *** END ADD TO STOP INVERTED DATA  ******

        end ;
        // continue with next parameter
        inc(param) ; // this is added from where it was right at start of loop
        if param > 3 then param := 1 ; // this is added from where it was right at start of loop  - changed for mean centred

      inc(iteration) ;
    end ;

    // create fitted model data
    paramStrm.Seek(0,soFromBeginning) ;
    paramStrm.Read(phase ,4) ;
    paramStrm.Read(range,4) ;
    paramStrm.Read(offset_scores,4) ;

    xyData.F_Mdata.Seek(0, soFromBeginning) ;  // xydata is <angle (in radians)><PCA score>
    modelData := TMatrix.Create2(xyData.SDPrec div 4,xyData.numRows,2) ;
    modelData.F_Mdata.Seek(0,soFromBeginning) ; // modelData is <predicted data><PCA score> pairs
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ;  // read the angle
//       s2 := range*(cos(frequency*(s1+phase))) ;// create the model data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       s2 := s2 {- pc10_score} {+ offset_scores - absolute_score } ;               // add the original offset to the model data
       modelData.F_Mdata.Write(s2, 4) ;         // write the model data
       xyData.F_Mdata.Read(s2, 4) ;             // read the original scores data
       s2 := s2 {-pc10_score} { -  absolute_score}  ;
       modelData.F_Mdata.Write(s2, 4) ;         // write the original scores data
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    modelData.F_Mdata.Seek(0, soFromBeginning) ;

    if  modelData.numRows > 1 then
    begin
      R_matrix := tPCAnalysis.vcv.GetVarCovarMatrix(modelData) ;  // simple matrix multiply to end with symmetric matrix
      tPCAnalysis.vcv.StandardiseVarCovar(R_matrix) ;  // returns 'Pearsons R matrix' or the 'correlation' matrix
      R_pearsons :=  tPCAnalysis.vcv.ReturnPearsonsCoeffFromStandardisedVarCovar(R_matrix,1,2) ; // this is the R value for data
      R_matrix.Free ;
      if R_pearsons < 0 then
//        phase := phase + (pi/2) ;
    end ;


    modelData.Frows.SetSize(4 * 4) ;  // use this to return the data with
    modelData.Frows.Seek(0,soFromBeginning) ;
    max_angle := (phase)/(pi) *180 ; //(((pi-phase)*frequency)/pi)*180 ;

    while max_angle < 0 do
      max_angle := max_angle + 180 ;
    while max_angle >= 180 do
      max_angle := max_angle - 180 ;

    max_angle := 180 - max_angle ;

    if max_angle  >= 90 then
      max_angle := max_angle - 90
    else
    if max_angle < 90 then
      max_angle := max_angle + 90 ;

    // this forces points between 0-90
    if max_angle > 90 then
    begin
      max_angle := max_angle - 180 ;
      max_angle := -1 * max_angle ;
    end ;
 {   // this wraps around high angles back to -ve eqivalents
    if max_angle > 135 then
    begin
      max_angle := max_angle - 180 ;
    end ;    }


    modelData.Frows.Write(max_angle,4) ;
    modelData.Frows.Write(range ,4) ;
    modelData.Frows.Write(offset_scores,4) ;
    modelData.Frows.Write(R_pearsons,4) ;
    result := modelData ;   // return TMatrix has to be freed when finished with in calling function
  end ;


end ;


function TIRPolAnalysis2.SumOfSquaresOfDifferences(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : single ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  SSDiff_f, param_i : single ;
  s1, s2 : single ;
  range, frequency, phase, offset : single ;
begin
    // read the parameter ;
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Read(s1,4) ;
    paramsStr.Seek(-4,soFromCurrent) ;
    param_i := s1 ;
    s1 := s1 + (direction* step) ;  // step forward or backward
    paramsStr.Write(s1,4) ;         // write the new parameter value to the parameter list (if R_f < R_i then change back to param_i at end of function)
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(phase ,4) ; // was
    paramsStr.Read(range,4) ;
    paramsStr.Read(offset,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;

    xyData.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read angle value
//       s2 := range*(cos(frequency*(s1+phase))) + offset  ;// +offset ; // create model y data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       xyData.F_Mdata.Read(s1,4) ;
       SSDiff_f := SSDiff_f + ((s1-s2)*(s1-s2)) ;
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    result :=  SSDiff_f ;

    if (SSDiff_i <= SSDiff_f) or (SSDiff_i = -1.0) then  // if step does not improve fit then place original parameter back
    begin
      // write the inital value of the paramater back
      paramsStr.Seek((param-1)*4,soFromBeginning) ;
      paramsStr.Write(param_i,4) ;
      paramsStr.Seek(0,soFromCurrent) ;
    end ;
end ;

// determine if we have to add or subtract 'step' value to minimise Sum of Squares
function TIRPolAnalysis2.SumOfSquaresOfDirection(direction, param : integer; step : single; xyData : TMatrix; paramsStr : TMemoryStream;  SSDiff_i : single) : integer ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  SSDiff_f, param_i : single ;
  s1, s2 : single ;
  range, frequency, phase, offset : single ;
begin
    // read the parameter ;
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Read(s1,4) ;
    paramsStr.Seek(-4,soFromCurrent) ;
    param_i := s1 ;
    s1 := s1 + (direction* step) ;  // step forward or backward
    paramsStr.Write(s1,4) ;
    paramsStr.Seek(0,soFromBeginning) ;

    paramsStr.Read(phase ,4) ;
    paramsStr.Read(range,4) ;
    paramsStr.Read(offset ,4) ;
    paramsStr.Read(frequency,4) ;
    SSDiff_f := 0.0 ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    for t1 := 1 to xyData.numRows do
    begin
       xyData.F_Mdata.Read(s1,4) ; // read x value
//       s2 := range*(cos(frequency*(s1+phase))) + offset ;  // create model data
       s2 :=  (cos(frequency*(s1+phase))) ;// create the model data
       s2 := range* s2 * s2 ;
       xyData.F_Mdata.Read(s1,4) ; // read x value
       SSDiff_f := SSDiff_f + ((s1-s2)*(s1-s2)) ;
    end ;
    xyData.F_Mdata.Seek(0, soFromBeginning) ;

    if direction = 1 then // direction is forward
    begin
      if SSDiff_f > SSDiff_i then result := -1
      else if SSDiff_f < SSDiff_i then result :=  1
      else result := 0 ;
    end
    else
    begin
      if SSDiff_i > SSDiff_f then result :=  1
      else if SSDiff_i < SSDiff_f then result := -1
      else result := 0 ;
    end  ;

    // write the inital value of the paramater back
    paramsStr.Seek((param-1)*4,soFromBeginning) ;
    paramsStr.Write(param_i,4) ;
    paramsStr.Seek(0,soFromCurrent) ;

end ;



function  TIRPolAnalysis2.ReturnExclusionString(inMat : TMatrix; numStddevs : single; colNum : integer) : string ;
 // only works for 2 column data
// removes data points from list that are > numStdevs away from surrounding data points
var
  t1, t2 : integer ;
  s1, s2, stdev_s : single ;
  d1, d2, stdev_d : double ;
  tStream : TMemoryStream ;
  trueFalse_f, trueFalse_b : integer ;
  rowRange : string ;

begin
   tStream := TMemoryStream.Create ;
   tStream.SetSize(4*inMat.numRows) ;

   inMat.Average;
   inMat.Stddev(true);
   inMat.F_MStdDev.Seek(inMat.SDPrec*(colNum-1),soFromBeginning) ;
   if  inMat.SDPrec = 4 then
     inMat.F_MStdDev.Read(stdev_s,inMat.SDPrec)
   else if  inMat.SDPrec = 8 then
     inMat.F_MStdDev.Read(stdev_d,inMat.SDPrec) ;

   colNum := colNum - 1 ;
   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number

   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4)
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

   // go forward through data
   trueFalse_f := 0 ;
   tStream.Seek(0,soFromBeginning) ;
   tStream.Write(trueFalse_f,4) ;

   for t1 := 1 to inMat.numRows-1 do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         if (s2 > (s1+(stdev_s*numStddevs))) or (s2 < (s1-(stdev_s*numStddevs))) then
         begin
            trueFalse_f := 1 ;
            tStream.Write(trueFalse_f,4) ;
         end
         else
         begin
            trueFalse_f := 0 ;
            tStream.Write(trueFalse_f,4) ;
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data


   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number
   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4) 
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

  // go forward through data again but compare the other way
//   rowRange := '1,' ;
   tStream.Seek(0,soFromBeginning) ;
   for t1 := 1 to inMat.numRows do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         tStream.Read(trueFalse_f,4) ;

         if (s1 > (s2+(stdev_s*numStddevs))) or (s1 < (s2-(stdev_s*numStddevs))) then
         begin
            if (trueFalse_f = 0) and (t1 <> 1) then
            begin
              rowRange := rowRange + inttostr(t1) + ',' ;
            end
         end
         else
         begin
            if (t1 <> 13) then
              rowRange := rowRange + inttostr(t1) + ','
            else if (t1 = 13) and (trueFalse_f = 0) then
              rowRange := rowRange + inttostr(t1) + ','
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data with comparison the other way

   // remove last comma
   rowRange := copy(rowRange,1,Length(rowRange)-1) ;

   // re-create Matrix, excluding unwanted data
//   for t1 := 0 to inMat.numRows


   result := rowRange ;

   tStream.Free ;
end ;


function TIRPolAnalysis2.AutoExcludeData(inMat : TMatrix; numStddevs : single; colNum : integer ) : TMatrix ;
// only works for 2 column data
// removes data points from list that are > numStdevs away from surrounding data points
var
  t1, t2 : integer ;
  s1, s2, stdev_s : single ;
  d1, d2, stdev_d : double ;
  tStream : TMemoryStream ;
  trueFalse_f, trueFalse_b : integer ;
  rowRange : string ;
  resMat : TMatrix ;
begin
   tStream := TMemoryStream.Create ;
   tStream.SetSize(4*inMat.numRows) ;

   inMat.Average;
   inMat.Stddev(true);
   inMat.F_MStdDev.Seek(inMat.SDPrec*(colNum-1),soFromBeginning) ;
   if  inMat.SDPrec = 4 then
     inMat.F_MStdDev.Read(stdev_s,inMat.SDPrec)
   else if  inMat.SDPrec = 8 then
     inMat.F_MStdDev.Read(stdev_d,inMat.SDPrec) ;

   colNum := colNum - 1 ;
   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number

   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4)
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

   // go forward through data
   trueFalse_f := 0 ;
   tStream.Seek(0,soFromBeginning) ;
   tStream.Write(trueFalse_f,4) ;

   for t1 := 1 to inMat.numRows-1 do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         if (s2 > (s1+(stdev_s*numStddevs))) or (s2 < (s1-(stdev_s*numStddevs))) then
         begin
            trueFalse_f := 1 ;
            tStream.Write(trueFalse_f,4) ;
         end
         else
         begin
            trueFalse_f := 0 ;
            tStream.Write(trueFalse_f,4) ;
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data


   inMat.F_Mdata.Seek(inMat.SDPrec*colNum,soFromBeginning) ; // get to correct column number
   // read first data point
   if  inMat.SDPrec = 4 then
     inMat.F_Mdata.Read(s1,4) 
   else if  inMat.SDPrec = 8 then
     inMat.F_Mdata.Read(d1,8) ;

  // go forward through data again but compare the other way
//   rowRange := '1,' ;
   tStream.Seek(0,soFromBeginning) ;
   for t1 := 1 to inMat.numRows do
   begin
      if  inMat.SDPrec = 4 then
      begin
         inMat.F_Mdata.Seek(inMat.SDPrec,soFromCurrent) ; // get to correct column number
         inMat.F_Mdata.Read(s2,4) ;
         tStream.Read(trueFalse_f,4) ;

         if (s1 > (s2+(stdev_s*numStddevs))) or (s1 < (s2-(stdev_s*numStddevs))) then
         begin
            if (trueFalse_f = 0) and (t1 <> 1) then
            begin
              rowRange := rowRange + inttostr(t1) + ',' ;
            end
         end
         else
         begin
            if (t1 <> 13) then
              rowRange := rowRange + inttostr(t1) + ','
            else if (t1 = 13) and (trueFalse_f = 0) then
              rowRange := rowRange + inttostr(t1) + ','
         end ;
         s1 := s2 ;
      end
      else if  inMat.SDPrec = 8 then
      begin

      end ;
   end ;  // going forward through data with comparison the other way

   // remove last comma
   rowRange := copy(rowRange,1,Length(rowRange)-1) ;

   // re-create Matrix, excluding unwanted data
//   for t1 := 0 to inMat.numRows
   resMat := TMatrix.Create(inMat.SDPrec div 4) ;
   resMat.FetchDataFromTMatrix(rowRange,'1-2',inMat) ;

   result := resMat ;

   tStream.Free ;
end ;


end.

 