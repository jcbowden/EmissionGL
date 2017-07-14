unit TMatrixObject;

//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}

interface

uses  classes, SysUtils, dialogs, Math, TMaxMinObject, BLASLAPACKfreePas, TASMTimerUnit  ;


type RowsOrCols = (Rows, Cols);
TRealImSingle = Array[0..1] of single ;
TRealImDouble = Array[0..1] of double ;

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
    procedure   CopyMatrix(sourceMat : TMatrix)  ;  // Copies complete TMatrix from the sourceMat to self.
    procedure   SetSizeTMat(singleOrDouble: integer; numSpectra, numXCoords, complexMatIn  : integer) ;
    procedure   MakeComplex(   imaginaryPartMatrixAmagalmated : TMatrix) ;  // makes Re Im pairs from own data and input matix (interlaces)
    procedure   MakeUnComplex( imaginaryPartMatrixSeparated   : TMatrix) ;  // seperates Im data from Re data and places Im in the input matix (de-interlaces)

    function    CopyMemStrmToDouble( singleMSIn  : TMemoryStream; numValsIn : int64 )  : TMemoryStream;
    function    CopyMemStrmToSingle( doubleMSIn  : TMemoryStream;  numValsIn : int64) : TMemoryStream ;
    procedure   ConvertToDouble  () ;
    procedure   ConvertToSingle  () ;
    procedure   Free ;

    procedure Transpose ;
    procedure RotateRight ;
    procedure Zero(matrixTMemStream : TMemoryStream) ;
    procedure MeanCentre ;                        // subtracts Average of column from each spectra/row
    procedure ColStandardize ;
    procedure ParetoScale ;   // divide by sqrt of stdev
    procedure LevelScale  ;   // divide by mean
    procedure DivByInvCoefVar ;     // Use this to 'Vast scale' - first ColStandardize then call this function (divide by stdev and multiply by mean)
    procedure Average ;                           // places average of each column into MAverage TMemoryStream
    procedure AverageSmooth(numPoints : integer) ;
    function  AverageReduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;  // rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
    function  Reduce(inNumAves : integer; rowOrCol: RowsOrCols) : TMatrix ;
    procedure VectorNormaliseRowVects ;
    function  VectorNormaliseRowVectsReturnNew(inMatrix : TMatrix)  : TMatrix  ;
    function  ReturnTMatrixFromTMemStream(inStream : TMemoryStream; SDPrecIn, numRowIn, numColsIn : integer): TMatrix ;
    procedure Variance ;  // call Average() first
    procedure Stddev( calculateVariance : boolean ) ;     // call Average() first; calculateVariance == true if variance was not read in from file
    procedure ClearData(singleOrDouble : integer) ;
    procedure FillMatrixData(firstXIn, lastXIn : double) ;

    // basic maths functions
    function MultiplyRealImagReturnRealImagSingle( ri1, ri2 : array of single) : TRealImSingle ;
    function MultiplyRealImagReturnRealImagDouble( ri1, ri2 : array of double) : TRealImDouble ;
    procedure MultiplyByScalar(inputScalar : single) ;
    procedure DivideByScalar(inputScalar : single)   ;
    procedure AddScalar(inputScalar : single) ;
    // maths point by point functions
    procedure AddOrSubtractMatrix(M2 : TMatrix; plusminus : integer)  ;  //  each point of original matrix +- M1 points
    // maths vector functions
    function  AddVectToMatrixRows(memStrIn  :  TMemoryStream) : integer ;  // adds the data in memStrIn to each row of the matrix - used to add back mean to mean centred data
    procedure MultiplyMatrixByVect(vectMat :  TMatrix) ;                  // multiplies the data in vectMat to each row of the matrix - used to "scale" by variance
    // returns 1 on EZeroDivide error, otherwise 0
    function  DivideMatrixByVect(vectMat :  TMatrix) : integer ;  // divides each row of matrix by corresponding column in memStrIn - used to "un-variance scale"

    function  LoadMatrixDataFromTxtFile(filenameIn : string ;startLineIn, endLineIn, startColIn, endColIn: integer; inDelimeter : string) :  boolean  ;  //  rowOrCol = true if in rows rowOrCol = false if in cols
    function  LoadXMatrixDataFromMODISCSV(filenameIn : string ; startLineIn, endLineIn : integer) :  boolean ;
    function  FindScaleFromMODISCSV(filenameIn : string ) :  double ;
    function  DetermineDelimiter(inString : string; inDelimeter : string) : string  ;
    procedure SaveMatrixDataTxt(filenameOut : string; delimeter : string) ;  // save as text file - data in rows (not excel friendly)

    // binary file load/save procedures
    procedure LoadMatrixDataFromBinFile(filenameIn : string) ;  // load from binary file  - assumed format : <DATA><rowNum><colNum><meanCentred><colStandardized><firstXCoord><lastXCoord><SDPrec><'v2'>
    procedure LoadMatrixDataRawBinFile(filenameIn : string) ;   // only loads F_data, other fields are as they were (empty or previous value) therefore need to set them.
    procedure SaveMatrixDataBin(filenameOut : string; firstXIn, lastXIn : single) ;  // binary format :  <DATA><rowNum><colNum><meanCentred><colStandardized><firstXCoord><lastXCoord><SDPrec><'v2'>
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
    procedure AddRowToEndOfData(sourceMat : TMatrix; rowNumIn, numberOfColIn : integer ) ;
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
 //   function  GetOffDiagonal(inputMat : TMatrix) : TMemoryStream ;  // returns the diagonal elements of a square matrix
    procedure SetDiagonal(inputStr : TMemoryStream)  ;  // Sets the diagonal elements of itself to values in inputStr
    function  GetMinAndMaxValAndPos(row, col : integer ) : TMaxMin ;  // row = 0 means each row on specified column and col = 0 means each col on specified row
    procedure VectSubProjectedFromMatrix(inputMatrix, eVectsIn : TMatrix )  ;
    function  GetSlope : single ;
    function  GetSlopeForcedThroughZero : single ;
    function  GetYIntercept(slope : single) : Single ;

    function  FindCharacterData(inData : TMemoryStream; numberIn : integer)  : int64 ;// numberIn: the number the data to find has been repeated in the source data
    function  FindFloatInData(dataIn, accuarcyIn : single; numberIn : integer) : int64 ; // numberIn: the number the data to find has been repeated in the source data

  private
    procedure AverageSSE ;
    procedure ErrorDialog(errorStr : string) ;
end;




implementation

uses TMatrixOperations ;




//////////////////////////////////////////////////////////////////////////////////////
/////////////////////////// TMatrix implementation ///////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////

procedure TMatrix.ErrorDialog(errorStr : string) ;
begin
{$ifdef FREEPASCAL}
    writeln( errorStr ) ;
{$else}
    messagedlg( errorStr ,mtError,[mbOK],0) ;
{$endif}
end;



{$ifdef FREEPASCAL}
function TMatrix.MovePointer(tp : pointer; amount : int64 ) : pointer;
begin
   asm  // 64bit
     MOV     RAX,tp
     MOV     RDX,amount
     ADD     RAX,RDX
     MOV     @Result,RAX
   end;
end ;
{$else}
function TMatrix.MovePointer(tp : pointer; amount : integer ) : pointer;
begin
   asm
     MOV     EAX,tp
     MOV     EDX,amount
     ADD     EAX,EDX
     MOV     @Result,EAX
   end;
end ;
{$endif}



constructor TMatrix.Create(singleOrDouble : integer);
begin
//  inherited Create;
  if singleOrDouble = 1 then singleOrDouble := 4 ;
  if singleOrDouble = 2 then singleOrDouble := 8 ;

  SDPrec := singleOrDouble  ;
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
  try
    F_Mdata.SetSize(numRowsIn* numColsIn * SDPrec)
  except on EOutofMemory do
    ErrorDialog('out of memory creating TMatrix') ;
  end;
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


procedure TMatrix.FillMatrixData(firstXIn, lastXIn : double) ;
// fills a single row with a linear gradient
var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  inc_d  : double ;
begin
self.F_Mdata.Seek(0,soFromBeginning) ;
s1 := firstXIn ;
d1 := firstXIn ;
if (self.numCols-1) <> 0 then
begin
  inc_d := (lastXIn - firstXIn) / (self.numCols-1)  ;
  if self.SDPrec = 4 then
  begin
      for t1 := 1 to self.numCols do
      begin
        self.F_Mdata.Write(s1,4) ;
        s1 := s1 + inc_d ;
      end ;
  end
  else if self.SDPrec = 8 then
  begin
      for t1 := 1 to self.numCols do
      begin
        self.F_Mdata.Write(d1,8) ;
        d1 := d1 + inc_d ;
      end
  end ;
end  // if (self.numCols-1) <> 0
else
begin
  if self.SDPrec = 4 then
  begin
     self.F_Mdata.Write(s1,4) ;
  end
  else if self.SDPrec = 8 then
  begin
     self.F_Mdata.Write(d1,8) ;
  end ;
end;
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

procedure TMatrix.SetSizeTMat(singleOrDouble: integer; numSpectra, numXCoords, complexMatIn : integer) ;
begin
   self.ClearData(self.SDPrec) ;

   if singleOrDouble = 1 then singleOrDouble := 4 ;
   if singleOrDouble = 2 then singleOrDouble := 8 ;

   self.SDPrec            := singleOrDouble ; // single or double precision
   self.numRows           := numSpectra ;
   self.numCols           := numXCoords ;
   self.meanCentred       := false ;
   self.colStandardized   := false ;
   self.Filename          := ''  ;
   self.complexMat        := complexMatIn ;  // if = 1 then not complex if = 2 then
//   self.startLine         := sourceMat.startLine  ;

   try
     self.F_Mdata.SetSize(self.SDPrec * self.numRows * self.numCols * self.complexMat) ;  // probably not needed
   except on EOutofMemory do
      ErrorDialog('SetSizeTMat() error: out of memory') ;
   end;
   self.F_Mdata.Seek(0, soFromBeginning) ;
   self.F_MAverage.Seek(0, soFromBeginning) ;
   self.F_MVariance.Seek(0, soFromBeginning) ;
   self.F_MStdDev.Seek(0, soFromBeginning) ;

end ;




procedure   TMatrix.MakeComplex( imaginaryPartMatrixAmagalmated : TMatrix) ;  // makes Re Im pairs from own data and input matix (interlaces)
// imaginaryPartMatrixAmagalmated can be  = nil and zeros inserted
var
  t1 : integer ;
  tMemStr : TMemoryStream ;
  s1 : single ;
  d1 : double ;
begin

  if complexMat = 1 then
  begin
  if imaginaryPartMatrixAmagalmated <> nil then
  begin
    if self.F_Mdata.Size <>  imaginaryPartMatrixAmagalmated.F_Mdata.Size then
    begin
      ErrorDialog('TMatrix.MakeComplex() Error: Real and Imginary matrix size does not match. Have to exit') ;
      exit ;
    end ;
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
    imaginaryPartMatrixAmagalmated.F_Mdata.Seek(0,soFromBeginning) ;
  end  // if <> nil
  else
  if imaginaryPartMatrixAmagalmated = nil then
  begin
    tMemStr := TMemoryStream.Create ;
    tMemStr.SetSize(self.numRows*self.numCols*self.SDPrec*2) ;
    if SDPrec = 4 then
    begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(s1,4) ;
        tMemStr.Write(s1,4) ;
        s1 := 0.0 ;
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
        d1 := 0.0 ;
        tMemStr.Write(d1,8) ;
      end
    end ;

  end;
       
  // copy interlaced complex data
  self.F_Mdata.Seek(0,soFromBeginning) ;
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
    if imaginaryPartMatrixSeparated <> nil then
    begin

      // make sure input is the correct size
      imaginaryPartMatrixSeparated.F_Mdata.SetSize( self.numRows*self.numCols*self.SDPrec ) ;
      imaginaryPartMatrixSeparated.numCols := self.numCols ;
      imaginaryPartMatrixSeparated.numRows := self.numRows ;

      tMemStr := TMemoryStream.Create ;
      tMemStr.SetSize(self.numRows*self.numCols*self.SDPrec) ;

      tMemStr.Seek(0,soFromBeginning) ;
      self.F_Mdata.Seek(0,soFromBeginning) ;
      imaginaryPartMatrixSeparated.F_Mdata.Seek(0,soFromBeginning) ;

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
      // copy uninterlaced data
      self.F_Mdata.Seek(0,soFromBeginning) ;
      imaginaryPartMatrixSeparated.F_Mdata.Seek(0,soFromBeginning) ;
      tMemStr.Seek(0,soFromBeginning) ;
      self.F_Mdata.Clear ;
      self.F_Mdata.LoadFromStream(tMemStr) ;
      tMemStr.Free ;

    end
    else
    if imaginaryPartMatrixSeparated = nil then  // do not save the imaginary data if input TMatrix is specified as nil
    begin

      tMemStr := TMemoryStream.Create ;
      tMemStr.SetSize(self.numRows*self.numCols*self.SDPrec) ;
      self.F_Mdata.Seek(0,soFromBeginning) ;
      tMemStr.Seek(0,soFromBeginning) ;
      if SDPrec = 4 then
      begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(s1,8) ;
        tMemStr.Write(s1[1],4) ;
        s1[2] := t1 ;
      end
      end
      else
      if SDPrec = 8 then
      begin
      for t1 := 1 to  (self.numRows*self.numCols) do
      begin
        self.F_Mdata.Read(d1,16) ;
        tMemStr.Write(d1[1],8) ;
      end
      end ;
      // copy uninterlaced data
      self.F_Mdata.Seek(0,soFromBeginning) ;
      tMemStr.Seek(0,soFromBeginning) ;
      self.F_Mdata.Clear ;
      self.F_Mdata.LoadFromStream(tMemStr) ;
      tMemStr.Free ;
    end;


    complexMat := 1 ;
  end ;
end ;


 //function CMatrix.CopyMemStrmToSingle(TMemoryStream* doubleMSIn, int64 numVals ) : TMemoryStream ;
procedure TMatrix.ConvertToSingle  () ;
var
  numberOfValues_64 : int64  ;
begin

	if (self.SDPrec = sizeof(double)) then
  begin
		self.SDPrec := sizeof(single) ;

		numberOfValues_64 := self.numRows * self.numCols * self.complexMat ;	// new number of values in CMatrix
		F_Mdata.Seek(0,soFromBeginning) ;
		F_Mdata := CopyMemStrmToSingle(F_Mdata, numberOfValues_64) ;
    F_Mdata.Seek(0,soFromBeginning) ;
		
		numberOfValues_64 := self.numCols *self.complexMat ;	// new number of values in CMatrix
		
		if (self.F_MAverage.Memory <> nil) then
		begin
		  F_MAverage.Seek(0,soFromBeginning) ;
		  F_MAverage := CopyMemStrmToSingle(F_MAverage, numberOfValues_64) ;
      F_MAverage.Seek(0,soFromBeginning) ;
		end ;
		if (F_MVariance.Memory <> nil) then
		begin
		  F_MVariance.Seek(0,soFromBeginning) ;
		  F_MVariance := CopyMemStrmToSingle(F_MVariance, numberOfValues_64) ;
      F_MVariance.Seek(0,soFromBeginning) ;
		end ;
		if (F_MStdDev.Memory <> nil) then
		begin
		  F_MStdDev.Seek(0,soFromBeginning) ;
		  F_MStdDev := CopyMemStrmToSingle(F_MStdDev, numberOfValues_64) ;
      F_MStdDev.Seek(0,soFromBeginning) ;
		end ;


	end ; // if (this->SDPrec == sizeof(float)

end ;


function TMatrix.CopyMemStrmToSingle( doubleMSIn : TMemoryStream;  numValsIn : int64) : TMemoryStream ;
// assumes a double precision MS in and converts it to single precsision and deletes input Matrix
var
  t1 : integer ;
  s1 : single;
  d1 : double;
  singleMSout: TMemoryStream ;
begin

  doubleMSIn.Seek(0,soFromBeginning)  ;
  singleMSout := TMemoryStream.Create() ;
	try
	  begin
		  singleMSout.SetSize( numValsIn * sizeof(single)) ;
	  end
	except
	begin
		ErrorDialog('Error CMatrix::CopyMemStrmToSingle():  ') ;
		singleMSout.Free ;
		exit ;
	end;
  end;

	singleMSout.Seek(0,soFromBeginning) ;
  doubleMSIn.Seek(0,soFromBeginning) ;
	for t1 := 1 to (numValsIn) do
	begin
		doubleMSIn.Read(&d1,sizeof(double)) ;
		s1 := d1 ;
		singleMSout.Write(&s1,sizeof(single)) ;
	end;

	doubleMSIn.Free ;
	result := singleMSout ;
  result.Seek(0,soFromBeginning) ;

end;



 

 
procedure   TMatrix.ConvertToDouble ;
var
  s1 : single ;
  d1 : double ;
  numberOfValues_64  : int64  ;
begin
  if SDPrec = 4 then
  begin
	  SDPrec := sizeof(double)  ;

    numberOfValues_64 := self.numRows * self.numCols * self.complexMat ;	// new number of values in CMatrix
		F_Mdata.Seek(0,soFromBeginning) ;
		F_Mdata := CopyMemStrmToDouble(F_Mdata, numberOfValues_64) ;
    numberOfValues_64 := self.numCols *self.complexMat ;	// new number of values in CMatrix
		
		if (self.F_MAverage.Memory <> nil) then
		begin
		  F_MAverage.Seek(0,soFromBeginning) ;
		  F_MAverage := CopyMemStrmToDouble(F_MAverage, numberOfValues_64) ;
		end ;
		if (F_MVariance.Memory <> nil) then
		begin
		  F_MVariance.Seek(0,soFromBeginning) ;
		  F_MVariance := CopyMemStrmToDouble(F_MVariance, numberOfValues_64) ;
		end ;
		if (F_MStdDev.Memory <> nil) then
		begin
		  F_MStdDev.Seek(0,soFromBeginning) ;
		  F_MStdDev := CopyMemStrmToDouble(F_MStdDev, numberOfValues_64) ;
		end ;


	end ;
end ;

// this is a private function
// copies data from a double precision stream to a single precision stream, replacing the original stream
function   TMatrix.CopyMemStrmToDouble( singleMSIn  : TMemoryStream; numValsIn : int64 ) : TMemoryStream;
var
  t1_64 : int64 ;
  t1 : integer ;
  s1 : single ;
  d1 : double ;
  doubleMSout : TMemoryStream ;
 begin

 singleMSIn.Seek(0,soFromBeginning)  ;
 doubleMSout := TMemoryStream.Create ;

	try
		doubleMSout.SetSize(numValsIn * sizeof(double)) ;
	except  on EOutofMemory do
	begin
      ErrorDialog('TMatrix.CopyMemStrmToDouble(): Out of Memory' ) ;
	    doubleMSout.Free ;
      exit ;
	end;
	end ;

	doubleMSout.seek(0,soFromBeginning) ;
	for t1 := 1 to numValsIn do
	begin
		singleMSIn.read(s1,sizeof(single)) ;
		d1 := s1 ;
		doubleMSout.write(d1,sizeof(double)) ;
	end ;

	singleMSIn.Free ;
  result := doubleMSout ;
  result.Seek(0,soFromBeginning) ;
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



procedure TMatrix.Zero(matrixTMemStream : TMemoryStream) ;
Var
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
    s1 := 0.0 ;
    d1 := 0.0 ;
    matrixTMemStream.Seek(0,soFromBeginning) ;

    if SDPrec = 4 then
     begin
       for t1 := 1 to (matrixTMemStream.Size div 4)  do
       begin
         matrixTMemStream.Write(s1,4) ;
         if self.complexMat = 2 then
            matrixTMemStream.Write(s1,4) ;
       end ;
     end
     else  //  SDPrec = 8
     begin
       for t1 := 1 to (matrixTMemStream.Size div 4)  do
       begin
         matrixTMemStream.Write(d1,8) ;
         if self.complexMat = 2 then
            matrixTMemStream.Write(d1,8) ;
       end ;
     end ;
    matrixTMemStream.Seek(0,soFromBeginning) ;
end ;


{$ifdef FREEPASCAL}      // 64 bit version
procedure TMatrix.AverageSSE ;
var
   t1, t2, t3 : int64 ;
   pdata, pave : pointer ;
   s1 : single ;
   d1 : double ;
begin
  F_Mdata.Seek(0,soFromBeginning) ;
  pdata := F_Mdata.memory ;
  if SDPrec = 4 then   // single precision
  begin
    t2 := ((numCols * complexmat) div 4) ;
    t3 := ((numCols * complexmat) mod 4) ;  // the remainer after the above
//if t3 = 0 then Write('AverageSSE(): all rows are 16 byte aligned')
//else Writeln('AverageSSE(): Each row is not 16 byte aligned') ;
//Writeln(Int64(pdata)) ;

   for t1 := 1 to numRows do
   begin
     F_MAverage.Seek(0,soFromBeginning) ;
     pave := F_MAverage.memory ;

     if t3 = 0 then
     begin
     if t2 > 0 then
     begin
     asm   // 64bit
       push rsi
       push rdi
       push rcx
       MOV rdi, pdata
       mov rsi, pave
       mov rcx, t2   {this is the loop counter}
       @loop:
       movaps xmm1, [rdi]
       movaps xmm0, [rsi]
       addps   xmm0, xmm1
       movaps [rsi],xmm0
       add rdi, 16
       add rsi, 16
       dec rcx
       jnz @loop

       MOV pdata, rdi   // store latest data pointer area
       pop rcx
       pop rdi
       pop rsi
     end;
     end ;
     end
     else  // t3 <> 0
// this looks after data where each row is not aligned on 16 byte increment
     begin
     if t2 > 0 then
     begin
       asm    // 64bit
         push rsi
         push rdi
         push rcx
         MOV rdi, pdata
         mov rsi, pave
         mov rcx, t2   {this is the loop counter}
         @loop:
         movups xmm1, [rdi]
         movups xmm0, [rsi]
         addps   xmm0, xmm1
         movups [rsi],xmm0
         add rdi, 16
         add rsi, 16
         dec rcx
         jnz @loop

         MOV pdata, edi   // store latest data pointer area
         MOV pave, esi
         pop rcx
         pop rdi
         pop rsi
       end;
     end;
     asm // 64bit this looks after scraggly end bits if numCols is not perfectly divisible by 4
       push rsi
       push rdi
       push rcx
       mov rsi, pdata
       mov rdi, pave
       mov rcx, t3   //this is the loop counter
       FINIT
     @loop:
       fld [rsi]
       FADD [rdi]
       FSTP [rdi]
       add rdi, 4
       add rsi, 4
       dec rcx
     jnz @loop
       mov pdata, rsi   // update pdata with current position
       pop rcx
       pop rdi
       pop rsi
      end;
     end;
    end;   // numRows

// this does the division by the number of samples to get the average
    s1 := 1 / numRows ;
    t2 := (numCols * complexmat) ;
    pave := F_MAverage.memory ;
    // Multiply all average data by 1/numRows
    asm    // 64bit
       push rsi
       push rcx
       mov rsi, pave
       mov rcx, t2   // this is the loop counter
       @loop:
       fld [rsi]
       FMUL s1
       FSTP [rsi]    // FSTP = store and pop stack
       add rsi, 4
       dec rcx
       jnz @loop
       pop rcx
       pop rsi
     end;

     F_MAverage.Seek(0,soFromBeginning) ;
     F_MAverage.Read(s1, SDPrec) ;

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
     asm       // 64bit
       push rsi
       push rdi
       push rcx
       MOV rdi, pdata
       mov rsi, pave
       mov rcx, t2   {this is the loop counter}
       @loop:
       movapd  xmm1, [rdi] // these are the fastest instructions
       movapd  xmm0, [rsi]
       addpd   xmm0, xmm1
       movapd  [rsi],xmm0
       add rdi, 16
       add rsi, 16
       dec rcx
       jnz @loop

       MOV pdata, edi   // store latest data pointer area
       pop rcx
       pop rdi
       pop rsi
     end;
     end ;
     end
     else  // t3 <> 0
// this looks after data where each row is not aligned on 16 byte increment
     begin
     if t2 > 0 then
     begin
     asm    // 64bit
       push rsi
       push rdi
       push rcx
       MOV rdi, pdata
       mov rsi, pave
       mov rcx, t2   {this is the loop counter}
       @loop:
       movupd  xmm1, [rdi]
       movupd  xmm0, [rsi]
       addpd   xmm0, xmm1
       movupd  [rsi],xmm0
       add rdi, 16
       add rsi, 16
       dec rcx
       jnz @loop

       MOV pdata, rdi   // store latest data pointer area
       MOV pave, rsi
       pop rcx
       pop rdi
       pop rsi
     end;
     end;
     asm    // 64bit this looks after scraggly end bits if numCols is not perfectly divisible by 2
       push rsi
       push rdi
       push rcx
       mov rsi, pdata
       mov rdi, pave
       mov rcx, t3   //this is the loop counter
       FINIT
     @loop:
       fld [rsi]
       FADD [rdi]
       FSTP [rdi]
       add rdi, 8
       add rsi, 8
       dec rcx
     jnz @loop
       mov pdata, rsi   // update pdata with current position
       pop rcx
       pop rdi
       pop rsi
      end;
     end;
    end;   // numRows

    d1 := 1 / numRows ;
    pave := F_MAverage.memory ;
    t2 := (numCols * complexmat) ;
    asm
       push rsi
       push rcx
       mov rsi, pave
       mov rcx, t2   // this is the loop counter
    @loop:
       fld [rsi]
       FMUL d1
       FSTP [rsi]    // FSTP = store and pop stack
       add rsi, 8
       dec rcx
    jnz @loop
       pop rcx
       pop rsi
     end;
   end  ; // if SDPrec = 8 then
end ;
{$else}      //  32 bit version

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
{$endif}  // end 32 bit version


{$ifdef FREEPASCAL}      // 64 bit version
// calculates per point average down columns and places result in F_MAverage MemoryStream
procedure TMatrix.Average() ;      // can **not** deal with complex
var
   t1, t2, t3 : int64 ;
   pave, pdata : pointer ;
   s1, s2 : single ;
   d1, d2 : double ;
   tTimer : TASMTimer ;
   matS1, matS2 : Array[0..3] of single ;
   matD1, matD2 : Array[0..3] of double ;
label
  loop, loop2 ;
begin

// asm code really fast!
F_MAverage.SetSize(numCols * SDPrec * complexmat) ;
Zero(F_MAverage) ;

t3 := (integer(F_Mdata.Memory) mod 16) ;
t3 :=  t3 +  (integer(F_MAverage.Memory) mod 16) ;
if t3 <> 0 then
begin

//Writeln('Average():') ;
  F_Mdata.Seek(0,soFromBeginning) ;
  F_MAverage.Seek(0,soFromBeginning) ;

  pdata  := F_Mdata.memory ;
  if SDPrec = 4 then   // single precision
  begin
   t2 := (numCols * complexmat)  ;  //
   for t1 := 1 to numRows do
   begin
//Writeln('Sum: ') ;
     pave   := F_MAverage.memory ;
     asm
       push rsi
       push rdi
       push rcx
       mov rsi, pdata
       mov rdi, pave
       mov rcx, t2   //this is the loop counter
       FINIT
     @loop:
       fld  [rsi]
       fadd [rdi]
       fstp [rdi]
       add rdi, 4
       add rsi, 4
       dec rcx
     jnz @loop
       mov pdata, rsi   // update pdata with current position
       pop rcx
       pop rdi
       pop rsi
      end;
   end ;  // end row
//Writeln('s1 is 1 / numRows: ') ;
   s1 := 1 / numRows ;
//Writeln('seek to start of data: ') ;
   F_MAverage.Seek(0,soFromBeginning) ;  // divide by number of cols
   for t2 := 1 to (numCols * complexmat) do
   begin
        F_MAverage.Read(s2,SDPrec) ;
        s2 := s2 * s1 ;
        F_MAverage.Seek(-SDPrec,soFromCurrent) ;
        F_MAverage.Write(s2,SDPrec) ;
   end ;
//Writeln('Done division: ') ;
  end
  else
  if SDPrec = 8 then   // double precision
  begin
   t2 := (numCols * complexmat)  ;  //
   for t1 := 1 to numRows do
   begin
//     F_MAverage.Seek(0,soFromBeginning) ;
     pave   := F_MAverage.memory ;
     asm
       push rsi
       push rdi
       mov rsi, pdata
       mov rdi, pave
       mov rcx, t2   //this is the loop counter
       FINIT
     @loop:
       fld  [rsi]
       fadd [rdi]
       fstp [rdi]
       add rdi, 8
       add rsi, 8
       dec rcx
     jnz @loop
       mov pdata, rsi   // update pdata with current position
       pop rdi
       pop rsi
      end;
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

end
else  // data is 16 byte aligned => do SSE instructions
begin
   AverageSSE() ;
end;

end ;


{$else}  // 32 bit version
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
t3 :=  t3 +  (integer(F_MAverage.Memory) mod 16) ;
if t3 <> 0 then
begin

//tTimer := TASMTimer.Create(0) ;
//tTimer.setTimeDifSecUpdateT1 ;

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

//tTimer.setTimeDifSecUpdateT1 ;
//tTimer.outputTimeSec('Average FPU time: ');

end
else  // data is 16 byte aligned => do SSE instructions
begin
   AverageSSE() ;
end;

end ;
{$endif}  // 32 bit version


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
  ErrorDialog('TMatrix.AverageSmooth Error: number of points to use has to be an odd number') ;

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
     ErrorDialog('TMatrix.MultiplyByScalar() Error: Overflow error' ) ;
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
     ErrorDialog('TMatrix.MultiplyByScalar() Error: Overflow error' ) ;
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
  ErrorDialog('TMatrix.AddOrSubtractMatrix Error: matricies not same size' ) ;


  self.F_Mdata.Seek(0, SoFromBeginning) ;
  M2.F_Mdata.Seek(0, SoFromBeginning) ;

end ;


function TMatrix.DivideMatrixByVect(vectMat :  TMatrix) : integer ;  // adds the data in memStrIn to each row of the matrix - used to "Un-scale" by variance
// returns 1 on EZeroDivide error, otherwise 0
var                                                                // cannot deal with complex numbers
  t1, t2, dataSizeBytes : integer ;
  sri1, sri2, sri3 : TRealImSingle ;  //  array[0..1] of single ; ;
  dri1, dri2, dri3 : TRealImDouble ;  //  array[0..1] of double ;
  initialPos : integer ;
begin
// start from start of data
  self.F_Mdata.Seek(0, SoFromBeginning) ;
  vectMat.F_Mdata.Seek(0, SoFromBeginning) ;


  if (self.numCols) = (vectMat.numCols) then
  begin

  // this makes sure both TMatrix are the same format
  if (self.complexMat = 2) or (vectMat.complexMat = 2) then
  begin
    self.MakeComplex(nil);
    vectMat.MakeComplex(nil);
  end;

  // precalculate the full size in bytes
  dataSizeBytes := self.SDPrec * self.complexMat  ;

  if SDPrec = 4 then
  begin

  for t1 := 1 to self.numRows do
  begin
    // for real data only
    if (self.complexMat = 1) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(sri1[0],dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(sri1[1],dataSizeBytes) ;
        sri1[0] := sri1[0] / sri1[0] ;
        self.F_Mdata.Write(sri1,dataSizeBytes) ;
      end ;
    end
    else if (self.complexMat = 2) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(sri1,dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(sri2,dataSizeBytes) ;
        sri3[0] := sri2[0] ;  //  Complex conjugate
        sri3[1] := -1 * sri2[1] ;
        sri1 := MultiplyRealImagReturnRealImagSingle(sri1, sri3) ;
        sri2[0] := (sri2[0] * sri2[0]) + (sri2[1] * sri2[1]) ;
        sri1[0] := sri1[0] / sri2[0] ;
        sri1[1] := sri1[0] / sri2[0] ;
        self.F_Mdata.Write(sri1,dataSizeBytes) ;
      end ;
    end;

    vectMat.F_Mdata.Seek(0, SoFromBeginning) ;
  end ;

  end
  else if SDPrec = 8 then
  begin
  for t1 := 1 to self.numRows do
  begin
    if (self.complexMat = 1) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(dri1[0],dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(dri1[1],dataSizeBytes) ;
        dri1[0] := dri1[0] / dri1[0] ;
        self.F_Mdata.Write(dri1,dataSizeBytes) ;
      end ;
    end
    else if (self.complexMat = 2) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(dri1,dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(dri2,dataSizeBytes) ;
        dri3[0] := dri2[0] ;  //  Complex conjugate
        dri3[1] := -1 * dri2[1] ;
        dri1 := MultiplyRealImagReturnRealImagDouble(dri1, dri3) ;
        dri2[0] := (dri2[0] * dri2[0]) + (dri2[1] * dri2[1]) ;
        dri1[0] := dri1[0] / dri2[0] ;
        dri1[1] := dri1[0] / dri2[0] ;
        self.F_Mdata.Write(dri1,dataSizeBytes) ;
      end ;
    end;
    vectMat.F_Mdata.Seek(0, SoFromBeginning) ;
  end ;
  end ;

  end
  else // (self.numCols) <> (vectMat.numCols)
   ErrorDialog('DivideMatixByVect Error: number of columns are not the same in matrix and vector' ) ;

//end ;

end ;


procedure TMatrix.MultiplyMatrixByVect(vectMat :  TMatrix) ;  // multiplys the data in memStrIn to each row of the matrix - used to "scale" by variance
var                                                                // cannot deal with complex numbers
  t1, t2, dataSizeBytes : integer ;
  sri1, sri2 : TRealImSingle ;  //  array[0..1] of single ; ;
  dri1, dri2 : TRealImDouble ;  //  array[0..1] of double ;
  initialPos : integer ;
begin
// start from start of data
  self.F_Mdata.Seek(0, SoFromBeginning) ;
  vectMat.F_Mdata.Seek(0, SoFromBeginning) ;


  if (self.numCols) = (vectMat.numCols) then
  begin

  // this makes sure both TMatrix are the same format
  if (self.complexMat = 2) or (vectMat.complexMat = 2) then
  begin
    self.MakeComplex(nil);
    vectMat.MakeComplex(nil);
  end;

  // precalculate the full size in bytes
  dataSizeBytes := self.SDPrec * self.complexMat  ;

  if SDPrec = 4 then
  begin

  for t1 := 1 to self.numRows do
  begin
    // for real data only
    if (self.complexMat = 1) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(sri1[0],dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(sri1[1],dataSizeBytes) ;
        sri1[0] := sri1[0] * sri1[1] ;
        self.F_Mdata.Write(sri1,dataSizeBytes) ;
      end ;
    end
    else if (self.complexMat = 2) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(sri1,dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(sri2,dataSizeBytes) ;
        sri1 := MultiplyRealImagReturnRealImagSingle(sri1, sri2) ;
        self.F_Mdata.Write(sri1,dataSizeBytes) ;
      end ;
    end;

    vectMat.F_Mdata.Seek(0, SoFromBeginning) ;
  end ;

  end
  else if SDPrec = 8 then
  begin
  for t1 := 1 to self.numRows do
  begin
    if (self.complexMat = 1) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(dri1[0],dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(dri1[1],dataSizeBytes) ;
        dri1[0] := dri1[0] * dri1[0] ;
        self.F_Mdata.Write(dri1,dataSizeBytes) ;
      end ;
    end
    else if (self.complexMat = 2) then
    begin
      for t2 := 1 to (self.numCols) do
      begin
        self.F_Mdata.Read(dri1,dataSizeBytes) ;
        self.F_Mdata.Seek(-dataSizeBytes, soFromCurrent) ;
        vectMat.F_Mdata.Read(dri2,dataSizeBytes) ;
        dri1 := MultiplyRealImagReturnRealImagDouble(dri1, dri2) ;
        self.F_Mdata.Write(dri1,dataSizeBytes) ;
      end ;
    end;
    vectMat.F_Mdata.Seek(0, SoFromBeginning) ;
  end ;
  end ;

  end
  else // (self.numCols) <> (vectMat.numCols)
   ErrorDialog('MultiplyMatixByVect Error: number of columns are not the same in matrix and vector' ) ;

end ;



function TMatrix.MultiplyRealImagReturnRealImagSingle( ri1, ri2 : array of single) : TRealImSingle ;
var
  resRealIm : TRealImSingle ; //  equivalent to: array[0..1] of single ;
begin
  resRealIm[0] := (ri1[0] * ri2[0]) - (ri1[1] * ri2[1]) ;
  resRealIm[1] := (ri1[0] * ri2[1]) + (ri1[1] * ri2[0]) ;
  result :=  resRealIm ;
end ;

function TMatrix.MultiplyRealImagReturnRealImagDouble( ri1, ri2 : array of double) : TRealImDouble ;
var
  resRealIm :  TRealImDouble ;  //  equivalent to:   array[0..1] of double ;
begin
  resRealIm[0] := (ri1[0] * ri2[0]) - (ri1[1] * ri2[1]) ;
  resRealIm[1] := (ri1[0] * ri2[1]) + (ri1[1] * ri2[0]) ;
  result :=  resRealIm ;
end ;


// Adds a selected row (rowNumIn) to the end of the calling matrix
// numColIn : is number of columns in sourceMatrix and should match number of columns in matrix being added to
procedure TMatrix.AddRowToEndOfData(sourceMat : TMatrix; rowNumIn, numberOfColIn : integer ) ;
var
  oldsize : integer  ;
  t1 : integer ;
  p1 : pointer ;
begin
  GetMem(p1, self.SDPrec * self.complexMat) ;
  oldSize := self.F_Mdata.Size ;
  self.F_Mdata.SetSize(oldSize+(numberOfColIn * self.SDPrec * self.complexMat)) ;
  self.F_Mdata.Seek(oldSize,soFromBeginning) ;
  sourceMat.F_Mdata.Seek((rowNumIn-1) * numberOfColIn * sourceMat.SDPrec * sourceMat.complexMat,soFromBeginning) ;

  if numberOfColIn = self.numCols then
  begin
    for t1 := 1 to numberOfColIn  do
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
    for t1 := 0 to numberOfColIn -1 do
    begin
      sourceMat.F_Mdata.Read(p1^,self.SDPrec  * self.complexMat) ;
      self.F_Mdata.Write(p1^,self.SDPrec  * self.complexMat) ;
    end ;
    self.numRows := 1 ;
    self.numCols := numberOfColIn ;
    end ;
  end
  else
  begin
     ErrorDialog('AddRowToEndOfData() Error: number of columns of input does not match number of columns of TMatrix being added to' ) ;
     self.F_Mdata.SetSize(oldSize) ;
     self.F_Mdata.Seek(0,soFromBeginning) ;
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
      ErrorDialog('AddRowsToTMatrix() Error: number of columns of input does not match number of columns of TMatrix being added to') ;
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
     ErrorDialog('AddColToEndOfData() Error: number of rows of input does not match number of rows of TMatrix') ;
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
     ErrorDialog('TMatrix.AddColumnsToMatrix() Error: Incorrect number of rows in column data.') ;
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
      ErrorDialog('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid numeric input') ;
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
    ErrorDialog('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid input') ;
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
          ErrorDialog('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_dash-1)+'" is not a valid numeric input' ) ;
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
          ErrorDialog('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
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
      ErrorDialog('TMatrix.CheckRangeInput() Error: "'+ rangeIn + '" is not a valid input') ;
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
          ErrorDialog('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
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
          ErrorDialog('TMatrix.CheckRangeInput() Error: "'+copy(Range,1,pos_comma-1)+'" is not a valid numeric input' ) ;
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
      ErrorDialog('TMatrix.CheckRangeInput() Error: "'+ rangeIn +'" is not a valid input') ;
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


   if pos('-',trim(rowRange)) = length(trim(rowRange)) then       // sampleRange string is open ended (e.g. '12-')
    rowRange := rowRange + inttostr(sourceMatrix.numRows) ;
   if pos('-',trim(colRange)) = length(trim(colRange)) then       // sampleRange string is open ended (e.g. '12-')
    colRange := colRange + inttostr(sourceMatrix.numCols) ;


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
     ErrorDialog('Error: TMatrix.FetchDataFromTMatrix(): Input data range not valid') ;
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
     ErrorDialog('Error: TMatrix.FetchDataFromTFileStream(): Input data range not valid') ;
end ;


procedure TMatrix.Stddev( calculateVariance : boolean)  ;  // is the sqrt of the variance
var
   t1 : integer ;
   s1 : TSingle ;
   d1 : TDouble ;
   root_s, cs : single ;
   root_d, cd : double ;
begin

  if (calculateVariance) or (self.F_MVariance.Size <> numCols*SDPrec*complexMat) then
    self.Variance ;
  F_MStdDev.SetSize(numCols*SDPrec*complexMat) ;
  F_MStdDev.Seek(0,soFromBeginning) ;
  F_MVariance.Seek(0,soFromBeginning) ;

   cs := 0.70710678118654752440084436210485 ;
   cd := 0.70710678118654752440084436210485 ;

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
       {root_s :=  sqrt((s1[1]*s1[1])+(s1[2]*s1[2])) ;
       s1[1]  :=  sqrt( ( root_s - s1[1]) / 2  )  ;
       s1[2]  :=  s1[2] / (2 * s1[1]) ;
       root_s :=  s1[1] ;
       s1[1]  :=  s1[2] ;
       s1[2]  :=  root_s ; }
       root_s := sqrt((s1[1] *s1[1] )+(s1[2]*s1[2])) ;
       s1[1]  := sqrt(root_s + s1[1]) * cs ;
       if (s1[2] = 0) then
	        s1[2] := 0.0
       else
       if (s1[2] > 0) then
         s1[2]:=  sqrt(root_s - s1[2]) * cs
       else
         s1[2]:=  -1* sqrt(root_s - s1[2]) * cs   ;

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
      { d1[1]  :=  sqrt( ( root_d - d1[1]) / 2  )  ;
       d1[2]  :=  d1[2] / (2 * d1[1]) ;
       root_d :=  d1[1] ;
       d1[1]  :=  d1[2] ;
       d1[2]  :=  root_d ;        }
       d1[1]  := sqrt(root_d + d1[1]) * cd ;
       if (d1[2] = 0) then
	        d1[2] := 0.0
       else
       if (d1[2] > 0) then
         d1[2]:=  sqrt(root_s - d1[2]) * cd
       else
         d1[2]:=  -1* sqrt(root_d - d1[2]) * cd   ;
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

   if (F_MAverage.Size <> numCols*SDPrec*complexMat) then
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
//  if  colStandardized = false then
//  begin
    if F_MStdDev.Size = 0 then
    begin
      if self.meanCentred = false then
        self.Average ;
      self.Stddev(true) ;
    end;

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
           if stddevs <> 0 then
           s1 := s1 / stddevs ;
           F_Mdata.Write(s1,SDPrec) ;
         end
         else
         begin
           F_Mdata.Read(d1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MStdDev.Read(stddevd,SDPrec) ;
           if stddevd <> 0 then
           d1 := d1 / stddevd ;
           F_Mdata.Write(d1,SDPrec) ;
         end ;
      end ;
    end ;

    colStandardized := true ;

//  end ;
end ;




procedure TMatrix.ParetoScale ;    // not complex number friendly
var
  t1, t2 : integer ;
  s1, stddevs : single ;
  d1, stddevd : double ;
begin
//  if  colStandardized = false then
//  begin
    if F_MStdDev.Size = 0 then
    begin
      self.Average ;
      self.Stddev(true) ;
    end;


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
           if stddevs <> 0 then
           s1 := s1 / sqrt(stddevs) ;
           F_Mdata.Write(s1,SDPrec) ;
         end
         else
         begin
           F_Mdata.Read(d1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MStdDev.Read(stddevd,SDPrec) ;
           if stddevd <> 0 then
           d1 := d1 / sqrt(stddevd) ;
           F_Mdata.Write(d1,SDPrec) ;
         end ;
      end ;
    end ;

    colStandardized := true ;

//  end ;
end ;




procedure TMatrix.DivByInvCoefVar ;    // not complex number friendly
var
  t1, t2 : integer ;
  s1, ave_s, stddev_s : single ;
  d1, ave_d, stddev_d : double ;
begin
//  if  colStandardized = false then
//  begin
    if F_MAverage.Size = 0 then
    begin
      self.Average ;
    end;
    if F_MStdDev.Size = 0 then
    begin
      self.Stddev(true) ;
    end;


    F_MAverage.Seek(0,soFromBeginning) ;
    F_MStdDev.Seek(0,soFromBeginning) ;
    F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 1 to numRows do
    begin
      F_MAverage.Seek(0,soFromBeginning) ;
      F_MStdDev.Seek(0,soFromBeginning) ;
      for t2 := 1 to numCols do
      begin
         if  SDPrec = 4 then
         begin
           F_Mdata.Read(s1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(ave_s,SDPrec) ;
           F_MStdDev.Read(stddev_s,SDPrec) ;
           if stddev_s <> 0 then
           s1 := (s1 * ave_s) / stddev_s ;
           F_Mdata.Write(s1,SDPrec) ;
         end
         else
         begin
           F_Mdata.Read(d1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(ave_d,SDPrec) ;
           F_MStdDev.Read(stddev_d,SDPrec) ;
           if stddev_d <> 0 then
           d1 := (d1 * ave_d) /  stddev_d ;
           F_Mdata.Write(d1,SDPrec) ;
         end ;
      end ;
    end ;
    F_MAverage.Seek(0,soFromBeginning) ;
    F_MStdDev.Seek(0,soFromBeginning) ;
    F_Mdata.Seek(0,soFromBeginning) ;

//  end ;
end ;




procedure TMatrix.LevelScale ;    // not complex number friendly
var
  t1, t2 : integer ;
  s1, ave_s : single ;
  d1, ave_d : double ;
begin
//  if  colStandardized = false then
//  begin


 //   if self.meanCentred = false then
 //   begin
//      self.Average ;
 //   end;

    F_MAverage.Seek(0,soFromBeginning) ;
    F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 1 to numRows do
    begin
      F_MAverage.Seek(0,soFromBeginning) ;
      for t2 := 1 to numCols do
      begin
         if  SDPrec = 4 then
         begin
           F_Mdata.Read(s1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(ave_s,SDPrec) ;
           if ave_s <> 0 then
           s1 := s1 / ave_s ;
           F_Mdata.Write(s1,SDPrec) ;
         end
         else
         begin
           F_Mdata.Read(d1,SDPrec) ;
           F_Mdata.Seek(-SDPrec,soFromCurrent) ;
           F_MAverage.Read(ave_d,SDPrec) ;
           if ave_d <> 0 then
           d1 := d1 / ave_d ;
           F_Mdata.Write(d1,SDPrec) ;
         end ;
      end ;
    end ;

    colStandardized := true ;

//  end ;
end ;

procedure TMatrix.MeanCentre() ;
var
   t1, t2 : integer ;
   pdata, pave  : pointer  ; // pointer to the stream that stores the average values
   s1, s2 : single ;
   d1, d2 : double ;
//   tTimer : TASMTimer ;
begin

//  if  meanCentred = false then
//  begin

   self.Average ;

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
//tTimer.Free ;


// end ;
 
 
 
end ;


// rows1orCols2 = 1 then average rows or rows1orCols2 = 2 = average cols
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
// similar to AverageReduce, without the average of the set being the new value
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
// works on 2 columns of data
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
        ErrorDialog('Error: TMatrix.GetSlope(): Slope is infinite (div by zero error)') ;


      FreeMem(x_ave) ;
      FreeMem(y_ave) ;
      FreeMem(s1) ;
      FreeMem(s2) ;
    end
    else
      ErrorDialog('Error: TMatrix.GetSlope(): Slope can only be determined for data in 2 columns' ) ;
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
      ErrorDialog('Error: TMatrix.GetIntercept(): Intercept can only be determined for data in 2 columns' ) ;
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
        ErrorDialog('Error: TMatrix.GetSlopeForcedThroughZero(): Slope is infinite (div by zero error)' ) ;

      FreeMem(x_ave) ;
      FreeMem(y_ave) ;
    end
    else
      ErrorDialog('Error: TMatrix.GetSlopeForcedThroughZero(): Slope can only be determined for data in 2 columns' ) ;
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
    inputMat.F_Mdata.Seek(0,soFromBeginning) ;
    GetMem(p1,inputMat.SDPrec * self.complexMat ) ;
    tMemstr := TMemoryStream.Create ;
    tMemstr.SetSize( inputMat.numCols * inputMat.SDPrec * self.complexMat) ;
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

{
function  TMatrix.GetOffDiagonal(inputMat : TMatrix) : TMemoryStream ;   // complex number friendly
// returns the diagonal elements of a square matrix 'inputMat'
var
  tMemstr : TMemoryStream ;
  t1 : integer ;
  p1 : pointer ;
  jump : integer ;
begin
  if inputMat.numRows = inputMat.numCols then
  begin
    inputMat.F_Mdata.Seek(0,soFromBeginning) ;
    GetMem(p1,inputMat.SDPrec * self.complexMat ) ;
    tMemstr := TMemoryStream.Create ;
    tMemstr.SetSize( inputMat.numCols * inputMat.numCols * inputMat.SDPrec * self.complexMat) ;
    jump :=  (inputMat.numCols * inputMat.SDPrec * self.complexMat)-1  ;
    inputMat.F_Mdata.Seek(jump,soFromEnd) ;
    jump :=  2 * jump ;
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
        }

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

   initialCols, initialRows, t1, t2, dataSize : integer ;
   p1  : pointer ;
   s1 : Array[0..1] of single   ;
   d1 : Array[0..1] of double   ;
begin
   dataSize := self.SDPrec * self.complexMat ;
   GetMem(p1, dataSize)  ; //sets buffer
//   F_MAverage.Clear ;    // resets (column) averaged data if calculated
//   F_MVariance.Clear  ;    // resets (column) variance  data if calculated
//   F_MStdDev.Clear  ;    // resets (column) stddev  data if calculated
   transM :=  TMemoryStream.Create ; // temporary storage
   transM.SetSize(F_Mdata.Size) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.Seek(0,soFromBeginning) ;

   initialCols := numCols ;
   initialRows := numRows ;
   // swap column/row dimensions
   numRows := numCols ;
   numCols := initialRows ;

 {    for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1 * self.SDPrec * self.complexMat,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(p1^,dataSize) ;
          transM.Write(p1^,dataSize) ;
          transM.Seek((initialRows-1) * dataSize,soFromCurrent) ;
       end ;
     end ;   }
//  if SDPrec = 4 then
//  begin
     for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1 * self.SDPrec * self.complexMat,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(p1^,dataSize) ;
          transM.Write(p1^,dataSize) ;
          transM.Seek((initialRows-1) * dataSize, soFromCurrent) ;
       end ;
     end ;
//  end   ;
{  else
  begin
     for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1 * self.SDPrec * self.complexMat,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(d1,dataSize) ;
          transM.Write(d1,dataSize) ;
          transM.Seek((initialRows-1) * dataSize,soFromCurrent) ;
       end ;
     end ;
  end ;    }



   F_Mdata.Seek(0,soFromBeginning) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.CopyFrom(transM,transM.size) ;  // copy transposed data into original data stream

   transM.Free ;
   FreeMem(p1);
end ;



procedure TMatrix.RotateRight() ;      // complex number friendly
Var
   rotM : TMemoryStream ;

   initialCols, initialRows, t1, t2, dataSize : integer ;
   p1  : pointer ;
   s1 : Array[0..1] of single   ;
   d1 : Array[0..1] of double   ;
begin
   dataSize := self.SDPrec * self.complexMat ;
   GetMem(p1, dataSize)  ; //sets buffer
//   F_MAverage.Clear ;    // resets (column) averaged data if calculated
//   F_MVariance.Clear  ;    // resets (column) variance  data if calculated
//   F_MStdDev.Clear  ;    // resets (column) stddev  data if calculated
   rotM :=  TMemoryStream.Create ; // temporary storage
   rotM.SetSize(F_Mdata.Size) ;
   rotM.Seek(0,soFromBeginning) ;
   F_Mdata.Seek(0,soFromBeginning) ;

   initialCols := numCols ;
   initialRows := numRows ;
   // swap column/row dimensions
   numRows := numCols ;
   numCols := initialRows ;


     for t1 := 1 to initialRows  do
     begin
       rotM.Seek((initialRows - t1) * dataSize, soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(p1^,dataSize) ;
          rotM.Write(p1^,dataSize) ;
          rotM.Seek((initialRows-1) * dataSize, soFromCurrent) ;
       end ;
     end ;


   F_Mdata.Seek(0,soFromBeginning) ;
   rotM.Seek(0,soFromBeginning) ;
   F_Mdata.CopyFrom(rotM,rotM.size) ;  // copy transposed data into original data stream

   rotM.Free ;
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
     ErrorDialog('TMatrix.CopyUpperToLower error: Matrix is not square ' ) ;
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



procedure TMatrix.SaveMatrixDataBin(filenameOut : string; firstXIn, lastXIn : single) ;  // save as binary file
// binary format :  <DATA><rowNum><colNum><meanCentred><colStandardized><firstXCoord><lastXCoord><SDPrec><'v2'>
// old format: "numRows,numCols,SDPrec,meanCentred,colSandardized"
var
  t1 : integer ;
  c1 : char ;
  d1, d2 : double ;
begin
   if self.SDPrec = 4 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(single)*2) + (sizeof(char)*2)
   else
   if self.SDPrec = 8 then
     t1 := (sizeof(integer)*3)+(2*sizeof(boolean))+ (sizeof(double)*2) + (sizeof(char)*2)   ;

   self.F_Mdata.SetSize(self.F_Mdata.Size+ t1) ;
   self.F_Mdata.Seek(-t1,soFromEnd) ;
   self.F_Mdata.Write(self.numRows, sizeof(integer));
   self.F_Mdata.Write(self.numCols, sizeof(integer));
   self.F_Mdata.Write(self.meanCentred, sizeof(boolean));
   self.F_Mdata.Write(self.colStandardized, sizeof(boolean));


   if firstXIn <> lastXIn then
   begin
   if self.SDPrec = 4 then
   begin
     self.F_Mdata.Write(firstXIn,sizeof(single)) ;
     self.F_Mdata.Write(lastXIn,sizeof(single)) ;
   end
   else
   if self.SDPrec = 8 then
   begin
     d1 := firstXIn ;
     d2 := lastXIn ;
     self.F_Mdata.Write(d1,sizeof(double)) ;
     self.F_Mdata.Write(d2,sizeof(double)) ;
   end ;
   end
   else   // range of columns is over the number of columns of the data
   begin
   if self.SDPrec = 4 then
   begin
     firstXIn := 1 ;
     lastXIn  := self.numCols ;
     self.F_Mdata.Write(firstXIn,sizeof(single)) ;
     self.F_Mdata.Write(lastXIn,sizeof(single)) ;
   end
   else
   if self.SDPrec = 8 then
   begin
     d1 := 1 ;
     d2 := self.numCols ;
     self.F_Mdata.Write(d1,sizeof(double)) ;
     self.F_Mdata.Write(d2,sizeof(double)) ;
   end ;
   end;

   self.F_Mdata.Write(self.SDPrec, sizeof(integer));

   c1 := 'v' ;
   self.F_Mdata.Write(c1,sizeof(char)) ;
   c1 := '2' ;
   self.F_Mdata.Write(c1,sizeof(char)) ;
   // save the data+footer here
   self.SaveMatrixDataRaw( filenameOut ) ;

   self.F_Mdata.SetSize(self.F_Mdata.Size - t1) ;
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
     ErrorDialog('TMatrix.LoadMatrixDataFromBinFile() Warning: Could not determine if data was complex so set as non-complex') ;
     self.complexMat := 1
   end ;

   self.Filename := filenameIn ;
end ;


procedure TMatrix.SaveMatrixDataRaw(filenameOut : string) ;  // save as binary file
var
  t1 : integer ;
begin
   self.F_Mdata.SaveToFile(filenameOut) ;
end ;


procedure TMatrix.LoadMatrixDataRawBinFile(filenameIn : string) ;  // load from binary file
var
  t1 : integer ;
begin
   self.F_Mdata.Clear ;
   self.F_Mdata.LoadFromFile(filenameIn) ;
   self.Filename := filenameIn ;
end ;



// creates a matrix of normalised (unit length) vectors from inMatrix
procedure TMatrix.VectorNormaliseRowVects ;
var

  t1 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
begin

    MKLa := self.F_Mdata.Memory ;
    MKLtint := 1 ;
    // normalise input vector  -
    for t1 := 1 to self.numRows do
    begin
      if  (self.SDPrec = 4) and (self.complexMat=1) then
      begin
        lengthSSEVects_s := snrm2 ( self.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        sscal (self.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (self.SDPrec = 8) and (self.complexMat=1) then
      begin
        lengthSSEVects_d := dnrm2 ( self.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        dscal (self.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end
      else
      if  (self.SDPrec = 4) and (self.complexMat=2) then
      begin
        lengthSSEVects_s := scnrm2 ( self.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_s := 1/lengthSSEVects_s ;
        csscal (self.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
      end
      else
      if  (self.SDPrec = 8) and (self.complexMat=2) then
      begin
        lengthSSEVects_d := dznrm2 ( self.numCols , MKLa, MKLtint ) ;
        lengthSSEVects_d := 1/lengthSSEVects_d ;
        zdscal (self.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
      end  ;
      MKLa := self.MovePointer(MKLa,self.numCols * self.SDPrec * self.complexMat) ;
    end ;

end ;


function  TMatrix.VectorNormaliseRowVectsReturnNew(inMatrix : TMatrix) : TMatrix ;
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

function  TMatrix.ReturnTMatrixFromTMemStream(inStream : TMemoryStream; SDPrecIn, numRowIn, numColsIn : integer) : TMatrix ;
var                                                                                    // not complex number friendly
  resMatrix : TMatrix ;
  t1, t2 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
begin
    resMatrix := TMatrix.Create2(SDPrecIn, numRowIn, numColsIn)   ;
    resMatrix.F_MData.CopyFrom(inStream, SDPrecIn*numRowIn*numColsIn) ;
    result := resMatrix ;  // this has to be freed on end of use
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
              ErrorDialog('Delimeter is not comma, space or tab') ;
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
         ErrorDialog('No delimeter of type ''+inDelimeter+'' found' ) ;
         result := '-1' ;
         exit ;
       end ;
    end ;
    result := delimeter ;

end ;


// Loads data into the TMatrix
function TMatrix.FindScaleFromMODISCSV(filenameIn : string ) :  double ;
var
  lineNum : integer ;
  TempList: TStringList ;
  fullStr : String ;
  foundStr : boolean ;
begin
   TempList := TStringList.Create ;
   foundStr := false ;
   lineNum := 0 ;
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
      ErrorDialog('TMatrix.LoadXMatrixDataFromMODISCSV Error:'+#13+'File: '+extractFilename(filenameIn)+#13+' does not exist!' ) ;
      result := 0.0 ;
      exit ;
    end ;

    while (foundStr = false) and (lineNum < TempList.Count) do
    begin
        fullStr := TempList.Strings[lineNum] ;
        inc(lineNum) ;
        if pos('Scale',fullStr) > 0  then
        begin
          foundStr := true ;
          fullStr  := copy(fullStr, pos(' ',FullStr), length(fullStr)-pos(' ',FullStr)+1) ;
          result   := strtofloat(fullStr) ;
        end;
    end;

  end;
  except on Exception do
    begin
     result := 0.0 ;
     self.ClearData(self.SDPrec) ;
    end ;
  end
  finally
     TempList.Free ;
  end ;
end;


// Loads data into the TMatrix
function TMatrix.LoadXMatrixDataFromMODISCSV(filenameIn : string ; startLineIn, endLineIn : integer) :  boolean ;
//  rowOrCol = true if in rows rowOrCol = false if in cols                     // not complex number friendly
var
  TempList: TStringList ;
  t1 : integer ;
  year, julian_day, fullStr : String ;
  year_s1, day_s1, s1 : single  ;
  year_d1, day_d1, d1 : double  ;
begin
  self.ClearData(self.SDPrec) ;
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
      ErrorDialog('TMatrix.LoadXMatrixDataFromMODISCSV Error:'+#13+'File: '+extractFilename(filenameIn)+#13+' does not exist!' ) ;
      result := false ;
      exit ;
    end ;

    // determine the number of lines of data in the file
    if endLineIn = 0 then
      endLineIn :=  TempList.Count ;
    self.numRows :=  1 ;
    self.numCols := endLineIn - startLineIn + 1;

    // Set size of matrix
    self.F_Mdata.SetSize(numRows*1*SDPrec) ;
    self.F_Mdata.Seek(0,soFromBeginning) ;

    for t1 := 0 to numCols-1 do
    begin
        fullStr := TempList.Strings[t1+startLine-1] ;
        year := copy(fullStr,10,4) ;
        julian_day  := copy(fullStr,14,3) ;
        if self.SDPrec = 4 then  // single precission
        begin
           year_s1 :=  strtofloat(year) ;
           day_s1  := strtofloat(julian_day) ;
           year_s1  :=  year_s1 + (day_s1 / 365.25) ;
           self.F_Mdata.Write( year_s1 , self.SDPrec ) ;
        end
        else // double precission
        begin
           year_d1 :=  strtofloat(year) ;
           day_d1  := strtofloat(julian_day) ;
           year_d1  :=  year_d1 + (day_d1 / 365.25) ;
           self.F_Mdata.Write( year_d1 , self.SDPrec ) ;
        end;
    end ;
    self.F_Mdata.Seek(0,soFromBeginning) ;
    result := true ;
  end ;
  except on Exception do
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


// Loads data into the TMatrix
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
      ErrorDialog('TMatrix.LoadMatrixDataFromTxtFile Error:'+#13+'File: '+extractFilename(filenameIn)+#13+' does not exist!' ) ;
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
  s1 : single ;
  d1 : double ;
//  p1 : pointer ;
  s_max, s_min : single ;
  d_max, d_min : double ;
  retValue : TMaxMin ;
begin
 // GetMem(p1, SDPrec) ;
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

          if SDPrec = 4 then
          begin
            //F_Mdata.Read(p1^,SDPrec) ;
 //            if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5;   // addedxxx  - actually a problem with complex data from PCAcomplex
             F_Mdata.Read(s1,SDPrec) ;
             if s1 >  s_max then
             begin
                s_max := s1 ;
                i_max := F_Mdata.Position - 4 ;
             end ;
             if s1 <  s_min then
             begin
               s_min := s1;
               i_min := F_Mdata.Position - 4 ;
             end ;
          end
          else // SDPrec = 8
          begin
             F_Mdata.Read(d1,SDPrec) ;
             if d1 >  d_max then
             begin
               d_max := d1 ;
               i_max := F_Mdata.Position - 8
             end ;
             if d1 <  d_min then
             begin
               d_min := d1 ;
               i_min := F_Mdata.Position - 8
             end ;
          end ;
       end ;
    end ;
  end
  else if (row = 0) and (col <> 0) then
  begin
       F_Mdata.Seek(SDPrec * (col-1), soFromCurrent) ;
       for t1 := 1 to self.numRows do     // for each row
       begin
          if SDPrec = 4 then
          begin
//             if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5;   // addedxxx
             F_Mdata.Read(s1,SDPrec) ;
             if s1 >  s_max then
             begin
               s_max := s1 ;
               i_max :=  F_Mdata.Position - 4 ;
             end ;
             if s1 <  s_min then
             begin
               s_min := s1 ;
               i_min :=  F_Mdata.Position - 4 ;
             end ;
          end
          else
          begin
             F_Mdata.Read(d1,SDPrec) ;
             if d1 >  d_max then
             begin
               d_max := d1 ;
               i_max :=  F_Mdata.Position - 8  ;
             end ;
             if d1 <  d_min then
             begin
               d_min := d1 ;
               i_min :=  F_Mdata.Position - 8  ;
             end ;
          end ;
          F_Mdata.Seek(SDPrec * (self.numCols-1), soFromCurrent) ;
       end ;
  end
  else if (row <> 0) and (col = 0) then
  begin
       F_Mdata.Seek(SDPrec * (row-1)* self.numCols, soFromCurrent) ;
       for t1 := 1 to self.numCols do     // for each row
       begin
         // F_Mdata.Read(p1^,SDPrec) ;
          if SDPrec = 4 then
          begin
            F_Mdata.Read(s1,SDPrec) ;
//             if FloatToStrF(single(p1^),ffgeneral,5,3) = 'NAN' then  single(p1^) := 5 ;   // addedxxx
             if s1 >  s_max then
             begin
               s_max := s1 ;
               i_max := F_Mdata.Position - 4  ;
             end ;
             if s1<  s_min then
             begin
               s_min := s1 ;
               i_min := F_Mdata.Position - 4   ;
             end ;
          end
          else
          begin
             F_Mdata.Read(d1,SDPrec) ;
             if d1>  d_max then
             begin
               d_max := d1 ;
               i_max :=  F_Mdata.Position - 8   ;
             end ;
             if d1 <  d_min then
             begin
               d_min :=  d1 ;
               i_min :=  F_Mdata.Position - 8   ;
             end ;
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

 // FreeMem(p1) ;
end ;



procedure TMatrix.VectSubProjectedFromMatrix(inputMatrix, eVectsIn : TMatrix )  ;
// subtract factor(s) from original matrix to leave residuals (in place of the original matrix)
var
   mo : TMatrixOps ;

   MKLa, MKLEVects, MKLscores : pointer ;
   MKLinc, MKLlda : integer ;

   MKLalphas, SSEVects_s : single ;
   MKLalphad, SSEVects_d : double ;

   tScores : TMatrix ;  // these are created by projecting input eVectsIn onto input data
   tEVect  : TMatrix ;  // copy of the input vectors
begin
      mo := TMatrixOps.Create ;

      if (inputMatrix.numCols = eVectsIn.numCols) then
      begin
        // create scores
        tEVect  := TMatrix.Create(eVectsIn.SDPrec) ; ;
        tEVect.CopyMatrix(eVectsIn) ;
        tEVect.VectorNormaliseRowVects ; // normalise eVectsIn
        tScores := mo.MultiplyMatrixByMatrix(inputMatrix, tEVect, false, true, 1.0, false) ;

{       // this would only subtract a single vector at a time - would need to itterate
        MKLbetas  := -1.0 ;
        MKLbetad  := -1.0 ;
        MKLinc    :=  1 ;
        MKLa      :=  inputMatrix.F_Mdata.Memory ;
        MKLEVects :=  tEVect.F_Mdata.Memory ;
        MKLscores :=  tScores.F_Mdata.Memory ;
        // sger: a := beta * vects * scores’ + a
        MKLlda :=  inputMatrix.numCols ;  // first dimension of matrix (in Fortran col-major thinking)
        if inputMatrix.SDPrec = 4 then                      // single precision
        begin
          MKLbetas := -1.0 ;
          sger (inputMatrix.numCols , inputMatrix.numRows, MKLalphas, MKLEVects, MKLinc, MKLscores , MKLinc, MKLa, MKLlda) ;
        end
        else  // inputMatrix.SDPrec = 8 (double precision)
        begin
           MKLbetad := -1.0 ;
           dger (inputMatrix.numCols , inputMatrix.numRows, MKLalphad, MKLEVects, MKLinc, MKLscores , MKLinc, MKLa, MKLlda) ;
        end ;   }

        mo.MultiplyMatrixByMatrixPlusMatrixUpdate(tEVect,tScores,true,true,-1.0,inputMatrix,1.0,true) ;



        tEVect.Free ;
        tScores.Free ;
      end
      else
      ErrorDialog('Column mismatch between data and projecting vector') ;

      mo.Free ;

end;


function  TMatrix.FindCharacterData(inData : TMemoryStream; numberIn : integer) : int64 ; // numberIn: the number the data to find has been repeated in the source data
var
  t1 : integer ;
  b1, b2 : char    ;
  foundAll : integer ;
  numBytesFound, numBytesToFind : integer ;
  posInData : integer ;
  sizeData : int64 ;
begin
  foundAll := 0 ;
  numBytesFound := 0 ;
  posInData := 0 ;
  numBytesToFind := inData.Size ;

  inData.Seek(0,soFromBeginning) ;
  inData.Read(b1,1) ;

  self.F_Mdata.Seek(0,soFromBeginning) ;
  self.F_Mdata.Read(b2,1) ;
  sizeData := self.F_Mdata.Size ;
  
  while foundAll <  numberIn do
  begin

     while (numBytesFound < numBytesToFind) and ( posInData < sizeData) do
     begin
       if b2 <> b1 then
       begin
         self.F_Mdata.Read(b2,1)  ;
         inc(posInData) ;
         numBytesFound := 0  ;
         inData.Seek(0,soFromBeginning) ;
         inData.Read(b1,1) ;
       end
       else
       begin
          self.F_Mdata.Read(b2,1) ;
          inc(posInData) ;
          inData.Read(b1,1) ;
          inc(numBytesFound) ;
       end ;
     end ;
     inc(foundAll) ;
     numBytesFound := 0 ;
     inData.Seek(0,soFromBeginning) ;
     inData.Read(b1,1) ;
  end ;

  self.F_Mdata.Seek(0,soFromBeginning) ;

  if posInData = self.F_Mdata.Size then
    result := -1
  else
    result := posInData  ;

end;



function  TMatrix.FindFloatInData(dataIn, accuarcyIn : single; numberIn : integer) : int64 ; // numberIn: the number the data to find has been repeated in the source data
var
  t1, foundAll : integer ;
  s1     : single ;
  posInData : integer ;
  sizeData : int64 ;
begin
  foundAll := 0 ;
  posInData := 0 ;

  self.F_Mdata.Seek(0,soFromBeginning) ;
   self.F_Mdata.Read(s1,4) ;
   self.F_Mdata.Seek(-3,soFromCurrent) ;
  sizeData := self.F_Mdata.Size ;
  
  if accuarcyIn = 0.0 then
  begin
  while (foundAll <  numberIn) and ( posInData < (sizeData-4)) do
  begin
       if s1 <> dataIn then
       begin
          self.F_Mdata.Read(s1,4) ;
          self.F_Mdata.Seek(-3,soFromCurrent) ;
          inc(posInData) ;
       end
       else
       begin
          self.F_Mdata.Read(s1,4) ;
          self.F_Mdata.Seek(-3,soFromCurrent) ;
          inc(posInData) ;
          inc(foundAll)  ;
       end ;

  end ;

  end

  else

  begin


  end;


  self.F_Mdata.Seek(0,soFromBeginning) ;

  result := posInData  ;

end;




end.

