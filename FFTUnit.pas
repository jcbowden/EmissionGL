unit FFTUnit;

interface

uses  Windows, OpenGL, classes, Dialogs,  Math, SysUtils, TMatrixObject ;

type
  TFFTFunctions = class
  public
    // Fourier Transform
    numPoints : integer ;
    dt, dfreq, nyquistFreq : single ;  // time space between data points and frequency space between freq. data
    hanningWindow : boolean ;          // not sure why this is in here
    FFTReverse : boolean ; // false = forward, true is reverse
    firstXVal : single ;   // used to store where data was displayed from before FFT taken
    zeroFillFFT : integer ;   // if > 1 then zero fill has been done already, so prevent multiple zero filling

    constructor Create ; // lc is pointer to TGLLineColor GLFloat array
    destructor  Destroy;
    procedure   Free;
    procedure CopyFFTObject( sourceFFT : TFFTFunctions )  ;   // used when TSpectraObject that owns this object is being copied
    procedure Set_dt(last, first : single) ;
    procedure Set_numPoints(numIn : integer) ;

    procedure ComputeFFTSingle(ForwardOrReverse : integer; ZeroFillIn : integer; p1 : pointer)  ;
    procedure CreateButterworthFilter(percentage, pow : single; p1 : pointer ) ;
    procedure MultiplyFFT(bw_p, p1 : pointer ) ;  // p1 is FFT data, bw_p is step type function
    procedure ConvolveByFFT(Spec1, Spec2 : TMemoryStream) ; // multiply two FFT by one another and inverse FFT to get convolution
    procedure CorrelateByFFT(Spec1, Spec2 : TMemoryStream) ;
    procedure FFTBandPass( percentage, pow : single; zero : boolean; zeroFill : integer ; p1 : pointer ) ;
    procedure MultiplySpectra(spec1, spec2 : TMemoryStream ) ;  // multiply spec1 by spec2 and place answer in spec1 - multiply Y values only
    procedure SaveFFT(SaveDialog : TSaveDialog) ;
    procedure DiffOrIntUsingFFT( p1 : pointer; order : integer ; zeroFillIn : integer ) ; // ; order 1 = 1st deriv, 2 = 2nd etc.
    procedure DeconvolveByFFT(tspec : TMemoryStream) ;
    procedure ApplyHanningWindow(numberOfVals : integer; inputRealImagStr : TMemoryStream) ;  // numberOfVals is size of FFTMemstream and is returned by ClosestPowofTwo()
    function  ClosestPowofTwo(numPoints : integer) : integer ;
    function  MultiplyRealImagReal( ri1, ri2 : array of single) : single ;   // returns real part of multiplication
    function  MultiplyRealImagImag( ri1, ri2 : array of single) : single ;   // retuns imaginary part of multiplication
//    procedure ScaleFFTData(max : single; spectra : TMemoryStream) ;
//    procedure ScaleFFTDataDouble(max : double; spectra : TMemoryStream) ;

   private

  end;

implementation

uses TSpectraRangeObject ;

constructor TFFTFunctions.Create; // found in implementation part below
begin
  dt := 0.0 ;
  FFTReverse := false ;
  inherited Create;
end ;

destructor TFFTFunctions.Destroy;
begin
  inherited Destroy;
end;

procedure TFFTFunctions.Free;
begin
 if Self <> nil then Destroy;
end;

procedure TFFTFunctions.CopyFFTObject( sourceFFT : TFFTFunctions )  ;
begin
    self.numPoints := sourceFFT.numPoints ;
    self.dt:=  sourceFFT.dt ;
    self.dfreq := sourceFFT.dfreq ;
    self.nyquistFreq := sourceFFT.nyquistFreq ;  // time space between data points and frequency space between freq. data
    self.hanningWindow := sourceFFT.hanningWindow ;          // not sure why this is in here
    self.FFTReverse := sourceFFT.FFTReverse ; // false = forward, true is reverse
    self.firstXVal := sourceFFT.firstXVal ;   // used to store where data was displayed from before FFT taken
end ;


procedure TFFTFunctions.Set_dt(last, first : single) ;
begin
   dt := last - first ;
end ;

procedure TFFTFunctions.Set_numPoints(numIn : integer) ;
begin
   numPoints :=  numIn ;
end ;

function TFFTFunctions.ClosestPowofTwo(numPoints : integer) : integer ;
begin ;
  result := 1 ;
  while (result < numPoints) do
  begin
    result := result * 2 ;
  end ;
end ;



//#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr
// void four1(float data[], unsigned long nn, int isign)
// data[] : a real array of length 2*nn (Contains nn real:imaj pairs).
// nn MUST be an integer power of 2.
// if isign is input as 1 :
//         Replaces data[1..2*nn] by its discrete Fourier transform.
// if isign is input as -1
//         Replaces data[1..2*nn] by nn times its inverse discrete Fourier transform.
procedure TFFTFunctions.ComputeFFTSingle(ForwardOrReverse : integer; ZeroFillIn : integer; p1 : pointer) ;
var
  n, mmax, m,  j, istep, i, ii : Longint	 ;
  wtemp,wr,wpr,wpi,wi,theta : double ; // Double precision for the trigonometric recurrences.
//  tempr,tempi : single ;
  numberOfVals : Longint	 ; // this is value "nn" in original code
  NumPointsInArray : Longint	 ;
  t1, upper, lower : Longint ;
  tempXY : Array [0..1] of single ;
  tempRealImag : Array [0..1] of single ;
  dataj, datai : Array [0..1] of single ;
  tempSwap : single ;
  freq : single ;

  tSR : TSpectraRanges ;
  newYMatrix, newImagMatrix : TMatrix ;  // place new (possibly) enlarged y data values in here and copy all old Y data
  tMStr : TMemoryStream ; // this is temporary inteleaved real+imaginary data pairs
  s1 : single ;
  spectraNumber : integer ;
begin

 tSR := TSpectraRanges( p1 ) ;
 newYMatrix := TMatrix.Create(tSR.yCoord.SDPrec div 4) ;
 newYMatrix.CopyMatrix( tSR.yCoord ) ;  // need to enlarge size of this if zero fill or numberofVals greater than original YCoord matrix

 newImagMatrix := TMatrix.Create(tSR.yCoord.SDPrec div 4) ;
 if tSR.yImaginary <> nil then
   newImagMatrix.CopyMatrix( tSR.yImaginary ) ;  // need to enlarge size of this if zero fill or numberofVals greater than original YCoord matrix
 // need to set numRow and numCol size if it did not exist

try
  // calculate dt - the spacing of the data
  // get first x value and then get last x value and divide by (total number of values - 1)
  tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  tSR.xCoord.F_Mdata.Read(s1,tSR.xCoord.SDPrec) ;
  dt := s1  ;   // this is used soon

  if tSR.fft.FFTReverse = false then
      tSR.fft.firstXVal := s1 ;  // only needed on forward FFT, used to offset data after reverse FFT

  tSR.xCoord.F_Mdata.Seek(-tSR.xCoord.SDPrec,soFromEnd) ;
  tSR.xCoord.F_Mdata.Read(s1,tSR.xCoord.SDPrec) ; // last x value
  dt := s1 - dt ;


  dt := dt / (tSR.xCoord.numCols -1) ; // full range divided by number in range - 1
//  if self.FFTReverse = false then nyquistFreq := 1 / (2*dt) ;
  nyquistFreq := 1 / (2*dt) ;
  // calculate closest power of two
  numberOfVals := ClosestPowofTwo(tSR.xCoord.numCols) ;
  // add zeros to end of data to increase frequency resolution (Zero-fill)

  if zeroFillFFT > 1 then    // data has been zero filled previously
    numberOfVals :=  numberOfVals
  else                      // data has not been zero filled
  begin
     zeroFillFFT := zeroFillIn   ;
     numberOfVals :=  numberOfVals *  zeroFillFFT ;
  end ;

  dfreq  := 1 / ((numberOfVals) * dt) ;  // this is the new XCoord data spacing

  // Resize the new Y matrix
  newYMatrix.numCols := numberOfVals ;
  newYMatrix.numRows := tSR.yCoord.numRows ;  // this is not needed as it stay the same
  newYMatrix.F_Mdata.SetSize(newYMatrix.numRows * newYMatrix.numCols * newYMatrix.SDPrec) ;

  // Resize the new Imaginary matrix
  newImagMatrix.numCols := numberOfVals ;
  newImagMatrix.numRows := tSR.yCoord.numRows ;  // this is not needed as it stay the same
  newImagMatrix.F_Mdata.SetSize(newImagMatrix.numRows * newImagMatrix.numCols * newImagMatrix.SDPrec) ;

  // create temporary storage for real and imaginary data for spectral data
  tMStr := TMemoryStream.Create ;
  tMStr.size := 2 * sizeof(single) * numberOfVals ;
  tMStr.Seek(0,soFromBeginning) ;

// ****************************************************************************************
//  ****************  Start for each spectrum in Y data  **********************************
// ****************************************************************************************
  for spectraNumber := 1 to tSR.yCoord.numRows do
  begin
  tMStr.Clear ;
  tMStr.size := 2 * sizeof(single) * numberOfVals ;
  tMStr.Seek(0,soFromBeginning) ;

  tSR.yCoord.F_Mdata.Seek(((spectraNumber-1) * tSR.yCoord.numCols)* tSR.yCoord.SDPrec ,soFromBeginning) ;
  if tSR.yImaginary <> nil then
  tSR.yImaginary.F_Mdata.Seek(((spectraNumber-1) * tSR.yImaginary.numCols)* tSR.yImaginary.SDPrec ,soFromBeginning) ;

  for t1 := 1 to newYMatrix.numCols do  // create the real:imag data from the Y data
  begin
     if t1 <= tSR.yCoord.numCols  then
     begin
       tSR.yCoord.F_Mdata.Read(s1,tSR.yCoord.SDPrec) ;
       tMStr.Write(s1,tSR.yCoord.SDPrec);
       if tSR.yImaginary = nil then
         s1 := 0.0 
       else
         tSR.yImaginary.F_Mdata.Read(s1,tSR.yCoord.SDPrec) ;
       tMStr.Write(s1,tSR.yCoord.SDPrec);
     end
     else    // add zeros to the end of the power of two nmuCols (zeroFill remainder)
     begin
        s1 := 0.0 ;
        tMStr.Write(s1,tSR.yCoord.SDPrec);   // real
        tMStr.Write(s1,tSR.yCoord.SDPrec);   // imaginary
     end ;
  end ;

  // apply Hanning window
  if hanningWindow = true then
  begin
    ApplyHanningWindow(numberOfVals, tMStr) ;
  end ;
  // blackman window     


   // This is the bit-reversal section of the routine.
   tMStr.Seek(0,soFromBeginning) ;
   ii := 1 ;
   n := numberOfVals shl 1 ;  // multiply by 2
   j:=1;
   for i:=1 to numberOfVals do
   begin
     if (j > ii) then
     begin
        tMStr.Seek((j-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
        tMStr.ReadBuffer(tempXY,tSR.yCoord.SDPrec*2) ;
        tMStr.Seek((ii-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
        tMStr.ReadBuffer(tempRealImag,tSR.yCoord.SDPrec*2) ;
        tMStr.Seek((j-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
        tMStr.Write(tempRealImag,tSR.yCoord.SDPrec*2) ;
        tMStr.Seek((ii-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
        tMStr.Write(tempXY,tSR.yCoord.SDPrec*2) ;
     end ;
     m := numberOfVals ;
    while (m >= 2) and (j > m) do
    begin
      j := j - m;
      m := m shr 1;  // divide by 2
    end ;
    j := j + m ;
    ii := ii + 2 ;
  end ;

// Here begins the Danielson-Lanczos section of the routine.
tMStr.Seek(0,soFromBeginning) ;
mmax := 2;
while (n > mmax) do // Outer loop executed log2 nn times.
begin
  istep := mmax shl 1;
  theta := ForwardOrReverse*(6.28318530717959/mmax); // Initialize the trigonometric recurrence.
  wtemp := sin(0.5*theta);
  wpr := -2.0*wtemp*wtemp;
  wpi := sin(theta);
  wr := 1.0;
  wi := 0.0;
  // for (m:=1;m<mmax;m+=2)  // Here are the two nested inner loops.
  m := 1  ;
  while m < mmax do
  begin
   // for (i=m;i<=n;i+=istep)
    i := m ;
    while i <= n do
    begin
      j := i+mmax; // This is the Danielson-Lanczos formula:
      tMStr.Seek((j-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
      tMStr.ReadBuffer(dataj,tSR.yCoord.SDPrec*2) ;
      tempRealImag[0] := wr*dataj[0]-wi*dataj[1]; // tempr := wr*data[j]-wi*data[j+1];
      tempRealImag[1] := wr*dataj[1]+wi*dataj[0]; // tempi := wr*data[j+1]+wi*data[j];
      tMStr.Seek((i-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
      tMStr.ReadBuffer(datai,tSR.yCoord.SDPrec*2) ;
      dataj[0] := datai[0] - tempRealImag[0] ;   // data[j] := data[i]-tempr;
      dataj[1] := datai[1] - tempRealImag[1] ;   // data[j+1] := data[i+1]-tempi;
      datai[0] := datai[0] + tempRealImag[0] ;   // data[i] := data[i] + tempr;
      datai[1] := datai[1] + tempRealImag[1] ;   // data[i+1] := data[i+1] + tempi;
      tMStr.Seek((j-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
      tMStr.Write(dataj,tSR.yCoord.SDPrec*2) ;
      tMStr.Seek((i-1)*tSR.yCoord.SDPrec,soFromBeginning) ;
      tMStr.Write(datai,tSR.yCoord.SDPrec*2) ;
      i := i + istep ;
    end ;
    wtemp := wr ;
    wr := wtemp*wpr-wi*wpi+wtemp; // Trigonometric recurrence.
    wi := wi*wpr+wtemp*wpi+wi;
    m := m + 2 ;
  end ;
  mmax := istep;
end ;

  if FFTReverse = false then
  begin
    tMStr.Seek(0,soFromBeginning) ;
    for t1 := 1 to (tMStr.size div (tSR.yCoord.SDPrec*2)) do     // Normalise range of data
    begin
      tMStr.ReadBuffer(TempXY,(tSR.yCoord.SDPrec*2)) ;
      TempXY[0] := (TempXY[0]) / numberOfVals ;
      TempXY[1] := (TempXY[1]) / numberOfVals ;
      tMStr.Seek(-(tSR.yCoord.SDPrec*2),soFromCurrent) ;
      tMStr.write(TempXY,(tSR.yCoord.SDPrec*2)) ;
    end ;
  end ;


  // If first time around, place x data (frequency data) in xCoord TMatrix - clear it and resize it first
  if (spectraNumber =  1) then
  begin
      tSR.xCoord.ClearData(tSR.xCoord.SDPrec div 4) ;
      tSR.xCoord.numCols := tMStr.Size div (tSR.xCoord.SDPrec*2) ;
      tSR.xCoord.numRows := 1 ;
      tSR.xCoord.F_Mdata.SetSize(tSR.xCoord.numCols * tSR.xCoord.SDPrec) ;
      // position data in correct place

      if FFTReverse = false then
      begin
        lower := -(newYMatrix.numCols div 2)+1 ;
        upper :=  (newYMatrix.numCols div 2) ;
       end
      else
      begin
        lower := 1 ;
        upper := newYMatrix.numCols ;
      end ;

    // write new x data (frequency data if forward FFT)
      for t1 := lower to upper do
      begin
       freq :=  (t1-1) * dfreq ;
       if FFTReverse = true then
         freq := freq + firstXVal ;
       tSR.xCoord.F_Mdata.Write(freq,tSR.xCoord.SDPrec) ;
      end ;
  end ;


  // seek to correct spectum start
  newYMatrix.F_Mdata.Seek((spectraNumber-1) * newYMatrix.SDPrec * newYMatrix.numCols , soFromBeginning) ;
  newImagMatrix.F_Mdata.Seek((spectraNumber-1) * newYMatrix.SDPrec * newYMatrix.numCols, soFromBeginning) ;

  // **** Seperate real and imaginary bits and place in new yCoord (newYMatrix) and yImaginary  *****
  if FFTReverse = false then   // reorder data
  begin
    tMStr.Seek((tMStr.size div 2),soFromBeginning) ;
    // ** write -ve frequency values **
    for t1 := 1 to (tMStr.size div 16) do
    begin
       tMStr.ReadBuffer(TempXY,(tSR.yCoord.SDPrec*2)) ;
       newYMatrix.F_Mdata.Write(TempXY[0],tSR.yCoord.SDPrec) ;
       newImagMatrix.F_Mdata.Write(TempXY[1],tSR.yCoord.SDPrec) ;
    end ;
    // ** write +ve frequency values to rest of stream **
    tMStr.Seek(0,soFromBeginning) ;
    for t1 := 1 to (tMStr.size div 16) do // write +ve frquency values
    begin
       tMStr.ReadBuffer(TempXY,(tSR.yCoord.SDPrec*2)) ;
       newYMatrix.F_Mdata.Write(TempXY[0],tSR.yCoord.SDPrec) ;
       newImagMatrix.F_Mdata.Write(TempXY[1],tSR.yCoord.SDPrec) ;
    end ;
  end
  else  // do not reorder data if we are doing backwards FFT (just shift back - this is done in xCoord) (FFTReverse = true)
  begin
      tMStr.Seek(0,soFromBeginning) ;
      for t1 := 1 to (tMStr.size div 8) do // write all
      begin
         tMStr.ReadBuffer(TempXY,8) ;
         if (t1 mod 2) = 0 then begin  TempXY[0] := -1 * TempXY[0] ;  TempXY[1] := -1 * TempXY[1] ;  end ;
         newYMatrix.F_Mdata.Write(TempXY[0],tSR.yCoord.SDPrec) ;
         newImagMatrix.F_Mdata.Write(TempXY[1],tSR.yCoord.SDPrec) ;
      end ;
  end ;

end ;  //  **************** end for each spectrum in Y data  **********************************

finally
    tMStr.Free ;
end ;

 FFTReverse := not FFTReverse ;
 tSR.yCoord.Free ;
 tSR.yCoord := newYMatrix ;
 if tSR.yImaginary <> nil then
   tSR.yImaginary.Free  ;
 tSR.yImaginary := newImagMatrix ;
//  ShiftData(firstXVal) ; // shift data back to original position

end ;




{procedure TFFTFunctions.FFTDeconvolution(tspec : TSpectraRanges) ;
var
  tint, origSize, pos : integer ;
  den, num : array[0..1] of single ;  // den is instrument func, num is original spectrum, congden is the complex conjugate of the denominator
  den_d, num_d, congden_d : array[0..1] of double ;  // den is instrument func, num is original spectrum, congden is the complex conjugate of the denominator
  tempxy_d : array[0..1] of single ;
  tempxy : array[0..1] of single ;
  tempRange : TGLRangeArray ;
  divden_d, fftScale : double ;
  scaleFact : single ;
  filter :  TSpectraRanges ;
  doubleStream : TMemoryStream ;
begin
  origSize := FMemStream.Size ;

  // for rescale
  tempRange := FindYLimits(FMemStream) ;
  scaleFact :=  tempRange[3] - tempRange[2] ;

  tspec.ComputeFFT(1, 1) ;
//  tspec.ScaleFFTData(1.0, tspec.FFTMemStream) ;
  ComputeFFT(1, 1) ;
//  ScaleFFTData(1.0, FFTMemStream) ;

  tempRange := FindXLimits(FFTMemStream) ;
  fftScale := tempRange[1] ;  // this is the maximum real value in the memory stream

  FFTMemStream.Seek(0, soFromBeginning) ;
  tspec.FFTMemStream.Seek(0, soFromBeginning) ;

//  pos := (FFTMemStream.Size div 2)-(FFTMemStream.Size div 4) ;
//  FFTMemStream.Seek(pos, soFromBeginning) ;
//  tspec.FFTMemStream.Seek(pos, soFromBeginning) ;

//  filter :=   TSpectraRanges.Create() ;
//  filter.FMemStream.SetSize(FFTMemStream.Size) ; // create filt of same size as FFT to be multiplied
 // filter.FMemStream.Seek(0,soFromBeginning) ;
 // CreateButterworthFilter(0.1, 50, filter) ;
//  MultiplyFFT(FFTMemStream, filter) ;
// MultiplyFFT(tspec.FFTMemStream, filter) ;
//  filter.Free ;

 // FFTMemStream.Seek(0, soFromBeginning) ;
 // tspec.FFTMemStream.Seek(0, soFromBeginning) ;

  doubleStream := TMemoryStream.Create ;
  doubleStream.SetSize(  FFTMemStream.Size * 2 ) ;
  doubleStream.Seek(0, soFromBeginning) ;
  for tint := 1 to (FFTMemStream.Size div 8) do
  begin
    FFTMemStream.Read(num,8) ;  // observed fft of lineshape
  //  FFTMemStream.Seek(-8, soFromCurrent) ;  // move back so as to place result of division in original spectrum
    tspec.FFTMemStream.Read(den,8) ;   // instrumental fft of line
    num_d[0] := num[0]; num_d[1] := num[1];
    den_d[0] := den[0]; den_d[1] := den[1];

    if (num[0] > 0.5) and (num[1] > 0.5) then // this works OK  when  num[1] > 0.5
    begin
      congden_d[0] := den[0] ;      // real part of complex conjugate is just the real part unchanged
      congden_d[1] := -1 * den[1] ; // complex conjugate is -ve of imaginary part
      divden_d := den_d[0]*den_d[0] + den_d[1]*den_d[1] ;
      if divden_d = 0.0 then
      begin
        if ((num_d[0]*den_d[0]) + (num_d[1]*congden_d[1]*-1.0)) = 0.0 then
          tempxy_d[0] := 0.0
        else
          tempxy_d[0] := math.MaxDouble ;
        if (num_d[0]*congden_d[1] + num_d[1]*congden_d[0]) = 0.0 then
          tempxy_d[1] := 0.0
        else
          tempxy_d[1] := math.MaxDouble ;
        end
      else
      begin
        tempxy_d[0] :=  ((num_d[0]*den_d[0]) + (num_d[1]*congden_d[1]*-1.0)) / divden_d ;
        tempxy_d[1] :=  (num_d[0]*congden_d[1] + num_d[1]*congden_d[0]) / divden_d ;
      end ;
    end
    else
    begin
      tempxy_d[0] :=  0.0 ;
      tempxy_d[1] :=  0.0 ;
    end ;

    doubleStream.Write(tempxy_d,16) ;
  end ;

//  ScaleFFTDataDouble(fftScale, doubleStream) ;
  doubleStream.Seek(0,soFromBeginning) ;
  FFTMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to (FMemStream.Size div 8) do
  begin
     doubleStream.Read(tempxy_d,16) ;
     tempxy[0] := tempxy_d[0]  ;
     tempxy[1] := tempxy_d[1]  ;
     FFTMemStream.Write(tempxy,8) ;
  end ;

// { for tint := 1 to (FFTMemStream.Size div 8) do
//  begin
//    FFTMemStream.Read(num,8) ;  // observed fft of lineshape
//    FFTMemStream.Seek(-8, soFromCurrent) ;  // move back so as to place result of division in original spectrum
//    tspec.FFTMemStream.Read(den,8) ;   // instrumental fft of line
//
//    if (num[0] > 0.5) and (num[1] > 0.5) then // this works OK  when  num[1] > 0.5
//    begin
//      congden[0] := den[0] ;      // real part of complex conjugate is just the real part unchanged
//      congden[1] := -1 * den[1] ; // complex conjugate is -ve of imaginary part
//      divden := den[0]*den[0] + den[1]*den[1] ;
//      tempxy[0] :=  ((num[0]*den[0]) + (num[1]*congden[1]*-1.0)) / divden ;
//      tempxy[1] :=  (num[0]*congden[1] + num[1]*congden[0]) / divden ;
//    end
//    else
//    begin
//      tempxy[0] :=  0.0 ;
 //     tempxy[1] :=  0.0 ;
 //   end ;
 //
 //   FFTMemStream.Write(tempxy,8) ;
//  end ;

// { filter :=   TSpectraRanges.Create() ;
//  filter.FMemStream.SetSize(FFTMemStream.Size) ; // create filt of same size as FFT to be multiplied
 // filter.FMemStream.Seek(0,soFromBeginning) ;

//  CreateButterworthFilter(0.05, 50, filter) ;
//  MultiplyFFT(Self.FFTMemStream, filter) ;

  hanningWindow := false ;
  ComputeFFT(-1,1) ;
  FMemStream.SetSize(origSize) ;  // this chops off any extra points that were added for FFT

  filter :=   TSpectraRanges.Create() ;
  filter.FMemStream.SetSize(FMemStream.Size) ; // create filt of same size as FFT to be multiplied
  filter.FMemStream.Seek(0,soFromBeginning) ;
  CreateButterworthFilter(0.8, 50, filter) ;
  MultiplySpectra(FMemStream, filter.FMemStream) ;
  filter.Free ;

  // rescale data to same height as original
  tempRange := FindYLimits(FMemStream) ;
  scaleFact :=   scaleFact / (tempRange[3] - tempRange[2]) ;
  FMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to (FMemStream.Size div 8) do
  begin
     FMemStream.Read(tempxy,8) ;
     FMemStream.Seek(-8, soFromCurrent) ;
     tempxy[1] := tempxy[1] * scaleFact ;
     FMemStream.Write(tempxy,8) ;
  end ;

  doubleStream.Free ;
end ;        }


procedure TFFTFunctions.DeconvolveByFFT(tspec : TMemoryStream) ;
{var
  tint, origSize, pos : integer ;
  den, num, congden : array[0..1] of single ;  // den is instrument func, num is original spectrum, congden is the complex conjugate of the denominator
  den_d, num_d, congden_d : array[0..1] of double ;  // den is instrument func, num is original spectrum, congden is the complex conjugate of the denominator
  tempxy_d : array[0..1] of single ;
  tempxy : array[0..1] of single ;
  divden : single ;
  tempRange : TGLRangeArray ;
  divden_d, fftScale : double ;
  scaleFact : single ;
  filter :  TSpectraRanges ;
  doubleStream : TMemoryStream ;  }
begin
  messagedlg('FFTDeconvolution() not fully implemented yet -  multi y data spectra handling needed' ,mtInformation,[mbOK],0) ;
{  origSize := FMemStream.Size ;

  // for rescale
  tempRange := FindYLimits(FMemStream) ;
  scaleFact :=  tempRange[3] - tempRange[2] ;

  tspec.ComputeFFT(1, 8) ;
//  tspec.ScaleFFTData(1.0, tspec.FFTMemStream) ;
  ComputeFFT(1, 8) ;
//  ScaleFFTData(1.0, FFTMemStream) ;

  tempRange := FindXLimits(FFTMemStream) ;
  fftScale := tempRange[1] ;  // this is the maximum real value in the memory stream

  FFTMemStream.Seek(0, soFromBeginning) ;
  tspec.FFTMemStream.Seek(0, soFromBeginning) ;

  doubleStream := TMemoryStream.Create ;
  doubleStream.SetSize(  FFTMemStream.Size * 2 ) ;
  doubleStream.Seek(0, soFromBeginning) ;
  for tint := 1 to (FFTMemStream.Size div 8) do
  begin
    FFTMemStream.Read(num,8) ;  // observed fft of lineshape
    FFTMemStream.Seek(-8, soFromCurrent) ;  // move back so as to place result of division in original spectrum
    tspec.FFTMemStream.Read(den,8) ;   // instrumental fft of line

    if (num[0] > 0.5) and (num[1] > 0.5) then // this works OK  when  num[1] > 0.5
    begin
      congden[0] := den[0] ;      // real part of complex conjugate is just the real part unchanged
      congden[1] := -1 * den[1] ; // complex conjugate is -ve of imaginary part
      divden := den[0]*den[0] + den[1]*den[1] ;
      tempxy[0] :=  ((num[0]*den[0]) + (num[1]*congden[1]*-1.0)) / divden ;
      tempxy[1] :=  (num[0]*congden[1] + num[1]*congden[0]) / divden ;
    end
    else
    begin
      tempxy[0] :=  0.0 ;
      tempxy[1] :=  0.0 ;
    end ;

    FFTMemStream.Write(tempxy,8) ;
  end ;

//  ScaleFFTDataDouble(fftScale, doubleStream) ;
//  doubleStream.Seek(0,soFromBeginning) ;
//  FFTMemStream.Seek(0,soFromBeginning) ;
//  for tint := 1 to (FMemStream.Size div 8) do
//  begin
//     doubleStream.Read(tempxy_d,16) ;
//     tempxy[0] := tempxy_d[0]  ;
//     tempxy[1] := tempxy_d[1]  ;
//     FFTMemStream.Write(tempxy,8) ;
//  end ; 


  hanningWindow := false ;
  ComputeFFT(-1,1) ;
  FMemStream.SetSize(origSize) ;  // this chops off any extra points that were added for FFT

  filter :=   TSpectraRanges.Create() ;
  filter.FMemStream.SetSize(FMemStream.Size) ; // create filt of same size as FFT to be multiplied
  filter.FMemStream.Seek(0,soFromBeginning) ;
  CreateButterworthFilter(0.8, 50, filter) ;
  MultiplySpectra(FMemStream, filter.FMemStream) ;
  filter.Free ;

  // rescale data to same height as original
  tempRange := FindYLimits(FMemStream) ;
  scaleFact :=   scaleFact / (tempRange[3] - tempRange[2]) ;
  FMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to (FMemStream.Size div 8) do
  begin
     FMemStream.Read(tempxy,8) ;
     FMemStream.Seek(-8, soFromCurrent) ;
     tempxy[1] := tempxy[1] * scaleFact ;
     FMemStream.Write(tempxy,8) ;
  end ;

  doubleStream.Free ;   }
end ;



{ // This is a tabletop step function
  startzero :=  Round((FFTMemStream.Size / 16) * percentage) ;
 // step low pass filter
  startzero :=  Round((FFTMemStream.Size / 16) * percentage) ;

  writeval[1] := 0.0 ;
  pos := 1 ;
  for tint := 1 to startzero do
  begin
    writeval[0] :=  (pos * dfreq) ;
    convFunc.FMemStream.Write(writeval,8) ;
    inc(pos) ;
  end ;
  writeval[1] := 1.0 ;
  for tint := 1 to ((FFTMemStream.Size div 8) - (startzero*2)) do
  begin
    writeval[0] :=  (pos * dfreq) ;
    convFunc.FMemStream.Write(writeval,8) ;
    inc(pos) ;
  end ;
  writeval[1] := 0.0 ;
  for tint := 1 to (startzero)+1  do
  begin
    writeval[0] :=  (pos * dfreq) ;
    convFunc.FMemStream.Write(writeval,8) ;
    inc(pos) ;
  end ;       }


procedure TFFTFunctions.CreateButterworthFilter(percentage, pow : single; p1 : pointer) ;
var
  startzero : single ;
  tint : integer ;
  writeval : Array [0..2] of single ;
  pos : integer ;
  tSR : TSpectraRanges ;
begin

  tSR :=  TSpectraRanges(p1) ;

  startzero :=  (tSR.xCoord.numCols / 2) * percentage ;
  // butterworth filter
  tSR.SeekFromBeginning(3,1,(tSR.yCoord.numCols div 2) * tSR.yCoord.SDPrec) ; // move to half way mark
  pos := 1 ;
  for tint := (tSR.yCoord.F_Mdata.Size div 8) to (tSR.yCoord.F_Mdata.Size div 4) do  // for positive frequencies
  begin
      writeval[0] :=  pos  ;
      writeval[1] :=  1 / ( 1 + power(writeval[0]/startzero, pow) ) ;
      tSR.yCoord.F_Mdata.Write(writeval[1], 4) ;
      tSR.xCoord.F_Mdata.Write(writeval[0], 4) ;
      inc(pos) ;
  end;
  for tint :=  0 to (tSR.yCoord.numCols div 2)-1  do  // for negative frequencies
  begin
     tSR.Read_XYrYi_Data((tint+1)+ (tSR.yCoord.numCols div 2),1,@writeval,true) ;

     tSR.SeekFromBeginning(3,1,((tSR.yCoord.numCols div 2) - tint -1) * tSR.yCoord.SDPrec) ; // move to half way mark

     tSR.yCoord.F_Mdata.Write(writeval[1], 4) ;
     writeval[0] := -1.0 * (writeval[0] -1 )  ;
     tSR.xCoord.F_Mdata.Write(writeval[0], 4) ;
  end;

//  tSR.SaveSpectraDelimExcel('butterworthfilter.csv',',') ;

end ;


// multiply spec1 by spec2 and place answer in spec1 - multiply Y values only, both should be same length
procedure TFFTFunctions.MultiplySpectra(spec1, spec2 : TMemoryStream ) ;
var
   tint : integer ;
   writeval : Array [0..1] of single ;
   multVal, resVal :  Array [0..1] of single ;
begin
   messagedlg('MultiplySpectra() not fully implemented -  multi y data spectra handling needed' ,mtInformation,[mbOK],0) ;
{  spec1.Seek(0,soFromBeginning) ;
  spec2.Seek(0,soFromBeginning) ;
  for tint := 1 to (spec1.Size div 8) do
  begin
    spec1.Read(writeval,8) ;
    spec2.Read(multVal,8) ;
    resval[0] := writeval[0];
    resval[1] := multVal[1] * writeval[1];    // multiply imaginary value
    spec1.Seek(-8,soFromCurrent) ;
    spec1.Write(resval,8) ;
  end ;  }
end ;


// multiplys a Re()IM() pair in p1 by Re() value in filter (p1)
procedure TFFTFunctions.MultiplyFFT( bw_p, p1 : pointer) ;
var
   t1, t2 : integer ;
   writeval : Array [0..1] of single ;
   multVal, resVal :  Array [0..1] of single ;
   filter, inSR : TSpectraRanges ;
begin

  inSR :=  TSpectraRanges(p1) ;
  filter :=  TSpectraRanges(bw_p) ;
  inSR.SeekFromBeginning(3,1,0) ;
  filter.SeekFromBeginning(3,1,0) ;

  for t1 := 1 to inSR.yCoord.numRows do   // for each spectrum
  begin
  filter.SeekFromBeginning(3,1,0) ;
    for t2 := 1 to inSR.yCoord.numCols do   // for each point
    begin
      inSR.Read_YrYi_Data(t2,t1,@writeVal,false) ;
      filter.yCoord.F_Mdata.Read(multVal,4) ;

      resval[0] := multVal[0] * writeval[0];    // multiply real value
      resval[1] := multVal[0] * writeval[1];    // multiply imaginary value

      inSR.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
      inSR.yImaginary.F_Mdata.Seek(-4,soFromCurrent) ;
      inSR.Write_YrYi_Data(0,t1,@resval,false) ;
    end ;

  end ;

end ;



procedure TFFTFunctions.FFTBandPass( percentage, pow : single; zero : boolean; zeroFill : integer; p1 : pointer ) ;
var
   t1 : integer ;
   writeval : Array [0..1] of single ;
   multVal, resVal :  Array [0..1] of single ;
   origSize : integer ;
   convFunc:    TSpectraRanges ;
   tSR : TSpectraRanges ;
begin

  tSR := TSpectraRanges(p1) ;

  origSize := tSR.xCoord.numCols ;

  ComputeFFTSingle(1, zeroFill, tSR) ;  // FFT *all* of the original spectra

  convFunc :=  TSpectraRanges.Create(1,1,tSR.xCoord.numCols,nil) ;

  CreateButterworthFilter(percentage, pow, convFunc) ;
  MultiplyFFT( convFunc, tSR ) ;

  // middle value of fft data is the numerical average of the data, setting to = zero will drop all data to the baseline
  if zero then
  begin
    resval[0] :=  0.0 ;
    resval[1] :=  0.0 ;
    for t1 := 1 to tSR.yCoord.numRows do  // for each spectrum in TSpectraRange
    begin
      tSR.Write_YrYi_Data((tSR.yCoord.numCols div 2)+1, t1, @resval, true) ;  // t1 is the spectra number
    end ;
  end ;

  ComputeFFTSingle(-1,1, tSR) ;

  convFunc.Free() ;
end ;


// finds max and min of Y data (or Imaginary part) and places it in last 2 array positions
{function TSpectraRanges.FindYLimits(tmem : TMemoryStream) : TGLRangeArray ;
var
 TempYMin, TempYMax : single ;
 temp :  single ;
 tint, tint2 : integer ;
begin
  TempYMax := Math.MinSingle ;
  TempYMin := Math.MaxSingle ;

  tmem.Seek(0,soFromBeginning) ;

  for tint := 1 to (FMemStream.size div (4 * (numSpectra+1))) do
  begin
     FMemStream.Seek( 4, soFromCurrent ) ;
     for tint2 := 1 to numSpectra do
     begin
       tmem.ReadBuffer(temp,4) ;
       if (temp > TempYMax) then  TempYMax := temp ;
       if (temp < TempYMin) then  TempYMin := temp ;
     end ;
  end ;

  result[2] := TempYMin ;
  result[3] := TempYMax ;
end ;   }


// finds max and min of x and y data
{function TSpectraRanges.FindXYLimits( tmem : TMemoryStream) : TGLRangeArray ;
var
 temp1  : TGLRangeArray ;
 tint : integer ;
begin

  result := FindXLimits(tmem ) ;
  result := FindYLimits(tmem ) ;

end ;   }


procedure TFFTFunctions.SaveFFT(SaveDialog : TSaveDialog) ;
var
  List1 : TStringList ;
  FloatX, FloatY, freq  : single ;
  tempStr : string ;
  tint : integer ;
begin

  messagedlg('SaveFFT() not fully implemented' ,mtInformation,[mbOK],0) ;

{  With SaveDialog DO
  begin
    If Execute Then
    begin
      List1 :=  TStringList.Create ;
      FFTMemStream.Seek(0,soFromBeginning) ;
      for tint := 1 to FFTMemStream.Size div 8 do
      begin
        freq := ((tint-1) - (FFTMemStream.Size div 16) ) * (dfreq) ;
        FFTMemStream.Read(FloatX,4) ;
        FFTMemStream.Read(FloatY,4) ;
        tempStr := FloatToStrF(freq,ffExponent	,7,5) +', '+ FloatToStrF(FloatX,ffExponent,7,5) +', '+ FloatToStrF(FloatY,ffExponent,7,5) ;
        List1.Add(tempStr) ;
      end ;
      List1.SaveToFile(filename) ;
      List1.Free();
    end ;
  end ;  }
end ;



// window to reduce sidebands in FFT frequency spectrum
procedure TFFTFunctions.ApplyHanningWindow(numberOfVals : integer; inputRealImagStr : TMemoryStream) ;
var
   tempXY : Array[0..1] of single ;
   t1 : integer ;
   tempSwap : single ;
begin
    numberOfVals := (inputRealImagStr.Size div 8) ;
    inputRealImagStr.Seek(0,soFromBeginning) ;
    for t1 := 0 to (inputRealImagStr.Size div 8)-1 do    // for i := 0 to (n-1) do
    begin
      inputRealImagStr.ReadBuffer(tempXY,8) ;
      tempSwap :=  0.5*(1 - cos(t1 * 6.28318530717959/numberOfVals)) ;   //c := 0.5·(1 - cos(i·2·Pi/n));    // n = number of points
      tempXY[0] :=  tempSwap * tempXY[0] ;   //x[i] := c·x[i];
      tempXY[1] :=  tempSwap * tempXY[1] ;
      inputRealImagStr.Seek(-8,soFromCurrent) ;
      inputRealImagStr.Write(tempXY,8) ;
    end;
end ;


function TFFTFunctions.MultiplyRealImagReal( ri1, ri2 : array of single) : single ;
begin
  result := (ri1[0] * ri2[0]) - (ri1[1] * ri2[1]) ;
end ;
function TFFTFunctions.MultiplyRealImagImag( ri1, ri2 : array of single) : single ;
begin
  result := (ri1[0] * ri2[1]) + (ri1[1] * ri2[0]) ;
end ;


// differentiation in fourier space is done by multiplying each frequency by (i * freq)
// Prof. Griffith method: FFT(freq) * freq^n; where n is order of derivative, freq is the frequency.
// order 1 = 1st deriv, 2 = 2nd etc.
procedure TFFTFunctions.DiffOrIntUsingFFT( p1 : pointer; order : integer; zeroFillIn : integer ) ;
var
  t1, t2, t3, t4, origSize1 : integer ;
  tXYrYi: array[0..2] of single ;
  ta0, ta1, ta2 : array[0..1] of single ;
  freq, tempSwap : single ;
  tspec : TSpectraRanges  ;
  tempRange : TGLRangeArray ;  // array[0..3] of single - 0,1 are min,max of X data, 2,3 are min,max of Y data    }
begin

//  origSize1 := tspec.yCoord.numCols ;
  tspec := TSpectraRanges( p1 ) ;
  
  if  tspec.yCoord.SDPrec = 4 then
  begin
    if FFTReverse then
      tspec.fft.ComputeFFTSingle( -1, zeroFillIn, tspec)
    else
      tspec.fft.ComputeFFTSingle(1, 1, tspec) ;

    tspec.SeekFromBeginning(3,1,0) ;


    for t2 := 1 to tspec.yCoord.numRows do    // for each spectra
    begin
      tspec.xCoord.F_Mdata.Seek(0,soFromBeginning) ; // these are the frequency values
      for t3 := 1 to tspec.yCoord.numCols do   // for each point
      begin
         tspec.Read_XYrYi_Data(t3,t2,@tXYrYi,false) ;
         ta2[0] :=  tXYrYi[1]  ;  // Y real
         ta2[1] :=  tXYrYi[2]  ;  // Y imaginary

         ta0[0] := 0.0 ;                     // Real      = 0.0
         ta0[1] := {-2 * pi * }tXYrYi[0] ;   // Imaginary = -2 * frequency
         for t4 := 2 to  Abs(order) do   // calculate the multiplicand value for the current frequency
         begin
            ta1[0] := MultiplyRealImagReal(ta0,ta0) ;
            ta1[1] := MultiplyRealImagImag(ta0,ta0) ;
            ta0[0] := ta1[0] ;
            ta0[1] := ta1[1] ;
         end ;

         if (order < 0) and ((ta0[0] <> 0) or (ta0[1] <> 0)) then
         begin
           ta1[0] :=     ta0[0] / ((ta0[0] * ta0[0]) + (ta0[1] * ta0[1]))  ;
           ta1[1] :=   - ta0[1] / ((ta0[0] * ta0[0]) + (ta0[1] * ta0[1]))  ;
           ta0[0] := ta1[0] ;
           ta0[1] := ta1[1] ;
         end ;


         ta1[0] :=  MultiplyRealImagReal( ta0, ta2 ) ;
         ta1[1] :=  MultiplyRealImagImag( ta0, ta2 ) ;

         tspec.Write_YrYi_Data(t3,t2,@ta1,true) ;
      end ;
    end ;

    if FFTReverse then
      tspec.fft.ComputeFFTSingle( -1 ,1, tspec)
    else
      tspec.fft.ComputeFFTSingle(1 ,1, tspec) ;
  end ;

//  tspec.FMemStream.SetSize(origSize1) ;  // this chops off any extra points that were added for FFT
end ;



// The Fourier transform of the cross correlation function is the product of the Fourier transform of the first series
// and the complex conjugate of the Fourier transform of the second series.
// Need to implement multi y data spectra handling
procedure TFFTFunctions.CorrelateByFFT(Spec1, Spec2 : TMemoryStream) ;
{var
  tint, origSize1, origSize2 : integer ;
  s1, s2, temps1 : array[0..1] of single ;
  tempRange : TGLRangeArray ;
  scaleFact : single ;    }
begin
  messagedlg('CorrelateByFFT() not fully implemented yet -  multi y data spectra handling needed' ,mtInformation,[mbOK],0) ;
{  origSize1 := Spec1.FMemStream.Size ;
  origSize2 := Spec2.FMemStream.Size ;

  // for rescale
  Spec1.FMemStream.Seek(0,soFromBeginning) ;
  tempRange := FindYLimits(Spec1.FMemStream) ;
  scaleFact := tempRange[3] - tempRange[2] ;


  Spec1.ComputeFFT(1,8) ;
  Spec2.ComputeFFT(1,8) ;
  Spec1.FFTMemStream.Seek(0,soFromBeginning) ;
  Spec2.FFTMemStream.Seek(0,soFromBeginning) ;

  for tint := 1 to (Spec1.FFTMemStream.Size div 8) do
  begin
    Spec1.FFTMemStream.Read(s1,8) ;
    Spec1.FFTMemStream.Seek(-8,soFromCurrent) ;
    Spec2.FFTMemStream.Read(s2,8) ;
    s1[1] := -1 * s1[1] ;  // THIS IS THE ONLY DIFFERENCE BETWEEN CONVOLVE AND CORRELATION FUNCTIONS

    temps1[0] := s1[0]  ;
    s1[0] :=  (s1[0] * s2[0]) - ( s1[1] * s2[1]) ; //  real part
    s1[1] :=   (temps1[0] * s2[1]) + (s1[1] * s2[0])  ;    // imaginary part
    Spec1.FFTMemStream.Write(s1,8) ;
  end ;

  Spec1.ComputeFFT(-1,1) ;
  Spec2.ComputeFFT(-1,1) ;

  Spec1.FMemStream.SetSize(origSize1) ;  // this chops off any extra points that were added for FFT
  Spec2.FMemStream.SetSize(origSize2) ;  // this chops off any extra points that were added for FFT

  // rescale data to same height as original
  tempRange := FindYLimits(Spec1.FMemStream) ;
  scaleFact :=   scaleFact /(tempRange[3]  - tempRange[2]) ;
  Spec1.FMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to (Spec1.FMemStream.Size div 8) do
  begin
     Spec1.FMemStream.Read(s1,8) ;
     Spec1.FMemStream.Seek(-8, soFromCurrent) ;
     s1[1] := s1[1] * scaleFact ;
     Spec1.FMemStream.Write(s1,8) ;
  end ;     }

end ;



// the Fourier transform of the convolution of two functions is the (complex) product of their Fourier transforms.
{                 (5 + 6i) * (7 + 8i)
This equals       35 + 40i + 42i + 48i2
As we saw above,  i2 = -1 so 48i2 = -48
So answer         = -13 + 82i}
procedure TFFTFunctions.ConvolveByFFT(Spec1, Spec2 : TMemoryStream) ;
{var
  tint, origSize1, origSize2 : integer ;
  s1, s2, temps1 : array[0..1] of single ;
  tempRange : TGLRangeArray ;
  scaleFact : single ;   }
begin
  messagedlg('ConvolveByFFT() not fully implemented yet -  multi y data spectra handling needed' ,mtInformation,[mbOK],0) ;
{  origSize1 := Spec1.FMemStream.Size ;
  origSize2 := Spec2.FMemStream.Size ;

  // for rescale
  Spec1.FMemStream.Seek(0,soFromBeginning) ;
  tempRange := FindYLimits(Spec1.FMemStream) ;
  scaleFact := tempRange[3] - tempRange[2] ;

  Spec1.ComputeFFT(1,8) ;
  Spec2.ComputeFFT(1,8) ;
  Spec1.FFTMemStream.Seek(0,soFromBeginning) ;
  Spec2.FFTMemStream.Seek(0,soFromBeginning) ;

  for tint := 1 to (Spec1.FFTMemStream.Size div 8) do
  begin
    Spec1.FFTMemStream.Read(s1,8) ;
    Spec1.FFTMemStream.Seek(-8,soFromCurrent) ;
    Spec2.FFTMemStream.Read(s2,8) ;

    temps1[0] :=  s1[0] ;
    s1[0] :=  (s1[0] * s2[0]) - ( s1[1] * s2[1]) ; //  real part

    s1[1] :=   (temps1[0] * s2[1]) + (s2[0] * s1[1])  ;    // imaginary part
    Spec1.FFTMemStream.Write(s1,8) ;
  end ;

  Spec1.ComputeFFT(-1,1) ;
  Spec2.ComputeFFT(-1,1) ;

  Spec1.FMemStream.SetSize(origSize1) ;  // this chops off any extra points that were added for FFT
  Spec2.FMemStream.SetSize(origSize2) ;  // this chops off any extra points that were added for FFT

  // rescale data to same height as original
  tempRange := FindYLimits(Spec1.FMemStream) ;
  scaleFact :=   scaleFact /(tempRange[3]  - tempRange[2]) ;
  Spec1.FMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to (Spec1.FMemStream.Size div 8) do
  begin
     Spec1.FMemStream.Read(s1,8) ;
     Spec1.FMemStream.Seek(-8, soFromCurrent) ;
     s1[1] := s1[1] * scaleFact ;
     Spec1.FMemStream.Write(s1,8) ;
  end ;
          }
end ;


{procedure TFFTFunctions.ScaleFFTData(max : single; spectra : TMemoryStream) ;
var
  tint : integer ;
  TempXY : array[0..1] of single ;
  tempRange : TGLRangeArray ;  // array[0..3] of single - 0,1 are min,max of X data, 2,3 are min,max of Y data
begin
  tempRange := FindXLimits(spectra) ;  // finds real part limits
//  tempRange := FindYLimits(FMemStream) ;  // finds imaginary part limits

  max := max / tempRange[1] ;

  for tint := 1 to (spectra.size div 8) do
  begin
    spectra.Read(TempXY,8) ;
    TempXY[0] :=  TempXY[0] * max ; // scale real part
    TempXY[1] :=  TempXY[1] * max ; // scale imaginary part
    spectra.Seek(-8,soFromCurrent) ;
    spectra.Write(TempXY,8) ;
  end ;
end ;


procedure TFFTFunctions.ScaleFFTDataDouble(max : double; spectra : TMemoryStream) ;
var
  tint : integer ;
  TempXY : array[0..1] of double ;
  tempRange : TGLRangeArrayD ;  // array[0..3] of single - 0,1 are min,max of X data, 2,3 are min,max of Y data
begin
  tempRange := FindXLimitsDouble(spectra) ;  // finds real part limits
//  tempRange := FindYLimits(FMemStream) ;  // finds imaginary part limits

  max := max / tempRange[1] ;

  for tint := 1 to (spectra.size div 16) do
  begin
    spectra.Read(TempXY, 16) ;
    TempXY[0] :=  TempXY[0] * max ; // scale real part
    TempXY[1] :=  TempXY[1] * max ; // scale imaginary part
    spectra.Seek(-16,soFromCurrent) ;
    spectra.Write(TempXY,16) ;
  end ;
end ;   }


end.






 {
// for old TSpectraRanges - non-multi y data
procedure TSpectraRanges.ComputeFFT(ForwardOrReverse : integer; ZeroFill : integer) ;
var
  n, mmax, m,  j, istep, i, ii : Longint	 ;
  wtemp,wr,wpr,wpi,wi,theta : double ; // Double precision for the trigonometric recurrences.
//  tempr,tempi : single ;
  numberOfVals : Longint	 ; // this is value "nn" in original code
  NumPointsInArray : Longint	 ;
  tint, upper, lower : Longint ;
  tempXY : Array [0..1] of single ;
  tempRealImag : Array [0..1] of single ;
  dataj, datai : Array [0..1] of single ;
  tempSwap : single ;
  freq : single ;
begin
//#define SWAP(a,b) tempr=(a);(a)=(b);(b)=tempr

// void four1(float data[], unsigned long nn, int isign)
// data[] : a real array of length 2*nn (Contains nn real:imaj pairs).
// nn MUST be an integer power of 2.
// if isign is input as 1 :
//         Replaces data[1..2*nn] by its discrete Fourier transform.
// if isign is input as -1
//         Replaces data[1..2*nn] by nn times its inverse discrete Fourier transform.

  // calculate dt - the spacing of the data
  // get first x value and then get last x value and divide by total number of values
  FMemStream.Seek(0,soFromBeginning) ;
  for tint := 1 to 2 do
  begin
  FMemStream.ReadBuffer(tempXY,8) ;
  if tint = 1 then
    begin
         dt := tempXY[0]  ;   // first x value is dt
         if FFTdirection = false then firstXVal := tempXY[0] ;
    end
  else
    begin
      FMemStream.Seek(-8,soFromEnd) ;
      FMemStream.ReadBuffer(tempXY,8) ; // last x value
      dt :=  tempXY[0] - dt ;           // the last minus the first
      dt := dt / (FMemStream.Size / 8) ; // full range divided by number in range
      if FFTdirection = false then nyquistFreq := 1 / (2*dt) ;
    end ;
  end ;

  // calculate closest power of two
  numberOfVals := ClosestPowofTwo() ;

  // create real and imaginary data for spectral data
  if FFTMemStream.Size = 0 then
  begin
    FFTMemStream.size := 2 * 4 * numberOfVals ;
    FMemStream.Seek(0,soFromBeginning) ;
    FFTMemStream.Seek(0,soFromBeginning) ;
    for tint := 1 to FMemStream.Size div 8 do  // create the real:imag data from the Y data
    begin
      FMemStream.ReadBuffer(tempXY,8) ;
      tempRealImag[0] := tempXY[1] ;
      tempRealImag[1] := 0.0 ;
      FFTMemStream.Write(tempRealImag,8) ;
    end ;
  end ;

  // apply Hanning window
  if hanningWindow = true then
  begin
    ApplyHanningWindow(numberOfVals) ;
  end ;
  // blackman window
//  for j := 0 to (n-1) do
//  begin
//  c := 0.42 - 0.5*cos(2*Pi*j/n) + 0.08*cos(4*Pi*j/n);
//  x[j] := c*x[j];
//  end;

  // add zeros to end of data to increase frequency resolution (Zero-fill)
  numberOfVals :=  numberOfVals *  ZeroFill ;
  FFTMemStream.SetSize( 2 * 4 * numberOfVals) ;
  dfreq  := 1 / (numberOfVals * dt) ;

   // This is the bit-reversal section of the routine.
   FFTMemStream.Seek(0,soFromBeginning) ;
   ii := 1 ;
   n := numberOfVals shl 1 ;  // multiply by 2
   j:=1;
   for i:=1 to numberOfVals do
   begin
     if (j > ii) then
     begin
        FFTMemStream.Seek((j-1)*4,soFromBeginning) ;
        FFTMemStream.ReadBuffer(tempXY,8) ;
        FFTMemStream.Seek((ii-1)*4,soFromBeginning) ;
        FFTMemStream.ReadBuffer(tempRealImag,8) ;
        FFTMemStream.Seek((j-1)*4,soFromBeginning) ;
        FFTMemStream.Write(tempRealImag,8) ;
        FFTMemStream.Seek((ii-1)*4,soFromBeginning) ;
        FFTMemStream.Write(tempXY,8) ;
     end ;
     m := numberOfVals ;
    while (m >= 2) and (j > m) do
    begin
      j := j - m;
      m := m shr 1;
    end ;
    j := j + m ;
    ii := ii + 2 ;
  end ;

// Here begins the Danielson-Lanczos section of the routine.
FFTMemStream.Seek(0,soFromBeginning) ;
mmax := 2;
while (n > mmax) do // Outer loop executed log2 nn times.
begin
  istep := mmax shl 1;
  theta := ForwardOrReverse*(6.28318530717959/mmax); // Initialize the trigonometric recurrence.
  wtemp := sin(0.5*theta);
  wpr := -2.0*wtemp*wtemp;
  wpi := sin(theta);
  wr := 1.0;
  wi := 0.0;
  // for (m:=1;m<mmax;m+=2)  // Here are the two nested inner loops.
  m := 1  ;
  while m < mmax do
  begin
   // for (i=m;i<=n;i+=istep)
    i := m ;
    while i <= n do
    begin
      j := i+mmax; // This is the Danielson-Lanczos formula:
      FFTMemStream.Seek((j-1)*4,soFromBeginning) ;
      FFTMemStream.ReadBuffer(dataj,8) ;
      tempRealImag[0] := wr*dataj[0]-wi*dataj[1]; // tempr := wr*data[j]-wi*data[j+1];
      tempRealImag[1] := wr*dataj[1]+wi*dataj[0]; // tempi := wr*data[j+1]+wi*data[j];
      FFTMemStream.Seek((i-1)*4,soFromBeginning) ;
      FFTMemStream.ReadBuffer(datai,8) ;
      dataj[0] := datai[0] - tempRealImag[0] ;   // data[j] := data[i]-tempr;
      dataj[1] := datai[1] - tempRealImag[1] ;   // data[j+1] := data[i+1]-tempi;
      datai[0] := datai[0] + tempRealImag[0] ;   // data[i] := data[i] + tempr;
      datai[1] := datai[1] + tempRealImag[1] ;   // data[i+1] := data[i+1] + tempi;
      FFTMemStream.Seek((j-1)*4,soFromBeginning) ;
      FFTMemStream.Write(dataj,8) ;
      FFTMemStream.Seek((i-1)*4,soFromBeginning) ;
      FFTMemStream.Write(datai,8) ;
      i := i + istep ;
    end ;
    wtemp := wr ;
    wr := wtemp*wpr-wi*wpi+wtemp; // Trigonometric recurrence.
    wi := wi*wpr+wtemp*wpi+wi;
    m := m + 2 ;
  end ;
  mmax := istep;
end ;

  // Scale the results
  if ForwardOrReverse = -1 then
  begin
    FFTMemStream.Seek(0,soFromBeginning) ;
    for tint := 1 to (FFTMemStream.size div 8) do
    begin
      FFTMemStream.ReadBuffer(TempXY,8) ;
      TempXY[0] := TempXY[0] / numberOfVals ;
      TempXY[1] := TempXY[1] / numberOfVals ;
      FFTMemStream.Seek(-8,soFromCurrent) ;
      FFTMemStream.write(TempXY,8) ;
    end ;
  end ;

  FMemStream.Clear() ;
  FMemStream.SetSize( FFTMemStream.Size ) ;
  FMemStream.Seek(0,soFromBeginning) ;
  if FFTdirection = false then   // reorder data
  begin
    FFTMemStream.Seek((FFTMemStream.size div 2),soFromBeginning) ;
    for tint := 1 to (FFTMemStream.size div 16) do // write -ve frquency values
    begin
       FFTMemStream.ReadBuffer(TempXY,8) ;
       FMemStream.Write(TempXY,8) ;
    end ;
    // write +ve frquency values to rest of stream
    FFTMemStream.Seek(0,soFromBeginning) ;
    for tint := 1 to (FFTMemStream.size div 16) do // write +ve frquency values
      begin
       FFTMemStream.ReadBuffer(TempXY,8) ;
       FMemStream.Write(TempXY,8) ;
      end ;
  end
  else  // do not reorder data if we are doing backwards FFT
    begin
      FMemStream.Clear() ;
      FMemStream.SetSize( FFTMemStream.Size ) ;
      FMemStream.Seek(0,soFromBeginning) ;
      FFTMemStream.Seek(0,soFromBeginning) ;
      for tint := 1 to (FFTMemStream.size div 8) do // write all
      begin
         FFTMemStream.ReadBuffer(TempXY,8) ;
         FMemStream.Write(TempXY,8) ;
      end ;
    end ;

  FFTMemStream.Clear() ;
  FFTMemStream.SetSize( FMemStream.Size ) ;
  FFTMemStream.LoadFromStream( FMemStream ) ;  // load the rearranged data back into the FFT data stream

  // position data in correct place
  if FFTdirection = false then
  begin
     lower := -(FMemStream.size div 16)+1 ;
     upper :=  (FMemStream.size div 16) ;
  end
  else
  begin
     lower := 1 ;
     upper :=  (FMemStream.size div 8) ;
  end ;

  // write amplitude data to FMemStream  for display
  FMemStream.Seek(0,soFromBeginning) ;
  for tint := lower to upper do
  begin
    freq :=  (tint-1) * dfreq ;
    FMemStream.ReadBuffer(TempXY,8) ;
    tempSwap :=  sqrt((TempXY[0] * TempXY[0]) + (TempXY[1] * TempXY[1]) ) ;
    TempXY[0] := freq ;
    TempXY[1] := tempSwap ;
    FMemStream.Seek(-8,soFromCurrent) ;
    FMemStream.Write(TempXY,8) ;
  end ;

  if FFTdirection = false then
    begin
      FFTdirection :=  true ;
    end
  else
    begin
      FFTdirection := false ;
      ShiftData(firstXVal) ; // shift data back to original position
      FFTMemStream.Clear() ; // clear FFTmemstream if doing second FFT to get original data space
    end ;

end ;        }

 