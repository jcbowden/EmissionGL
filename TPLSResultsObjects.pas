unit TPLSResultsObjects;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface
uses  classes,  SysUtils, TMatrixOperations, TMatrixObject, TVarAndCoVarOperations,
      BLASLAPACKfreePas, TASMTimerUnit ;

type
  PLSResults = class
  public
    dataCreated, dataSaved : boolean ;
    PCOutputFilename : string ;

    numPCs : integer  ; // the number of PC's calculated
    XMatrix, YMatrix  : TMatrix; // these are copied over in CreatePLSModelMatrix function

    ScoresPLS         : TMatrix ;
    XEVects           : TMatrix ;
    EigenValues       : TMatrix ;  // Eigenvalue = scores(PCx)' * scores(PCx)  ==  variance of each PC
//    XResiduals        : TMatrix ;
//    XRegenMatrix      : TMatrix ;  // Data made from specific PCs using  RegenerateData() function
    YResidualsPLS     : TMatrix ;  // Stores output data
    YPredTotal        : TMatrix ;  // sum of PredictedYPLS row-wise
    Weights           : TMatrix ;  // Weights is a specific to PLS calculations
    RegresCoefPLS     : TMatrix ;  // Coefficients for regression with a cirtain number of PCs for known Y values
    R_sqrd_PLS        : TMatrix ;
    YEVectsPLS        : TMatrix ;  // contains 1 value for each PC for each Y value (which is only 1 in PLS1)

    constructor Create(PCOutputFilenameIn : string; singleOrDouble : integer) ; // singleOrDouble = 1 (single) or = 2 (double)
    destructor  Destroy; override; // found in implementation part below
    procedure   Free;

    // PLS-1 regression  S. Wold algorithm **********************
    // from:   	Brereton, R.G., Chemometrics. Data Analysis for the Laboratory and Chemical Plant
    //          John Wiley & Sons, Ltd 2003
    procedure CreatePLSModelMatrix(xDataIn : TMatrix; yDataIn : TMatrix;  numPCsWanted : integer) ;  // creates "RegressionCoef" TMatrix for a set of X data with known Y values
    function  PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ;
//    function  RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;  // this is inherited // pcRange is a list of PCs to include when regenerating the data
//    function  CalcResidualData(addMean : boolean) : string  ;

  private
    mo  : TMatrixOps ;
    vcv : TVarAndCoVarFunctions ;

    PredictedYPLS     : TMatrix ;  // Contribution of each PC to predicted y values (added in YPredTotal for dislay above)

    // return result is 'true' if want to continue without saving
    function  ClearResultsData(singleOrDouble : integer;  messageStr : string) : boolean ;
    function  SaveResultsData(PCOutputFilename : string) : boolean ;
    procedure MakeAllComplex ;

//    function  ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
    procedure CalculateEigenVals ; // stores results in "EigenValues" TMatrix
    function  ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
end;


implementation

uses  FileInfo ;

constructor PLSResults.Create(PCOutputFilenameIn : string; singleOrDouble : integer );
begin
//  inherited Create;
  PCOutputFilename := PCOutputFilenameIn ;

  ScoresPLS         :=  TMatrix.Create(singleOrDouble);
  XEVects           :=  TMatrix.Create(singleOrDouble);
  eigenvalues       :=  TMatrix.Create(singleOrDouble);
//  XResiduals        :=  TMatrix.Create(singleOrDouble);
//  XRegenMatrix      :=  TMatrix.Create(singleOrDouble);
  YResidualsPLS     :=  TMatrix.Create(singleOrDouble);
  YPredTotal        :=  TMatrix.Create(singleOrDouble);
  Weights           :=  TMatrix.Create(singleOrDouble);
  RegresCoefPLS     :=  TMatrix.Create(singleOrDouble);
  YEVectsPLS        :=  TMatrix.Create(singleOrDouble);

  mo := TMatrixOps.Create ;
  vcv :=  TVarAndCoVarFunctions.Create ;

  dataSaved := false ;
  dataCreated := false ;

end;


destructor PLSResults.Destroy;
begin

  ScoresPLS.Free ;
  XEVects.Free ;
  Eigenvalues.Free ;
//  XResiduals.Free ;
//  XRegenMatrix.Free ;
  YResidualsPLS.Free ;
  YPredTotal.Free ;
  Weights.Free ;
//  R_sqrd_PLS.Free ;
  YEVectsPLS.Free ;

  if XMatrix <> nil then
    XMatrix.free ;
  if YMatrix <> nil then
    YMatrix.Free ;
  if PredictedYPLS <> nil then
    PredictedYPLS.free ;
  if RegresCoefPLS <> nil then
    RegresCoefPLS.Free ;


  mo.Free ;
  vcv.Free ;

//  inherited Destroy;
//  inherited Free;
end;


procedure PLSResults.Free;
begin
 if Self <> nil then Destroy;
end;


function PLSResults.SaveResultsData(PCOutputFilename : string) : boolean ;
begin

    result := false ;
end ;


function PLSResults.ClearResultsData(singleOrDouble : integer;  messageStr : string) : boolean ;
Var
  msgRes : Word ;
begin
    result := true ;
    ScoresPLS.ClearData(singleOrDouble) ;
    XEVects.ClearData(singleOrDouble) ;
    Eigenvalues.ClearData(singleOrDouble) ;
//    XResiduals.ClearData(singleOrDouble) ;
//    XRegenMatrix.ClearData(singleOrDouble) ;
    YResidualsPLS.ClearData(singleOrDouble) ;
    YPredTotal.ClearData(singleOrDouble) ;
    Weights.ClearData(singleOrDouble) ;
    RegresCoefPLS.ClearData(singleOrDouble) ;
    YEVectsPLS.ClearData(singleOrDouble) ;
    if XMatrix <> nil then
      XMatrix.ClearData(singleOrDouble) ;
    if YMatrix <> nil then
      YMatrix.ClearData(singleOrDouble) ;
    if PredictedYPLS <> nil then
      PredictedYPLS.ClearData(singleOrDouble) ;
    if RegresCoefPLS <> nil then
      RegresCoefPLS.Free ;

    dataCreated := false ;

end ;



procedure PLSResults.MakeAllComplex ;
begin

  ScoresPLS.F_Mdata.SetSize(ScoresPLS.F_Mdata.Size * 2) ;
  ScoresPLS.complexMat  :=  2 ;
  XEVects.F_Mdata.SetSize(XEVects.F_Mdata.Size * 2) ;
  XEVects.complexMat  :=  2 ;
  Eigenvalues.F_Mdata.SetSize(Eigenvalues.F_Mdata.Size * 2) ;
  Eigenvalues.complexMat  :=  2 ;
//  XResiduals.F_Mdata.SetSize(XResiduals.F_Mdata.Size * 2) ;
//  XResiduals.complexMat  :=  2 ;
//  XRegenMatrix.F_Mdata.SetSize(XRegenMatrix.F_Mdata.Size * 2) ;
//  XRegenMatrix.complexMat  :=  2 ;
  YResidualsPLS.F_Mdata.SetSize(YResidualsPLS.F_Mdata.Size * 2) ;
  YResidualsPLS.complexMat  :=  2 ;
  YPredTotal.F_Mdata.SetSize(YPredTotal.F_Mdata.Size * 2) ;
  YPredTotal.complexMat  :=  2 ;
  Weights.F_Mdata.SetSize(Weights.F_Mdata.Size * 2) ;
  Weights.complexMat  :=  2 ;
  RegresCoefPLS.F_Mdata.SetSize(RegresCoefPLS.F_Mdata.Size * 2) ;
  RegresCoefPLS.complexMat  :=  2 ;
  YEVectsPLS.F_Mdata.SetSize(YEVectsPLS.F_Mdata.Size * 2) ;
  YEVectsPLS.complexMat  :=  2 ;

    if XMatrix <> nil then begin
      XMatrix.F_Mdata.SetSize(XMatrix.F_Mdata.Size * 2) ;
      XMatrix.complexMat  :=  2 ; end ;
    if YMatrix <> nil then  begin
      YMatrix.F_Mdata.SetSize(YMatrix.F_Mdata.Size * 2) ;
      YMatrix.complexMat  :=  2 ; end ;
    if PredictedYPLS <> nil then  begin
      PredictedYPLS.F_Mdata.SetSize(PredictedYPLS.F_Mdata.Size * 2) ;
      PredictedYPLS.complexMat  :=  2 ; end ;
    if RegresCoefPLS <> nil then begin
      RegresCoefPLS.F_Mdata.SetSize(RegresCoefPLS.F_Mdata.Size * 2) ;
      RegresCoefPLS.complexMat  :=  2 ; end ;

end;



// this creates the PLS regression model. X and Y data must be of same numer of rows (samples).
// pcRange is '1-numPCs'
procedure PLSResults.CreatePLSModelMatrix(xDataIn : TMatrix; yDataIn : TMatrix; numPCsWanted : integer)  ;
var
  t1, t2 : integer ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
  tMat1, tMat2, tMat3  : TMatrix ;
  normEVects : TMatrix ;
  tEVects_x : TMatrix ;
  tEVects_y : single ;
  tScores   : TMatrix ;
  tWeights  : TMatrix ;
  y_sum   : TMemoryStream ;

  PCsSoFar  : integer ;
  divisorSingle  : single ;
  scoresSingle   : single ;

  MKLxdata, MKLydata, MKLWeights, MKLEVects, MKLscores, MKLYEstimate : pointer ;
  MKLtint, MKLlda : integer ;
  MKLtrans : char ;
  SSScores_s, SSEVects_s, lengthSSEVects_s, newSSScores_s, MKLalpha_s, MKLbeta_s : single ;
  SSScores_d, SSEVects_d, lengthSSEVects_d, newSSScores_d, MKLalpha_d, MKLbeta_d : double ;

  tXMatrix : TMatrix  ;
  tYMatrix : TMatrix  ;

begin
try
  tEVects_x     := TMatrix.Create2(xDataIn.SDPrec, 1, xDataIn.numCols) ;
  tScores       := TMatrix.Create2(xDataIn.SDPrec, xDataIn.numRows, 1) ;
  tWeights      := TMatrix.Create2(xDataIn.SDPrec, 1, xDataIn.numCols) ;
  y_sum         := TMemoryStream.Create ; // this is needed for GetTotalRowsColsFromString function to determine numPCsWanted

  tYMatrix := TMatrix.Create(yDataIn.SDPrec) ; // this is used in calculation, and results in residuals
  tYMatrix.CopyMatrix(yDataIn) ;
//tYMatrix.SaveMatrixDataTxt('tYMatrix_PC'+'.txt','        ') ;
  // **** THIS IS PROBABLY NOT NEEDED *** JUST POINT to xDataIn  ****
  YMatrix := TMatrix.Create(yDataIn.SDPrec) ;   // this stores the original Y data
  YMatrix.CopyMatrix(yDataIn) ;

  // copy data for calculation below
//  tXMatrix := TMatrix.Create(xDataIn.SDPrec) ; //1 // this is used in calculation, and results in residuals
//  tXMatrix.CopyMatrix(xDataIn) ;                     //1 // IT IS DELETED IN FINALY BLOCK BELOW
  tXMatrix :=  xDataIn ;    //1
  // **** THIS IS PROBABLY NOT NEEDED *** JUST POINT to xDataIn  ****
//1  XMatrix  := TMatrix.Create(xDataIn.SDPrec) ; //1 // this is a copy of the oriinal data, to be used for display
//1  XMatrix.CopyMatrix(xDataIn) ;                      //1
//tXMatrix.SaveMatrixDataTxt('tXMatrix_PC'+'.txt','        ') ;

  // intially is 1 column, contribution of each PC to predicted y values are added (i.e. have to sum the values in the rows + mean centre value)
  PredictedYPLS := TMatrix.Create2(yDataIn.SDPrec,yDataIn.numRows,1) ;
  PredictedYPLS.Zero(PredictedYPLS.F_Mdata) ; // zero as first column is predicted mean centred data
  R_sqrd_PLS    := TMatrix.Create2(yDataIn.SDPrec, 1, numPCsWanted )  ;

  YEVectsPLS.numRows := 1 ;
//  YEVectsPLS.numCols := 0 ;

  // mean centre X and Y data
  if (not xDataIn.meanCentred) then
     tXMatrix.MeanCentre ;
  if (not yDataIn.meanCentred) then
     tYMatrix.MeanCentre ;


  self.numPCs := numPCsWanted ;
  PCsSoFar := 1 ;
  while (PCsSoFar <= numPCsWanted) do
  begin
    if xDataIn.SDPrec = 4 then    // single precision
    begin
      MKLscores   :=  tScores.F_Mdata.Memory ;
      MKLEVects   :=  tEVects_x.F_Mdata.Memory ;
      MKLWeights  :=  tWeights.F_Mdata.Memory ;
      MKLxdata    :=  tXMatrix.F_Mdata.Memory ;
      MKLydata    :=  tYMatrix.F_Mdata.Memory ;
      MKLlda      :=  tXMatrix.numCols ;        // = first dimension of matrix  (always numCols for TMatrix data)
      MKLtrans   := 'n' ;
      MKLalpha_s := 1.0 ;
      MKLtint    := 1 ;  // incx
      MKLbeta_s  := 0.0 ;  // if this is zero then sgemv y data is not added


      // Part 1a - calculate EVect weights (MKLWeights)
      //  weights =  X_t' * y_t ;       // (22 x 1) = (22 x 16) MM (16 x 1)
      // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
      // call sgemv ( trans,    m,                n,          alpha,     a,       lda,    x,        incx,    beta,      y,        incy )
      sgemv (MKLtrans, tXMatrix.numCols , tXMatrix.numRows  , MKLalpha_s, MKLxdata, MKLlda, MKLydata, MKLtint, MKLbeta_s, MKLWeights, MKLtint ) ;
//tWeights.SaveMatrixDataTxt('tWeights_PC'+inttostr(PCsSoFar)+'.txt','        ') ;

      // Part 1b - scale the weights  by:  Y' * Y
      divisorSingle := sdot (tYMatrix.numRows,  MKLydata, MKLtint,  MKLydata, MKLtint) ;
//messagedlg('divisorSingle ='+ floattostrf(divisorSingle,ffGeneral,7,5) ,mtError,[mbOK],0) ;
      divisorSingle  := 1 / divisorSingle ;
      //  sscal ( n, a, x, incx )
       //  x = a*x
       sscal(tWeights.numRows, divisorSingle, MKLWeights, MKLtint) ;  // tWeights scaled by divisorSingle ( = Y' * Y )

      tMat1 := mo.ReturnVectNormalisedMatrix(tWeights) ;
      tWeights.CopyMatrix(tMat1) ;
      tMat1.Free ;
      MKLWeights :=  tWeights.F_Mdata.Memory ;


      // Part 3 - Estimate scores for next PLS component and sum of squares of the scores vector
      MKLtrans   := 't' ;
      divisorSingle := 1.0 ;
      // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
      // call sgemv ( trans,    m,                n,          alpha,       a,       lda,    x,          incx,    beta,      y,        incy )
      sgemv (MKLtrans, tXMatrix.numCols, tXMatrix.numRows, divisorSingle, MKLxdata, MKLlda, MKLWeights, MKLtint, MKLbeta_s, MKLscores, MKLtint ) ;
//tScores.SaveMatrixDataTxt('tScores_PC'+inttostr(PCsSoFar)+'.txt','        ') ;

      scoresSingle := sdot (tScores.numRows,  MKLscores, MKLtint,  MKLscores, MKLtint) ; //messagedlg('scoresSingle ='+ floattostrf(scoresSingle,ffGeneral,7,5) ,mtError,[mbOK],0) ;
      scoresSingle := 1 / scoresSingle ;
      // Part 4 - Estimate x and y EVects for  PLS component
      MKLtrans   := 'n' ;
      // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
      // call sgemv ( trans,    m,                n,          alpha,       a,       lda,    x,          incx,    beta,      y,        incy )
      sgemv (MKLtrans, tXMatrix.numCols, tXMatrix.numRows, scoresSingle, MKLxdata, MKLlda, MKLscores, MKLtint, MKLbeta_s, MKLEVects, MKLtint ) ;
//tEVects_x.SaveMatrixDataTxt('tEVects_PC'+inttostr(PCsSoFar)+'.txt','        ') ;

      // above sgemv was calculation of tEVects_x
      tEVects_y := sdot (tScores.numRows,  MKLydata, MKLtint,  MKLscores, MKLtint) ;
      tEVects_y := tEVects_y  * scoresSingle ;
//messagedlg('tEVects_y ='+ floattostrf(tEVects_y,ffGeneral,7,5) ,mtError,[mbOK],0) ;
      YEVectsPLS.numCols := YEVectsPLS.numCols + 1 ;
      YEVectsPLS.F_Mdata.SetSize(YEVectsPLS.F_mData.Size + 4) ;
      YEVectsPLS.F_Mdata.Seek(  (PCsSoFar -1) * 4, soFromBeginning) ;
      YEVectsPLS.F_Mdata.Write(tEVects_y, 4) ;
      YEVectsPLS.F_Mdata.Seek(0, soFromBeginning) ;

      // Part 6 - Calculate X residuals  (deflate X)   (Remove contribution from this PC)
       MKLalpha_s := -1.0 ;
       // a := alpha*x*y’ + a,
       // sger (       m,              n,           alpha,         x,        incx,      y,       incy,    a,    lda )
       sger (tXMatrix.numCols , tXMatrix.numRows  , MKLalpha_s,  MKLEVects, MKLtint, MKLscores  , MKLtint, MKLxdata, MKLlda) ;
       MKLalpha_s := 1.0 ;
//tXMatrix.SaveMatrixDataTxt('tXMatrix_'+inttostr(PCsSoFar)+'.txt','        ') ;

       // Part 7 - store PC scores and EVects
       ScoresPLS.AddColToEndOfData(tScores.F_Mdata, tScores.numRows) ;
//ScoresPLS.SaveMatrixDataTxt('ScoresPLS_'+inttostr(PCsSoFar)+'.txt','        ') ;
       XEVects.AddRowToEndOfData(tEVects_x,1,tEVects_x.numCols) ;
//XEVects.SaveMatrixDataTxt('XEVects_'+inttostr(PCsSoFar)+'.txt','        ') ;
       Weights.AddRowToEndOfData(tWeights,1,tWeights.numCols) ;
//Weights.SaveMatrixDataTxt('Weights_'+inttostr(PCsSoFar)+'.txt','        ') ;


// calculate regression coefficients - with help from : http://www.iasbs.ac.ir/chemistry/chemometrics/  power point slide on PLS
      //  regCoefAll( : , num_PCs_so_far  )   = weightsPLS * inv(xEVectsPLS' * weightsPLS) * yLoad'  ;

       // ********** the L * [L' * L]^-1  works MUCH better than W [L' * W]^-1 ***************
       tMat1 := mo.MultiplyMatrixByMatrix(XEVects     ,Weights   ,false ,true ,1.0,false) ;   // ( Rcoef = Weights x  YLoad' ) creates a vector of regression coefficients
//tMat1.SaveMatrixDataTxt('tMat1_'+inttostr(PCsSoFar)+'.txt','        ') ;
       if mo.MatrixInverseGeneral(tMat1)<>0 then exit ;  // exits if inverse cannot be found
//tMat3.SaveMatrixDataTxt('tMat3_inverse'+inttostr(PCsSoFar)+'.txt','        ') ;
       tMat2 := mo.MultiplyMatrixByMatrix(Weights , tMat1,true,false,1.0,false) ;
       tMat1.Free ;
       tMat1 := mo.MultiplyMatrixByMatrix(tMat2 , YEVectsPLS,false,true,1.0,false) ;
       RegresCoefPLS.AddRowToEndOfData(tMat1,1,tMat1.numRows) ;
//RegresCoefPLS.SaveMatrixDataTxt('RegresCoefPLS'+inttostr(PCsSoFar)+'.txt','        ') ;    //  ****** check this on 2nd time through *******
       tMat1.Free ;
       tMat2.Free ;



      // Part 8 - Determine new concentration estimate
       //  sscal ( n, a, x, incx )
       //  x = a*x
       sscal(tScores.numRows, tEVects_y, MKLscores, MKLtint) ;  // tScores scaled by tEVects_y
       // add back mean centred value to get true value
       PredictedYPLS.AddColToEndOfData(tScores.F_Mdata,tScores.numRows) ; // first col is zeros due to mean centering
//PredictedYPLS.SaveMatrixDataTxt('PredictedYPLS_'+inttostr(PCsSoFar)+'.txt','        ') ;


      if y_sum = nil then  y_sum := TMemoryStream.Create
      else  y_sum.Clear ;
        //clear y_sum
      y_sum.SetSize(PredictedYPLS.numRows * 4) ;
      y_sum.Seek(0,soFromBeginning) ;
      tYMatrix.F_Mdata.Seek(0,soFromBeginning) ;
      PredictedYPLS.F_Mdata.Seek(0,soFromBeginning) ;
      // Part 9 - sum all previously calculated y values on row by row basis
      //         (calculates full contribution to predicted Y)
      for t1 := 1 to PredictedYPLS.numRows do
      begin
        s2 := 0.0 ;
        for t2 := 1 to PredictedYPLS.numCols do
        begin
           PredictedYPLS.F_MData.Read(s1,4) ;
           s2 := s2 + s1 ;
        end ;
        tYMatrix.F_Mdata.Read(s3,4) ;
        s3 := s3 - s1 ;
        tYMatrix.F_Mdata.Seek(-4,soFromCurrent) ;
        tYMatrix.F_Mdata.write(s3,4) ;
        y_sum.Write(s2,4) ;
      end ;
      tYMatrix.F_Mdata.Seek(0,soFromBeginning) ;
      y_sum.Seek(0,soFromBeginning) ;
      // add to total sum for display
      YPredTotal.AddColToEndOfData(y_sum,PredictedYPLS.numRows) ;
//YPredTotal.SaveMatrixDataTxt('YPredTotal_'+inttostr(PCsSoFar)+'.txt','        ') ;

      y_sum.Seek(0,soFromBeginning) ;
      // Calculate y residuals
      YMatrix.F_Mdata.Seek(0,soFromBeginning) ;
      for t1 := 1 to PredictedYPLS.numRows do
      begin
         YMatrix.F_Mdata.Read(s1,4) ;
         y_sum.Read(s2,4) ;
         s1 := s1 - s2 ;
         y_sum.Seek(-4,soFromCurrent) ;
         y_sum.Write(s1,4) ;
      end ;
      YResidualsPLS.AddColToEndOfData(y_sum,PredictedYPLS.numRows) ;

// tYMatrix.SaveMatrixDataTxt('tYMatrix_'+inttostr(PCsSoFar)+'.txt','        ') ;
    end
    else
    if xDataIn.SDPrec = 8 then    // single precision
    begin
      // double precision code to go here
    end ;

    Form4.StatusBar1.Panels[1].Text := 'PLS1 PC number ' + inttostr(PCsSoFar) + ' found.'  ;
{    Write() ;
    Write(  ) ;
    WriteLn(  ) ; }
    PCsSoFar := PCsSoFar + 1  ;
  end ;

//PredictedYPLS.SaveMatrixDataTxt('PredictedYPLS_'+inttostr(PCsSoFar)+'.txt','        ') ;
//RegresCoefPLS.SaveMatrixDataTxt('RegresCoefPLS_ALL'+'.txt','        ') ;
//YEVectsPLS.SaveMatrixDataTxt('YEVectsPLS_PC123.txt','        ') ;



  // transpose is dependent upon being an image or not
//  if IsImageData = true then
//    YResidualsPLS.Transpose ;
  CalculateEigenVals ;  // not sure what use this is in PLS

//  to conserve memory this can be removed
//  RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(XEVects.numCols),true,XMatrix.F_MAverage) ;

//  to conserve memory this can be removed
    // residuals do not need to be calculated here as they are whats left over in tXMatrix
//  XResiduals.CopyMatrix(tXMatrix) ;
    // Calculate them anyway, to see if code works
//  CalcResidualData ( true ) ;

  // this calculates the "predictive value" of the model created above i.e. the R^2 value
  tMat1 := TMatrix.Create(xDataIn.SDPrec) ;
  R_sqrd_PLS.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 1 to YPredTotal.numCols do  // join together each predicted and original Y data into 1 matrix
  begin
     tMat1.AddColumnsToMatrix('1-'+intToStr(YPredTotal.numRows), inttostr(t1),YPredTotal) ;
     tMat1.AddColumnsToMatrix('1-'+intToStr(yDataIn.numRows), '1',yDataIn) ;

     tMat2 := vcv.GetVarCovarMatrix(tMat1) ;  // simple matrix multiply to end with symmetric matrix
     vcv.StandardiseVarCovar(tMat2) ;         // divide by the variance to normalise
     s1 := vcv.ReturnPearsonsCoeffFromStandardisedVarCovar(tMat2,1,2) ; // this is the R value for data
     s1 := s1 * s1 ;  // calculate R^2
     d1 := s1 ;

     if  R_sqrd_PLS.SDPrec = 4 then
       R_sqrd_PLS.F_Mdata.Write(s1,4)
     else if R_sqrd_PLS.SDPrec = 4 then
       R_sqrd_PLS.F_Mdata.Write(d1,8) ;

     tMat1.ClearData(tMat1.SDPrec) ;
     tMat2.ClearData(tMat2.SDPrec) ;
  end ;
  tMat2.Free ;
  tMat1.Free ;

  R_sqrd_PLS.F_Mdata.Seek(0,soFromBeginning) ;

  dataCreated := true ;

finally
begin

  if tEVects_x <> nil then tEVects_x.Free ;
  if tScores <> nil then tScores.Free ;
  if tWeights <> nil then tWeights.Free ;
//1  if tXMatrix <> nil then tXMatrix.Free ;
  if tYMatrix <> nil then tYMatrix.Free ;
  if y_sum <> nil then y_sum.Free ;

end ;
end ;


end ;



function PLSResults.PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
begin
  result :=  mo.MultiplyMatrixByMatrix(xData,regressCoef, false, true, 1.0, false) ;
end ;


{
function  PLSResults.CalcResidualData( addMean : boolean ) : string ;  // does not work for imaginary data
//  =  original data - regenerated data
//     RegenerateData must be called before this function
// N.B. This is not used and will not work as XMatrix assignment has been removed from CreatePLSModelMatrix() code
var
  t1, t2 : integer ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
begin

  try
  result := '' ;
  XMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  XRegenMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  XResiduals.F_Mdata.Seek(0,soFromBeginning) ;


  if XMatrix.SDPrec =  4 then
  begin
    if (XMatrix.meanCentred and (not addMean)) or ((not XMatrix.meanCentred) and  addMean) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(s1,4) ;
         XRegenMatrix.F_Mdata.Read(s2,4) ;
         s1 := s1 - s2 ;
         XResiduals.F_Mdata.Write(s1,4) ;
       end ;
      end ;
    end  // if  (XMatrix.meanCentred and (not addMean)) or ((not XMatrix.meanCentred) and  addMean)
    else
    if (XMatrix.meanCentred and addMean) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       XMatrix.F_MAverage.Seek(0,soFromBeginning);
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(s1,4) ;
         XRegenMatrix.F_Mdata.Read(s2,4) ;
          XMatrix.F_MAverage.Read(s3,4) ;
         s1 := s1 - s2 + s3 ;
         XResiduals.F_Mdata.Write(s1,4) ;
       end ;
      end ;
    end
    else
    if ((not XMatrix.meanCentred) and (not addMean)) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       XMatrix.F_MAverage.Seek(0,soFromBeginning);
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(s1,4) ;
         XRegenMatrix.F_Mdata.Read(s2,4) ;
          XMatrix.F_MAverage.Read(s3,4) ;
         s1 := s1 - s2 - s3 ;
         XResiduals.F_Mdata.Write(s1,4) ;
       end ;
      end ;
    end ;
  end
  else
  if XMatrix.SDPrec = 8 then
  begin
     if (XMatrix.meanCentred and (not addMean)) or ((not XMatrix.meanCentred) and  addMean) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(d1,4) ;
         XRegenMatrix.F_Mdata.Read(d2,4) ;
         d1 := d1 - d2 ;
         XResiduals.F_Mdata.Write(d1,4) ;
       end ;
      end ;
    end  // if  (XMatrix.meanCentred and (not addMean)) or ((not XMatrix.meanCentred) and  addMean)
    else
    if (XMatrix.meanCentred and addMean) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       XMatrix.F_MAverage.Seek(0,soFromBeginning);
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(d1,4) ;
         XRegenMatrix.F_Mdata.Read(d2,4) ;
          XMatrix.F_MAverage.Read(d3,4) ;
         d1 := d1 - d2 + d3 ;
         XResiduals.F_Mdata.Write(d1,4) ;
       end ;
      end ;
    end
    else
    if ((not XMatrix.meanCentred) and (not addMean)) then
    begin
      for t1 := 1 to XMatrix.numRows do
      begin
       XMatrix.F_MAverage.Seek(0,soFromBeginning);
       for t2 := 1 to XMatrix.numCols do
       begin
         XMatrix.F_Mdata.Read(d1,4) ;
         XRegenMatrix.F_Mdata.Read(d2,4) ;
          XMatrix.F_MAverage.Read(d3,4) ;
         d1 := d1 - d2 - d3 ;
         XResiduals.F_Mdata.Write(d1,4) ;
       end ;
      end ;
    end ;

  end ;

  XMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  XRegenMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  XResiduals.F_Mdata.Seek(0,soFromBeginning) ;
  XMatrix.F_MAverage.Seek(0,soFromBeginning);
  except on Exception do
  begin
     result := 'PLS CalcResidualData() failed' ;
  end ;
  end
end ;  }




 {
function PLSResults.RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;
// Creates data by multiplying the scores and the eigenvectors
var
  regen : TMatrix ;
  tScores, tEVects : TMatrix ;
  tStream : TMemoryStream ;
  numPCsWanted : integer ;
begin
//  regen     := TMatrix.Create ;
  tScores   := TMatrix.Create(ScoresPLS.SDPrec) ;
  tEVects := TMatrix.Create(ScoresPLS.SDPrec) ;
  tStream   := TMemoryStream.Create ;

  if (ScoresPLS.complexMat=2) then
  begin
    tScores.F_Mdata.SetSize( tScores.F_Mdata.Size * 2) ;
    tScores.complexMat := 2 ;
    tEVects.F_Mdata.SetSize( tEVects.F_Mdata.Size * 2) ;
    tEVects.complexMat := 2 ;
  end ;

  numPCsWanted := ScoresPLS.GetTotalRowsColsFromString(pcRange,tstream) ;

  // regenerate data
  if (numPCsWanted < numPCs) then
  begin
    tScores.FetchDataFromTMatrix('1-'+inttostr(ScoresPLS.numRows),pcRange,ScoresPLS) ;
    tEVects.FetchDataFromTMatrix(pcRange,'1-'+inttostr(XEVects.numCols),XEVects) ;
    regen := mo.MultiplyMatrixByMatrix(tScores, tEVects, false, false, 1.0, false) ;
  end
  else // (numPCsWanted = numPCs)
    regen := mo.MultiplyMatrixByMatrix(ScoresPLS, XEVects, false, false, 1.0, false) ;

  if  addMean and (aveDataIn.Size > 0) then
  begin
    aveDataIn.Seek(0,soFromBeginning) ;
    regen.AddVectToMatrixRows( aveDataIn ) ;
  end  ;

  tStream.Free ;
  tScores.Free ;
  tEVects.Free ;
  XRegenMatrix :=  regen ;
  // regen.Free ; // do not free data if it is actually being used somewhere

  // calculate residuals here =  original data - regenrated data
end ;
}


procedure PLSResults.CalculateEigenVals ;
// eigenvalue = scores(PCx)' * scores(PCx)
// stores eigenvalue for each PC in row vector
// % variance spanned by eigenvalue = eigenvalue / (sum of all eigenvalues)
Var
   s1 : TSingle ; // for testing only
   d1 : TDouble ;
   t1 : integer ;
   MKLtint : integer ;
   MKLscores : pointer ;

begin
  if Eigenvalues.F_Mdata.Size > 0 then   // reset the resuts TMatrix if allready used
     Eigenvalues.ClearData(Eigenvalues.SDPrec) ;

  Eigenvalues.numRows := 1 ; eigenvalues.numCols :=  self.numPCs  ;  // = Scores.numCols
  Eigenvalues.F_Mdata.SetSize(ScoresPLS.SDPrec* numPCs * ScoresPLS.complexMat) ;
  Eigenvalues.F_Mdata.Seek(0,soFromBeginning) ;

  MKLscores := ScoresPLS.F_Mdata.Memory ;
  MKLtint   := ScoresPLS.numCols ;

  for t1 := 1 to numPCs do
  begin
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 1) then
    begin
      s1[1] := sdot (ScoresPLS.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 1)then
    begin
      d1[1] := ddot (ScoresPLS.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 2)then
    begin
      s1 := cdotu (ScoresPLS.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 2)then
    begin
      d1 := zdotu(ScoresPLS.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    begin
      writeln('Function PCRResultsObject.CalculateEigenVals() error: Precision of data is not calculated correctly' ) ;
    end ;
    MKLscores := ScoresPLS.MovePointer(MKLScores,Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
  end ;

end ;


function PLSResults.ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
// % variance spanned by eigenvalue = eigenvalue / (sum of all eigenvalues)
var
  t1 : integer ;
  sum_s, s1, e_s : single ;
  sum_d, d1, e_d : double ;
begin
  if Eigenvalues.SDPrec = 4 then
  begin
    sum_s := 0 ;
    for t1 := 1 to numPCs do
    begin
       Eigenvalues.F_Mdata.Read(s1,4) ;
       sum_s := sum_s + s1 ;
       if t1 = pcNum then
         e_s := s1 ;
    end ;
    result :=  e_s / sum_s ;
  end
  else  if Eigenvalues.SDPrec = 8 then
  begin
    sum_d := 0 ;
    for t1 := 1 to numPCs do
    begin
       Eigenvalues.F_Mdata.Read(d1,8) ;
       sum_d := sum_d + d1 ;
       if t1 = pcNum then
         e_d := d1 ;
    end ;
    result :=  e_d / sum_d ;
  end
  else
    result := 0 ;
end ;



end.

