unit TPCalResultsObjects;
//  This unit alows us to calculate a model using 'P calibration' method
//  by just inputing eigenvectors or scores
// (i.e. without a PCA of the dataa to obtain them)
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses  classes,  SysUtils,  TMatrixOperations, TMatrixObject , TVarAndCoVarOperations,
      TPCAResultsObject ;

type
  TPCalResults = class
  public
    dataSaved : boolean ;
    numPCsILS : integer  ; // the total number of PC's calculated
    PCOutputFilename : string ;

//    Model                  : TMatrix ; // this is latest model for set PCs wanted
    RegressionCoef         : TMatrix ;  // Coefficients for regression with a cirtain number of PCs
    PredictedY             : TMatrix ;
    YResidualsPCR          : TMatrix ;
    R_sqrd_PCR             : TMatrix ;

    ILSSDPrec : integer ; // 4 or 8 bytes for floating point data

    constructor Create(PCOutputFilenameIn : string; singleOrDouble : integer) ; // singleOrDouble = 1 (single) or = 2 (double)
    destructor  Destroy; override; // found in implementation part below
    procedure   Free;

    // return result is 'true' if want to continue without saving
    function  ClearResultsData(singleOrDouble : integer;  messageStr : string) : boolean ;
    function  SaveResultsData(PCOutputFilename : string) : boolean ;
    procedure MakeAllComplex ;

    // ILS needs Y data and The Scores matrix (or Xdata and loadings, so we can make the scores data)
    function  CreateILSModel(xDataIn, yDataIn, inScores : TMatrix;  pcRange : string) : string ;  // creates "RegressionCoef" TMatrix for a set of X data with known Y values

    function  PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // used by CreatePCRModelSecond
    function  CalcYResidualData(addMean : boolean; YdataIn : TMatrix) : string  ;

  private
    mo  : TMatrixOps ;
    vcv : TVarAndCoVarFunctions ;

    function  ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
//    function  ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;

end;


implementation

uses BLASLAPACKfreePas ;


constructor TPCalResults.Create(PCOutputFilenameIn : string; singleOrDouble : integer );
begin

  PCOutputFilename := PCOutputFilenameIn ;

  ILSSDPrec  :=  singleOrDouble  ;
  PredictedY :=  TMatrix.Create(ILSSDPrec);
  RegressionCoef := TMatrix.Create(ILSSDPrec) ;

  mo := TMatrixOps.Create ;
  vcv :=  TVarAndCoVarFunctions.Create ;

  dataSaved := false ;

end;


destructor TPCalResults.Destroy;
begin


  R_sqrd_PCR.Free ;
  if PredictedY <> nil then
    PredictedY.free ;
  if RegressionCoef <> nil then
    RegressionCoef.Free ;


  mo.Free ;
  vcv.Free ;

end;


procedure TPCalResults.Free;
begin
 if Self <> nil then Destroy;
end;


function TPCalResults.SaveResultsData(PCOutputFilename : string) : boolean ;
begin
    result := false ;
end ;


function TPCalResults.ClearResultsData(singleOrDouble : integer; messageStr : string) : boolean ;
Var
  msgRes : Word ;
begin

    result := true ;

    if PredictedY <> nil then
      PredictedY.ClearData(singleOrDouble) ;
    if RegressionCoef <> nil then
      RegressionCoef.Free ;

end ;



procedure TPCalResults.MakeAllComplex ;
begin



end;




// this creates the regression model -  Inverse Least Squares (P-Matrix Calibration). Calculates: P = CA'[AA']^-1  = Y_times_Model
// .PCA() has to be called first to make "EVects" TMatrix
function TPCalResults.CreateILSModel( xDataIn, yDataIn, inScores : TMatrix; pcRange : string)  : string ;
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

  tEVects       := TMatrix.Create(ILSSDPrec) ;
  if xDataIn <> nil then   // inScores is actually evects (i.e. not scores - so have to create the scores)
  begin

    tStream       := TMemoryStream.Create ;   // holds (0 based) array of which PCs are wanted

    tNumPCsWanted :=  inScores.GetTotalRowsColsFromString(pcRange,tStream) ;
    tNormEVects   :=  ReturnVectNormalisedEVects(inScores) ;
    tStream.Seek(0,soFromBeginning) ;

     // copy only EVectors wanted for use in the calibration
    tEVects.FetchDataFromTMatrix(tEVects.CreateStringFromRowColStream(tStream)  ,'1-'+inttostr(tNormEVects.numCols)  ,tNormEVects);
    tNormEVects.ClearData(tEVects.SDPrec) ;
    tNormEVects.CopyMatrix(tEVects);
    tEVects.ClearData(tEVects.SDPrec); // this is used again in next section to accept incremented numbers of vectors from tNormEVects (which contains all the vectors)
  end
  else
  begin
    tNumPCsWanted := inScores.numCols ;
  end;
    numPCsILS := tNumPCsWanted ;

  for  t2 := 1 to (tNumPCsWanted) do
  begin
    // calculate scores (of normalised EVects)
    if True then
    begin
      if (t2 < numPCsILS) then
      begin
      tEVects.FetchDataFromTMatrix('1-'+inttostr(t2),'1-'+inttostr(tNormEVects.numCols),tNormEVects) ;  // "normEVects" created by previous PCA
      tScoresProjection := mo.MultiplyMatrixByMatrix(xDataIn, tEVects, false, true, 1.0, true) ;
      end
      else
      begin
      tEVects.Free ;
      tEVects :=  tNormEVects ;
      tScoresProjection := mo.MultiplyMatrixByMatrix(xDataIn, tNormEVects, false, true, 1.0, true) ; // leave inverted => next function is reverse of Scilab code
      end
    end
    else
    begin
       tScoresProjection := tMatrix.Create(ILSSDPrec);
       tScoresProjection.FetchDataFromTMatrix('1-'+inttostr(inScores.numRows),'1-'+inttostr(t2),inScores) ;
    end;


    // square score marix - ( [A_pro] x [A_pro]^T )
    InverseMat1 := mo.MultiplyMatrixByMatrix(tScoresProjection, tScoresProjection, false, true, 1.0, true) ;  // last param => leave transposed as matrix is symmetric anyway
    // inverse square matrix  - ( [A_pro] x [A_pro]^T )^-1
    mo.MatrixInverseSymmetric(InverseMat1) ;

    // Create [A_pro]^T x ( [A_pro] x [A_pro]^T )^-1
    tModel := mo.MultiplyMatrixByMatrix(tScoresProjection, InverseMat1, true, false, 1.0, false) ;  //

    // this creates the regression coefficients FOR EACH COLUMN of Y data (yData = C ; C = concentrations)
    // Y_times_Model = F = P = CA'[AA']^-1
    tY_times_Model := mo.MultiplyMatrixByMatrix( yDataIn, tModel, true, false, 1.0, false) ;
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



   R_sqrd_PCR  :=  TMatrix.Create2(xDataIn.SDPrec, 1, numPCsILS) ;
   R_sqrd_PCR.F_Mdata.Seek(0,soFromBeginning) ;
   // this calculates the "predictive value" of the model created above i.e. the R^2 value
   tMat1 := TMatrix.Create(xDataIn.SDPrec) ;
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

  CalcYResidualData( true, yDataIn ) ;

  tScoresProjection.Free ;
  tModel.Free ;
  tNormEVects.Free ;
  tStream.Free   ;

end ;



function TPCalResults.PredictYFromModel(xData, regressCoef : TMatrix) : TMatrix ; // returns predicted Y data
begin
  result :=  mo.MultiplyMatrixByMatrix(xData,regressCoef, false, true, 1.0, false) ;
end ;




// creates a matrix of normalised (unit length) vectors from inMatrix
function TPCalResults.ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
var
  resMatrix : TMatrix ;
  t1, t2 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
begin
    resMatrix := TMatrix.Create(inMatrix.SDPrec) ;
    resMatrix.CopyMatrix(inMatrix) ;
    MKLa := resMatrix.F_Mdata.Memory ;
    MKLtint := 1 ;
    // normalise input vector  -
    for t1 := 1 to resMatrix.numRows do
    begin
      if  (resMatrix.SDPrec = 4) and (resMatrix.complexMat=1) then
      begin
        lengthSSEVects_s := snrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        sscal (resMatrix.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (resMatrix.SDPrec = 8) and (resMatrix.complexMat=1) then
      begin
        lengthSSEVects_d := dnrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        dscal (resMatrix.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end
      else
      if  (resMatrix.SDPrec = 4) and (resMatrix.complexMat=2) then
      begin
        lengthSSEVects_s := scnrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        csscal (resMatrix.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (resMatrix.SDPrec = 8) and (resMatrix.complexMat=2) then
      begin
        lengthSSEVects_d := dznrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        zdscal (resMatrix.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end  ;
      MKLa := resMatrix.MovePointer(MKLa,resMatrix.numCols * resMatrix.SDPrec * resMatrix.complexMat) ;
    end ;

    result := resMatrix ;
end ;



function  TPCalResults.CalcYResidualData(addMean : boolean; YdataIn : TMatrix) : string  ;
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
  YdataIn.F_Mdata.Seek(0,soFromBeginning) ;
  PredictedY.F_Mdata.Seek(0,soFromBeginning) ;
  YResidualsPCR.F_Mdata.Seek(0,soFromBeginning) ;


  if YdataIn.SDPrec =  4 then
  begin
      for t1 := 1 to PredictedY.numRows do
      begin
       YdataIn.F_Mdata.Read(s2,4) ;
       for t2 := 1 to PredictedY.numCols do  // each col is a PC
       begin
         PredictedY.F_Mdata.Read(s1,4) ;
         s1 := s1 - s2 ;
         YResidualsPCR.F_Mdata.Write(s1,4) ;
       end ;
      end ;
  end ;  // if YMatrix.SDPrec =  4 then

  except on Exception do
  begin
     result := 'PCR CalcYResidualData() failed' ;
  end ;
  end
end ;


{
procedure TPCalResults.CalculateEigenVals ;
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
  Eigenvalues.F_Mdata.SetSize(ScoresPCR.SDPrec* numPCs * ScoresPCR.complexMat) ;
  Eigenvalues.F_Mdata.Seek(0,soFromBeginning) ;

  MKLscores := ScoresPCR.F_Mdata.Memory ;
  MKLtint   := ScoresPCR.numCols ;

  for t1 := 1 to numPCs do
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

 }
 {
function TPCalResults.ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
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

      }



end.
