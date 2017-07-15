unit TMatrix;

interface

uses  classes, Dialogs, SysUtils  ;

type
  TMatrix_  = class(TObject)
  public
    numRows : integer ; // the number of Y data values... Used for .MAP files
    numCols : integer ;
    SDPrec : integer ;   // single or double precision data storage
    meanCentred, colCentred : boolean ;
    Filename : String ;
    F_Mdata : TMemoryStream ;

    constructor Create(singleOrDouble : integer) ;
    destructor Destroy; override; // found in implementation part below

    property Mdata: TMemoryStream read F_Mdata write F_Mdata ;

    procedure TransposeX ;
    procedure SaveMatrixData(filenameOut : string) ;
    procedure MeanCentre(aveMatrix : TMatrix_) ;
    function LoadMatrixDataForPCanalysis(filenameIn : string ;startLine : integer) :  boolean  ;
  private
  end;

implementation


constructor TMatrix_.Create(singleOrDouble : integer);
begin
  inherited Create;

  SDPrec := singleOrDouble ;

  F_Mdata := TMemoryStream.Create;

  meanCentred := false ;
  colCentred  := false ;
  numRows := 0;
  numCols := 0;
end;


destructor TMatrix_.Destroy;
begin
  F_Mdata.free ;

  inherited Destroy;
end;


procedure TMatrix_.MeanCentre(aveMatrix : TMatrix_) ;
var
   t1, t2 : integer ;
   s1, s2 : single ;
   d1, d2 : double ;
     // ponter to the stream that stores the average values
begin
    F_Mdata.Seek(0,soFromBeginning) ;
    meanCentred := true ;

    aveMatrix.F_Mdata.SetSize(SDPrec * 4 * numCols) ;

    for t1 := 0 to numRows-1 do
    begin
         for t2 := 0 to numCols-1 do
         begin
           

         end ;
    end ;

end ;


procedure TMatrix_.TransposeX() ;
Var
   transM : TMemoryStream ;

   tempList: TStrings ;
   tstr1 : string ;

   initialCols, initialRows, t1, t2 : integer ;
   td1 : double ;
   ts1 : single ;
begin
   transM :=  TMemoryStream.Create ;
   transM.SetSize(F_Mdata.Size) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.Seek(0,soFromBeginning) ;

   initialCols := numCols ;
   initialRows := numRows ;
   // swap column/row dimensions
   numRows := numCols ;
   numCols := initialRows ;

   if SDPrec = 1 then
   begin
     for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1*4,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(ts1,4) ;
          transM.Write(ts1,4) ;
          transM.Seek((initialRows-1)*4,soFromCurrent) ;
       end ;
     end ;
   end
   else
   begin   // double precision code
     for t1 := 0 to initialRows -1 do
     begin
       transM.Seek(t1*8,soFromBeginning) ;
       for t2 := 0 to  initialCols -1 do
       begin
          F_Mdata.Read(td1,8) ;
          transM.Write(td1,8) ;
          transM.Seek((initialRows-1)*8,soFromCurrent) ;
       end ;
     end ;
   end ;

   F_Mdata.Seek(0,soFromBeginning) ;
   transM.Seek(0,soFromBeginning) ;
   F_Mdata.CopyFrom(transM,transM.size) ;  // copy transposed data into original data stream

   transM.Free ;
end ;



// save to file for viewing
procedure TMatrix_.SaveMatrixData(filenameOut : string) ;
Var
   tempList: TStringList ;
   tstr1 : string ;
   t1, t2 : integer ;
   td1 : double ;
   ts1 : single ;
begin
   F_Mdata.Seek(0,soFromBeginning) ;
   tempList :=  TStringList.Create ;
   tempList.Capacity :=  numRows ;
   for t1 := 0 to numRows -1 do
   begin
     tstr1 := '' ;
     for t2 := 0 to  numCols -1 do
     begin
       F_Mdata.Read(ts1,4);
       tstr1 := tstr1 + floattoStrf(ts1,ffGeneral,5,4) + #9 ;
     end ;
     tempList.Append(tstr1) ;
   end ;
   tempList.SaveToFile(filenameOut) ;
   tempList.Free ;
end ;


// Loads data into
function TMatrix_.LoadMatrixDataForPCanalysis(filenameIn : string ;startLine : integer) :  boolean ;
var
  TempList: TStrings ;
  tStr1, tStr2, delimeter : String ;
  t1, t2, line, col : integer ;
  td1 : double ;
  ts1 : single ;

  xinc : single ;

begin
  TempList := TStringList.Create ;
  delimeter := '' ;

  Try
  With TempList Do
  begin
    LoadFromFile(filenameIn) ;  // load text data file into string list
    self.filename := filenameIn ;
    if TempList.capacity = 0 then
    begin
      messagedlg('File is empty!' ,mtinformation,[mbOK],0) ;
      result := false ;
      exit ;
    end ;
    tStr1 := TempList.Strings[startLine-1] ;
    tStr1 := trim(tStr1) ;

    t1 := pos(',',tStr1) ;  // start choosing delimeter
    if t1 > 0 then
       delimeter :=   ','    // comma
    else
    begin
         t1 := pos(#32,tStr1)  ;
         if t1 > 0  then delimeter :=  #32    // space
         else
         begin
           t1 := pos(#9,tStr1)  ;
           if t1 > 0 then delimeter :=   #9     // tab
           else
           begin
              messagedlg('Delimeter is not comma, space or tab' ,mtinformation,[mbOK],0) ;
              result := false ;
              exit ;
           end ;
          end ;
    end ;   // end choosing delimeter

    numRows :=  (TempList.Count+1) - startLine ;

    inc(numCols) ;
    tStr2 := tStr1 ;
    while t1 > 0 do
    begin
       t2 := length(tStr2) ;
       tStr2 := copy(tStr2,t1,t2) ;
       tStr2 := trim(tStr2) ;
       t1 := pos(delimeter,tStr2) ;
       inc(numCols) ;
    end ;

    F_Mdata.SetSize(numRows*numCols*SDPrec*4) ;
    for line := 0 to numRows-1 do
    begin
      tStr1 := TempList.Strings[line+startLine-1] ;
      for col := 0 to numCols-1 do
      begin
          tStr1 := trim(tStr1) ;
          t1 := pos(delimeter,tStr1) ;
          t2 := length(tStr1) ;
          if col < numCols-1 then
            tStr2 := copy(tStr1,1,t1-1)
          else
            tStr2 := tStr1 ;
          tStr1 := copy(tStr1,t1,t2) ;
          if SDPrec = 1 then
          begin
            ts1 := strtofloat(tStr2) ;
            F_Mdata.Write(ts1,4) ;
          end
          else
          begin
            td1 := strtofloat(tStr2) ;
            F_Mdata.Write(td1,8) ;
          end ;
      end ;
    end ;
//    transpose(F_allData) ;
    
    //  messagedlg('numCols ='+inttostr(numCols) ,mtinformation,[mbOK],0) ;
  end
  finally
     TempList.Free ;
  end ;
end ;









end.
 