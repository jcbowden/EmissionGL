unit TPreprocessUnit;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses  classes, SysUtils, TMatrixObject, TSpectraRangeObject, TBatchBasicFunctions,
      FFTUnit, BLASLAPACKfreePas  ;

type
  TPreprocess  = class
  public
     bb           : TBatchBasics ;
//     fft          : TFFTFunctions     not needed as they are present in TSpectraRanges

     lineString   : string ;

     constructor Create ;
     destructor  Destroy; override;
     procedure   Free ;

     {
     function BaselineCorrect(x1, y1, x2, y2 : single; snapToPoints : boolean; var inSpect : TMatrix)  : TMatrix ;
     function ChangeUnits( fromString, toString : string ; var inSpect : TSpectraRanges) : TSpectraRanges ;
     function NormaliseToPeakArea( x1, y1, x2, y2 : single ; var inSpect : TMatrix) : TMatrix ;
     function SubfirstSpectFromAllSpectra( var inSpect : TMatrix ) : TMatrix ;
     function SelfDeconvolveByFFT( var inSpect : TMatrix ) : TMatrix ;
     }

     // smooth = average,15  // fourier,15,50,remove complex  // %,power
     function Smooth(InputDetails : string ; var inSpect : TSpectraRanges )  : string ; // this uses either an average smooth or a Fourier smooth

    // derivative = fourier, 2, remove complex // fourier only available
     function Differentiate( InputDetails : string ; var inSpect : TSpectraRanges ) : string ;

    // usefull after any Fourier functions have been used
     procedure RemoveImaginaryMatrix( var inSpect : TSpectraRanges )  ;

     procedure VectorNormalise(var inSpect : TMatrix) ;
  private

end;

implementation

constructor TPreprocess.Create ;
begin
   bb := TBatchBasics.Create ;
end ;

destructor TPreprocess.Destroy ;
begin
   bb.Free   ;
end ;

procedure TPreprocess.Free;
begin
 if Self <> nil then Destroy;
end;





procedure TPreprocess.RemoveImaginaryMatrix( var inSpect : TSpectraRanges )  ;
begin
     if inSpect.yImaginary <> nil then
     begin
        inSpect.yImaginary.Free ;
        inSpect.yImaginary := nil ;
     end ;
end ;



function TPreprocess.Smooth(InputDetails : string ; var inSpect : TSpectraRanges )  : string ;
// this calls either AverageSmooth or FourierSmooth     tSR.yCoord.AverageSmooth(StrToInt(Trim(copy(Form2.ComboBox5.Text,1,pos(' ',Form2.ComboBox5.Text)-1)))) ;
// InputDetails = "average,15"  // or "fourier,15,50,remove complex"  // %,power
var
  boxcarAve : string ;
  boxAveInt : integer ;
  t1 : integer   ;
  remComplex : boolean ;
  nyquist, power : single ;
begin
  result := '' ;
  inputDetails := lowerCase(inputDetails) ;
  if pos('fourier', InputDetails) > 0  then
  begin
    try
     t1 := pos(',', InputDetails) ;  // finds first comma
     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from first comma to end of string
     t1 := pos(',', InputDetails) ;  // finds second comma
     nyquist := strtoFloat(copy(inputDetails,1,t1-1)) ;

     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;
     t1 := pos(',', InputDetails) ;  // finds third comma
     if t1 = 0 then t1 := length(inputdetails) ;
     power := strtoFloat(copy(inputDetails,1,t1-1)) ;

     if pos('remove complex',inputDetails) > 0 then
       remComplex := true
     else
       remComplex := false ;

     inSpect.fft.FFTBandPass(nyquist/100,power,false,1,inSpect) ;

     if remComplex then
        self.RemoveImaginaryMatrix(inSpect) ;

    except on econverterror  do
    begin
      result := 'fourier smooth batch details incorrect' ;
      exit ;
    end ;
    end ;
  end
  else
  if pos('average', InputDetails) > 0  then
  begin
    try
      t1 := pos(',', InputDetails) ;  // finds first comma
      boxcarAve := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from first comma to end of string
//      t1 := pos(',', InputDetails) ;  // finds second comma
//      boxcarAve := copy(inputDetails,1,t1-1) ;

      boxAveInt := strtoint(boxcarAve) ;

      if ((boxAveInt mod	 2) = 0) then  // boxAveInt has to be an odd number
        boxAveInt := boxAveInt + 1 ;

     inSpect.yCoord.AverageSmooth(boxAveInt) ;

    except on econverterror  do
    begin
      result := 'average smooth batch details incorrect' ;
      exit ;
    end ;
    end ;
  end ;

end ;




// InputDetails = "fourier, 2, remove complex, true, 1" // inputs: "diff type: 1st 2nd deriv etc: true = Hanning Window: 1 2 3 etc = zero fill"  N.B. type=fourier only available;
function TPreprocess.Differentiate( inputDetails : string ; var inSpect : TSpectraRanges ) : string ;
var
  derivNum, zeroFillStr : string ;
  t1 : integer   ;
  remComplex : boolean ;
  hanning    : boolean ;
  zeroFillIn : integer ;
begin
  inputDetails := lowerCase(inputDetails) ;
  if pos('fourier', InputDetails) > 0  then
  begin
    try
     t1 := pos(',', InputDetails) ;  // finds first comma
     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from first comma to end of string
     derivNum := copy(inputDetails,1,pos(',',inputDetails)-1) ;  // copies to second comma
     derivNum := trim(derivNum) ;                            // trims leading/trailing spaces
     if pos('remove complex',inputDetails) > 0 then
       remComplex := true
     else
       remComplex := false ;

     if pos('true',InputDetails) > 0 then
       inSpect.fft.hanningWindow := true 
     else
       inSpect.fft.hanningWindow := false ;


     t1 := pos(',', InputDetails) ;  // finds first comma
     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from 2nd comma to end of string
     t1 := pos(',', InputDetails) ;  // finds first comma
     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from 3rd comma to end of string
     t1 := pos(',', InputDetails) ;  // finds first comma
     inputDetails := copy(inputDetails,t1+1,length(inputDetails)) ;   // copies from 4th comma to end of string

     zeroFillStr :=  trim(copy(inputDetails,1,length(inputDetails))) ;  // copies last number
     zeroFillIn := strtoint(zeroFillStr) ;

     inSpect.fft.DiffOrIntUsingFFT(inSpect,strtoint(derivNum),zeroFillIn ) ;   // could add

     if remComplex then
        self.RemoveImaginaryMatrix(inSpect) ;

     result := '' ;  // all went well!

     except
     begin
       result := 'Differentiation of data failed. ' ;
       exit ;
     end ;
     end ;
  end ;


end ;


procedure TPreprocess.VectorNormalise(var inSpect : TMatrix);
var
  t1, t2 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
begin
         MKLa := inSpect.F_Mdata.Memory ;
         MKLtint := 1 ;
         // normalise input vector  -
         for t2 := 1 to inSpect.numRows do
         begin
           if  (inSpect.SDPrec = 4) and (inSpect.complexMat=1) then
           begin
             lengthSSEVects_s := snrm2 ( inSpect.numCols , MKLa, MKLtint ) ;
             if lengthSSEVects_s <> 0 then
             lengthSSEVects_s := 1/lengthSSEVects_s ;
             sscal (inSpect.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
           end
           else
           if  (inSpect.SDPrec = 8) and (inSpect.complexMat=1) then
            begin
              lengthSSEVects_d := dnrm2 ( inSpect.numCols , MKLa, MKLtint ) ;
              if lengthSSEVects_s <> 0 then
                lengthSSEVects_d := 1/lengthSSEVects_d ;
              dscal (inSpect.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
            end
           else
           if  (inSpect.SDPrec = 4) and (inSpect.complexMat=2) then
           begin
                lengthSSEVects_s := scnrm2 ( inSpect.numCols , MKLa, MKLtint ) ;
                if lengthSSEVects_s <> 0 then
                lengthSSEVects_s := 1/lengthSSEVects_s ;
                csscal (inSpect.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
           end
           else
           if  (inSpect.SDPrec = 8) and (inSpect.complexMat=2) then
           begin
                lengthSSEVects_d := dznrm2 ( inSpect.numCols , MKLa, MKLtint ) ;
                if lengthSSEVects_s <> 0 then
                lengthSSEVects_d := 1/lengthSSEVects_d ;
                zdscal (inSpect.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
           end  ;
           MKLa := inSpect.MovePointer(MKLa,inSpect.numCols * inSpect.SDPrec * inSpect.complexMat) ;
         end ;
end;


end.
 
