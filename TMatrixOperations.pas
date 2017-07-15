unit TMatrixOperations;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, TMatrixObject ;

type
  TMatrixOps  = class
  public
     constructor Create ;  // 
     destructor  Destroy; // override;
     procedure Free ;
     // add_m3 is a matrix that is same size as multiplication result whos values are added placewise to the result. If beta = 0 then added_m3 is ignored
     function    MultMatByMatReturnSingle( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double;transposeResult : boolean ) : single ;
     function    MultiplyMatrixByMatrix( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double;  transposeResult : boolean ) : TMatrix ;
     function    MultiplyMatrixByMatrixPlusMatrix( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double; add_m3 : TMatrix; beta : double; transposeResult : boolean ) : TMatrix ;
     function    MatrixInverseSymmetric(var inOutData : TMatrix): Integer  ; // returns 0 if inversion was success; inOutData input data is overwritten with output data - LAPACK function
     function    MatrixInverseGeneral(var inOutData : TMatrix): Integer  ; // returns 0 if inversion was success; inOutData input data is overwritten with output data - LAPACK function
     function    ReturnVectNormalisedMatrix(inMatrix: TMatrix) : TMatrix ;  // creates a matrix of normalised (unit length) vectors from inMatrix
  private
end;

implementation

uses AtlusBLASLAPACLibrary ;


constructor TMatrixOps.Create;  //
begin
//   inherited Create ;
end ;


destructor  TMatrixOps.Destroy; // override;
begin
//  inherited Destroy ;
end ;

procedure TMatrixOps.Free;
begin
 if Self <> nil then Destroy;
end;


function TMatrixOps.MultMatByMatReturnSingle( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double; transposeResult : boolean ) : single ;
var
  retMat : TMatrix ;
  reVal : single ;
begin
    retMat := TMatrix.Create(1)  ;
    // this should check that return value is a 1x1 matrix
    retMat := MultiplyMatrixByMatrixPlusMatrix(m1, m2, t1, t2, alpha, nil, 0.0, transposeResult ) ;
    retMat.F_Mdata.Seek(0,soFromBeginning) ;
    retMat.F_Mdata.Read(reVal,4) ;
    result := reVal ;
end ;

function TMatrixOps.MultiplyMatrixByMatrix( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double;  transposeResult : boolean ) : TMatrix ;
begin
    result := MultiplyMatrixByMatrixPlusMatrix(m1, m2, t1, t2, alpha, nil, 0.0, transposeResult ) ;
end ;


function TMatrixOps.MultiplyMatrixByMatrixPlusMatrix( m1, m2 : TMatrix; t1, t2 : boolean; alpha : double; add_m3 : TMatrix; beta : double; transposeResult : boolean ) : TMatrix ;
// t1 and t2 are 'transpose' flags
// transposeResult -  sgemm() and dgemm() return a transposed matrix so transpose if we DONT want a transposed result (i.e. when  transposeResult = false)
Var
   resultMatrix : TMatrix ;  // the reult is transposed as obtained from _gemm
   MKLtrans_1, MKLtrans_2 : char ;

   MKLalphas, MKLbetas : TSingle ;
   MKLalphad, MKLbetad : TDouble ;
   MKLp_m3, MKLp_m1, MKLp_m2 : pointer ;
   MKLlda_m1, MKLlda_m2, MKLlda_m3, commonIndex : integer ;

   MKLtint : integer ;
begin
  //uses BLAS level 3: _gemm ( transa, transb, m, n, commonIndex, alpha, a, lda, b, ldb, beta, c, ldc )
//  c := alpha*op( a)*op( b) + beta* c,
//  op( a) is an m by k matrix
//  op( b) is a k by n matrix
//  c is an m by n matrix.
  MKLp_m1  := m1.F_Mdata.Memory ;     // = a
  MKLp_m2  := m2.F_Mdata.Memory ;     // = b
  if add_m3  <> nil then
    MKLp_m3 := add_m3.F_Mdata.Memory 
  else
    MKLp_m3 := nil ;

  if m1.SDPrec <> m1.SDPrec then
  begin
    messagedlg('matricies are not the same precision, convert first' ,mtError,[mbOK],0) ;
    exit ;
  end ;

  MKLalphas[1] := alpha ;  MKLalphas[2] := 0.0 ;
  MKLbetas[1] := beta;     MKLbetas[2] := 0.0 ;
  MKLalphad[1] := alpha ;  MKLalphad[2] := 0.0 ;
  MKLbetad[1] := beta ;     MKLbetad[2] := 0.0 ;
  MKLlda_m1 :=  m1.numCols ;   // 1st dimension of matrix is always # cols
  MKLlda_m2 :=  m2.numCols ;   // 1st dimension of matrix is always # cols
  if add_m3  <> nil then
    MKLlda_m3 :=  add_m3.numCols ;

  if t1 and t2 then
  begin
    if m1.numRows  <> m2.numCols then
    begin messagedlg('matrix multiplication mismatch:'+ inttoStr(m1.numCols) + ','+ inttoStr(m1.numRows) +' x '+ inttoStr(m2.numCols) + ','+ inttoStr(m2.numRows) ,mtError,[mbOK],0) ; exit end ;
    MKLtrans_1 := 'n' ;
    MKLtrans_2 := 'n' ;
    commonIndex := m1.numRows ;
    resultMatrix :=  TMatrix.Create2(m1.SDPrec div 4, m2.numRows , m1.numCols) ;  // this constructor sets size of 'F_Mdata' data matrix
    if (m1.complexMat=2) then
    begin
      resultMatrix.F_Mdata.SetSize(resultMatrix.F_Mdata.Size * 2) ;
      resultMatrix.complexMat := 2 ;
    end ;
    MKLlda_m3 :=  resultMatrix.numCols ;
    MKLp_m3  := resultMatrix.F_Mdata.Memory ;
    if (m1.SDPrec = 4) and (m1.complexMat=1) then
      sgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=1)  then
      dgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 4) and (m1.complexMat=2)  then
      cgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas, MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=2)  then
      zgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad, MKLp_m3, MKLlda_m3 ) ;
    if not transposeResult then resultMatrix.Transpose ;
  end
  else if (not t1) and  t2 then  // false, true
  begin
    if m1.numCols  <> m2.numCols then
    begin messagedlg('matrix multiplication mismatch:'+ inttoStr(m1.numRows) + ','+ inttoStr(m1.numCols) +' x '+ inttoStr(m2.numCols) + ','+ inttoStr(m2.numRows) ,mtError,[mbOK],0) ; exit end ;
    MKLtrans_1 := 't' ;
    MKLtrans_2 := 'n' ;
    commonIndex := m1.numCols ;
    resultMatrix :=  TMatrix.Create2(m1.SDPrec div 4, m2.numRows, m1.numRows) ;  // this constructor sets size of 'F_Mdata' data matrix
    if (m1.complexMat=2) then
    begin
      resultMatrix.F_Mdata.SetSize(resultMatrix.F_Mdata.Size * 2) ;
      resultMatrix.complexMat := 2 ;
    end ;
    MKLlda_m3 :=  resultMatrix.numCols ;
    MKLp_m3  := resultMatrix.F_Mdata.Memory ;
    if (m1.SDPrec = 4) and (m1.complexMat=1) then
      sgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=1) then
      dgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 4) and (m1.complexMat=2) then
      cgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas, MKLp_m3, MKLlda_m3 )
     else
    if (m1.SDPrec = 8) and (m1.complexMat=2) then
      zgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad, MKLp_m3, MKLlda_m3 ) ;
    if not transposeResult then resultMatrix.Transpose ;
  end
  else if t1 and (not t2) then // true, false   - this works for scores' x scores
  begin
    if m1.numRows  <> m2.numRows then
    begin messagedlg('matrix multiplication mismatch:'+ inttoStr(m1.numCols) + ','+ inttoStr(m1.numRows) +' x '+ inttoStr(m2.numRows) + ','+ inttoStr(m2.numCols) ,mtError,[mbOK],0) ; exit end ;
    MKLtrans_1 := 'n' ;
    MKLtrans_2 := 't' ;
    commonIndex := m1.numRows ;
    resultMatrix :=  TMatrix.Create2(m1.SDPrec div 4, m2.numCols, m1.numCols) ;  // this constructor sets size of 'F_Mdata' data matrix
    if (m1.complexMat=2) then
    begin
      resultMatrix.F_Mdata.SetSize(resultMatrix.F_Mdata.Size * 2) ;
      resultMatrix.complexMat := 2 ;
    end ;
    MKLlda_m3 :=  resultMatrix.numCols ;
    MKLp_m3  := resultMatrix.F_Mdata.Memory ;
    if (m1.SDPrec = 4) and (m1.complexMat=1) then
      sgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=1) then
      dgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 4) and (m1.complexMat=2) then
      cgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas, MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=2) then
      zgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad, MKLp_m3, MKLlda_m3 ) ;
    if not transposeResult then resultMatrix.Transpose ;
  end
  else  // (not t1) and (not t2)
  begin
    if m1.numCols  <> m2.numRows then
    begin messagedlg('matrix multiplication mismatch:'+ inttoStr(m1.numRows) + ','+ inttoStr(m1.numCols) +' x '+ inttoStr(m2.numRows) + ','+ inttoStr(m2.numCols) ,mtError,[mbOK],0) ; exit end ;
   // this works but answer is transposed version of matrix wanted
    MKLtrans_1 := 't' ;
    MKLtrans_2 := 't' ;
    commonIndex := m1.numCols ;
    resultMatrix :=  TMatrix.Create2(m1.SDPrec div 4, m2.numCols, m1.numRows) ;  // this constructor sets size of 'F_Mdata' data matrix
    if (m1.complexMat=2) then
    begin
      resultMatrix.F_Mdata.SetSize(resultMatrix.F_Mdata.Size * 2) ;
      resultMatrix.complexMat := 2 ;
    end ;
    MKLlda_m3 :=  resultMatrix.numCols ;
    MKLp_m3  := resultMatrix.F_Mdata.Memory ;
    if (m1.SDPrec = 4) and (m1.complexMat=1) then
      sgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=1) then
      dgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad[1], MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad[1], MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 4) and (m1.complexMat=2) then
      cgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphas, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetas, MKLp_m3, MKLlda_m3 )
    else
    if (m1.SDPrec = 8) and (m1.complexMat=2) then
     zgemm ( MKLtrans_1, MKLtrans_2, resultMatrix.numCols  , resultMatrix.numRows, commonIndex, MKLalphad, MKLp_m1, MKLlda_m1, MKLp_m2, MKLlda_m2, MKLbetad, MKLp_m3, MKLlda_m3 ) ;
    if not transposeResult then resultMatrix.Transpose ;
  end ;

  result := resultMatrix ; // result is a pointer to the object created above
end ;


function TMatrixOps.MatrixInverseSymmetric(var inOutData : TMatrix): Integer  ;
 // returns 0 if inversion was success; inOutData input data is overwritten with output data
var
  uplo : char ;
  MKLa, ipiv, work : pointer ;
  n, MKLlda, lwork, info : integer ;
begin
try
  uplo   := 'L' ;   // the data ends up in upper triangle
  n      :=  inOutData.numCols ;
  MKLlda :=  inOutData.numCols ;
  lwork  :=  n * 8 * inOutData.SDPrec * inOutData.complexMat ; // lwork = n*blocksize,  blocksize is typically, 16 to 64
  info := 0 ;

  MKLa := inOutData.F_Mdata.Memory ;
  GetMem(ipiv, 4*n) ;
  GetMem(work, lwork) ;
  if (inOutData.SDPrec = 4) and (inOutData.complexMat=1) then
    ssytrf(uplo, n, MKLa, MKLlda, ipiv, work, lwork, info)   // LAPACK FUNCTION      // Computes the Bunch-Kaufman factorization of a symmetric matrix.
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=1) then
    dsytrf(uplo, n, MKLa, MKLlda, ipiv, work, lwork, info)   // LAPACK FUNCTION
  else if (inOutData.SDPrec = 4) and (inOutData.complexMat=2) then
    csytrf(uplo, n, MKLa, MKLlda, ipiv, work, lwork, info)   // LAPACK FUNCTION
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=2) then
    zsytrf(uplo, n, MKLa, MKLlda, ipiv, work, lwork, info) ;  // LAPACK FUNCTION
  if info <> 0 then
  begin
     messagedlg('Failed to factorise matrix while finding inverse. Error: ' + inttostr(info)  ,mtinformation,[mbOK],0) ;
     result := info ;
     exit ;
  end ;

  MKLa := inOutData.F_Mdata.Memory ;
  if (inOutData.SDPrec = 4) and (inOutData.complexMat=1) then
    ssytri(uplo, n, MKLa, MKLlda, ipiv, work, info)    // LAPACK FUNCTION  // Computes the inverse of a real symmetric indefinite matrix
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=1) then
    dsytri(uplo, n, MKLa, MKLlda, ipiv, work, info)    // LAPACK FUNCTION
  else if (inOutData.SDPrec = 4) and (inOutData.complexMat=2) then
    csytri(uplo, n, MKLa, MKLlda, ipiv, work, info)    // LAPACK FUNCTION
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=2) then
    zsytri(uplo, n, MKLa, MKLlda, ipiv, work, info) ;   // LAPACK FUNCTION
  if info <> 0 then
  begin
     messagedlg('Failed to find inverse. Error: ' + inttostr(info)  ,mtinformation,[mbOK],0) ;
     result := info ;
     exit ;
  end ;

//  inOutData.Transpose ;
  inOutData.CopyUpperToLower ; // copies upper triangle of matrix to lower

  result := info ;
finally
begin
  FreeMem(ipiv) ;
  FreeMem(work) ;
end ;
end ;
end ;



function TMatrixOps.MatrixInverseGeneral(var inOutData : TMatrix): Integer  ;
 // returns 0 if inversion was success; inOutData input data is overwritten with output data
var
  uplo : char ;
  MKLa, ipiv, work : pointer ;
  m, n, MKLlda, lwork, info : integer ;
begin
try
  m      :=  inOutData.numRows ;
  n      :=  inOutData.numCols ;
  MKLlda :=  inOutData.numCols ;
  lwork  :=  n * 8 * inOutData.SDPrec * inOutData.complexMat ; // lwork = n*blocksize,  blocksize is typically, 16 to 64
  info := 0 ;
  MKLa := inOutData.F_Mdata.Memory ;

{sgetrf  (         VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );   }
  GetMem(ipiv, 4*n) ;
  GetMem(work, lwork) ;
  if (inOutData.SDPrec = 4) and (inOutData.complexMat=1) then
    sgetrf(m, n, MKLa, MKLlda, ipiv, info)   // LAPACK FUNCTION      // Computes the Bunch-Kaufman factorization of a symmetric matrix.
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=1) then
    dgetrf(m, n, MKLa, MKLlda, ipiv, info)   // LAPACK FUNCTION
  else if (inOutData.SDPrec = 4) and (inOutData.complexMat=2) then
    cgetrf(m, n, MKLa, MKLlda, ipiv, info)   // LAPACK FUNCTION
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=2) then
    zgetrf(m, n, MKLa, MKLlda, ipiv, info) ;  // LAPACK FUNCTION
  if info <> 0 then
  begin
     messagedlg('Failed to factorise matrix while finding inverse. Error: ' + inttostr(info)  ,mtinformation,[mbOK],0) ;
     result := info ;
     exit ;
  end ;


 { sgetri        (  VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl; }

  MKLa := inOutData.F_Mdata.Memory ;
  if (inOutData.SDPrec = 4) and (inOutData.complexMat=1) then
    sgetri( n, MKLa, MKLlda, ipiv, work, lwork, info)    // LAPACK FUNCTION  // Computes the inverse of a real symmetric indefinite matrix
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=1) then
    dgetri( n, MKLa, MKLlda, ipiv, work, lwork, info)    // LAPACK FUNCTION
  else if (inOutData.SDPrec = 4) and (inOutData.complexMat=2) then
    cgetri( n, MKLa, MKLlda, ipiv, work, lwork, info)    // LAPACK FUNCTION
  else if (inOutData.SDPrec = 8) and (inOutData.complexMat=2) then
    zgetri( n, MKLa, MKLlda, ipiv, work, lwork, info) ;   // LAPACK FUNCTION
  if info <> 0 then
  begin
     messagedlg('Failed to find inverse. Error: ' + inttostr(info)  ,mtinformation,[mbOK],0) ;
     result := info ;
     exit ;
  end ;

//  inOutData.Transpose ;
//  inOutData.CopyUpperToLower ; // copies upper triangle of matrix to lower

  result := info ;
finally
begin
  FreeMem(ipiv) ;
  FreeMem(work) ;
end ;
end ;
end ;




// creates a matrix of normalised (unit length) vectors from inMatrix
function TMatrixOps.ReturnVectNormalisedMatrix(inMatrix: TMatrix) : TMatrix ;
// N.B. Always free the original incoming matrix if it is being reassigned to resMatrix matrix created in this function
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
        lengthSSEVects_s := snrm2 ( resMatrix.numCols , MKLa, MKLtint ) ; // SNRM2 := sqrt( x'*x ).
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


end.
 