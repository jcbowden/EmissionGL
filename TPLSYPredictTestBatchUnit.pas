unit TPLSYPredictTestBatchUnit;

// Used to predict Y data from a multivariate model (either PCR or PLS).
// Needs <X Data> <Y data (optional)> <Regression coeficients>
// If Y data present then calculates differences between predicted and actual data
// X data must match the regression coefficients in terms of variable type (wavelength/wavenumer value) and number
// (I will fix this so you can select the number/range of variables from the regression coeficients sometime)

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject, TMatrixOperations,
  PLSResultsObjects, TBatch, TPreprocessUnit, TVarAndCoVarOperations, AtlusBLASLAPACLibrary ;

type
  TPLSYPredictTestBatch  = class
  public
     numPCs : integer ;  // number of rows of regression coeficients
     resultsFileName : string ;
     YDataExists : boolean ;

     XsampleRange : string ;  //
     xVarRange : string ;     // variable range or filled in by ConvertValueStringToPosString()
     xVarRangeIsPositon : boolean ;

     YsampleRange : string ;  //
     yVarRange : string ;     // variable range or filled in by ConvertValueStringToPosString()
     YinXData  : boolean ;

     meanCentre : boolean ;
     colStd     : boolean ;

     LineColor : TGLLineColor ;


     // if not empty then preprocess data with smoothing and derivatives
     smooth       :   string  ; // = average 15  // fourier 15,50 remove complex  // %,power
     derivative   :   string  ; // = fourier 2 : remove complex // fourier only available
     pp                      : TPreprocess ;
     bb                      : TBatchBasics ;
     mo                      : TMatrixOps ; // predicts Y
     vcv                     : TVarAndCoVarFunctions ;

     allXData                : TSpectraRanges ;  //
     allYData                : TSpectraRanges ;  // for display in column 2 and 3 - The original data sets
     regresCoefSpectra       : TSpectraRanges ;  // These come from previous model creation using  PLS or PCR

     predYSpectra            : TSpectraRanges ;  // this is a scatter plot of actual vs predicted
     YresidualsSpectra       : TSpectraRanges ;  // this is where we get PRESS data from
     SEPSpectra              : TSpectraRanges ;  // this has a single row of SEP values. One for each factor. (SEP = standard error of prediction)
     R_sqrd                  : TSpectraRanges ;  // this has a single row of R^2 values. One for each factor.

     constructor Create(SDPrec : integer) ;  //
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     function  GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     function  TestModelData(inputX, inputY, inputRegresCoef : TSpectraRanges)   : string ;  // this calls private functions and creates model
     function  PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
     function  CalcYResidualData( addMean : boolean ) : string ;  // does not work for imaginary data
     function  CalcSEPData(inputYresidMat, outputSEPMat : TMatrix) : string ;
     function  CalcRSqrd( addMean : boolean ) : string ;
  private

     function  GetAllXData( sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
     function  GetAllYData( sourceSpecRange : TSpectraRanges )  : string  ; // TBatch virtual method
     function  PreProcessData  : string ; // override  ;
     function  CreateDisplayDataWithResiduals(lc : pointer )  : string ;   // lc is pointer to TGLLineColor type, holding the line colour TSpectraRange.LineColor
     function  CreateDisplayNoRefYData(lc : pointer )  : string ;   //
end;


implementation


constructor TPLSYPredictTestBatch.Create(SDPrec : integer);  // need SDPrec
begin
   inherited Create ;
   pp := TPreprocess.Create ;
   mo := TMatrixOps.Create ;
   bb := TBatchBasics.Create ;
   vcv:= TVarAndCoVarFunctions.Create ;
end ;


destructor  TPLSYPredictTestBatch.Destroy; // override;
begin
  allYData.Free ; // created in
  pp.Free ;
  mo.Free ;
  bb.Free ;
  vcv.Free ;
  inherited Free ;
end ;

procedure TPLSYPredictTestBatch.Free;
begin
 if Self <> nil then Destroy;
end;

function TPLSYPredictTestBatch.PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
begin
  result :=  mo.MultiplyMatrixByMatrix(xData,regressCoef, false, true, 1.0, false) ;
end ;



{
type = VERIFY Y

// input x and y data
x sample range = 1-686     // (ROWS)
x var range = 1-520        // (COLS)

y in x data = true
y sample range = 1-686     // (ROWS)
y var range = 1-1          // (COLS)

// pre-processing
mean centre = true
column standardise = false
smooth = average,15  // fourier,15,50,remove complex  // %,power
derivative = fourier, 2, remove complex, true, 1 // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;

// output
results file = TestData.out
}

function  TPLSYPredictTestBatch.GetBatchArguments( lineNum, iter : integer; tStrList : TStringList ) : string   ;
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





function  TPLSYPredictTestBatch.GetAllXData(  sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
var
  t1 : integer ;
  t2 : integer ;
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
//        MessageDlg('TPLSYPredictTestBatch.GetAllXData() Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        result := 'PLS input error: x var range values not appropriate: '  + #13  ;
        exit ;
      end ;
  end ;

  // *****************   Get the y data of TSpectraRanges object *****************
  if pos('-',XsampleRange) = length(trim(XsampleRange)) then       // sampleRange string is open ended (e.g. '12-')
    XsampleRange := XsampleRange + inttostr(sourceSpecRange.yCoord.numRows) ;

  // to save memory, do not duplicate data if sourceSpectraRange is identical to data wanted (i.e has same number of rows and cols)
  if (XsampleRange = '1-'+inttostr(sourceSpecRange.yCoord.numRows)) and (xVarRange='1-'+inttostr(sourceSpecRange.yCoord.numCols)) then
  begin
     allXData :=  sourceSpecRange ;   // this only works because no new line is created in Y predict code
     exit ;
  end;
  

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
        result := 'PLS input error: fetching x data failed'   + #13 ;
        raise;
  end ;
  end ;


end ;




function  TPLSYPredictTestBatch.GetAllYData( sourceSpecRange : TSpectraRanges ) : string  ; // TBatch virtual method
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
//allYData.yCoord.SaveMatrixDataTxt('ydata_1.txt',',') ;  // 1
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
        result := 'PLS input error: fetching y data failed'  + #13 ;
  end ;
  end ;

end ;


function  TPLSYPredictTestBatch.PreProcessData : string ;
{  meanCentre, colStd : boolean ;
   smooth       :   string   // = average 15  // fourier 15,50 remove complex  // %,power
   derivative   :   string   // = fourier 2 : remove complex // fourier only available
}
begin

//     if not noYData then
//       self.allYData.yCoord.MeanCentre ; // Y data has to be mean centred (i think)
       
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


function  TPLSYPredictTestBatch.CalcYResidualData( addMean : boolean ) : string ;  // does not work for imaginary data
//  =  original Y data - Predicted Y data
//     RegenerateData must be called before this function
var
  t1, t2 : integer ;
  s1, s2, sAve : single ;
  d1, d2, dAve : double ;
begin
  result := ''  ;
  try

    allYData.yCoord.MeanCentre ;
    allYData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

    predYSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    YresidualsSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if allYData.yCoord.SDPrec = 4 then
    begin
      for t1 := 1 to predYSpectra.yCoord.numRows do  // for each sample
      begin
        allYData.yCoord.F_Mdata.Read(s1,4) ;
        for t2 := 1 to predYSpectra.yCoord.numCols do   // at each PC
        begin
           predYSpectra.yCoord.F_Mdata.Read(s2,4) ;
           s2 := s1 - s2 ;
           YresidualsSpectra.yCoord.F_Mdata.Write(s2,4) ;
        end ;
      end ;
    end
    else
    if allYData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to predYSpectra.yCoord.numRows do
      begin

        allYData.yCoord.F_Mdata.Read(d1,8) ;
        for t2 := 1 to predYSpectra.yCoord.numCols do
        begin
           predYSpectra.yCoord.F_Mdata.Read(d2,8) ;
           d2 := d1 - d2 ;
           YresidualsSpectra.yCoord.F_Mdata.Write(d2,8) ;
        end ;
      end ;
    end ;

   allYData.yCoord.F_MAverage.Seek(0,soFromBeginning) ;
   allYData.yCoord.AddVectToMatrixRows(allYData.yCoord.F_MAverage) ;
   allYData.yCoord.meanCentred := false ;
   allYData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

   predYSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
   YresidualsSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;


  except on Exception do
  begin
     result := 'CalcYResidualData failed'   ;
  end ;
  end ;

end ;




function  TPLSYPredictTestBatch.CalcSEPData(inputYresidMat, outputSEPMat : TMatrix) : string ;
var
  t1, t2 : integer ;
  tnumRows, tnumCols : integer ;
  index, MKLtint : integer ;
  p1, pMKL, pMKL2 : pointer ;
  s1 : single ;
  d1 : double ;

begin
  result := ''  ;
  try
     GetMem(p1, inputYresidMat.SDPrec) ;
     tnumRows :=  inputYresidMat.numRows ;
     tnumCols :=  inputYresidMat.numCols ;
     outputSEPMat.F_Mdata.SetSize(tnumCols * inputYresidMat.SDPrec) ;
     outputSEPMat.F_Mdata.Seek(0,soFromBeginning) ;

     // calculate the sum of squares for each column (each column is a set of Y residuals for a particular number of PCs)
     pMKL := inputYresidMat.F_Mdata.Memory ;

       if inputYresidMat.SDPrec = 4 then        // single precision
       begin
         for t1 := 0 to tnumCols-1 do
         begin
           s1 := sdot ( tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           s1 := s1 / (inputYresidMat.numRows -1) ;
           s1 := sqrt(s1) ;
           outputSEPMat.F_Mdata.Write(s1,inputYresidMat.SDPrec) ;
           pMKL := inputYresidMat.MovePointer(pMKL,inputYresidMat.SDPrec) ;
         end ;
       end
       else // inputMatrix.SDPrec = 8
       begin
         for t1 := 0 to tnumCols-1 do
         begin                                // double precision
           d1 := ddot ( tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           d1 := d1 / (inputYresidMat.numRows -1) ;
           d1 := sqrt(d1) ;
           outputSEPMat.F_Mdata.Write(d1,inputYresidMat.SDPrec) ;
           pMKL := inputYresidMat.MovePointer(pMKL,inputYresidMat.SDPrec) ;
         end ;
       end ;

  except on Exception do
  begin
     result := 'CalcSEPData() failed '  ;
     raise;
  end ;
  end;

end ;





function  TPLSYPredictTestBatch.CalcRSqrd( addMean : boolean ) : string ;  // does not work for imaginary data
//  =  original Y data - Predicted Y data
//     RegenerateData must be called before this function
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  tMat1, tMat2 : TMatrix ;
  tMemStr : TMemoryStream ;
begin

  result := ''  ;
  try

  if allYData.yCoord.numRows <> 1 then    // make sure more than one spectra is being predicted
  begin
      predYSpectra.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      allYData.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      if  allYData.yCoord.meanCentred then
        allYData.yCoord.AddVectToMatrixRows(allYData.yCoord.F_MAverage) ;  // add back mean value
      allYData.yCoord.F_MAverage.Read(s1,4) ;
      tMemStr := TMemoryStream.Create ;
      tMemStr.SetSize( 4 * predYSpectra.yCoord.numCols ) ;
      tMemStr.Seek(0,soFromBeginning) ;
      for t1 := 1 to predYSpectra.yCoord.numCols do
      begin
          tMemStr.Write(s1,4) ;
      end ;
      tMemStr.Seek(0,soFromBeginning) ;
      predYSpectra.yCoord.AddVectToMatrixRows(tMemStr) ;  // add back mean value
      tMemStr.Free ;

     // this calculates the "predictive value" of the model created above i.e. the R^2 value
     tMat1 := TMatrix.Create(allXData.yCoord.SDPrec div 4) ;
     R_sqrd.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
     for t1 := 1 to predYSpectra.yCoord.numCols do  // join together each predicted and original Y data into 1 matrix
     begin
       tMat1.AddColumnsToMatrix('1-'+intToStr(predYSpectra.yCoord.numRows), inttostr(t1),predYSpectra.yCoord) ;
       tMat1.AddColumnsToMatrix('1-'+intToStr(allYData.yCoord.numRows), '1',allYData.yCoord) ;
//tMat1.SaveMatrixDataTxt('rsqrd_'+inttostr(t1)+'.txt','        ') ;
       tMat2 := vcv.GetVarCovarMatrix(tMat1) ;  // simple matrix multiply to end with symmetric matrix
       vcv.StandardiseVarCovar(tMat2) ;         // divide by the variance to normalise
       s1 := vcv.ReturnPearsonsCoeffFromStandardisedVarCovar(tMat2,1,2) ; // this is the R value for data
       s1 := s1 * s1 ;  // calculate R^2
       d1 := s1 ;

       if  R_sqrd.yCoord.SDPrec = 4 then
         R_sqrd.yCoord.F_Mdata.Write(s1,4)
       else if R_sqrd.yCoord.SDPrec = 4 then
         R_sqrd.yCoord.F_Mdata.Write(d1,8) ;

       tMat1.ClearData(tMat1.SDPrec div 4) ;
//       tMat2.ClearData(tMat2.SDPrec div 4) ;
       tMat2.Free ;
//         tMat1.Free ;
     end ;
//     tMat2.Free ;
     tMat1.Free ;
     R_sqrd.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  end ;



  except on Exception do
  begin
     tMat2.Free ;
     tMat1.Free ;
     result := 'CalcRSqrd failed'   ;
     raise;
  end ;
  end ;

end ;


// *********************    THIS IS THE MAIN FUNCTION OF THIS UNIT   ***********************
// GetBatchArguments() has to be called before this function
// LineColor has to be assigned before calling this function
function  TPLSYPredictTestBatch.TestModelData(inputX, inputY, inputRegresCoef : TSpectraRanges)  : string ;
var
  resultString : string ;
  tMat : TMatrix ;
begin
   result := '' ;
   if (inputX = nil) or (inputRegresCoef = nil)  then
   begin
      result := 'X data or regression coefficients missing from col 2 or 4' ;
      exit ;
   end ;
   try
     if inputY = nil then YDataExists := false  // if no Y data then we can not calculate Y residuals or R^2. i.e. Only predict
     else  YDataExists := true ;

     resultString := '' ;
     // this gets the data matrix (X then Y) and pre-processes
     resultString := resultString + GetAllXData(  inputX ) ;
     if YDataExists = true then
       resultString := resultString + GetAllYData(  inputY ) ;
     resultString := resultString + PreProcessData  ;

     if  length(resultString) > 0 then
     begin
       result := 'TestModelData function failed: #13'+ resultString ;
       exit ;
     end ;

     numPCs := inputRegresCoef.yCoord.numRows ;
     regresCoefSpectra := TSpectraRanges.Create( inputRegresCoef.yCoord.SDPrec div 4, 1,1, @inputRegresCoef.LineColor ) ;
     regresCoefSpectra.CopySpectraObject(inputRegresCoef)  ; // These come from previous model creation using  PLS or PCR

     predYSpectra       := TSpectraRanges.Create(inputX.yCoord.SDPrec div 4,allXData.yCoord.numRows,numPCs, @self.LineColor)    ;  // this is a scatter plot of actual vs predicted

     if allXData.yImaginary = nil then
     begin
       // Do the prediction
       tMat  := PredictYFromModel(allXData.yCoord, regresCoefSpectra.yCoord ); // returns predicted Y data
       predYSpectra.yCoord.CopyMatrix(tMat) ;
       tMat.Free ;
       
       if predYSpectra.yCoord = nil then
       begin
          result := 'Exception in PredictYFromModel()' ;
          predYSpectra.yCoord := TMatrix.Create(inputX.yCoord.SDPrec div 4) ;  // recreate the yCoord data
          exit ;
       end ;

       if  YDataExists = true then  // there is Y data so calculate statistics
       begin
         YresidualsSpectra  := TSpectraRanges.Create(inputX.yCoord.SDPrec div 4,allXData.yCoord.numRows,numPCs, @self.LineColor) ; // this is where we get PRESS data from
         SEPSpectra         := TSpectraRanges.Create(inputX.yCoord.SDPrec div 4,1                      ,numPCs, @self.LineColor) ;
         R_sqrd             := TSpectraRanges.Create(inputX.yCoord.SDPrec div 4,1                      ,numPCs, @self.LineColor) ;

         resultString := resultString + CalcYResidualData(true) ;  // calculates data for "YresidualsSpectra"
         resultString := resultString + CalcSEPData(YresidualsSpectra.yCoord, SEPSpectra.yCoord) ;
         resultString := resultString + CalcRSqrd(true) ;
         CreateDisplayDataWithResiduals(@self.LineColor) ;  // may have problems with this
       end
       else
       begin
         CreateDisplayNoRefYData( @self.LineColor) ;
       end ;

       result := '' ;
     end ;

    except on Exception do
    begin
       result := 'Exception in TestModelData()' ;
       raise;
    end ;
    end ;

end ;


function  TPLSYPredictTestBatch.CreateDisplayNoRefYData(lc : pointer )  : string ;
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
begin
     // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject

    if allXData.yCoord.complexMat = 2 then
    begin
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec div 4, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predYSpectra.yImaginary := TMatrix.Create2(predYSpectra.yCoord.SDPrec div 4, predYSpectra.yCoord.numRows, predYSpectra.yCoord.numCols) ;
         predYSpectra.yCoord.MakeUnComplex( predYSpectra.yImaginary ) ;
    end ;

    // 3/ ****  Create X data for output display objects  ****
    allXData.SeekFromBeginning(3,1,0) ;
//    allYData.SeekFromBeginning(3,1,0) ;    ???

    predYSpectra.SeekFromBeginning(3,1,0) ;

    // A/ create x coord data for predYSpectra (one point for each PC)
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCs do
       begin
         s1 := t1 ;
         predYSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCs do
      begin
        d1 := t1 ;
        predYSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

    // reset data to first positions
    allXData.SeekFromBeginning(3,1,0) ;
//    allYData.SeekFromBeginning(3,1,0) ;    ???
    predYSpectra.SeekFromBeginning(3,1,0) ;
end ;



function  TPLSYPredictTestBatch.CreateDisplayDataWithResiduals(lc : pointer)  : string  ;
var
 t1 : integer ;
 s1 : single ;
 d1 : double ;
begin
    // 1/ ****  Create display objects for calculated data ****  Then just add Y data matric from PLSResultsObject

    if allXData.yCoord.complexMat = 2 then
    begin
         YresidualsSpectra.yImaginary := TMatrix.Create2(YresidualsSpectra.yCoord.SDPrec div 4, YresidualsSpectra.yCoord.numRows, YresidualsSpectra.yCoord.numCols) ;
         YresidualsSpectra.yCoord.MakeUnComplex( YresidualsSpectra.yImaginary ) ;
         // not sure if these are ever going to be complex
         regresCoefSpectra.yImaginary := TMatrix.Create2(regresCoefSpectra.yCoord.SDPrec div 4, regresCoefSpectra.yCoord.numRows, regresCoefSpectra.yCoord.numCols) ;
         regresCoefSpectra.yCoord.MakeUnComplex( regresCoefSpectra.yImaginary ) ;
         predYSpectra.yImaginary := TMatrix.Create2(predYSpectra.yCoord.SDPrec div 4, predYSpectra.yCoord.numRows, predYSpectra.yCoord.numCols) ;
         predYSpectra.yCoord.MakeUnComplex( predYSpectra.yImaginary ) ;
    end ;

    // 3/ ****  Create X data for output display objects  ****
    // A/ add 'sample number' to scores matrix (may be able to reference a 'string' value from this value in the future)

    // B/ add wavelength values as xCoord for loadings matrix storage
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;

    predYSpectra.SeekFromBeginning(3,1,0) ;
    SEPSpectra.SeekFromBeginning(3,1,0);
    R_sqrd.SeekFromBeginning(3,1,0) ;

    // C/ create x coord data for eigenValSpectra and R_sqrd_PLS, SEPSpectra and YResiduals (one point for each PC)
    YresidualsSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    if self.allXData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to self.numPCs do
       begin
         s1 := t1 ;
         R_sqrd.xCoord.F_Mdata.Write(s1,4) ;
         SEPSpectra.xCoord.F_Mdata.Write(s1,4) ;
         YresidualsSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if self.allXData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to self.numPCs do
      begin
        d1 := t1 ;
        R_sqrd.xCoord.F_Mdata.Write(d1,8) ;
        SEPSpectra.xCoord.F_Mdata.Write(d1,8) ;
        YresidualsSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;



  // predictedYPLS - ScatterPlot
  // D/ create x coord data for predictedYPLS (one point for each sample)
    predYSpectra.yCoord.Transpose ;
    predYSpectra.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    allYData.SeekFromBeginning(3,1,0) ;
    if allYData.yCoord.SDPrec = 4 then
    begin
       for t1 := 1 to allYData.yCoord.numRows do
       begin
         allYData.yCoord.F_Mdata.Read(s1,4) ;
         predYSpectra.xCoord.F_Mdata.Write(s1,4) ;
       end ;
    end
    else
    if allYData.yCoord.SDPrec = 8 then
    begin
      for t1 := 1 to allYData.yCoord.numRows  do
      begin
        allYData.yCoord.F_Mdata.Read(d1,8) ;
        predYSpectra.xCoord.F_Mdata.Write(d1,8) ;
      end
    end ;

    // reset data to first positions
    allXData.SeekFromBeginning(3,1,0) ;
    allYData.SeekFromBeginning(3,1,0) ;
    YresidualsSpectra.SeekFromBeginning(3,1,0) ;
    regresCoefSpectra.SeekFromBeginning(3,1,0) ;
    predYSpectra.SeekFromBeginning(3,1,0) ;
    SEPSpectra.SeekFromBeginning(3,1,0) ;
    R_sqrd.SeekFromBeginning(3,1,0) ;
end ;



end.
 