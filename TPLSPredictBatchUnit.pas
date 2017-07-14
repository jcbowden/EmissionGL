unit TPLSPredictBatchUnit ;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses
  SysUtils, Classes, TBatchBasicFunctions, TSpectraRangeObject,
  TMatrixObject, TMatrixOperations, TPLSResultsObjects, TPreprocessUnit ;

type
  TPLSYPredictBatch  = class  // does not inherit from TBatchMVA
  public
     numPCs : integer ;

     xFilename : string ;
     XsampleRange : string ;  //  these X values could have been inherited from TBatchMVA
     xVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     yFilename : string ;
     YsampleRange : string ;  //  not needed in IR-pol of PCA units
     yVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     YinXData  : boolean ;

     resultsFileName : string;
     PCsString : string;
     firstSpectra : integer ;  // not needed in PCA, PCR, PLS... it is first value in sampleRange

     xDiskEQxData  : boolean ; // if data from disk is identical to what is processed then this is 'true'

     // if not empty then preprocess data with smoothing and derivatives
     smooth       :   string  ; // = average 15  // fourier 15,50 remove complex  // %,power
     derivative   :   string  ; // = fourier 2 : remove complex // fourier only available

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     normalisedEVects, meanCentre, colStd : boolean ;

     // interleaved = 2 then this is IR-pol format, where each polarisation angle spectra at an individual pixel is one after another
     // interleaved = 1 this is standard interleaved format with image in large block (i.e. 32x32 spectra, followed by another 32x32 etc at each angle )
     interleaved : integer ;

     autoExclude : single;     // used in IR-pol analysis but not PCA as yet.
     excludePCsStr : string;   // used in IR-pol analysis but not PCA as yet.

     bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc


     pp                      : TPreprocess ;

     PLSResultsObject        : PLSResults ;      // does the calculations

     allXData                : TSpectraRanges ;  // this is inherited
     allYData                : TSpectraRanges ;  // for display in column 2 and 3 - The original data sets

     scoresSpectra           : TSpectraRanges ;  // this is inherited
     eigenVSpectra           : TSpectraRanges ;  // this is inherited
//     XresidualsSpectra       : TSpectraRanges ; // this is inherited
     YresidualsSpectra       : TSpectraRanges ;
     eigenValSpectra         : TSpectraRanges ;  // this is inherited // Eigenvalue = scores(PCx)' * scores(PCx)  ==  variance of each PC
//     regenSpectra            : TSpectraRanges ;  // this is inherited // Data made from specific PCs using  RegenerateData() function

     weightsSpectra          : TSpectraRanges ;  // these are PLS specific
     regresCoefSpectra       : TSpectraRanges ;  // X Coefficients for regression with a cirtain number of PCs for known Y values
     predYPLSSpectra         : TSpectraRanges ;
     R_sqrd_PLS              : TSpectraRanges ;


     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     function  GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     function  ProcessPLSBatchFile(inputX, inputY : TSpectraRanges)   : string ;  // this calls private functions and creates mode
     procedure SaveSpectra(filenameIn : string)  ;
  private

     function  DetermineNumPCs : string ;
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
     function  GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges )  : string  ; // TBatch virtual method
     function  PreProcessData  : string ; // override  ;
     function  CreatePLSDisplayData(lc : pointer )  : boolean ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
end;

implementation


constructor TPLSYPredictBatch.Create(SDPrec : integer);  // need SDPrec
begin
   bB := TBatchBasics.Create ;
   PLSResultsObject  := PLSResults.Create('PLS_Output.out',SDPrec) ;
   pp                := TPreprocess.Create ;
end ;


destructor  TPLSYPredictBatch.Destroy; // override;
begin
//allXData.Free ; // this is inherited from TBatchMVA
//  allYData.Free ; // created in  GetAllYData

  YresidualsSpectra.Free ;

  weightsSpectra.Free ;
  regresCoefSpectra.Free ;
  predYPLSSpectra.Free ;
  R_sqrd_PLS.Free ;

  pp.Free ;
  PLSResultsObject.Free ;

//  if allXData           <> nil then  allXData.Free ;
  if scoresSpectra      <> nil then  scoresSpectra.Free ;
  if eigenVSpectra      <> nil then  eigenVSpectra.Free ;
  if eigenValSpectra    <> nil then  eigenValSpectra.Free ;
//  if  XresidualsSpectra <> nil then  XresidualsSpectra.Free ;
//  if  regenSpectra      <> nil then  regenSpectra.Free ;
  bB.Free ;               // TBatchBasics
end ;


procedure TPLSYPredictBatch.Free;
begin
 if Self <> nil then Destroy;
end;

{
type = PLS

// input x and y data
x sample range = 1-686     // (ROWS)
x var range = 1-520        // (COLS)

y in x data = true
y sample range = 1-686     // (ROWS)
y var range = 1-1          // (COLS)

number of PCs = 1-20

// pre-processing
mean centre = true
column standardise = false
smooth = average,15  // fourier,15,50,remove complex, true, 1  // %,power
derivative = fourier, 2, remove complex, true, 1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;

// EVects output
pos or neg range =              // 1200-1260 cm-1
positive or negative = positive
normalised EVects = true

// output
results file = PLS.out
}

function  TPLSYPredictBatch.GetBatchArguments( lineNum, iter : integer; tStrList : TStringList ) : string   ;
// return result is either:
// on success:  string version of line number
// on fail :    string of 'line number + ', error message'
// comma present indicates failure
var
 t1 : integer ;
 tstr1  : string ;
begin
       try
 {
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
                                                                                   }
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
         // smooth = average,15  // fourier,15,50,remove complex, true, 1  // %,power
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
       repeat              // this is not used at preset
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


      result := inttostr(lineNum) ;  // if result has a comma then input has failed
      except on eConvertError do
      begin
         result := inttostr(lineNum) + ', PCA batch input conversion error' +  #13 ;
      end ;
      end ;
end ;





function  TPLSYPredictBatch.GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t2 : integer ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := '' ;
  try

  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
//        MessageDlg('TIPLSPredict.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := 'PLS input error: x var range values not appropriate: '  + #13  ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;


   // if the data is exactly as recieved in sourceSpecRange then do not copy (saves memory)
  if (sourceSpecRange.yCoord.numRows = sourceSpecRange.yCoord.GetTotalRowsColsFromString(XsampleRange)) and (sourceSpecRange.yCoord.numCols = sourceSpecRange.yCoord.GetTotalRowsColsFromString(xVarRange))then
  begin
    allXData :=  sourceSpecRange ;
    xDiskEQxData := true ;
    exit ;
  end;

  // otherwise copy the data wanted
  allXData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1, @sourceSpecRange.LineColor) ;

  // *****************  This actually retrieves the data  ********************
  allXData.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXData.yImaginary := TMatrix.Create(allXData.yCoord.SDPrec) ;
    allXData.yImaginary.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yImaginary ) ;
  end ;


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


  except
  begin
        result := 'PLS input error: fetching x data failed'   + #13 ;
  end ;
  end ;


end ;




function  TPLSYPredictBatch.GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
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

  allYData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec,1,1, @sourceSpecRange.lineColor) ;

  // *****************  This actually retrieves the data  ********************
  allYData.yCoord.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allYData.yImaginary := TMatrix.Create(allYData.yCoord.SDPrec) ;
    allYData.yImaginary.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yImaginary ) ;
  end ;


  // *****************   Get the x data of TSpectraRanges object - X data can be disjoint (it just will display disjoint) *****************
  allYData.xString := sourceSpecRange.xString ;
  allYData.yString := sourceSpecRange.yString ;
  allYData.xCoord.numCols :=  allYData.yCoord.numCols ;
  allYData.xCoord.numRows := 1 ;
  allYData.xCoord.Filename := resultsFileName ;
  allYData.xCoord.F_Mdata.SetSize(allYData.xCoord.numCols * 1 * allYData.xCoord.SDPrec) ;
  allYData.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
  t2 := allYData.xCoord.GetTotalRowsColsFromString(yVarRange, allYData.xCoord.Fcols) ;
  allYData.xCoord.Fcols.Seek(0,soFromBeginning) ;
  for t1 := 1 to allYData.xCoord.numCols do
  begin
     allYData.xCoord.Fcols.Read(t2,4) ;
     sourceSpecRange.xCoord.F_Mdata.Seek(t2*sourceSpecRange.xCoord.SDPrec,soFromBeginning) ;
     if sourceSpecRange.xCoord.SDPrec = 4 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(s1, 4) ;
        allYData.xCoord.F_Mdata.Write(s1,4) ;
     end
     else
     if sourceSpecRange.xCoord.SDPrec = 8 then
     begin
        sourceSpecRange.xCoord.F_Mdata.Read(d1, 8) ;
        allYData.xCoord.F_Mdata.Write(d1,8) ;
     end ;
  end ;

  except
  begin
        result := 'PLS input error: fetching y data failed'  + #13 ;
  end ;
  end ;

end ;


function  TPLSYPredictBatch.PreProcessData : string ;
{  meanCentre, colStd : boolean ;
   smooth       :   string   // = average 15  // fourier 15,50 remove complex  // %,power
   derivative   :   string   // = fourier 2 : remove complex // fourier only available
}
begin

     self.allYData.yCoord.MeanCentre ; // Y data has to be mean centred (i think)
     if  meanCentre then
        self.allXData.yCoord.MeanCentre ;

     if  colStd then
       self.allXData.yCoord.ColStandardize ; // not sure what to do with y data with col standardise

     if length(trim(smooth)) > 0 then
     begin
        result := pp.Smooth(smooth,allXData) ;
     end ;

     if length(trim(derivative)) > 0 then
     begin
        if length(result) > 0 then
          result := result + #13 + pp.Differentiate(derivative,allXData)
        else
          result :=  pp.Differentiate(derivative,allXData)   ;
     end  ;

     if length(result) > 0 then
     result := result +  #13 ;

end ;



function  TPLSYPredictBatch.DetermineNumPCs : string ;
var
  t1 : integer ;
  pcsToFitMemStrm : TMemoryStream ;
begin
  try
    result := '' ;
    pcsToFitMemStrm := TMemoryStream.Create ;
    t1 := allXData.yCoord.GetTotalRowsColsFromString(PCsString, pcsToFitMemStrm) ; // number of PCs to fit

    pcsToFitMemStrm.Seek(-4,soFromEnd) ;
    pcsToFitMemStrm.Read(numPCs,4) ; // read final number in range (don't use t1 as it is number in set, not the maximum PC needed)
    numPCs := numPCs + 1 ;    // add one because the numbers returned are zero based
    if numPcs > allXData.yCoord.numRows then
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



procedure   CheckResult(resultStringIn : string) ;
begin
     if  length(resultStringIn) > 0 then
     begin
       writeln('ProcessPCRBatchFile failed:' + #13 + resultStringIn ) ;
       exit ;
     end ;
end ;


// *********************    THIS IS THE MAIN FUNCTION OF THIS UNIT   ***********************
//
function  TPLSYPredictBatch.ProcessPLSBatchFile(inputX, inputY : TSpectraRanges)  : string ;  // this calls all above functions and creates model
// LineColor has to be assigned before calling this function
var
  resultString : string ;
begin
   result := '' ;

      try
     resultString := resultString + GetAllXData( interleaved,  inputX ) ;  //
     if (xDiskEQxData  = false) and (YinXData = false) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free ;

     resultString := resultString + GetAllYData( interleaved,  inputY ) ;


     if (xDiskEQxData  = false) and (YinXData = true) then  // input (disk) file and matrix data are identical so do not delete
       inputX.Free 
     else
       inputY.Free ;

     resultString := resultString + PreProcessData  ;
     resultString := resultString + DetermineNumPCs ;
     CheckResult(resultString) ;

     if allXData.yImaginary = nil then  // do not have code for complex data type
     begin
        // Do PLS regression
       PLSResultsObject.CreatePLSModelMatrix(allXData.yCoord,allYdata.yCoord, numPCs) ; // PCsString has been checked
 //      messagedlg('returned from  CreatePLSModelMatrix' ,mtInformation,[mbOK],0) ;
       CreatePLSDisplayData(@inputY.LineColor) ;
       result := '' ;
     end
     else  // data is complex
     begin
       writeln('PLS code does not accept complex data. Remove imaginary component first') ;
       exit ;
     end ;

     allXData.Free ; // this will remove inputX.Free if "xDiskEQxData = true"
     allYData.Free ; // created in  GetAllYData

    except on Exception do
    begin
       PLSResultsObject.CreatePLSModelMatrix(allXData.yCoord,allYdata.yCoord, numPCs) ;
       result := 'Exception in PLS1 ProcessPLSBatchFile()' ;
    end ;
    end ;

end ;

{ // original function before memory optimisation
function  TPLSYPredictBatch.ProcessPLSBatchFile(inputX, inputY : TSpectraRanges)  : string ;  // this calls all above functions and creates model
// LineColor has to be assigned before calling this function
var
  resultString : string ;
begin
   result := '' ;

   try
     resultString := '' ;
     // this gets the data matricies and pre-processes
     resultString := resultString + GetAllXData( interleaved,  inputX ) ;
     resultString := resultString + GetAllYData( interleaved,  inputY ) ;
     resultString := resultString + PreProcessData  ;
     resultString := resultString + DetermineNumPCs ;

     if  length(resultString) > 0 then
     begin
       result := 'ProcessPLSBatchFile failed: '+ #13 + resultString ;
       exit ;
     end ;

     if allXData.yImaginary = nil then  // do not have code for complex data type
     begin
       // Do PLS regression
       PLSResultsObject.CreatePLSModelMatrix(allXData.yCoord,allYdata.yCoord, numPCs) ; // PCsString has been checked
 //      messagedlg('returned from  CreatePLSModelMatrix' ,mtInformation,[mbOK],0) ;
       CreatePLSDisplayData ;
       result := '' ;
     end ;

    except on Exception do
    begin
       PLSResultsObject.CreatePLSModelMatrix(allXData.yCoord,allYdata.yCoord, numPCs) ;
       result := 'Exception in PLS1 ProcessPLSBatchFile()' ;
    end ;
    end ;

end ;}





function  TPLSYPredictBatch.CreatePLSDisplayData(lc : pointer )  : boolean ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
begin
      // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject
    scoresSpectra    := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  allXData.yCoord.numRows , numPCs                , lc  )  ;
    eigenVSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCs                  ,  allXData.yCoord.numCols, lc)  ;
//1    XresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec, allXData.yCoord.numRows ,  allXData.yCoord.numCols, lc )  ; //1
    YresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,allXData.yCoord.numRows                   ,  numPCs, lc )  ; // numPCs by number of Samples
    eigenValSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  1                       ,  numPcs                 , lc)  ;
//1    regenSpectra     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  allXData.yCoord.numRows ,  allXData.yCoord.numCols, lc )  ; //1

    weightsSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCs                  , allXData.yCoord.numCols , lc)  ;
    regresCoefSpectra:= TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCs                  , allXData.yCoord.numCols , lc)  ;
    predYPLSSpectra  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  numPCs                  , allXData.yCoord.numRows , lc)  ;
    R_sqrd_PLS       := TSpectraRanges.Create(self.allXData.yCoord.SDPrec,  1                       , numPCs                  , lc)  ;

    // 2/ ****  Copy calculated data to output display objects ****
    scoresSpectra.yCoord.CopyMatrix( PLSResultsObject.ScoresPLS ) ;
    eigenVSpectra.yCoord.CopyMatrix( PLSResultsObject.XEVects ) ;

//1    XresidualsSpectra.yCoord.CopyMatrix( PLSResultsObject.XResiduals )   ;//1
    YresidualsSpectra.yCoord.CopyMatrix( PLSResultsObject.YResidualsPLS )   ;
    eigenValSpectra.yCoord.CopyMatrix( PLSResultsObject.EigenValues ) ;
///    PLSResultsObject.RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(PLSResultsObject.XEVects.numCols),meanCentre,PLSResultsObject.XResiduals.F_MAverage) ;
//1    regenSpectra.yCoord.CopyMatrix( PLSResultsObject.XRegenMatrix ) ;   //1
    weightsSpectra.yCoord.CopyMatrix( PLSResultsObject.Weights ) ;
    regresCoefSpectra.yCoord.CopyMatrix( PLSResultsObject.RegresCoefPLS ) ;
    predYPLSSpectra.yCoord.CopyMatrix( PLSResultsObject.YPredTotal ) ;
    R_sqrd_PLS.yCoord.CopyMatrix( PLSResultsObject.R_sqrd_PLS ) ;


    if eigenVSpectra.yCoord.complexMat = 2 then
    begin
         scoresSpectra.yImaginary := TMatrix.Create2(scoresSpectra.yCoord.SDPrec, scoresSpectra.yCoord.numRows, scoresSpectra.yCoord.numCols ) ;
         scoresSpectra.yCoord.MakeUnComplex( scoresSpectra.yImaginary ) ;
         eigenVSpectra.yImaginary := TMatrix.Create2(eigenVSpectra.yCoord.SDPrec, eigenVSpectra.yCoord.numRows, eigenVSpectra.yCoord.numCols ) ;
         eigenVSpectra.yCoord.MakeUnComplex( eigenVSpectra.yImaginary ) ;
//1         XresidualsSpectra.yImaginary := TMatrix.Create2(XresidualsSpectra.yCoord.SDPrec, XresidualsSpectra.yCoord.numRows, XresidualsSpectra.yCoord.numCols) ; //1
//1         XresidualsSpectra.yCoord.MakeUnComplex( XresidualsSpectra.yImaginary ) ; //1
         YresidualsSpectra.yImaginary := TMatrix.Create2(YresidualsSpectra.yCoord.SDPrec, YresidualsSpectra.yCoord.numRows, YresidualsSpectra.yCoord.numCols) ;
         YresidualsSpectra.yCoord.MakeUnComplex( YresidualsSpectra.yImaginary ) ;
         eigenValSpectra.yImaginary := TMatrix.Create2(eigenValSpectra.yCoord.SDPrec, eigenValSpectra.yCoord.numRows, eigenValSpectra.yCoord.numCols) ;
         eigenValSpectra.yCoord.MakeUnComplex( eigenValSpectra.yImaginary ) ;
//1         regenSpectra.yImaginary := TMatrix.Create2(regenSpectra.yCoord.SDPrec, regenSpectra.yCoord.numRows, regenSpectra.yCoord.numCols) ; //1
//1         regenSpectra.yCoord.MakeUnComplex( regenSpectra.yImaginary ) ; //1
         weightsSpectra.yImaginary := TMatrix.Create2(weightsSpectra.yCoord.SDPrec, weightsSpectra.yCoord.numRows, weightsSpectra.yCoord.numCols) ;
         weightsSpectra.yCoord.MakeUnComplex( weightsSpectra.yImaginary ) ;
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predYPLSSpectra.yImaginary := TMatrix.Create2(predYPLSSpectra.yCoord.SDPrec, predYPLSSpectra.yCoord.numRows, predYPLSSpectra.yCoord.numCols) ;
         predYPLSSpectra.yCoord.MakeUnComplex( predYPLSSpectra.yImaginary ) ;
     //    R_sqrd_PLS
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)
    scoresSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
    for t1 := 1 to allXData.yCoord.numRows do
    begin
      if self.allXData.yCoord.SDPrec = 4 then
      begin
        s1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end
      else
      if self.allXData.yCoord.SDPrec = 8 then
      begin
        d1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;
    // B/ add wavelength values as xCoord for EVects matrix storage
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
//1    XresidualsSpectra.SeekFromBeginning(3,1,0) ; //1
//1    regenSpectra.SeekFromBeginning(3,1,0) ;      //1
    weightsSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predYPLSSpectra.SeekFromBeginning(3,1,0) ;
    R_sqrd_PLS.SeekFromBeginning(3,1,0) ;

    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(s1,4) ;

        eigenVSpectra.xCoord.F_Mdata.Write(s1,4) ;
//1        XresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ; //1
//1        regenSpectra.xCoord.F_Mdata.Write(s1,4) ;      //1
        weightsSpectra.xCoord.F_Mdata.Write(s1,4) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end  ;
    end
    else
    if self.allXData.xCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(d1,8) ;

        eigenVSpectra.xCoord.F_Mdata.Write(d1,8) ;
//1        XresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;  //1
//1        regenSpectra.xCoord.F_Mdata.Write(d1,8) ;       //1
        weightsSpectra.xCoord.F_Mdata.Write(d1,8) ;
        regresCoefSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end  ;
    end ;


    // C/ create x coord data for eigenValSpectra and R_sqrd_PLS and YResiduals (one point for each PC)
    eigenValSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    YresidualsSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCs do
       begin
         s1 := t1 ;
         eigenValSpectra.xCoord.F_Mdata.Write(s1,4) ;
         R_sqrd_PLS.xCoord.F_Mdata.Write(s1,4) ;
         YresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCs do
      begin
        d1 := t1 ;
        eigenValSpectra.xCoord.F_Mdata.Write(d1,8) ;
        R_sqrd_PLS.xCoord.F_Mdata.Write(d1,8) ;
        YresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  // predictedYPLS
  // D/ create x coord data for predictedYPLS (one point for each sample)
    predYPLSSpectra.yCoord.Transpose ;
    predYPLSSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    allYData.SeekFromBeginning(3,1,0) ;
    if allYData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to allYData.yCoord.numRows do
       begin
         allYData.yCoord.F_Mdata.Read(s1,4) ;
         predYPLSSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if allYData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allYData.yCoord.numRows  do
      begin
        allYData.yCoord.F_Mdata.Read(d1,8) ;
        predYPLSSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

    // reset data to first positions
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
//1    XresidualsSpectra.SeekFromBeginning(3,1,0) ; //1
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
//1    regenSpectra.SeekFromBeginning(3,1,0) ;      //1
    weightsSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predYPLSSpectra.SeekFromBeginning(3,1,0) ;
    R_sqrd_PLS.SeekFromBeginning(3,1,0) ;
end ;

procedure TPLSYPredictBatch.SaveSpectra(filenameIn : string)  ;
begin
    scoresSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_scoresPLS.bin') ;
    eigenVSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenVectPLS.bin') ;
    eigenValSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_eigenValPLS.bin') ;
    regresCoefSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_regCoefPLS.bin') ;
    predYPLSSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_predictedYPLS.bin') ;
    YresidualsSpectra.SaveSpectraRangeDataBinV2(filenameIn+'_residualsYPLS.bin') ;
    R_sqrd_PLS.SaveSpectraRangeDataBinV2(filenameIn+'_R_sqrd_PLS.bin') ;
end ;


end.

