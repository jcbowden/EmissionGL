unit StringGridDataViewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Grids, StdCtrls, ExtCtrls, Clipbrd ;

type
  TSGDataView = class(TForm)
    SG2: TStringGrid;
    Panel1: TPanel;
    ColStrText: TEdit;
    RowStrText: TEdit;
    Label1: TLabel;
    Label2: TLabel;

    procedure SG2KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure SG2KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    
    procedure SG2DrawCell(Sender: TObject; Colx, Rowx: Integer; Rect: TRect;
      State: TGridDrawState );

    procedure SG2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormCreate(Sender: TObject);
    
    function GetTotalRowsColsFromString(range :string; rowcolList : TMemoryStream; inSet : integer) : boolean ;
    function CreateStringFromTMemStream(rowcolList : TMemoryStream) : string ; // does oppisite of GetTotalRowsColsFromString() - i.e. from MemStream of integers, create range i.e. "3,6-12,30"
  
    procedure RemoveRangeFromTMemStream(range :string; rowcolList : TMemoryStream) ;// range is a string e.g. '1-3,4,8-10' whose values are to be removed from rowcolList; rowcolList is a list of integers;
    procedure AddRangeToTMemStream(range :string; rowcolList : TMemoryStream) ;  // adds a range of numbers to another range of numbers - results in new range being available in rowcolList TMemoryStream

      procedure SortTMemStream(inStream : TMemoryStream) ;
    procedure RemoveDoublesFromTMemStream(rowcolList : TMemoryStream) ;
    procedure RemoveBothDoublesFromTMemStream(rowcolList : TMemoryStream) ;  // used by RemoveRangeFromTMemStream()
    // sets boolean values to true if the row or column is selected - used for display of 'lue' selected cells in  SG2MouseDown()
    procedure FlagSelectedRowCols(rowcolList: TMemoryStream; flagsRowCol : TMemoryStream)  ;
    procedure SetAllFlagsRowCols(setTrueFalse : boolean; flagsRowCol : TMemoryStream) ;

    procedure FormActivate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    // flags for what col or row are selected
    flagsRow : TMemoryStream ;
    flagsCol : TMemoryStream ;
    ownersRow, ownersCol : integer ;
    { Public declarations }
  end;

var
  SGDataView: TSGDataView;
  keyDownV : integer ;  // 0 = no key down, 1 = Ctrl, 2 = Shift, 3 = Ctrl and Shift... used for selecting multiple file from SG2
  sROW, sCOL : integer ; // currently selected row and column
  lastCOL, lastROW : integer ;  // used for multiple selections in string grid SG2

implementation

{$R *.DFM}
uses  FileInfo {= TForm4}, emissionGL  {= TForm1}, TSpectraRangeObject,
  ColorsEM ;


procedure TSGDataView.FormCreate(Sender: TObject);
begin
  lastROW :=  -1 ;
  lastCOL :=  -1 ;
  flagsRow :=  TMemoryStream.Create ;
  flagsCol :=  TMemoryStream.Create ;
end;

procedure TSGDataView.FormDestroy(Sender: TObject);
begin
  flagsRow.Free ;
  flagsCol.Free ;

end;


procedure TSGDataView.SG2KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  tR : TRect;
begin
  if (ssCtrl in Shift) and not ((ssAlt in Shift) or (ssShift in Shift)) then  // only Ctrl is down
    keyDownV := 1   // Ctrl is down
  else
  if (ssShift in Shift) and not ((ssAlt in Shift) or (ssCtrl in Shift)) then  // only Shift is down
    keyDownV := 2   // Shift is down
  else
  if ((ssCtrl in Shift) and  (ssShift in Shift)) and not (ssAlt in Shift) then  // Ctrl and Shift are down
    keyDownV := 3   // Ctrl and Shift are down
  else
    keyDownV := 0 ;

 // messagedlg('key is:'+ inttostr(Key) ,mtInformation,[mbOK],0) ;

 if keyDownV = 0 then
 begin
   if key = 38 then // up key pressed
   begin
//      Form4.StatusBar1.Panels[0].Text := Form4.StatusBar1.Panels[0].Text + inttostr(key) ;
//      sROW := sROW + 1 ;
      if sROW > 2 then begin
        tR := SG2.CellRect(1, sROW );
        SG2MouseDown(Sender, mbLeft, Shift, tR.Left, tR.top-6 );
      end ;
   end
   else
   if key = 40 then // down key is pressed
   begin
     if sROW < SG2.Row then
     begin
      tR := SG2.CellRect(1, sROW );
      SG2MouseDown(Sender, mbLeft, Shift, tR.Left, tR.bottom+6 );
     end ;
   end ;
 end ;

 // messagedlg(inttostr(Key) ,mtInformation,[mbOK],0) ;
end;

procedure TSGDataView.SG2KeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and not ((ssAlt in Shift) or (ssShift in Shift)) then  // only Ctrl is down
    keyDownV := 1   // Ctrl is down
  else
  if (ssShift in Shift) and not ((ssAlt in Shift) or (ssCtrl in Shift)) then  // only Shift is down
    keyDownV := 2   // Shift is down
  else
  if ((ssCtrl in Shift) and  (ssShift in Shift)) and not (ssAlt in Shift) then  // only Ctrl is down
    keyDownV := 3   // Ctrl and Shift are down
  else
    keyDownV := 0 ;
end;




// From a string range (eg '3-7,9-24') get total number of rows and place the row numbers
// in a (zero based) vector (MemoryStream) also returns if a nominated number is in the set of numbers
// TMemoryStream has to be created
function TSGDataView.GetTotalRowsColsFromString(range :string; rowcolList : TMemoryStream; inSet : integer) : boolean ;
var
  tstr : string ;
  lowInt, highInt, t1 : integer ;
  pos_dash, pos_comma : integer ;
begin
  range := trim(range) ;
  pos_dash := pos('-',range) ;
  pos_comma := pos(',',range) ;
  rowcolList.Clear ;
  result := false ;
  inSet := inSet ;

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
       for t1 := lowInt to highInt do
       begin
         rowcolList.SetSize(rowcolList.Size+4) ;
         rowcolList.Write(t1,4) ;
         if t1 = inSet then result := true ;
       end ;
    end
    else
    begin
       tstr := copy(range, 1, pos_comma-1) ;
       highInt := strtoint(tstr) ;
       range := copy(range,pos_comma+1,length(range)-pos_comma) ;
       rowcolList.SetSize(rowcolList.Size+4) ;
       highInt:= highInt ;
       rowcolList.Write(highInt,4) ;
       if highInt = inSet then result := true ;
    end ;
    range := trim(range) ;
    pos_dash := pos('-',range) ;
    pos_comma := pos(',',range) ;
    if (pos_dash = 0) and (pos_comma = 0) and (Length(range) <> 0) then
    begin
       highInt := strtoint(range) ;
       range := '' ;
       rowcolList.SetSize(rowcolList.Size+4) ;
       highInt:= highInt ;
       rowcolList.Write(highInt,4) ;
       if highInt = inSet then result := true ;
    end ;

   until  (pos_dash = 0) and (pos_comma = 0)  ;

   SortTMemStream( rowcolList ) ;
   RemoveDoublesFromTMemStream( rowcolList ) ;

end ;



function GetLastNumber(inStr : string; var iStr : string) : integer ;
var
  tStr : string ;
  t1 : integer ;
  dash, comma, empty : string ;
begin
  tStr :=  inStr ;
  t1 := 0 ;

  //*********** check this code here !!! 2-3 and add 4 does not work!
  dash := copy(tStr,length(tStr),1) ;
  comma := copy(tStr,length(tStr),1) ;
  empty  := copy(tStr,length(tStr),1) ;

  repeat
    tStr := copy(tStr,1,length(tStr)-1) ;    //remove last digit
    inc(t1) ;
    dash := copy(tStr,length(tStr),1) ;
    comma := copy(tStr,length(tStr),1) ;
    empty  := copy(tStr,length(tStr),1) ;
  until (dash = '-') or (comma = ',') or (empty = '') ;


  iStr := copy(tStr,length(tStr),1) ; // this returns '-' or ',' or ''

  t1 :=  strtoint( copy(inStr,length(inStr)-t1+1,t1)) ; // this is the last full number

  result :=  t1 ;
end ;

function TSGDataView.CreateStringFromTMemStream(rowcolList : TMemoryStream) : string ;
var
  t1 : integer ;
  i1, i2 : integer ;
  resStr : string ;
  iStr : string ;
begin
//  RemoveDoublesFromTMemStream(rowcolList) ;
  resStr := '' ;
  rowcolList.Seek(0,soFromBeginning) ;

  for t1 := 1 to (rowcolList.Size div 4) do
  begin
     rowcolList.Read(i1,4) ;
     if t1 = 1 then
       resStr := inttostr(i1)
     else   // get last digit ( = i1)
     begin
       i2 := GetLastNumber(resStr,iStr) ; // iStr returns from function as ',' or '-' or ''

       if abs(i2 - i1) = 1 then
       begin   // place i2 as dashed
         if iStr = ',' then
           resStr := resStr + '-' + inttostr(i1) ;
         if iStr = '-' then
           resStr := copy(resStr,1,length(resStr)-length(inttostr(i2))) + inttostr(i1) ;
         if iStr = '' then
           resStr := resStr + '-' + inttostr(i1) ;
       end
       else
       begin  // place i2 as single
          resStr := resStr + ',' + inttostr(i1) ;
       end ;
     end ;

  end ;
  result := resStr ;
end ;


function debugPrint(rowcolList: TMemoryStream) : string ;
var
  q1, q2 : integer ;
  sortedStr : string ;
begin

  rowcolList.Seek(0,soFromBeginning) ;
  for q1 := 1 to rowcolList.Size div 4 do
  begin
    rowcolList.Read(q2,4) ;
    sortedStr := sortedStr + inttostr(q2) + ',' ;
  end ;
//  TSGDataView.RowStrText.Text :=  sortedStr ;
  result := sortedStr ;
end ;


// rowcolList is a list of integers;
// range is a string e.g. '1-3,4,8-10' whose values are to be removed from rowcolList
procedure TSGDataView.RemoveRangeFromTMemStream(range :string; rowcolList : TMemoryStream) ;
var
  t1 : integer ;
  tMS : TMemoryStream ;
  i1 : integer ;
  numInRow : integer ;
  initialPos : integer ;
begin

  try
    tMS := TMemoryStream.Create ;
    GetTotalRowsColsFromString(range, tMS , 0 ) ;  // this puts values in range into the tMS memory stream sorted into numerical order

    tMS.Seek(0,soFromBeginning) ;

    // may want to RemoveDoublesFromTMemStream(rowcolList) ; // remove doubled up values
    rowcolList.Seek(0,soFromEnd) ;

    rowcolList.SetSize(rowcolList.size + tMS.size) ; // increase size

    for t1 := 1 to tMS.Size div 4 do  // add new values to end
    begin
      tMS.Read(i1,4) ;
      rowcolList.Write(i1,4) ;
    end ;

    SortTMemStream(rowcolList) ;  // sort

    RemoveBothDoublesFromTMemStream(rowcolList) ; // remove doubled up values
  finally
    tMS.Free ;
  end ;
end ;

// removes doubled up values from an ordered list
procedure TSGDataView.RemoveBothDoublesFromTMemStream(rowcolList : TMemoryStream) ;
var
  t1, t2, t3 : integer ;
  tMS : TMemoryStream ;
  i1, i2 : integer ;
begin
  try
    tMS := TMemoryStream.Create ;
    rowcolList.Seek(0,soFromBeginning) ;
    rowcolList.Read(i1,4) ;

      t1 := 4 ;
      repeat
        rowcolList.Read(i2,4) ;
        inc(t1,4) ;
        if (i1 <> i2) then
        begin
          tMS.SetSize(tMS.Size + 4) ;
          tMS.Write(i1,4) ;
          i1 := i2 ;
        end
        else // they are equal so do not write
        begin
          rowcolList.Read(i1,4) ;
          inc(t1,4) ;
        end ;
      until t1 >= rowcolList.Size   ;

      if rowcolList.Size  > 4 then
      begin
        rowcolList.Seek(-8,soFromEnd) ;
        rowcolList.Read(i1,4) ;
        rowcolList.Read(i2,4) ;
        if (i1 <> i2) then
           tMS.Write(i2,4) ;
      end ;

//    tMS.SetSize(tMS.Size + 4) ;
//    tMS.Write(i1,4) ;
    rowcolList.Clear ;
    if tMS.size > 0 then
      rowcolList.LoadFromStream(tMS)

//    RowStrText.Text := RowStrText.Text +'   rem_p: '+ debugPrint(rowcolList) + '  '  ;
  finally
    tMS.Free ;
  end ;
end ;


procedure TSGDataView.SortTMemStream(inStream : TMemoryStream) ;
var
  t1, t2, t3 : integer ;
  i1, i2 : integer ;
  currPos : integer ;
begin
    inStream.Seek(0,soFromBeginning) ;

    while  inStream.Position < (inStream.Size - 4) do
    begin
       inStream.Read(i1,4) ;
       inStream.Read(i2,4) ;
//       if (i2 < i1) then   // remeber where we are up to
         currPos :=  inStream.Position - 4 ;
       while (i2 < i1) do
       begin

          inStream.Seek(-8,soFromCurrent) ;
          inStream.Write(i2,4) ;
          inStream.Write(i1,4) ;
          i1 := i2 ;
          if inStream.Position >= 12 then
          begin
            inStream.Seek(-12,soFromCurrent) ;
            inStream.Read(i1,4) ;
            inStream.Read(i2,4) ;
          end ;
       end ;
       inStream.Seek(currPos,soFromBeginning) ;
    end ;

end ;

// makes doubled up numbers into single numbers
procedure TSGDataView.RemoveDoublesFromTMemStream(rowcolList : TMemoryStream) ;
var
  t1, t2, t3 : integer ;
  tMS : TMemoryStream ;
  i1, i2 : integer ;
begin
  try
    tMS := TMemoryStream.Create ;
    rowcolList.Seek(0,soFromBeginning) ;
    rowcolList.Read(i1,4) ;

    if rowcolList.Size > 4 then
    begin
      for t1 := 1 to (rowcolList.Size div 4) do
      begin
        rowcolList.Read(i2,4) ;
        if i1 <> i2 then
        begin
          tMS.SetSize(tMS.Size + 4) ;
          tMS.Write(i1,4) ;
        end ;
        i1 := i2 ;
      end ;
    end ;

    tMS.SetSize(tMS.Size + 4) ;
    tMS.Write(i1,4) ;
    rowcolList.Clear ;
    rowcolList.LoadFromStream(tMS) ;

  finally
    tMS.Free ;
  end ;
end ;



// adds a range of numbers to another range of numbers - results in new range being available in rowcolList TMemoryStream
procedure TSGDataView.AddRangeToTMemStream(range :string; rowcolList : TMemoryStream) ;
var
  t1 : integer ;
  tMS : TMemoryStream ;
  i1 : integer ;
begin
  try
    tMS := TMemoryStream.Create ;
    GetTotalRowsColsFromString(range, tMS , 0 ) ;  // this puts values in range into the tMS memory stream sorted into numerical order

    tMS.Seek(0,soFromBeginning) ;
    rowcolList.Seek(0,soFromEnd) ;

    rowcolList.SetSize(rowcolList.size + tMS.size) ; // increase size

    for t1 := 1 to tMS.Size div 4 do  // add new values to end
    begin
      tMS.Read(i1,4) ;
      rowcolList.Write(i1,4) ;
    end ;

    SortTMemStream(rowcolList) ;  // sort

    RemoveDoublesFromTMemStream(rowcolList) ; // remove doubled up values

  finally
    tMS.Free ;
  end ;
end ;


procedure TSGDataView.SetAllFlagsRowCols(setTrueFalse : boolean; flagsRowCol : TMemoryStream)  ;
// flagsRowCol is an array of boolean (bytes) that holds: true : if row/col selected; false: if not selected
var
  t1 : integer ;
begin
  flagsRowCol.Seek(0,soFromBeginning) ;
  for t1 := 1 to flagsRowCol.Size do  // set all to zero (false = not selected)
    flagsRowCol.Write(setTrueFalse,1) ;
end ;


procedure TSGDataView.FlagSelectedRowCols(rowcolList: TMemoryStream; flagsRowCol : TMemoryStream)  ;
// flagsRowCol is an array of boolean (bytes) that holds: true : if row/col selected; false: if not selected
var
  t1, t2 : integer ;
  b1 : boolean ;
begin
  rowcolList.Seek(0,soFromBeginning) ;
  SetAllFlagsRowCols(false, flagsRowCol)  ;

  b1 := true ;
  for t1 := 1 to rowcolList.Size div 4 do
  begin
    rowcolList.Read(t2,4) ;
    dec(t2) ;
    flagsRowCol.Seek(t2,soFromBeginning) ;
    flagsRowCol.Write(b1,1) ;
  end ;

end ;




procedure TSGDataView.SG2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  t1, t2 : integer ;
//  posDash : integer ;
  rowVis, colVis : integer ;
  tGDS : TGridDrawState ;
  tR : TRect ;
  colInput, rowInput: Longint ; // returned by MouseToCell() function
  rowcolList : TMemoryStream ;
  rowStr, colStr : String ;
//  rowBool, colBool : boolean ;
//  sortedStr : string ;  // for debug
  b1 : boolean ;
  SelectionCell: TGridRect;
begin

if Button = mbLeft then
begin
  // this chooses how many cells to draw
  if  SG2.VisibleRowCount = SG2.RowCount then
    rowVis := SG2.RowCount
  else
    rowVis :=  SG2.VisibleRowCount + 1 ;
  if  SG2.VisibleColCount = SG2.ColCount then
    colVis := SG2.ColCount
  else
    colVis :=  SG2.VisibleColCount + 1 ;


 // ********   Save the previous row/cols selcted  ******* //
  if (sROW < 2) and (sCol > 1) then  // a column was chosen in last selection
  begin
     lastCOL :=  sCOL ;
     lastROW :=  -1 ;
  end
  else if (sCol < 2) and (sRow > 1) then  // a row was selected n last selection
  begin
     lastROW :=  sROW ;
     lastCOL :=  -1 ;
  end
  else if (sCol < 2) and (sRow < 2) then   // all rows/cols were selected
  begin
    lastROW :=  -1 ;
    lastCOL :=  -1 ;
  end
  else  if (sCol > 1) and (sRow > 1) then   // a single cell was selected
  begin
     lastROW :=  -1 ;
     lastCOL :=  -1 ;
  end ;


// This determine which cell was selected
  SG2.MouseToCell(X, Y,  colInput, rowInput ) ;
  // these are the new row/col selected
  sROW :=  rowInput ;
  sCOL :=  colInput ;

  rowStr :=   RowStrText.Text   ;
  colStr :=   ColStrText.Text   ;

  rowcolList := TMemoryStream.Create ;

  if ((sROW < 2) or (sCOL < 2)) and not ((sROW < 2) and (sCOL < 2)) then
  begin  // only if a column or row has been selected
    if  keyDownV = 0 then   // Ctrl, Shift or Shift and Ctrl are not down
    begin
       if sCol < 2 then // *** sCol < 2 so selecting rows ***
       begin
         if (rowStr = '') or (sRow <> lastRow)  then
         begin
           rowStr := inttostr(sRow-1) ;
           rowcolList.SetSize(4) ;
           t1 := sRow - 1 ;
           rowcolList.Write(t1,4) ;
  //         FlagSelectedRowCols(rowcolList, flagsRow) ;
         end
         else
         begin
           rowStr := '' ;
           SetAllFlagsRowCols(false,flagsRow) ;
         end ;
       end ;
       if sROW < 2 then  // *** sRow < 2 so selecting columns ***
       begin
         if (colStr = '') or (sCol <> lastCOL)  then
         begin
           colStr := inttostr(sCol-1) ;
           rowcolList.SetSize(4) ;
           t1 := sCol - 1 ;
           rowcolList.Write(t1,4) ;
  //         FlagSelectedRowCols(rowcolList, flagsCol) ;
         end 
         else
         begin
           colStr := '' ;
           SetAllFlagsRowCols(true,flagsCol) ;
         end ;
       end ;
        //RowStrText.Text :=  inttostr(sCol-1) ;
    end
    else
    if  keyDownV = 1 then   // Ctrl is down
    begin
       if sCol < 2 then  // *** sCol < 2 so selecting rows ***
       begin
         if length(rowStr) = 0 then
         begin
           rowStr := inttostr(sRow-1)  ;
           rowcolList.SetSize(4) ;
           t1 := sRow - 1 ;
           rowcolList.Write(t1,4) ;
         end
         else // row/rows are already selected
         begin
            if GetTotalRowsColsFromString(rowStr, rowcolList, sRow-1 ) then  // returns 'true' if sRow-1 is in range 'rowStr'
            begin  // selected row is in list already => remove
                RemoveRangeFromTMemStream(inttostr(sRow-1), rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString()
                rowStr := CreateStringFromTMemStream(rowcolList) ;
            end
            else  // selected string is not in list => add
            begin
                AddRangeToTMemStream(inttostr(sRow-1), rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString()
                rowStr := CreateStringFromTMemStream(rowcolList) ;
            end ;
         end ;
 //        FlagSelectedRowCols(rowcolList, flagsRow) ;
       end

       else
       if sROW < 2 then  // *** sRow < 2 so selecting columns ***
       begin
         if length(colStr) = 0 then
         begin
           colStr := inttostr(sCol-1) ;
           rowcolList.SetSize(4) ;
           t1 := sCol - 1 ;
           rowcolList.Write(t1,4) ;
         end 
         else // column/columns are already selected
         begin
            if GetTotalRowsColsFromString(colStr, rowcolList, sCol-1 ) then  // returns 'true' if sCol-1 is in range 'colStr'
            begin  // selected column is in list already => remove
                RemoveRangeFromTMemStream(inttostr(sCol-1), rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString() above
                colStr := CreateStringFromTMemStream(rowcolList) ;
            end
            else  // selected string is not in list => add
            begin
                AddRangeToTMemStream(inttostr(sCol-1), rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString()  above
                colStr := CreateStringFromTMemStream(rowcolList) ;
            end ;
         end ;
   //      FlagSelectedRowCols(rowcolList, flagsCol) ;
      end ;
    end
    else

    if  keyDownV = 2 then   // Shift is down
    begin
       if sCol < 2 then // *** sCol < 2 so selecting rows ***
       begin
          if lastROW <> -1 then
          begin
            if lastRow > sRow then
              rowStr := inttostr(sRow-1) +'-'+inttostr(lastRow-1)
            else
              rowStr := inttostr(lastRow-1) +'-'+inttostr(sRow-1) ;
              AddRangeToTMemStream(rowStr, rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString()
    //          FlagSelectedRowCols(rowcolList, flagsRow) ;
          end
          else
          begin
            rowStr := inttostr(sRow-1)  ;
            rowcolList.SetSize(4) ;
            t1 := sRow - 1 ;
            rowcolList.Write(t1,4) ;
          end
       end ;
       if sROW < 2 then  // *** sRow < 2 so selecting columns ***
       begin
          if lastCOL <> -1 then
          begin
            if lastCOL > sCol then
              colStr := inttostr(sCol-1) +'-'+inttostr(lastCOL-1)
            else
              colStr := inttostr(lastCOL-1) +'-'+inttostr(sCol-1) ;
              AddRangeToTMemStream(colStr, rowcolList) ; // rowcolList is filled by GetTotalRowsColsFromString()
  //            FlagSelectedRowCols(rowcolList, flagsCol) ;
          end
          else
          begin
            colStr := inttostr(sCol-1)  ;
            rowcolList.SetSize(4) ;
            t1 := sCol - 1 ;
            rowcolList.Write(t1,4) ;
          end ;
       end ;

    end
    else
    if  keyDownV = 3 then   // Ctrl and Shift are down
    begin
       if sCol < 2 then // *** sCol < 2 so selecting rows ***
       begin
          if lastROW <> -1 then
          begin
            GetTotalRowsColsFromString(rowStr, rowcolList, sRow-1 ) ;   // get initial selected rows
            if lastRow > sRow then
              rowStr := inttostr(sRow-1) +'-'+inttostr(lastRow-1)      // compose range of new columns to add to initial selected rows
            else
              rowStr := inttostr(lastRow-1) +'-'+inttostr(sRow-1) ;
            AddRangeToTMemStream(rowStr, rowcolList) ;                 // add new columns to initial columns
            rowStr := CreateStringFromTMemStream(rowcolList) ;         // create string from the join of the two sets
      //      FlagSelectedRowCols(rowcolList, flagsRow) ;
          end
          else
          begin
            rowStr := inttostr(sRow-1)  ;
            rowcolList.SetSize(4) ;
            t1 := sRow - 1 ;
            rowcolList.Write(t1,4) ;
    //        FlagSelectedRowCols(rowcolList, flagsRow) ;
          end
       end ;
       if sROW < 2 then  // *** sRow < 2 so selecting columns ***
       begin
          if lastCOL <> -1 then
          begin
            GetTotalRowsColsFromString(colStr, rowcolList, sCol-1 ) ;  // get initial selected columns
            if lastCOL > sCol then
              colStr := inttostr(sCol-1) +'-'+inttostr(lastCOL-1)      // compose range of new columns to add to initial selected columns
            else
              colStr := inttostr(lastCOL-1) +'-'+inttostr(sCol-1) ;
            AddRangeToTMemStream(colStr, rowcolList) ;                 // add new columns to initial columns
            colStr := CreateStringFromTMemStream(rowcolList) ;         // create string from the join of the two sets
      //      FlagSelectedRowCols(rowcolList, flagsCol) ;
          end
          else
          begin
            colStr := inttostr(sCol-1)  ;
            rowcolList.SetSize(4) ;
            t1 := sCol - 1 ;
            rowcolList.Write(t1,4) ;
         //   FlagSelectedRowCols(rowcolList, flagsCol) ;
          end ;
       end ;
    end ;

    if sROW < 2 then  // *** sRow < 2 so selecting columns ***
    begin
      FlagSelectedRowCols(rowcolList, flagsCol) ;
    end
    else
    if sCol < 2 then // *** sCol < 2 so selecting rows ***
    begin
      FlagSelectedRowCols(rowcolList, flagsRow) ;
    end ;
  end ;





  if (sROW < 2)and (sCOL < 2) then  // All cells selected or deselected
  begin
    if (rowStr = '1-'+inttostr(flagsRow.Size)) and (colStr = '1-'+inttostr(flagsCol.Size)) then
    begin
      rowStr := '' ;
      colStr := '' ;
      SetAllFlagsRowCols(false,flagsRow) ;
      SetAllFlagsRowCols(false,flagsCol) ;
    end
    else
    if (rowStr <> '1-'+inttostr(flagsRow.Size)) or (colStr <> '1-'+inttostr(flagsCol.Size)) then
    begin
      rowStr := '1-'+inttostr(flagsRow.Size) ;
      colStr := '1-'+inttostr(flagsCol.Size) ;
      SetAllFlagsRowCols(true,flagsRow) ;
      SetAllFlagsRowCols(true,flagsCol) ;
    end

  end ;

  RowStrText.Text :=  rowStr ;
  ColStrText.Text :=  colStr ;

// *******   This selects rows/cols for display   ****** //
// this redraws each cell that is visible
  for  t1  :=  SG2.TopRow to SG2.TopRow + rowVis do
  begin
    for t2 := SG2.leftCol to SG2.LeftCol + colVis  do
    begin
      tR := SG2.CellRect(t2, t1) ;
      SG2DrawCell(sender,t2,t1,tR,tGDS) ;
    end ;
  end ;

  form4.StringGrid1.Cells[ownersCol,ownersRow] := RowStrText.Text +':'+ ColStrText.Text ;

  SG1_ROW := ownersRow ;
  SG1_COL := ownersCol  ;

  form4.StringGrid1.Col := ownersCol ;
  form4.StringGrid1.Row := ownersRow ;
  
//  Form4.StringGrid1SelectCell(sender,ownersCol,ownersRow,b1) ;

  TSpectraRanges(form4.StringGrid1.Objects[ownersCol,ownersRow]).CreateGLList(RowStrText.Text, Form1.Canvas.Handle, RC,  Form2.GetWhichLineToDisplay(), TSpectraRanges(form4.StringGrid1.Objects[ownersCol,ownersRow]).lineType) ;

  if Form4.CheckBox7.Checked = false then
    Form1.UpdateViewRange() ;  // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

  rowcolList.Free ;

end
else
if Button = mbRight then
begin


end ;

  Form1.Refresh ;
end;

procedure TSGDataView.SG2DrawCell(Sender: TObject; Colx, Rowx: Integer;
  Rect: TRect; State: TGridDrawState );
// this function is called every time a cell is selected (or reselected) and is called for every cell that
// has text or objects associated with them.
Var
  tstr : String ;
  rowBool, colBool : boolean ;
begin

   flagsRow.Seek(Rowx-2,soFromBeginning) ;
   flagsRow.Read(rowBool,1) ;
   flagsCol.Seek(Colx-2,soFromBeginning) ;
   flagsCol.Read(colBool,1) ;

   if rowBool and colBool then
     State := [ gdSelected ]   // clNavy
   else
   if (rowBool) or (colBool) then
     State := [ gdFocused	 ]   // clNavy
   else
     State := [ ] ;


   If (Rowx > 1) and (Colx > 1) then
   begin
     if  (gdSelected in State) then
     begin
        SG2.Canvas.Brush.Color := clNavy			 ;
        SG2.Canvas.FillRect(Rect) ;
        SetTextColor(SG2.Canvas.Handle, clWhite ) ;
     end
     else
     if  (gdFocused in State) then
     begin
        SG2.Canvas.Brush.Color := $02E0E0E0			 ;
        SG2.Canvas.FillRect(Rect) ;
        SetTextColor(SG2.Canvas.Handle, clBlack ) ;
     end
     else
     begin
       SG2.Canvas.Brush.Color :=  clWhite		 ;
       SG2.Canvas.FillRect(Rect) ;
       SetTextColor(SG2.Canvas.Handle, clBlack ) ;
     end ;
     tstr :=  SG2.Cells[Colx,Rowx] ;
     DrawText(SG2.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
   end ;

   // paint edges grey with black text - need this even if FixedCols and FixedRows are = to 1
   If  (Rowx = 1) or (Colx = 1)  Then  // numerical labels of each variable
   begin
   //   if SGx_COL
      SG2.Canvas.Brush.Color := clBlack		 ;
      SG2.Canvas.FillRect(Rect) ;
      SG2.Canvas.Brush.Color := clLtGray		 ;
      Rect.Left := Rect.Left - 1 ;
      Rect.Right := Rect.Right - 1 ;
      Rect.Top := Rect.Top - 1 ;
      Rect.Bottom := Rect.Bottom -1 ;
      SG2.Canvas.FillRect(Rect) ;
      SetTextColor(SG2.Canvas.Handle, clBlack ) ;;
      tstr :=  SG2.Cells[Colx,Rowx] ;
      DrawText(SG2.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
   end ;
   If  (Rowx = 0) or (Colx = 0)  Then   // text labels if present
   begin
   //   if SGx_COL
      SG2.Canvas.Brush.Color := clBlack		 ;
      SG2.Canvas.FillRect(Rect) ;
      SG2.Canvas.Brush.Color := clWhite		 ;
      Rect.Left := Rect.Left - 1 ;
      Rect.Right := Rect.Right - 1 ;
      Rect.Top := Rect.Top - 1 ;
      Rect.Bottom := Rect.Bottom -1 ;
      SG2.Canvas.FillRect(Rect) ;
      SetTextColor(SG2.Canvas.Handle, clBlack ) ;;
      tstr :=  SG2.Cells[Colx,Rowx] ;
      DrawText(SG2.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
   end ;

   SG2.Canvas.Brush.Color := clBlack		 ;
end;



procedure TSGDataView.FormActivate(Sender: TObject);
begin
  SG1_ROW := ownersRow ;
  SG1_COL := ownersCol  ;
  
  form4.StringGrid1.Col := ownersCol ;
  form4.StringGrid1.Row := ownersRow ;
end;


procedure TSGDataView.Button1Click(Sender: TObject);
begin
   form4.StringGrid1.Cells[ownersCol,ownersRow] := RowStrText.Text +':'+ ColStrText.Text ;
end;




end.
