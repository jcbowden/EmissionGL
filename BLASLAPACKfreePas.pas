UNIT BLASLAPACKfreePas;
//{$define LINUX=1}
//{$define free=1}
//{$define ATLASLINUX=1}
 
{$ifdef free}  // this is defined by Free pascal complier
//{$mode delphi}
{$else}
{$define WIN32}
{$endif}
// From efg
// Modifed by Josh Bowden for Ccompilation with Free Pascal Ccompiler
// josh.bowden@csiro.au

// {$define LINUX}
// {$define FREEPASCAL}

{$ifdef MKL}
  {$LIBRARYPATH /opt/intel/mkl/10.0.1.014/lib/em64t}
  {$LIBRARYPATH /lib64/}
  {$LinkLib 'c'}
  {$LinkLib 'mkl_lapack'}
  {$linklib 'mkl_intel_lp64'}
  {$linklib 'mkl_intel_thread'}
  {$linklib 'mkl_core'}
  {$LinkLib 'pthread'}
  {$LinkLib 'gcc_s'}
  {$LinkLib 'm'}
{$endif}

{$ifdef ATLASLINUX}
  {$LIBRARYPATH /usr/lib64/atlas/}
  {$LinkLib 'c'}
  {$LinkLib '/usr/lib64/atlas/libatlas.so.3'}
  {$LinkLib '/usr/lib64/atlas/libblas.so.3'}
  {$LinkLib '/usr/lib64/atlas/liblapack.so.3'}
  {$LinkLib 'pthread'}
  {$LinkLib 'gcc_s'}
  {$LinkLib 'm'}
{$endif}




INTERFACE

//{$ifdef LINUX}
uses
mkl_types;
//{$endif}

type
  TSingle = Array[1..2] of single ;
  TDouble = Array[1..2] of double ;

{$ifndef LINUX}
CONST
  IntelDLL = 'atlas_centrino_new.dll';
  IntelDLL_LAPACK = 'LAPACK.dll' ;
{$endif}



 FUNCTION sasum  (VAR n   :  INTEGER;                        // Single
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl ;

  FUNCTION dasum  (VAR n   :  INTEGER;                        // Double
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  double;   CDecl ;

  FUNCTION scasum (VAR n   :  INTEGER;                        // Complex Single
                    x   :  pointer;  // vector
                   VAR incx:  INTEGER):  Single;   CDecl ;

  FUNCTION dzasum (VAR n   :  INTEGER;                        // Complex Double
                    x   :  pointer;  // vector
                   VAR incx:  INTEGER):  Single;   CDecl ;



  PROCEDURE  saxpy ( VAR n   :  INTEGER;
                    VAR a   :  Single;
                     x   :  pointer;
                    VAR incx:  INTEGER;
                     y   :  pointer;
                    VAR incy:  INTEGER); CDecl ;


  PROCEDURE  daxpy ( VAR n   :  INTEGER;
                    VAR a   :  double;
                     x   :  pointer;
                    VAR incx:  INTEGER;
                     y   :  pointer;
                    VAR incy:  INTEGER); CDecl ;

 PROCEDURE  caxpy ( VAR n   :  INTEGER;
                    VAR a   :  TSingle;
                     x   :  pointer;
                    VAR incx:  INTEGER;
                     y   :  pointer;
                    VAR incy:  INTEGER); CDecl ;

 PROCEDURE  zaxpy ( VAR n   :  INTEGER;
                    VAR a   :  TDouble;
                     x   :  pointer;
                    VAR incx:  INTEGER;
                     y   :  pointer;
                    VAR incy:  INTEGER); CDecl ;




  PROCEDURE scopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl ;

  PROCEDURE dcopy (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl ;

  PROCEDURE ccopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl ;

  PROCEDURE zcopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl ;

  // res = snrm2 ( n, x, incx )   - calculates euclidean norm of vector = sqrt(sum of square)
  FUNCTION snrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl ;

  FUNCTION dnrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Double;   CDecl ;

  FUNCTION scnrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl ;

  FUNCTION dznrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Double;   CDecl ;


  // call sscal ( n, a, x, incx )
  PROCEDURE sscal  (VAR n   :  INTEGER;
                   VAR a   :  Single ;
                    x   :  pointer;          // vector{$LIBRARYPATH /usr/X11/lib;/usr/local/lib}
                   VAR incx:  INTEGER);     CDecl ;

  PROCEDURE dscal  (VAR n   :  INTEGER;
                   VAR a   :  Double ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl ;

  PROCEDURE csscal  (VAR n   :  INTEGER;   // scale complex by single
                   VAR a   :  Single ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl ;

  PROCEDURE zdscal  (VAR n   :  INTEGER;   // scale double complex by double
                   VAR a   :  Double ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl ;


  // dot product
  FUNCTION sdot   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  Single;   CDecl ;

  FUNCTION ddot   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  double;   CDecl ;

  FUNCTION cdotu   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  TSingle;   CDecl ;

  FUNCTION zdotu   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  TDouble;   CDecl ;


  FUNCTION isamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl ;

  FUNCTION idamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl ;

  FUNCTION icamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl ;

  FUNCTION izamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl ;

  // BLAS Level 2 /////////////////////////////////////////////////////////////
  // call sger ( m, n, alpha, x, incx, y, incy, a, lda )
  // a := alpha* x* y’ + a
  PROCEDURE sger  (VAR m,n  :  INTEGER;
                   VAR alpha:  Single;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl ;

  PROCEDURE dger  (VAR m,n  :  INTEGER;
                   VAR alpha:  Double;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl ;

  PROCEDURE cgeru  (VAR m,n  :  INTEGER;
                   VAR alpha:  TSingle;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl ;

  PROCEDURE zgeru  (VAR m,n  :  INTEGER;
                   VAR alpha:  TDouble;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl ;

  // y = alpha*a*x + beta*y:  if trans = 't' then a = a'
  PROCEDURE sgemv  (VAR trans : CHAR ;
                   VAR m,n  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  Single;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                   VAR beta:  Single;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER
                   );            CDecl ;

   PROCEDURE dgemv  (VAR trans : CHAR ;
                   VAR m,n  :  INTEGER;
                   VAR alpha:  Double;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                   VAR beta:  Double;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER
                   );            CDecl ;

   PROCEDURE cgemv  (VAR trans : CHAR ;
                   VAR m,n  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  TSingle;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                   VAR beta:  TSingle;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER
                   );            CDecl ;

   PROCEDURE zgemv  (VAR trans : CHAR ;
                   VAR m,n  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  TDouble;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                   VAR beta:  TDouble;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER
                   );            CDecl ;


// BLAS Level 3 /////////////////////////////////////////////////////////////

//call sgemm ( transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc )
//call dgemm ( transa, transb, m, n, k, alpha, a, lda, b, ldb, beta, c, ldc )

PROCEDURE sgemm  (VAR transa, transb : CHAR ;
                   VAR m,n,k  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  Single;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    b    :  pointer;    // n-by-m matrix
                   VAR ldb :  INTEGER;
                   VAR beta:  Single;
                    c    :  pointer;    // m-by-m matrix
                   VAR ldc :  INTEGER
                   );            CDecl  ;

PROCEDURE dgemm  (VAR transa, transb : CHAR ;
                   VAR m,n,k  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  double;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    b    :  pointer;    // n-by-m matrix
                   VAR ldb :  INTEGER;
                   VAR beta:  double;
                    c    :  pointer;    // m-by-m matrix
                   VAR ldc :  INTEGER
                   );            CDecl ;

PROCEDURE cgemm  (VAR transa, transb : CHAR ;
                   VAR m,n,k  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  TSingle;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    b    :  pointer;    // n-by-m matrix
                   VAR ldb :  INTEGER;
                   VAR beta:  TSingle;
                    c    :  pointer;    // m-by-m matrix
                   VAR ldc :  INTEGER
                   );            CDecl	 ;

PROCEDURE zgemm  (VAR transa, transb : CHAR ;
                   VAR m,n,k  :  INTEGER; // m = num rows, n = num cols
                   VAR alpha:  TDouble;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    b    :  pointer;    // n-by-m matrix
                   VAR ldb :  INTEGER;
                   VAR beta:  TDouble;
                    c    :  pointer;    // m-by-m matrix
                   VAR ldc :  INTEGER
                   );            CDecl	 ;

// LAPACK - system enquiry function, used to determine work space size etc (see docs on web)
FUNCTION ilaenv  (VAR ispec   : INTEGER ;     // desired return value (=1 for block size)
                  name, opts  : string ;      // name = name of routine of interest ; opts - see below
                  VAR n1,n2,n3,n4 : INTEGER ) : INTEGER ;  CDecl	 ;   // integer parameters of the routine of interest
                  {opts :  The character options to the subroutine NAME, concatenated  into  a  single  character string.
                   Example, UPLO = 'U', TRANS = 'T', and DIAG  =  'N' for  a  triangular  routine  would be specified as
                   OPTS = 'UTN'.  }

// LAPACK factorisation of general matrix
// call sgetrf ( m, n, a, lda, ipiv, info )
// CALL BEFORE sgetri()
PROCEDURE sgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE dgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE cgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE zgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl ;


// LAPACK factorisation of symmetric matrix
// call ssytrf ( uplo, n, a, lda, ipiv, work, lwork, info )
// CALL BEFORE ssytri()
PROCEDURE ssytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE dsytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE csytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl ;

PROCEDURE zsytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl ;


// LAPACK inverse of genral matrix  - have to call sgetrf first to factorize
//call sgetri (n, a, lda, ipiv, work, lwork, info)
PROCEDURE sgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl ;

PROCEDURE dgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl ;

PROCEDURE cgetri ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl ;

PROCEDURE zgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl ;

// LAPACK inverse of symmetric matrix
// call ssytri ( uplo, n, a, lda, ipiv, work, info)
PROCEDURE ssytri (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl ;

PROCEDURE dsytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl ;

PROCEDURE csytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl ;

PROCEDURE zsytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl ;



IMPLEMENTATION



{$ifdef ATLASLINUX}
  // BLAS Level 1 /////////////////////////////////////////////////////////////
  FUNCTION  sasum;   CDecl;   EXTERNAL   NAME 'sasum_';
  FUNCTION  dasum;   CDecl;   EXTERNAL  NAME 'dasum_';
  FUNCTION  scasum;  CDecl;   EXTERNAL  NAME 'scasum_';
  FUNCTION  dzasum;  CDecl;   EXTERNAL  NAME 'dzasum_';

  PROCEDURE  saxpy;  CDecl;   EXTERNAL  NAME 'saxpy_' ;
  PROCEDURE  daxpy;  CDecl;   EXTERNAL  NAME 'daxpy_' ;
  PROCEDURE  caxpy;  CDecl;   EXTERNAL  NAME 'caxpy_' ;
  PROCEDURE  zaxpy;  CDecl;   EXTERNAL  NAME 'zaxpy_' ;

  FUNCTION  snrm2;   CDecl;   EXTERNAL   NAME 'snrm2_';
  FUNCTION  dnrm2;   CDecl;   EXTERNAL   NAME 'dnrm2_';
  FUNCTION  scnrm2;  CDecl;   EXTERNAL  NAME 'scnrm2_';
  FUNCTION  dznrm2;  CDecl;   EXTERNAL  NAME 'dznrm2_';

  PROCEDURE sscal;   CDecl;   EXTERNAL   NAME 'sscal_';
  PROCEDURE dscal;   CDecl;   EXTERNAL   NAME 'dscal_';
  PROCEDURE csscal;   CDecl;   EXTERNAL  NAME 'csscal_';
  PROCEDURE zdscal;   CDecl;   EXTERNAL  NAME 'zdscal_';

  PROCEDURE scopy;   CDecl;   EXTERNAL  NAME 'scopy_';
  PROCEDURE dcopy;   CDecl;   EXTERNAL  NAME 'dcopy_';
  PROCEDURE ccopy;   CDecl;   EXTERNAL  NAME 'ccopy_';
  PROCEDURE zcopy;   CDecl;   EXTERNAL  NAME 'zcopy_';

  FUNCTION  sdot;    CDecl;   EXTERNAL   NAME 'sdot_';
  FUNCTION  cdotu;    CDecl;   EXTERNAL  NAME 'cdotu_';
  FUNCTION  ddot;    CDecl;   EXTERNAL   NAME 'ddot_';
  FUNCTION  zdotu;    CDecl;   EXTERNAL  NAME 'zdotu_';

  FUNCTION  isamax;  CDecl;   EXTERNAL  NAME 'isamax_';
  FUNCTION  idamax;  CDecl;   EXTERNAL  NAME 'idamax_';
  FUNCTION  icamax;  CDecl;   EXTERNAL  NAME 'idamax_';
  FUNCTION  izamax;  CDecl;   EXTERNAL  NAME 'idamax_';

 // BLAS Level 2 /////////////////////////////////////////////////////////////
  PROCEDURE sger;  CDecl;   EXTERNAL  NAME 'sger_';
  PROCEDURE dger;  CDecl;   EXTERNAL  NAME 'dger_';
  PROCEDURE cgeru;  CDecl;   EXTERNAL  NAME 'cgeru_';
  PROCEDURE zgeru;  CDecl;   EXTERNAL  NAME 'zgeru_';

  PROCEDURE sgemv;  CDecl;   EXTERNAL  NAME 'sgemv_';
  PROCEDURE dgemv;  CDecl;   EXTERNAL  NAME 'dgemv_';
  PROCEDURE cgemv;  CDecl;   EXTERNAL  NAME 'cgemv_';
  PROCEDURE zgemv;  CDecl;   EXTERNAL  NAME 'zgemv_';

 // BLAS Level 3 /////////////////////////////////////////////////////////////
  PROCEDURE sgemm;  CDecl;   EXTERNAL  NAME 'sgemm_';
  PROCEDURE dgemm;  CDecl;   EXTERNAL  NAME 'dgemm_';
  PROCEDURE cgemm;  CDecl;   EXTERNAL  NAME 'cgemm_';
  PROCEDURE zgemm;  CDecl;   EXTERNAL  NAME 'zgemm_';

  // atlas_centrino.dll original code for seperate lapack and blas dll
 // LAPACK ROUTINES //////////////////////////////////////////////////////////
 // diagnostic function - determine block size
   FUNCTION  ilaenv;  CDecl;   EXTERNAL  NAME 'ilaenv_';
 // MATRIX FACTORISATION
   PROCEDURE sgetrf;  CDecl;   EXTERNAL  NAME 'sgetrf_';   // general matrix factorisation
   PROCEDURE dgetrf;  CDecl;   EXTERNAL  NAME 'dgetrf_';   // general matrix factorisation
   PROCEDURE cgetrf;  CDecl;   EXTERNAL  NAME 'cgetrf_';   // general matrix factorisation
   PROCEDURE zgetrf;  CDecl;   EXTERNAL  NAME 'zgetrf_';   // general matrix factorisation

   PROCEDURE ssytrf;  CDecl;   EXTERNAL  NAME 'ssytrf_';   // symmetric matrix factorisation
   PROCEDURE dsytrf;  CDecl;   EXTERNAL  NAME 'dsytrf_';   // symmetric matrix factorisation
   PROCEDURE csytrf;  CDecl;   EXTERNAL  NAME 'csytrf_';   // symmetric matrix factorisation
   PROCEDURE zsytrf;  CDecl;   EXTERNAL  NAME 'zsytrf_';   // symmetric matrix factorisation

 // MATRIX INVERSION - need to call  'ssytrf' first
   PROCEDURE sgetri;  CDecl;   EXTERNAL  NAME 'sgetri_';   // symmetric matrix inversion
   PROCEDURE dgetri;  CDecl;   EXTERNAL  NAME 'dgetri_';   // symmetric matrix inversion
   PROCEDURE cgetri;  CDecl;   EXTERNAL  NAME 'cgetri_';   // symmetric matrix inversion
   PROCEDURE zgetri;  CDecl;   EXTERNAL  NAME 'zgetri_';   // symmetric matrix inversion

   PROCEDURE ssytri;  CDecl;   EXTERNAL  NAME 'ssytri_';   // symmetric matrix inversion
   PROCEDURE dsytri;  CDecl;   EXTERNAL  NAME 'dsytri_';   // symmetric matrix inversion
   PROCEDURE csytri;  CDecl;   EXTERNAL  NAME 'csytri_';   // symmetric matrix inversion
   PROCEDURE zsytri;  CDecl;   EXTERNAL  NAME 'zsytri_';   // symmetric matrix inversion


{$else}   // Windows code using atlas .dll's
  // BLAS Level 1 /////////////////////////////////////////////////////////////
  FUNCTION  sasum;   CDecl;   EXTERNAL IntelDLL  NAME 'sasum';
  FUNCTION  dasum;   CDecl;   EXTERNAL IntelDLL  NAME 'dasum';
  FUNCTION  scasum;  CDecl;   EXTERNAL IntelDLL  NAME 'scasum';
  FUNCTION  dzasum;  CDecl;   EXTERNAL IntelDLL  NAME 'dzasum';

  PROCEDURE  saxpy;  CDecl;   EXTERNAL IntelDLL  NAME 'saxpy' ;
  PROCEDURE  daxpy;  CDecl;   EXTERNAL IntelDLL  NAME 'daxpy' ;
  PROCEDURE  caxpy;  CDecl;   EXTERNAL IntelDLL  NAME 'caxpy' ;
  PROCEDURE  zaxpy;  CDecl;   EXTERNAL IntelDLL  NAME 'zaxpy' ;

  FUNCTION  snrm2;  CDecl;   EXTERNAL IntelDLL  NAME 'snrm2';
  FUNCTION  dnrm2;  CDecl;   EXTERNAL IntelDLL  NAME 'dnrm2';
  FUNCTION  scnrm2;  CDecl;   EXTERNAL IntelDLL  NAME 'scnrm2';
  FUNCTION  dznrm2;  CDecl;   EXTERNAL IntelDLL  NAME 'dznrm2';

  PROCEDURE sscal;   CDecl;   EXTERNAL IntelDLL  NAME 'sscal';
  PROCEDURE dscal;   CDecl;   EXTERNAL IntelDLL  NAME 'dscal';
  PROCEDURE csscal;   CDecl;   EXTERNAL IntelDLL  NAME 'csscal';
  PROCEDURE zdscal;   CDecl;   EXTERNAL IntelDLL  NAME 'zdscal';

  PROCEDURE scopy;   CDecl;   EXTERNAL IntelDLL  NAME 'scopy';
  PROCEDURE dcopy;   CDecl;   EXTERNAL IntelDLL  NAME 'dcopy';
  PROCEDURE ccopy;   CDecl;   EXTERNAL IntelDLL  NAME 'ccopy';
  PROCEDURE zcopy;   CDecl;   EXTERNAL IntelDLL  NAME 'zcopy';

  FUNCTION  sdot;    CDecl;   EXTERNAL IntelDLL  NAME 'sdot';
  FUNCTION  cdotu;    CDecl;   EXTERNAL IntelDLL  NAME 'cdotu';
  FUNCTION  ddot;    CDecl;   EXTERNAL IntelDLL  NAME 'ddot';
  FUNCTION  zdotu;    CDecl;   EXTERNAL IntelDLL  NAME 'zdotu';

  FUNCTION  isamax;  CDecl;   EXTERNAL IntelDLL  NAME 'isamax';
  FUNCTION  idamax;  CDecl;   EXTERNAL IntelDLL  NAME 'idamax';
  FUNCTION  icamax;  CDecl;   EXTERNAL IntelDLL  NAME 'idamax';
  FUNCTION  izamax;  CDecl;   EXTERNAL IntelDLL  NAME 'idamax';

 // BLAS Level 2 /////////////////////////////////////////////////////////////
  PROCEDURE sger;  CDecl;   EXTERNAL IntelDLL  NAME 'sger';
  PROCEDURE dger;  CDecl;   EXTERNAL IntelDLL  NAME 'dger';
  PROCEDURE cgeru;  CDecl;   EXTERNAL IntelDLL  NAME 'cgeru';
  PROCEDURE zgeru;  CDecl;   EXTERNAL IntelDLL  NAME 'zgeru';

  PROCEDURE sgemv;  CDecl;   EXTERNAL IntelDLL  NAME 'sgemv';
  PROCEDURE dgemv;  CDecl;   EXTERNAL IntelDLL  NAME 'dgemv';
  PROCEDURE cgemv;  CDecl;   EXTERNAL IntelDLL  NAME 'cgemv';
  PROCEDURE zgemv;  CDecl;   EXTERNAL IntelDLL  NAME 'zgemv';

 // BLAS Level 3 /////////////////////////////////////////////////////////////
  PROCEDURE sgemm;  CDecl;   EXTERNAL IntelDLL  NAME 'sgemm';
  PROCEDURE dgemm;  CDecl;   EXTERNAL IntelDLL  NAME 'dgemm';
  PROCEDURE cgemm;  CDecl;   EXTERNAL IntelDLL  NAME 'cgemm';
  PROCEDURE zgemm;  CDecl;   EXTERNAL IntelDLL  NAME 'zgemm';

  // atlas_centrino.dll original code for seperate lapack and blas dll
 // LAPACK ROUTINES //////////////////////////////////////////////////////////
 // diagnostic function - determine block size
   FUNCTION ilaenv;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'ilaenv_';
 // MATRIX FACTORISATION
   PROCEDURE sgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'sgetrf_';   // general matrix factorisation
   PROCEDURE dgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'dgetrf_';   // general matrix factorisation
   PROCEDURE cgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'cgetrf_';   // general matrix factorisation
   PROCEDURE zgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'zgetrf_';   // general matrix factorisation

   PROCEDURE ssytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'ssytrf_';   // symmetric matrix factorisation
   PROCEDURE dsytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'dsytrf_';   // symmetric matrix factorisation
   PROCEDURE csytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'csytrf_';   // symmetric matrix factorisation
   PROCEDURE zsytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'zsytrf_';   // symmetric matrix factorisation

 // MATRIX INVERSION - need to call  'ssytrf' first
   PROCEDURE sgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'sgetri_';   // symmetric matrix inversion
   PROCEDURE dgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'dgetri_';   // symmetric matrix inversion
   PROCEDURE cgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'cgetri_';   // symmetric matrix inversion
   PROCEDURE zgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'zgetri_';   // symmetric matrix inversion

   PROCEDURE ssytri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'ssytri_';   // symmetric matrix inversion
   PROCEDURE dsytri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'dsytri_';   // symmetric matrix inversion
   PROCEDURE csytri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'csytri_';   // symmetric matrix inversion
   PROCEDURE zsytri;  CDecl;   EXTERNAL IntelDLL_LAPACK  NAME 'zsytri_';   // symmetric matrix inversion
{$endif}




END.
