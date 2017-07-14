unit TPCR_ResultsObjects;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses  classes,  SysUtils,  TMatrixOperations, TMatrixObject , TVarAndCoVarOperations,
      TPCA_ResultsObject ;

type
  TPCRResults = class
  public
    dataCreated, dataSaved : boolean ;
    numPCsPCR : integer  ; // the total number of PC's calculated
    PCOutputFilename : string ;

    // all of these are made in tPCAObject in function DoPCAFirst below
    ScoresPCR, EVectsPCR   : TMatrix;   // Stores output data
    EigenValues            : TMatrix ; // eigenvalue = scores(PCx)' * scores(PCx)

    YMatrix  : TMatrix; // this is copied over in CreatePCRModelSecond function

    RegressionCoef         : TMatrix ;  // Coefficients for regression with a cirtain number of PCs
    PredictedY             : TMatrix ;
    YResidualsPCR          : TMatrix ;
    R_sqrd_PCR             : TMatrix ;

    constructor Create(PCOutputFilenameIn : string; singleOrDouble : integer) ; // singleOrDouble = 1 (single) or = 2 (double)
    destructor  Destroy; override; // found in implementation part below
    procedure   Free;

    // return result is 'true' if want to continue without saving
    function  ClearResultsData(singleOrDouble : integer;  messageStr : string) : boolean ;
    function  SaveResultsData(PCOutputFilename : string) : boolean ;
    procedure MakeAllComplex ;

    // PCA only works on the X data
    function  DoPCAFirst(xDataIn : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) : string  ;  // XMatrix added here so not needed in CreatePCRModelSecond
    // PCR needs Y data too
    function  CreatePCRModelSecond(xDataIn, yDataIn : TMatrix;  pcRange : string) : string ;  // creates "RegressionCoef" TMatrix for a set of X data with known Y values

    function  PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // used by CreatePCRModelSecond
//    function  RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;  // pcRange is a list of PCs to include when regenerating the data
//    function  CalcXResidualData(addMean : boolean) : string  ;
    function  CalcYResidualData(addMean : boolean) : string  ;

  private
    mo  : TMatrixOps ;
    vcv : TVarAndCoVarFunctions ;

    function  ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
    procedure CalculateEigenVals ; // stores results in "EigenValues" TMatrix
    function  ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;

end;


implementation

uses BLASLAPACKfreePas ;


constructor TPCRResults.Create(PCOutputFilenameIn : string; singleOrDouble : integer );
begin

  PCOutputFilename := PCOutputFilenameIn ;

//  XMatrix       :=  TMatrix.Create(singleOrDouble);
  YMatrix        :=  TMatrix.Create(singleOrDouble);
  ScoresPCR      :=  TMatrix.Create(singleOrDouble);
  EVectsPCR      :=  TMatrix.Create(singleOrDouble);

  eigenvalues    :=  TMatrix.Create(singleOrDouble);
  PredictedY     :=  TMatrix.Create(singleOrDouble);
  RegressionCoef := TMatrix.Create(EVectsPCR.SDPrec) ;

  mo := TMatrixOps.Create ;
  vcv :=  TVarAndCoVarFunctions.Create ;

  dataSaved := false ;
  dataCreated := false ;

end;


destructor TPCRResults.Destroy;
begin


  YMatrix.Free ;
  ScoresPCR.free ;
  EVectsPCR.free ;
  eigenvalues.free ;

  R_sqrd_PCR.Free ;
  if PredictedY <> nil then
    PredictedY.free ;
  if RegressionCoef <> nil then
    RegressionCoef.Free ;


  mo.Free ;
  vcv.Free ;

end;


procedure TPCRResults.Free;
begin
 if Self <> nil then Destroy;
end;


function TPCRResults.SaveResultsData(PCOutputFilename : string) : boolean ;
begin
    result := false ;
end ;


function TPCRResults.ClearResultsData(singleOrDouble : integer; messageStr : string) : boolean ;
Var
  msgRes : Word ;
begin

    result := true ;
    ScoresPCR.ClearData(singleOrDouble) ;
    EVectsPCR.ClearData(singleOrDouble) ;
    EigenValues.ClearData(singleOrDouble) ;

    if PredictedY <> nil then
      PredictedY.ClearData(singleOrDouble) ;
    if RegressionCoef <> nil then
      RegressionCoef.Free ;

    dataCreated := false ;

end ;



procedure TPCRResults.MakeAllComplex ;
begin

  ScoresPCR.F_Mdata.SetSize(ScoresPCR.F_Mdata.Size * 2) ;
  ScoresPCR.complexMat  :=  2 ;
  EVectsPCR.F_Mdata.SetSize(EVectsPCR.F_Mdata.Size * 2) ;
  EVectsPCR.complexMat  :=  2 ;
  eigenvalues.F_Mdata.SetSize(eigenvalues.F_Mdata.Size * 2) ;
  eigenvalues.complexMat  :=  2 ;

end;



function TPCRResults.DoPCAFirst(xDataIn : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) : string ;
var
  tPCAObject  : TPCA ;
begin
  result := '' ;

  try

     tPCAObject  := TPCA.Create(xDataIn.SDPrec)  ;
     tPCAObject.PCA(xDataIn,PCs_wanted_in, meanCentre, colStandardise) ; // this does the PCA analysis

     self.numPCsPCR := tPCAObject.numPCs ;

     // copy scores, EVects etc objects needed for P matrix calibration in next step
     self.ScoresPCR.CopyMatrix(tPCAObject.Scores) ;
     self.EVectsPCR.CopyMatrix(tPCAObject.EVects) ;
     self.EigenValues.CopyMatrix(tPCAObject.EigenValues) ;


     self.dataCreated := true ;
     tPCAObject.Free ;

  except
  begin
     self.dataCreated := false ;
     tPCAObject.Free ;
     result := 'PCA analysis failed' ;
  end ;
  end ;

end ;



// this creates the regression model -  Inverse Least Squares (P-Matrix Calibration). Calculates: P = CA'[AA']^-1  = Y_times_Model
// .PCA() has to be called first to make "EVects" TMatrix
function TPCRResults.CreatePCRModelSecond( xDataIn, yDataIn : TMatrix; pcRange : string)  : string ;
var
  tScoresProjection, InverseMat1, tMat1, tMat2  : TMatrix ;
  tY_times_Model : TMatrix ;
  tPredictedY : TMatrix ;
  tRegressionCoef : TMAtrix ;
  tModel : TMatrix ;
  tNormEVects : TMatrix ;
  tEVects : TMatrix ;
  tStream : TMemoryStream ;
  tNumPCsWanted : integer ;
  t1, t2 : integer ;
  s1 : single ;
  d1 : double ;


begin

  if   self.dataCreated = false then
  begin
    result := 'PCA not carried out, can not create PCR model' ;
    exit ;
  end ;

//  self.YMatrix.CopyMatrix(yDataIn) ;

  tEVects      := TMatrix.Create(EVectsPCR.SDPrec) ;
  tStream      := TMemoryStream.Create ;   // holds (0 based) array of which PCs are wanted

  tNumPCsWanted :=  EVectsPCR.GetTotalRowsColsFromString(pcRange,tStream) ;
  tNormEVects   :=  ReturnVectNormalisedEVects(EVectsPCR) ;
  tStream.Seek(0,soFromBeginning) ;

   // copy only EVectors wanted for use in the calibration
  tEVects.FetchDataFromTMatrix(tEVects.CreateStringFromRowColStream(tStream)  ,'1-'+inttostr(tNormEVects.numCols)  ,tNormEVects);
  tNormEVects.ClearData(tEVects.SDPrec) ;
  tNormEVects.CopyMatrix(tEVects);
  tEVects.ClearData(tEVects.SDPrec); // this is used again in next section to accept incremented numbers of vectors from tNormEVects (which contains all the vectors)


  for  t2 := 1 to (tNumPCsWanted) do
  begin

    // calculate scores (of normalised EVects)
    if (t2 < numPCsPCR) then
    begin
      tEVects.FetchDataFromTMatrix('1-'+inttostr(t2),'1-'+inttostr(tNormEVects.numCols),tNormEVects) ;  // "normEVects" created by previous PCA
      tScoresProjection := mo.MultiplyMatrixByMatrix(xDataIn, tEVects, false, true, 1.0, true) ;
    end
   else
   begin
      tEVects.Free ;
      tEVects :=  tNormEVects ;
      tScoresProjection := mo.MultiplyMatrixByMatrix(xDataIn, tNormEVects, false, true, 1.0, true) ; // leave inverted => next function is reverse of Scilab code
   end ;


    // square score marix - ( [A_pro] x [A_pro]^T )
    InverseMat1 := mo.MultiplyMatrixByMatrix(tScoresProjection, tScoresProjection, false, true, 1.0, true) ;  // last param => leave transposed as matrix is symmetric anyway
    // inverse square matrix  - ( [A_pro] x [A_pro]^T )^-1
    mo.MatrixInverseSymmetric(InverseMat1) ;

    // Create [A_pro]^T x ( [A_pro] x [A_pro]^T )^-1
    tModel := mo.MultiplyMatrixByMatrix(tScoresProjection, InverseMat1, true, false, 1.0, false) ;  //

    // this creates the regression coefficients FOR EACH COLUMN of Y data (yData = C ; C = concentrations)
    // Y_times_Model = F = P = CA'[AA']^-1
    tY_times_Model := mo.MultiplyMatrixByMatrix({YMatrix,} yDataIn, tModel, true, false, 1.0, false) ;
    // C_unk = F x [normEVects]^T x Abs_unk ;  RegressionCoef = F x [normEVects]^T
    tRegressionCoef := mo.MultiplyMatrixByMatrix(tY_times_Model, tEVects,false, false, 1.0, false) ;

    //  RegressionCoef can now be used for predicting conc. of unknowns from spectra of the unknowns
    //  in this step, "PredictedY" gives the predicted values from the data that made the model
    tPredictedY := PredictYFromModel(xDataIn, tRegressionCoef) ;  // RegressionCoef is the model, xData could be any data to obtain predicted values from

    PredictedY.AddColToEndOfData(tPredictedY.F_mData,tPredictedY.numRows) ;
    RegressionCoef.AddRowToEndOfData(tRegressionCoef,1, tRegressionCoef.numCols) ;

    tRegressionCoef.Free ;  // free data first before recalculating
    tPredictedY.Free ;
    tY_times_Model.Free ;
    if t2 <> tNumPCsWanted then
    begin
      tScoresProjection.Free ;
      tModel.Free ;
    end ;
    InverseMat1.Free ;

  end ;  // for  t2 := 1 to (numPCsWanted+1) do



   R_sqrd_PCR  :=  TMatrix.Create2(xDataIn.SDPrec, 1, numPCsPCR) ;
   R_sqrd_PCR.F_Mdata.Seek(0,soFromBeginning) ;
   // this calculates the "predictive value" of the model created above i.e. the R^2 value
   tMat1 := TMatrix.Create(xDataIn.SDPrec) ;
//   PredictedY.SaveMatrixDataRawBin('predYDat.raw');
//   yDataIn.SaveMatrixDataRawBin('yDat.raw');
   for t2 := 1 to PredictedY.numCols do  // join together each predicted and original Y data into 1 matrix
   begin
       tMat1.AddColumnsToMatrix('1-'+intToStr(PredictedY.numRows), inttostr(t2),PredictedY) ;
       tMat1.AddColumnsToMatrix('1-'+intToStr(yDataIn.numRows), '1',yDataIn) ;

       tMat2 := vcv.GetVarCovarMatrix(tMat1) ;  // simple matrix multiply to end with symmetric matrix
       vcv.StandardiseVarCovar(tMat2) ;         // divide by the variance to normalise
       s1 := vcv.ReturnPearsonsCoeffFromStandardisedVarCovar(tMat2,1,2) ; // this is the R value for data
       s1 := s1 * s1 ;  // calculate R^2
       d1 := s1 ;

       if  R_sqrd_PCR.SDPrec = 4 then
         R_sqrd_PCR.F_Mdata.Write(s1,4)
       else if R_sqrd_PCR.SDPrec = 4 then
         R_sqrd_PCR.F_Mdata.Write(d1,8) ;

       tMat1.ClearData(tMat1.SDPrec) ;
       tMat2.ClearData(tMat2.SDPrec) ;
   end ;
   tMat2.Free ;
   tMat1.Free ;


  CalcYResidualData( true ) ;

//  RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(tEVects.numCols),true,XMatrix.F_MAverage) ;
//  CalcXResidualData( true ) ;

// this is done after PCA in TRegression object
// repeated because these EVects could be a sub-selection of all vectors present as chosen by "pcRange"
//  EVectPCRNormalsied.CopyMatrix(tNormEVects) ;  // save these for display purposes
//  ScoresPCRNormalised.CopyMatrix(scoresProjection) ;  // save these for display purposes
  tScoresProjection.Free ;

//  self.Model.CopyMatrix(tModel) ;
//  self.Model.Transpose ;
  tModel.Free ;
   
  tNormEVects.Free ;
//  if tEVects <> nil then tEVects.Free ;  // check this comment - I think tNormEVects = tEVects so all is good???
  tStream.Free   ;

end ;



function TPCRResults.PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
begin
  result :=  mo.MultiplyMatrixByMatrix(xData,regressCoef, false, true, 1.0, false) ;
end ;




// creates a matrix of normalised (unit length) vectors from inMatrix
function TPCRResults.ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
begin
  result := inMatrix.VectorNormaliseRowVectsReturnNew(inMatrix) ;
end ;


{
function  TPCRResults.CalcXResidualData( addMean : boolean ) : string ;  // does not work for imaginary data
//  =  original data - regenerated data
//     RegenerateData must be called before this function
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
  XResiduals.CopyMatrix(XMatrix) ;

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
end ;

 }

function  TPCRResults.CalcYResidualData(addMean : boolean) : string  ;
//  =  original Y data - Prdicted Y data
//     RegenerateData must be called before this function

var
  t1, t2 : integer ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
begin

  try

  if YResidualsPCR = nil then
    YResidualsPCR := TMatrix.Create2(PredictedY.SDPrec, PredictedY.numRows,PredictedY.numCols) ;

  
  result := '' ;
  YMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  PredictedY.F_Mdata.Seek(0,soFromBeginning) ;
  YResidualsPCR.F_Mdata.Seek(0,soFromBeginning) ;


  if YMatrix.SDPrec =  4 then
  begin
//    if (YMatrix.meanCentred and (not addMean)) or ((not YMatrix.meanCentred) and  addMean) then
//    begin
      for t1 := 1 to PredictedY.numRows do
      begin
//       YMatrix.F_Mdata.Seek(0,soFromBeginning) ;
       YMatrix.F_Mdata.Read(s2,4) ;
       for t2 := 1 to PredictedY.numCols do  // each col is a PC
       begin
         PredictedY.F_Mdata.Read(s1,4) ;
         s1 := s1 - s2 ;
         YResidualsPCR.F_Mdata.Write(s1,4) ;
       end ;
      end ;
  end ;  // if YMatrix.SDPrec =  4 then

//    end  // if  (XMatrix.meanCentred and (not addMean)) or ((not XMatrix.meanCentred) and  addMean)
{    else
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

  end ;                }

//  XMatrix.F_Mdata.Seek(0,soFromBeginning) ;
//  XRegenMatrix.F_Mdata.Seek(0,soFromBeginning) ;
//  XResiduals.F_Mdata.Seek(0,soFromBeginning) ;
//  XMatrix.F_MAverage.Seek(0,soFromBeginning);
  except on Exception do
  begin
     result := 'PCR CalcYResidualData() failed' ;
  end ;
  end
end ;

{
function TPCRResults.RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;
var
  regen : TMatrix ;
  tScores, tEVects : TMatrix ;
  tStream : TMemoryStream ;
  numPCsWanted : integer ;
begin
//  regen     := TMatrix.Create ;
  tScores   := TMatrix.Create(ScoresPCR.SDPrec) ;
  tEVects := TMatrix.Create(ScoresPCR.SDPrec) ;
  tStream   := TMemoryStream.Create ;

  if (ScoresPCR.complexMat=2) then
  begin
    tScores.F_Mdata.SetSize( tScores.F_Mdata.Size * 2) ;
    tScores.complexMat := 2 ;
    tEVects.F_Mdata.SetSize( tEVects.F_Mdata.Size * 2) ;
    tEVects.complexMat := 2 ;
  end ;


  numPCsWanted := ScoresPCR.GetTotalRowsColsFromString(pcRange,tstream) ;

  if (numPCsWanted < numPCs) then
  begin
    tScores.FetchDataFromTMatrix('1-'+inttostr(ScoresPCR.numRows),pcRange,ScoresPCR) ;
    tEVects.FetchDataFromTMatrix(pcRange,'1-'+inttostr(EVectsPCR.numCols),EVectsPCR) ;
    regen := mo.MultiplyMatrixByMatrix(tScores, tEVects, false, false, 1.0, false) ;
  end
  else // (numPCsWanted = numPCs)
    regen := mo.MultiplyMatrixByMatrix(ScoresPCR, EVectsPCR, false, false, 1.0, false) ;

  if  addMean and (aveDataIn.Size > 0) then
  begin
    aveDataIn.Seek(0,soFromBeginning) ;
    regen.AddVectToMatrixRows( aveDataIn ) ;
  end  ;

  tStream.Free ;
  tScores.Free ;
  tEVects.Free ;
  XRegenMatrix :=  regen ;
//  regen.Free ; // do not free data if it is actually being used somewhere
end ;

 }

procedure TPCRResults.CalculateEigenVals ;
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

  Eigenvalues.numRows := 1 ; eigenvalues.numCols :=  self.numPCsPCR  ;  // = Scores.numCols
  Eigenvalues.F_Mdata.SetSize(ScoresPCR.SDPrec* numPCsPCR * ScoresPCR.complexMat) ;
  Eigenvalues.F_Mdata.Seek(0,soFromBeginning) ;

  MKLscores := ScoresPCR.F_Mdata.Memory ;
  MKLtint   := ScoresPCR.numCols ;

  for t1 := 1 to numPCsPCR do
  begin
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 1) then
    begin
      s1[1] := sdot (ScoresPCR.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 1)then
    begin
      d1[1] := ddot (ScoresPCR.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 2)then
    begin
      s1 := cdotu (ScoresPCR.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 2)then
    begin
      d1 := zdotu (ScoresPCR.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    begin
      WriteLn('Function PCRResultsObject.CalculateEigenVals() error: Precision of data is not calculated correctly') ;
    end ;
    MKLscores := ScoresPCR.MovePointer(MKLScores,Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
  end ;

end ;


function TPCRResults.ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
// % variance spanned by eigenvalue = eigenvalue / (sum of all eigenvalues)
var
  t1 : integer ;
  sum_s, s1, e_s : single ;
  sum_d, d1, e_d : double ;
begin
  if Eigenvalues.SDPrec = 4 then
  begin
    sum_s := 0 ;
    for t1 := 1 to numPCsPCR do
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
    for t1 := 1 to numPCsPCR do
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
