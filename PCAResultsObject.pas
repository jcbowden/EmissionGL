unit PCAResultsObject;

interface   //
uses  classes, Dialogs, SysUtils, TMatrixObject, TMatrixOperations, TVarAndCoVarOperations  ;
type
  TPCA = class
  public
    dataCreated, dataSaved : boolean ;

    XMatrix                             : TMatrix ;   // this is the input data
    Scores, EVects                      : TMatrix ;   // Stores output data
    ScoresNormalised, EVectNormalsied   : TMatrix ;   // these are created when CreateModelMatrix() is called. They use ReturnNormalisedEVects()
    EigenValues                         : TMatrix ;   // eigenvalue = diagonals of (scores(PCx)' * scores(PCx))
    RegenMatrix                         : TMatrix ;
    XResiduals                          : TMatrix ;

    numPCs : integer ;

    mo  : TMatrixOps ;
    vcv : TVarAndCoVarFunctions ;

    constructor Create( singleOrDouble : integer) ;
    destructor Destroy; // found in implementation part below
    procedure Free ; // found in implementation part below

    procedure ClearAll ;
    procedure ClearResults ;  // uses TPCResults.ClearResultsData() method
    function ConvertSingleDouble(singleOrDouble : integer) : boolean ;  // not properly implemented
    procedure MakeAllComplex ;

    // Main procedure for PCA - NIPALS Agorithm. Fills PCResults TPCResults Object
    procedure PCA(inputMatrix : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) ;
    procedure PCAcomplex(inputMatrix : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) ;
    // Helper for PCA() method. Finds column with maximum sum of sqaures for inital guess of Scores vector (PCResults.scoresVect)
    procedure GetMaxSumSquaresVector(inputMatrix : TMatrix; var scoresVect : TMemoryStream) ;
    procedure GetMaxSumSquaresVectorComplex(inputMatrixComplex : TMatrix; var scoresVect : TMemoryStream) ;

    function  ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
    function  ReturnVectorLoadings : TMatrix ;    // creates a matrix of EVetcs * sqrt(eVals)   (eVals = Scores * Scores')
    // creates spectra from the scores and eigenvectors obtained from PCA
    function  RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;  // Inherited // pcRange is a list of PCs to include when regenerating the data
    function  CalcResidualData(addMean : boolean) : string  ;    // this calculates "XResiduals" TMatrix
    procedure CalculateEigenVals ; // stores results in "EigenValues" TMatrix
    function  ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
    
  private
end;

implementation

uses AtlusBLASLAPACLibrary ;

constructor TPCA.Create(singleOrDouble : integer );
var
  resultsFilename, fileextension : string ;
  t1 : integer ;
begin
//  inherited Create;
  XMatrix            :=  TMatrix.Create(singleOrDouble);

  vcv                :=  TVarAndCoVarFunctions.Create ;

  Scores             :=  TMatrix.Create(singleOrDouble); ;
  EVects             :=  TMatrix.Create(singleOrDouble);
  ScoresNormalised   :=  TMatrix.Create(singleOrDouble);
  EVectNormalsied    :=  TMatrix.Create(singleOrDouble);

  XResiduals         :=  TMatrix.Create(singleOrDouble);

  EigenValues        :=  TMatrix.Create(singleOrDouble);
  RegenMatrix        :=  TMatrix.Create(singleOrDouble);
end;


// call 'free' rather than destroy as it checks to see if the object exists and then calls Destroy anyway.
destructor TPCA.Destroy;
begin
  XMatrix.free ;

  vcv.Free ;

  Scores.Free ;
  EVects.Free ;
  ScoresNormalised.Free ;
  EVectNormalsied.Free ;

  XResiduals.free ;

  EigenValues.Free ;
  RegenMatrix.Free ;       

//  inherited Destroy;
end;

procedure TPCA.Free ;
begin
  Destroy ;
end;


procedure TPCA.ClearAll;
var
  tSOrD : integer ;
begin
  tSOrD :=  XMatrix.SDPrec div 4 ;

  XMatrix.ClearData(tSOrD) ;
  XResiduals.ClearData(tSOrD) ;;

  Scores.ClearData(tSOrD) ;
  EVects.ClearData(tSOrD) ;
  ScoresNormalised.ClearData(tSOrD) ;
  EVectNormalsied.ClearData(tSOrD) ;
  EigenValues.ClearData(tSOrD) ;
  RegenMatrix.ClearData(tSOrD) ;
end;


procedure TPCA.ClearResults;
var
  tSOrD : integer ;
begin
  tSOrD :=  XMatrix.SDPrec div 4 ;

  Scores.ClearData(tSOrD) ;
  EVects.ClearData(tSOrD) ;
  ScoresNormalised.ClearData(tSOrD) ;
  EVectNormalsied.ClearData(tSOrD) ;
//  XResiduals.ClearData(tSOrD) ;
  EigenValues.ClearData(tSOrD) ;
  RegenMatrix.ClearData(tSOrD) ;
end;



// returns 'true' if data converted
function  TPCA.ConvertSingleDouble(singleOrDouble : integer) : boolean ;
begin
{  if  then
  begin
    if FileExists(allXData.Filename) then
    begin
      allXData.ClearData(singleOrDouble) ;
      allXData.SDPrec :=  singleOrDouble * 4 ;
      allXData.LoadMatrixDataFromTxtFile(allXData.Filename,allXData.startLine) ;
    end ;

    if not YdataInXMatrix and (FileExists(allYData.Filename)) then
    begin
      allYData.ClearData(singleOrDouble) ;
      allYData.SDPrec :=  singleOrDouble * 4 ;
      allYData.LoadMatrixDataFromTxtFile(allYData.Filename,allYData.startLine) ;
    end ;

    // these are filled when PC analysis is done, so just clear for now
    XResiduals.ClearData(singleOrDouble) ;
    XMatrix.ClearData(singleOrDouble) ;
    YMatrix.ClearData(singleOrDouble) ;
    result := true ;
  end
  else
    result := false ; // data not converted to other data type    }
end ;


procedure TPCA.MakeAllComplex ;
begin
  Scores.F_Mdata.SetSize(Scores.F_Mdata.Size * 2) ;
  Scores.complexMat  :=  2 ;
  EVects.F_Mdata.SetSize(EVects.F_Mdata.Size * 2) ;
  EVects.complexMat  :=  2 ;
  eigenvalues.F_Mdata.SetSize(eigenvalues.F_Mdata.Size * 2) ;
  eigenvalues.complexMat  :=  2 ;
  EVectNormalsied.F_Mdata.SetSize(EVectNormalsied.F_Mdata.Size * 2) ;
  EVectNormalsied.complexMat  :=  2 ;
  ScoresNormalised.F_Mdata.SetSize(ScoresNormalised.F_Mdata.Size * 2) ;
  ScoresNormalised.complexMat  :=  2 ;
  RegenMatrix.F_Mdata.SetSize(EVectNormalsied.F_Mdata.Size * 2) ;
  RegenMatrix.complexMat  :=  2 ;
//  PredictedY :=  TMatrix.Create(singleOrDouble);

end  ;


procedure TPCA.GetMaxSumSquaresVector(inputMatrix : TMatrix; var scoresVect : TMemoryStream) ;
var
  t1, t2 : integer ;
  tnumRows, tnumCols : integer ;
  index, MKLtint : integer ;
  p1, pMKL, pMKL2 : pointer ;
  s1 : single ;
  d1 : double ;
  ss_vector : TMemoryStream ;
begin
     GetMem(p1, inputMatrix.SDPrec) ;
     ss_vector := TMemoryStream.Create ;
     tnumRows :=  inputMatrix.numRows ;
     tnumCols :=  inputMatrix.numCols ;
     ss_vector.SetSize(tnumCols * inputMatrix.SDPrec) ;
     ss_vector.Seek(0,soFromBeginning) ;

     // calculate the sum of sqaures for each column
     // inputMatrix.Variance ;
     pMKL := inputMatrix.F_Mdata.Memory ;

       if inputMatrix.SDPrec = 4 then        // single precision
       begin
         for t1 := 0 to tnumCols-1 do
         begin
           s1 := sdot ( tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           ss_vector.Write(s1,inputMatrix.SDPrec) ;
           pMKL := inputMatrix.MovePointer(pMKL,inputMatrix.SDPrec) ;
         end ;
       end
       else
       begin
         for t1 := 0 to tnumCols-1 do
         begin                                // double precision
           d1 := ddot ( tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           ss_vector.Write(d1,inputMatrix.SDPrec) ;
           pMKL := inputMatrix.MovePointer(pMKL,inputMatrix.SDPrec) ;
         end ;
       end ;


     // find largest sum of sqaures
     MKLtint := 1 ;
     pMKL := ss_vector.Memory ;
     if inputMatrix.SDPrec = 4 then          // single precision
           index := isamax ( tnumCols, pMKL, MKLtint )
     else                                    // double precision
           index := idamax ( tnumCols, pMKL, MKLtint ) ;

     // copy largest sum of squares vector to input array
     scoresVect.Seek(0, soFromBeginning) ;
     pMKL := inputMatrix.F_Mdata.Memory ;
     pMKL := inputMatrix.MovePointer(pMKL,(index-1)*inputMatrix.SDPrec) ;
     pMKL2 := scoresVect.Memory ;
     if inputMatrix.SDPrec = 4 then          // single precision
           scopy ( tnumRows, pMKL, tnumCols, pMKL2,  MKLtint )
     else                                    // double precision
           dcopy ( tnumRows, pMKL, tnumCols, pMKL2, MKLtint ) ;


     FreeMem(p1) ;
     ss_vector.Free ;
end ;



// PCA only uses the X matrix, however just in case we want to do PCA on another matrix, specify it
// N.B. Call GetDataMatrix(...) first to obtain the X matrix then copy to residual matrix and pass residual matrix to this procedure
procedure TPCA.PCA(inputMatrix : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) ;
var
   t1 : integer ;
   PCs_sofar, numIter : integer ;
   diff_x_SS : double ;
   MKLa, MKLEVects, MKLscores : pointer ;
   MKLtint, MKLlda : integer ;
   MKLtrans : char ;
   SSScores_s, SSEVects_s, lengthSSEVects_s, newSSScores_s, MKLalphas, MKLbetas : single ;
   SSScores_d, SSEVects_d, lengthSSEVects_d, newSSScores_d, MKLalphad, MKLbetad : double ;
   tscoresVect, tEVectsVect : TMatrix ;
   tXMatrix, tMat1 : TMatrix  ;


//   s1 : single ;
begin
     MKLtint := 1 ;
     MKLbetas := 0.0 ;
     MKLbetad := 0.0 ;
     PCs_sofar := 1 ;
     tscoresVect   := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numRows) ;
     tEVectsVect := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numCols)  ;

     // this is a copy of the oriinal data, to be used for display - added recently
     XMatrix  := TMatrix.Create(inputMatrix.SDPrec div 4) ;
     XMatrix.CopyMatrix(inputMatrix) ;

     if PCs_wanted_in <= inputMatrix.numRows then
       self.numPCs := PCs_wanted_in
     else
     begin
       PCs_wanted_in :=  inputMatrix.numRows ; // can only have as many PCs as there are samples in the data matrix (-1 if mean centred)
       self.numPCs  := PCs_wanted_in ;
     end ;

     // Pre-process
     if meanCentre then  // mean centre or 'column centre'
     begin
        inputMatrix.MeanCentre ;
        if PCs_wanted_in = inputMatrix.numRows then
        begin
          self.numPCs := PCs_wanted_in -1 ;
          PCs_wanted_in := PCs_wanted_in -1 ;
        end ;
     end ;
     if colStandardise then
        inputMatrix.ColStandardize ;

     // copy preprocessed data for calculation of scores (projecting the 'latent variables') at end of procedure
     tXMatrix := TMatrix.Create(self.XMatrix.SDPrec) ;
     tXMatrix.CopyMatrix(inputMatrix) ;


     MKLa :=  inputMatrix.F_Mdata.Memory ;
     MKLscores :=  tscoresVect.F_Mdata.Memory ;
     MKLEVects :=  tEVectsVect.F_Mdata.Memory ;
 //    MKLlda :=  inputMatrix.numRows ;  // not sure what this should be yet, rows or cols

     while  PCs_sofar <= self.numPCs do
     begin
       GetMaxSumSquaresVector(inputMatrix, tscoresVect.F_Mdata) ; // finds column with maximum sum of squares for inital guess of Scores vector
       if inputMatrix.SDPrec = 4 then                      // single precision
         SSScores_s := sdot (inputMatrix.numRows, MKLscores, MKLtint, MKLscores, MKLtint )
       else                                                // double precision
         SSScores_d :=  ddot (inputMatrix.numRows, MKLscores, MKLtint, MKLscores, MKLtint ) ;
        diff_x_SS := 1.0 ;
        numIter := 1 ;

        while  (abs(diff_x_SS) > 0.000001)  and (numIter < 1000)  do   // start of iteratve loop
        begin
           if inputMatrix.SDPrec = 4 then    // single precision
           begin
              MKLtrans := 'n' ;
              MKLbetas := 0.0 ;
              SSScores_s := 1/SSScores_s ;

              // this creates the EVects matrix (MKLEVects)
              MKLlda :=  inputMatrix.numCols ;  // = first dimension of matrix  (always numCols for TMatrix data)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
              // call sgemv ( trans, m,                 n,                 alpha,      a,     lda,      x, incx, beta, y, incy )
              sgemv (MKLtrans, inputMatrix.numCols , inputMatrix.numRows, SSScores_s, MKLa, MKLlda, MKLscores, MKLtint, MKLbetas, MKLEVects, MKLtint ) ;

              SSEVects_s := sdot (tEVectsVect.numCols,  MKLEVects, MKLtint,  MKLEVects, MKLtint) ;
              // do not normalise EVects vector here

              MKLtrans := 't' ;  // do not transpose matrix 'a'
              SSEVects_s := 1/SSEVects_s ;
              // this creates the scores matrix (MKLscores)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'   alpha = 1/SSEVects_s
              sgemv (MKLtrans, inputMatrix.numCols  , inputMatrix.numRows, SSEVects_s, MKLa, MKLlda, MKLEVects, MKLtint, MKLbetas, MKLscores, MKLtint ) ;
              newSSScores_s := sdot (tscoresVect.numCols, MKLscores, MKLtint, MKLscores, MKLtint )  ;

              SSScores_s := 1 / SSScores_s ;
              diff_x_SS :=   SSScores_s -  newSSScores_s ;
              SSScores_s := newSSScores_s ;

              inc(numIter) ;  
//              diff_x_SS   := 0.0000001 ;
           end
           else // inputMatrix.SDPrec = 8
           begin    // double precision code
              MKLtrans := 'n' ;
              MKLbetad := 0.0 ;
              SSScores_d := 1/SSScores_d ;

              // this creates the EVects matrix (MKLEVects)
              MKLlda :=  inputMatrix.numCols ;  // = first dimension of matrix  (always numCols for TMatrix data)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
              // call sgemv ( trans, m, n, alpha, a, lda, x, incx, beta, y, incy )
              dgemv (MKLtrans, inputMatrix.numCols , inputMatrix.numRows, SSScores_d, MKLa, MKLlda, MKLscores, MKLtint, MKLbetad, MKLEVects, MKLtint ) ;

              SSEVects_d := ddot (tEVectsVect.numCols,  MKLEVects, MKLtint,  MKLEVects, MKLtint) ;
              // do not normalise EVects vector here

              MKLtrans := 't' ;  // do not transpose matrix 'a'
              SSEVects_d := 1/SSEVects_d ;
              // this creates the scores matrix (MKLscores)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'   alpha = 1/SSEVects_s
              dgemv (MKLtrans, inputMatrix.numCols  , inputMatrix.numRows, SSEVects_d, MKLa, MKLlda, MKLEVects, MKLtint, MKLbetad, MKLscores, MKLtint ) ;
              newSSScores_d := ddot (tscoresVect.numCols, MKLscores, MKLtint, MKLscores, MKLtint )  ;

              SSScores_d := 1 / SSScores_d ;
              diff_x_SS :=   SSScores_d -  newSSScores_d ;
              SSScores_d := newSSScores_d ;

              inc(numIter) ;
           end ;
        end ;  // end of iterative loop
        // messagedlg('PC #'+inttostr(PCs_sofar) +' Number of iterations: ' + inttostr(numIter)  ,mtinformation,[mbOK],0) ;

        // subtract factor from original matrix to leave residuals
        // sger: a := alpha * x * y’ + a
         MKLlda :=  inputMatrix.numCols ;  // first dimension of matrix
        if inputMatrix.SDPrec = 4 then                      // single precision
        begin
          MKLbetas := -1.0 ;
          sger (inputMatrix.numCols , inputMatrix.numRows, MKLbetas, MKLEVects, MKLtint, MKLscores , MKLtint, MKLa, MKLlda) ;
        end
        else  // inputMatrix.SDPrec = 8 (double precision)
        begin
           MKLbetad := -1.0 ;
           dger (inputMatrix.numCols , inputMatrix.numRows, MKLbetad, MKLEVects, MKLtint, MKLscores , MKLtint, MKLa, MKLlda) ;
        end ;

        Scores.AddColToEndOfData(tscoresVect.F_Mdata,inputMatrix.numRows) ;     //
        EVects.AddRowToEndOfData(tEVectsVect, 1 ,inputMatrix.numCols) ;     //

        inc(PCs_sofar) ;
     end ;

     CalculateEigenVals ;
     dataCreated := true ;
     EVectNormalsied.CopyMatrix(ReturnVectNormalisedEVects(EVects)) ;

     // project *normalised* latent variables onto original (pre-processed) data to give final scores of normalised EVects
     tMat1 := mo.MultiplyMatrixByMatrix(tXMatrix, EVectNormalsied, false, true, 1.0, false) ;
     ScoresNormalised.CopyMatrix(tMat1)  ;
     tMat1.Free ;

     // regenerate with all PCs created (creates spectra from the scores and eigenvectors obtained from PCA)
     RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(EVects.numCols),meanCentre,XResiduals.F_MAverage) ;

     tXMatrix.Free ;
     tscoresVect.Free   ;
     tEVectsVect.Free ;
end ;



procedure TPCA.GetMaxSumSquaresVectorComplex(inputMatrixComplex : TMatrix; var scoresVect : TMemoryStream) ;
// scoresVect is the returned values
var
  t1, t2 : integer ;
  tnumRows, tnumCols : integer ;
  index, MKLtint : integer ;
  p1, pMKL, pMKL2 : pointer ;
  s1 : TSingle ;
  d1 : TDouble ;
  ss_vector : TMemoryStream ;
begin
     ss_vector := TMemoryStream.Create ;
     tnumRows :=  inputMatrixComplex.numRows ;
     tnumCols :=  inputMatrixComplex.numCols ;
     ss_vector.SetSize(tnumCols * inputMatrixComplex.SDPrec * 2) ;
     ss_vector.Seek(0,soFromBeginning) ;

     // calculate the sum of sqaures for each column
     // inputMatrix.Variance ;
     pMKL := inputMatrixComplex.F_Mdata.Memory ;

     if inputMatrixComplex.SDPrec = 4 then        // single precision complex
     begin
        for t1 := 0 to tnumCols-1 do
        begin
           s1 := cdotu (tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           ss_vector.Write(s1,8) ;
           pMKL := inputMatrixComplex.MovePointer(pMKL,8) ;
        end ;
     end
     else
     begin                                 // double precision complex
       for t1 := 0 to tnumCols-1 do
       begin
           d1 := zdotu ( tnumRows, pMKL, tnumCols, pMKL, tnumCols ) ;
           ss_vector.Write(d1,16) ;
           pMKL := inputMatrixComplex.MovePointer(pMKL,16) ;
       end ;
     end ;

     ss_vector.Seek(0,soFromBeginning) ;
     // find largest sum of sqaures
     MKLtint := 1 ;
     pMKL := ss_vector.Memory ;
     if inputMatrixComplex.SDPrec = 4 then          // single precision complex
           index := icamax ( tnumCols, pMKL, MKLtint )
     else                                           // double precision complex
           index := izamax ( tnumCols, pMKL, MKLtint ) ;

     // copy largest sum of squares vector to input array
     scoresVect.Seek(0, soFromBeginning) ;
     pMKL := inputMatrixComplex.F_Mdata.Memory ;
     pMKL := inputMatrixComplex.MovePointer(pMKL,(index-1)*inputMatrixComplex.SDPrec*inputMatrixComplex.complexMat) ;
     pMKL2 := scoresVect.Memory ;
     if inputMatrixComplex.SDPrec = 4 then          // single precision complex
           ccopy ( tnumRows, pMKL, tnumCols, pMKL2,  MKLtint )
     else                                           // double precision complex
           zcopy ( tnumRows, pMKL, tnumCols, pMKL2, MKLtint ) ;


     ss_vector.Free ;
end ;



// PCA only uses the X matrix, however just in case we want to do PCA on another matrix, specify it
// N.B. Call GetDataMatrix(...) first to obtain the X matrix then copy to residual matrix and pass residual matrix to this procedure
procedure TPCA.PCAcomplex(inputMatrix : TMatrix; PCs_wanted_in : integer; meanCentre, colStandardise : boolean) ;
var
   t1 : integer ;
   PCs_sofar, numIter : integer ;
   diff_x_SS : double ;
   MKLa, MKLEVects, MKLscores : pointer ;
   MKLtint, MKLlda : integer ;
   MKLtrans : char ;
   SSScores_s, SSEVects_s, lengthSSEVects_s, newSSScores_s, MKLalpha_s, MKLbeta_s, temp_s : TSingle ;
   SSScores_d, SSEVects_d, lengthSSEVects_d, newSSScores_d, MKLalpha_d, MKLbeta_d, temp_d : TDouble ;
   tscoresVect, tEVectsVect : TMatrix ;
   tXMatrix, tMat1 : TMatrix  ;
begin
     MKLtint := 1 ;
     MKLbeta_s[1] := 0.0 ;  MKLbeta_s[2] := 0.0 ;
     MKLbeta_d[1] := 0.0 ;  MKLbeta_d[2] := 0.0 ;
     PCs_sofar := 1 ;

     // this makes sure all TMatrix objects are complex
     tXMatrix := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numRows) ;
     tscoresVect   := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numRows) ;
     tscoresVect.MakeComplex(tXMatrix) ;
     tXMatrix.Free ;
     tXMatrix := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numCols)  ;
     tEVectsVect := TMatrix.Create2(inputMatrix.SDPrec div 4, 1, inputMatrix.numCols)  ;
     tEVectsVect.MakeComplex(tXMatrix) ;
     tXMatrix.Free ;

     self.MakeAllComplex ;

     if PCs_wanted_in <= inputMatrix.numRows then
       self.numPCs := PCs_wanted_in
     else
     begin
       PCs_wanted_in :=  inputMatrix.numRows ; // can only have as many PCs as there are samples in the data matrix (-1 if mean centred)
       self.numPCs := PCs_wanted_in ;
     end ;

     // Pre-process
     if meanCentre then  // mean centre or 'column centre'
     begin
        inputMatrix.MeanCentre ;
        if PCs_wanted_in = inputMatrix.numRows then
        begin
          self.numPCs := PCs_wanted_in -1 ;
          PCs_wanted_in := PCs_wanted_in -1 ;
        end ;
     end ;
     if colStandardise then
        inputMatrix.ColStandardize ;

     // copy preprocessed data for calculation of scores (projecting the 'latent variables') at end of procedure
     tXMatrix := TMatrix.Create(inputMatrix.SDPrec div 4) ;
     tXMatrix.CopyMatrix(inputMatrix) ;

     MKLa :=  inputMatrix.F_Mdata.Memory ;
     MKLscores :=  tscoresVect.F_Mdata.Memory ;
     MKLEVects :=  tEVectsVect.F_Mdata.Memory ;
 //    MKLlda :=  inputMatrix.numRows ;  // not sure what this should be yet, rows or cols

     while  PCs_sofar <= self.numPCs do
     begin
       GetMaxSumSquaresVectorComplex(inputMatrix, tscoresVect.F_Mdata) ; // finds column with maximum sum of sqaures for inital guess of Scores vector
       if inputMatrix.SDPrec = 4 then                      // single precision
         SSScores_s := cdotu (inputMatrix.numRows, MKLscores, MKLtint, MKLscores, MKLtint )
       else                                                // double precision
         SSScores_d :=  zdotu (inputMatrix.numRows, MKLscores, MKLtint, MKLscores, MKLtint ) ;
        diff_x_SS := 1.0 ;
        numIter := 1 ;

        while  (abs(diff_x_SS) > 0.000001)  and (numIter < 1000)  do   // start of iteratve loop
        begin
           if inputMatrix.SDPrec = 4 then    // single precision
           begin
              MKLtrans := 'n' ;
              MKLbeta_s[1] := 0.0 ; MKLbeta_s[2] := 0.0 ;
             // SSScores_s := 1/SSScores_s ;
              temp_s[1] := ((SSScores_s[1]*SSScores_s[1])+(SSScores_s[2]*SSScores_s[2])) ;
              if temp_s[1] <> 0 then
              begin
                SSScores_s[1] := SSScores_s[1] / temp_s[1]  ;
                SSScores_s[2] := -SSScores_s[2] / temp_s[1]  ;
              end ;
              // this creates the EVects matrix (MKLEVects)
              MKLlda :=  inputMatrix.numCols ;  // = first dimension of matrix  (always numCols for TMatrix data)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
              // call sgemv ( trans, m, n, alpha, a, lda, x, incx, beta, y, incy )
              cgemv (MKLtrans, inputMatrix.numCols , inputMatrix.numRows, SSScores_s, MKLa, MKLlda, MKLscores, MKLtint, MKLbeta_s, MKLEVects, MKLtint ) ;

              SSEVects_s := cdotu (tEVectsVect.numCols,  MKLEVects, MKLtint,  MKLEVects, MKLtint) ;
              // do not normalise EVects vector here

              MKLtrans := 't' ;  // do not transpose matrix 'a'
              //SSEVects_s := 1/SSEVects_s ;
              temp_s[1] := ((SSEVects_s[1]*SSEVects_s[1])+(SSEVects_s[2]*SSEVects_s[2])) ;
              if temp_s[1] <> 0 then
              begin
                SSEVects_s[1] := SSEVects_s[1] / temp_s[1]  ;
                SSEVects_s[2] := -SSEVects_s[2] / temp_s[1]  ;
              end ;
              // this creates the scores matrix (MKLscores)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'   alpha = 1/SSEVects_s
              cgemv (MKLtrans, inputMatrix.numCols  , inputMatrix.numRows, SSEVects_s, MKLa, MKLlda, MKLEVects, MKLtint, MKLbeta_s, MKLscores, MKLtint ) ;
              newSSScores_s := cdotu (tscoresVect.numCols, MKLscores, MKLtint, MKLscores, MKLtint )  ;

              //SSScores_s := 1 / SSScores_s ;
              temp_s[1] := ((SSScores_s[1]*SSScores_s[1])+(SSScores_s[2]*SSScores_s[2])) ;
              if temp_s[1] <> 0 then
              begin
                SSScores_s[1] := SSScores_s[1] / temp_s[1]  ;
                SSScores_s[2] := -SSScores_s[2] / temp_s[1]  ;
              end ;
              //diff_x_SS :=   SSScores_s -  newSSScores_s ;
              diff_x_SS := sqrt(((SSScores_s[1]*SSScores_s[1])+(SSScores_s[2]*SSScores_s[2]))) - sqrt(((newSSScores_s[1]*newSSScores_s[1])+(newSSScores_s[2]*newSSScores_s[2]))) ;
              SSScores_s[1] := newSSScores_s[1] ;
              SSScores_s[2] := newSSScores_s[2] ;

              inc(numIter) ;
           end
           else // inputMatrix.SDPrec = 8
           begin    // double precision code
              MKLtrans := 'n' ;
              MKLbeta_d[1] := 0.0 ; MKLbeta_d[2] := 0.0 ;
              //SSScores_d := 1/SSScores_d ;
              temp_d[1] := ((SSScores_d[1]*SSScores_d[1])+(SSScores_d[2]*SSScores_d[2])) ;
              SSScores_d[1] := SSScores_d[1] / temp_d[1]  ;
              SSScores_d[2] := -SSScores_d[2] / temp_d[1]  ;

              // this creates the EVects matrix (MKLEVects)
              MKLlda :=  inputMatrix.numCols ;  // = first dimension of matrix  (always numCols for TMatrix data)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
              // call sgemv ( trans, m, n, alpha, a, lda, x, incx, beta, y, incy )
              zgemv (MKLtrans, inputMatrix.numCols , inputMatrix.numRows, SSScores_d, MKLa, MKLlda, MKLscores, MKLtint, MKLbeta_d, MKLEVects, MKLtint ) ;

              SSEVects_d := zdotu (tEVectsVect.numCols,  MKLEVects, MKLtint,  MKLEVects, MKLtint) ;
              // do not normalise EVects vector here

              MKLtrans := 't' ;  // do not transpose matrix 'a'
              //SSEVects_d := 1/SSEVects_d ;
              temp_d[1] := ((SSEVects_d[1]*SSEVects_d[1])+(SSEVects_d[2]*SSEVects_d[2])) ;
              SSEVects_d[1] := SSEVects_d[1] / temp_d[1]  ;
              SSEVects_d[2] := -SSEVects_d[2] / temp_d[1]  ;
              // this creates the scores matrix (MKLscores)
              // y = alpha*a*x + beta*y:  if trans = 't' then a = a'   alpha = 1/SSEVects_s
              zgemv (MKLtrans, inputMatrix.numCols  , inputMatrix.numRows, SSEVects_d, MKLa, MKLlda, MKLEVects, MKLtint, MKLbeta_d, MKLscores, MKLtint ) ;
              newSSScores_d := zdotu (tscoresVect.numCols, MKLscores, MKLtint, MKLscores, MKLtint )  ;

              //SSScores_d := 1 / SSScores_d ;
              temp_d[1] := ((SSScores_d[1]*SSScores_d[1])+(SSScores_d[2]*SSScores_d[2])) ;
              SSScores_d[1] := SSScores_d[1] / temp_d[1]  ;
              SSScores_d[2] := -SSScores_d[2] / temp_d[1]  ;

              //diff_x_SS :=   SSScores_d -  newSSScores_d ;
              diff_x_SS := sqrt(((SSScores_d[1]*SSScores_d[1])+(SSScores_d[2]*SSScores_d[2]))) - sqrt(((newSSScores_d[1]*newSSScores_d[1])+(newSSScores_d[2]*newSSScores_d[2]))) ;
              SSScores_s[1] := newSSScores_d[1] ;
              SSScores_s[2] := newSSScores_d[2] ;

              inc(numIter) ;
           end ;
        end ;  // end of iterative loop
//        messagedlg('PC #'+inttostr(PCs_sofar) +' Number of iterations: ' + inttostr(numIter)  ,mtinformation,[mbOK],0) ;

        // subtract factor from original matrix to leave residuals
        // sger: a := alpha* x* y’ + a
         MKLlda :=  inputMatrix.numCols ;  // first dimension of matrix
        if inputMatrix.SDPrec = 4 then                      // single precision
        begin
          MKLbeta_s[1] := -1.0 ;
          cgeru (inputMatrix.numCols , inputMatrix.numRows, MKLbeta_s, MKLEVects, MKLtint, MKLscores , MKLtint, MKLa, MKLlda) ;
        end
        else  // inputMatrix.SDPrec = 8 (double precision)
        begin
           MKLbeta_d[1] := -1.0 ;
           zgeru (inputMatrix.numCols , inputMatrix.numRows, MKLbeta_d, MKLEVects, MKLtint, MKLscores , MKLtint, MKLa, MKLlda) ;
        end ;

        Scores.AddColToEndOfData(tscoresVect.F_Mdata,inputMatrix.numRows) ;     //
        EVects.AddRowToEndOfData(tEVectsVect, 1 ,inputMatrix.numCols) ;     //  

        inc(PCs_sofar) ;
     end ;

     CalculateEigenVals ;
     self.dataCreated := true ;
     self.EVectNormalsied.CopyMatrix(ReturnVectNormalisedEVects(EVects)) ;   // we now have un-normalised and normalised EVects

     // project *normalised* latent variables onto original (pre-processed) data to give normalised scores
     tMat1 :=  mo.MultiplyMatrixByMatrix(tXMatrix, EVectNormalsied, false, true, 1.0, false) ;
     self.ScoresNormalised.CopyMatrix(tMat1)  ;
     tMat1.Free ;
     
     RegenerateData( '1-'+inttostr(numPCs),'1-'+inttostr(EVects.numCols),meanCentre,XResiduals.F_MAverage) ;


     tXMatrix.Free ;
     tscoresVect.Free   ;
     tEVectsVect.Free ;
end ;



// creates a matrix of EVetcs * sqrt(eVals)   (eVals = Scores * Scores')
// does not work on complex data
function TPCA.ReturnVectorLoadings : TMatrix ;
var
  sqrtEval : TMatrix ;
  eValStrm : TMemoryStream ;
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
    eValStrm := TMemoryStream.Create  ;

    if Eigenvalues.F_Mdata.Size = 0 then   // reset the resuts TMatrix if already used
       CalculateEigenVals ;

 //   EigenValues.SaveMatrixDataTxt('eigenvals_array.txt', ', ') ;

    // take the sqrt of eigenvalues
//    eValStrm.CopyFrom(Eigenvalues.F_Mdata,0) ;
    eValStrm.SetSize(EigenValues.NumCols * EigenValues.SDPrec) ;
    eValStrm.Seek(0,soFromBeginning) ;
    EigenValues.F_Mdata.Seek(0,soFromBeginning) ;
    if EigenValues.SDPrec = 4 then
    begin
      for t1 := 1 to  EigenValues.NumCols do
      begin
        EigenValues.F_Mdata.Read(s1,4) ;
        s1 := sqrt(s1) ;
        eValStrm.Write(s1,4) ;
      end ;
    end
    else
    if EigenValues.SDPrec = 8 then
    begin
      for t1 := 1 to  EigenValues.NumCols do
      begin
        EigenValues.F_Mdata.Read(d1,8) ;
        d1 := sqrt(d1) ;
        eValStrm.Write(d1,8) ;
      end ;
    end  ;
    eValStrm.Seek(0,soFromBeginning) ;
    EigenValues.F_Mdata.Seek(0,soFromBeginning) ;

    // create the sqrt of the eigenvalues matrix
    sqrtEval := TMatrix.Create2(EigenValues.SDPrec div 4, EigenValues.NumCols,  EigenValues.NumCols) ;
    sqrtEval.Zero(sqrtEval.F_Mdata) ;
    sqrtEval.SetDiagonal(eValStrm) ;  // place sqrt values in diagonal of matrix

    // mutlply the evects by the squrt(evals) and return the result.
    result  := mo.MultiplyMatrixByMatrix(EVectNormalsied,sqrtEval,true,false,1.0,true) ;
    eValStrm.Free ;
end ;



// creates a matrix of normalised (unit length) vectors from inMatrix
function TPCA.ReturnVectNormalisedEVects(inMatrix: TMatrix) : TMatrix ;
var
  resMatrix : TMatrix ;
  t1, t2 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
begin
    resMatrix := TMatrix.Create(inMatrix.SDPrec div 4) ;
    resMatrix.CopyMatrix(inMatrix) ;
    MKLa := resMatrix.F_Mdata.Memory ;
    MKLtint := 1 ;
    // normalise input vector  -
    for t1 := 1 to resMatrix.numRows do
    begin
      if  (resMatrix.SDPrec = 4) and (resMatrix.complexMat=1) then
      begin
        lengthSSEVects_s := snrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        if lengthSSEVects_s <> 0 then
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        sscal (resMatrix.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (resMatrix.SDPrec = 8) and (resMatrix.complexMat=1) then
      begin
        lengthSSEVects_d := dnrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        if lengthSSEVects_s <> 0 then
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        dscal (resMatrix.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end
      else
      if  (resMatrix.SDPrec = 4) and (resMatrix.complexMat=2) then
      begin
        lengthSSEVects_s := scnrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        if lengthSSEVects_s <> 0 then
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        csscal (resMatrix.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (resMatrix.SDPrec = 8) and (resMatrix.complexMat=2) then
      begin
        lengthSSEVects_d := dznrm2 ( resMatrix.numCols , MKLa, MKLtint ) ;
        if lengthSSEVects_s <> 0 then
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        zdscal (resMatrix.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end  ;
      MKLa := resMatrix.MovePointer(MKLa,resMatrix.numCols * resMatrix.SDPrec * resMatrix.complexMat) ;
    end ;

    result := resMatrix ;
end ;



function  TPCA.CalcResidualData( addMean : boolean ) : string ;  // does not work for imaginary data
//     XResiduals =  original data - regenerated data
//     RegenerateData must be called before this function
var
  t1, t2 : integer ;
  s1, s2, s3 : single ;
  d1, d2, d3 : double ;
begin

  try
  result := '' ;
  XMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  RegenMatrix.F_Mdata.Seek(0,soFromBeginning) ;
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
         RegenMatrix.F_Mdata.Read(s2,4) ;
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
         RegenMatrix.F_Mdata.Read(s2,4) ;
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
         RegenMatrix.F_Mdata.Read(s2,4) ;
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
         RegenMatrix.F_Mdata.Read(d2,4) ;
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
         RegenMatrix.F_Mdata.Read(d2,4) ;
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
         RegenMatrix.F_Mdata.Read(d2,4) ;
          XMatrix.F_MAverage.Read(d3,4) ;
         d1 := d1 - d2 - d3 ;
         XResiduals.F_Mdata.Write(d1,4) ;
       end ;
      end ;
    end ;

  end ;

  XMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  RegenMatrix.F_Mdata.Seek(0,soFromBeginning) ;
  XResiduals.F_Mdata.Seek(0,soFromBeginning) ;
  XMatrix.F_MAverage.Seek(0,soFromBeginning);
  except on Exception do
  begin
     result := 'PCA CalcResidualData() failed' ;
  end ;
  end
end ;

// creates spectra from the scores and eigenvectors obtained from PCA
function TPCA.RegenerateData(pcRange, variableRange : string; addMean : boolean; aveDataIn: TMemoryStream) : TMatrix ;
var
  regen : TMatrix ;
  tScores, tEVects : TMatrix ;
  tStream : TMemoryStream ;
  numPCsWanted : integer ;
begin
//  regen     := TMatrix.Create ;
  tScores   := TMatrix.Create(Scores.SDPrec div 4) ;
  tEVects := TMatrix.Create(Scores.SDPrec div 4) ;
  tStream   := TMemoryStream.Create ;

  if (Scores.complexMat=2) then
  begin
    tScores.F_Mdata.SetSize( tScores.F_Mdata.Size * 2) ;
    tScores.complexMat := 2 ;
    tEVects.F_Mdata.SetSize( tEVects.F_Mdata.Size * 2) ;
    tEVects.complexMat := 2 ;
  end ;


  numPCsWanted := Scores.GetTotalRowsColsFromString(pcRange,tstream) ;

  if (numPCsWanted < numPCs) then
  begin
    tScores.FetchDataFromTMatrix('1-'+inttostr(Scores.numRows),pcRange,ScoresNormalised) ;
    tEVects.FetchDataFromTMatrix(pcRange,'1-'+inttostr(EVects.numCols),EVectNormalsied) ;
    regen := mo.MultiplyMatrixByMatrix(tScores, tEVects, false, false, 1.0, false) ;
  end
  else // (numPCsWanted = numPCs)
    regen := mo.MultiplyMatrixByMatrix(ScoresNormalised, EVectNormalsied, false, false, 1.0, false) ;


  if  addMean and (aveDataIn.Size > 0) then
  begin
    aveDataIn.Seek(0,soFromBeginning) ;
    regen.AddVectToMatrixRows( aveDataIn ) ;
  end  ;

  tStream.Free ;
  tScores.Free ;
  tEVects.Free ;
  RegenMatrix :=  regen ;
//  regen.Free ; // do not free data if it is actually being used somewhere
end ;



procedure TPCA.CalculateEigenVals ;
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
  if Eigenvalues.F_Mdata.Size > 0 then   // reset the resuts TMatrix if already used
     Eigenvalues.ClearData(Eigenvalues.SDPrec div 4) ;

  Eigenvalues.numRows := 1 ; eigenvalues.numCols :=  self.numPCs  ;  // = Scores.numCols
  Eigenvalues.F_Mdata.SetSize(Scores.SDPrec* numPCs * Scores.complexMat) ;
  Eigenvalues.F_Mdata.Seek(0,soFromBeginning) ;

  MKLscores := Scores.F_Mdata.Memory ;
  MKLtint   := Scores.numCols ;

  for t1 := 1 to numPCs do
  begin
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 1) then
    begin
      s1[1] := sdot (Scores.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 1)then
    begin
      d1[1] := ddot (Scores.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec) ;
    end
    else
    if (Eigenvalues.SDPrec = 4) and (Eigenvalues.complexMat = 2)then
    begin
      s1 := cdotu (Scores.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(s1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    if (Eigenvalues.SDPrec = 8) and (Eigenvalues.complexMat = 2)then
    begin
      d1 := zdotu (Scores.numRows, MKLscores , MKLtint, MKLscores ,  MKLtint) ;
      Eigenvalues.F_Mdata.Write(d1, Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
    end
    else
    begin
      messagedlg('Function PCRResultsObject.CalculateEigenVals() error: Precision of data is not calculated correctly' ,mtinformation,[mbOK],0) ;
    end ;
    MKLscores := Scores.MovePointer(MKLScores,Eigenvalues.SDPrec*Eigenvalues.complexMat) ;
  end ;

end ;


function TPCA.ReturnPercentSpannedByEigenValue(pcNum : integer) :  single ;
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


