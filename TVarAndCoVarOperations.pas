unit TVarAndCoVarOperations;

interface


uses  classes, Dialogs, SysUtils, controls, TMatrixOperations, TMatrixObject  ;
type
  TVarAndCoVarFunctions = class(TObject)
  public
    mo : TMatrixOps ;

    constructor Create ; // singleOrDouble = 1 (single) or = 2 (double)
    destructor  Destroy; override; // found in implementation part below
    procedure   Free;

    function GetVarCovarMatrix(dataMatrix : TMatrix) : TMatrix ;   // matrix multiplication to create a new matrix
    function ReturnCovariance(varCovarMatrix : TMatrix; sample1, sample2 : integer) : single ;   // used after call of GetVarCovarMatrix() to return sample specific covariance
    // uses the sqrt(variance) = stdev; variance = diagonals of varCovar TMatrix. varCovar is from GetVarCovarMatrix()
    function StandardiseVarCovar(varCovarMatrix : TMatrix) : boolean ;
    // uses  StandardiseVarCovar() and takes off diagonals
    // varStandardisedCovar is from StandardisedVarCovar(); sample1, sample2 are indices to the 2D correlation matrix
    function ReturnPearsonsCoeffFromStandardisedVarCovar(varStandardisedCovar : TMatrix; sample1, sample2 : integer) : single ;
    // uses  StandardiseVarCovar() and takes off diagonals and square them.
    // varStandardisedCovar is from StandardisedVarCovar(); sample1, sample2 are indices to the 2D correlation matrix
    function ReturnCorrelCoeffFromStandardisedVarCovar(varStandardisedCovar : TMatrix; sample1, sample2  : integer) : single ;
  private
end;



implementation


constructor TVarAndCoVarFunctions.Create ;
begin
  inherited Create;
  mo := TMatrixOps.Create ;
end;


destructor TVarAndCoVarFunctions.Destroy;
begin
  mo.Free ;
  inherited Destroy;
end;


procedure TVarAndCoVarFunctions.Free;
begin
 if Self <> nil then Destroy;
end;



function TVarAndCoVarFunctions.GetVarCovarMatrix(dataMatrix : TMatrix) : TMatrix ;   // dataMatrix has to be mean centred
// returns variance / covariance matrix
// Diagonals of Var/Covar matrix is variance. sqrt(variance) is the stddev
var
  matCopy : TMatrix ;
begin
     matCopy := TMatrix.Create(dataMatrix.SDPrec div 4) ;
     matCopy.CopyMatrix(dataMatrix) ;
     if dataMatrix.meanCentred = false then
       matCopy.MeanCentre ;   // THIS WOULD MODIFY the input data - So copy to new TMatrix (above)

  // the result should always be equal to the number of variables (i.e. # of columns)
    if matCopy.numRows > 1 then
    result :=  mo.MultiplyMatrixByMatrix(matCopy,matCopy,true,false, 1/(matCopy.numRows-1), true) ;   // was 1/(dataMatrix.numCols-1), which was WRONG

    matCopy.Free ;
end ;



function TVarAndCoVarFunctions.StandardiseVarCovar(varCovarMatrix : TMatrix) : boolean ;
// input matrix is returned as 'Pearsons R matrix' or the 'correlation' matrix
// i.e. the standardised Covariance (correlation) from the variance/covariance matrix
// Diagonals of input Var/Covar matrix is variance. sqrt(variance) is the stddev
// Take the off diagonals of the result and ^2 to get R squared
var
  t1, t2 : integer ;
  stdev_1s, stdev_2s, data_s : single ;
  stdev_1d, stdev_2d, data_d : double ;
  tStrm : TMemoryStream ;
begin
  result := false ;
 try
 try
  varCovarMatrix.F_Mdata.Seek(0,soFromBeginning) ;

  tStrm := varCovarMatrix.GetDiagonal(varCovarMatrix) ;

  if  tStrm <> nil then
  begin
  tStrm.Seek(0,soFromBeginning) ;

  // obtain the standard deviations
  for t1 := 1 to varCovarMatrix.numCols do
  begin
    if varCovarMatrix.SDPrec = 4 then
    begin
       tStrm.Read(stdev_1s, 4) ;
       tStrm.Seek(-4,soFromCurrent) ;
       if stdev_1s < 0 then stdev_1s := 0.0 ;
       stdev_1s := sqrt(stdev_1s) ; // square root of diagonals are the standard deviations
       tStrm.Write(stdev_1s, 4) ;
    end
    else
    begin
       tStrm.Read(stdev_1d, 8) ;
       tStrm.Seek(-8,soFromCurrent) ;
       if stdev_1s < 0 then stdev_1s := 0.0 ;
       stdev_1d := sqrt(stdev_1d) ; // square root of diagonals are the standard deviations
       tStrm.Write(stdev_1d, 8) ;
    end ;
  end ;

  tStrm.Seek(0,soFromBeginning) ;
  varCovarMatrix.F_Mdata.Seek(0,soFromBeginning) ;

  // normalise data by division by (stdev1 * stdev2)
  if varCovarMatrix.SDPrec = 4 then
  begin
  for t1 := 0 to varCovarMatrix.numRows-1  do
  begin
     tStrm.Seek(t1*4, soFromBeginning) ;
     tStrm.Read(stdev_1s, 4) ;
     tStrm.Seek(0,soFromBeginning) ;
     for t2 := 0 to varCovarMatrix.numCols-1 do
     begin
        tStrm.Read(stdev_2s, 4) ;
        varCovarMatrix.F_Mdata.Read(data_s, 4) ;
        varCovarMatrix.F_Mdata.Seek(-4, soFromCurrent) ;
        if (stdev_1s <> 0) and (stdev_2s <> 0) then
        begin
          data_s := data_s / (stdev_1s * stdev_2s) ;
          varCovarMatrix.F_Mdata.Write(data_s, 4) ;
        end
        else
        if (stdev_1s = 0) and (stdev_2s = 0) then
        begin
          data_s := 1 ;
          varCovarMatrix.F_Mdata.Write(data_s, 4) ;
        end
     end ;
  end ;
  end
  else // varCovarMatrix.SDPrec = 8
  begin
  for t1 := 0 to varCovarMatrix.numRows-1  do
  begin
     tStrm.Seek(t1*8, soFromBeginning) ;
     tStrm.Read(stdev_1d, 8) ;
     tStrm.Seek(0,soFromBeginning) ;
     for t2 := 0 to varCovarMatrix.numCols-1 do
     begin
        tStrm.Read(stdev_2d, 8) ;
        varCovarMatrix.F_Mdata.Read(data_d, 8) ;
        varCovarMatrix.F_Mdata.Seek(-8,soFromCurrent) ;
        if (stdev_1d <> 0) and (stdev_2d <> 0) then
        begin
          data_d := data_d / (stdev_1d * stdev_2d) ;
          varCovarMatrix.F_Mdata.Write(data_d, 8) ;
        end
        else
        if (stdev_1d = 0) and (stdev_2d = 0) then
        begin
          data_d := 1 ;
          varCovarMatrix.F_Mdata.Write(data_d, 8) ;
        end
     end ;
  end ;
  end ;
  end ; // if  tStrm <> nil then
 finally
   if  tStrm <> nil then
     tStrm.Free ;
   result := true ;
 end ;
 except
   result := false ;
 end ;
end ;


function TVarAndCoVarFunctions.ReturnCorrelCoeffFromStandardisedVarCovar(varStandardisedCovar : TMatrix; sample1, sample2 : integer) : single ;
// off diagonals squared are the 'coefficient of determination' or R squared values
var
   seekPos : integer ;
   s1 : single ;
   d1 : double ;
begin
   seekPos := ((sample1-1)*varStandardisedCovar.SDPrec) + ((sample2-1)*varStandardisedCovar.SDPrec) ;
   varStandardisedCovar.F_Mdata.Seek(seekPos, soFromBeginning) ;
   if varStandardisedCovar.SDPrec = 4 then
   begin
     varStandardisedCovar.F_Mdata.Read( s1 , varStandardisedCovar.SDPrec) ;
     result := s1 * s1 ;
   end
   else
   begin  // varStandardisedCovar.SDPrec = 8 ; double precision
     varStandardisedCovar.F_Mdata.Read( d1 , varStandardisedCovar.SDPrec) ;
     result := d1 * d1 ;
   end ;

end ;


function TVarAndCoVarFunctions.ReturnPearsonsCoeffFromStandardisedVarCovar(varStandardisedCovar : TMatrix; sample1, sample2 : integer) : single ;
// off diagnols are the 'standardised covariance' of two variables (= Pearsons R)
{ have to call:
  GetVarCovarMatrix()
  then
  StandardiseVarCovar()
}
var
   seekPos : integer ;
   s1 : single ;
   d1 : double ;
begin
   seekPos := ((sample1-1)*varStandardisedCovar.SDPrec) + ((sample2-1)*varStandardisedCovar.SDPrec) ;
   varStandardisedCovar.F_Mdata.Seek(seekPos, soFromBeginning) ;
   if varStandardisedCovar.SDPrec = 4 then
   begin
     varStandardisedCovar.F_Mdata.Read( s1 , varStandardisedCovar.SDPrec) ;
     result := s1 ;
   end
   else
   begin  // varStandardisedCovar.SDPrec = 8 ; double precision
     varStandardisedCovar.F_Mdata.Read( d1 , varStandardisedCovar.SDPrec) ;
     result := d1 ;
   end ;

end ;


function TVarAndCoVarFunctions.ReturnCovariance(varCovarMatrix : TMatrix; sample1, sample2 : integer) : single ;
//  off diagonal is the 'covariance' of two variables
var
   seekPos : integer ;
   s1 : single ;
   d1 : double ;
begin
   seekPos := ((sample1-1)*varCovarMatrix.SDPrec) + ((sample2-1)*varCovarMatrix.SDPrec) ;
   varCovarMatrix.F_Mdata.Seek(seekPos, soFromBeginning) ;
   if varCovarMatrix.SDPrec = 4 then
   begin
     varCovarMatrix.F_Mdata.Read( s1 , varCovarMatrix.SDPrec) ;
     result := s1 ;
   end
   else
   begin  // varStandardisedCovar.SDPrec = 8 ; double precision
     varCovarMatrix.F_Mdata.Read( d1 , varCovarMatrix.SDPrec) ;
     result := d1 ;
   end ;

end ;




end.
 