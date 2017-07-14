unit TRotateToFitScoresUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  TBatchBasicFunctions, TSpectraRangeObject, TMatrixObject, TMatrixOperations,
  TBatch, BLASLAPACKfreePas ;

{
   Need original data in X column, Evectors in Y and a section of scores to try to fit in Z column')
   Rotates 2 eigenvectors selected and projects one on original data to obtain scores'
   Rotates EVects so as to minimis fit between the projected scores and the reference scores in the Z column'
}
type
  TRotateToFitScores  = class
  public
     XYZ_PCs                                     : string ;           // these PCs are extracted in the oreder give to become PC1, PC2 and PC3 corresponding to the x,y and z axe

     originalEVectors                            : TMatrix ;          // these are used for each rotation - it is always a 3 row matrix (if only 2 evects wanted, 3rd is filled with zeros)
     numVects                                    : integer ;          // can be 2 or 3

     initialAngle                                : double  ;          // minimisation procedure requires an initial angle for rotation
     stepAngle                                   : double  ;          // minimisation procedure requires an angle to step from

     scoreRange                                  : string ;           // data points to use for fit
     scoreRefRange                               : string ;           // Reference data (Y column) data points to use for fit
     PCnumOfScoreToFit                           : integer ;          // this is the PC that we are going to match to scoresToFitSpectra

     AllXData                                    : TSpectraRanges ;   // X column data - holds copy of original data
     ResidualXData                               : TSpectraRanges ;   // initally is a copy of AllXData then rotated/projected data is removed
     scoresToFitSpectra                          : TSpectraRanges ;   // Y column data - holds copy of to original data
     scoresNew                                   : TSpectraRanges ;   // Holds new scores from projection of rotated eigenvector
     origEVectSpectra                            : TSpectraRanges ;  // Used for display of original EVectors in string list
     rotatedVectSpectra                          : TSpectraRanges ;

     scoresWanted                                : TMemoryStream  ;   // call GetTotalRowsColsFromString() to fill this Stream with the postion of scores of interest in fit of new scores
     scoresRefWanted                             : TMemoryStream  ;

     Angle_min                                   : single ;           // this is the angle of best match to 'scoresToFitSpectra'

     bB :   TBatchBasics ;
     mo :   TMatrixOps ;

     constructor Create(SDPrec : integer) ;
     destructor  Destroy; // override;
     procedure   Free ;

     // get input data from memo1 text. Returns final line number of String list
     // if lineNum is -ve then function has failed
     // has to be called externally
     function   GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ;
     // has to be called externally which has access to the source data (sourceSpecRange) - usually the 3rd & 4th column (X and Y columns)
     function   GetAllDataSpectra( origXData, eVectors, refScoresData : TSpectraRanges ) : boolean ;

     function   Return3DRotationMatrix( rotateAboutXYorZ : integer ; angleDegrees : single  ) : TMatrix ;  // rotateAboutXYorZ = 1 for x, 2 for y, 3 for z

      // minimises difference between scoresToFitSpectra and rotated PC ( factNumToFit is input factor to rotate )
     function   FitRotationScoresBatchFile : string ;
     // used by FitRotationScoresBatchFile() to find best match betwen rotation derived scores and comparison function
     function   FunctionToMinimise( rotatedScores, scoresForMatch : TMatrix ) : double ;

  private
     procedure LoadRotationIdentity( inMat : TMatrix )  ;   // this load the identity matrix into 'rotationMatrix'
     procedure GetOriginalPCs( inVect : TSpectraRanges ) ;  // extracts PCs  'XYZ_PCs' from input vectors
end;


implementation


constructor TRotateToFitScores.Create(SDPrec : integer);  // need SDPrec
begin
   bB :=   TBatchBasics.Create ;
   mo :=   TMatrixOps.Create ;
   scoresWanted := TMemoryStream.Create ;
   scoresRefWanted := TMemoryStream.Create ;
//   rotationMatrix := TMatrix.Create2(SDPrec,3,3) ;
//   LoadRotationIdentity ;

   inherited Create ;
end ;


destructor  TRotateToFitScores.Destroy; // override;
begin

  bB.Free ;
  mo.Free ;

  scoresRefWanted.Free ;
  scoresWanted.Free ;

  if originalEVectors <> nil then  originalEVectors.Free  ;

  if AllXData <> nil then  AllXData.Free  ;
  if ResidualXData <> nil then  ResidualXData.Free  ;
  if scoresToFitSpectra <> nil then  scoresToFitSpectra.Free  ;
  if scoresNew <> nil then  scoresNew.Free  ;
  if origEVectSpectra <> nil then  origEVectSpectra.Free  ;
  if rotatedVectSpectra <> nil then rotatedVectSpectra.Free ;

  inherited Destroy ;
end ;


procedure TRotateToFitScores.Free;
begin
 if Self <> nil then Destroy;
end;

// loads a 3x3 identy matrix into TRotateFactor3D.rotationMatrix
procedure TRotateToFitScores.LoadRotationIdentity( inMat : TMatrix )  ;
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


function  TRotateToFitScores.GetBatchArguments(lineNum, iter : integer; tStrList : TStringList ) : string ; // get input data from memo1 text. Returns final line number of String list
// if lineNum is -ve then function has failed
// this has to be called externally before
var
   tstr1  : string ;
   tmat : TMatrix ;
   tMemStr : TMemoryStream ;
{File input is of this format:
     'Need original Evector data in X column, Evectors in Y and a section of scores to try to fit in Z column'
     'Rotates 2 eigenvectors selected and projects one on original data to obtain scores'
     'Rotates EVects so as to minimis fit between the projected scores and the reference scores in the Y column'
     'type = Rotate Factors To Fit Scores') ;
     'PCs to rotate = 1,2') ;   // in order: X Y Z'
     'initial angle = 0.0') ;
     'angle step = 0.5') ;
     'Score to fit = 1        // rotate PC1 to fit vector in Y column - Probably has to be 1 anyway'
     'Score range to fit = 1-  // select specific scores') ;   // in order: X Y Z'
     'Score reference range to fit = 1-  // Y column data to select') ;   // in order: X Y Z'

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
             if  (numVects <> 2) and (numVects <> 3)   then
             begin
                lineNum :=  lineNum -1  ;
                result  := inttoStr(lineNum) + ',' ;
                exit ;
             end ;

            // ********************** initial angle ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'initial angle' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  initialAngle := strtofloat(bB.RightSideOfEqual(tstr1)) ;

            // ********************** angle step ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'angle step' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  stepAngle := strtofloat(bB.RightSideOfEqual(tstr1)) ;

            // ********************** Score to fit (which PC is needed for rotation) ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'score to fit' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  PCnumOfScoreToFit := strtoint(bB.RightSideOfEqual(tstr1)) ;
            // ********************** scoreRange ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'score range to fit' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  scoreRange := bB.RightSideOfEqual(tstr1) ;  // string of form '1-...'
           // ********************** scoreRefRange ******************************************
            repeat
               inc(lineNum) ;
               tstr1 := bB.GetStringFromStrList(tStrList, lineNum) ;
             until (trim(tstr1) <> '') or (linenum > tStrList.Count)  ;
             if bB.LeftSideOfEqual(tstr1) = 'score reference range to fit' then
               if bB.RightSideOfEqual(tstr1)  <> '' then
                  scoreRefRange := bB.RightSideOfEqual(tstr1) ;  // string of form '1-...' from Y column of stringgrid data


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
function TRotateToFitScores.GetAllDataSpectra( origXData, eVectors, refScoresData : TSpectraRanges ) : boolean ;
begin
  result := false ;
  try
    AllXData := TSpectraRanges.Create(origXData.yCoord.SDPrec div 4, 0,0,nil) ;
    AllXData.CopySpectraObject( origXData ) ;

    GetOriginalPCs( eVectors ) ; // this obtains the 3 rows wanted into a TMatrix
    origEVectSpectra := TSpectraRanges.Create(refScoresData.yCoord.SDPrec div 4, 3, originalEVectors.numCols,nil) ;
    origEVectSpectra.yCoord.ClearData(origEVectSpectra.yCoord.SDPrec div 4) ;
    origEVectSpectra.yCoord.CopyMatrix(originalEVectors) ;  // this copys TMatix into a TspectraRanges object for display
    origEVectSpectra.xCoord.ClearData(origEVectSpectra.yCoord.SDPrec div 4) ;
    origEVectSpectra.xCoord.CopyMatrix(eVectors.xCoord ) ;

    scoresToFitSpectra := TSpectraRanges.Create(refScoresData.yCoord.SDPrec div 4, 0,0,nil) ;
    scoresToFitSpectra.CopySpectraObject( refScoresData ) ;

    // copy original X data to create residuals from later
    ResidualXData := TSpectraRanges.Create(origXData.yCoord.SDPrec div 4, 0,0,nil) ;
    ResidualXData.CopySpectraObject( origXData ) ;

    result := true ;
  finally

  end ;
end ;




function  TRotateToFitScores.Return3DRotationMatrix( rotateAboutXYorZ : integer ; angleDegrees : single  ) : TMatrix  ;
var
  cosA, sinA, msinA : single ;
  angleRads : single ;
  retMat : TMatrix ;
begin
  angleRads := (angleDegrees/180) * pi ;

  cosA  := cos(angleRads) ;
  sinA  := sin(angleRads) ;
  msinA := -1 * sinA  ;

  retMat := TMatrix.Create2(originalEVectors.SDPrec div 4,3,3) ;

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


procedure TRotateToFitScores.GetOriginalPCs( inVect : TSpectraRanges) ;
// extract the original vectors to be rotated
var
  t1 : integer ;
  s1 : single  ;
  varRange : string ;
begin

   varRange := '1-' + inttostr(inVect.yCoord.numCols) ;
   originalEVectors := TMatrix.Create(inVect.yCoord.SDPrec div 4)  ;
   originalEVectors.FetchDataFromTMatrix( XYZ_PCs, varRange , inVect.yCoord ) ;
   if numVects = 2 then  // add row of zeros to data
   begin
      originalEVectors.numRows := 3 ;
      originalEVectors.F_Mdata.SetSize(originalEVectors.F_Mdata.Size + (originalEVectors.SDPrec * originalEVectors.numCols)) ;
      s1 := 0.0 ;
      originalEVectors.F_Mdata.Seek(originalEVectors.SDPrec * originalEVectors.numCols * 2, soFromBeginning ) ;
      for t1 := 1 to originalEVectors.numCols do   // fill with zeros
      begin
         originalEVectors.F_Mdata.Write(s1,originalEVectors.SDPrec) ;
      end ;
   end ;
   originalEVectors.F_Mdata.Seek(0, soFromBeginning ) ;
end ;



function  TRotateToFitScores.FitRotationScoresBatchFile : string ;
// minimises difference between factorToFitSpectra and rotated PC ( factNumToFit is input factor to rotate )
// rotates PC 'factNumToFit' to fit the factorToFitSpectra data
var

  tZ, t1, t2 : integer ;
  currentAngle          : single ;
  RotMatZ,  rotatedVect, tScores : TMatrix ;
  SS_1, SS_2, SS_3 : single ;
  S1, S2, x1, x2, dx, SS_i, SS_f      : double ;
  A, B                                : double ;
  Angle_min_i, Angle_min_f, angle_dif : double ;

  MKLbetas : single ;
  MKLEVects, MKLscores, MKLdata : pointer ;
  MKLtint, MKLlda : integer ;

begin
//    MinimisedPCs := TSpectraRanges.Create(xData.yCoord.SDPrec div 4, xData.yCoord.numRows, xData.yCoord.numCols, @xData.LineColor) ;
  try
    result := '' ;

    RotMatZ := TMatrix.Create2(originalEVectors.SDPrec div 4, 3, 3) ;

    t1 := RotMatZ.GetTotalRowsColsFromString( scoreRange,    scoresWanted ) ;
    t2 := RotMatZ.GetTotalRowsColsFromString( scoreRefRange, scoresRefWanted ) ;

    if t1 <> t2 then
    begin
      result := 'Input Error. Points in: Score range to fit <> Score reference range' ;
      exit ;
    end ;

    dx := self.stepAngle ;
    currentAngle :=  self.initialAngle ;
    for tZ := 0 to 2  do
    begin
       // 1/ Rotate the eigenvecors
       RotMatZ := Return3DRotationMatrix( 3 , currentAngle ) ;
       rotatedVect := mo.MultiplyMatrixByMatrix(originalEVectors,RotMatZ,true,false,1.0,true) ;

       // 2/ Project rotated vector on original data to get scores
       // create scores by projection of EVects onto original data
       tScores := mo.MultiplyMatrixByMatrix(AllXData.yCoord,rotatedVect,false,true,1.0,true) ;
 //      tScores.Transpose ;

       // 3/ Determine points on function to minimise
       if tZ = 0 then
         SS_1 := FunctionToMinimise( tScores , scoresToFitSpectra.yCoord)
       else
       if tZ = 1 then
         SS_2 := FunctionToMinimise( tScores , scoresToFitSpectra.yCoord)
       else
       if tZ = 2 then
         SS_3 := FunctionToMinimise( tScores , scoresToFitSpectra.yCoord) ;

 //      tScores.SaveSpectraDelimExcel('rotatedVectorsExcel.txt',',') ;

       RotMatZ.Free ;
       tScores.Free ;
       rotatedVect.Free ;
       currentAngle := currentAngle + dx ;
    end ;

    // 4/ calculate angle to rotate to get a minimum in the function
    x1 := Angle_min_i + (dx / 2) ;
    x2 := Angle_min_i + ((dx*3) / 2) ;

    S1 := ( SS_2 - SS_1 ) / dx ;
    S2 := ( SS_3 - SS_2 ) / dx  ;

    A := (S1 -S2) / dx;
    B := ((x1*S2)-(x2*S1)) / dx ;

    currentAngle := (-1*B) / A ;
    self.Angle_min :=  currentAngle ;

    // 5/ rotate evectors by desired angle that was calculated in 3 & 4
    RotMatZ := Return3DRotationMatrix( 3 , Self.Angle_min ) ;
    rotatedVect := mo.MultiplyMatrixByMatrix(originalEVectors,RotMatZ,true,false,1.0,true) ;
 //   rotatedVect.SaveMatrixDataTxt('rotatedVectors.txt',',') ;
    // create display object for rotated eigenvectors
    rotatedVectSpectra := TSpectraRanges.Create(originalEVectors.SDPrec div 4, 3, originalEVectors.numCols,nil) ;
    rotatedVectSpectra.yCoord.ClearData(originalEVectors.SDPrec div 4) ;
    rotatedVectSpectra.yCoord.CopyMatrix(rotatedVect) ;  // this copys the TMatrix into a TspectraRanges object for display
    rotatedVectSpectra.xCoord.ClearData(originalEVectors.SDPrec div 4) ;
    rotatedVectSpectra.xCoord.CopyMatrix(origEVectSpectra.xCoord) ;

 //   rotatedVectSpectra.SaveSpectraDelimExcel('rotatedVectorsExcel.txt',',') ;

    // 6/ project rotated evects onto data to create scores matrix
    scoresNew := TSpectraRanges.Create(AllXData.yCoord.SDPrec div 4, 1, AllXData.yCoord.numRows, nil) ;
    scoresNew.yCoord.Free ;
    scoresNew.yCoord := mo.MultiplyMatrixByMatrix(AllXData.yCoord,rotatedVect,false,true,1.0,true) ;
  //  scoresNew.yCoord.Transpose ;

    //  7/ use BLAS level 2 routine - subtract reconstructed data from original data
    MKLEVects   := rotatedVect.F_Mdata.Memory ;
    MKLscores   := scoresNew.yCoord.F_Mdata.Memory ;
    MKLdata     := ResidualXData.yCoord.F_Mdata.Memory ;
    MKLlda      := ResidualXData.yCoord.numCols  ;
    MKLtint     :=  1 ;
    MKLbetas    := -1.0 ;
    sger (ResidualXData.yCoord.numCols , ResidualXData.yCoord.numRows, MKLbetas, MKLEVects, MKLtint, MKLscores , MKLtint, MKLdata, MKLlda) ;

    // 7/ save the scores and the residuals for further analysis
    scoresNew.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 1 to scoresNew.xCoord.numCols do
    begin
       SS_1 := t1 ;
       scoresNew.xCoord.F_Mdata.Write(SS_1, scoresNew.xCoord.SDPrec) ;
    end ;

  finally
  begin
     RotMatZ.Free ;
     rotatedVect.Free ;
  end ;
  end ;

end ;




function TRotateToFitScores.FunctionToMinimise( rotatedScores, scoresForMatch : TMatrix) : double ;
var     // param is the paramter number to step in value (reference into paramsStr memory stream)
  t1 : integer ;
  t2 : integer ;
  d1, f_SS : double ;
  s1, s2 : single ;
  difMatrix : TMatrix ;
begin

try
    // 1/ select, subtract and copy desired values into a new TMemoryStream
    difMatrix := TMatrix.Create2(rotatedScores.SDPrec div 4,1,scoresWanted.Size div 4 ) ;
    scoresWanted.Seek(0,soFromBeginning) ;
    scoresRefWanted.Seek(0,soFromBeginning) ;
    for t1 := 1 to  scoresWanted.Size div 4 do
    begin
       scoresWanted.Read(t2,4) ;
       rotatedScores.F_Mdata.Seek(t2*rotatedScores.SDPrec, soFromBeginning) ;
       rotatedScores.F_Mdata.Read(s1,rotatedScores.SDPrec) ;

       scoresRefWanted.Read(t2,4) ;
       scoresForMatch.F_Mdata.Seek(t2*scoresForMatch.SDPrec, soFromBeginning) ;
       scoresForMatch.F_Mdata.Read(s2,scoresForMatch.SDPrec) ;

       s1 := s1 - s2 ;

       difMatrix.F_Mdata.Write(s1, scoresForMatch.SDPrec) ;
    end ;

    // 2/ this calculates the sum of the squares of the differences
    f_SS := 0.0 ;
    difMatrix.F_Mdata.Seek(0, soFromBeginning) ;
    for t1 := 1 to difMatrix.numCols do
    begin
       difMatrix.F_Mdata.Read(s1,4) ; // read angle value
       d1 :=  (s1*s1) ;
       f_SS := f_SS + d1 ;
    end ;
    rotatedScores.F_Mdata.Seek(0, soFromBeginning) ;
    scoresForMatch.F_Mdata.Seek(0, soFromBeginning) ;

    result :=  f_SS ;

finally
    difMatrix.Free ;
end ;

end ;


end.

