unit TPCR_BatchUnit ;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses
   SysUtils, Classes, TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject,
   TMatrixOperations, TPCR_ResultsObjects, TPreprocessUnit, TASMTimerUnit ;

type
  TPCRBatch  = class
  public
     numPCsPCR : integer ;

     // the X data versions of these are inherited from TBatchMVA
     yFilename : string ;  // this where data is stored on disk
     YsampleRange : string ;  //  not needed in IR-pol of PCA units
     yVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     YinXData  : boolean ;
//     GLListNumber : integer ;
     SDPrecPCR      : integer ;  // 4 or 8 depeding on floating point precission

     resultsFileName : string;
     PCsString : string;
     firstSpectra : integer ;  // not needed in PCA, PCR, PLS... it is first value in sampleRange

     xFilename : string ; // used in command line version
     XsampleRange : string ;  //  not needed in IR-pol
     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     normalisedEVects, meanCentre, colStd : boolean ;
     xDiskEQxData  : boolean ; // if data from disk is identical to what is processed then this is 'true'
     interleaved : integer ;

     // if not empty then preprocess data with smoothing and derivatives
     smooth        :   string  ; // = average 15  // fourier 15,50 remove complex  // %,power
     derivative    :   string  ; // = fourier 2 : remove complex // fourier only available
     normaliseXPCR :   string  ;

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive  : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     bB                 : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
     pp                 : TPreprocess ;

     PCRResults         : TPCRResults  ;      // does the calculations

     allXDataPCR        : TSpectraRanges ;
     allYDataPCR        : TSpectraRanges ;  // for display in column 2 and 3 - The original data sets

     scoresSpectra      : TSpectraRanges ;
     eigenVSpectra      : TSpectraRanges ;
     eigenValSpectra    : TSpectraRanges ;  // Eigenvalue = scores(PCx)' * scores(PCx)  ==  variance of each PC
     YresidualsSpectra  : TSpectraRanges ;
     regresCoefSpectra  : TSpectraRanges ;  // X Coefficients for regression with a cirtain number of PCs for known Y values
     predictedYPCR      : TSpectraRanges ;
     R_sqrd_PCR         : TSpectraRanges ;

     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     function  GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     function  ProcessPCRBatchFile(inputX, inputY : TSpectraRanges)   : string ;  // this calls private functions and creates model
     procedure  SaveSpectra(filenameIn : string)  ;
  private
     function  DetermineNumPCs : string ;
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
     function  GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges )  : string  ; // TBatch virtual method
     function  PreProcessData  : string ; // override  ;
     function  CreatePCRDisplayData  : boolean ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
     procedure CheckResult(resultStringIn : string) ;
  end;
implementation


constructor TPCRBatch.Create(SDPrec : integer);  // need SDPrec
begin
   SDPrecPCR := SDPrec ;
   bB := TBatchBasics.Create ;
   pp := TPreprocess.Create ;
   PCRResults := TPCRResults.Create('PCR_Results.out',SDPrecPCR)  ;
   xDiskEQxData  := false ;
   YinXData := false ;
end ;


destructor  TPCRBatch.Destroy; // override;
begin

  YresidualsSpectra.Free ;
  regresCoefSpectra.Free ;
  predictedYPCR.Free ;
  R_sqrd_PCR.Free ;

  if scoresSpectra      <> nil then  scoresSpectra.Free ;
  if eigenVSpectra      <> nil then  eigenVSpectra.Free ;
  if eigenValSpectra    <> nil then  eigenValSpectra.Free ;

  bb.Free;
  pp.Free ;
  PCRResults.Free ;

end ;

procedure TPCRBatch.Free;
begin
 if Self <> nil then Destroy;
end;




{
type = PCR

// input x and y data
x sample range = 1-686     // (ROWS)
x var range = 1-520        // (COLS)

y sample range = 1-686     // (ROWS)
y var range = 1-1          // (COLS)

number of PCs = 1-20

// pre-processing
mean centre = true
column standardise = false
smooth = average,15  // fourier,15,50,remove complex  // %,power
derivative = fourier, 2, remove complex, true, 1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;

// EVects output
pos or neg range =              // 1200-1260 cm-1
positive or negative = positive
normalised EVects = true

// output
results file = PLS.out
}

function  TPCRBatch.GetBatchArguments( lineNum, iter : integer; tStrList : TStringList ) : string   ;
// return result is either:
// on success:  string version of line number
// on fail :    string of 'line number + ', error message'
// comma present indicates failure
var
 t1 : integer ;
 tstr1  : string ;
begin
       try
         result := '' ;
        // ********************** X data file name ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'x data file' then
               xFilename :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** Y data file name ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'y data file' then
               yFilename :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** X Samples ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'x sample range' then
          XsampleRange :=  bB.RightSideOfEqual(tstr1) ;

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

        // ********************** Y in X data ******************************************
         repeat
           inc(lineNum) ;
           tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
         until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
         if bB.LeftSideOfEqual(tstr1) = 'y in x data' then
         begin
           if bB.RightSideOfEqual(tstr1) = 'true'  then
             YinXData :=  true
           else
             YinXData :=  false ;
         end ;

        // ********************** Y Samples ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'y sample range' then
          YsampleRange :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** Y Variables  ******************************************
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'y var range' then
          yVarRange    :=  bB.RightSideOfEqual(tstr1) ;  //  = 800-1800 cm-1

 {       if pos(' ',trim(xVarRange)) > 0 then
          yVarRangeIsPositon := false
        else
          yVarRangeIsPositon := true ;    }



         // ********************** number of PCs ******************************************
         repeat
           inc(lineNum) ;
           tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
         until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
         if bB.LeftSideOfEqual(tstr1) = 'number of pcs' then
           PCsString :=  bB.RightSideOfEqual(tstr1) ;



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

         // ********************** smooth ******************************************
         // smooth = average,15  // fourier,15,50,remove complex  // %,power
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'smooth' then
          smooth :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** derivative ******************************************
        // derivative = "fourier, 2, remove complex, true, 1" // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;
        repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'derivative' then
          derivative :=  bB.RightSideOfEqual(tstr1) ;

        // ********************** vector normalise ******************************************
         repeat
          inc(lineNum) ;
          tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
        until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
        if bB.LeftSideOfEqual(tstr1) = 'normalise x' then
          normaliseXPCR :=  bB.RightSideOfEqual(tstr1)
        else
          result := inttostr(lineNum)  + ', input invalid: ' + bB.LeftSideOfEqual(tstr1) + ' try: normalise x = vn,pre' ;

//        if (normaliseXPCR <> 'vn')  or (normaliseXPCR <> '') then
//          result := inttostr(lineNum)  + ', normalise x input is not valid' ;

       // ********************** pos or neg range = 1200-1260 cm-1 ******************************************
       repeat
         inc(lineNum) ;
         tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
       if bB.LeftSideOfEqual(tstr1) = 'positive or negative' then
         flipRange :=  bB.RightSideOfEqual(tstr1) ;

       // **********************  positive or negative ******************************************
       repeat
         inc(lineNum) ;
         tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
       until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
       if bB.LeftSideOfEqual(tstr1) = 'autoexclude' then
       if bB.RightSideOfEqual(tstr1) = 'positive'  then
           positive := true
       else
           positive :=  false ;


       // ********************** normalised output of scores and EVects ******************************************
       repeat                     // this is not used at preset
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


//      result :=  result ;  // if result has a comma then input has failed
      if length(result) = 0 then
        result :=   inttostr(lineNum)  ;
      except on eConvertError do
      begin
         result := inttostr(lineNum) + ', PCA batch input conversion error' +  #13 ;
      end ;
      end ;
end ;





function  TPCRBatch.GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t2 : integer ;
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  // converts cm-1 or other units into range of data positions in matrix (i.e. 800-1600 cm-1  ->  228-526 )
  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
        result := 'PCR input error: x var range values not appropriate: '  + #13  ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  // set up the string of rows to collect

  // sampleRange string is open ended (e.g. '12-')
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  // if the data is exactly as recieved in sourceSpecRange then do not copy (saves memory)
  if (sourceSpecRange.yCoord.numRows = sourceSpecRange.yCoord.GetTotalRowsColsFromString(XsampleRange)) and (sourceSpecRange.yCoord.numCols = sourceSpecRange.yCoord.GetTotalRowsColsFromString(xVarRange))then
  begin
    allXDataPCR :=  sourceSpecRange ;
    xDiskEQxData := true ;
    exit ;
  end;

  // otherwise copy the data wanted
  allXDataPCR := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1) ;
  // *****************  This actually retrieves the data  ********************
  allXDataPCR.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXDataPCR.yImaginary := TMatrix.Create(allXDataPCR.yCoord.SDPrec) ;
    allXDataPCR.yImaginary.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yImaginary ) ;
  end ;

  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allXDataPCR.xString := sourceSpecRange.xString ;
  allXDataPCR.yString := sourceSpecRange.yString ;
  allXDataPCR.xCoord.numCols :=  allXDataPCR.yCoord.numCols ;
  allXDataPCR.xCoord.numRows := 1 ;
  allXDataPCR.xCoord.Filename := resultsFileName ;
  allXDataPCR.xCoord.F_Mdata.SetSize(allXDataPCR.xCoord.numCols * 1 * allXDataPCR.xCoord.SDPrec) ;
  allXDataPCR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allXDataPCR.xCoord.GetTotalRowsColsFromString(xVarRange, allXDataPCR.xCoord.Fcols) ;
  allXDataPCR.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allXDataPCR.xCoord.numCols do
  begin
     allXDataPCR.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allXDataPCR.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allXDataPCR.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;


  except
  begin
        result := 'PCR input error: fetching x data failed'   + #13 ;
  end ;
  end ;


end ;




function  TPCRBatch.GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',YsampleRange) = length(trim(YsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    YsampleRange := YsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  allYDataPCR := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1) ;

  // *****************  This actually retrieves the data  ********************
  allYDataPCR.yCoord.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allYDataPCR.yImaginary := TMatrix.Create(allYDataPCR.yCoord.SDPrec) ;
    allYDataPCR.yImaginary.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yImaginary ) ;
  end ;


  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allYDataPCR.xString := sourceSpecRange.xString ;
  allYDataPCR.yString := sourceSpecRange.yString ;
  allYDataPCR.xCoord.numCols :=  allYDataPCR.yCoord.numCols ;
  allYDataPCR.xCoord.numRows := 1 ;
  allYDataPCR.xCoord.Filename := resultsFileName ;
  allYDataPCR.xCoord.F_Mdata.SetSize(allYDataPCR.xCoord.numCols * 1 * allYDataPCR.xCoord.SDPrec) ;
  allYDataPCR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allYDataPCR.xCoord.GetTotalRowsColsFromString(yVarRange, allYDataPCR.xCoord.Fcols) ;
  allYDataPCR.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allYDataPCR.xCoord.numCols do
  begin
     allYDataPCR.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allYDataPCR.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allYDataPCR.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;

  except
  begin
        result := 'PCR input error: fetching y data failed'  + #13 ;
  end ;
  end ;

end ;


function  TPCRBatch.PreProcessData : string ;
{  meanCentre, colStd : boolean ;
   smooth       :   string   // = average 15  // fourier 15,50 remove complex  // %,power
   derivative   :   string   // = fourier 2 : remove complex // fourier only available
}

begin

     writeln('Mean Centre Y data  ') ;
     self.allYDataPCR.yCoord.MeanCentre ; // Y data has to be mean centred (i think)

     if pos('pre',normaliseXPCR) > 0 then
     begin
       writeln('Vector normalising X') ;
       allXDataPCR.yCoord.VectorNormaliseRowVects  ;
     end;

     if  meanCentre then
     begin
        writeln('Mean Centre X data  ') ;
        self.allXDataPCR.yCoord.MeanCentre ;
     end ;

     if pos('post',normaliseXPCR) > 0 then
     begin
        writeln('Vector normalising X') ;
        allXDataPCR.yCoord.VectorNormaliseRowVects  ;
     end;

     if  colStd then
       self.allXDataPCR.yCoord.ColStandardize ; // not sure what to do with y data with col standardise

     if length(trim(smooth)) > 0 then
     begin
        writeln('Smooth X data  ') ;
        result := pp.Smooth(smooth,allXDataPCR) ;
//writeln('Done') ;
     end ;

     if length(trim(derivative)) > 0 then
     begin
        writeln('Differentiate X data  ') ;
        if length(result) > 0 then
          result := result + #13 + pp.Differentiate(derivative,allXDataPCR)
        else
          result :=  pp.Differentiate(derivative,allXDataPCR)   ;
//writeln('Done ') ;
     end  ;


     if length(result) > 0 then
     result := result +  #13 ;

end ;



function  TPCRBatch.DetermineNumPCs : string ;
var
  t1 : integer ;
  pcsToFitMemStrm : TMemoryStream ;
begin
  try
    result := '' ;
    pcsToFitMemStrm := TMemoryStream.Create ;
    t1 := allXDataPCR.yCoord.GetTotalRowsColsFromString(PCsString, pcsToFitMemStrm) ; // number of PCs to fit

    pcsToFitMemStrm.Seek(-4,soFromEnd) ;
    pcsToFitMemStrm.Read(numPCsPCR,4) ; // read final number in range (don't use t1 as it is number in set, not the maximum PC needed)
    numPCsPCR := numPCsPCR + 1 ;        // add one because the numbers returned are zero based
    if numPCsPCR > allXDataPCR.yCoord.numRows then
    begin
      result :=  'Have to exit batch process, number of PCs wanted is greater than number of spectra'  ;
      pcsToFitMemStrm.free ;
      exit ;
    end ;
  except on Exception do
  begin
    pcsToFitMemStrm.free ;
    result := 'determining number of PCs for PLS analysis failed' + #13 ;
  end ;
  end ;
  pcsToFitMemStrm.free ;
end ;


procedure   TPCRBatch.CheckResult(resultStringIn : string) ;
begin
     if  length(resultStringIn) > 0 then
     begin
       writeln('ProcessPCRBatchFile failed:' + #13 + resultStringIn ) ;
       halt ;
     end ;
end ;


function  TPCRBatch.ProcessPCRBatchFile(inputX, inputY : TSpectraRanges)  : string ;  // this calls all above functions and creates model
var
  resultString : string ;
begin
   result := '' ;
   // N.B. if YinXData is true then inputX points to inputY
   try
     resultString := resultString + GetAllXData( interleaved,  inputX ) ;  //
     if (xDiskEQxData  = false) and (YinXData = false) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free ;

     resultString := resultString + GetAllYData( interleaved,  inputY ) ;
     PCRResults.YMatrix.CopyMatrix(allYDataPCR.yCoord) ;    // copy the Y data

     if (xDiskEQxData  = false) and (YinXData = true) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free
     else
       inputY.Free ;

     resultString := resultString + PreProcessData  ;
     resultString := resultString + DetermineNumPCs ;
     CheckResult(resultString) ;

     if allXDataPCR.yImaginary = nil then  // do not have code for complex data type
     begin
       // Do PCR regression
       // PCA first - allXData.yCoord will be altered (into residuals) therfore reload after
       resultString := PCRResults.DoPCAFirst(allXDataPCR.yCoord,numPCsPCR,meanCentre, colStd) ;
       CheckResult(resultString) ;

       // *** Reset and read in data again as allXData is now just residuals ***
       allXDataPCR.Free ;   // this will free inputX if 'xIsIdentical' = true
       allXDataPCR := TSpectraRanges.Create(SDPrecPCR,0,0) ;
       inputX   := TSpectraRanges.Create(SDPrecPCR,0,0) ;   // this has to be OK as inputX was freed either during GetAllXData, GetAllXData or allXData.Free above
       inputX.LoadSpectraRangeDataBinV2(Self.xFilename);
       GetAllXData( interleaved,  inputX ) ;
       if (xDiskEQxData = false) then  // input (disk) file and matrix data are identical so do not delete
         inputX.Free ;
       resultString :=  PreProcessData  ;
       CheckResult(resultString) ;

       PCRResults.CreatePCRModelSecond(allXDataPCR.yCoord, allYDataPCR.yCoord {PCRResults.YMatrix} , PCsString ) ; // PCsString has been checked

     end
     else  // data is complex
     begin
       writeln('PCR code does not accept complex data. Remove imaginary component first') ;
       exit ;
     end ;

     CreatePCRDisplayData ;  // may have problems with this
     allXDataPCR.Free ; // this will remove inputX.Free if "xDiskEQxData = true"
     allYDataPCR.Free ; // created in  GetAllYData


    except on Exception do
    begin

       result := 'Exception in PLS1 ProcessPLSBatchFile()' ;
    end ;
    end ;
end ;




function  TPCRBatch.CreatePCRDisplayData  : boolean ;
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
 tstr : string ;
begin
      // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject
    scoresSpectra     := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  allXDataPCR.yCoord.numRows , numPCsPCR                   )  ;
    eigenVSpectra   := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  numPCsPCR                  ,  allXDataPCR.yCoord.numCols )  ;
//    XresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec, allXData.yCoord.numRows ,  allXData.yCoord.numCols )  ;
    YresidualsSpectra := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,allXDataPCR.yCoord.numRows                   ,  numPCsPCR  )  ; // numPCs by number of Samples
    eigenValSpectra   := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  1                       ,  numPCsPCR                 )  ;
//    regenSpectra      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  allXData.yCoord.numRows ,  allXData.yCoord.numCols )  ;

//    modelPCRSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCsPCR                  , allXData.yCoord.numCols )  ;
    regresCoefSpectra:= TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  numPCsPCR                  , allXDataPCR.yCoord.numCols )  ;
    predictedYPCR  := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  numPCsPCR                  , allXDataPCR.yCoord.numRows )  ;
    R_sqrd_PCR       := TSpectraRanges.Create(self.allXDataPCR.yCoord.SDPrec,  1                       , numPCsPCR                  )  ;

    // 2/ ****  Copy calculated data to output display objects ****
    scoresSpectra.yCoord.CopyMatrix( PCRResults.ScoresPCR ) ;
    eigenVSpectra.yCoord.CopyMatrix( PCRResults.EVectsPCR ) ;
    eigenValSpectra.yCoord.CopyMatrix( PCRResults.EigenValues ) ;

    //    PCRResults.RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(PCRResults.EVectsPCR.numCols),meanCentre,PCRResults.XResiduals.F_MAverage) ;
//    regenSpectra.yCoord.CopyMatrix( PCRResults.XRegenMatrix ) ;
//    XresidualsSpectra.yCoord.CopyMatrix( PCRResults.XResiduals )   ;

//    modelPCRSpectra.yCoord.CopyMatrix( PCRResults.Model ) ;
    regresCoefSpectra.yCoord.CopyMatrix( PCRResults.RegressionCoef ) ;
    predictedYPCR.yCoord.CopyMatrix( PCRResults.PredictedY ) ;
    YresidualsSpectra.yCoord.CopyMatrix( PCRResults.YResidualsPCR )   ;
    R_sqrd_PCR.yCoord.CopyMatrix( PCRResults.R_sqrd_PCR ) ;


    if eigenVSpectra.yCoord.complexMat = 2 then
    begin
         scoresSpectra.yImaginary := TMatrix.Create2(scoresSpectra.yCoord.SDPrec, scoresSpectra.yCoord.numRows, scoresSpectra.yCoord.numCols ) ;
         scoresSpectra.yCoord.MakeUnComplex( scoresSpectra.yImaginary ) ;
         eigenVSpectra.yImaginary := TMatrix.Create2(eigenVSpectra.yCoord.SDPrec, eigenVSpectra.yCoord.numRows, eigenVSpectra.yCoord.numCols ) ;
         eigenVSpectra.yCoord.MakeUnComplex( eigenVSpectra.yImaginary ) ;
//         XresidualsSpectra.yImaginary := TMatrix.Create2(XresidualsSpectra.yCoord.SDPrec, XresidualsSpectra.yCoord.numRows, XresidualsSpectra.yCoord.numCols) ;
//         XresidualsSpectra.yCoord.MakeUnComplex( XresidualsSpectra.yImaginary ) ;
         YresidualsSpectra.yImaginary := TMatrix.Create2(YresidualsSpectra.yCoord.SDPrec, YresidualsSpectra.yCoord.numRows, YresidualsSpectra.yCoord.numCols) ;
         YresidualsSpectra.yCoord.MakeUnComplex( YresidualsSpectra.yImaginary ) ;
         eigenValSpectra.yImaginary := TMatrix.Create2(eigenValSpectra.yCoord.SDPrec, eigenValSpectra.yCoord.numRows, eigenValSpectra.yCoord.numCols) ;
         eigenValSpectra.yCoord.MakeUnComplex( eigenValSpectra.yImaginary ) ;
//         regenSpectra.yImaginary := TMatrix.Create2(regenSpectra.yCoord.SDPrec, regenSpectra.yCoord.numRows, regenSpectra.yCoord.numCols) ;
//         regenSpectra.yCoord.MakeUnComplex( regenSpectra.yImaginary ) ;
//         modelPCRSpectra.yImaginary := TMatrix.Create2(modelPCRSpectra.yCoord.SDPrec, modelPCRSpectra.yCoord.numRows, modelPCRSpectra.yCoord.numCols) ;
//         modelPCRSpectra.yCoord.MakeUnComplex( modelPCRSpectra.yImaginary ) ;
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predictedYPCR.yImaginary := TMatrix.Create2(predictedYPCR.yCoord.SDPrec, predictedYPCR.yCoord.numRows, predictedYPCR.yCoord.numCols) ;
         predictedYPCR.yCoord.MakeUnComplex( predictedYPCR.yImaginary ) ;
     //    R_sqrd_PLS
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)
    scoresSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
//    modelPCRSpectra.SeekFromBeginning(3,1,0) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
    for t1 := 1 to allXDataPCR.yCoord.numRows do
    begin
      if self.allXDataPCR.yCoord.SDPrec = 4 then
      begin
        s1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(s1,4) ;
//        modelPCRSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end
      else
      if self.allXDataPCR.yCoord.SDPrec = 8 then
      begin
        d1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(d1,8) ;
 //       modelPCRSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;
    // B/ add wavelength values as xCoord for EVects matrix storage
    allXDataPCR.SeekFromBeginning(3,1,0) ;
    allYDataPCR.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
//    XresidualsSpectra.SeekFromBeginning(3,1,0) ;
//    regenSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predictedYPCR.SeekFromBeginning(3,1,0) ;
    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;

    if self.allXDataPCR.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXDataPCR.yCoord.numCols do
      begin
        allXDataPCR.xCoord.F_Mdata.Read(s1,4) ;

        eigenVSpectra.xCoord.F_Mdata.Write(s1,4) ;
//        XresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
//        regenSpectra.xCoord.F_Mdata.Write(s1,4) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXDataPCR.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXDataPCR.yCoord.numCols do
      begin
        allXDataPCR.xCoord.F_Mdata.Read(d1,8) ;

        eigenVSpectra.xCoord.F_Mdata.Write(d1,8) ;
//        XresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
//        regenSpectra.xCoord.F_Mdata.Write(d1,8) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;


    // C/ create x coord data for eigenValSpectra and R_sqrd_PLS and YResiduals (one point for each PC)
    eigenValSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    YresidualsSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXDataPCR.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCsPCR do
       begin
         s1 := t1 ;
         eigenValSpectra.xCoord.F_Mdata.Write(s1,4) ;
         R_sqrd_PCR.xCoord.F_Mdata.Write(s1,4) ;
         YresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXDataPCR.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCsPCR do
      begin
        d1 := t1 ;
        eigenValSpectra.xCoord.F_Mdata.Write(d1,8) ;
        R_sqrd_PCR.xCoord.F_Mdata.Write(d1,8) ;
        YresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  // predictedYPLS
  // D/ create x coord data for predictedYPLS (one point for each sample)
    predictedYPCR.yCoord.Transpose ;
    predictedYPCR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    allYDataPCR.SeekFromBeginning(3,1,0) ;
    if allYDataPCR.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to allYDataPCR.yCoord.numRows do
       begin
         allYDataPCR.yCoord.F_Mdata.Read(s1,4) ;
         predictedYPCR.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if allYDataPCR.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allYDataPCR.yCoord.numRows  do
      begin
        allYDataPCR.yCoord.F_Mdata.Read(d1,8) ;
        predictedYPCR.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  //
    // reset data to first positions
//    allXData.SeekFromBeginning(3,1,0) ;
//    allYData.SeekFromBeginning(3,1,0) ;
    scoresSpectra.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
    eigenValSpectra.SeekFromBeginning(3,1,0) ;
//    XresidualsSpectra.SeekFromBeginning(3,1,0) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
//    regenSpectra.SeekFromBeginning(3,1,0) ;
//    modelPCRSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predictedYPCR.SeekFromBeginning(3,1,0) ;
    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;

    tstr := copy(self.xFilename,1,pos(extractfileext(self.xFilename),self.xFilename))  ;

end ;



procedure TPCRBatch.SaveSpectra(filenameIn : string)  ;
var
 t1 : integer ;
begin
    t1 := pos('.', filenameIn)-1 ;
    if t1 > 0 then
    filenameIn := copy(filenameIn,1,t1) ;

    scoresSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_scoresPCR.bin') ;
    eigenVSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenVectPCR.bin') ;
    eigenValSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenValPCR.bin') ;
    regresCoefSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_regCoefPCR.bin') ;
    predictedYPCR.SaveSpectraRangeDataBinV2(filenameIn+'_predictedYPCR.bin') ;
    YresidualsSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_residualsYPCR.bin') ;
    R_sqrd_PCR.SaveSpectraRangeDataBinV2(filenameIn+'_R_sqrd_PCR.bin') ;
end ;


end.
