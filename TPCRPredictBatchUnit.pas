unit TPCRPredictBatchUnit ;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject, TMatrixOperations,
  PCResultsObjects, TBatch, TPreprocessUnit ;

type
  TPCRYPredictBatch  = class(TBatchMVA)
  public
     numPCs : integer ;
 //    PCsString : string;  // inherited from TBatchMVA

     // the X data versions of these are inherited from TBatchMVA
     YsampleRange : string ;  //  not needed in IR-pol of PCA units
     yVarRange : string ; // variable range or filled in by ConvertValueStringToPosString()
     YinXData  : boolean ;
     LineColor : TGLLineColor ;
//     GLListNumber : integer ;

     // if not empty then preprocess data with smoothing and derivatives
     smooth       :   string  ; // = average 15  // fourier 15,50 remove complex  // %,power
     derivative   :   string  ; // = fourier 2 : remove complex // fourier only available

     // not used:
     flipRange : string ; // section of e-vector of interest. if  flipRange = '' then do not do test
     positive : boolean ; // if true then area of e-vect should be positive else area should be negative. Flip if not true.

     pp                      : TPreprocess ;

     PCRResults              : TPCResults  ;      // does the calculations

//   allXData                : TSpectraRanges ;  // this is inherited
     allYData                : TSpectraRanges ;  // for display in column 2 and 3 - The original data sets

//   scoresSpectra           : TSpectraRanges ;  // this is inherited
//   eigenVSpectra         : TSpectraRanges ;  // this is inherited
//    XresidualsSpectra      : TSpectraRanges ;  // this is inherited
//    eigenValSpectra        : TSpectraRanges ;  // this is inherited  // Eigenvalue = scores(PCx)' * scores(PCx)  ==  variance of each PC
//    regenSpectra           : TSpectraRanges ;  // Data made from specific PCs using  RegenerateData() function

     YresidualsSpectra       : TSpectraRanges ;
     modelPCRSpectra         : TSpectraRanges ;  // this is PCR/MLR specific
     regresCoefSpectra       : TSpectraRanges ;  // X Coefficients for regression with a cirtain number of PCs for known Y values
     predictedYPCR           : TSpectraRanges ;
     R_sqrd_PCR              : TSpectraRanges ;

     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     function  GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     function  ProcessPCRBatchFile(inputX, inputY : TSpectraRanges)   : string ;  // this calls private functions and creates model
//     function  PredictYFromModel( xData, regressCoef : TMatrix) : TMatrix   ;

  private

     function  DetermineNumPCs : string ;
     function  GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
     function  GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges )  : string  ; // TBatch virtual method
     function  PreProcessData  : string ; // override  ;
     function  CreatePCRDisplayData(lc : pointer )  : boolean ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
end;

implementation


constructor TPCRYPredictBatch.Create(SDPrec : integer);  // need SDPrec
begin
   inherited Create ;
   pp := TPreprocess.Create ;
   PCRResults := TPCResults.Create('PCR_Results.out',SDPrec)  ;
end ;


destructor  TPCRYPredictBatch.Destroy; // override;
begin
//  allXData.Free ; // created in  GetAllXData
  allYData.Free ; // created in  GetAllYData
  YresidualsSpectra.Free ;
  modelPCRSpectra.Free ;
  regresCoefSpectra.Free ;
  predictedYPCR.Free ;
  R_sqrd_PCR.Free ;

  pp.Free ;
  PCRResults.Free ;
  
  inherited Free ;
end ;

procedure TPCRYPredictBatch.Free;
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

function  TPCRYPredictBatch.GetBatchArguments( lineNum, iter : integer; tStrList : TStringList ) : string   ;
// return result is either:
// on success:  string version of line number
// on fail :    string of 'line number + ', error message'
// comma present indicates failure
var
 t1 : integer ;
 tstr1  : string ;
begin
       try
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


      result := inttostr(lineNum) ;  // if result has a comma then input has failed
      except on eConvertError do
      begin
         result := inttostr(lineNum) + ', PCA batch input conversion error' +  #13 ;
      end ;
      end ;
end ;





function  TPCRYPredictBatch.GetAllXData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
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

  // converts cm-1 or other units into range of data positions in matrix (i.e. 800-1600 cm-1  ->  228-526 )
  if xVarRangeIsPositon = false then
  begin
      self.xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, sourceSpecRange.xCoord) ;
      if  self.xVarRange = '' then
      begin
//        MessageDlg('TIPCRPredict.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := 'PLS input error: x var range values not appropriate: '  + #13  ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  // set up the string of rows to collect

  // sampleRange string is open ended (e.g. '12-')
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  allXData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec div 4,1,1,@self.LineColor) ;

  // *****************  This actually retrieves the data  ********************
  allXData.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allXData.yImaginary := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
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
        result := 'PCR input error: fetching x data failed'   + #13 ;
  end ;
  end ;


end ;




function  TPCRYPredictBatch.GetAllYData( interleavedOrBlocked : integer;  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
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

  allYData := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec div 4,1,1,@self.LineColor) ;  

  // *****************  This actually retrieves the data  ********************
  allYData.yCoord.FetchDataFromTMatrix( YsampleRange, yVarRange , sourceSpecRange.yCoord ) ;
  if sourceSpecRange.yImaginary <> nil then
  begin
    allYData.yImaginary := TMatrix.Create(allYData.yCoord.SDPrec div 4) ;
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
        result := 'PCR input error: fetching y data failed'  + #13 ;
  end ;
  end ;

end ;


function  TPCRYPredictBatch.PreProcessData : string ;
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



function  TPCRYPredictBatch.DetermineNumPCs : string ;
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




function  TPCRYPredictBatch.ProcessPCRBatchFile(inputX, inputY : TSpectraRanges)  : string ;  // this calls all above functions and creates model
var
  resultString : string ;
begin
   result := '' ;

   try
     resultString := resultString + GetAllXData( interleaved,  inputX ) ;
     resultString := resultString + GetAllYData( interleaved,  inputY ) ;
     resultString := resultString + PreProcessData  ;
     resultString := resultString + DetermineNumPCs ;

     if  length(resultString) > 0 then
     begin
       result := 'ProcessPLSBatchFile failed:' + #13 + resultString ;
       exit ;
     end ;

     if allXData.yImaginary = nil then  // do not have code for complex data type
     begin
       // Do PCR regression
       PCRResults.DoPCAFirst(allXData.yCoord,numPCs,meanCentre, colStd) ;
//       PCRResults.XResiduals.ClearData(allXData.yCoord.SDPrec div 4)  ;
//       PCRResults.XResiduals.CopyMatrix(allXData.yCoord) ;
       allXData.yCoord.ClearData(allXData.yCoord.SDPrec div 4)  ;
       allXData.yCoord.CopyMatrix(PCRResults.XMatrix) ;
       PCRResults.CreatePCRModelSecond( allYdata.yCoord, PCsString ) ; // PCsString has been checked
     end
     else  // data is complex
     begin
       messagedlg('PLS code does not work with complex data. Remove imaginary component first',mtError,[mbOK],0) ;
       exit ;
     end ;

     CreatePCRDisplayData(@allXData.LineColor) ;  // may have problems with this

    except on Exception do
    begin

       result := 'Exception in PLS1 ProcessPLSBatchFile()' ;
    end ;
    end ;
end ;




function  TPCRYPredictBatch.CreatePCRDisplayData(lc : pointer)  : boolean ;
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
begin
      // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject
    scoresSpectra     := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  allXData.yCoord.numRows , numPCs                  , lc )  ;
    eigenVSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  numPCs                  ,  allXData.yCoord.numCols, lc )  ;
XresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4, 1 ,  1, lc )  ;
    YresidualsSpectra := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,allXData.yCoord.numRows                   ,  numPCs , lc )  ; // numPCs by number of Samples
    eigenValSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  1                       ,  numPcs                 , lc )  ;
regenSpectra      := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  1 , 1, lc )  ;

    modelPCRSpectra   := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  numPCs                  , allXData.yCoord.numCols,  lc )  ;
    regresCoefSpectra:= TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  numPCs                  , allXData.yCoord.numCols,  lc )  ;
    predictedYPCR  := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  numPCs                  , allXData.yCoord.numRows,  lc )  ;
    R_sqrd_PCR       := TSpectraRanges.Create(self.allXData.yCoord.SDPrec div 4,  1                       , numPCs                 ,  lc )  ;

    // 2/ ****  Copy calculated data to output display objects ****
    scoresSpectra.yCoord.CopyMatrix( PCRResults.ScoresPCR ) ;
    eigenVSpectra.yCoord.CopyMatrix( PCRResults.EVectsPCR ) ;
    eigenValSpectra.yCoord.CopyMatrix( PCRResults.EigenValues ) ;

    //    PCRResults.RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(PCRResults.EVectsPCR.numCols),meanCentre,PCRResults.XResiduals.F_MAverage) ;
//    regenSpectra.yCoord.CopyMatrix( PCRResults.XRegenMatrix ) ;
//    XresidualsSpectra.yCoord.CopyMatrix( PCRResults.XResiduals )   ;

    modelPCRSpectra.yCoord.CopyMatrix( PCRResults.Model ) ;
    regresCoefSpectra.yCoord.CopyMatrix( PCRResults.RegressionCoef ) ;
    predictedYPCR.yCoord.CopyMatrix( PCRResults.PredictedY ) ;
    YresidualsSpectra.yCoord.CopyMatrix( PCRResults.YResidualsPCR )   ;
    R_sqrd_PCR.yCoord.CopyMatrix( PCRResults.R_sqrd_PCR ) ;


    if eigenVSpectra.yCoord.complexMat = 2 then
    begin
         scoresSpectra.yImaginary := TMatrix.Create2(scoresSpectra.yCoord.SDPrec div 4, scoresSpectra.yCoord.numRows, scoresSpectra.yCoord.numCols ) ;
         scoresSpectra.yCoord.MakeUnComplex( scoresSpectra.yImaginary ) ;
         eigenVSpectra.yImaginary := TMatrix.Create2(eigenVSpectra.yCoord.SDPrec div 4, eigenVSpectra.yCoord.numRows, eigenVSpectra.yCoord.numCols ) ;
         eigenVSpectra.yCoord.MakeUnComplex( eigenVSpectra.yImaginary ) ;
 //        XresidualsSpectra.yImaginary := TMatrix.Create2(XresidualsSpectra.yCoord.SDPrec div 4, XresidualsSpectra.yCoord.numRows, XresidualsSpectra.yCoord.numCols) ;
 //        XresidualsSpectra.yCoord.MakeUnComplex( XresidualsSpectra.yImaginary ) ;
         YresidualsSpectra.yImaginary := TMatrix.Create2(YresidualsSpectra.yCoord.SDPrec div 4, YresidualsSpectra.yCoord.numRows, YresidualsSpectra.yCoord.numCols) ;
         YresidualsSpectra.yCoord.MakeUnComplex( YresidualsSpectra.yImaginary ) ;
         eigenValSpectra.yImaginary := TMatrix.Create2(eigenValSpectra.yCoord.SDPrec div 4, eigenValSpectra.yCoord.numRows, eigenValSpectra.yCoord.numCols) ;
         eigenValSpectra.yCoord.MakeUnComplex( eigenValSpectra.yImaginary ) ;
//         regenSpectra.yImaginary := TMatrix.Create2(regenSpectra.yCoord.SDPrec div 4, regenSpectra.yCoord.numRows, regenSpectra.yCoord.numCols) ;
//         regenSpectra.yCoord.MakeUnComplex( regenSpectra.yImaginary ) ;
         modelPCRSpectra.yImaginary := TMatrix.Create2(modelPCRSpectra.yCoord.SDPrec div 4, modelPCRSpectra.yCoord.numRows, modelPCRSpectra.yCoord.numCols) ;
         modelPCRSpectra.yCoord.MakeUnComplex( modelPCRSpectra.yImaginary ) ;
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec div 4, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predictedYPCR.yImaginary := TMatrix.Create2(predictedYPCR.yCoord.SDPrec div 4, predictedYPCR.yCoord.numRows, predictedYPCR.yCoord.numCols) ;
         predictedYPCR.yCoord.MakeUnComplex( predictedYPCR.yImaginary ) ;
     //    R_sqrd_PLS
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)
    scoresSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    modelPCRSpectra.SeekFromBeginning(3,1,0) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
    for t1 := 1 to allXData.yCoord.numRows do
    begin
      if self.allXData.yCoord.SDPrec = 4 then
      begin
        s1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(s1,4) ;
        modelPCRSpectra.xCoord.F_Mdata.Write(s1,4) ;
      end
      else
      if self.allXData.yCoord.SDPrec = 8 then
      begin
        d1 := t1 ;
        scoresSpectra.xCoord.F_Mdata.Write(d1,8) ;
        modelPCRSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;
    // B/ add wavelength values as xCoord for EVects matrix storage
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
//    XresidualsSpectra.SeekFromBeginning(3,1,0) ;
//    regenSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predictedYPCR.SeekFromBeginning(3,1,0) ;
    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;

    if self.allXData.xCoord.SDPrec = 4 then
    begin
      for t1 := 1 to allXData.yCoord.numCols do
      begin
        allXData.xCoord.F_Mdata.Read(s1,4) ;

        eigenVSpectra.xCoord.F_Mdata.Write(s1,4) ;
//        XresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
//        regenSpectra.xCoord.F_Mdata.Write(s1,4) ;
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
 //       XresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
 //       regenSpectra.xCoord.F_Mdata.Write(d1,8) ;
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
         R_sqrd_PCR.xCoord.F_Mdata.Write(s1,4) ;
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
        R_sqrd_PCR.xCoord.F_Mdata.Write(d1,8) ;
        YresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  // predictedYPLS
  // D/ create x coord data for predictedYPLS (one point for each sample)
    predictedYPCR.yCoord.Transpose ;
    predictedYPCR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    allYData.SeekFromBeginning(3,1,0) ;
    if allYData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to allYData.yCoord.numRows do
       begin
         allYData.yCoord.F_Mdata.Read(s1,4) ;
         predictedYPCR.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if allYData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allYData.yCoord.numRows  do
      begin
        allYData.yCoord.F_Mdata.Read(d1,8) ;
        predictedYPCR.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

  //
    // reset data to first positions
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;
    eigenVSpectra.SeekFromBeginning(3,1,0) ;
//    XresidualsSpectra.SeekFromBeginning(3,1,0) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
//    regenSpectra.SeekFromBeginning(3,1,0) ;
    modelPCRSpectra.SeekFromBeginning(3,1,0) ;

    regresCoefSpectra.SeekFromBeginning(3,1,0) ;

    predictedYPCR.SeekFromBeginning(3,1,0) ;

    R_sqrd_PCR.SeekFromBeginning(3,1,0) ;
end ;


{
function TPCRYPredictBatch.PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
begin
  //result :=  mo.MultiplyMatrixByMatrix(xData,regressCoef, false, true, 1.0, false) ;
end ;
}

end.
