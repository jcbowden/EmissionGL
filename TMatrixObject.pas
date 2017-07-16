unit TMatrixObject;

//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}

interface

uses  classes, dialogs, SysUtils, Math, TMaxMinObject, BLASLAPACKfreePas, TASMTimerUnit  ;


type RowsOrCols = (Rows, Cols);

type
  TMatrix  = class
  public
    numRows : integer ; // the number of Y data values... Used for .MAP files
    numCols : integer ;
    SDPrec : integer ;   // single or double precision data storage - size in bytes
    complexMat : integer ; // if = 1 then not complexs if = 2 then complex (i.e interleaved)

    meanCentred, colStandardized : boolean ;
    Filename : String ;
    startLine : integer ;  // used to store where in file the data starts - useful when reloading when precision is changed
    F_Mdata, F_MAverage, F_MStdDev, F_MVariance : TMemoryStream ;
    Fcols, Frows : TMemoryStream ;  // these are to store list of integers for columns or rows wanted when copying or saving data from F_Mdata

    constructor Create(singleOrDouble : integer) ;
    constructor Create2(singleOrDouble, numRowsIn, numColsIn : integer) ; // this constructor sets size of 'F_Mdata' data matrix
    destructor  Destroy;  // found in implementation part below
    procedure   CopyMatrix(sourceMat : TMatrix) ;  // Copies complete TMatrix from the sourceMat to self.
    procedure   MakeComplex( imaginaryPartMatrixAmagalmated : TMatrix) ;  // makes Re Im pairs from own data and input matix (interlaces)
    procedure   MakeUnComplex( imaginaryPartMatrixSeparated   : TMatrix) ;// seperates Im data from Re data and places Im in the input matix (de-interlaces)
    procedure   Free ;

    procedure Transpose ;
    procedure Zero(tstr : TMemoryStream) ;
    procedure MeanCentre ;                        // subtracts Average of column from each spectra/row
    procedure ColStandardize ;
    procedure Average ;                           // places average of each column into MAverage TMemoryStream
    procedure AverageSmooth(numPoints : integer) ;
    function  AverageReduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
    function  Reduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;
    procedure Variance ;
    procedure Stddev ;
    procedure ClearData(singleOrDouble : integer) ;

    // basic maths functions
    procedure MultiplyByScalar(inputScalar : single) ;
    procedure DivideByScalar(inputScalar : single)   ;
    procedure AddScalar(inputScalar : single) ;
    // maths point by point functions
    procedure AddOrSubtractMatrix(M2 : TMatrix; plusminus : integer)  ;  //  each point of original matrix +- M1 points
    // maths vector functions
    function AddVectToMatrixRows(memStrIn  :  TMemoryStream) : integer ;  // adds the data in memStrIn to each row of the matrix - used to add back mean to mean centred data
    procedure MultiplyMatrixByVect(memStrIn :  TMemoryStream) ;  // adds the data in memStrIn to each row of the matrix - used to "scale" by variance
    // returns 1 on EZeroDivide error, otherwise 0
    function DivideMatrixByVect(memStrIn :  TMemoryStream) : integer ;  // divides each row of matrix by corresponding column in memStrIn - used to "un-variance scale"

    function  LoadMatrixDataFromTxtFile(filenameIn : string ;startLineIn, endLineIn, startColIn, endColIn: integer; inDelimeter : string) :  boolean  ;  //  rowOrCol = true if in rows rowOrCol = false if in cols
    function  DetermineDelimiter(inString : string; inDelimeter : string) : string  ;
    procedure SaveMatrixDataTxt(filenameOut : string; delimeter : string) ;  // save as text file - data in rows (not excel friendly)

    // binary file load/save procedures
    procedure LoadMatrixDataFromBinFile(filenameIn : string) ;  // load from binary file  - assumed format : <DATA><rowNum><colNum><SDPrec><meanCentred><colStandardized>
    procedure LoadMatrixDataRawBinFile(filenameIn : string) ;   // only loads F_data, other fields are as they were (empty or previous value) therefore need to set them.
    procedure SaveMatrixDataBin(filenameOut : string) ;  // save as binary file with  <DATA><rowNum><colNum><SDPrec><meanCentred><colStandardized> at end
    procedure SaveMatrixDataRaw(filenameOut : string) ;  // only saves F_data
    procedure ReverseByteOrder ;


    procedure FetchDataFromTMatrix(rowRange, colRange : string; sourceMatrix : TMatrix) ; // places data into self - emptys self first
    procedure FetchDataFromTFileStream(rowRange, colRange : string;  numColsIn : integer;  sourceFileStrm : TFileStream) ;

    // GetTotalRowsColsFromString is a helper for  FetchDataFromTMatrix() function, returns number of rows or cols in 'range' and places values-1 in
    // rowcolList for access to memory
    // i.e. From a string range (eg '3-7,9-24') get total number of rows and place the row numbers
    // in a (zero based) vector (rowcolList MemoryStream) also returns total number of numbers in the range specified
    function  GetTotalRowsColsFromString(range :string; rowcolList : TMemoryStream) : integer ;  overload ;// rowcolList Stream is filled with zero based list of column/row numbers
    function  GetTotalRowsColsFromString(range :string) : integer ; overload ;// rowcolList Stream is filled with zero based list of column/row numbers

    function  CreateStringFromRowColStream(rowcolList : TMemoryStream) : string ;// does oppisite of GetTotalRowsColsFromString() - i.e. from MemStream of integers, create range i.e. "3,6-12,30"
    function  CheckRangeInput(rangeIn : String) : boolean ; // Input error detecting helper function for GetTotalRowsColsFromString()
    procedure AddRowToEndOfData(sourceMat : TMatrix; rowNumIn, numColIn : integer ) ;
    procedure AddRowsToMatrix(sourceMat : TMatrix; startRowIn, numRowsIn : integer ) ;  // numCols has to match in Source and Recieving TMatrix ;
    procedure AddColToEndOfData(var dataCol : TMemoryStream; numRowIn : integer ) ;
    // adds columns to a TMatrix from sourceMatrix, uses FetchDataFromTMatrix and AddColToEndOfData
    procedure AddColumnsToMatrix(rowRange, colRange : string; sourceMatrix : TMatrix) ;

    function  MovePointer(tp : pointer; amount : integer ) : pointer ;
    // returns the numerical contents of input as 5.4 float format 'delimeter' delimeted string
    // Used to add Average, Stddev and Variance to end of a text output data file
    function  CreateStringFromVector(memStrIn :  TMemoryStream; offsetBytes, inputNumCols : integer; delimeter : string) : string ;
    procedure CopyUpperToLower ;  // copies upper trianglar part of matrix to lower riangular part
    function  GetDiagonal(inputMat : TMatrix) : TMemoryStream ;  // returns the diagonal elements of a square matrix
    procedure  SetDiagonal(inputStr : TMemoryStream)  ;  // Sets the diagonal elements of itself to values in inputStr
    function  GetMinAndMaxValAndPos(row, col : integer ) : TMaxMin ;  // row = 0 means each row on specified column and col = 0 means each col on specified row

    function  GetSlope : single ;
    function  GetSlopeForcedThroughZero : single ;
    function  GetYIntercept(slope : single) : Single ;

    procedure VectSubProjectedFromMatrix(inputMatrix, eVectsIn : TMatrix )  ;
  private
    procedure AverageSSE ;
    procedure WriteError(inputStr : string ) ;
end;




implementation


uses TMatrixOperations ;



//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// TMatrix implementation ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

function TMatrix.MovePointer(tp : pointer; amount : integer ) : pointer;
begin
{$ifdef FREEPASCAL}
asm
   movq     tp, %rax
   movq     amount, %rdx
   addq     %rdx, %rax
   movq     %rax, Result
end;
{$else}
   asm
   MOV     EAX,tp
   MOV     EDX,amount
   ADD     EAX,EDX
   MOV     @Result,EAX
   end;
{$endif}


end ;



constructor TMatrix.Create(singleOrDouble : integer);
begin
//  inherited Create;
  if singleOrDouble = 1 then singleOrDouble := 4 ;
  if singleOrDouble = 2 then singleOrDouble := 8 ;

  SDPrec := singleOrDouble  ;  // = 4 for singgle and 8 for double
  complexMat := 1 ;

  F_Mdata := TMemoryStream.Create;
//  writeln(integer(F_Mdata.Memory) mod 16) ;
  F_MAverage  := TMemoryStream.Create;
  F_MVariance  := TMemoryStream.Create;
  F_MStdDev  := TMemoryStream.Create;
  Fcols :=  TMemoryStream.Create;
  Frows :=  TMemoryStream.Create;

  meanCentred := false ;
  colStandardized  := false ;
  numRows := 0;
  numCols := 0;
end;

constructor TMatrix.Create2(singleOrDouble, numRowsIn, numColsIn : integer) ;
// this constructor sets size of 'F_Mdata' data matrix
begin
//  inherited Create;
  if singleOrDouble = 1 then singleOrDouble := 4 ;
  if singleOrDouble = 2 then singleOrDouble := 8 ;

  SDPrec := singleOrDouble ;
  complexMat := 1 ;

  F_Mdata := TMemoryStream.Create;
  F_Mdata.SetSize(numRowsIn* numColsIn * SDPrec) ;
  F_MAverage  := TMemoryStream.Create;
  F_MVariance  := TMemoryStream.Create;
  F_MStdDev  := TMemoryStream.Create;
  Fcols :=  TMemoryStream.Create;
  Frows :=  TMemoryStream.Create;

  meanCentred := false ;
  colStandardized  := false ;
  numRows := numRowsIn;
  numCols := numColsIn;
end;


destructor TMatrix.Destroy;
begin
  F_Mdata.free ;
  F_MAverage.free ;
  F_MVariance.free ;
  F_MStdDev.free ;
  Fcols.free;
  Frows.free;
end;

procedure TMatrix.Free;
begin
 if Self <> nil then Destroy;
end;


procedure TMatrix.WriteError(inputStr : string ) ;
begin
//{$define cmdline=1}

{$ifdef cmdline}
   Writeln(inputStrt) ;
{$else}
   messagedlg(inputStr+filename,mtError,[mbOk],0) ;
{$endif}

 end;


procedure TMatrix.ClearData(singleOrDouble : integer) ;  // = 4 for single, 8 for double
begin
  if singleOrDouble = 1 then singleOrDouble := 4 ;
  if singleOrDouble = 2 then singleOrDouble := 8 ;

  SDPrec := singleOrDouble ;
  complexMat := 1 ;

  F_Mdata.Clear;    // clear TMemoryStreams

  F_MAverage.Clear; // clear TMemoryStreams
  F_MVariance.Clear;// clear TMemoryStreams
  F_MStdDev.Clear;  // clear TMemoryStreams

  // These are only used by the X and Y data matricies to store indicies of rows and columns
  // of original matrix where data was obtained
  Fcols.Clear;      // clear TMemoryStreams
  Frows.Clear;      // clear TMemoryStreams

  meanCentred := false ;
  colStandardized  := false ;
  numRows := 0;
  numCols := 0;
end;

procedure TMatrix.CopyMatrix(sourceMat : TMatrix) ;
begin
   self.ClearData(self.SDPrec) ;

   self.SDPrec            := sourceMat.SDPrec ; // single or double precision
   self.complexMat        := sourceMat.complexMat ;
   self.numRows           := sourceMat.numRows ;
   self.numCols           := sourceMat.numCols ;
   self.meanCentred       := sourceMat.meanCentred  ;
   self.colStandardized   := sourceMat.colStandardized ;
   self.Filename          := sourceMat.Filename  ;
   self.startLine         := sourceMat.startLine  ;

   self.F_Mdata.SetSize(sourceMat.F_Mdata.Size ) ;  // probably not needed

   self.F_Mdata.Seek(0, soFromBeginning) ;
   self.F_MAverage.Seek(0, soFromBeginning) ;
   self.F_MVariance.Seek(0, soFromBeginning) ;
   self.F_MStdDev.Seek(0, soFromBeginning) ;

   self.F_Mdata.CopyFrom(sourceMat.F_Mdata, 0) ;
   self.F_MAverage.CopyFrom(sourceMat.F_MAverage, 0) ;
   self.F_MVariance.CopyFrom(sourceMat.F_MVariance, 0) ;
   self.F_MStdDev.CopyFrom(sourceMat.F_MStdDev, 0) ;
end ;




procedure   TMatrix.MakeComplex( imaginaryPartMatrixAmagalmated : TMatrix) ;  // makes Re Im pairs from own data and input matix (interlaces)
var
  t1 : integer ;
  tMemStr : TMemoryStream ;
  s1 : single ;
  d1 : double ;
begin

  if self.F_Mdata.Size <>  imaginaryPartMatrixAmagalmated.F_Mdata.Size then
  begin
     WriteError('TMatrix.MakeComplex() Error: Real and Imginary matrix size does not match. Have to exit') ;
     exit ;
  end ;

  if complexMat = 1 then
  begin
    self.F_Mdata.Seek(0,soFromBeginning) ;
    imaginaryPartMatrixAmagalmated.F_Mdata.Seek(0,soFromBeginning) ;

    tMemStr := TMemoryStream.Create ;
    tMemStr.SetSize(self.numRows*self.numCols*self.SDPrec*2) ;

    if SDPrec = 4 then
    begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(s1,4) ;
        tMemStr.Write(s1,4) ;
        imaginaryPartMatrixAmagalmated.F_Mdata.Read(s1,4) ;
        tMemStr.Write(s1,4) ;
      end
    end
    else
    if SDPrec = 8 then
    begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(d1,8) ;
        tMemStr.Write(d1,8) ;
        imaginaryPartMatrixAmagalmated.F_Mdata.Read(d1,8) ;
        tMemStr.Write(d1,8) ;
      end
    end ;

    // copy interlaced complex data
    self.F_Mdata.Seek(0,soFromBeginning) ;
    imaginaryPartMatrixAmagalmated.F_Mdata.Seek(0,soFromBeginning) ;
    tMemStr.Seek(0,soFromBeginning) ;
    self.F_Mdata.Clear ;
    self.F_Mdata.LoadFromStream(tMemStr) ;
    tMemStr.Free ;

    complexMat := 2 ;
  end ;

end ;



procedure   TMatrix.MakeUnComplex( imaginaryPartMatrixSeparated   : TMatrix) ;// seperates Im data from Re data and places Im in the input matix (de-interlaces)
var
  t1 : integer ;
  tMemStr : TMemoryStream ;
  s1 : TSingle ;
  d1 : TDouble ;
begin

  if complexMat = 2 then
  begin
    self.F_Mdata.Seek(0,soFromBeginning) ;
    imaginaryPartMatrixSeparated.F_Mdata.Seek(0,soFromBeginning) ;

    tMemStr := TMemoryStream.Create ;
    tMemStr.SetSize(self.numRows*self.numCols*self.SDPrec*2) ;

    if SDPrec = 4 then
    begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(s1,8) ;
        tMemStr.Write(s1[1],4) ;
        imaginaryPartMatrixSeparated.F_Mdata.Write(s1[2],4) ;
      end
    end
    else
    if SDPrec = 8 then
    begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(d1,16) ;
        tMemStr.Write(d1[1],8) ;
        imaginaryPartMatrixSeparated.F_Mdata.Write(d1[2],8) ;
      end
    end ;

    // copy interlaced complex data
    self.F_Mdata.Seek(0,soFromBeginning) ;
    imaginaryPartMatrixSeparated.F_Mdata.Seek(0,soFromBeginning) ;
    tMemStr.Seek(0,soFromBeginning) ;
    self.F_Mdata.Clear ;
    self.F_Mdata.LoadFromStream(tMemStr) ;
    tMemStr.Free ;

    complexMat := 1 ;
  end ;
end ;



procedure TMatrix.ReverseByteOrder ;
var
  t1 : integer ;
  b1, b2, b3, b4, bswap : byte ;
begin
  self.F_Mdata.Seek(0,soFromBeginning) ;
  for t1 := 1 to self.F_Mdata.Size div 4  do
  begin
      self.F_Mdata.Read(b1,1) ;
      self.F_Mdata.Read(b2,1) ;
      self.F_Mdata.Read(b3,1) ;
      self.F_Mdata.Read(b4,1) ;
      bswap := b1 ;
      b1 := b4 ;
      b4 := bswap ;
      bswap := b2 ;
      b2 := b3 ;
      b3 := bswap ;
      self.F_Mdata.Seek(-4,soFromCurrent) ;
      self.F_Mdata.Write(b1,1) ;
      self.F_Mdata.Write(b2,1) ;
      self.F_Mdata.Write(b3,1) ;
      self.F_Mdata.Write(b4,1) ;
  end ;
  self.F_Mdata.Seek(0,soFromBeginning) ;
end ;




procedure TMatrix.Zero(tstr : TMemoryStream) ;
Var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
    s1 := 0.0 ;
    d1 := 0.0 ;
    tstr.Seek(0,soFromBeginning) ;

    if SDPrec = 4 then
     begin
       for t1 := 1 to (tstr.Size div 4)  do
       begin
         tstr.Write(s1,4) ;
         if self.complexMat = 2 then
            tstr.Write(s1,4) ;
       end ;
     end
     else  //  SDPrec = 8
     begin
       for t1 := 1 to (tstr.Size div 4)  do
       begin
         tstr.Write(d1,8) ;
         if self.complexMat = 2 then
            tstr.Write(d1,8) ;
       end ;
     end ;
    tstr.Seek(0,soFromBeginning) ;
end ;



procedure TMatrix.AverageSSE ;
var
   t1, t2, t3 : integer ;
   pdata, pave : pointer ;
   s1 : single ;
   d1 : double ;
//   tTimer : TASMTimer ;
begin

/// tTimer := TASMTimer.Create(0) ;
// tTimer.setTimeDifSecUpdateT1 ;
  F_Mdata.Seek(0,soFromBeginning) ;
  pdata := F_Mdata.memory ;
  if SDPrec = 4 then   // single precision
  begin
    t2 := ((numCols * complexmat) div 4) ;
    t3 := ((numCols * complexmat) mod 4) ;  // the remainer after the above
   for t1 := 1 to numRows do
   begin
     F_MAverage.Seek(0,soFromBeginning) ;
     pave := F_MAverage.memory ;

     if t3 = 0 then
     begin
     if t2 > 0 then
     begin
     asm
       push esi
       push edi
       MOV edi, pdata
       mov esi, pave
       mov ecx, t2   {this is the loop counter}
       @loop:
       movaps xmm1, [edi]
       movaps xmm0, [esi]
       addps   xmm0, xmm1
       movaps [esi],xmm0
       add edi, 16
       add esi, 16
       dec ecx
       jnz @loop

       MOV pdata, edi   // store latest data pointer area
       pop edi
       pop esi
     end;
     end ;
     end
     else  // t3 <> 0
// this looks after data where each row is not aligned on 16 byte increment
     begin
     if t2 > 0 then
     begin
     asm
       push esi
       push edi
       MOV edi, pdata
       mov esi, pave
       mov ecx, t2   {this is the loop counter}
       @loop:
       movups xmm1, [edi]
       movups xmm0, [esi]
       addps   xmm0, xmm1
       movups [esi],xmm0
       add edi, 16
       add esi, 16
       dec ecx
       jnz @loop

       MOV pdata, edi   // store latest data pointer area
       MOV pave, esi
       pop edi
       pop esi
     end;
     end;
     asm // this looks after scraggly end bits if numCols is not perfectly divisible by 4
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t3   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 4
       add esi, 4
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;
     end;
    end;   // numRows
    // t2 = 0
    { F_Mdata.Seek((t2*4*SDPrec), soFromBeginning) ;
     F_MAverage.Seek((t2*4*SDPrec), soFromBeginning) ;
      for t3 := 1 to (numCols -(t2*4)) do    // this is changed between single (4) and double (2)
      // this looks after scraggly end bits if numCols is not perfectly divisible by 4
      // did not work with SSE code as did not update the pdata pointer
      begin
        F_Mdata.Read(s1,SDPrec) ;
        F_MAverage.Read(s2,SDPrec) ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        s1 := s1 + s2 ;
        F_MAverage.Write(s1,SDPrec) ;
       end ;
     end;  // t1 := 1 to numRows   }

// this does the division by the number of samples to get the average
    s1 := 1 / numRows ;
    t2 := (numCols * complexmat) ;
    pave := F_MAverage.memory ;
    // Multiply all average data by 1/numRows
    asm
       push esi
       mov esi, pave
       mov ecx, t2   // this is the loop counter
       @loop:
       fld [esi]
       FMUL s1
       FSTP [esi]    // FSTP = store and pop stack
       add esi, 4
       dec ecx
       jnz @loop
       pop esi
     end;

     F_MAverage.Seek(0,soFromBeginning) ;
     F_MAverage.Read(s1, SDPrec) ;

{     s1 := 1 / numRows ;
     F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
     for t2 := 1 to (numCols * complexmat) do
     begin
        F_MAverage.Read(s2,SDPrec) ;
        s2 := s2 * s1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(s2,SDPrec) ;
     end ; }


   end
   else
   if SDPrec = 8 then   // double precision
   begin
    t2 := ((numCols * complexmat) div 2) ;
    t3 := ((numCols * complexmat) mod 2) ;  // the remainer after the above
   for t1 := 1 to numRows do
   begin
     F_MAverage.Seek(0,soFromBeginning) ;
     pave := F_MAverage.memory ;

     if t3 = 0 then
     begin
     if t2 > 0 then
     begin
     asm
       push esi
       push edi
       MOV edi, pdata
       mov esi, pave
       mov ecx, t2   {this is the loop counter}
       @loop:
       movapd  xmm1, [edi] // these are the fastest instructions
       movapd  xmm0, [esi]
       addpd   xmm0, xmm1
       movapd  [esi],xmm0
       add edi, 16
       add esi, 16
       dec ecx
       jnz @loop

       MOV pdata, edi   // store latest data pointer area
       pop edi
       pop esi
     end;
     end ;
     end
     else  // t3 <> 0
// this looks after data where each row is not aligned on 16 byte increment
     begin
     if t2 > 0 then
     begin
     asm
       push esi
       push edi
       MOV edi, pdata
       mov esi, pave
       mov ecx, t2   {this is the loop counter}
       @loop:
       movupd  xmm1, [edi]
       movupd  xmm0, [esi]
       addpd   xmm0, xmm1
       movupd  [esi],xmm0
       add edi, 16
       add esi, 16
       dec ecx
       jnz @loop

       MOV pdata, edi   // store latest data pointer area
       MOV pave, esi
       pop edi
       pop esi
     end;
     end;
     asm    // this looks after scraggly end bits if numCols is not perfectly divisible by 2
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t3   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 8
       add esi, 8
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;
     end;
    end;   // numRows

    d1 := 1 / numRows ;
    pave := F_MAverage.memory ;
    t2 := (numCols * complexmat) ;
    asm
       push esi
       mov esi, pave
       mov ecx, t2   // this is the loop counter
    @loop:
       fld [esi]
       FMUL d1
       FSTP [esi]    // FSTP = store and pop stack
       add esi, 8
       dec ecx
    jnz @loop
       pop esi
     end;
   {  F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
     for t2 := 1 to (numCols * complexmat) do
     begin
        F_MAverage.Read(d2,SDPrec) ;
        d2 := d2 * d1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(d2,SDPrec) ;
     end ;   }

   end  ; // if SDPrec = 8 then

end ;





// calculates per point average down columns and places result in F_MAverage MemoryStream
procedure TMatrix.Average() ;      // can **not** deal with complex
var
   t1, t2, t3 : integer ;
   pave, pdata : pointer ;
   s1, s2 : single ;
   d1, d2 : double ;
   tTimer : TASMTimer ;
   matS1, matS2 : Array[0..3] of single ;
   matD1, matD2 : Array[0..3] of double ;
begin

{ 2nd attempt at speeding up - maybe 5% better

  F_MAverage.SetSize(numCols * SDPrec * complexmat) ;
  Zero(F_MAverage) ;
  F_Mdata.Seek(0,soFromBeginning) ;
  if SDPrec = 4 then   // single precision
  begin
   for t1 := 1 to numRows do
   begin
     F_MAverage.Seek(0,soFromBeginning) ;
     for t2 := 1 to (numCols * complexmat) do
     begin
        F_Mdata.Read(s1,SDPrec) ;
        F_MAverage.Read(s2,SDPrec) ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        s1 := s1 + s2 ;
        F_MAverage.Write(s1,SDPrec) ;
     end ;
     
   end ;

   s1 := 1 / numRows ;
   F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
   for t2 := 1 to (numCols * complexmat) do
   begin
        F_MAverage.Read(s2,SDPrec) ;
        s2 := s2 * s1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(s2,SDPrec) ;
   end ;
   end
   
   else
   if SDPrec = 8 then   // double precision
   begin
     for t1 := 1 to numRows do
     begin
       F_MAverage.Seek(0,soFromBeginning) ;
       for t2 := 1 to (numCols * complexMat) do
       begin
        F_Mdata.Read(d1,SDPrec) ;
        F_MAverage.Read(d2,SDPrec) ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        d1 := d1 + d2 ;
        F_MAverage.Write(s1,SDPrec) ;
       end ;
     end ;

     d1 := 1 / numRows ;
     F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
     for t2 := 1 to (numCols * complexMat) do
     begin
        F_MAverage.Read(d2,SDPrec) ;
        d2 := d2 * d1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(d2,SDPrec) ;
     end ;
   end ;       }


// single precission original code
// twice as fast as original code
F_MAverage.SetSize(numCols * SDPrec * complexmat) ;
Zero(F_MAverage) ;

t3 := (integer(F_Mdata.Memory) mod 16) ;
t3 :=  t3 +  (integer(F_Mdata.Memory) mod 16) ;
if t3 <> 0 then
begin

tTimer := TASMTimer.Create(0) ;
tTimer.setTimeDifSecUpdateT1 ;

  F_Mdata.Seek(0,soFromBeginning) ;
  F_MAverage.Seek(0,soFromBeginning) ;
  pave   := F_MAverage.memory ;
  pdata  := F_Mdata.memory ;
  if SDPrec = 4 then   // single precision
  begin
   for t1 := 1 to numRows do
   begin

     t2 := (numCols * complexmat)  ;  //
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 4
       add esi, 4
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;
{      pave   := F_MAverage.memory ;
     t2 := ((numCols * complexmat) div 4) ;
     // this looks after the bulk of the data row
     if t2 > 0 then
     begin
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       fld [esi+4]
       fld [esi+8]
       fld [esi+12]
       FADD [edi+12]
       FSTP [edi+12]
       FADD [edi+8]
       FSTP [edi+8]
       FADD [edi+4]
       FSTP [edi+4]
       FADD [edi]
       FSTP [edi]
       add edi, 16
       add esi, 16
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       mov pave, edi   // update pdata with current position
       pop edi
       pop esi
      end;
      end ; // t2 <> 0
      t2 := ((numCols * complexmat) mod 4) ;  // the remainer after the above
     // this looks after scraggly end bits if numCols is not perfectly divisible by 4
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 4
       add esi, 4
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;       }

   end ;  // end row

   s1 := 1 / numRows ;
   F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
   for t2 := 1 to (numCols * complexmat) do
   begin
        F_MAverage.Read(s2,SDPrec) ;
        s2 := s2 * s1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(s2,SDPrec) ;
   end ;
  end
  else
  if SDPrec = 8 then   // double precision
  begin
   for t1 := 1 to numRows do
   begin
//     F_MAverage.Seek(0,soFromBeginning) ;
     pave   := F_MAverage.memory ;
     t2 := (numCols * complexmat)  ;  //
     // this looks after scraggly end bits if numCols is not perfectly divisible by 4
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 8
       add esi, 8
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;
{     t2 := ((numCols * complexmat) div 4) ;
     // this looks after the bulk of the data row
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       fld [esi+8]
       fld [esi+16]
       fld [esi+24]
       FADD [edi+24]
       FSTP [edi+24]
       FADD [edi+16]
       FSTP [edi+16]
       FADD [edi+8]
       FSTP [edi+8]
       FADD [edi]
       FSTP [edi]
       add edi, 32
       add esi, 32
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       mov pave, edi   // update pdata with current position
       pop edi
       pop esi
      end;

      t2 := ((numCols * complexmat) mod 4) ;  // the remainer after the above
     // this looks after scraggly end bits if numCols is not perfectly divisible by 4
     asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
     @loop:
       fld [esi]
       FADD [edi]
       FSTP [edi]
       add edi, 8
       add esi, 8
       dec ecx
     jnz @loop
       mov pdata, esi   // update pdata with current position
       pop edi
       pop esi
      end;      }

   end ;  // end row

   d1 := 1 / numRows ;
   F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
   for t2 := 1 to (numCols * complexmat) do
   begin
        F_MAverage.Read(d2,SDPrec) ;
        d2 := d2 * d1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(d2,SDPrec) ;
   end ;
  end ; // SDPrec = 8

tTimer.setTimeDifSecUpdateT1 ;
tTimer.outputTimeSec('Average FPU time: ');

end
else  // data is 16 byte aligned => do SSE instructions
begin
tTimer := TASMTimer.Create(0) ;
tTimer.setTimeDifSecUpdateT1 ;
   AverageSSE() ;
tTimer.setTimeDifSecUpdateT1 ;
tTimer.outputTimeSec('AverageSSE time: ');
end;

tTimer.Free ;

end ;

procedure TMatrix.AverageSmooth(numPoints : integer)  ;
var
  t1, t2, t3, t4 : integer ;
  s1 : single ;
  d1 : double ;
  bufSize : integer ;
  streamBuf : TMemoryStream ;
  average_d : double ;
  p1 : pointer ;
begin

if ((numPoints / 2) - (numPoints div 2)) > 0.0 then  // check that numPoints is uneven number
begin
try
  streamBuf:= TMemoryStream.Create ;  // buffer to temporalily store results
  streamBuf.SetSize(self.numCols*self.SDPrec) ;
  GetMem(p1,self.SDPrec) ;

  for t1 := 1 to self.numRows do // for each row of data
  begin
    self.F_Mdata.Seek((t1-1)*self.numCols*self.SDPrec,soFromBeginning) ;
    streamBuf.Seek(0,soFromBeginning) ;
    // for first points
    for t2 := 1 to (numPoints div 2) do
    begin
      average_d := 0.0 ;
      for t3 := 1 to ((numPoints div 2) + t2) do
      begin
         self.F_Mdata.Read(p1^,4) ;
         if self.SDPrec = 4 then
           average_d := average_d + single(p1^)
         else
           average_d := average_d + double(p1^) ;
      end ;
      self.F_Mdata.Seek(-((numPoints div 2) + t2)*self.SDPrec,soFromCurrent) ;
      average_d := average_d / ((numPoints div 2) + t2) ;
      if  self.SDPrec = 4 then
      begin
        s1 := average_d ;
        streamBuf.Write(s1,4) ;
      end
      else
        streamBuf.Write(average_d,8) ;
    end ;

    // for central points (main part of data)
    for t2 := (numPoints div 2)+1 to (self.numCols - (numPoints div 2)) do
    begin
      average_d := 0.0 ;
      for t3 := 1 to numPoints  do
      begin
         self.F_Mdata.Read(p1^,self.SDPrec) ;
          if self.SDPrec = 4 then
           average_d := average_d + single(p1^)
         else
           average_d := average_d + double(p1^) ;
      end ;
      self.F_Mdata.Seek(-(numPoints-1)*self.SDPrec,soFromCurrent) ;
      average_d := average_d / numPoints  ;
      if  self.SDPrec = 4 then
      begin
        s1 := average_d ;
        streamBuf.Write(s1,4) ;
      end
      else
        streamBuf.Write(average_d,8) ;
    end ;

    // for final few points
    t4 := 1 ;
    for t2 :=  (self.numCols - (numPoints div 2) + 1) to self.numCols  do
    begin
      average_d := 0.0 ;
      for t3 := (numPoints - t4) downto 1  do
      begin
         self.F_Mdata.Read(p1^,self.SDPrec) ;
          if self.SDPrec = 4 then
           average_d := average_d + single(p1^)
         else
           average_d := average_d + double(p1^) ;
      end ;
      self.F_Mdata.Seek(-(numPoints - (t4+1))*self.SDPrec,soFromCurrent) ;
      average_d := average_d / (numPoints - t4)  ;
      if  self.SDPrec = 4 then
      begin
        s1 := average_d ;
        streamBuf.Write(s1,4) ;
      end
      else
        streamBuf.Write(average_d,8) ;
      inc(t4) ;
    end ;

    streamBuf.Seek(0,soFromBeginning) ;
    self.F_Mdata.Seek((t1-1)*self.numCols*self.SDPrec,soFromBeginning) ;

    for t2 := 0 to self.numCols -1do
    begin
       if SDPrec = 4 then
       begin
        streamBuf.Read(s1,self.SDPrec) ;
        self.F_Mdata.Write(s1,self.SDPrec) ;
       end
       else
       begin
         streamBuf.Read(d1,self.SDPrec) ;
         self.F_Mdata.Write(d1,self.SDPrec) ;
       end ;
    end ;

  end ; // for each row

finally
  streamBuf.free ;
  FreeMem(p1) ;
end ;
end
else
  WriteError('TMatrix.AverageSmooth Error: number of points to use has to be an odd number') ;

end ;


procedure TMatrix.DivideByScalar(inputScalar : single) ;    // does not divide complexs scalars
var
 t1 : integer  ;
 s1 : single ;
 d1 : double ;
begin
  if inputScalar <> 0 then
  begin
     self.F_Mdata.Seek(0,soFromBeginning) ;
     if SDPrec = 4 then
     begin
       for t1 := 1 to (self.numRows * self.numCols * self.complexMat) do
       begin
         self.F_Mdata.Read(s1,4) ;
         self.F_Mdata.Seek(-4,soFromCurrent) ;
         s1 := s1 / inputScalar  ;
         self.F_Mdata.Write(s1,4) ;
       end ;
     end
     else  //  SDPrec = 8
     begin
       for t1 := 1 to self.numRows * self.numCols * self.complexMat do
       begin
         self.F_Mdata.Read(d1,8) ;
         self.F_Mdata.Seek(-8,soFromCurrent) ;
         d1 := d1 / inputScalar  ;
         self.F_Mdata.Write(d1,8) ;
       end
     end ;
     self.F_Mdata.Seek(0,soFromBeginning) ;
  end ;
end ;

procedure TMatrix.MultiplyByScalar(inputScalar : single) ;  // does not multiply complexs scalars
var          // could use BLAS 1 _axpy() function
 t1 : integer  ;
 s1 : single ;
 d1 : double ;
begin
  try
     self.F_Mdata.Seek(0,soFromBeginning) ;
     if SDPrec = 4 then
     begin
       for t1 := 1 to self.numRows * self.numCols do
       begin
         self.F_Mdata.Read(s1,4) ;
         self.F_Mdata.Seek(-4,soFromCurrent) ;
         s1 := s1 * inputScalar  ;
         self.F_Mdata.Write(s1,4) ;
       end ;
     end
     else  //  SDPrec = 8
     begin
       for t1 := 1 to self.numRows * self.numCols  do
       begin
         self.F_Mdata.Read(d1,8) ;
         self.F_Mdata.Seek(-8,soFromCurrent) ;
         d1 := d1 * inputScalar  ;
         self.F_Mdata.Write(d1,8) ;
       end ;
     end ;
  except on EOverFlow
  do
     WriteError('TMatrix.MultiplyByScalar() Error: Overflow error' ) ;
  end ;
  self.F_Mdata.Seek(0,soFromBeginning) ;

end ;

procedure TMatrix.AddScalar(inputScalar : single) ;    // does not add complexs scalars
var
 t1 : integer  ;
 s1 : single ;
 d1 : double ;
begin
  try
     self.F_Mdata.Seek(0,soFromBeginning) ;
     if SDPrec = 4 then
     begin
       for t1 := 1 to self.numRows * self.numCols  do
       begin
         self.F_Mdata.Read(s1,4) ;
         self.F_Mdata.Seek(-4,soFromCurrent) ;
         s1 := s1 + inputScalar  ;
         self.F_Mdata.Write(s1,4) ;
         if self.complexMat = 2 then
            self.F_Mdata.Seek(4,soFromCurrent) ;
       end ;
     end
     else  //  SDPrec = 8
     begin
       for t1 := 1 to self.numRows * self.numCols  do
       begin
         self.F_Mdata.Read(d1,8) ;
         self.F_Mdata.Seek(-8,soFromCurrent) ;
         d1 := d1 + inputScalar  ;
         self.F_Mdata.Write(d1,8) ;
         if self.complexMat = 2 then
            self.F_Mdata.Seek(8,soFromCurrent) ;
       end ;
     end ;
  except on EOverFlow
  do
     WriteError('TMatrix.MultiplyByScalar() Error: Overflow error' ) ;
  end ;
  self.F_Mdata.Seek(0,soFromBeginning) ;
end ;


function TMatrix.AddVectToMatrixRows(memStrIn :  TMemoryStream) : integer ;
// adds the data in memStrIn to each row of the matrix - used to add back mean to mean centred data
// can deal with complex numbers    (only accepts real number, so skips imaginary part in the matrix)
// N.B. Adds in memStrIn from the current position in the memory stream
// memStrIn has to be same number of columns as the TMatrix
var

  t1, t2 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  initialPos : integer ;
begin
//  memStrIn.Seek(0, SoFromBeginning) ;
  self.F_Mdata.Seek(0, SoFromBeginning) ;
  initialPos :=  memStrIn.Position ;
  result := 0 ; // result is false

  // this has been modified from   ((numCols * self.complexMat) = (memStrIn.Size div SDPrec))
  if ((numCols * self.complexMat) <= (memStrIn.Size div SDPrec)) then
  begin

  if SDPrec = 4 then
  begin
  for t1 := 1 to self.numRows do
  begin
    for t2 := 1 to (self.numCols * self.complexMat) do
    begin
      self.F_Mdata.Read(s1,4) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      memStrIn.Read(s2,self.SDPrec) ;
      s1 := s1 + s2 ;
      self.F_Mdata.Write(s1,4) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
  end ;
  end
  else
  begin
  for t1 := 1 to self.numRows do
  begin
    for t2 := 1 to (self.numCols * self.complexMat)  do
    begin
      self.F_Mdata.Read(d1,8) ;
      self.F_Mdata.Seek(-8, soFromCurrent) ;
      memStrIn.Read(d2,self.SDPrec) ;
      d1 := d1 + d2 ;
      self.F_Mdata.Write(d1,8) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
  end ;
  end ;

  result := 1 ; // result is true
  end ;

end ;

procedure TMatrix.AddOrSubtractMatrix(M2 : TMatrix; plusminus : integer)  ;  //  each point of original matrix +- M1 points
var                                                                // cannot deal with complex numbers
  t1, t2 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  initialPos : integer ;
begin

  self.F_Mdata.Seek(0, SoFromBeginning) ;
  M2.F_Mdata.Seek(0, SoFromBeginning) ;

  if ((numRows * numCols ) = (M2.numRows * M2.numCols)) then
  begin

  if SDPrec = 4 then
  begin
    if plusminus > 0 then
    begin
    for t1 := 1 to (self.numRows * self.numCols) do
    begin
      self.F_Mdata.Read(s1,4) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      M2.F_Mdata.Read(s2,self.SDPrec) ;
      s1 := s1 + s2 ;
      self.F_Mdata.Write(s1,4) ;
    end ;
    end
    else
    if  plusminus < 0 then
    begin
    for t1 := 1 to (self.numRows * self.numCols) do
    begin
      self.F_Mdata.Read(s1,4) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      M2.F_Mdata.Read(s2,self.SDPrec) ;
      s1 := s1 - s2 ;
      self.F_Mdata.Write(s1,4) ;
    end ;
    end ;
  end
  else
  if SDPrec = 8 then
  begin
    if plusminus > 0 then
    begin
    for t1 := 1 to (self.numRows * self.numCols) do
    begin
      self.F_Mdata.Read(d1,self.SDPrec) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      M2.F_Mdata.Read(d2,self.SDPrec) ;
      d1 := d1 + d2 ;
      self.F_Mdata.Write(d1,self.SDPrec) ;
    end ;
    end
    else
    if  plusminus < 0 then
    begin
    for t1 := 1 to (self.numRows * self.numCols) do
    begin
      self.F_Mdata.Read(d1,self.SDPrec) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      M2.F_Mdata.Read(d2,self.SDPrec) ;
      d1 := d1 - d2 ;
      self.F_Mdata.Write(d1,4) ;
    end ;
    end ;
  end ;

  end
  else
  WriteError('TMatrix.AddOrSubtractMatrix Error: matricies not same size' ) ;


  self.F_Mdata.Seek(0, SoFromBeginning) ;
  M2.F_Mdata.Seek(0, SoFromBeginning) ;

end ;


function TMatrix.DivideMatrixByVect(memStrIn :  TMemoryStream) : integer ;  // adds the data in memStrIn to each row of the matrix - used to "Un-scale" by variance
// returns 1 on EZeroDivide error, otherwise 0
var                                                                // cannot deal with complex numbers
  t1, t2 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  initialPos : integer ;
begin
//  memStrIn.Seek(0, SoFromBeginning) ;
  self.F_Mdata.Seek(0, SoFromBeginning) ;
  initialPos :=  memStrIn.Position ;

  if ((numCols * self.complexMat) = (memStrIn.Size div SDPrec)) then
  begin
  try
    result := 0 ;
    if SDPrec = 4 then
    begin
    for t1 := 1 to self.numRows do
    begin
    for t2 := 1 to (self.numCols) do
    begin
      self.F_Mdata.Read(s1,4) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      memStrIn.Read(s2,self.SDPrec) ;
      s1 := s1 / s2 ;
      self.F_Mdata.Write(s1,4) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
    end ;
    end
    else
    begin
    for t1 := 1 to self.numRows do
    begin
    for t2 := 1 to (self.numCols)  do
    begin
      self.F_Mdata.Read(d1,8) ;
      self.F_Mdata.Seek(-8, soFromCurrent) ;
      memStrIn.Read(d2,self.SDPrec) ;
      d1 := d1 / d2 ;
      self.F_Mdata.Write(d1,8) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
    end ;
    end ;
  except on EZeroDivide do
  begin
    WriteError('EZeroDivide') ;
    result := 1 ;
  end ;
  end ;
  end ;

end ;


procedure TMatrix.MultiplyMatrixByVect(memStrIn :  TMemoryStream) ;  // multiplys the data in memStrIn to each row of the matrix - used to "scale" by variance
var                                                                // cannot deal with complex numbers
  t1, t2 : integer ;
  s1, s2 : single ;
  d1, d2 : double ;
  initialPos : integer ;
begin
//  memStrIn.Seek(0, SoFromBeginning) ;
  self.F_Mdata.Seek(0, SoFromBeginning) ;
  initialPos :=  memStrIn.Position ;

  if ((numCols * self.complexMat) = (memStrIn.Size div SDPrec)) then
  begin

  if SDPrec = 4 then
  begin
  for t1 := 1 to self.numRows do
  begin
    for t2 := 1 to (self.numCols) do
    begin
      self.F_Mdata.Read(s1,4) ;
      self.F_Mdata.Seek(-4, soFromCurrent) ;
      memStrIn.Read(s2,self.SDPrec) ;
      s1 := s1 * s2 ;
      self.F_Mdata.Write(s1,4) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
  end ;
  end
  else
  begin
  for t1 := 1 to self.numRows do
  begin
    for t2 := 1 to (self.numCols)  do
    begin
      self.F_Mdata.Read(d1,8) ;
      self.F_Mdata.Seek(-8, soFromCurrent) ;
      memStrIn.Read(d2,self.SDPrec) ;
      d1 := d1 * d2 ;
      self.F_Mdata.Write(d1,8) ;
    end ;
    memStrIn.Seek(initialPos, SoFromBeginning) ;
  end ;
  end ;

  end ;

end ;


// numColIn : is number of columns in sourceMatrix and should match number of columns in matrix being added to
procedure TMatrix.AddRowToEndOfData(sourceMat : TMatrix; rowNumIn, numColIn : integer ) ;
var
  oldsize : integer  ;
  t1 : integer ;
  p1 : pointer ;
begin
  GetMem(p1, self.SDPrec * self.complexMat) ;
  oldSize := self.F_Mdata.Size ;
  self.F_Mdata.SetSize(oldSize+(numColIn * self.SDPrec * self.complexMat)) ;
  self.F_Mdata.Seek(oldSize,soFromBeginning) ;
  sourceMat.F_Mdata.Seek((rowNumIn-1) * numColIn * sourceMat.SDPrec * sourceMat.complexMat,soFromBeginning) ;

  if numColIn = self.numCols then
  begin
    for t1 := 1 to numColIn  do
    begin
      sourceMat.F_Mdata.Read(p1^,self.SDPrec  * self.complexMat) ;
      self.F_Mdata.Write(p1^,self.SDPrec  * self.complexMat) ;
    end ;
    inc(self.numRows)  ;
  end
  else if self.numCols = 0 then
  begin
    if (self.numCols = 0) and (self.numRows = 0) then  // no data so far so just add it as a row
    begin
    for t1 := 0 to numColIn -1 do
    begin
      sourceMat.F_Mdata.Read(p1^,self.SDPrec  * self.complexMat) ;
      self.F_Mdata.Write(p1^,self.SDPrec  * self.complexMat) ;
    end ;
    self.numRows := 1 ;
    self.numCols := numColIn ;
    end ;
  end
  else
  begin
     WriteError('AddRowToEndOfData() Error: number of columns of input does not match number of columns of TMatrix being added to' ) ;
  end ;

  FreeMem(p1) ;
end ;


procedure TMatrix.AddRowsToMatrix(sourceMat : TMatrix; startRowIn, numRowsIn : integer ) ;
// Adds a number of rows to the calling TMatrix object
// numCols has to match in Source and Recieving TMatrix ;
var
  t1 : integer ;
  oldSize : integer ;
  s1 : single ;
  d1 : double ;

begin
   if self.numCols = sourceMat.numCols then
   begin
      oldSize := self.F_MData.Size ;

      sourceMat.F_Mdata.Seek((startRowIn-1)*sourceMat.numCols*sourceMat.SDPrec * sourceMat.complexMat,soFromBeginning) ;
      self.F_Mdata.SetSize(oldSize + (numRowsIn * sourceMat.numCols * sourceMat.SDPrec * sourceMat.complexMat)) ;
      self.F_Mdata.Seek(oldSize,soFromBeginning) ;
      if self.SDPrec = 4 then
      begin
        for t1 := 1 to (numRowsIn * numCols * sourceMat.complexMat) do
        begin
          sourceMat.F_Mdata.Read(s1,4) ; // copy from source matrix
          self.F_Mdata.Write(s1,4) ;     // to destination matrix
        end ;
      end
      else
      if self.SDPrec = 8 then
      begin
        for t1 := 1 to (numRowsIn * numCols * sourceMat.complexMat) do
        begin
          sourceMat.F_Mdata.Read(d1,4) ;
          self.F_Mdata.Write(d1,4) ;
        end ;
      end ;

      self.numRows := self.numRows + numRowsIn ;
      sourceMat.F_Mdata.Seek(0,soFromBeginning) ;
      self.F_Mdata.Seek(0,soFromBeginning) ;
   end
   else
   begin
      WriteError('AddRowsToTMatrix() Error: number of columns of input does not match number of columns of TMatrix being added to') ;
   end ;


end ;


procedure TMatrix.AddColToEndOfData(var dataCol : TMemoryStream; numRowIn : integer ) ;   // dataCol is the complete column
var
  oldsize : integer ;
  t1, t2 : integer ;
  p1 : pointer ;
  tMemStr : TMemoryStream ;
begin
  GetMem(p1, self.SDPrec * self.complexMat) ;
  oldSize := self.F_Mdata.Size ;
  dataCol.Seek(0,soFromBeginning) ;

  tMemStr := TMemoryStream.Create ; // this is a temp storage for the added data

  if numRowIn = self.numRows then
  begin
    self.F_Mdata.Seek(0,soFromBeginning) ;
    tMemStr.SetSize(oldSize+(numRowIn * self.SDPrec * self.complexMat)) ;
    tMemStr.Seek(0,soFromBeginning) ;
    for t1 := 0 to self.numRows -1 do
    begin
      for t2 := 0 to self.numCols -1 do
      begin
        self.F_Mdata.Read(p1^,self.SDPrec * self.complexMat) ;
        tMemStr.Write(p1^,self.SDPrec * self.complexMat) ;
      end ;
      dataCol.Read(p1^,self.SDPrec  * self.complexMat) ;   // read the single real or real-Imag pair
      tMemStr.Write(p1^,self.SDPrec  * self.complexMat) ;  // write the single real or real-Imag pair
    end ;
    inc(self.numCols) ;
    self.F_Mdata.SetSize(oldSize+(numRowIn * self.SDPrec * self.complexMat)) ;
    self.F_Mdata.Seek(0,soFromBeginning) ;
    tMemStr.Seek(0,soFromBeginning)  ;
    self.F_Mdata.CopyFrom(tMemStr,tMemStr.Size) ;
  end
  else  if self.numRows = 0 then
  begin
    if (self.numCols = 0) and (self.numRows = 0) then  // no data so far so just add it as a column
    begin
      self.F_Mdata.SetSize(oldSize+(numRowIn * self.SDPrec * self.complexMat)) ;
      for t1 := 0 to numRowIn -1 do
      begin
        dataCol.Read(p1^,self.SDPrec * self.complexMat) ;
        self.F_Mdata.Write(p1^,self.SDPrec * self.complexMat) ;
      end ;
      self.numCols := 1 ;
      self.numRows := numRowIn ;
    end ;
  end
  else //if (numRowIn <> self.numRows) and (self.numRows <> 0)then
  begin
     WriteError('AddColToEndOfData() Error: number of rows of input does not match number of rows of TMatrix') ;
  end ;
  FreeMem(p1) ;
  tMemStr.Free ;
end ;



procedure TMatrix.AddColumnsToMatrix(rowRange, colRange : string; sourceMatrix : TMatrix) ;
var
   t1 : integer ;
   c1 : integer ;
   p1 : pointer ;
   rowsToAdd, colsToAdd : integer;
   tMat : TMatrix ;
begin
   rowRange := trim(rowRange) ;
   colRange := trim(colRange) ;

   rowsToAdd := self.GetTotalRowsColsFromString(rowRange, Frows) ;
   colsToAdd := self.GetTotalRowsColsFromString(colRange, Fcols) ;

   if  (self.numRows <> rowsToAdd) and (self.numRows <> 0) then
   begin
     WriteError('TMatrix.AddColumnsToMatrix() Error: Incorrect number of rows in column data.') ;
     exit ;
   end ;

   Frows.Seek(0,soFromBeginning) ;
   Fcols.Seek(0,soFromBeginning) ;
   self.F_Mdata.Seek(0,soFromBeginning) ;
   sourceMatrix.F_Mdata.Seek(0,soFromBeginning) ;
   tMat := TMatrix.Create(self.SDPrec) ;

   for t1 := 1 to  colsToAdd do
   begin
       Fcols.Read(c1,4) ;
       tMat.FetchDataFromTMatrix(rowRange,inttostr(c1+1),sourceMatrix) ;   // fetch a single column at a time (either real or real-Imag pairs)
       self.AddColToEndOfData(tMat.F_Mdata, rowsToAdd) ;
   end ;

   tMat.Free ;
end ;




// check for correct input - numeric, '-' and ',' with numeric going low to high
function TMatrix.CheckRangeInput(rangeIn : String) : boolean ;
var
  range : String ;
  t1 : integer ;
  pos_dash, pos_comma : integer ;
  repeatNum : integer ;
begin
  rangeIn := trim(rangeIn) ;
  Range := rangeIn ;



  if length(Range) = 0 then
  begin
    result := false ;
    exit ;
  end  ;

//  else
  if length(Range) = 1 then
  begin

    try
     strtoint(Range) ;
    except
    on  EConvertError  do
    begin
      result := false ;
      WriteError('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid numeric input') ;
      exit ;
    end;
    end ; // except

  end ;

  pos_dash := pos('-',range) ;
  pos_comma := pos(',',range) ;

  // error if dash follows comma directly of vice versa
  if ((pos_dash - pos_comma) = -1) or ((pos_dash - pos_comma) = 1)  then
  begin
    result := false ;
    WriteError('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid input') ;
    exit ;
  end;

  while (pos_dash > 0) or (pos_comma > 0) do
  begin
     if  (pos_dash < pos_comma) and (pos_dash <> 0) then
     begin
        try
          strtoint(copy(Range,1,pos_dash-1)) ;
        except
        on  EConvertError  do
        begin
          result := false ;
          WriteError('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_dash-1)+'" is not a valid numeric input' ) ;
          exit ;
        end;
        end ; // try/except
        Range := copy(Range,pos_dash+1,length(Range)) ;
        pos_dash := pos('-',range) ;
        pos_comma := pos(',',range) ;
     end ;
     if  (pos_comma < pos_dash) and (pos_comma <> 0) then
     begin
        try
          strtoint(copy(Range,1,pos_comma-1)) ;
        except
        on  EConvertError  do
        begin
          result := false ;
          WriteError('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
          exit ;
        end;
        end ; // try/except
        Range := copy(Range,pos_comma+1,length(Range)) ;
        pos_dash := pos('-',range) ;
        pos_comma := pos(',',range) ;
     end ;

     // error if dash follows comma directly of vice versa
    if ((pos_dash - pos_comma) = -1) or ((pos_dash - pos_comma) = 1)  then
    begin
      result := false ;
      WriteError('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid input') ;
      exit ;
    end;

     if (pos_comma > 0) and ((pos_comma < pos_dash) or (pos_dash = 0)) then
     begin
       try
          strtoint(copy(Range,1,pos_comma-1)) ;
        except
        on  EConvertError  do
        begin
          result := false ;
          WriteError('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
          exit ;
        end;
        end ; // try/except
       Range := copy(Range,pos_comma+1,length(Range)) ;
     end ;

     if (pos_dash > 0) and ((pos_dash < pos_comma) or (pos_comma = 0)) then
     begin
       try
          strtoint(copy(Range,1,pos_dash-1)) ;
        except
        on  EConvertError  do
        begin
          result := false ;
          WriteError('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
          exit ;
        end;
        end ; // try/except
       Range := copy(Range,pos_dash+1,length(Range)) ;
     end ;


     pos_dash := pos('-',range) ;
     pos_comma := pos(',',range) ;

  end ;  // end while loop

  if length(Range) > 0 then
  begin
    try
     strtoint(Range) ;
    except
    on  EConvertError  do
    begin
      result := false ;
      WriteError('TMatrix.CheckRangeInput() Error: "'+ rangeIn +'" is not a valid input') ;
      exit ;
    end;
    end ; // except
  end ;

  result := true ;
//  end ;   // End loop for first/secod halves of ':' sectioined string

end ;


function  TMatrix.CreateStringFromRowColStream(rowcolList : TMemoryStream) : string ;
// does oppisite of GetTotalRowsColsFromString()
// - i.e. from MemStream of integers, create range i.e. "3,6-12,30"
var
  t1, t2, last, num : integer ;
  str : string ;
begin
   rowcolList.Seek(0,soFromBeginning) ;

   // read first integer
   rowcolList.read(t2,sizeof(integer)) ;
   t2 := t2+1 ;
   result := inttostr(t2) ;
   last := t2 ;
   while rowcolList.Position <= (rowcolList.Size-4) do
   begin
     rowcolList.read(t2,sizeof(integer)) ;
     t2 := t2+1 ;
     num := 0 ;

     while (t2 = (last + 1)) and (rowcolList.Position < (rowcolList.Size)) do
     begin
       rowcolList.read(t2,sizeof(integer)) ;
       t2 := t2+1 ;
       last := last + 1 ;
       num := num + 1 ;
     end;

     if num > 0 then
       result := result +'-'+inttostr(t2)
     else
       result := result +','+inttostr(t2) ;

   end;

   rowcolList.Seek(0,soFromBeginning) ;
end;





// From a string range (eg '3-7,9-24') get total number of rows and place the row numbers
// in a (zero based) vector (MemoryStream) also returns total number of numbers in the range specified
// TMemoryStream has to be created
function TMatrix.GetTotalRowsColsFromString(range :string; rowcolList : TMemoryStream) : integer  ;
var
  tstr : string ;
  lowInt, highInt, t1 : integer ;
  pos_dash, pos_comma : integer ;
begin
  range := trim(range) ;
  pos_dash := pos('-',range) ;
  pos_comma := pos(',',range) ;
  result := 0 ;
  rowcolList.Clear ;

  repeat
    if ((pos_dash < pos_comma) and (pos_dash <> 0)) or (pos_comma =0) then
    begin
       tstr := copy(range, 1, pos_dash-1) ;
       if tstr <> '' then
         lowInt := strtoint(tstr)
       else
         lowInt := strtoint(range) ;   // this is needed for when list is only '1' etc
       range := copy(range,pos_dash+1,length(range)-pos_dash) ;
       if pos_comma = 0 then
         pos_comma := length(range)+1
       else
         pos_comma := pos(',',range) ;
       tstr := copy(range, 1, pos_comma-1) ;
       highInt := strtoint(tstr) ;
       range := copy(range,pos_comma+1,length(range)-pos_comma) ;
       result := result + (highint - lowint) + 1 ;
       for t1 := lowInt-1 to highInt-1 do
       begin
         rowcolList.SetSize(rowcolList.Size+4) ;
         rowcolList.Write((t1),4) ;
       end ;
    end
    else
    begin
       tstr := copy(range, 1, pos_comma-1) ;
       highInt := strtoint(tstr) ;
       range := copy(range,pos_comma+1,length(range)-pos_comma) ;
       result := result + 1  ;
       rowcolList.SetSize(rowcolList.Size+4) ;
       highInt:= highInt-1 ;
       rowcolList.Write((highInt),4) ;
    end ;
    range := trim(range) ;
    pos_dash := pos('-',range) ;
    pos_comma := pos(',',range) ;
    if (pos_dash = 0) and (pos_comma = 0) and (Length(range) <> 0) then
    begin
       highInt := strtoint(range) ;
       range := '' ;
       result := result + 1  ;
       rowcolList.SetSize(rowcolList.Size+4) ;
       highInt:= highInt-1 ;
       rowcolList.Write((highInt),4) ;
    end ;

   until  (pos_dash = 0) and (pos_comma = 0)  ;

   // recent addition to reset TMemoryStream to the beginning
   rowcolList.Seek(0,soFromBeginning) ;

end ;


function  TMatrix.GetTotalRowsColsFromString(range :string) : integer ;
var
  tstr : string ;
  lowInt, highInt, t1 : integer ;
  pos_dash, pos_comma : integer ;
begin
  range := trim(range) ;
  pos_dash := pos('-',range) ;
  pos_comma := pos(',',range) ;
  result := 0 ;


  repeat
    if ((pos_dash < pos_comma) and (pos_dash <> 0)) or (pos_comma =0) then
    begin
       tstr := copy(range, 1, pos_dash-1) ;
       if tstr <> '' then
         lowInt := strtoint(tstr)
       else
         lowInt := strtoint(range) ;   // this is needed for when list is only '1' etc
       range := copy(range,pos_dash+1,length(range)-pos_dash) ;
       if pos_comma = 0 then
         pos_comma := length(range)+1
       else
         pos_comma := pos(',',range) ;
       tstr := copy(range, 1, pos_comma-1) ;
       highInt := strtoint(tstr) ;
       range := copy(range,pos_comma+1,length(range)-pos_comma) ;
       result := result + (highint - lowint) + 1 ;

    end
    else
    begin
       tstr := copy(range, 1, pos_comma-1) ;
       highInt := strtoint(tstr) ;
       range := copy(range,pos_comma+1,length(range)-pos_comma) ;
       result := result + 1  ;

       highInt:= highInt-1 ;

    end ;
    range := trim(range) ;
    pos_dash := pos('-',range) ;
    pos_comma := pos(',',range) ;
    if (pos_dash = 0) and (pos_comma = 0) and (Length(range) <> 0) then
    begin
       highInt := strtoint(range) ;
       range := '' ;
       result := result + 1  ;

       highInt:= highInt-1 ;

    end ;

   until  (pos_dash = 0) and (pos_comma = 0)  ;

end ;

procedure TMatrix.FetchDataFromTMatrix(rowRange, colRange : string; sourceMatrix : TMatrix) ;
var
   t1, t2 : integer ;
   r1, c1 : integer ;
   p1 : pointer ;
begin
   rowRange := trim(rowRange) ;
   colRange := trim(colRange) ;
   if (rowRange <> '') and (colRange <> '') then
   begin
   GetMem(p1, SDPrec * self.complexMat) ;
   self.ClearData(SDPrec) ;

   self.SDPrec := sourceMatrix.SDPrec ; // single or double precision
   self.complexMat := sourceMatrix.complexMat ;

   self.numRows := self.GetTotalRowsColsFromString(rowRange, Frows) ;
   self.numCols := self.GetTotalRowsColsFromString(colRange, Fcols) ;
   self.F_Mdata.SetSize(self.numRows * self.numCols * self.SDPrec * self.complexMat) ;
   Frows.Seek(0,soFromBeginning) ;
   Fcols.Seek(0,soFromBeginning) ;
   self.F_Mdata.Seek(0,soFromBeginning) ;

   for t1 := 1 to  self.numRows do
   begin
     Frows.Read(r1,4) ;
     for t2 := 1 to self.numCols do
     begin
         Fcols.Read(c1,4) ;
         sourceMatrix.F_Mdata.Seek( ((r1 * sourceMatrix.numCols)*SDPrec*complexMat) + (c1*SDPrec*complexMat), soFromBeginning) ;
         sourceMatrix.F_Mdata.Read(p1^,SDPrec*complexMat) ;
         self.F_Mdata.Write(p1^,SDPrec*complexMat) ;
     end ;
     Fcols.Seek(0,soFromBeginning) ;
   end ;
   FreeMem(p1) ;
   end
   else

     WriteError('Error: TMatrix.FetchDataFromTMatrix(): Input data range not valid') ;
end ;


procedure TMatrix.FetchDataFromTFileStream(rowRange, colRange : string; numColsIn : integer;  sourceFileStrm : TFileStream) ;
var
   t1, t2, t_seek : integer ;
   r1, c1 : integer ;
   p1 : pointer ;
begin
   rowRange := trim(rowRange) ;
   colRange := trim(colRange) ;
   if (rowRange <> '') and (colRange <> '') then
   begin
   GetMem(p1, SDPrec * self.complexMat) ;
   self.ClearData(SDPrec) ;

 //  self.SDPrec := SDPrecIn ; // single or double precision
//   self.complexMat := complexMatIn ;

   self.numRows := self.GetTotalRowsColsFromString(rowRange, Frows) ;
   self.numCols := self.GetTotalRowsColsFromString(colRange, Fcols) ;
   self.F_Mdata.SetSize(self.numRows * self.numCols * self.SDPrec * self.complexMat) ;
   Frows.Seek(0,soFromBeginning) ;
   Fcols.Seek(0,soFromBeginning) ;
   self.F_Mdata.Seek(0,soFromBeginning) ;

   for t1 := 1 to  self.numRows do
   begin
     Frows.Read(r1,4) ;
     for t2 := 1 to self.numCols do
     begin
         Fcols.Read(c1,4) ;
         t_seek := ((r1 * numColsIn)*SDPrec*complexMat) + (c1*SDPrec*complexMat) ;
         if (sourceFileStrm.Position <> t_seek) then ;
           sourceFileStrm.Seek(t_seek , soFromBeginning) ;
         sourceFileStrm.Read(p1^,SDPrec*complexMat) ;
         self.F_Mdata.Write(p1^,SDPrec*complexMat) ;
     end ;
     Fcols.Seek(0,soFromBeginning) ;
   end ;
   FreeMem(p1) ;
   end
   else
     WriteError('Error: TMatrix.FetchDataFromTFileStream(): Input data range not valid') ;
end ;


procedure TMatrix.Stddev ;  // is the sqrt of the variance
var
   t1 : integer ;
   s1 : TSingle ;
   d1 : TDouble ;
   root_s : single ;
   root_d : double ;
begin

  self.Variance ;
  F_MStdDev.SetSize(numCols*SDPrec*complexMat) ;
  F_MStdDev.Seek(0,soFromBeginning) ;
  F_MVariance.Seek(0,soFromBeginning) ;

  if (SDPrec = 4) and (complexMat=1) then
  begin
    for t1 := 1 to numCols do
    begin
       F_MVariance.Read(s1,SDPrec) ;
       s1[1] := sqrt(s1[1]) ;
       F_MStdDev.Write(s1,SDPrec) ;
    end ;
  end
  else
  if (SDPrec = 4) and (complexMat=2) then
  begin
    for t1 := 1 to numCols do
    begin
       F_MVariance.Read(s1,SDPrec*complexMat) ;
       root_s :=  sqrt((s1[1]*s1[1])+(s1[2]*s1[2])) ;
       s1[1]  :=  sqrt( ( root_s - s1[1]) / 2  )  ;
       s1[2]  :=  s1[2] / (2 * s1[1]) ;
       root_s :=  s1[1] ;
       s1[1]  :=  s1[2] ;
       s1[2]  :=  root_s ;
       F_MStdDev.Write(s1,SDPrec*complexMat) ;
    end ;
  end
  else
  if (SDPrec = 8) and (complexMat=1) then
  begin
    for t1 := 1 to numCols do
    begin
       F_MVariance.Read(d1,SDPrec) ;
       d1[1] := sqrt(d1[1]) ;
       F_MStdDev.Write(d1,SDPrec) ;
    end ;
  end
  else
  if (SDPrec = 8) and (complexMat=2) then
  begin
    for t1 := 1 to numCols do
    begin
       F_MVariance.Read(d1,SDPrec*complexMat) ;
       root_d :=  sqrt((d1[1]*d1[1])+(d1[2]*d1[2])) ;
       d1[1]  :=  sqrt( ( root_d - d1[1]) / 2  )  ;
       d1[2]  :=  d1[2] / (2 * d1[1]) ;
       root_d :=  d1[1] ;
       d1[1]  :=  d1[2] ;
       d1[2]  :=  root_d ;
       F_MStdDev.Write(d1,SDPrec*complexMat) ;
    end ;
  end  ;

  F_MStdDev.Seek(0,soFromBeginning) ;
  F_MVariance.Seek(0,soFromBeginning) ;
end ;


//  if data is mean centred then x_ave = 0 so sum of square of
//  each column are added and divided by (i-1)
procedure TMatrix.Variance ;
var
   t1, t2 : integer ;
   pdata, pvar, pave, pMKL : pointer ;
   s1, s2, s3, s4 : TSingle ;
   d1, d2, d3, d4 : TDouble ;
begin

   if (F_MAverage.Size = 0) then
       self.Average ;


   GetMem(pdata, SDPrec) ;
   GetMem(pvar, SDPrec) ;
   GetMem(pave, SDPrec) ;

   F_MVariance.SetSize(numCols*SDPrec) ;
   Zero(F_MVariance) ;
   F_Mdata.Seek(0,soFromBeginning) ;

   if self.meanCentred = false then
   begin
     for t1 := 1 to numRows do
     begin
       F_MVariance.Seek(0,soFromBeginning) ;
       F_MAverage.Seek(0,soFromBeginning) ;

       for t2 := 1 to numCols do
       begin

         if (SDPrec = 4) and (complexMat=1) then                      // single precision
         begin
           F_Mdata.Read(s1[1],SDPrec) ;
           F_MVariance.Read(s4[1],SDPrec) ;
           F_MVariance.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(s3[1],SDPrec) ;

           s2[1] := (s1[1] - s3[1])  ;
           s4[1] := s4[1] + (s2[1] * s2[1])  ;

           F_MVariance.Write(s4,SDPrec) ;
         end
         else
         if (SDPrec = 4) and (complexMat=2) then                      // single precision
         begin
           F_Mdata.Read(s1,8) ;
           F_MVariance.Read(s4,8) ;
           F_MVariance.Seek(-8,soFromCurrent) ;
           F_MAverage.Read(s3,8) ;

           s2[1] := (s1[1] - s3[1])  ;
           s2[2] := (s1[2] - s3[2])  ;

           s3[1] :=  (s2[1] * s2[1]) - (s2[1] * s2[1]) ;
           s3[2] :=  (s2[1] * s2[2]) + (s2[1] * s2[2]) ;

           s4[1] := s4[1] +  s3[1]  ;
           s4[2] := s4[2] +  s3[2]  ;

           F_MVariance.Write(s4,8) ;
         end
         else
         if (SDPrec = 8) and (complexMat=1) then   // double precision
         begin
           F_Mdata.Read(d1[1],SDPrec) ;
           F_MVariance.Read(d4[1],SDPrec) ;
           F_MVariance.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(d3[1],SDPrec) ;

           d2[1] := (d1[1] - d3[1])  ;
           d4[1] := d4[1] + (d2[1] * d2[1])  ;

           F_MVariance.Write(d4[1],SDPrec) ;
         end
         else
         if (SDPrec = 8) and (complexMat=2) then   // double precision
         begin
           F_Mdata.Read(d1,16) ;
           F_MVariance.Read(d4,16) ;
           F_MVariance.Seek(-16,soFromCurrent) ;
           F_MAverage.Read(d3,16) ;

           d2[1] := (d1[1] - d3[1])  ;
           d2[2] := (d1[2] - d3[2])  ;

           d3[1] :=  (d2[1] * d2[1]) - (d2[1] * d2[1]) ;
           d3[2] :=  (d2[1] * d2[2]) + (d2[1] * d2[2]) ;

           d4[1] := d4[1] +  d3[1]  ;
           d4[2] := d4[2] +  d3[2]  ;

           F_MVariance.Write(d4,16) ;
         end

        end ;
      end ;

   end   // meanCentrd = false
   else  // meanCentred = true
   begin
       pMKL := F_Mdata.Memory ;
       for t1 := 0 to numCols-1 do
       begin
         if (SDPrec = 4) and (complexMat=1) then                      // single precision
         begin
           s1[1] := sdot ( numRows, pMKL, numCols, pMKL, numCols )  ;
           F_MVariance.Write(s1,SDPrec) ;
         end
         else
          if (SDPrec = 4) and (complexMat=2) then                      // single precision
         begin
           s1 := cdotu ( numRows, pMKL, numCols, pMKL, numCols );
           F_MVariance.Write(s1,SDPrec*complexMat) ;
         end
         else
         if (SDPrec = 8) and (complexMat=1) then
         begin                                   // double precision
           d1[1] := ddot ( numRows, pMKL, numCols, pMKL, numCols ) ;
           F_MVariance.Write(d1,SDPrec) ;
         end
         else
         if (SDPrec = 8) and (complexMat=2) then
         begin                                   // double precision
           d1 := zdotu ( numRows, pMKL, numCols, pMKL, numCols ) ;
           F_MVariance.Write(d1,SDPrec*complexMat) ;
         end ;
         pMKL := movePointer(pMKL,SDPrec*complexMat) ;
       end ;
   end ;

   // divide by number of rows
   if (complexMat=1) then
   begin
     s1[1] := 1 / (numRows-1) ;
     d1[1] := 1 / (numRows-1) ;
   end
   else
   if (complexMat=2) then
   begin
     s1[1] := 1 / (numRows-1) ;
     s1[2] := 0 ;
     d1[1] := 1 / (numRows-1) ;
     d1[2] := 0 ;
   end ;

   F_MVariance.Seek(0,soFromBeginning) ;
   for t1 := 1 to numCols do
   begin
        if (SDPrec = 4) and (complexMat=1) then
        begin
           F_MVariance.Read(s2,SDPrec) ;
           F_MVariance.Seek(-SDPrec,soFromCurrent) ;
           s2[1] := s2[1] * s1[1] ;   // single(pvar^) := single(pvar^) * s1
           F_MVariance.Write(s2,SDPrec) ;
        end
        else
        if (SDPrec = 4) and (complexMat=2) then
        begin
           F_MVariance.Read(s2,SDPrec*complexMat) ;
           F_MVariance.Seek(-SDPrec*complexMat,soFromCurrent) ;
           //s3[1] := (s2[1] * s1[1]) - (s2[2]*s1[2])  ;   // full complex multiplication is not needed as imaginary part of multiplicand is zero
           //s3[2] := (s2[1] * s1[2]) + (s2[2]*s1[1]) ;
           s2[1] := s2[1] * s1[1] ;
           s2[2] := s2[2] * s1[1] ;
           F_MVariance.Write(s2,SDPrec*complexMat) ;
        end
        else
        if (SDPrec = 8) and (complexMat=1) then
        begin
           F_MVariance.Read(d2,SDPrec) ;
           F_MVariance.Seek(-SDPrec,soFromCurrent) ;
           d2[1] := d2[1] * d1[1] ;
           F_MVariance.Write(d2,SDPrec) ;
        end
        else
        if (SDPrec = 8) and (complexMat=2) then
        begin
           F_MVariance.Read(d2,SDPrec*complexMat) ;
           F_MVariance.Seek(-SDPrec*complexMat,soFromCurrent) ;
           d2[1] := d2[1] * d1[1] ;
           d2[2] := d2[2] * d1[1] ;
           F_MVariance.Write(d2,SDPrec*complexMat) ;
        end ;
   end ;

   FreeMem(pdata) ;
   FreeMem(pvar) ;
   FreeMem(pave) ;

end ;



procedure TMatrix.ColStandardize ;    // not complex number friendly
var
  t1, t2 : integer ;
  s1, stddevs : single ;
  d1, stddevd : double ;
begin
  if  colStandardized = false then
  begin
    if F_MStdDev.Size = 0 then
      self.Stddev ;

    F_MStdDev.Seek(0,soFromBeginning) ;
    F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 1 to numRows do
    begin
      F_MStdDev.Seek(0,soFromBeginning) ;
      for t2 := 1 to numCols do
      begin
         if  SDPrec = 4 then
         begin
           F_Mdata.Read(s1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MStdDev.Read(stddevs,SDPrec) ;
           s1 := s1 / stddevs ;
           F_Mdata.Write(s1,SDPrec) ;
         end
         else
         begin
           F_Mdata.Read(d1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MStdDev.Read(stddevd,SDPrec) ;
           d1 := d1 / stddevd ;
           F_Mdata.Write(d1,SDPrec) ;
         end ;
      end ;
    end ;
    colStandardized := true ;
  end ;


end ;


procedure TMatrix.MeanCentre() ;
var
   t1, t2 : integer ;
   pdata, pave  : pointer  ; // pointer to the stream that stores the average values
   s1, s2 : single ;
   d1, d2 : double ;
   tTimer : TASMTimer ;
begin
{  if  meanCentred = false then
  begin
   GetMem(pdata, SDPrec) ;
   GetMem(pave, SDPrec)  ;

   self.Average ;
   F_Mdata.Seek(0,soFromBeginning) ;

   F_Mdata.Seek(0,soFromBeginning) ;
   for t1 := 1 to numRows do
   begin
     F_MAverage.Seek(0,soFromBeginning) ;
     for t2 := 1 to numCols do
     begin
        F_Mdata.Read(pdata^,SDPrec) ;
        F_MAverage.Read(pave^,SDPrec) ;
        F_Mdata.Seek(-SDPrec,soFromCurrent) ;
        if SDPrec = 4 then                      // single precision
           single(pdata^) := single(pdata^) - single(pave^)
        else                                    // double precision
           double(pdata^) := double(pdata^) - double(pave^) ;
        F_Mdata.Write(pdata^,SDPrec) ;

        // add imaginary section identical to above here...
        if complexMat = 2 then
        begin
          F_Mdata.Read(pdata^,SDPrec) ;
          F_MAverage.Read(pave^,SDPrec) ;
          F_Mdata.Seek(-SDPrec,soFromCurrent) ;
          if SDPrec = 4 then                      // single precision
             single(pdata^) := single(pdata^) - single(pave^)
          else                                    // double precision
             double(pdata^) := double(pdata^) - double(pave^) ;
          F_Mdata.Write(pdata^,SDPrec) ;
        end ;
     end ;
   end ;
   FreeMem(pdata) ;
   FreeMem(pave) ;
   meanCentred := true ;
 end ;  }
  if  meanCentred = false then
  begin

   self.Average ;

//Writeln('') ;
//Write('Subtraction stage: ') ;
//tTimer := TASMTimer.Create(0) ;
//tTimer.setTimeDifSecUpdateT1 ;

   F_Mdata.Seek(0,soFromBeginning) ;
  if SDPrec = 4 then  // single precision
  begin
   pdata := F_MData.memory ;
   for t1 := 1 to numRows do
   begin
  {    F_MAverage.Seek(0,soFromBeginning) ;
     for t2 := 1 to numCols * complexmat do
     begin
        F_Mdata.Read(s1,SDPrec) ;
        F_MAverage.Read(s2,SDPrec) ;
        F_Mdata.Seek(-SDPrec,soFromCurrent) ;
        s1 := s1 - s2 ;
        F_Mdata.Write(s1,SDPrec) ;
     end ;
   end;  }
    pave  := F_MAverage.memory ;
    t2 := (numCols * complexmat) ;
    asm
       push esi
       push edi
       mov esi, pdata
       mov edi, pave
       mov ecx, t2   //this is the loop counter
       FINIT
    @loop:
       fld [esi]
       FSUB [edi]
       FSTP [esi]
       add edi, 4
       add esi, 4
       dec ecx
    jnz @loop
       mov pdata, esi
       pop edi
       pop esi
     end;
   end ;
   end  // if SDPrec = 4 then
   else
   if SDPrec = 8 then
   begin
     for t1 := 1 to numRows do
     begin
     F_MAverage.Seek(0,soFromBeginning) ;
     for t2 := 1 to numCols * complexmat do
     begin
        F_Mdata.Read(d1,SDPrec) ;
        F_MAverage.Read(d2,SDPrec) ;
        F_Mdata.Seek(-SDPrec,soFromCurrent) ;
        d1 := d1 - d2  ;
        F_Mdata.Write(d1,SDPrec) ;
     end ;
   end ;

   end ; // SDPrec = 8
   F_MAverage.Seek(0,soFromBeginning) ;
   F_Mdata.Seek(0,soFromBeginning) ;
   meanCentred := true ;

//   self.SaveMatrixDataBin('meancentred_data.bin');

//tTimer.setTimeDifSec ;
//tTimer.outputTimeSec('The subtraction part: ') ;
 end ;
 
 
 
end ;



function TMatrix.AverageReduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;      // not complex number friendly
var
   t1, t2,  t3 : integer ;
//   p1  : pointer ;
   s1, s2 : single ;
   d1, d2 : double ;
   reducedM : TMatrix ;  // this is the result value and has to be freed by calling procedure
begin
//   GetMem(p1, SDPrec)  ; //sets buffer
   reducedM :=  TMatrix.Create(SDPrec) ; // temporary storage

   if rowOrCol = Rows  then  //  rows/samples are averaged
   begin
     reducedM.numCols := numCols ;
     reducedM.numRows := numRows div inNumAves ;

     reducedM.F_Mdata.SetSize(reducedM.numRows * reducedM.numCols * reducedM.SDPrec) ;
     reducedM.F_Mdata.Seek(0,soFromBeginning) ;

     self.F_Mdata.Seek(0,soFromBeginning) ;

     if SDPrec = 4 then
     begin
     for t1 := 0 to numCols -1 do
     begin
       for t2 := 0 to reducedM.numRows - 1 do
       begin
         s2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(s1,SDPrec) ;
            s2 := s2 + s1 ;
            self.F_Mdata.Seek((SDPrec*(numCols-1)),soFromCurrent) ;
         end ;
         reducedM.F_Mdata.Seek(t2*self.SDPrec*self.numCols+(t1 * SDPrec),soFromBeginning) ;
         s2 := s2 /  inNumAves ;
         reducedM.F_Mdata.Write(s2,4) ;
       end ;
       self.F_Mdata.Seek(SDPrec*(t1+1),soFromBeginning) ;
     end  ;
     end
     else
     if SDPrec = 8 then
     begin
     for t1 := 0 to numCols-1 do
     begin
       begin
       for t2 := 0 to reducedM.numRows-1  do
         d2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(d1,SDPrec) ;
            d2 := d2 + d1 ;
            self.F_Mdata.Seek((SDPrec*(numCols-1)),soFromCurrent) ;
         end ;
          d2 := d2 /  inNumAves ;
         reducedM.F_Mdata.Seek(t2*self.SDPrec*self.numCols+(t1 * SDPrec),soFromBeginning) ;
         reducedM.F_Mdata.Write(d2,4) ;
       end ;
       self.F_Mdata.Seek(SDPrec*(t1+1),soFromBeginning) ;
     end  ;
     end  ;
   end
   else
   if rowOrCol = Cols then  //  columns/variables are averaged
   begin
     reducedM.numCols := numCols div inNumAves;
     reducedM.numRows := numRows  ;

     reducedM.F_Mdata.SetSize(reducedM.numRows * reducedM.numCols * reducedM.SDPrec) ;
     reducedM.F_Mdata.Seek(0,soFromBeginning) ;

     self.F_Mdata.Seek(0,soFromBeginning) ;

     if SDPrec = 4 then
     begin
     for t1 := 0 to numRows-1 do  // for each row
     begin
       self.F_Mdata.Seek(SDPrec*t1*self.numCols,soFromBeginning) ;  // get to correct line
       for t2 := 1 to reducedM.numCols  do   // do reducedM.numCols number of averages
       begin
         s2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(s1,SDPrec) ;
            s2 := s2 + s1 ;
         end ;
          s2 := s2 /  inNumAves ;
         reducedM.F_Mdata.Write(s2,4) ;
       end ;
     end  ;
     end
     else
     if SDPrec = 8 then
     begin
     for t1 := 0 to numRows-1 do  // for each row
     begin
       self.F_Mdata.Seek(SDPrec*t1*self.numCols,soFromBeginning) ;  // get to correct line
       for t2 := 1 to reducedM.numCols  do   // do reducedM.numCols number of averages
       begin
         d2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(d1,SDPrec) ;
            d2 := d2 + d1 ;
         end ;
         d2 := d2 /  inNumAves ;
         reducedM.F_Mdata.Write(d2,4) ;
       end ;
     end  ;
     end  ;
   end ;



   F_Mdata.Seek(0,soFromBeginning) ;
   reducedM.F_Mdata.Seek(0,soFromBeginning) ;

   result :=  reducedM ;
end ;


function TMatrix.Reduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;      // not complex number friendly
var
   t1, t2,  t3 : integer ;
   p1  : pointer ;
   s1, s2 : single ;
   d1, d2 : double ;
   reducedM : TMatrix ;  // this is the result value and has to be freed by calling procedure
begin
   GetMem(p1, SDPrec)  ; //sets buffer
   reducedM :=  TMatrix.Create(SDPrec) ; // temporary storage

   if rowOrCol = Rows  then  //  rows/samples are averaged
   begin
     reducedM.numCols := numCols ;
     reducedM.numRows := numRows div inNumAves ;

     reducedM.F_Mdata.SetSize(reducedM.numRows * reducedM.numCols * reducedM.SDPrec) ;
     reducedM.F_Mdata.Seek(0,soFromBeginning) ;

     self.F_Mdata.Seek(0,soFromBeginning) ;

     if SDPrec = 4 then
     begin
     for t1 := 0 to numCols -1 do
     begin
       for t2 := 0 to reducedM.numRows - 1 do
       begin
//         s2 := 0 ;
//         self.F_Mdata.Read(s1,SDPrec) ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(s1,SDPrec) ;
//            s2 := s2 + s1 ;
            self.F_Mdata.Seek((SDPrec*(numCols-1)),soFromCurrent) ;
         end ;
         reducedM.F_Mdata.Seek(t2*self.SDPrec*self.numCols+(t1 * SDPrec),soFromBeginning) ;
//         s2 := s2 /  inNumAves ;
         reducedM.F_Mdata.Write(s1,4) ;
       end ;
       self.F_Mdata.Seek(SDPrec*(t1+1),soFromBeginning) ;
     end  ;
     end
     else
     if SDPrec = 8 then
     begin
     for t1 := 0 to numCols-1 do
     begin
       begin
       for t2 := 0 to reducedM.numRows-1  do
//         d2 := 0 ;
//         self.F_Mdata.Read(d1,SDPrec) ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(d1,SDPrec) ;
//            d2 := d2 + d1 ;
            self.F_Mdata.Seek((SDPrec*(numCols-1)),soFromCurrent) ;
         end ;
//          d2 := d2 /  inNumAves ;
         reducedM.F_Mdata.Seek(t2*self.SDPrec*self.numCols+(t1 * SDPrec),soFromBeginning) ;
         reducedM.F_Mdata.Write(d1,4) ;
       end ;
       self.F_Mdata.Seek(SDPrec*(t1+1),soFromBeginning) ;
     end  ;
     end  ;
   end
   else
   if rowOrCol = Cols then  //  columns/variables are averaged
   begin
     reducedM.numCols := numCols div inNumAves;
     reducedM.numRows := numRows  ;

     reducedM.F_Mdata.SetSize(reducedM.numRows * reducedM.numCols * reducedM.SDPrec) ;
     reducedM.F_Mdata.Seek(0,soFromBeginning) ;

     self.F_Mdata.Seek(0,soFromBeginning) ;

     if SDPrec = 4 then
     begin
     for t1 := 0 to numRows-1 do  // for each row
     begin
       self.F_Mdata.Seek(SDPrec*t1*self.numCols,soFromBeginning) ;  // get to correct line
       for t2 := 1 to reducedM.numCols  do   // do reducedM.numCols number of averages
       begin
         s2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(s1,SDPrec) ;
//            s2 := s2 + s1 ;
         end ;
//          s2 := s2 /  inNumAves ;
         reducedM.F_Mdata.Write(s1,4) ;
       end ;
     end  ;
     end
     else
     if SDPrec = 8 then
     begin
     for t1 := 0 to numRows-1 do  // for each row
     begin
       self.F_Mdata.Seek(SDPrec*t1*self.numCols,soFromBeginning) ;  // get to correct line
       for t2 := 1 to reducedM.numCols  do   // do reducedM.numCols number of averages
       begin
         d2 := 0 ;
         for t3 := 1 to  inNumAves  do
         begin
            self.F_Mdata.Read(d1,SDPrec) ;
//            d2 := d2 + d1 ;
         end ;
//         d2 := d2 /  inNumAves ;
         reducedM.F_Mdata.Write(d1,4) ;
       end ;
     end  ;
     end  ;
   end ;



   F_Mdata.Seek(0,soFromBeginning) ;
   reducedM.F_Mdata.Seek(0,soFromBeginning) ;

   result :=  reducedM ;
end ;




function TMatrix.GetSlope() : Single ; // not complex number friendly
var
  t1 : integer ;
  s1, s2 : pointer ;
  x_ave, y_ave : pointer ;
  s_numerator, s_denom  : single ;
begin

    if self.numCols = 2 then
    begin
      GetMem(x_ave, SDPrec) ;
      GetMem(y_ave, SDPrec) ;
      GetMem(s1, SDPrec) ;
      GetMem(s2, SDPrec) ;

      self.Average ;
      self.F_MAverage.Seek(0,soFromBeginning) ;
      self.F_MAverage.Read(x_ave^,SDPrec) ;
      self.F_MAverage.Read(y_ave^,SDPrec) ;
      s_numerator := 0.0 ;
      s_denom := 0.0 ;
      self.F_Mdata.Seek(0,soFromBeginning) ;
      for t1 := 1 to self.numRows do
      begin
       self.F_Mdata.Read(s1^,SDPrec) ;
       self.F_Mdata.Read(s2^,SDPrec) ;
       single(s1^) := single(s1^) - single(x_ave^) ;
       single(s2^) := single(s2^) - single(y_ave^) ;
       s_numerator := s_numerator + (single(s1^) * single(s2^)) ;
       s_denom := s_denom + (single(s1^) * single(s1^)) ;
      end ;
      if s_denom <> 0.0 then
        result := s_numerator / s_denom
      else
        WriteError('Error: TMatrix.GetSlope(): Slope is infinite (div by zero error)') ;


      FreeMem(x_ave) ;
      FreeMem(y_ave) ;
      FreeMem(s1) ;
      FreeMem(s2) ;
    end
    else
      WriteError('Error: TMatrix.GetSlope(): Slope can only be determined for data in 2 columns' ) ;
end ;

function TMatrix.GetYIntercept(slope : single) : Single ;   // not complex number friendly
var
  x_ave, y_ave : pointer ;
begin
    if self.numCols = 2 then
    begin
      GetMem(x_ave, SDPrec) ;
      GetMem(y_ave, SDPrec) ;

      self.Average ;
      self.F_MAverage.Seek(0,soFromBeginning) ;
      self.F_MAverage.Read(x_ave^,SDPrec) ;
      self.F_MAverage.Read(y_ave^,SDPrec) ;

      result := single(y_ave^) - (slope * single(x_ave^)) ;

      FreeMem(x_ave) ;
      FreeMem(y_ave) ;
    end
    else
      WriteError('Error: TMatrix.GetIntercept(): Intercept can only be determined for data in 2 columns' ) ;
end ;



function TMatrix.GetSlopeForcedThroughZero() : Single ;  // not complex number friendly
var
  x_ave, y_ave : pointer ;
begin

    if self.numCols = 2 then
    begin
      GetMem(x_ave, SDPrec) ;
      GetMem(y_ave, SDPrec) ;

      self.Average ;
      self.F_MAverage.Seek(0,soFromBeginning) ;
      self.F_MAverage.Read(x_ave^,SDPrec) ;
      self.F_MAverage.Read(y_ave^,SDPrec) ;

      if single(x_ave^) <> 0.0 then
        result := single(y_ave^) / single(x_ave^)
      else
        WriteError('Error: TMatrix.GetSlopeForcedThroughZero(): Slope is infinite (div by zero error)' ) ;

      FreeMem(x_ave) ;
      FreeMem(y_ave) ;
    end
    else
      WriteError('Error: TMatrix.GetSlopeForcedThroughZero(): Slope can only be determined for data in 2 columns' ) ;
end ;



function  TMatrix.GetDiagonal(inputMat : TMatrix) : TMemoryStream ;   // complex number friendly
// returns the diagonal elements of a square matrix 'inputMat'
var
  tMemstr : TMemoryStream ;
  t1 : integer ;
  p1 : pointer ;
  jump : integer ;
begin
  if inputMat.numRows = inputMat.numCols then
  begin
    GetMem(p1,inputMat.SDPrec * self.complexMat ) ;
    tMemstr := TMemoryStream.Create ;
    tMemstr.SetSize( inputMat.numCols * inputMat.numCols * inputMat.SDPrec * self.complexMat) ;
    jump :=  (inputMat.numCols * inputMat.SDPrec * self.complexMat)  ;
    for t1 := 1 to  inputMat.numCols do
    begin
         inputMat.F_Mdata.Read(p1^,inputMat.SDPrec * self.complexMat) ;
         tMemstr.Write(p1^,inputMat.SDPrec * self.complexMat) ;
         inputMat.F_Mdata.Seek(jump,soFromCurrent) ;
    end ;
    result := tMemstr ;
    FreeMem(p1) ;
  end
  else
    result := nil ;
end ;


procedure  TMatrix.SetDiagonal(inputStr : TMemoryStream)  ;  // Sets the diagonal elements of itself to values in inputStr
var
  t1 : integer ;
  p1 : pointer ;
  jump : integer ;
begin
  inputStr.Seek(0,soFromBeginning) ;
  if (inputStr.Size div (self.SDPrec*self.complexMat)) = self.numCols then
  begin
    GetMem(p1,self.SDPrec * self.complexMat ) ;
    jump :=  (self.numCols * self.SDPrec * self.complexMat)  ;
    for t1 := 1 to  self.numCols do
    begin
         inputStr.Read(p1^,self.SDPrec * self.complexMat) ;
         self.F_Mdata.Write(p1^,self.SDPrec * self.complexMat) ;
         self.F_Mdata.Seek(jump,soFromCurrent) ;
    end ;
    FreeMem(p1) ;
  end ;
  inputStr.Seek(0,soFromBeginning) ;
  self.F_Mdata.Seek(0,soFromBeginning) ;
end ;


procedure TMatrix.Transpose() ;      // complex number friendly
Var
   transM : TMemoryStream ;

   initialCols, initialRows, t1, t2 : integer ;
   p1  : pointer ;
begin
   GetMem(p1, SDPrec)  ; //sets buffer
   F_MAverage.Clear ;    // resets (column) averaged data if calculated
   F_MVariance.Clear  ;    // resets (column) variance  data if calculated
   F_MStdDev.Clear  ;    // resets (column) stddev  data if calculated
   transM :=  TMemoryStream.Create ; // temporary storage
   transM.SetSize(F_Mdata.Size) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.Seek(0,soFromBeginning) ;

   initialCols := numCols ;
   initialRows := numRows ;
   // swap column/row dimensions
   numRows := numCols ;
   numCols := initialRows ;

     for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1 * self.SDPrec * self.complexMat,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(p1^,SDPrec * complexMat) ;
          transM.Write(p1^,SDPrec * complexMat) ;
          transM.Seek((initialRows-1) * self.SDPrec * self.complexMat,soFromCurrent) ;
       end ;
     end ;


   F_Mdata.Seek(0,soFromBeginning) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.CopyFrom(transM,transM.size) ;  // copy transposed data into original data stream

   transM.Free ;
   FreeMem(p1);
end ;


procedure TMatrix.CopyUpperToLower ;   // complex number friendly
Var
  t1, t2 : integer ;
  p1  : pointer ;

begin
   GetMem(p1, SDPrec * complexMat )  ; //sets buffer

   if numRows <> numCols then
   begin
     WriteError('TMatrix.CopyUpperToLower error: Matrix is not square ' ) ;
     exit ;
   end ;

   for t1 := 0 to self.numRows - 2 do
     begin
       for t2 := t1 + 1  to self.numCols -1 do
       begin
          F_Mdata.Seek( (t1 * SDPrec * complexMat * self.numRows) + (t2 *SDPrec * complexMat) ,soFromBeginning) ;
          F_Mdata.Read(p1^,SDPrec * complexMat) ;
          self.F_Mdata.Seek( (t2 * SDPrec* complexMat * self.numRows) + (t1 * SDPrec * complexMat)    ,soFromBeginning) ;
          F_Mdata.Write(p1^,SDPrec * complexMat) ;
       end ;
     end ;

    FreeMem(p1);
end ;



function TMatrix.CreateStringFromVector(memStrIn :  TMemoryStream; offsetBytes, inputNumCols : integer; delimeter : string) : string ;   // complex number friendly
// returns the numerical contents of input as 5.4 float format delimeted string
var
  t1  : integer ;
  p1  : pointer ;
begin
  GetMem(p1, SDPrec) ;
  result := '' ;
  if memStrIn.Size > 0 then
   begin
     memStrIn.Seek(offsetBytes,soFromBeginning) ;
     for t1 := 0 to  (inputNumCols * complexMat) -1 do
     begin
       memStrIn.Read(p1^,SDPrec);
       if SDPrec = 4 then
         result := result + floattoStrf(single(p1^),ffGeneral,5,4) + delimeter
       else
         result := result + floattoStrf(double(p1^),ffGeneral,5,4) + delimeter ;
     end ;
   end ;
   FreeMem(p1) ;
end ;



procedure TMatrix.SaveMatrixDataBin(filenameOut : string) ;  // save as binary file
var
  t1 : integer ;
begin
   t1 := (sizeof(integer)*3)+(2*sizeof(boolean)) ;  // size of "numRows,numCols,SDPrec,meanCentred,colSandardized"
   self.F_Mdata.SetSize(self.F_Mdata.Size+ t1) ;
   self.F_Mdata.Seek(-t1,soFromEnd) ;
   self.F_Mdata.Write(self.numRows, sizeof(integer));
   self.F_Mdata.Write(self.numCols, sizeof(integer));
   self.F_Mdata.Write(self.SDPrec, sizeof(integer));
   self.F_Mdata.Write(self.meanCentred, sizeof(boolean));
   self.F_Mdata.Write(self.colStandardized, sizeof(boolean));
   self.F_Mdata.SaveToFile(filenameOut) ;
end ;

procedure TMatrix.LoadMatrixDataFromBinFile(filenameIn : string) ;  // load from binary file
var                                                                 // complex number friendly
  t1 : integer ;
begin
   self.ClearData(1) ;
   t1 := (sizeof(integer)*3)+(2*sizeof(boolean)) ;  // size of "numRows,numCols,SDPrec,meanCentred,colSandardized"
   self.F_Mdata.LoadFromFile(filenameIn) ;
   self.F_Mdata.Seek(-t1,soFromEnd) ;
   self.F_Mdata.Read(self.numRows, sizeof(integer));
   self.F_Mdata.Read(self.numCols, sizeof(integer));
   self.F_Mdata.Read(self.SDPrec, sizeof(integer));
   self.F_Mdata.Read(self.meanCentred, sizeof(boolean));
   self.F_Mdata.Read(self.colStandardized, sizeof(boolean));
   self.F_Mdata.SetSize(self.F_Mdata.Size- t1) ;

   if self.F_Mdata.Size = (numRows * numCols * SDPrec) then
     self.complexMat := 1
   else
   if self.F_Mdata.Size = (numRows * numCols * SDPrec * 2) then
     self.complexMat := 2
   else
   begin
     WriteError('TMatrix.LoadMatrixDataFromBinFile() Warning: Could not determine if data was complex so set as non-complex') ;
     self.complexMat := 1
   end ;

   self.Filename := filenameIn ;
end ;


procedure TMatrix.SaveMatrixDataRaw(filenameOut : string) ;  // save as binary file
begin
   self.F_Mdata.SaveToFile(filenameOut) ;
end ;


procedure TMatrix.LoadMatrixDataRawBinFile(filenameIn : string) ;  // load from binary file
begin
   self.F_Mdata.Clear ;
   self.F_Mdata.LoadFromFile(filenameIn) ;
   self.Filename := filenameIn ;
end ;


// save to file for viewing
procedure TMatrix.SaveMatrixDataTxt(filenameOut : string; delimeter : string) ;   // complex number friendly
Var
   tempList: TStringList ;
   tstr1  : string ;
   t1, t2 : integer ;
   p1     : pointer ;

begin
   GetMem(p1, SDPrec) ;
   if delimeter = '' then delimeter := #9 ;

   F_Mdata.Seek(0,soFromBeginning) ;
   tempList :=  TStringList.Create ;
   tempList.Capacity :=  numRows + 4 ;
   tempList.Append('numRows =' + inttostr(numRows)) ;
   tempList.Append('numCols =' + inttostr(numCols)) ;
   for t1 := 0 to (numRows * complexMat) -1 do
   begin
     tstr1 := '' ;
     for t2 := 0 to  numCols -1 do
     begin
       F_Mdata.Read(p1^,SDPrec);
       if SDPrec = 4 then
         tstr1 := tstr1 + floattoStrf(single(p1^),ffGeneral,7,5) + delimeter
       else
         tstr1 := tstr1 + floattoStrf(double(p1^),ffGeneral,7,5) + delimeter ;
     end ;
     tempList.Append(tstr1) ;
   end ;

   // Add the average data values to the bottom of the list
   tstr1 := CreateStringFromVector(F_MAverage,0,self.numCols,#9) ;
   if tstr1 <> '' then tempList.Append(tstr1) ;
   tstr1 := CreateStringFromVector(F_MStdDev,0,self.numCols,#9) ;
   if tstr1 <> '' then tempList.Append(tstr1) ;
   tstr1 := CreateStringFromVector(F_MVariance,0,self.numCols,#9) ;
   if tstr1 <> '' then tempList.Append(tstr1) ;
   // add filename
   tempList.Append(self.Filename) ;

   tempList.SaveToFile(filenameOut) ;
   tempList.Free ;
   FreeMem(p1) ;
end ;


function TMatrix.DetermineDelimiter(inString : string; inDelimeter : string) : string ;
var
  t1 : integer ;
  delimeter : string ;
begin
    if inDelimeter = '' then
    begin
      t1 := pos(',',inString) ;  // start choosing delimeter
      if t1 > 0 then
         delimeter :=   ','    // comma
      else
      begin
         t1 := pos(#32,inString)  ;
         if t1 > 0  then delimeter :=  #32    // space
         else
         begin
           t1 := pos(#9,inString)  ;
           if t1 > 0 then delimeter :=   #9     // tab
           else
           begin
              WriteError('Delimeter is not comma, space or tab') ;
              result := '-1' ;
              exit ;
           end ;
          end ;
      end ;   // end choosing delimeter
    end
    else // search for inDelimeter as delimeter
    begin
       t1 := pos(inDelimeter,inString)  ;
       if t1 > 0 then delimeter :=   inDelimeter     // tab
       else
       begin
         WriteError('No delimeter of type ''+inDelimeter+'' found' ) ;
         result := '-1' ;
         exit ;
       end ;
    end ;
    result := delimeter ;

end ;



// Loads data into
function TMatrix.LoadMatrixDataFromTxtFile(filenameIn : string ; startLineIn, endLineIn, startColIn, endColIn : integer; inDelimeter : string) :  boolean ;
//  rowOrCol = true if in rows rowOrCol = false if in cols                     // not complex number friendly
var
  TempList: TStringList ;
  tStr1, tStr2, delimeter : String ;
  t1, t2, t3, line, col : integer ;
  tNumCols : integer ;
  td1 : double ;
  ts1 : single ;
begin
  self.ClearData(SDPrec) ;
  self.startLine := startLineIn ;

  TempList := TStringList.Create ;

  Try
  Try
  With TempList Do
  begin
    if FileExists(filenameIn) then
    begin
      LoadFromFile(filenameIn) ;  // load text data file into string list
      self.filename := filenameIn
    end
     else
     begin
      WriteError('TMatrix.LoadMatrixDataFromTxtFile Error:'+#13+'File: '+extractFilename(filenameIn)+#13+' does not exist!' ) ;
      result := false ;
      exit ;
     end ;

    tStr1 := TempList.Strings[startLine-1] ;  // get first line
    tStr1 := trim(tStr1) ;

    delimeter := '' ;
    if inDelimeter = '' then
      delimeter := self.DetermineDelimiter(tStr1,inDelimeter)
    else
      delimeter := inDelimeter ;

    // This removes any blank lines at end of file
    tStr1 := Trim(TempList.Strings[TempList.Count-1]) ;
    while tStr1 = '' do
    begin
       TempList.Delete(TempList.Count-1) ;
       tStr1 := Trim(TempList.Strings[TempList.Count-1]) ;
    end ;
    // This removes any lines at end of file that do not have delimiter
    tStr1 := Trim(TempList.Strings[TempList.Count-1]) ;
    while pos(delimeter,tStr1) = 0 do
    begin
       TempList.Delete(TempList.Count-1) ;
       tStr1 := Trim(TempList.Strings[TempList.Count-1]) ;
    end ;

    // determine number of rows - problem if last lines are empty
    if endLineIn = 0 then
      self.numRows :=  (TempList.Count) - startLine  + 1
    else
      self.numRows :=  endLineIn - startLine ;

    // determine total number of columns
    tNumCols := 0 ;
    tStr2 := tStr1 ;
    t1 := pos(delimeter,tStr2) ; ;
    while (t1 > 0) and (t1 <> length(tStr2)) do // (t1 <> length(tStr2)) to make sure end delimeter is not counted if present
    begin
       t2 := length(tStr2) ;
       tStr2 := copy(tStr2,t1+1,t2) ;
       tStr2 := trim(tStr2) ;
       t1 := pos(delimeter,tStr2) ;
       inc(tNumCols) ;
    end ;
    inc(tNumCols) ;

    if  startColIn = 1 then   // ignore first column if in quotes
    begin
      tStr1 := trim(tStr1) ;
      t1 := pos('"',tStr1) ;
      if t1 = 1 then
      begin
        tNumCols := tNumCols - 1; // subtract one from column count
      end ;
    end ;

    // calculate number of columns to be part of TMatrix
    if tNumCols < endColIn then  // something is wrong with 'file input' data
      self.numCols := tNumCols - startColIn + 1
    else if endColIn = 0 then    // this means load all columns from startColIn
      self.numCols := tNumCols - startColIn + 1
    else                         // else number of cols is between
      self.numCols := endColIn - startColIn + 1 ;

    // Set size of matrix
    F_Mdata.SetSize(numRows*numCols*SDPrec) ;


//    if rowOrCol then
//    begin
      for line := 0 to numRows-1 do
      begin
        tStr1 := TempList.Strings[line+startLine-1] ;

        // trim off any labels in quotes
        tStr1 := trim(tStr1) ;
        t1 := pos('"',tStr1) ;
        if t1 = 1 then
        begin
          inc(t1) ;
          t2 := length(tStr1) ;
          tStr1 := copy(tStr1,t1,t2-t1) ;
          t1 := pos('"',tStr1) ;
          inc(t1) ;
          t2 := length(tStr1) ;
          tStr1 := copy(tStr1,t1,t2-t1) ;
        end ;

        // remove first unwanted columns
        for t3 := 1 to startColIn - 1 do
        begin
          tStr1 := copy(trim(tStr1),pos(delimeter,tStr1)+1,length(tStr1)) ;
        end ;

        for col := 0 to self.numCols-1 do
        begin
          tStr1 := trim(tStr1) ;
          t1 := pos(delimeter,tStr1) ;
          // backup full string removing first data point
          tStr2 := copy(tStr1,t1+1,length(tStr1)) ; ;
          // get next data point from string, storing in the same string
          if t1 > 0 then
            tStr1 := copy(tStr1,1,t1-1) ;
          // convert to floating point
          if SDPrec = 4 then
          begin
            if length(tStr1) > 0 then
            begin
              ts1 := strtofloat(tStr1) ;
              F_Mdata.Write(ts1,SDPrec) ;
            end ;
          end
          else // SDPrec = 8
          begin
            if length(tStr1) > 0 then
            begin
              td1 := strtofloat(tStr1) ;
              F_Mdata.Write(td1,SDPrec) ;
            end ;
          end ;
          // replace data for next iteration
          tStr1 := tStr2 ;
        end ;
        result := true ;
     end ;
     end ;


  except  on Exception do
    begin
     result := false ;
     self.ClearData(self.SDPrec) ;
    end ;
  end
  finally
     TempList.Free ;
  end ;



//  SaveMatrixDataTxt('check for code.txt') ;
end ;

function TMatrix.GetMinAndMaxValAndPos(row, col : integer ) : TMaxMin ; // get <min><max><min_pos(bytes)><max_pos(bytes)>
var                                                                     // not complex number friendly
  t1, t2 : integer ;
  i_max, i_min : integer ;
  p1 : pointer ;
  s_max, s_min : single ;
  d_max, d_min : double ;
  retValue : TMaxMin ;
begin
  GetMem(p1, SDPrec) ;
  s_max := Math.MinSingle ;
  s_min := Math.MaxSingle ;
  d_max := Math.MinDouble ;
  d_min := Math.MaxDouble ;
  F_Mdata.Seek(0, soFromBeginning) ;

  if (row = 0) and (col = 0) then
  begin
    for t1 := 1 to self.numRows do
    begin
       for t2 := 1 to self.numCols do
       begin
          F_Mdata.Read(p1^,SDPrec) ;
          if SDPrec = 4 then
          begin
 //            if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5;   // addedxxx  - actually a problem with complex data from PCAcomplex
             if single(p1^) >  s_max then begin s_max := single(p1^) ; i_max := F_Mdata.Position - 4 ; end ;
             if single(p1^) <  s_min then begin s_min := single(p1^) ; i_min := F_Mdata.Position - 4 ; end ;
          end
          else // SDPrec = 8
          begin
             if double(p1^) >  d_max then begin d_max := double(p1^) ; i_max := F_Mdata.Position - 8  end ;
             if double(p1^) <  d_min then begin d_min := double(p1^) ; i_min := F_Mdata.Position - 8  end ;
          end ;
       end ;
    end ;
  end
  else if (row = 0) and (col <> 0) then
  begin
       F_Mdata.Seek(SDPrec * (col-1), soFromCurrent) ;
       for t1 := 1 to self.numRows do     // for each row
       begin
          F_Mdata.Read(p1^,SDPrec) ;
          if SDPrec = 4 then
          begin
//             if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5;   // addedxxx
             if single(p1^) >  s_max then begin s_max := single(p1^) ; i_max :=  F_Mdata.Position - 4 ; end ;
             if single(p1^) <  s_min then begin s_min := single(p1^) ; i_min :=  F_Mdata.Position - 4 ; end ;
          end
          else
          begin
             if double(p1^) >  d_max then begin d_max := double(p1^) ; i_max :=  F_Mdata.Position - 8  ; end ;
             if double(p1^) <  d_min then begin d_min := double(p1^) ; i_min :=  F_Mdata.Position - 8  ; end ;
          end ;
          F_Mdata.Seek(SDPrec * (self.numCols-1), soFromCurrent) ;
       end ;
  end
  else if (row <> 0) and (col = 0) then
  begin
       F_Mdata.Seek(SDPrec * (row-1)* self.numCols, soFromCurrent) ;
       for t1 := 1 to self.numRows do     // for each row
       begin
          F_Mdata.Read(p1^,SDPrec) ;
          if SDPrec = 4 then
          begin
//             if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5 ;   // addedxxx
             if single(p1^) >  s_max then begin s_max := single(p1^) ; i_max := F_Mdata.Position - 4  ; end ;
             if single(p1^) <  s_min then begin s_min := single(p1^) ; i_min := F_Mdata.Position - 4   ; end ;
          end
          else
          begin
             if double(p1^) >  d_max then begin d_max := double(p1^) ; i_max :=  F_Mdata.Position - 8   ; end ;
             if double(p1^) <  d_min then begin d_min := double(p1^) ; i_min :=  F_Mdata.Position - 8   ; end ;
          end ;
       end ;
  end  ;

  if SDPrec = 4 then
  begin
    retValue := TMaxMin.Create(SDPrec) ;
    retValue.SetData(@s_min,1) ;
    retValue.SetData(@s_max,2) ;
    retValue.SetData(@i_min,3) ;
    retValue.SetData(@i_max,4) ;
  end
  else if SDPrec = 8 then
  begin
    retValue := TMaxMin.Create(SDPrec) ;
    retValue.SetData(@d_min,1) ;
    retValue.SetData(@d_max,2) ;
    retValue.SetData(@i_min,3) ;
    retValue.SetData(@i_max,4) ;
  end ;

  result := retValue ;   // have tofree this object when finished with it

//  retValue.SaveData('output1.txt') ;

  FreeMem(p1) ;
end ;



procedure TMatrix.VectSubProjectedFromMatrix(inputMatrix, eVectsIn : TMatrix )  ;
// subtract factor from original matrix to leave residuals
var
   mo : TMatrixOps ;

   MKLa, MKLEVects, MKLscores : pointer ;
   MKLtint, MKLlda : integer ;

   MKLbetas, SSEVects_s : single ;
   MKLbetad, SSEVects_d : double ;

   tScores : TMatrix ;  // these are created by projecting input eVectsIn onto input data
begin
      mo := TMatrixOps.Create ;

      if (inputMatrix.numCols = eVectsIn.numCols) then
      begin
        // create scores
        tScores := mo.MultiplyMatrixByMatrix(inputMatrix, eVectsIn, false, true, 1.0, false) ;

        // normalise eVectsIn
        SSEVects_s := snrm2 (eVectsIn.numCols, MKLEVects, MKLtint ) ; // = sqrt(sum of values)
        SSEVects_s := 1 / SSEVects_s ;

        MKLbetas  := -1.0 ;
        MKLbetad  := -1.0 ;
        MKLtint   :=  1 ;
        MKLa  :=  inputMatrix.F_Mdata.Memory ;
        MKLEVects := eVectsIn.F_Mdata.Memory ;
        MKLscores := tScores.F_Mdata.Memory ;
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

      end
      else
        WriteError('Column mismatch between data and projecting vector') ;

      mo.Free ;
end;


end.

