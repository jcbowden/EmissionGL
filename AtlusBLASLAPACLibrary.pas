// efg's Computer Lab, www.efg2.com/lab
// efg, February 1999

UNIT AtlusBLASLAPACLibrary;

INTERFACE


{
  TYPE
    TSingleComplex =
    RECORD
      x:  Single;
      y:  Single
    END;

    TDoubleComplex =
    RECORD
      x:  Double;
      y:  Double
    END;     }

type
  TSingle = Array[1..2] of single ;
  TDouble = Array[1..2] of double ;


{  FUNCTION SetSingleComplex(CONST x,y:  Single):  TSingleComplex;
  FUNCTION SetDoubleComplex(CONST x,y:  Double):  TDoubleComplex;       }

  // Main 'trick' so far:  Use all VAR parameters (i.e., a pointer is being
  // passed).  For vectors pass first element, i.e., pass x[1] instead of
  // simply x.  Could define arrays to be 0 or 1-based this way.

  // BLAS Level 1 /////////////////////////////////////////////////////////////

  // ?asum -- Computes the sum of magnitudes of the vector elements
  FUNCTION sasum  (VAR n   :  INTEGER;                        // Single
                   VAR x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl;

  FUNCTION dasum  (VAR n   :  INTEGER;                        // Double
                   VAR x   :  pointer;          // vector
                   VAR incx:  INTEGER):  double;   CDecl;

  FUNCTION scasum (VAR n   :  INTEGER;                        // Complex Single
                   VAR x   :  pointer;  // vector
                   VAR incx:  INTEGER):  Single;   CDecl;

  FUNCTION dzasum (VAR n   :  INTEGER;                        // Complex Double
                   VAR x   :  pointer;  // vector
                   VAR incx:  INTEGER):  Single;   CDecl;



  PROCEDURE  saxpy ( VAR n   :  INTEGER;
                    VAR a   :  Single;
                    VAR x   :  pointer;
                    VAR incx:  INTEGER;
                    VAR y   :  pointer;
                    VAR incy:  INTEGER); CDecl;


  PROCEDURE  daxpy ( VAR n   :  INTEGER;
                    VAR a   :  double;
                    VAR x   :  pointer;
                    VAR incx:  INTEGER;
                    VAR y   :  pointer;
                    VAR incy:  INTEGER); CDecl;

 PROCEDURE  caxpy ( VAR n   :  INTEGER;
                    VAR a   :  TSingle;
                    VAR x   :  pointer;
                    VAR incx:  INTEGER;
                    VAR y   :  pointer;
                    VAR incy:  INTEGER); CDecl;

 PROCEDURE  zaxpy ( VAR n   :  INTEGER;
                    VAR a   :  TDouble;
                    VAR x   :  pointer;
                    VAR incx:  INTEGER;
                    VAR y   :  pointer;
                    VAR incy:  INTEGER); CDecl;




  PROCEDURE scopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl;

  PROCEDURE dcopy (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl;

  PROCEDURE ccopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl;

  PROCEDURE zcopy (VAR n   :  INTEGER;
                   x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER);            CDecl;

  // res = snrm2 ( n, x, incx )   - calculates euclidean norm of vector = sqrt(sum of square)
  FUNCTION snrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl;

  FUNCTION dnrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Double;   CDecl;

  FUNCTION scnrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Single;   CDecl;

  FUNCTION dznrm2  (VAR n   :  INTEGER;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER):  Double;   CDecl;


  // call sscal ( n, a, x, incx )
  PROCEDURE sscal  (VAR n   :  INTEGER;
                   VAR a   :  Single ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl;

  PROCEDURE dscal  (VAR n   :  INTEGER;
                   VAR a   :  Double ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl;

  PROCEDURE csscal  (VAR n   :  INTEGER;   // scale complex by single
                   VAR a   :  Single ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl;

  PROCEDURE zdscal  (VAR n   :  INTEGER;   // scale double complex by double
                   VAR a   :  Double ;
                    x   :  pointer;          // vector
                   VAR incx:  INTEGER);     CDecl;


  // dot product
  FUNCTION sdot   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  Single;   CDecl;

  FUNCTION ddot   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  double;   CDecl;

  FUNCTION cdotu   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  TSingle;   CDecl;

  FUNCTION zdotu   (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER;
                    y   :  pointer;    // vector
                   VAR incy:  INTEGER):  TDouble;   CDecl;


  FUNCTION isamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl;

  FUNCTION idamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl;

  FUNCTION icamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl;

  FUNCTION izamax (VAR n   :  INTEGER;
                    x   :  pointer;    // vector
                   VAR incx:  INTEGER):  INTEGER;   CDecl;

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
                   VAR lda  :  INTEGER);            CDecl;

  PROCEDURE dger  (VAR m,n  :  INTEGER;
                   VAR alpha:  Double;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl;

  PROCEDURE cgeru  (VAR m,n  :  INTEGER;
                   VAR alpha:  TSingle;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl;

  PROCEDURE zgeru  (VAR m,n  :  INTEGER;
                   VAR alpha:  TDouble;
                    x    :  pointer;    // m-element vector
                   VAR incx :  INTEGER;
                    y    :  pointer;    // n-element vector
                   VAR incy :  INTEGER;
                    a    :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER);            CDecl;

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
                   );            CDecl;

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
                   );            CDecl;

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
                   );            CDecl;

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
                   );            CDecl;


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
                   );            CDecl		;

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
                   );            CDecl	;

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
                   );            CDecl	;

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
                   );            CDecl	;        

// LAPAC factorisation of general matrix
// call sgetrf ( m, n, a, lda, ipiv, info )
// CALL BEFORE sgetri()
PROCEDURE sgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl;

PROCEDURE dgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl;

PROCEDURE cgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl;

PROCEDURE zgetrf  (VAR m    :  INTEGER ;   // m = num cols
                   VAR n    :  INTEGER;   // n = num rows
                    a       :  pointer;   // m-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;  // The first dimension of a
                    ipiv    :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                   VAR info :  INTEGER    // info=0, the execution is successful.
                   );            CDecl;


// LAPAC factorisation of symmetric matrix
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
                   );            CDecl;

PROCEDURE dsytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl;

PROCEDURE csytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl;

PROCEDURE zsytrf  (VAR uplo : CHAR ;       // 'U' for upper, 'L' for lower
                   VAR n  :  INTEGER;      // n = num rows, n = num cols
                    a    :  pointer;       // n-by-n matrix  - factorised result overwrites original data
                   VAR lda  :  INTEGER ;
                    ipiv :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work :  pointer;   // work is lwork in size.
                   VAR lwork : INTEGER;  // try using lwork = n*blocksize,  blocksize is typically, 16 to 64 ; work(1) gives value needed afer 1st execution
                   VAR info :  INTEGER   // info=0, the execution is successful.
                   );            CDecl;


// LAPAC inverse of genral matrix  - have to call sgetrf first to factorize
//call sgetri (n, a, lda, ipiv, work, lwork, info)
PROCEDURE sgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl;

PROCEDURE dgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl;

PROCEDURE cgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl;

PROCEDURE zgetri  ( VAR n    :  INTEGER;    // n = num rows, n = num cols
                    a        :  pointer;    // m-by-n matrix
                    VAR lda  :  INTEGER ;   // The first dimension of a
                    ipiv     :  pointer ;   // INTEGER Array, DIMENSION at least max(1,n).  The ipiv array, as returned by ?getrf
                    work     :  pointer;    // work must be at least max(1,2* n).
                    VAR lwork    :  INTEGER;    // lwork is the size of the 'work' array
                    VAR info :  INTEGER     // info=0, the execution is successful.
                    );            CDecl;

// LAPAC inverse of symmetric matrix
// call ssytri ( uplo, n, a, lda, ipiv, work, info)
PROCEDURE ssytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl;

PROCEDURE dsytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl;

PROCEDURE csytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl;

PROCEDURE zsytri  (VAR uplo : CHAR ;
                   VAR n    :  INTEGER; // n = num rows, n = num cols
                    a     :  pointer;    // m-by-n matrix
                   VAR lda  :  INTEGER ;
                    ipiv  :  pointer ;  // INTEGER Array, DIMENSION at least max(1,n).
                    work  :  pointer;    // work must be at least max(1,2* n).
                   VAR info :  INTEGER
                   );            CDecl;



IMPLEMENTATION

  USES
    Windows,   // THandle
    Dialogs,   // MessageDlg
    SysUtils;  // IntToHex

  CONST
//      IntelDLL = 'atlas_centrino.dll';
      IntelDLL = 'atlas_centrino_new.dll';
//    IntelDLL = 'MKL_III.dll';
//      IntelDLL = 'atlas_blaslapack.dll';
//      IntelDLL = 'atlas_C2DSSE3pt.dll'; // multithreaded but needs LAPACK
//      IntelDLL = 'atlas.dll';

      IntelDLL_LAPACK = 'LAPACK.dll' ;
//       IntelDLL_LAPACK = 'atlas_centrino_new.dll';

  VAR
    DLLHandle1:  THandle; // IntelDLL
    DLLHandle2:  THandle; // IntelDLL_LAPACK



  // 'Strange' Intel names were discovered by viewing the DLL in the KEdit
  // editor, but I didn't believe the names were correct until the TDUMP
  // utility also verified the 'strange' prefix, which I assume is present
  // to guarantee a unique name.

  // BLAS Level 1 /////////////////////////////////////////////////////////////

  FUNCTION  sasum;   CDecl;   EXTERNAL IntelDLL NAME 'sasum';
  FUNCTION  dasum;   CDecl;   EXTERNAL IntelDLL NAME 'dasum';
  FUNCTION  scasum;  CDecl;   EXTERNAL IntelDLL NAME 'scasum';
  FUNCTION  dzasum;  CDecl;   EXTERNAL IntelDLL NAME 'dzasum';

  PROCEDURE  saxpy;  CDecl;   EXTERNAL IntelDLL NAME 'saxpy'     // these do not seem to work - (see PLS1 code)
  PROCEDURE  daxpy;  CDecl;   EXTERNAL IntelDLL NAME 'daxpy'
  PROCEDURE  caxpy;  CDecl;   EXTERNAL IntelDLL NAME 'caxpy'
  PROCEDURE  zaxpy;  CDecl;   EXTERNAL IntelDLL NAME 'zaxpy'

  FUNCTION  snrm2;  CDecl;   EXTERNAL IntelDLL NAME 'snrm2';
  FUNCTION  dnrm2;  CDecl;   EXTERNAL IntelDLL NAME 'dnrm2';
  FUNCTION  scnrm2;  CDecl;   EXTERNAL IntelDLL NAME 'scnrm2';
  FUNCTION  dznrm2;  CDecl;   EXTERNAL IntelDLL NAME 'dznrm2';

  PROCEDURE sscal;   CDecl;   EXTERNAL IntelDLL NAME 'sscal';
  PROCEDURE dscal;   CDecl;   EXTERNAL IntelDLL NAME 'dscal';
  PROCEDURE csscal;   CDecl;   EXTERNAL IntelDLL NAME 'csscal';
  PROCEDURE zdscal;   CDecl;   EXTERNAL IntelDLL NAME 'zdscal';

  PROCEDURE scopy;   CDecl;   EXTERNAL IntelDLL NAME 'scopy';
  PROCEDURE dcopy;   CDecl;   EXTERNAL IntelDLL NAME 'dcopy';
  PROCEDURE ccopy;   CDecl;   EXTERNAL IntelDLL NAME 'ccopy';
  PROCEDURE zcopy;   CDecl;   EXTERNAL IntelDLL NAME 'zcopy';

  FUNCTION  sdot;    CDecl;   EXTERNAL IntelDLL NAME 'sdot';
  FUNCTION  cdotu;    CDecl;   EXTERNAL IntelDLL NAME 'cdotu';
  FUNCTION  ddot;    CDecl;   EXTERNAL IntelDLL NAME 'ddot';
  FUNCTION  zdotu;    CDecl;   EXTERNAL IntelDLL NAME 'zdotu';

  FUNCTION  isamax;  CDecl;   EXTERNAL IntelDLL NAME 'isamax';
  FUNCTION  idamax;  CDecl;   EXTERNAL IntelDLL NAME 'idamax';
  FUNCTION  icamax;  CDecl;   EXTERNAL IntelDLL NAME 'idamax';
  FUNCTION  izamax;  CDecl;   EXTERNAL IntelDLL NAME 'idamax';

 // BLAS Level 2 /////////////////////////////////////////////////////////////
  PROCEDURE sger;  CDecl;   EXTERNAL IntelDLL NAME 'sger';
  PROCEDURE dger;  CDecl;   EXTERNAL IntelDLL NAME 'dger';
  PROCEDURE cgeru;  CDecl;   EXTERNAL IntelDLL NAME 'cgeru';
  PROCEDURE zgeru;  CDecl;   EXTERNAL IntelDLL NAME 'zgeru';

  PROCEDURE sgemv;  CDecl;   EXTERNAL IntelDLL NAME 'sgemv';
  PROCEDURE dgemv;  CDecl;   EXTERNAL IntelDLL NAME 'dgemv';
  PROCEDURE cgemv;  CDecl;   EXTERNAL IntelDLL NAME 'cgemv';
  PROCEDURE zgemv;  CDecl;   EXTERNAL IntelDLL NAME 'zgemv';

 // BLAS Level 3 /////////////////////////////////////////////////////////////
  PROCEDURE sgemm;  CDecl;   EXTERNAL IntelDLL NAME 'sgemm';
  PROCEDURE dgemm;  CDecl;   EXTERNAL IntelDLL NAME 'dgemm';
  PROCEDURE cgemm;  CDecl;   EXTERNAL IntelDLL NAME 'cgemm';
  PROCEDURE zgemm;  CDecl;   EXTERNAL IntelDLL NAME 'zgemm';

  // atlas_centrino.dll original code for seperate lapack and blas dll
 // LAPACK ROUTINES //////////////////////////////////////////////////////////
 // MATRIX FACTORISATION
   PROCEDURE sgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'sgetrf_';   // general matrix factorisation
   PROCEDURE dgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'dgetrf_';   // general matrix factorisation
   PROCEDURE cgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'cgetrf_';   // general matrix factorisation
   PROCEDURE zgetrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'zgetrf_';   // general matrix factorisation

   PROCEDURE ssytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'ssytrf_';   // symmetric matrix factorisation
   PROCEDURE dsytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'dsytrf_';   // symmetric matrix factorisation
   PROCEDURE csytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'csytrf_';   // symmetric matrix factorisation
   PROCEDURE zsytrf;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'zsytrf_';   // symmetric matrix factorisation

 // MATRIX INVERSION - need to call  'ssytrf' first
   PROCEDURE sgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'sgetri_';   // symmetric matrix inversion
   PROCEDURE dgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'dgetri_';   // symmetric matrix inversion
   PROCEDURE cgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'cgetri_';   // symmetric matrix inversion
   PROCEDURE zgetri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'zgetri_';   // symmetric matrix inversion

   PROCEDURE ssytri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'ssytri_';   // symmetric matrix inversion
   PROCEDURE dsytri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'dsytri_';   // symmetric matrix inversion
   PROCEDURE csytri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'csytri_';   // symmetric matrix inversion
   PROCEDURE zsytri;  CDecl;   EXTERNAL IntelDLL_LAPACK NAME 'zsytri_';   // symmetric matrix inversion

{
//  dual core compiles atlas with lapack: atlas_blaslapack.dll
 // LAPACK ROUTINES //////////////////////////////////////////////////////////
 // MATRIX FACTORISATION
   PROCEDURE sgetrf;  CDecl;   EXTERNAL IntelDLL NAME 'sgetrf';   // general matrix factorisation
   PROCEDURE dgetrf;  CDecl;   EXTERNAL IntelDLL NAME 'dgetrf';   // general matrix factorisation
   PROCEDURE cgetrf;  CDecl;   EXTERNAL IntelDLL NAME 'cgetrf';   // general matrix factorisation
   PROCEDURE zgetrf;  CDecl;   EXTERNAL IntelDLL NAME 'zgetrf';   // general matrix factorisation

   PROCEDURE ssytrf;  CDecl;   EXTERNAL IntelDLL NAME 'ssytrf';   // symmetric matrix factorisation
   PROCEDURE dsytrf;  CDecl;   EXTERNAL IntelDLL NAME 'dsytrf';   // symmetric matrix factorisation
   PROCEDURE csytrf;  CDecl;   EXTERNAL IntelDLL NAME 'csytrf';   // symmetric matrix factorisation
   PROCEDURE zsytrf;  CDecl;   EXTERNAL IntelDLL NAME 'zsytrf';   // symmetric matrix factorisation

 // MATRIX INVERSION - need to call  'ssytrf' first
   PROCEDURE sgetri;  CDecl;   EXTERNAL IntelDLL NAME 'sgetri';   // symmetric matrix inversion
   PROCEDURE dgetri;  CDecl;   EXTERNAL IntelDLL NAME 'dgetri';   // symmetric matrix inversion
   PROCEDURE cgetri;  CDecl;   EXTERNAL IntelDLL NAME 'cgetri';   // symmetric matrix inversion
   PROCEDURE zgetri;  CDecl;   EXTERNAL IntelDLL NAME 'zgetri';   // symmetric matrix inversion

   PROCEDURE ssytri;  CDecl;   EXTERNAL IntelDLL NAME 'ssytri';   // symmetric matrix inversion
   PROCEDURE dsytri;  CDecl;   EXTERNAL IntelDLL NAME 'dsytri';   // symmetric matrix inversion
   PROCEDURE csytri;  CDecl;   EXTERNAL IntelDLL NAME 'csytri';   // symmetric matrix inversion
   PROCEDURE zsytri;  CDecl;   EXTERNAL IntelDLL NAME 'zsytri';   // symmetric matrix inversion
 }


INITIALIZATION
  DLLHandle1 := LoadLibrary(IntelDLL);
  IF   DLLHandle1 = 0
  THEN MessageDlg('Error Loading ' + IntelDLL + #$0D + '(Error Code ' +
                  IntToHex(GetLastError,8) + ')', mtError, [mbOK], 0) ;

//  DLLHandle2 := DLLHandle1 ;  // new
  DLLHandle2 := LoadLibrary(IntelDLL_LAPACK);
  IF   DLLHandle2 = 0
  THEN MessageDlg('Error Loading ' + IntelDLL_LAPACK + #$0D + '(Error Code ' +
                  IntToHex(GetLastError,8) + ')', mtError, [mbOK], 0) ; 

FINALIZATION
  IF   NOT FreeLibrary(DLLHandle1)
  THEN MessageDlg('Error Freeing ' + IntelDLL + #$0D + '(Error Code ' +
                  IntToHex(GetLastError,8) + ')', mtError, [mbOK], 0) ;

  IF   NOT FreeLibrary(DLLHandle2)
  THEN MessageDlg('Error Freeing ' + IntelDLL + #$0D + '(Error Code ' +
                  IntToHex(GetLastError,8) + ')', mtError, [mbOK], 0)  ;
END.
