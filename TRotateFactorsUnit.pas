unit TRotateFactorsUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject, TMatrixOperations,
  TBatch ;

type
  TRotateFactor3D  = class
  public
     XYZ_PCs                                     : string ;    // these PCs are extracted in the oreder give to become PC1, PC2 and PC3 corresponding to the x,y and z axe


     angleX, angleY, angleZ                      : single ;
     angleRangePC1, angleRangePC2, angleRangePC3 : string ;           // number of angles is determined by: range / angle

     originalVectors                             : TMatrix ;          // these are used for each rotation
     numVects                                    : integer ;          // can be 2 or 3
     RotatedPC1, RotatedPC2, RotatedPC3          : TSpectraRanges ;   // seperate each rotated PC at each angle of rotation
     combinedRotatedXYZ                          : TSpectraRanges ;   // in interleaved order (12312323 etc.)

     fitToFactorBool                             : boolean ;          // if true then try rotate vectors to minimise difference between the rotated vector and  factorToFitSpectra
     factorToFit                                 : integer ;          // this is the PC that we are going to match to factorToFitSpectra
     factorToFitSpectra                          : TSpectraRanges ;   // this is used if we are trying to fit rotated vectors
     Angle_min                                   : single ;           // this is the angle of best match to 'factorToFitSpectra'

     bB :   TBatchBasics ;
     mo :   TMatrixOps ;

     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     // if lineNum is -ve then function has failed
     // has to be called externally before  ProcessRotationBatchFile
     function   GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     // inVect is array of vectors (3 of which are) to be rotated
     // return value is an error message or blank string if no error.
     function   SurveyRotationBatchFile( inVect : TSpectraRanges) : string ;  // this calls private functions and creates model
     function   Return3DRotationMatrix( rotateAboutXYorZ : integer ; angleDegrees : single  ) : TMatrix ;  // rotateAboutXYorZ = 1 for x, 2 for y, 3 for z
     // has to be called from external code which has access to the source data (sourceSpecRange) - usually the 2nd column next to original data     p
     function   GetFactorToFitSpectra(sourceSpecRange : TSpectraRanges ) : boolean ;
     function   SumOfSquaresOfDifferences( rotatedVect, vectForMatch : TMatrix ) : double ;
     function   FitRotationBatchFile( inVect : TSpectraRanges ) : string ;  // minimises difference between factorToFitSpectra and rotated PC ( factNumToFit is input factor to rotate )

  private
     procedure LoadRotationIdentity( inMat : TMatrix )  ; // this load the identity matrix into 'rotationMatrix'
     procedure GetOriginalPCs( inVect : TSpectraRanges ) ;  // extracts PCs  'XYZ_PCs' from input vectors
     function getInitialOrFinalAngle(inStr : string; initialorfinal : integer ) : single ;  // initialorfinal = 1 for initial, 2 for final
     procedure DistributeResults(resMat : TMatrix) ;
     procedure SetUpResultsSpectra( inVect : TSpectraRanges ) ;
end;


implementation


constructor TRotateFactor3D.Create(SDPrec : integer);  // need SDPrec
begin
   bB :=   TBatchBasics.Create ;
   mo :=   TMatrixOps.Create ;
   fitToFactorBool := false ;
//   rotationMatrix := TMatrix.Create2(SDPrec,3,3) ;
//   LoadRotationIdentity ;

   inherited Create ;
end ;


destructor  TRotateFactor3D.Destroy; // override;
begin

  bB.Free ;
  mo.Free ;

  if combinedRotatedXYZ <> nil then combinedRotatedXYZ.Free ;
  if RotatedPC1 <> nil then  RotatedPC1.Free  ;
  if RotatedPC2 <> nil then  RotatedPC2.Free  ;
  if RotatedPC3 <> nil then  RotatedPC3.Free  ;
  if originalVectors <> nil then  originalVectors.Free  ;

  inherited Destroy ;
end ;


procedure TRotateFactor3D.Free;
begin
 if Self <> nil then Destroy;
end;

// loads a 3x3 identy matrix into TRotateFactor3D.rotationMatrix
procedure TRotateFactor3D.LoadRotationIdentity( inMat : TMatrix )  ;
var
  s1, s2 : single ;
begin
  s1 := 1.0 ;
  s2 := 0.0 ;
  inMat.F_Mdata.Seek(0,soFromBeginning) ;
  inMat.F_Mdata.write(s1,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s1,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s2,4) ;
  inMat.F_Mdata.write(s1,4) ;
  inMat.F_Mdata.Seek(0,soFromBeginning) ;
end ;


function  TRotateFactor3D.GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
// if lineNum is -ve then function has failed
// this has to be called externally before
var
   tstr1  : string ;
   tmat : TMatrix ;
   tMemStr : TMemoryStream ;
{File input is of this format:
   'type = Rotate Factors'
   'PCs to rotate = 1-3   // in order: X Y Z'
   'anglePC1 = 0  // = x axis '
   'anglePC2 = 0  // = y axis '
   'anglePC3 = 5  // = z axis. If only 2 PCs then rotate around this axis'
   'range PC1 = 0-0'
   'range PC2 = 0-0'
   'range PC3 = 0-180'
   'fit to factor = false'
   'factor to fit = 1'
    }
begin
          try
             // ********************** PCs to rotate  ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until trim(tstr1) <> ''  ;
             if bB.LeftSideOfEqual(tstr1) = 'pcs to rotate' then
               XYZ_PCs :=  bB.RightSideOfEqual(tstr1) ;
             tMemStr := TMemoryStream.Create ;
             tMat := TMatrix.Create(4)  ;
             numVects := tmat.GetTotalRowsColsFromString(XYZ_PCs,tMemStr) ;
             tMemStr.Free ;
             tMat.Free ;
             if  (numVects < 2) or (numVects > 3) then
             begin
                lineNum :=  lineNum  ;
                result  := inttoStr(lineNum) + ',' ;
                exit ;
             end ;

             // ********************** anglePC1 **************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'anglepc1' then
               angleX :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;  //

              // **************  anglePC2 *************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'anglepc2' then
                 angleY :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;

             // ********************** anglePC3******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'anglepc3' then
                 angleZ :=  strtofloat(bB.RightSideOfEqual(tstr1)) ;

             // ********************** angle range PC1 ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'range pc1' then
                angleRangePC1 := bB.RightSideOfEqual(tstr1) ;

             // ********************** angle range PC2 ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'range pc2' then
               angleRangePC2 := bB.RightSideOfEqual(tstr1) ;;
            // ********************** angle range PC3 ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'range pc3' then
               angleRangePC3 := bB.RightSideOfEqual(tstr1) ;;

            // ********************** Fit to factor ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'fit to factor' then
               if bB.RightSideOfEqual(tstr1)  = 'true' then
                 fitToFactorBool := true
               else
                 fitToFactorBool := false ;
            // ********************** factor to fit ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'factor to fit' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  factorToFit := strtoint(bB.RightSideOfEqual(tstr1)) ;
             // ********************* continue ******************************************
             repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (lineNum>=tStrList.Count)  ;

           except
           begin
             result := inttoStr(lineNum)+', Vector Rotate batch input conversion error' ;
           end ;
           end ;

           result := inttoStr(lineNum) ;
end ;


// has to be called from external code which has access to the source data (sourceSpecRange)
function TRotateFactor3D.GetFactorToFitSpectra( sourceSpecRange : TSpectraRanges ) : boolean ;
var
  t2 : integer ;
// TBatch virtual method
// sourceMatrix is either interleaved (interleavedOrBlocked =1) or block structure (interleavedOrBlocked =2)
  t1 : integer ;
  s1 : single ;
  d1 : double ;
begin
  result := false ;
  try
  // simply copy original eigenvector factor data (do not extract specific row or anything fancy)
  factorToFitSpectra := TSpectraRanges.Create(sourceSpecRange.yCoord.SDPrec div 4, 0,0,nil) ;
  factorToFitSpectra.CopySpectraObject( sourceSpecRange ) ;

  result := true ;
  finally

  end ;
end ;



function  TRotateFactor3D.Return3DRotationMatrix( rotateAboutXYorZ : integer ; angleDegrees : single  ) : TMatrix  ;
var
  cosA, sinA, msinA : single ;
  angleRads : single ;
  retMat : TMatrix ;
begin
  angleRads := (angleDegrees/180) * pi ;

  cosA  := cos(angleRads) ;
  sinA  := sin(angleRads) ;
  msinA := -1 * sinA  ;

  retMat := TMatrix.Create2(originalVectors.SDPrec div 4,3,3) ;

  LoadRotationIdentity(retMat) ;
  if   rotateAboutXYorZ = 1 then   // rotate about x axis
  begin
    retMat.F_Mdata.Seek(16,soFromCurrent) ;
    retMat.F_Mdata.Write(cosA,4) ;
    retMat.F_Mdata.Write(sinA,4) ;
    retMat.F_Mdata.Seek(8,soFromCurrent) ;
    retMat.F_Mdata.Write(msinA,4) ;
    retMat.F_Mdata.Write(cosA,4) ;
  end
  else
  if   rotateAboutXYorZ = 2 then  // rotate about y axis
  begin
    retMat.F_Mdata.Write(cosA,4) ;
    retMat.F_Mdata.Seek(4,soFromCurrent) ;
    retMat.F_Mdata.Write(msinA,4) ;
    retMat.F_Mdata.Seek(12,soFromCurrent) ;
    retMat.F_Mdata.Write(sinA,4) ;
    retMat.F_Mdata.Seek(4,soFromCurrent) ;
    retMat.F_Mdata.Write(cosA,4) ;
  end
  else
  if   rotateAboutXYorZ = 3 then  // rotate about z axis (used if only 2 PCs)
  begin
    retMat.F_Mdata.Write(cosA,4) ;
    retMat.F_Mdata.Write(sinA,4) ;
    retMat.F_Mdata.Seek(4,soFromCurrent) ;
    retMat.F_Mdata.Write(msinA,4) ;
    retMat.F_Mdata.Write(cosA,4) ;
  end ;

  retMat.F_Mdata.Seek(0,soFromBeginning) ;

  result := retMat ;
end ;


procedure TRotateFactor3D.GetOriginalPCs( inVect : TSpectraRanges) ;
// extract the original vectors to be rotated
var
  t1 : integer ;
  s1 : single  ;
  varRange : string ;
begin

   varRange := '1-' + inttostr(inVect.yCoord.numCols) ;
   originalVectors := TMatrix.Create(inVect.yCoord.SDPrec div 4)  ;
   originalVectors.FetchDataFromTMatrix( XYZ_PCs, varRange , inVect.yCoord ) ;
   if numVects = 2 then  // add row of zeros to data
   begin
      originalVectors.numRows := 3 ;
      originalVectors.F_Mdata.SetSize(originalVectors.F_Mdata.Size + (originalVectors.SDPrec * originalVectors.numCols)) ;
      s1 := 0.0 ;
      originalVectors.F_Mdata.Seek(originalVectors.SDPrec * originalVectors.numCols * 2, soFromBeginning ) ;
      for t1 := 1 to originalVectors.numCols do   // fill with zeros
      begin
         originalVectors.F_Mdata.Write(s1,originalVectors.SDPrec) ;
      end ;
   end ;
   originalVectors.F_Mdata.Seek(0, soFromBeginning ) ;
end ;



function TRotateFactor3D.getInitialOrFinalAngle(inStr : string; initialorfinal : integer ) : single ;
// initialorfinal = 1 for initial, 2 for final
// input:  a string of range of angles i.e. '0-90'
// output: floating point value of start (i.e. 0.0) or end (i.e. 90.0) angle value
var
 t1, t2 : integer ;
 bitWanted : string ;
begin
  t1 :=   pos('-',inStr) ;
  if initialorfinal = 1 then
    bitWanted := copy(inStr,1,t1-1)
  else
    bitWanted := copy(inStr,t1+1,length(inStr)) ;

  try
    result := strtofloat(bitWanted) ;
  except on EConvertError do
  begin
     result := 0.0 ;
  end ;
  end ;
end ;




procedure TRotateFactor3D.DistributeResults(resMat : TMatrix)  ;
begin

    combinedRotatedXYZ.yCoord.AddRowsToMatrix(resMat,1,3) ;
    RotatedPC1.yCoord.AddRowsToMatrix(resMat,1,1) ;
    RotatedPC2.yCoord.AddRowsToMatrix(resMat,2,1) ;
    RotatedPC3.yCoord.AddRowsToMatrix(resMat,3,1) ;


end ;

procedure TRotateFactor3D.SetUpResultsSpectra( inVect : TSpectraRanges ) ;
begin
    RotatedPC1         := TSpectraRanges.Create(originalVectors.SDPrec div 4,0,0, nil) ;
    RotatedPC2         := TSpectraRanges.Create(originalVectors.SDPrec div 4,0,0, nil) ;
    RotatedPC3         := TSpectraRanges.Create(originalVectors.SDPrec div 4,0,0, nil) ;
    combinedRotatedXYZ := TSpectraRanges.Create(originalVectors.SDPrec div 4,0,0, nil) ;   // in interleaved order (12312323 etc.)
    RotatedPC1.CopySpectraObject(inVect) ;
    RotatedPC2.CopySpectraObject(inVect) ;
    RotatedPC3.CopySpectraObject(inVect) ;
    combinedRotatedXYZ.CopySpectraObject(inVect) ;
    RotatedPC1.yCoord.F_Mdata.Clear ;
    RotatedPC1.yCoord.numRows := 0 ;
    RotatedPC2.yCoord.F_Mdata.Clear ;
    RotatedPC2.yCoord.numRows := 0 ;
    RotatedPC3.yCoord.F_Mdata.Clear ;
    RotatedPC3.yCoord.numRows := 0 ;
    combinedRotatedXYZ.yCoord.F_Mdata.Clear ;
    combinedRotatedXYZ.yCoord.numRows := 0 ;
end ;


function  TRotateFactor3D.SurveyRotationBatchFile( inVect : TSpectraRanges ) : string ;
// inVect is array of vectors (3 of which are) to be rotated
// return value is an error message or blank string if no error.
var
  tX, tY, tZ : integer ;
  s1 : single ;
  d1 : double ;
  initialX, finalX : single ;
  initialY, finalY : single ;
  initialZ, finalZ : single ;
  currentX, currentY, currentZ : single ;
  numStepsX,numStepsY,numStepsZ : integer ;
  RotMatX, RotMatY, RotMatZ, tMat1, tMat2, resultMat : TMatrix ;

begin
  try
  try
    result := '' ;
    GetOriginalPCs( inVect ) ;

    initialX := getInitialOrFinalAngle(angleRangePC1,1) ;
    finalX := getInitialOrFinalAngle(angleRangePC1,2) ;
    initialY := getInitialOrFinalAngle(angleRangePC2,1) ;
    finalY := getInitialOrFinalAngle(angleRangePC2,2) ;
    initialZ := getInitialOrFinalAngle(angleRangePC3,1) ;
    finalZ := getInitialOrFinalAngle(angleRangePC3,2) ;

    if angleX <> 0.0 then numStepsX := round((finalX-initialX) / angleX ) else  numStepsX := 0 ;
    if angleY <> 0.0 then numStepsY := round((finalY-initialY) / angleY ) else  numStepsY:= 0 ;
    if angleZ <> 0.0 then numStepsZ := round((finalZ-initialZ) / angleZ ) else  numStepsZ := 0 ;

    RotMatX := TMatrix.Create2(originalVectors.SDPrec div 4, 3, 3) ;
    RotMatY := TMatrix.Create2(originalVectors.SDPrec div 4, 3, 3) ;
    RotMatZ := TMatrix.Create2(originalVectors.SDPrec div 4, 3, 3) ;

    // these are for the results
    Self.SetUpResultsSpectra( inVect ) ;


    for tX := 0 to numStepsX  do
    begin
       currentX :=  initialX + (angleX * tX)  ;
       RotMatX := Return3DRotationMatrix( 1 , currentX ) ;

       for tY := 0 to numStepsY  do
       begin
           currentY := initialY + (angleY * tY) ;
           RotMatY := Return3DRotationMatrix( 2 , currentY  ) ;

           for tZ := 0 to numStepsZ  do
           begin
              currentZ := initialZ + (angleZ * tZ)  ;
              RotMatZ := Return3DRotationMatrix( 3 , currentZ ) ;

              tMat1 :=   mo.MultiplyMatrixByMatrix(RotMatY,RotMatX,false,false,1.0,false) ;
              tMat2 :=  mo.MultiplyMatrixByMatrix(RotMatZ,tMat1,false,false,1.0,false) ;
              resultMat := mo.MultiplyMatrixByMatrix(originalVectors,tMat2,true,false,1.0,true) ;

              tMat1.Free ;
              tMat2.Free ;
              RotMatZ.Free ;

              DistributeResults(resultMat) ;
              resultMat.Free ;
            end ;
            RotMatY.Free ;
       end ;
       RotMatX.Free ;
    end ;


  finally

  end ;
  except
    result := 'Error in ProcessRotationBatchFile() function'
  end ;

end ;



function  TRotateFactor3D.FitRotationBatchFile( inVect : TSpectraRanges ) : string ;
// minimises difference between factorToFitSpectra and rotated PC ( factNumToFit is input factor to rotate )
// rotates PC 'factNumToFit' to fit the factorToFitSpectra data
var

  tZ : integer ;
  currentAngle : single ;
  RotMatZ,  rotatedVect : TMatrix ;
  SS_1, SS_2, SS_3 : single ;
  S1, S2, x1, x2, dx, SS_i, SS_f      : double ;
  A, B                                : double ;
  Angle_min_i, Angle_min_f, angle_dif : double ;
begin
//    MinimisedPCs := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;
  try
    result := '' ;
    GetOriginalPCs( inVect ) ;

    RotMatZ := TMatrix.Create2(originalVectors.SDPrec div 4, 3, 3) ;

    // these are for the results
    Self.SetUpResultsSpectra( inVect ) ;

    dx := 1 ;
    currentAngle :=  0 ;
    for tZ := 0 to 2  do
    begin
       RotMatZ := Return3DRotationMatrix( 3 , currentAngle ) ;
       rotatedVect := mo.MultiplyMatrixByMatrix(originalVectors,RotMatZ,true,false,1.0,true) ;

       if tZ = 0 then
         SS_1 := SumOfSquaresOfDifferences( rotatedVect, factorToFitSpectra.yCoord)
       else
       if tZ = 1 then
         SS_2 := SumOfSquaresOfDifferences( rotatedVect, factorToFitSpectra.yCoord)
       else
       if tZ = 2 then
         SS_3 := SumOfSquaresOfDifferences( rotatedVect, factorToFitSpectra.yCoord) ;

       RotMatZ.Free ;
       rotatedVect.Free ;
       currentAngle := currentAngle + dx ;
    end ;

    x1 := Angle_min_i + (dx / 2) ;
    x2 := Angle_min_i + ((dx*3) / 2) ;

    S1 := ( SS_2 - SS_1 ) / dx ;
    S2 := ( SS_3 - SS_2 ) / dx  ;

    A := (S1 -S2) / dx;
    B := ((x1*S2)-(x2*S1)) / dx ;

    currentAngle := (-1*B) / A ;


    self.Angle_min :=  currentAngle ;

    RotMatZ := Return3DRotationMatrix( 3 , Self.Angle_min ) ;
    rotatedVect := mo.MultiplyMatrixByMatrix(originalVectors,RotMatZ,true,false,1.0,true) ;

    DistributeResults(rotatedVect) ;

    RotMatZ.Free ;
    rotatedVect.Free ;
  finally
  begin

  end ;
  end ;

end ;


function TRotateFactor3D.SumOfSquaresOfDifferences( rotatedVect, vectForMatch : TMatrix) : double ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  d1, f_SS : double ;
  s1, s2 : single ;
  COPY_rotated : TMatrix ;
begin

try
    // 1/ this calculates the difference between values
    rotatedVect.MultiplyByScalar(-1) ;
    vectForMatch.F_Mdata.Seek(0,soFrombeginning) ;
    rotatedVect.AddVectToMatrixRows(vectForMatch.F_Mdata) ;

    // 2/ this calculates the sum of the squares of the differences
    f_SS := 0.0 ;
    rotatedVect.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to rotatedVect.numCols do
    begin
       rotatedVect.F_Mdata.Read(s1,4) ; // read angle value
       d1 :=  (s1*s1) ;
       f_SS := f_SS + d1 ;
    end ;
    rotatedVect.F_Mdata.Seek(0, soFromBeginning) ;
    vectForMatch.F_Mdata.Seek(0, soFromBeginning) ;

    result :=  f_SS ;

finally

end ;

end ;


end.
