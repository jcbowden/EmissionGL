unit TVarAndCoVarOperations;
//{$define FREEPASCAL=1}
{$ifdef FREEPASCAL}
{$mode delphi}
{$endif}
interface

uses  classes,  TMatrixOperations, TMatrixObject  ;

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

    // Returns covariance between rows of two different input maticies (have to have same number of rows)
    function GetSampleVarCovarOfTwoMatrix(dataM1,dataM2  : TMatrix) : TMatrix ;

  private
    procedure MultiplyAverages( inDataMat : TMatrix; multFact : single ) ;
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



procedure TVarAndCoVarFunctions.MultiplyAverages( inDataMat : TMatrix; multFact : single ) ;
var
  t1 : integer ;
  m1_ave   : single ;
  m1_ave_d : double ;
begin
  // pre-multiply the averages
  inDataMat.F_MAverage.Seek(0,soFromBeginning) ;
  if inDataMat.SDPrec = 4 then
  begin
    for t1 := 0 to inDataMat.numCols - 1 do
    begin
      inDataMat.F_MAverage.Read(m1_ave,inDataMat.SDPrec) ;
      inDataMat.F_MAverage.Seek(-inDataMat.SDPrec,soFromCurrent) ;
      m1_ave := m1_ave * multFact; // these are not averages now, but the total sum of the column (as required)
      inDataMat.F_MAverage.Write(m1_ave,inDataMat.SDPrec) ;
    end;
  end
  else
  if inDataMat.SDPrec = 8 then
  begin
    for t1 := 0 to inDataMat.numCols - 1 do
    begin
      inDataMat.F_MAverage.Read(m1_ave_d,inDataMat.SDPrec) ;
      inDataMat.F_MAverage.Seek(-inDataMat.SDPrec,soFromCurrent) ;
      m1_ave_d := m1_ave_d * multFact; // these are not averages now, but the total sum of the column (as required)
      inDataMat.F_MAverage.Write(m1_ave_d,inDataMat.SDPrec) ;
    end;
  end  ;

  inDataMat.F_MAverage.Seek(0,soFromBeginning) ;
end;



function TVarAndCoVarFunctions.GetSampleVarCovarOfTwoMatrix(dataM1,dataM2  : TMatrix) : TMatrix ;   // dataMatrix has to be mean centred
// returns variance / covariance matrix
var
  tMat : TMatrix ;
  t1, t2, SD  : integer ;
  s1, m1_ave,   m2_ave,   sd1,   sd2,   i_div    : single  ;
  d1, m1_ave_d, m2_ave_d, sd1_d, sd2_d, i_div_d  : double  ;
  originallyMC_M1, originallyMC_M2 : boolean ;
begin
try
  // transpose as we want the variance within a sample (within a single spectra)
  dataM1.Transpose  ;   // have to untranspose  after
  dataM2.Transpose  ;   // have to untranspose  after
  // do this so matrix multiplication will give us the variance and covariance matrix
  //(do not need to subtract the mean as this zeros it)
  if dataM1.meancentred = true  then  originallyMC_M1 := true else originallyMC_M1 := false ;
  if dataM2.meancentred = true  then  originallyMC_M2 := true else originallyMC_M2 := false ;
  dataM1.MeanCentre ;   // have to unmeancentre after
  dataM2.MeanCentre ;   // have to unmeancentre after
  dataM1.Stddev(true) ;
  dataM2.Stddev(true) ;

  if dataM1.numRows = dataM2.numRows then
    tMat :=  mo.MultiplyMatrixByMatrix(dataM1,dataM2, true,false, dataM1.numRows , false) ;   // was 1/(dataMatrix.numCols-1), which was WRONG
  // could exchange 1.0 for  dataM1.numRows and then remove from (below):

  // pre-multiply the averages to obtain *sum* of all data in a column
  MultiplyAverages( dataM1, dataM1.numRows ) ;
  MultiplyAverages( dataM2, dataM2.numRows ) ;


  SD := tMat.SDPrec ;
  if SD = 4 then
  begin
    i_div := dataM2.numRows ;
    i_div := i_div * ( i_div - 1.0) ;
    tMat.F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 0 to tMat.numRows - 1 do
    begin
      dataM1.F_MAverage.Read(m1_ave,SD) ;
      dataM1.F_MStdDev.Read(sd1,SD) ;

      for t2 := 0 to tMat.numCols - 1 do
      begin
         dataM2.F_MAverage.Read(m2_ave,SD) ;
         dataM2.F_MStdDev.Read(sd2,SD) ;
         tMat.F_Mdata.Read(s1,SD);
         tMat.F_Mdata.Seek(-SD,soFromCurrent) ;
         s1 := ((s1 ) - ( m1_ave  *  m2_ave)) / i_div ;   // was (s1 * dataM1.numRows) but the multiply is done in the MultiplyMatrixByMatrix () function above
         s1 := s1 / (sd1 * sd2) ;
         tMat.F_Mdata.Write(s1,SD);
      end;
      dataM2.F_MAverage.Seek(0,soFromBeginning) ;
      dataM2.F_MStdDev.Seek(0,soFromBeginning) ;
    end;
  end
  else
  if SD = 8  then
  begin
    i_div_d := dataM2.numRows ;
    i_div_d := i_div_d * ( i_div_d - 1.0) ;
    tMat.F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 0 to tMat.numRows - 1 do
    begin
      dataM1.F_MAverage.Read(m1_ave_d,SD) ;
      dataM1.F_MStdDev.Read(sd1_d,SD) ;

      for t2 := 0 to tMat.numCols - 1 do
      begin
         dataM2.F_MAverage.Read(m2_ave_d,SD) ;
         dataM2.F_MStdDev.Read(sd2_d,SD) ;
         tMat.F_Mdata.Read(d1,SD);
         tMat.F_Mdata.Seek(-SD,soFromCurrent) ;
         d1 := ((d1 ) - ( m1_ave_d  *  m2_ave_d)) / i_div ;   // was (s1 * dataM1.numRows) but the multiply is done in the MultiplyMatrixByMatrix () function above
         d1 := d1 / (sd1_d * sd2_d) ;
         tMat.F_Mdata.Write(d1,SD);
      end;
      dataM2.F_MAverage.Seek(0,soFromBeginning) ;
      dataM2.F_MStdDev.Seek(0,soFromBeginning) ;
    end;
  end;
  // reset stream position to start of stream
  tMat.F_Mdata.Seek(0,soFromBeginning) ;
  dataM1.F_MAverage.Seek(0,soFromBeginning) ;
  dataM1.F_MStdDev.Seek(0,soFromBeginning) ;
  dataM2.F_MAverage.Seek(0,soFromBeginning) ;
  dataM2.F_MStdDev.Seek(0,soFromBeginning) ;

  // undo everything done to original matricies
  MultiplyAverages( dataM1, 1/dataM1.numRows ) ;
  MultiplyAverages( dataM2, 1/dataM2.numRows ) ;
  dataM1.AddVectToMatrixRows(dataM1.F_MAverage) ;   // unmeancentre
  dataM2.AddVectToMatrixRows(dataM2.F_MAverage) ;   // unmeancentre
  dataM1.Transpose  ;   // have to untranspose  after
  dataM2.Transpose  ;   // have to untranspose  after
  if originallyMC_M1 = true  then  dataM1.MeanCentre else dataM1.meancentred := false ;
  if originallyMC_M2 = true  then  dataM2.MeanCentre else dataM2.meancentred := false ;

  finally
     Result := tMat ;
  end;
end ;





function TVarAndCoVarFunctions.GetVarCovarMatrix(dataMatrix : TMatrix) : TMatrix ;   // dataMatrix has to be mean centred
// returns variance / covariance matrix
// Diagonals of Var/Covar matrix is variance. sqrt(variance) is the stddev
var
  matCopy : TMatrix ;
begin
  try
     matCopy := TMatrix.Create(dataMatrix.SDPrec) ;
     matCopy.CopyMatrix(dataMatrix) ;
     if dataMatrix.meanCentred = false then
       matCopy.MeanCentre ;   // THIS WOULD MODIFY the input data - So copy to new TMatrix (above)

  // the result should always be equal to the number of variables (i.e. # of columns)
    if matCopy.numRows > 1 then
    result :=  mo.MultiplyMatrixByMatrix(matCopy,matCopy,true,false, 1/(matCopy.numRows-1), true) ;   // was 1/(dataMatrix.numCols-1), which was WRONG


  finally
    matCopy.Free  ;
  end;
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
 
