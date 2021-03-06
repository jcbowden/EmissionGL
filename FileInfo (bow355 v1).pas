unit FileInfo;

interface

uses
  Windows, OpenGL, Messages, SysUtils, Classes, Graphics, Controls, Clipbrd, Forms, Dialogs,
  Grids, ComCtrls, StdCtrls, Menus, ShellAPI, ExtCtrls, Math, BLASLAPACKfreePas, TMatrixObject, TSpectraRangeObject,
  TBatch, TIRPolAnalysisObject2, TPCABatchObject, T2DCorrelObject, SPCFileUnit,
  TStringListExtUnit, TPLMAnalysisUnit1, TDichroicRatioUnit, TPCRPredictBatchUnit, TPLSPredictBatchUnit,
  TPLSYPredictTestBatchUnit, TRotateFactorsUnit, TTiffReadWriteUnit, TPassBatchFileToExecutableUnit ;

type AverageOrSkip = (average, skip);

type
  TForm4 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    StringGrid1: TStringGrid;
    PopupMenu1: TPopupMenu;
    close1: TMenuItem;
    Save1: TMenuItem;
    SaveDialog1: TSaveDialog;
    Panel1: TPanel;
    CheckBox8: TCheckBox;
    CheckBox7: TCheckBox;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Open1: TMenuItem;
    Revert1: TMenuItem;
    MenuItem1: TMenuItem;
    SaveFile1: TMenuItem;
    N2: TMenuItem;
    Exit1: TMenuItem;
    Edit1: TMenuItem;
    CutText1: TMenuItem;
    Copy1: TMenuItem;
    Paste1: TMenuItem;
    N1: TMenuItem;
    Clear1: TMenuItem;
    Colours1: TMenuItem;
    Background1: TMenuItem;
    Font1: TMenuItem;
    Batch1: TMenuItem;
    FontDialog1: TFontDialog;
    OpenDialog1: TOpenDialog;
    GraphicsWindow1: TMenuItem;
    OpenFiles1: TMenuItem;
    StatusBar1: TStatusBar;
    N3: TMenuItem;
    N4: TMenuItem;
    Combine1: TMenuItem;
    separate1: TMenuItem;
    N2Ddisplay1: TMenuItem;
    N5: TMenuItem;
    Cut2: TMenuItem;
    Flip1: TMenuItem;
    Transpose1: TMenuItem;
    ColorDialog1: TColorDialog;
    Colour1: TMenuItem;
    Processing1: TMenuItem;
    MeanCentre1: TMenuItem;
    VarianceScale1: TMenuItem;
    Unmeancentre1: TMenuItem;
    UnvarianceScale1: TMenuItem;
    Average2: TMenuItem;
    Variance1: TMenuItem;
    alldata1: TMenuItem;
    N6: TMenuItem;
    FlipXAxis1: TMenuItem;
    About1: TMenuItem;
    VectorNormalise1: TMenuItem;
    ViewAverage: TMenuItem;
    ExtractAverage1: TMenuItem;
    ViewVariance1: TMenuItem;
    ExtractVariance1: TMenuItem;
    Timer1: TTimer;
    All2: TMenuItem;
    Selected2: TMenuItem;
    CombineAll1: TMenuItem;
    CombineSelected1: TMenuItem;
    As2DPlots1: TMenuItem;
    Integration1: TMenuItem;
    UseAsXcoords1: TMenuItem;
    ScaledXCoords1: TMenuItem;
    procedure StringGrid1Click(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure close1Click(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure StringGrid1KeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure StringGrid1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);
    procedure SaveDialog1TypeChange(Sender: TObject);
    procedure FormResize(Sender: TObject);
    Function GetOrthoVarValues(NumRows : Integer) : TGLRangeArray  ;
    procedure StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
      var CanSelect: Boolean);
    procedure StringGrid1DblClick(Sender: TObject);
    procedure StringGrid1SetEditText(Sender: TObject; ACol, ARow: Integer;
      const Value: String);
    procedure CheckBox7Click(Sender: TObject);
    procedure Open1Click(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure Background1Click(Sender: TObject);
    procedure Font1Click(Sender: TObject);
    procedure Batch1Click(Sender: TObject);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure OpenFiles1Click(Sender: TObject);
    procedure GraphicsWindow1Click(Sender: TObject);
    procedure CheckBox8Click(Sender: TObject);
    procedure N2Ddisplay1Click(Sender: TObject);
    procedure CutText1Click(Sender: TObject);
    procedure Flip1Click(Sender: TObject);
    procedure Transpose1Click(Sender: TObject);
    procedure Colour1Click(Sender: TObject);
    procedure MeanCentre1Click(Sender: TObject);
    procedure VarianceScale1Click(Sender: TObject);
    procedure Unmeancentre1Click(Sender: TObject);
    procedure UnvarianceScale1Click(Sender: TObject);
    procedure alldata1Click(Sender: TObject);
    procedure FlipXAxis1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure VectorNormalise1Click(Sender: TObject);
    procedure ViewAverageClick(Sender: TObject);
    procedure ExtractAverage1Click(Sender: TObject);
    procedure ViewVariance1Click(Sender: TObject);
    procedure ExtractVariance1Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Selected2Click(Sender: TObject);
    procedure All2Click(Sender: TObject);
    procedure CombineSelected1Click(Sender: TObject);
    procedure CombineAll1Click(Sender: TObject);
    procedure Revert1Click(Sender: TObject);
    procedure As2DPlots1Click(Sender: TObject);
    procedure Integration1Click(Sender: TObject);
    procedure UseAsXcoords1Click(Sender: TObject);
    procedure ScaledXCoords1Click(Sender: TObject);// OVXMax,OVXMin,OVYMax,OVYMin : GLFloat
  private
    { Private declarations }
  public
    procedure wmDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    procedure InitialiseDataGrid ;

    procedure InitializeSpectraData(files : TStringList; numSpectra : integer ) ;
    procedure DoStuffWithStringGrid(filename : String; XorYMatrix, numRows, numCols : integer; addLineToStrGrid : boolean; addToRow : integer) ;
    function  GetLowestListNumber : Integer ;

    procedure SortList(TL : TStringList) ;

    function  LoadSPCXrayFile(SpectObj : TSpectraRanges): boolean ;
    Procedure LoadSPAFileFFT(SpectObj : TSpectraRanges) ; // loads original fourier data from SPA file
    procedure LoadSPAFileFloat(SpectObj : TSpectraRanges) ; // loads (modified) floating point data from SPA files
    function  LoadJDXFile(SpectObj : TSpectraRanges; tStrList : TStringList; numFiles, numPoints, whichFile, lineNum : integer) : integer ;
    function  ProcessXYYString(SpectraObject : TSpectraRanges; dataString : String) : integer ;
    function  GetJDXlineNumofString(tStrList : TStringList; toFind : String; lineNum : integer) : integer ;
    function  GetNumJDXSubFiles(tStrList : TStringList) : integer ;
    function  GetJDXHeaderSize(tStrList : TStringList; dataType : String ; lineNum : integer) : integer ; // dataType is '##XYDATA=' or '##XYPOINTS='
    function  GetJDXHeaderData(toFind : string; tStrList : TStringList ; headerSize, lineNum : integer) : string ;
    function  FindStringInFile(compareStr : String; fileStream : TFileStream; startPos : integer) : integer ;
    function  CheckFileExtension(inFilename, extensionDotIncl: string) : string ;
    function  ChooseDisplayType(SpectObj : TSpectraRanges) : boolean ;   // frequencyImage or Nativeimage or normal spectra

    procedure ClearCellObjectAndString(selectedColNum :integer; selectedRowNum :integer );
    // load results from 'externally executed' function.
    // fileExtIn : is '.bin' etc, inclusive of point '.'
    procedure LoadResultFiles(bFE: TPassBatchFileToExecutable; SGRowNum : integer; fileExtIn : string) ; // pass the executed processes info and its line number

    procedure ReduceTIFF(tSRIn : TSpectraRanges; factor: Integer; aveOrSkip: AverageOrSkip) ;
    { Public declarations }

  end;


var
  Form4: TForm4;
  SelectStrLst, SelectColList : TStringListExt ;  // used to store selection from string grid and to paint these cells in differnt color
  keyDownV : integer ;  // 0 = no key down, 1 = Ctrl, 2 = Shift, 3 = Ctrl and Shift... used for selecting multiple file from StringGrid1
  lastRowClicked, lastColClicked : integer ;
  SG1_ROW, SG1_COL : integer ;  // stores what StringGrid1 cell was last selected
  originalText : string ;
  mouse_downCOL, mouse_downROW : LongInt ;
    mouse_UpCol, mouse_UpRow : Longint ; // returned by MouseToCell() function in StringGrid1.StringGrid1MouseUp()
  clipboardCharBuff : PChar ;  // used to store text for clipboard
  HomeDir : string ;
  IntensityList : TStringList ;
  mouseDownBool : boolean ;
  lastFileExt : string ;
  maxList : integer ;

implementation

uses emissionGL, ColorsEM, StringGridDataViewer, batchEdit, TAutoProjectEVectsUnit ;

{$R *.DFM}



procedure TForm4.SortList(TL : TStringList) ;
var
  swapped, didswap : boolean ;
  tint1 : integer ;
begin
//     Form4.TabSheet2.Show ;
     swapped  := true ;
     didswap := false ;
     while swapped = true do
     begin
        for tint1 := 0 to TL.Count-2 do
        begin
          if strtoint(TL.Strings[tint1]) > strtoint(TL.Strings[tint1+1]) then
          begin
            TL.Exchange(tint1, tint1+1) ;
            didswap := true ;
          end ;
        end ;

        if didswap = true then
           swapped := true
        else
           swapped := false ;

        didswap := false ;

//        Form4.Memo1.Lines.Clear() ; // used to view numbers in SelectStrLst
//        for tint1 := 0 to TL.Count-1 do
//             Form4.Memo1.Lines.Add(TL.Strings[tint1]) ;
     end ;

end ;

procedure TForm4.ClearCellObjectAndString(selectedColNum :integer; selectedRowNum :integer );
begin

   if StringGrid1.Objects[ selectedColNum,  selectedRowNum] <> nil  then
     StringGrid1.Objects[ selectedColNum,  selectedRowNum].Free ;

   StringGrid1.Objects[ selectedColNum,  selectedRowNum] := nil ;

   StringGrid1.Cells[ selectedColNum,  selectedRowNum]   := ''  ;
end ;




procedure TForm4.close1Click(Sender: TObject);
Var
  t1, t2, t3, t4 : Integer ;
  selectedRowNum : integer ;
  colNumber : integer ;
  GR : TGridRect ;
  StringsToMove : TStringListExt ;
  Row1, Row2 : integer ;
begin

  SelectStrLst.SortListNumeric ;

 // close single file if cell is not first in the slected row (unless col2 is empty)
  if StringGrid1.Objects[2 , selectedRowNum] = nil then
  begin
  if (SG1_COL > 2) then
  begin
    for t1 := 1 to SelectStrLst.Count do // close each file selected in the TStrigGrid starting from last one (in sorted order)
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1-1]) ; // the file to be deleted is the integer value of the string that is last in the list.

      if StringGrid1.Objects[SG1_COL , selectedRowNum] is TSpectraRanges then
      begin
        ActivateRenderingContext(Form1.Canvas.Handle,RC);
          TSpectraRanges(StringGrid1.Objects[SG1_COL , selectedRowNum]).ClearOpenGLData; // remove OpenGL compiled list
          glFlush ;
        wglMakeCurrent(0,0);
        TSpectraRanges(StringGrid1.Objects[SG1_COL , selectedRowNum]).Free ;
        StringGrid1.Objects[ SG1_COL ,  selectedRowNum] := nil ;
        StringGrid1.Cells[ SG1_COL ,  selectedRowNum] := ''  ;
      end ;
    end;
    StringGrid1.Refresh ;
    Form1.Refresh ;
    exit ;
  end ;
  end;



  StringsToMove  := TStringListExt.Create ;

  for t1 := 1 to SelectStrLst.Count do
  begin
    Row1 := strtoint(SelectStrLst.Strings[t1-1]) ;
    if t1 < SelectStrLst.Count then
    begin
      Row2 := strtoint(SelectStrLst.Strings[t1]) ;
    end
    else
    begin
      Row2 := StringGrid1.RowCount -1 ;  // maybe -2
    end ;
    while row2 <> (row1+1) do
    begin
      StringsToMove.Add(inttostr(row1+1)) ;
      inc(row1) ;
    end ;
  end ;

//  StringsToMove.SaveToFile('stringsTomove.txt') ;


  for t1 := 1 to SelectStrLst.Count do // close each file selected in the TStrigGrid starting from last one (in sorted order)
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1-1]) ; // the file to be deleted is the integer value of the string that is last in the list.

   if selectedRowNum <> StringGrid1.RowCount - 1 Then  // make sure selected stringgrid item is not the last empty one
   begin
      for t2 := 1 to StringGrid1.ColCount-1 do // for each column in row
      begin
       if StringGrid1.Objects[t2,selectedRowNum] <> nil then
       begin
          // **** Free TSpectraRanges Objects ****
         if StringGrid1.Objects[t2,selectedRowNum] is TSpectraRanges then
         begin
           ActivateRenderingContext(Form1.Canvas.Handle,RC);
              TSpectraRanges(StringGrid1.Objects[t2,selectedRowNum]).ClearOpenGLData; // remove OpenGL compiled list
              glFlush ;
            wglMakeCurrent(0,0);
           TSpectraRanges(StringGrid1.Objects[t2,selectedRowNum]).Free ;
           StringGrid1.Objects[ t2,  selectedRowNum] := nil ;
           StringGrid1.Cells[ t2,  selectedRowNum]   := ''  ;
         end
       end  // if t2 <> 1
     end ; // if <> nil
  end ;  // for loop iterating through each selected file in StringGrid1
  end ;



  Row1 := strtoint(SelectStrLst.Strings[0]) ;
  for t1 := 1 to StringsToMove.Count do
  begin
     Row2 := strtoint(StringsToMove.Strings[t1-1])  ;

  {  // remove this code as now spectra can be dragged and dropped anywhere so have to delete whole row
     if  (StringGrid1.Objects[ 1, Row2] = nil) then    // Row2 was t1
     for t2 := 0 to 3 do   // four first columns
     begin
       StringGrid1.Objects[t2, Row1 ] := StringGrid1.Objects[t2, Row2 ]  ;
       StringGrid1.Cells[t2, Row1 ]   := StringGrid1.Cells[t2, Row2 ]  ;
     end
     else // copy all columns    }
     for t2 := 0 to StringGrid1.ColCount -1 do   // for each column in row to delete
     begin
       StringGrid1.Objects[t2, Row1 ] := StringGrid1.Objects[t2, Row2 ]  ;
       StringGrid1.Cells[t2, Row1 ]   := StringGrid1.Cells[t2, Row2 ]  ;
     end ;

     inc(Row1) ;
  end ;



  for t2 := 0 to StringGrid1.ColCount -1 do   // for each column in  last row?/?
  begin
    StringGrid1.Objects[t2, Row1 ] := nil  ;
    StringGrid1.Cells[t2, Row1 ]   := ''  ;
  end ;



  StringGrid1.RowCount := StringGrid1.RowCount - SelectStrLst.Count ;
  SelectStrLst.Clear ;
  StringsToMove.Free ;
//  for t1 := 0 to StringGrid1.ColCount -1 do   // for each column
//    StringGrid1.Cells[t1, StringGrid1.RowCount-1 ] := '' ;

  lastRowClicked := 0 ;
  lastColClicked := 0 ;

  StringGrid1.Refresh ;
  Form1.Refresh ;
end;

procedure TForm4.Save1Click(Sender: TObject);
var
  t1, t2 : integer ;
  rowNum, rowNum2, t3, offset, xxx, specNum : Integer ;
  tempFN : String ;
  newMultiSpec, specPtr : TSpectraRanges ;
  TempXY : Array[0..1] of single ;
  xpos : single ;
  saveSPC : ReadWriteSPC ;
begin

  SortList(SelectStrLst) ;
  t1 := 0 ;
  while t1 <= SelectStrLst.Count -1 do // Save each file selected in the TStrigGrid (in sorted order)
  begin
    rowNum := StrToInt(SelectStrLst.Strings[t1]) ; // the file to be deleted is the int value of the string that is last in the list, then delete this string
//      rowNum := rowNum - 1 ;

      Form4.SaveDialog1.Title := 'Save selected spectra file(s)'  ;
      Form4.SaveDialog1.Filter := 'any (*.*)|*.*|jcamp (single)|*.jdx|jcamp (multi)|*.jdx|comma separated (single)|*.csv|comma separated (multi) excel format|*.csv|tab separated (multi)|*.txt|binary (*.bin)|*.bin|Galactic SPC (*.spc)|*.spc|ImageJ RAW (*.raw)|*.raw'    ;

      tempFN :=  copy(Form4.StringGrid1.Cells[1,rowNum],1,pos(extractfileext(Form4.StringGrid1.Cells[1,rowNum]),Form4.StringGrid1.Cells[1,rowNum])-1) ;
      Form4.SaveDialog1.FileName :=   tempFN  ;

      tempFN := TSpectraRanges(Form4.StringGrid1.Objects[2,rowNum]).xCoord.Filename ; // remove file extension
      tempFN := copy(tempFN,1,length(tempFN)-length(ExtractFileExt(tempFN))) ; // remove file extension
//      Form4.SaveDialog1.filename :=  tempFN ;  // this cannot be modified during savedialog1 use, so modify after to add file extension
//      Form4.SaveDialog1.InitialDir := extractFilePath(Form4.SaveDialog1.filename) ;
 //     messagedlg('Selected file is... '+filename,mtInformation,[mbOk],0) ;
      If Form4.SaveDialog1.Execute Then
      begin
        if Form4.SaveDialog1.FilterIndex = 1 then
          begin
             SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.csv') ;
             TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).SaveSpectraDelimExcel(SaveDialog1.filename, ',') ;
             TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).xCoord.Filename := Form4.SaveDialog1.FileName ;
             Form4.StringGrid1.Cells[1,rowNum] := extractFileName(SaveDialog1.filename) ;
             // messagedlg('Selected file is... *.*  '+Form4.SaveDialog1.filename,mtInformation,[mbOk],0) ;
             inc(t1) ;
             Form4.SaveDialog1.DefaultExt := '*.csv' ;
             Form4.SaveDialog1.FileName := '*.csv' ;
             Form4.SaveDialog1.FilterIndex := 1 ;
          end
          else if Form4.SaveDialog1.FilterIndex = 2 then
          begin                                                                                                  ;
          //    TSpectraRanges(Form4.StringGrid1.Objects[1,rowNum]).SaveJDXSpectrum(SaveDialog1.filename+'.jdx')
              //   messagedlg('Selected file is... *.jdx  '+Form4.SaveDialog1.filename,mtInformation,[mbOk],0) ;
              inc(t1) ;
          end
          else if Form4.SaveDialog1.FilterIndex = 3 then  // multi jdx file
          begin
          //    TSpectraRanges(Form4.StringGrid1.Objects[1,rowNum]).SaveJDXSpectrum(SaveDialog1.filename+'.jdx')   ;
              // messagedlg('Selected file is... *.jdx (multi) '+Form4.SaveDialog1.filename,mtInformation,[mbOk],0) ;
              t1 := SelectStrLst.Count ;
          end
          else if Form4.SaveDialog1.FilterIndex = 4 then  // single each file as a single csv file
          begin
              SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.csv') ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).SaveSpectraDelimExcel(SaveDialog1.filename, ',')       ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).xCoord.Filename := Form4.SaveDialog1.FileName ;
              Form4.StringGrid1.Cells[1,rowNum] := extractFileName(SaveDialog1.filename) ;
              //messagedlg('Selected file is... *.csv  '+Form4.SaveDialog1.filename,mtInformation,[mbOk],0) ;
              inc(t1) ;
              Form4.SaveDialog1.DefaultExt := '*.csv' ;
             Form4.SaveDialog1.FileName := '*.csv' ;
             Form4.SaveDialog1.FilterIndex := 4 ;
          end
          else if (Form4.SaveDialog1.FilterIndex = 5) or ( Form4.SaveDialog1.FilterIndex = 6) then  // multi tab delimeted file with variables per column
          begin
              xxx := 0 ;
              // count number of spectra in spectra objects selected
              For t2 := 0 to SelectStrLst.Count -1 do  // for each spectum in list
              begin
                 specPtr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,StrToInt(SelectStrLst.Strings[t2])]) ;  // this is to get number of data points for size of new multi spectra
                 xxx := xxx + specPtr.yCoord.numRows ;
              end ;

              newMultiSpec := TSpectraRanges.Create(specPtr.yCoord.SDPrec div 4,1, specPtr.xCoord.numCols, nil  ) ;
//              newMultiSpec.yCoord.numRows :=  SelectStrLst.Count ;

              // add x data and copy Y data of first spectra in list
              specPtr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,StrToInt(SelectStrLst.Strings[0])]) ;    // this SG1_COL was = to 2
              newMultiSpec.xCoord.CopyMatrix(specPtr.xCoord) ;
              newMultiSpec.yCoord.CopyMatrix(specPtr.yCoord) ;


              For t2 := 1 to SelectStrLst.Count -1 do  // for each spectum in list
              begin
                 specPtr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,StrToInt(SelectStrLst.Strings[t1])]) ;
                 for t3 := 1 to  specPtr.yCoord.numRows do   // add each row of Y data
                   newMultiSpec.yCoord.AddRowToEndOfData(specPtr.yCoord, t3, specPtr.yCoord.numCols) ;
              end ; // adding data to multi spectrum TSpectraRanges object

              newMultiSpec.yCoord.numRows := xxx ;

              // save the spectrum
              if  Form4.SaveDialog1.FilterIndex = 5 then
              begin
                  SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.csv') ;
                  newMultiSpec.SaveSpectraDelimExcel(SaveDialog1.filename, ',')       ;
                  Form4.StringGrid1.Cells[1,rowNum] := extractFileName(SaveDialog1.filename)  ;
                  Form4.SaveDialog1.DefaultExt := '*.csv' ;
                  Form4.SaveDialog1.FileName := '*.csv' ;
                  Form4.SaveDialog1.FilterIndex := 5 ;
              end
              else
              if  Form4.SaveDialog1.FilterIndex = 6 then
              begin
                  SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.txt') ;
                  newMultiSpec.SaveSpectraDelimited(SaveDialog1.filename, #9)       ;
                  Form4.StringGrid1.Cells[1,rowNum] := extractFileName(SaveDialog1.filename) ;
                  Form4.SaveDialog1.DefaultExt := '*.txt' ;
                  Form4.SaveDialog1.FileName := '*.txt' ;
                  Form4.SaveDialog1.FilterIndex := 6 ;
              end ;

              //t1 := SelectStrLst.Count ;
              t1 := t1 + 1 ; //
              newMultiSpec.Free ;

          end
          else if Form4.SaveDialog1.FilterIndex = 7 then  // Binary file called
          begin
              SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.bin') ;
//              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).SaveSpectraRangeDataBinV2( Form4.SaveDialog1.FileName ) ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).SaveSpectraRangeDataBinV3( Form4.SaveDialog1.FileName ) ;
              Form4.StringGrid1.Cells[1,rowNum] := extractfilename(SaveDialog1.filename) ;
              t1 := t1 + 1 ; //
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).xCoord.Filename := Form4.SaveDialog1.FileName ;

              Form4.SaveDialog1.DefaultExt := '*.bin' ;
              Form4.SaveDialog1.FileName := '*.bin' ;
              Form4.SaveDialog1.FilterIndex := 7 ;
          end
          else if Form4.SaveDialog1.FilterIndex = 8 then  // SPC file called
          begin
              SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.spc') ;
              saveSPC  := ReadWriteSPC.Create ;

              saveSPC.WriteSPCDataFromSpectraRange( Form4.SaveDialog1.FileName, TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]))  ;
              Form4.StringGrid1.Cells[1,rowNum] := extractfilename(SaveDialog1.filename) ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).xCoord.Filename := Form4.SaveDialog1.FileName ;

              saveSPC.Free ;
              t1 := t1 + 1 ; // SelectStrLst.Count ;
              Form4.SaveDialog1.DefaultExt := '*.spc' ;
              Form4.SaveDialog1.FileName := '*.spc' ;
              Form4.SaveDialog1.FilterIndex := 8 ;
          end
          else if Form4.SaveDialog1.FilterIndex = 9 then  // RAW file called
          begin
              SaveDialog1.filename := CheckFileExtension(SaveDialog1.filename,'.raw') ;

              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).YCoord.ReverseByteOrder ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).YCoord.F_Mdata.SaveToFile(SaveDialog1.filename) ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).YCoord.ReverseByteOrder ;
              TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,rowNum]).xCoord.Filename := Form4.SaveDialog1.FileName ;
              Form4.StringGrid1.Cells[1,rowNum] := extractfilename(SaveDialog1.filename) ;

              t1 := t1 + 1 ; // SelectStrLst.Count ;
              Form4.SaveDialog1.DefaultExt := '*.raw' ;
              Form4.SaveDialog1.FileName := '*.raw' ;
              Form4.SaveDialog1.FilterIndex := 9 ;

          end  ;
          OpenDialog1.InitialDir :=  ExtractFilePath(SaveDialog1.filename) ;
          SaveDialog1.InitialDir :=  ExtractFilePath(SaveDialog1.filename) ;
      end // execute not called
      else   t1 := SelectStrLst.Count ;

  end ;

end;


function TForm4.CheckFileExtension(inFilename, extensionDotIncl : string) : string ;
var
  t2 : integer ;
begin
  if extractfileext(inFilename) <> extensionDotIncl then
  begin
    t2 := pos(extractfileext(inFilename),inFilename) ;
    if t2  > 0 then
      inFilename := copy(inFilename,1,t2-1) ;
    inFilename := inFilename + extensionDotIncl ;
  end ;

 result := inFilename ;
end ;


procedure TForm4.FormCreate(Sender: TObject);
begin
  HomeDir := GetCurrentDir ;
  SelectStrLst := TStringListExt.Create ;
  SelectColList  := TStringListExt.Create ;

  keyDownV := 0 ;
  mouseDownBool := false ;

  StringGrid1.Cells[1,0]  := 'filename:' ;
  StringGrid1.Cells[2,0]  := 'X Data' ;       // Double click = Can edit values, sample names and variable names.
  StringGrid1.Cells[3,0]  := 'Y Data:' ;       // click = display selected. Double click = open string grid containing all data,
                                               // with specified data highlighted. Can edit values, sample names and variable names.
  StringGrid1.Cells[4,0]  := 'scores'     ;
  StringGrid1.Cells[5,0]  := 'eignevects'   ;
  StringGrid1.Cells[6,0]  := 'eigenvals' ;    // plot of variance spanned by each PC
  StringGrid1.Cells[7,0]  := 'x resid'   ;    // residual data left after subtraction of desired PC range of eigenvectors.
  StringGrid1.Cells[8,0]  := 'x regen '  ;    // regenerated data from desired set of PCs  specified
  StringGrid1.Cells[9,0]  := 'y resid'   ;    // regression residual y data for each PC added. Good for outlier detection.
  StringGrid1.Cells[10,0] := 'y pred'    ;    // plot of measured vs predicted for set of PC's specified
  StringGrid1.Cells[11,0] := 'weights'   ;    // PLS specific
  StringGrid1.Cells[12,0] := 'reg. coef' ;    // result of regression. Plot of Variables vs Absorbance for number of PC's specified
  StringGrid1.Cells[13,0] := 'R^2'     ;    // Single value of R value for regression. If IR-pol then plot of position vs R value OR if 2D then

  maxList :=  258 ;
  lastRowClicked := 1 ;
  lastColClicked := 1 ;
  SG1_COL := 0 ;
  SG1_ROW := 0 ;

  lastFileExt :=  '*.bin' ;  // default file type on starting program

   //also checks to see if files being opened are not older than the current time (so can't set clock back) (security feature 2)  //
   // security feature 1 of 2
//   MessageDlg('time now = '+ floattostr(Now) ,mtInformation, [mbOk], 0) ;
   if (Now) > ((12661.59853 * pi) + (512/3))  then  // if (now) is > 26th May + 170 days then exit
   begin
     Application.Destroy ;
   end ;


end;

procedure TForm4.FormDestroy(Sender: TObject);
Var
 t1, t2 : Integer ;
begin
  SelectStrLst.Free ;
  SelectColList.Free ;
end;


procedure TForm4.wmDropFiles(var Msg: TWMDropFiles); //message WM_DROPFILES;
var
  count, tint : integer ;
  CFileName      : array[0..MAX_PATH] of Char;
  strList : TStringList ;
  TempStr : String ;
begin
  try
    strList := TStringList.Create;

    count :=  DragQueryFile(Msg.Drop, $FFFFFFFF, CFileName, MAX_PATH) ;
    if count > 0 then
    begin
      for tint := 0 to count-1 do   // create list of each filename dropped
      begin
        DragQueryFile(Msg.Drop, tint, CFileName, MAX_PATH) ;
        TempStr :=  Format('%s', [CFilename]) ;
        strList.Add(TempStr) ;
      end ;
      InitializeSpectraData(strList, count) ;  // drag and drop opening  // load each file dropped
    end;
  finally
    Msg.Result := 0;
    DragFinish(Msg.Drop);
   // if SetCurrentDir(ExtractFileDir(strList.Strings[0])) then
    //   messagedlg('new directory is'+ExtractFileDir(strList.Strings[0]) ,mtError,[mbOk],0) ;
    ChDir(ExtractFileDir(strList.Strings[0]))  ;
 //   messagedlg(GetCurrentDir  ,mtinformation,[mbOk],0) ;
    OpenDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
    SaveDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
    strList.Free ;
    Form1.Refresh;
  end;
end;

procedure TForm4.StringGrid1KeyUp(Sender: TObject; var Key: Word;
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

procedure TForm4.StringGrid1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
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
end;




procedure TForm4.CheckBox7Click(Sender: TObject);  // keep current perspective
begin
//  Form1.UpdateViewRange() ;
  Form1.FormResize(Sender) ;
end;


procedure TForm4.StringGrid1Click(Sender: TObject);
Var
  t1 : integer ;
  s1, s2 : single ;
  TempRow : Integer ;
  tSR : TSpectraRanges ;
  XorYdata : integer ;
  first_selection : integer ;
begin
if StringGrid1.Row  <> StringGrid1.RowCount - 1 then  // do not do anything with bottom empty cell
begin
//Memo1.Lines.Clear() ; // used to view numbers in SelectStrLst
if  keyDownV = 0 then   // Ctrl, Shift or Shift and Ctrl are not down
begin
{   if mouseDownBool then
        first_selection :=   StrToInt(SelectStrLst.Strings[0]) ;    }

    if (SG1_COL = mouse_downCOL) then
    begin
      SelectStrLst.Clear() ;
      SelectStrLst.Add(inttostr(StringGrid1.Selection.Top)) ;
      SelectColList.Clear() ;
      SelectColList.Add(inttostr(StringGrid1.Selection.Left)) ;
    end ;
    // code to keep selection if we drag to another column exists in StringGrid1MouseUp() - search for 'top_row'

  if StringGrid1.Col = 1 then
    XorYdata := 2
  else
    XorYdata :=  StringGrid1.Col ;

  if StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top] is TSpectraRanges Then
  begin
    tSR := TSpectraRanges(StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top]) ;
    if (checkbox7.Checked = false) {or (SG1_COL <> StringGrid1.Selection.Left)} then  // then do not keep current perspecive
      begin
        Form1.UpdateViewRange() ;  // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
        EyeX := 0 ;
        EyeY := 0 ;
        CenterX := 0 ;
        CenterY := 0 ;
      end ;
    Form1.Caption := StringGrid1.Cells[1,StringGrid1.Selection.Top] ;
    CurrentFileName := tSR.xCoord.filename ;  // CurrentFileName not used at present
    Form2.Panel2.Color :=  TSpectraRanges(StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top]).ReturnTColorFromLineColor ;
    Form3.Panel2.Color :=  TSpectraRanges(StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top]).ReturnTColorFromLineColor ;

    if tSR.frequencyImage = true then
    begin
      Form2.FrequencySlider1.Max :=  tSR.yCoord.numCols ;
      Form2.FrequencySlider1.Position := tSR.currentSlice ;
      tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      tSR.xCoord.F_Mdata.Read(s1,4) ;
      Form2.Label47.Caption := floattostrF(s1,ffGeneral,5,3 ) ;
      tSR.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
      tSR.xCoord.F_Mdata.Read(s1,4) ;
      Form2.Label48.Caption := floattostrF(s1,ffGeneral,5,3 ) ;
      tSR.xCoord.F_Mdata.Seek((tSR.xCoord.SDPrec * tSR.currentSlice )-tSR.xCoord.SDPrec,soFromBeginning) ;
      tSR.xCoord.F_Mdata.Read(s1,4) ;
      Form2.imageSliceValEB.Text  := floattostrF(s1,ffGeneral,5,3 ) ;
      Form2.ImageNumberTB1.Text := inttostr(tSR.currentImageNumber) ;
    end ;

    if ((tSR.frequencyImage = true) or (tSR.nativeImage = true)) and (tSR.image2DSpecR <> nil) then
    begin
      StatusBar1.Panels[1].Text := 'image range = ' + floattostrf(tSR.image2DSpecR.yLow,ffgeneral,5,3) +' to '+  floattostrf(tSR.image2DSpecR.yHigh,ffgeneral,5,3) ;
      if not Form2.ImageMaxColorCB.Checked then Form2.ImageMaxColorValEB.Text :=   floattostrf(tSR.image2DSpecR.yHigh,ffgeneral,5,3) ;
      if not Form2.ImageMinColorCB.Checked then Form2.ImageMinColorValEB.Text :=   floattostrf(tSR.image2DSpecR.yLow,ffgeneral,5,3) ;
    end
    else
    begin
      StatusBar1.Panels[1].Text := 'image range = ' + floattostrf(tSR.yLow,ffgeneral,5,3) +' to '+  floattostrf(tSR.yHigh,ffgeneral,5,3) ;
    end ;

  end ; // If StringGrid1.Objects[1,TempRow] is TSpectraRanges Then

// this puts column labels on the top of the stringgrid columns
  for t1 := 0 to StringGrid1.ColCount - 1 do
  begin
    if StringGrid1.Objects[t1,StringGrid1.Selection.Top] is TSpectraRanges Then
     StringGrid1.Cells[t1,0]  :=  TSpectraRanges(StringGrid1.Objects[t1,StringGrid1.Selection.Top]).columnLabel
    else
     StringGrid1.Cells[t1,0]  := '' ;
  end;
end // Ctrl and Shift are not down
else
if  keyDownV = 1 then   // Ctrl key down
begin
  //StringGrid1.Cells[2,StringGrid1.Selection.Top] := 'Ctrl' ;

  if (SelectStrLst.IndexOf(inttostr(StringGrid1.Selection.Top))) = -1 then
     SelectStrLst.Add(inttostr(StringGrid1.Selection.Top))
  else
     SelectStrLst.Delete(SelectStrLst.IndexOf(inttostr(StringGrid1.Selection.Top))) ;

  if (SelectColList.IndexOf(inttostr(StringGrid1.Selection.Left))) = -1 then
     SelectColList.Add(inttostr(StringGrid1.Selection.Left))
  else
     SelectColList.Delete(SelectStrLst.IndexOf(inttostr(StringGrid1.Selection.Left))) ;
end
else
if  keyDownV = 2 then   // Shift key down
begin
  //StringGrid1.Cells[2,StringGrid1.Selection.Top] := 'Shift' ;
  SelectStrLst.Clear() ;
  if lastRowClicked <= StringGrid1.Selection.Top then
  begin
    for TempRow := lastRowClicked to StringGrid1.Selection.Top do
      begin
         SelectStrLst.Add(inttostr(Temprow))
      end
  end
  else
  begin
     for Temprow := StringGrid1.Selection.Top to lastRowClicked do
       begin
          SelectStrLst.Add(inttostr(Temprow))
       end
  end ;

  SelectColList.Clear() ;
  if lastColClicked <= StringGrid1.Selection.Left then
  begin
    for TempRow := lastColClicked to StringGrid1.Selection.Left do
      begin
         SelectColList.Add(inttostr(Temprow))
      end
  end
  else
  begin
     for Temprow := StringGrid1.Selection.left to lastColClicked do
       begin
          SelectColList.Add(inttostr(Temprow))
       end
  end ;

end
else
if  keyDownV = 3 then   // Shift and Ctrl key down
begin
  //StringGrid1.Cells[2,StringGrid1.Selection.Top] := 'ShiftCtrl' ;
  if lastRowClicked <= StringGrid1.Selection.Top then
  begin
    for TempRow := lastRowClicked to StringGrid1.Selection.Top do
      begin
         if (SelectStrLst.IndexOf(inttostr(Temprow))) = -1 then
            SelectStrLst.Add(inttostr(Temprow))
      end
  end
  else
  begin
     for Temprow := StringGrid1.Selection.Top to lastRowClicked do
       begin
          if (SelectStrLst.IndexOf(inttostr(Temprow))) = -1 then
            SelectStrLst.Add(inttostr(Temprow))
       end
  end ;

   if lastColClicked <= StringGrid1.Selection.Left then
  begin
    for TempRow := lastColClicked to StringGrid1.Selection.Left do
      begin
         if (SelectColList.IndexOf(inttostr(Temprow))) = -1 then
            SelectColList.Add(inttostr(Temprow))
      end
  end
  else
  begin
     for Temprow := StringGrid1.Selection.Left to lastColClicked do
       begin
          if (SelectColList.IndexOf(inttostr(Temprow))) = -1 then
            SelectColList.Add(inttostr(Temprow))
       end
  end ;
end  ;

  // **** COPY BATCH FILE TEXT TO MEMO1 in Batch File Edit window*********
  if lastRowClicked <> StringGrid1.Selection.Top then // do not copy if same cell is selected as last time
  begin
  if StringGrid1.Objects[2,StringGrid1.Selection.Top] is TSpectraRanges Then
  begin
     if (StringGrid1.Objects[2,lastRowClicked]) is TSpectraRanges then
     begin
        TSpectraRanges(Form4.StringGrid1.Objects[2,lastRowClicked]).batchList.Clear ;
        for t1 := 0 to Form3.BatchMemo1.Lines.Count -1 do // this copies any changes in the BatchMemo1 to storage in the StringList of the previous line that was selected
        begin
         TSpectraRanges(Form4.StringGrid1.Objects[2,lastRowClicked]).batchList.Add(Form3.BatchMemo1.Lines.Strings[t1]) ;
        end ;
     end ;
     Form3.BatchMemo1.Lines := TSpectraRanges(StringGrid1.Objects[2,StringGrid1.Selection.Top]).batchList ;
     Form3.Caption :=   TSpectraRanges(StringGrid1.Objects[2,StringGrid1.Selection.Top]).batchList.filename
  end ;
  end ;


lastRowClicked :=  StringGrid1.Selection.Top ;
lastColClicked :=  StringGrid1.Selection.Left ;
//if StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top] is  TSpectraRanges then
// StatusBar1.Panels[0].Text := 'List number is:' + inttostr(TSpectraRanges(StringGrid1.Objects[XorYdata,StringGrid1.Selection.Top]).GLListNumber) ;
StatusBar1.Panels[0].Text := 'Number selected: ' + inttostr(SelectStrLst.Count) ;
Form1.FormResize(Sender) ;

end ;

 { if SelectStrLst.Count > 1 then
    Combine1.Enabled := true
  else
    Combine1.Enabled := false ;     }


end;



procedure TForm4.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
// this function is called every time a cell is selected (or reselected) and is called for every cell that
// has text or objects associated with them.
Var
  tstr : String ;
  tSR : TSpectraRanges ;
begin
  If  (Col = 0) and (Row < StringGrid1.RowCount-1) Then
   begin
     if (StringGrid1.Objects[2,Row] is TSpectraRanges) then    // repaint the spectra colour
     begin
       tSR := TSpectraRanges(StringGrid1.Objects[2,Row])  ;
       StringGrid1.Canvas.Brush.Color := TSpectraRanges(StringGrid1.Objects[2,Row]).ReturnTColorFromLineColor		 ;
       StringGrid1.Canvas.FillRect(Rect) ;
       if (round(tSR.LineColor[0] * 255) > 128) or (round(tSR.LineColor[1] * 255) > 128) or (round(tSR.LineColor[2] * 255) > 128)  then
          SetTextColor(StringGrid1.Canvas.Handle, clBlack )
       else
       SetTextColor(StringGrid1.Canvas.Handle, clWhite ) ;
       tstr :=  inttostr(Row) ;
       DrawText(StringGrid1.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
     end ;
   end ;
  If  {Col = StringGrid1.Col} (SelectColList.IndexOf(inttostr(Col)) <> -1) and (SelectStrLst.IndexOf(inttostr(Row)) <> -1) Then
   begin
      StringGrid1.Canvas.Brush.Color := clNavy		 ;
      StringGrid1.Canvas.FillRect(Rect) ;
      SetTextColor(StringGrid1.Canvas.Handle, clWhite ) ;;
      tstr :=  StringGrid1.Cells[Col,Row] ;
      DrawText(StringGrid1.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
   end
   else
   if (Col > 0)  and (Row > 0) Then
   begin
      StringGrid1.Canvas.Brush.Color := clWhite		 ;
      StringGrid1.Canvas.FillRect(Rect) ;
      SetTextColor(StringGrid1.Canvas.Handle, clBlack ) ;;
      tstr :=  StringGrid1.Cells[Col,Row] ;
      DrawText(StringGrid1.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
   end  ;

end;




procedure TForm4.StringGrid1MouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  SelectionCell: TGridRect;
  Rect: TRect ;
  tState1: TGridDrawState ;
begin

  StringGrid1.Cursor :=  crDrag ;
  StringGrid1.MouseToCell(X, Y,  mouse_downCOL, mouse_downROW ) ;
  Rect.Left :=  mouse_downCOL ;
  Rect.Right :=  mouse_downCOL ;
  Rect.top :=  mouse_downROW ;
  Rect.bottom :=  mouse_downROW ;

  if Button = mbRight then
  begin
    SelectionCell.Left :=  mouse_downCOL ;
    SelectionCell.Right :=  mouse_downCOL ;
    SelectionCell.top :=  mouse_downROW ;
    SelectionCell.bottom :=  mouse_downROW ;
    StringGrid1.Selection :=  SelectionCell ;   // this does not select
    StringGrid1DrawCell(nil,mouse_downCOL,mouse_downROW,Rect,tState1) ;
    PopupMenu1.Popup(Form4.Left+X,Form4.Top+Y+50)
  end
  else
  begin
    // This determines which cell was selected
    mouseDownBool := true ;
  end ;
end;




procedure TForm4.StringGrid1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
// implements drag and drop of TSpectraRanges
var
     t1 : integer ;
     top_row : integer ;
//     mouse_UpCol, mouse_UpRow : Longint ; // returned by MouseToCell() function
     tSR, newSR : TSpectraRanges ;
     tStr : string ;
     selectedRowNum : integer ;
begin

try
 // This determines which cell was selected
  StringGrid1.MouseToCell(X, Y,  mouse_UpCol, mouse_UpRow ) ;
  // these are the new row/col selected
  StringGrid1.Cursor :=  crDefault ;
  SelectStrLst.SortListNumeric ;

  if (StringGrid1.Objects[mouse_UpCol, mouse_UpRow] = nil) and (mouse_UpRow <> 0)  then  // column is empty
  begin
   for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
   begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (StringGrid1.Objects[mouse_downCOL, {selectedRowNum} mouse_downROW]) is  TSpectraRanges then
   begin
     // if mouse_downCOL =  mouse_UpCol then
     //   tSR := TSpectraRanges(StringGrid1.Objects[mouse_downCOL, selectedRowNum {mouse_downROW}])
     // else  }
      tSR := TSpectraRanges(StringGrid1.Objects[mouse_downCOL, selectedRowNum {mouse_downROW}])  ;

      // **** this makes new TSpectraRanges object and adds new line to StringGrid1 *****
      if mouse_UpRow = Form4.StringGrid1.RowCount-1 then  // add to empty row
      begin
        DoStuffWithStringGrid('', mouse_UpCol, 1, 1, true, mouse_UpRow ) ;
        newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[mouse_UpCol, mouse_UpRow ]) ;
      end
      else  // NOT LAST ROW
      begin
        DoStuffWithStringGrid('', mouse_UpCol, 1, 1, false,  mouse_UpRow)  ;  // false => DO NOT ADD LINE
        newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[mouse_UpCol, mouse_UpRow ]) ;
      end ;
      newSR.GLListNumber := 0 ;
      newSR.CopySpectraObject(tSR) ;
 {     if tStr.fft.dtime  <> 0 then  // copy fourier stuff if it exists
            newSR.fft.CopyFFTObject(tStr.fft) ;    }
      newSR.SGDataView := nil ;  // this is done in CopySpectraObject
      newSR.GLListNumber := Form4.GetLowestListNumber ;


      if (mouse_UpCol = 3) and (UpperCase(newSR.columnLabel) = 'X DATA') Then
        newSR.columnLabel := 'Y Data'  ;


      tStr  := '' ;
      tStr  :=  copy(StringGrid1.Cells[1, selectedRowNum ],1,pos(extractfileext(StringGrid1.Cells[1, selectedRowNum ]),StringGrid1.Cells[1, selectedRowNum ])-1) +'_'+ tStr + extractfileext(StringGrid1.Cells[1, selectedRowNum ])  ;
      newSR.xCoord.Filename :=  tStr ;

      if  tSR.yCoord.numRows > 1 then
        Form4.StringGrid1.Cells[mouse_UpCol, mouse_UpRow ] := '1-'+inttostr(newSR.yCoord.numRows)+':'+'1-'+inttostr(newSR.yCoord.numCols)
      else
        Form4.StringGrid1.Cells[mouse_UpCol, mouse_UpRow ] := '1'+':'+'1-'+inttostr(newSR.yCoord.numCols) ;

      // place filename in first cell
      if Form4.StringGrid1.Cells[1, mouse_UpRow ] = '' then
        Form4.StringGrid1.Cells[1, mouse_UpRow ] := extractfilename(tSR.xCoord.Filename) ;
      if Form4.StringGrid1.Cells[1, mouse_UpRow ] = '' then   // xCoord did not have a file name
        Form4.StringGrid1.Cells[1, mouse_UpRow ] := extractfilename(newSR.xCoord.Filename) ;

    //  newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    //  newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
      ChooseDisplayType(newSR) ;

      mouse_UpRow := mouse_UpRow + 1 ;
   end ;
   end ;
  end ;
//  MessageDlg('The mouse was released in cell '+inttostr(mouse_UpCol)+ ', '+inttostr(mouse_UpRow) ,mtInformation, [mbOK], 0)  ;


  // we are clicking in another column
  if (SG1_COL <> mouse_downCOL) then
  begin
      SelectStrLst.SortListNumeric() ;
      top_row :=  strtoint(SelectStrLst.Strings[0]) ;
      top_row := SG1_ROW - top_row ;
      for t1 := 0 to SelectStrLst.Count - 1 do
      begin
        SelectStrLst.Strings[t1] := inttostr(strtoint(SelectStrLst.Strings[t1]) + top_row)  ;
      end;
      Form4.StatusBar1.Panels[0].Text := 'top_row = '+ inttostr(top_row) ;
      Form4.StatusBar1.Panels[1].Text := 'top_row = '+ inttostr(top_row) ;
  end;

  mouse_downCOL := 0 ;
  mouse_downROW := 0 ;
except
on EListError do

end ;
 StringGrid1.Refresh ;
end;




procedure TForm4.FormActivate(Sender: TObject);
begin
//Set this application to accept files dragged and dropped from Explorer
  DragAcceptFiles(Handle, True);
end;


procedure TForm4.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  If Sender is TDragObject Then Accept := True ;
end;


procedure TForm4.SaveDialog1TypeChange(Sender: TObject);
var
  tempFN : String ;
begin

      tempFN := extractfilename(SaveDialog1.filename) ;
      tempFN := copy(tempFN,1,length(tempFN)-length(ExtractFileExt(tempFN))) ;
      if (SaveDialog1.FilterIndex = 2) or (SaveDialog1.FilterIndex = 3)  then
        SaveDialog1.filename := extractfilePath(SaveDialog1.filename)+ tempFN + '.jdx'
      else
      if (SaveDialog1.FilterIndex = 4) or (SaveDialog1.FilterIndex = 5)  then
      begin
        SaveDialog1.filename := extractfilePath(SaveDialog1.filename)+ tempFN + '.csv' ;
      end ;

  //     SaveDialog1.Execute() ;


end;


procedure TForm4.ScaledXCoords1Click(Sender: TObject);
Var
  t0, t1, selectedRowNum, lastSelectedNum  : integer ;
  s1, s2, firstData, dataRange  : single ;
  tSR1, tSR2, newSR : TSpectraRanges ;
  tMat1 : TMatrix ;
begin

  SelectStrLst.SortListNumeric ;

  for t0 := 0 to SelectStrLst.Count-1 do // for each row selected
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
  // column 3 is the Y data data
  if Form4.StringGrid1.Objects[ 3 ,selectedRowNum] is  TSpectraRanges  then
  begin
  // column 2 is the X data data
  if Form4.StringGrid1.Objects[ 2 ,selectedRowNum] is  TSpectraRanges  then
  begin
    // The first row of the Y data (tSR1 = column 3)
    // will be the xCoord data for the TSpectra in the X Data column
    tSR1  :=  TSpectraRanges(Form4.StringGrid1.Objects[ 3,selectedRowNum]) ;
    // this TMatrix will hold the data wanted
    tMat1 := TMatrix.Create2(tSR1.yCoord.SDPrec,1,tSR1.yCoord.numCols) ;
    tSR1.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;
     // copy over the first row of the last TSpectra
    for t1 := 0 to tSR1.yCoord.numCols - 1 do
    begin
       tSR1.yCoord.F_Mdata.Read(s1, tSR1.yCoord.SDPrec) ;
       tMat1.F_Mdata.Write(s1, tSR1.yCoord.SDPrec)
    end;
    tSR1.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;
    // Scale data from 0 to 1 - get first and last value
    //(assumes sequential order in magnitude)

    tMat1.F_Mdata.Read(firstData, tSR1.yCoord.SDPrec) ;
    tMat1.F_Mdata.Seek(-tMat1.SDPrec,soFromEnd) ;
    tMat1.F_Mdata.Read(dataRange, tSR1.yCoord.SDPrec) ;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;
    dataRange := (dataRange - firstData) ;
    for t1 := 0 to tMat1.numCols - 1 do
    begin
       tMat1.F_Mdata.Read(s1, tSR1.yCoord.SDPrec) ;
       s1 := (s1 - firstData) / dataRange ;
       tMat1.F_Mdata.Seek(-tMat1.SDPrec,soFromCurrent) ;
       tMat1.F_Mdata.Write(s1, tMat1.SDPrec) ;
    end;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;


        tSR2  :=  TSpectraRanges(Form4.StringGrid1.Objects[2,selectedRowNum]) ;
        if tSR2.xCoord.numCols = tSR1.xCoord.numCols then // if they have the same number of columns
        begin

          // create new line in stringgrid and create TSpectraRanges object for each TSpectraRanges selected (one at a time)
          // DoStuffWithStringGrid('', 2, tSR2.yCoord.numRows, tSR2.yCoord.numCols , true, StringGrid1.RowCount-1 ) ;
          newSR :=  TSpectraRanges.Create(tSR2.yCoord.SDPrec,tSR2.yCoord.numRows, tSR2.yCoord.numCols,@tSR2.LineColor );
          // point pointer newSR to the new TSpectraRange object
          Form4.StringGrid1.Objects[4, selectedRowNum] := newSR ;
          // copy the original data
          newSR.CopySpectraObject(tSR2);

          // *********** this does the actual functionality ***************
          newSR.xCoord.F_MData.Seek(0,soFromBeginning) ;
          tMat1.F_Mdata.Seek(0,soFromBeginning) ;
          // scale the xCoord data using the values in the tMat1 matrix
          for t1 := 0 to tMat1.numCols - 1 do
          begin
            tMat1.F_Mdata.Read(s1, tSR1.yCoord.SDPrec) ;
            newSR.xCoord.F_Mdata.Read(s2, tSR1.yCoord.SDPrec) ;
            s1 := s1 * s2 ;
            newSR.xCoord.F_Mdata.Seek(-tMat1.SDPrec,soFromCurrent) ;
            newSR.xCoord.F_Mdata.Write(s1, tMat1.SDPrec) ;
          end;

          // do display and interface stuff
          newSR.GLListNumber := GetLowestListNumber ;
          if tSR2.fft.dtime  <> 0 then
            newSR.fft.CopyFFTObject(tSR2.fft) ;
          StringGrid1.Cells[4, selectedRowNum ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
          newSR.xCoord.Filename :=  'xCoord_scaled_integratedx.bin'   ;
          newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
          newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
        end ; //  if they have dsame number of columns

        tMat1.Free ;
      end;  // if it is a TSpectraRanges object
      end ; // if it is a TSpectraRanges object
   end;  // for each row selected


   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;
end;


procedure TForm4.CombineAll1Click(Sender: TObject);
var
  t1 : integer ;
  newSR : TSpectraRanges ;
  tSR   : TSpectraRanges ;
  numVars1, numVars2 : integer ;
  selectedRowNum : integer ;
  tStr : string ;
  tbool, hasImaginary : boolean ;
  tMat : TMatrix ;
begin
  tbool := true ;

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
  hasImaginary := false ;
  tSr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
  numVars1 := tSr.xCoord.numCols ;
  if tSr.yImaginary <> nil then
       hasImaginary := true ;
  for t1 := 1 to SelectStrLst.Count-1 do
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     tSr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
     numVars2 := tSr.xCoord.numCols ;
     if numVars1 <> numVars2 then
       tbool := false ;
     if tSR.yImaginary <> nil then
       hasImaginary := true ;
  end ;

  if (tbool = false) then
  begin
    MessageDlg('At least one file has a different number of variables.'#13'can not complete combine operation',mtError, [mbOK], 0)  ;
    exit ;
  end ;

  // create new line in stringgrid and create TSpectraRanges object
  DoStuffWithStringGrid('', 2, 1, numVars1, true, StringGrid1.RowCount-1 ) ;

  newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;  // this is the new combined data in new row of list

  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
  tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
  newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
  // the files to be combined are the int value of the string that are in the list.
  // Add files rows to the new TSpectraRanges object
  for t1 := 1 to SelectStrLst.Count-1 do
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
     newSR.yCoord.AddRowsToMatrix(tSR.yCoord,1,tSR.yCoord.numRows) ;
  end ;

  if hasImaginary then
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
     tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
     if newSR.yImaginary = nil then
       newSR.yImaginary := TMatrix.Create(newSR.yCoord.SDPrec div 4) ;  // create the Imaginary matrix
     if tSR.yImaginary <> nil then
       newSR.yImaginary.CopyMatrix(tSR.yImaginary) ;  // copy the first matrix
     // the files to be combined are the int value of the string that are in the list.
     // Add files rows to the new TSpectraRanges object
     for t1 := 1 to SelectStrLst.Count-1 do
     begin
        selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
        if tSR.yImaginary <> nil then
        begin
          newSR.yImaginary.AddRowsToMatrix(tSR.yImaginary,1,tSR.yImaginary.numRows) ;
        end
        else
        begin
          tMat := TMatrix.Create2(newSR.yCoord.SDPrec div 4,tSR.yCoord.numRows,tSR.yCoord.numCols) ;
          tMat.Zero(tMat.F_Mdata) ;
          newSR.yImaginary.AddRowsToMatrix(tMat,1,tMat.numRows) ;
          tMat.Free ;
        end ;
     end ;
  end ;


  newSR.xCoord.CopyMatrix(tSR.xCoord) ;

  StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
  StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'Combined.bin'   ;
  newSR.xCoord.Filename :=  'Combined.bin'   ;

  newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
  newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType ) ;


end;

procedure TForm4.CombineSelected1Click(Sender: TObject);
var
  t1, t2, t3, t4 : integer ;
  maxCols, totalRows : integer ;
  currentCols, currentRows : integer ;
  s1  : single ;
  numVarList, numSpectList : TStringList ;
  tSR, tSR2, tSR3   : TSpectraRanges ;
  rowToDisplay : TMemoryStream ;
  selectedRowNum, numSpectra : integer ;
  rowRange : string ;
  colRange : string;
  tStr     : string ;
  addedXData : boolean ;
  tMat1 : TMatrix    ;

begin

  SelectStrLst.SortListNumeric ;

  if SelectStrLst.Count >= 1 then // make sure a spectrum is selected
  begin
  try
    numVarList   :=  TStringList.Create ;
    numSpectList :=  TStringList.Create ;

    for t1 := 0 to SelectStrLst.Count-1 do  // 1. count the number of variables in each spectraRange
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      if TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
      numVarList.Add(inttostr(tSR.yCoord.numCols))  ;
    end ;

    for t1 := 0 to SelectStrLst.Count-1 do  // 2. count number of spectra selected in each spectraRange selected
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      rowToDisplay := TMemoryStream.Create ;

      if TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR 
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

      rowRange := '' ;
      if tSR.SGDataView <> nil then
        rowRange := tSR.SGDataView.RowStrTextTB.Text ;  //2.1 these are the selected spectra out of a group

      if trim(rowRange) = '1-' then                      //2.2 otherwise, all the spectra are considered selected
        rowRange := rowRange + inttostr(tSR.yCoord.numRows)
      else
      if trim(rowRange) = '' then
        rowRange := '1-' + inttostr(tSR.yCoord.numRows) ;

      numSpectra := tSR.yCoord.GetTotalRowsColsFromString(rowRange,rowToDisplay) ;  // rowToDisplay is a TMemoryStream ;
      numSpectList.Add(inttostr(numSpectra))  ;
      rowToDisplay.Free ;
    end ;



    maxCols := 0 ;
    for t1 := 0 to  SelectStrLst.Count-1 do
    begin
      if strtoint(numVarList.Strings[t1])  > maxCols then
        maxCols :=  strtoint(numVarList.Strings[t1]) ;
    end ;

    totalRows := 0 ;
    for t1 := 0 to  SelectStrLst.Count-1 do
    begin
        totalRows := totalRows + strtoint(numSpectList.Strings[t1]) ;
    end ;



    DoStuffWithStringGrid('', 2, 0, maxCols, true, StringGrid1.RowCount-1 ) ;
    tSR2 :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;  // this is the new combined data in new row of list

     // 4. place data in new TSpectraRange
    for t1 := 0 to SelectStrLst.Count-1 do
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;

      if (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage) or (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).nativeImage ) then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
        
      rowRange := '' ;
      if tSR.SGDataView <> nil then
        rowRange := tSR.SGDataView.RowStrTextTB.Text ;

      currentRows :=  strtoint(numSpectList.Strings[t1]) ;
      currentCols :=  strtoint(numVarList.Strings[t1])   ;

      if trim(rowRange) = '1-' then
        rowRange := rowRange + numSpectList.Strings[t1]
      else
      if trim(rowRange) = '' then
        rowRange := '1-' + numSpectList.Strings[t1] ;

      colRange := '1-' + numVarList.Strings[t1] ;

      tSR3 := TSpectraRanges.Create(tSR.xCoord.SDPrec div 4, currentRows,  currentCols ,  nil) ;
      tSR3.yCoord.FetchDataFromTMatrix(rowRange, colRange, tSR.yCoord ) ;


      if tSR3.yCoord.numCols < tSR2.yCoord.numCols then  // Add extra columns to the tSR3 so that it matches the largest one present in list
      begin
         tSR3.Transpose ;
         tMat1 := TMatrix.Create2(tSR3.yCoord.SDPrec,1,(tSR3.yCoord.numCols)) ;
         tMat1.Zero(tMat1.F_Mdata);
         for t2 := 1 to (tSR2.yCoord.numCols-tSR3.yCoord.numRows) do
         begin
          // tSR3.yCoord.AddVectToMatrixRows(rowToDisplay)
            tSR3.yCoord.AddRowToEndOfData(tMat1,1,tMat1.numCols);
         end;
         tMat1.Free ;
         tSR3.Transpose ;
      end;

      // ****  This does the adding part to the combined tSpectraRange ****
      tSR2.yCoord.AddRowsToMatrix(tSR3.yCoord,1,currentRows) ;

      tSR3.Free ;
    end ;

    // make sure XCoord data is possibly correct
    t1 := 0 ;
    addedXData := false ;
    while  addedXData = false do
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      if (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage) or (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).nativeImage ) then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

      if tSR.yCoord.numCols = tSR2.yCoord.numCols then
      begin
         tSR2.xCoord.CopyMatrix(tSR.xCoord);
      end;
      addedXData := true ;
      inc(t1) ;
    end;


  finally
    numVarList.Free ;
    numSpectList.Free ;
  end ;


  StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(tSR2.yCoord.numRows)+' : '+'1-'+inttostr(tSR2.yCoord.numCols) ;
  StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'Combined.bin'   ;
  tSR2.xCoord.Filename :=  'Combined.bin'   ;

  tSR2.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
  tSR2.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType ) ;



  end ;

  Form1.refresh ;



end;

procedure TForm4.Selected2Click(Sender: TObject);
var
  t1, t2 : integer ;
  s1 : single ;
  tStr : string ;
  tSR, newSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tempStream : TMemoryStream ;
begin
try
  tempStream := TMemoryStream.Create ;
  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        // this is the file to be split up into scatter plots
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

     end;
  end;

  if not Form4.CheckBox7.Checked then
  Form1.UpdateViewRange() ;
  Form1.Refresh ;

finally
   tempStream.Free ;
end;

end;

procedure TForm4.FormResize(Sender: TObject);
begin
      StringGrid1.Height :=  Form4.Height - (Panel1.Height+65) ;
end;


Function TForm4.GetOrthoVarValues(NumRows : Integer) : TGLRangeArray  ;// OVXMax,OVXMin,OVYMax,OVYMin : GLFloat
Var
  TempInt1 : Integer ;
  TempXMax, TempXMin, TempYMax, TempYMin : GLFloat ;
  Temp2XMax, Temp2XMin, Temp2YMax, Temp2YMin : GLFloat ;
begin
  TempXMin := Math.MaxSingle ;
  TempXMax := Math.MinSingle ;
  TempYMin := Math.MaxSingle ;
  TempYMax := Math.MinSingle ;
  For TempInt1 := 1 to (NumRows) Do
  begin
    if Form4.StringGrid1.Objects[2,TempInt1] <> nil then    // 1 changed to 2 xxxx
    begin
      With Form4.StringGrid1 Do
      begin
        Temp2XMin := TSpectraRanges(Objects[2,TempInt1]).XLow  ;
        Temp2XMax := TSpectraRanges(Objects[2,TempInt1]).XHigh ;
        Temp2YMin := TSpectraRanges(Objects[2,TempInt1]).YLow  ;
        Temp2YMax := TSpectraRanges(Objects[2,TempInt1]).YHigh ;
        {
         Temp2XMin := TSpectraRanges(Objects[1,TempInt1]).XLow - (30*WidthPerPix1)  ;
        Temp2XMax := TSpectraRanges(Objects[1,TempInt1]).XHigh    ;
        Temp2YMin := TSpectraRanges(Objects[1,TempInt1]).YLow - (41*HeightPerPix1) ;
        Temp2YMax := TSpectraRanges(Objects[1,TempInt1]).YHigh + (5*HeightPerPix1) ;
        }
      end ;
      If Temp2XMin < TempXMin Then TempXMin := Temp2XMin ;
      If Temp2XMax > TempXMax Then TempXMax := Temp2XMax ;
      If Temp2YMin < TempYMin Then TempYMin := Temp2YMin ;
      If Temp2YMax > TempYMax Then TempYMax := Temp2YMax ;
    end ;
  end ;

  Result[0] := TempXMax  ;
  Result[1] := TempXMin  ;
  Result[2] := TempYMax  ;
  Result[3] := TempYMin  ;

end ;

procedure TForm4.StringGrid1SelectCell(Sender: TObject; Col, Row: Integer;
  var CanSelect: Boolean);
var
  SelectionCell: TGridRect;
begin
     SG1_ROW :=  Row ;
     SG1_COL :=  Col ;
     originalText := StringGrid1.Cells[Col,Row] ;
end;


procedure TForm4.InitialiseDataGrid ;
// The data grid once initialised allows for data viewing, selection, modification etc.
var
  tSR1 : TSpectraRanges ;
  caption : string ;
begin
    if (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]) <> nil) and (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]).SGDataView = nil) then
    begin
      tSR1 := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]) ; // assign object to pointer

      // **** Create form with string grid *****
      Application.CreateForm(TSGDataView, tSR1.SGDataView);
      caption := 'Row ' + inttostr(SG1_ROW)+ ': '  + copy(stringGrid1.Cells[ SG1_COL , 0],1,length(stringGrid1.Cells[ SG1_COL , 0])-1) ; // + ExtractFilename(tSR1.xCoord.Filename) ;
      tSR1.FillDataGrid(SG1_ROW, SG1_COL, caption) ;

    end   // TSpectraRanges(Form4.StringGrid1.Objects[1,SG1_ROW])  <> nil
    else
    begin
      if (Form4.StringGrid1.Objects[SG1_COL,SG1_ROW] <> nil) then
        if  (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]).SGDataView <> nil) then
        begin
          TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]).SGDataView.Visible := false ;
          TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]).SGDataView.Visible := true ;
        end ;
    end ;
end ;


procedure TForm4.StringGrid1DblClick(Sender: TObject);
// **** Creates a new StringGridDataViewer and fills in data in string grid *****
begin
  if (SG1_COL = 1) and not (StringGrid1.Objects[2,SG1_ROW] is TSpectraRanges) then  // click on 'filename:' and open dialog appears
  begin
     Form4.Open1Click(Sender) ;
  end
  else
  if ((SG1_COL = 2) or (SG1_COL = 3)) and not (StringGrid1.Objects[SG1_COL,SG1_ROW] is TSpectraRanges) then
  // click on 'X data:' or 'Y Data:' open dialog appears if SG.Object not TSpectraRange object
  begin
     Form4.Open1Click(Sender) ;
  end
  else
  if (SG1_COL >= 2) and (StringGrid1.Objects[SG1_COL,SG1_ROW] is TSpectraRanges) then
  // click on 'X data:' or 'Y Data:' etc creates and fills a new form with the data of the TSpectraRange object
  begin
     InitialiseDataGrid
  end
  else
  if SG1_COL = 4 then   // "analysis" cell selected so open batch file text box viewer
  begin
     Form3.Visible := true ;
  end
end;


procedure TForm4.Open1Click(Sender: TObject);
begin
  Form4.OpenDialog1.Title := 'Open spectral file' ;
  Form4.OpenDialog1.Filter := 'binary (*.bin)|*.bin|comma delimited (*.csv, *.txt, *.asc)|*.txt;*.csv;*.asc|omnic spectral files (*.spa)|*.spa|GRAMS SPC (*.spc)|*.spc|JCAMP (*.dx, *.jdx)|*.dx,*.jdx|raw (*.raw)|*.raw|all files (*.*)|*.*' ;
  Form4.OpenDialog1.DefaultExt := lastFileExt ;   // '*.bin' ;
  Form4.OpenDialog1.filename :=  {'*'+} lastFileExt ; // '*.bin' ;
  if Sender = Open1 then  // if true then MainMenu 'Open' item sent message and only open X Data
  begin
    SG1_COL := 1 ;  // do this so we can confirm that the Open1 Menu item was selected and cells were not double clicked
    StringGrid1.Col := 1 ;
  end ;

  if  not ((SG1_COL = 3) and (SG1_ROW = StringGrid1.RowCount-1)) then // make sure Y data column not selected with empty X data on last enpty row
  begin
    StringGrid1.Options := [goFixedVertLine,goFixedHorzLine,goVertLine,goHorzLine,goColSizing,goTabs,goThumbTracking] ; // disallow editing
    StringGrid1.Refresh ;
    With Form4.OpenDialog1 do
    begin
      If Execute Then
      begin
        InitializeSpectraData(TStringList(Files), Files.Count) ;
        // SetCurrentDir(ExtractFilePath(filename));
        SaveDialog1.InitialDir :=  ExtractFilePath(OpenDialog1.filename) ;
        OpenDialog1.InitialDir :=  ExtractFilePath(OpenDialog1.filename) ;
      end ;
    end ;
  end ;
  Form2.CheckListBox1Click(Sender) ; // Set best Y scale for reference lines

  Form1.FormResize(Sender) ;
  Form1.Refresh;
 // Form2.SpeedButton1Click(Sender) ; // Reset button - displays full x,y data range
end;



procedure TForm4.StringGrid1SetEditText(Sender: TObject; ACol,  ARow: Integer; const Value: String);
// OnSetEditText does not occur unless the Options property includes goEditing
// checks that data range input is of correct format
// numeric, "-" or "," e.g.   "1,3,10-17,21"
// This function is called on every key press so each entry is tested and is removed if not of correct format.
var
  okay : boolean ;
  colonPos : integer ;
  rowStr, colStr : string ;
begin
   if  ((SG1_COL = 2) or (SG1_COL = 3)) and (SG1_ROW < Form4.StringGrid1.RowCount -1) then
   begin
     colonPos := pos(':',StringGrid1.Cells[ACol,ARow]) ;
     if colonPos > 0 then
     begin
       rowStr := copy(StringGrid1.Cells[ACol,ARow],1,colonPos-1) ;
       colStr := copy(StringGrid1.Cells[ACol,ARow],colonPos+1,length(StringGrid1.Cells[ACol,ARow])-colonPos) ;

       okay := TSpectraRanges(Form4.StringGrid1.Objects[2,SG1_ROW]).XCoord.CheckRangeInput(rowStr) ;
       if okay then
         okay := TSpectraRanges(Form4.StringGrid1.Objects[2,SG1_ROW]).XCoord.CheckRangeInput(colStr)
       else
       begin
         StringGrid1.Cells[ACol,ARow] := originalText  ;
         okay := true ;
       end ;
       if not okay then  // copy all but last inputted character (which was not the correct format)
         StringGrid1.Cells[ACol,ARow] := originalText  ;


     end
     else //  colonPos = 0 so no colon in string
     begin

       okay := TSpectraRanges(Form4.StringGrid1.Objects[2,SG1_ROW]).XCoord.CheckRangeInput(StringGrid1.Cells[ACol,ARow]) ;
       if not okay then  // copy all but last inputted character (which was not the correct format)
         StringGrid1.Cells[ACol,ARow] := originalText ;

     end ;
   end ;
end;



procedure TForm4.Exit1Click(Sender: TObject);
begin
 Form4.Close ;
end;

procedure TForm4.Copy1Click(Sender: TObject);
Var
  Source1, Dest1 : TRect ;
begin
  Form1.Image1.Canvas.Create ;
  Form1.Image1.Picture.Bitmap.Canvas.Create ;

  Source1.Left := 0 ;
  source1.Top := 0 ;
  Source1.Bottom := Form1.Image1.Height ;
  source1.Right := Form1.Image1.Width ;

  Dest1.Left := 0 ;
  Dest1.Top := 0 ;
  Dest1.Bottom := Form1.Image1.Height ;
  Dest1.Right := Form1.Image1.Width ;

  Form1.Image1.Picture.Bitmap.Canvas.CopyRect(Dest1,Form1.Canvas,source1) ;

  Clipboard.Assign(Form1.Image1.Picture.Bitmap) ;

  Form1.Image1.Visible := False ;
  Form1.refresh ;
end;

procedure TForm4.Background1Click(Sender: TObject);
begin
  Form2.visible := true ;    
end;

procedure TForm4.Font1Click(Sender: TObject);
begin
  If FontDialog1.Execute Then
  begin
    ActivateRenderingContext(Canvas.Handle,RC);
      glDeleteLists(1,256) ;
      FontName := FontDialog1.Font.Name ;
      FontSize := FontDialog1.Font.Size ;
      Form1.BuildOutLineFont(FontName, FontSize);
    wglMakeCurrent(0,0); // another way to release control of context
    MouseArrayX[0]:= 0;
    MouseArrayY[0] := 0;
    MouseArrayX[1] := 0;
    MouseArrayY[1] := 0;
    FormResize(Sender) ;
    Refresh;
  end ;
end;

procedure TForm4.Batch1Click(Sender: TObject);
begin
  Form3.Visible := true ;
end;


function TForm4.GetLowestListNumber : Integer ;
Var
  theListNum, t1, t2 : Integer ;
  flag : Bool ;
Begin //********* finds lowest number not already used as a GLListNumber
{  theListNum := 258 ; // this is the known lowest number (=259)
  flag := false ;

  while (flag = false) do
  begin
    flag := true ;
    inc(theListNum) ;
    t1 := 1 ;
    while (t1 < StringGrid1.RowCount) and (flag) do
    begin
      t2 := 1 ;
      while (t2 < StringGrid1.ColCount) and (flag) do
      begin
        if StringGrid1.Objects[t2,t1] is TSpectraRanges then
        begin
         if (TSpectraRanges(StringGrid1.Objects[t2,t1]).GLListNumber) = theListNum then
           flag := false ;
        end ;
        inc(t2) ;
      end ;
      inc(t1) ;
    end ;
  end ;  // while flag=false


  Result := theListNum ;   }

  inc(maxList) ;
  Result := maxList ;

//  StatusBar1.Panels[0].Text := inttoStr(theListNum) ;
End ; //***********



// called within InitilizeSpectraData()
// ***  Creates the new TSpectraRanges object ***
procedure TForm4.DoStuffWithStringGrid(filename : String; XorYMatrix, numRows, numCols : integer; addLineToStrGrid : boolean; addToRow : integer) ;
// XorYMatrix = 2 if X data; 3 if Y data (i.e. for regression); 5 if scores ;  if EVects ; 7 eigenvals ; 8 if residuals etc
Var
   GR : TGridRect ;
   stringNum, t1 : integer ;
   LineColor : TGLLineColor ;
   tStr : string ;
begin

  With Form4.StringGrid1 Do
    begin
      if  addLineToStrGrid then // new X data added into column #2
      begin
        // determine colour format
        stringNum := Form4.StringGrid1.RowCount - 1   ;
        while  stringNum >= IntensityList.Count do
        stringNum :=  stringNum - IntensityList.Count ;

        // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
        tStr := IntensityList.Strings[stringNum] ;
        tStr := TrimLeft(copy(tStr,Pos(' ',tStr)+1,Length(tStr))) ;
       // tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        LineColor[0] := StrToFloat(copy(tStr,1,t1-1)) ;
        tStr := copy(tStr,t1+1,Length(tStr)) ;
        tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        LineColor[1] := StrToFloat(copy(tStr,1,t1-1)) ;
        tStr := copy(tStr,t1+1,Length(tStr)) ;
        tStr := TrimLeft(tStr) ;
        t1 := Pos(' ', tStr) ;
        LineColor[2] := StrToFloat(copy(tStr,1,t1-1)) ;
       end
       else   // Not new line in stringGrid - get colour from adjacent spectra
       begin
          // line colour of Y Data is same as for X data (if it exists)
          if  (StringGrid1.Objects[2, addToRow]) is  TSpectraRanges then
           LineColor := TSpectraRanges(Objects[2,addToRow]).LineColor
         else
         if  (StringGrid1.Objects[3, addToRow]) is  TSpectraRanges then
           LineColor := TSpectraRanges(Objects[3,addToRow]).LineColor  ;
       end ;
       // end of determining spectra display line colour

      // Now create the TSpectraRanges object
      if  addLineToStrGrid then // new X data added into column #2
      begin
        Objects[XorYMatrix,Form4.StringGrid1.RowCount-1] := TSpectraRanges.Create(1,numRows,numCols, @LineColor)  ; // Create spectra object
        if (Objects[2,Form4.StringGrid1.RowCount-2] is TSpectraRanges) and (Objects[1,Form4.StringGrid1.RowCount-2] = nil) then
        begin
          TSpectraRanges(Objects[XorYMatrix,Form4.StringGrid1.RowCount-1]).GLListNumber := GetLowestListNumber ;
        end
        else
        begin
          t1 := GetLowestListNumber ; // gets lowest GLListNumber
          TSpectraRanges(Objects[XorYMatrix,Form4.StringGrid1.RowCount-1]).GLListNumber := t1 ;
        end ;
        TSpectraRanges(Objects[XorYMatrix,Form4.StringGrid1.RowCount-1]).xCoord.Filename := filename ;
        Cells[1,Form4.StringGrid1.RowCount-1] := ExtractFileName(filename) ;  // place "filename" in string grid box
        Form4.StringGrid1.RowCount := Form4.StringGrid1.RowCount + 1 ;  // add extra line to stringgrid1 ;
      end
      else // addLineToStrGrid = false
      begin
         Objects[XorYMatrix,addToRow] := TSpectraRanges.Create(1,numRows,numCols, @LineColor)  ; // Create spectra object
         t1 := GetLowestListNumber ; // gets lowest GLListNumber
         TSpectraRanges(Objects[XorYMatrix,addToRow]).GLListNumber := t1 ;
         TSpectraRanges(Objects[XorYMatrix,addToRow]).xCoord.Filename := filename ;
      end ;

      //  select the spectra just created
      if addLineToStrGrid then  // new X data matrix
      begin
        GR.Top    := RowCount - 2 ;
        GR.Bottom := RowCount - 2 ;
      end
      else  // adding TSpectraRange to columns in StringGrid1
      begin
        GR.Top    := addToRow - 1 ;
        GR.Bottom := addToRow - 1 ;
      end ;
      GR.Left   := XorYMatrix ;
      GR.Right  := XorYMatrix ;
      StringGrid1.Selection := GR ;    // select currently loaded file in stringlist
    end ;
end ;


procedure TForm4.ReduceTIFF(tSRIn : TSpectraRanges; factor: Integer; aveOrSkip: AverageOrSkip) ;
var
  t1 : integer ;
  tMat1 : TMatrix ;
begin

    if (factor mod 2) <> 0 then exit ;


  if aveOrSkip = average then
  begin
    while factor <> 1 do  // for each spectra in list
    begin
      if (tSRIn.yCoord.numCols mod 2) <> 0 then exit ;

      tMat1 := tSRIn.yCoord.AverageReduce(2, Cols) ;
      tSRIn.yCoord.CopyMatrix(tMat1) ;
      tMat1.Free ;

      if (tSRIn.yCoord.numRows mod 2) <> 0 then exit ;

      tMat1 := tSRIn.yCoord.AverageReduce(2, Rows) ;
      tSRIn.yCoord.CopyMatrix(tMat1) ;
      tMat1.Free ;

      factor := factor div 2 ;
    end ;
  end
  else  // aveOrSkip = skip
  begin
      if (tSRIn.yCoord.numCols mod factor) <> 0 then exit ;

      tMat1 := tSRIn.yCoord.Reduce(factor, Cols) ;

      tSRIn.yCoord.CopyMatrix(tMat1) ;
      tMat1.Free ;

      if (tSRIn.yCoord.numRows mod factor) <> 0 then exit ;

      tMat1 := tSRIn.yCoord.Reduce(factor, Rows) ;
      tSRIn.yCoord.CopyMatrix(tMat1) ;
      tMat1.Free ;
  end;
end;


procedure TForm4.Revert1Click(Sender: TObject);
var
  t1, t2, selectedRowNum : integer ;
  tSR, tSR2 : TSpectraRanges ;

begin

  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;
      if lowercase(extractfileext(tSR.yCoord.Filename)) = '.bin' then
      begin
        tSR2 := TSpectraRanges.Create(tSR.yCoord.SDPrec,1,1,@tSR.LineColor) ;
        tSR2.LoadSpectraRangeDataBinV2(tSR.yCoord.Filename);
        tSR.CopySpectraObject(tSR2) ;

        tSR.GLListNumber := Form4.GetLowestListNumber ;
        if (tSR.lineType > MAXDISPLAYTYPEFORSPECTRA) or (tSR.lineType < 1)  then tSR.lineType := 1 ;  //
          tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  tSR.lineType )   ;
          tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
      end;
   end ;

  end ;  // for each file selected

  form1.Refresh ;

end;


// called by TForm1.wmDropFiles(), TForm4.wmDropFiles() and  TForm4.Open1Click()
// loads the spectral data, dependent upon file extension
Procedure TForm4.InitializeSpectraData(files : TStringList; numSpectra : integer ) ;
Var
 TempRow, t1, currentFile, numSubFiles, numPoints, lineNum, headerSize : Integer ;
 success : bool ;
 tStrList : TStringList ;
 tSR : TSpectraRanges ;
 firstXVal_, XstepVal : single ;
 tMat : TMatrix ;
 s1 : single ;
 d1 : double ;
 XorYMatrixData, rowNumber, initialRowNum : integer ;
 spcRead : ReadWriteSPC ;
 ReturnVal : integer ;
 tTIFFIn : TTiffReadWrite ;
 aveOrSkip: AverageOrSkip ;

Begin



  if Form2.RBXData.Checked then
  begin
     XorYMatrixData := 2  ;  // load X Data in column 2 (=3)
     rowNumber :=  StringGrid1.RowCount -1 ;
  end
  else  if Form2.RBYData.Checked then
  begin
     XorYMatrixData := 3  ;  // load X Data in column 2 (=3)
     rowNumber :=  SG1_ROW ;
  end ;

  initialRowNum :=  rowNumber ;
  

  for currentFile := 0 to numSpectra-1 do  // this opens each file given as a list in 'files' TStringList when multiple files selected or dropped on main form.
  begin
    success := true ;
    lastFileExt :=  ExtractFileExt(files.Strings[currentFile]) ;

//    form2.edit14.text := floattostr(  FileDateToDateTime(FileAge(files.Strings[currentFile]))   )  ;
    // test if file being read has been created after the current time (i.e. the system clock has been set back)
    // security feature 2 of 2
    if ((Now) < FileDateToDateTime(FileAge(files.Strings[currentFile]))) and (now <> -1)  then
    begin
       Application.Destroy ;
    end ;



    if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.SPA') then
    begin
    //   LoadSPAFileFFT(TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.RowCount-2]))
        if  XorYMatrixData = 2 then
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, true, initialRowNum + currentFile )
        else
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, false, initialRowNum + currentFile) ;
        LoadSPAFileFloat(TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,Form4.StringGrid1.RowCount-2])) ;
        TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,Form4.StringGrid1.RowCount-2]).xString :=   Form2.Edit30.Text ;
        numSubFiles := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,Form4.StringGrid1.RowCount-2]).yCoord.numRows ;

    end
    else if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.DX') or ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.JDX') then
    begin
        try
        tStrList := TStringList.Create ;
        tStrList.LoadFromFile(files.Strings[currentFile]) ;
        numSubFiles := GetNumJDXSubFiles(tStrList) ;
        headerSize := GetJDXHeaderSize(tStrList, '##XYDATA=', lineNum) ; // this is the number of lines past the current line number (lineNum) to the data of interest
        if headerSize = 0 then
        begin
          headerSize := GetJDXHeaderSize(tStrList, '##XYPOINTS=', lineNum) ;
          if headerSize = 0 then
            Exit ;
        end ;
        numPoints :=  strtoint( GetJDXHeaderData('##NPOINTS=', tStrList, headerSize, lineNum)  );
        if  XorYMatrixData = 2 then
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,numSubFiles,numPoints, true, SG1_ROW)
        else
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,numSubFiles,numPoints, false, SG1_ROW) ;
         // linePos usefull so do not have to read in all previous line data
        lineNum := 0 ;
        for t1 := 1 to numSubFiles do
        begin
          tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;
          // function LoadJDXFile(SpectObj : TSpectraRanges; tStrList : TStringList; numFiles, numPoints, whichFile, lineNum : integer) : integer ;
          lineNum := LoadJDXFile(tSR, tStrList, numSubFiles, numPoints, t1, lineNum) ;
        end ;
        finally
          tStrList.Free ;
        end ;

        tSR.xString := Form2.Edit30.Text ;
    end
    else if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.SPC') then
    begin


        if  XorYMatrixData = 2 then
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, true, SG1_ROW)
        else
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, false, SG1_ROW) ;

        tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;

        spcRead :=  ReadWriteSPC.Create ;
        numSubFiles :=  spcRead.ReadSPCDataIntoSpectraRange(tSR.xCoord.Filename, tSR) ;
        spcRead.Free ;
        
        tSR.xString := Form2.Edit30.Text ;
        ChooseDisplayType(tSR) ;

     //  success := LoadSPCXrayFile(TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,Form4.StringGrid1.RowCount-2])) ;
    end
    else if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.BIN') then
    begin  // Load Y data from binary file + Calculate x data with 'file import' details
       // create TSpectraRange in TStringGrid
       if Form2.RBXData.Checked then  // load into X matrix
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, true, SG1_ROW)     // X Matrix data
       else  // load into Y matrix
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, false, SG1_ROW) ; // Y Matrix data

       // Load Row data from binary file
       tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;

       tSR.LoadSpectraRangeDataBinV2(tSR.xCoord.Filename) ;
       numSubFiles := tSR.yCoord.numRows ;

       Form2.NumColsEB1.Text := inttoStr(tSR.yCoord.numCols) ;
       Form2.NumRowsEB1.Text := inttoStr(tSR.yCoord.numRows) ;

       if  tSR.xCoord.F_Mdata.Size = 0 then  // DoStuffWithStringGrid() above has 1 row with 0 columns
       begin                                 // LoadSpectraRangeDataBinV2() will fill xCoord if file type is 'v2'
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         numSubFiles := tSR.yCoord.numRows ;
         // Calculate x data using 'file import' details
         firstXVal_ := strtofloat( Form2.Edit29.Text ) ;
         XstepVal   := strtofloat( Form2.Edit16.Text ) ;
         tSR.xCoord.ClearData(tSR.xCoord.SDPrec div 4) ;
         tSR.xCoord.numCols := tSR.yCoord.numCols ;   // y data determines number of x data points
         tSR.xCoord.numRows := 1 ;
         tSR.xCoord.F_Mdata.SetSize(tSR.xCoord.numCols*tSR.xCoord.SDPrec) ;
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         for t1 := 0 to tSR.xCoord.numCols-1 do
         begin
            if tSR.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              tSR.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              tSR.xCoord.F_Mdata.Write(d1,8) ;
            end ;

         end ;
       end ;
       tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;


       ChooseDisplayType(tSR) ;
       tSR.xString := Form2.Edit30.Text ;

    end
    else if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.TIF') then
    begin  // Load Y data from TIFF file (see http://partners.adobe.com/public/developer/en/tiff/TIFF6.pdf)

         // this reads in TIFF file 'Image file directory'
         tTIFFIn := TTiffReadWrite.Create2(files.Strings[currentFile]) ;

         // load data as square image
         if  XorYMatrixData = 2 then   // sets up filename but does not load file data
            //                  (filename : String;           XorYMatrix,     numRows,    numPoints : integer;     addLineToStrGrid : boolean; addToRow : integer) ;
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData, tTIFFIn.ImageLength,tTIFFIn.ImageWidth, true, SG1_ROW)
         else
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,tTIFFIn.ImageLength,tTIFFIn.ImageWidth, false, SG1_ROW) ;

         // LOAD TIFF DATA INTO NEW TSpectraRange object
         tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;
         tTIFFIn.CopyData(tSR.yCoord.F_Mdata,tSR.yCoord.SDPrec );
         if tTIFFIn.byteOrder = 1 then  // if tiff file is from a mac (or imageJ) then bytes are reversed
           tSR.yCoord.ReverseByteOrder ;
         tTIFFIn.Free ;

         // Determine average data or skip data for ReduceTIFF() procedure
         if pos('ave',lowerCase(Form2.ScaleImageEditBox1.text)) >= 1 then
            aveOrSkip := average
         else
            aveOrSkip := skip ;

         if pos(',',Form2.ScaleImageEditBox1.text) = 0 then
            Form2.ScaleImageEditBox1.text := Form2.ScaleImageEditBox1.text + ',' ;

         ReduceTIFF(tSR, strtoint(copy(Form2.ScaleImageEditBox1.text,1,pos(',',Form2.ScaleImageEditBox1.text)-1 ))  , aveOrSkip) ;


        // the above code opens all tiff files as 2D files to allow the ReduceTiff code to work properly (i.e. in 2D)
        // This now changes data structures to indicate data is linear array vector
         if Form2.Not2DdataRB.Checked then // form back into single vector (not 2D after this)
         begin
           tSR.yCoord.numCols :=  tSR.yCoord.numCols * tSR.yCoord.numRows ;
           tSR.yCoord.numRows :=  1 ;
           tSR.nativeImage := false ;
           tSR.frequencyImage := false ;
         end ;

         Form2.NumColsEB1.Text := inttoStr(tSR.yCoord.numCols) ;
         Form2.NumRowsEB1.Text := inttoStr(tSR.yCoord.numRows) ;

         tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

         numSubFiles := 1 ; // tSR.yCoord.numRows ;  // used for string grid text display
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         firstXVal_ := 0.0 ;
         XstepVal   := strtofloat( Form2.PixelSpaceX_EB.Text ) ;
         tSR.xCoord.ClearData(tSR.xCoord.SDPrec div 4) ;
         tSR.xCoord.numCols := tSR.yCoord.numCols ;   // y data determines number of x data points
         tSR.xCoord.numRows := 1 ;
         tSR.xCoord.F_Mdata.SetSize(tSR.xCoord.numCols*tSR.xCoord.SDPrec) ;
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         for t1 := 0 to tSR.xCoord.numCols-1 do
         begin
            if tSR.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              tSR.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              tSR.xCoord.F_Mdata.Write(d1,8) ;
            end ;
         end ;

         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

         ChooseDisplayType(tSR) ;
         tSR.xString := Form2.Edit30.Text ;    // type and units of x coordinate
       end  // Form2.IsNative2DdataRB.Checked



    else if ( UpperCase(ExtractFileExt(files.Strings[currentFile])) = '.RAW') then  // MVA = Multi Variate Analysis
    begin  //

      if Form2.IsNative2DdataRB.Checked then
      begin
         if  XorYMatrixData = 2 then   // sets up filename but does not load file data
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData, strtoint(Form2.ImageNumberTB1.Text) *  strtoint(Form2.NumRowsEB1.Text),strtoint(Form2.NumColsEB1.Text), true, SG1_ROW)
         else
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,strtoint(Form2.ImageNumberTB1.Text) * strtoint(Form2.NumRowsEB1.Text),strtoint(Form2.NumColsEB1.Text), false, SG1_ROW) ;

         // LOAD DATA INTO NEW TSpectraRange object
         tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;
         tSR.LoadRawData(tSR.xCoord.Filename,1,1) ;
         if Form2.SwapBytesInRAWfile.Checked then
            tSR.yCoord.ReverseByteOrder ;  // needed for ImageJ byte ordering of single precision data
         tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;


         numSubFiles := tSR.yCoord.numRows ;  // used for string grid text display
         //
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         firstXVal_ := 0.0 ;
         XstepVal   := strtofloat( Form2.PixelSpaceX_EB.Text ) ;
         tSR.xCoord.ClearData(tSR.xCoord.SDPrec div 4) ;
         tSR.xCoord.numCols := tSR.yCoord.numCols ;   // y data determines number of x data points
         tSR.xCoord.numRows := 1 ;
         tSR.xCoord.F_Mdata.SetSize(tSR.xCoord.numCols*tSR.xCoord.SDPrec) ;
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         for t1 := 0 to tSR.xCoord.numCols-1 do
         begin
            if tSR.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              tSR.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              tSR.xCoord.F_Mdata.Write(d1,8) ;
            end ;
         end ;

         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

         ChooseDisplayType(tSR) ;
         tSR.xString := Form2.Edit30.Text ;    // type and units of x coordinate
       end  // Form2.IsNative2DdataRB.Checked
       else if Form2.Not2DdataRB.Checked then
       begin
         if  XorYMatrixData = 2 then   // sets up filename but does not load file data
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData, strtoint(Form2.ImageNumberTB1.Text) *  strtoint(Form2.NumRowsEB1.Text),strtoint(Form2.NumColsEB1.Text), true, SG1_ROW)
         else
            DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,strtoint(Form2.ImageNumberTB1.Text) * strtoint(Form2.NumRowsEB1.Text),strtoint(Form2.NumColsEB1.Text), false, SG1_ROW) ;

         // LOAD DATA INTO NEW TSpectraRange object
         tSR := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]) ;
         tSR.LoadRawData(tSR.xCoord.Filename,1,1) ;
         if Form2.SwapBytesInRAWfile.Checked then
           tSR.yCoord.ReverseByteOrder ;  // needed for ImageJ byte ordering of single precision data
         tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;


         numSubFiles := tSR.yCoord.numRows ;  // used for string grid text display
         //
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         firstXVal_ := 0.0 ;
         XstepVal   := strtofloat( Form2.PixelSpaceX_EB.Text ) ;
         tSR.xCoord.ClearData(tSR.xCoord.SDPrec div 4) ;
         tSR.xCoord.numCols := tSR.yCoord.numCols ;   // y data determines number of x data points
         tSR.xCoord.numRows := 1 ;
         tSR.xCoord.F_Mdata.SetSize(tSR.xCoord.numCols*tSR.xCoord.SDPrec) ;
         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
         for t1 := 0 to tSR.xCoord.numCols-1 do
         begin
            if tSR.xCoord.SDPrec = 4 then
            begin
              s1 := firstXVal_ + (t1*XstepVal);
              tSR.xCoord.F_Mdata.Write(s1,4) ;
            end
            else
            begin
              d1 := firstXVal_ + (t1*XstepVal) ;
              tSR.xCoord.F_Mdata.Write(d1,8) ;
            end ;
         end ;

         tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

         ChooseDisplayType(tSR) ;
         tSR.xString := Form2.Edit30.Text ;    // type and units of x coordinate

       end ;
    end
    else // load text file data into  TSpectraRanges object  using 'file import' details
    begin
       if  XorYMatrixData = 2 then
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, true, SG1_ROW)
       else
          DoStuffWithStringGrid(files.Strings[currentFile],XorYMatrixData,1,0, false, SG1_ROW) ;
       
       numSubFiles := TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).LoadXYDataFile()  ; // return result is number of samples in file (= ydata.numRows)

       if numSubFiles > 0 then
         success := true
       else
         success := false ;

       TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
       TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data

       if Form4.CheckBox7.Checked = false then  // keep current perspective = false
         Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

       TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).xString := Form2.Edit30.Text ;
    end  ; // load text file data into  TSpectraRanges object  using 'file import' details


   Form2.Edit8.Text := FloatToStrf(OrthoVarYMax,ffGeneral,6,6) ;  // Max "Visible Y Range"
   Form2.Edit9.Text := FloatToStrf(OrthoVarYMin,ffGeneral,6,6) ;  // Min "Visible Y Range"
   // OpenGL drawing function data -
   EyeX := 0 ; EyeY := 0 ; CenterX := 0 ; CenterY := 0 ;

   // place text expression of data range in stringgrid1 cell in correct column (=XorYMatrixData)
   if numSubFiles > 1 then
      Form4.StringGrid1.Cells[XorYMatrixData,rowNumber] := '1-' + inttostr(numSubFiles) + ' : 1-' + inttostr(TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).xCoord.numCols)
   else
     Form4.StringGrid1.Cells[XorYMatrixData,rowNumber] := '1' + ' : 1-' + inttostr(TSpectraRanges(Form4.StringGrid1.Objects[XorYMatrixData,rowNumber]).xCoord.numCols) ;

    
   Form1.Caption := ExtractFileName(files.Strings[currentFile]) ;
   Form2.Panel2.Color :=  TSpectraRanges(Form4.StringGrid1.Objects[2,rowNumber]).ReturnTColorFromLineColor ;
   Form3.Panel2.Color :=  Form2.Panel2.Color ;
   if success = false then
       Form4.close1Click(nil);

    inc(rowNumber) ; 
  end ; // repeat for next file in list

end ;





procedure TForm4.Integration1Click(Sender: TObject);
Var
  t0, t1, selectedRowNum, currentSpecNum  : integer ;
  X1, Y1, X2, Y2  : single ;
  area1, area2, area_ave, area_total : single ;
  tSR, newSR : TSpectraRanges ;
begin
  currentSpecNum := 0 ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
    selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;

    if Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum] is  TSpectraRanges  then
    begin
      tSR  :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;
      // create new line in stringgrid and create TSpectraRanges object for each TSpectraRanges selected (one at a time)
      DoStuffWithStringGrid('', 2, tSR.yCoord.numRows, tSR.yCoord.numCols , true, StringGrid1.RowCount-1 ) ;
      // point pointer newSR to the new TSpectraRange object
      newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2]) ;
      // copy the original data
      newSR.CopySpectraObject(tSR);


      tSR.yCoord.F_MData.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_MData.Seek(0,soFromBeginning) ;

      for  currentSpecNum := 1 to tSR.yCoord.numRows do  // for each row in the selected TSpectraRanges object
      begin
        area_total := 0 ;
        tSR.xCoord.F_MData.Seek(0,soFromBeginning) ; // retieve the 1st x value each iteration
        tSR.xCoord.F_MData.Read(X1,4) ;
        tSR.yCoord.F_MData.Read(Y1,4) ;
        tSR.xCoord.F_MData.Read(X2,4) ;
        tSR.yCoord.F_MData.Read(Y2,4) ;
        area_total := ((Y1 + Y2)/2) * (X2-X1) ;   // = area per unit x
 //       area2 :=    area_total ;
        // the first value is not averaged as we do not know what is before it
        newSR.yCoord.F_MData.Write(area_total,newSR.yCoord.SDPrec) ;
        for t1 := 1 to tSR.yCoord.numCols - 1 do
        begin
           X1 := X2 ;
           Y1 := Y2 ;
           tSR.xCoord.F_MData.Read(X2,4) ;
           tSR.yCoord.F_MData.Read(Y2,4) ;

           area1 := ((Y1 + Y2)/2) * (X2-X1) ;  // = area per unit x

           // This averaging is so we get a value that represents the xCoord data point,
           // not a half step between each.
//           area_ave := ((area1 + area2) / 2) ;
//           area_total := area_total + area_ave ;
           area_total := area_total + area1 ;
           newSR.yCoord.F_MData.Write(area_total,newSR.yCoord.SDPrec) ;

 //          area2 := area1 ;
           Form4.StatusBar1.Panels[0].Text :=  't1 = ' + inttostr(t1) ;
        end;  // end for each col
        // the last value is not averaged either as we do not know what is after it
 //       newSR.yCoord.F_MData.Write(area_total,newSR.yCoord.SDPrec) ;

      end ;  // end for each row

      // do display and interface
      newSR.GLListNumber := GetLowestListNumber ;
      if tSR.fft.dtime  <> 0 then
        newSR.fft.CopyFFTObject(tSR.fft) ;
      StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'integrated' + '_' + Form4.StringGrid1.Cells[1,selectedRowNum] ; // this is the file name displayed in column 2 ;
     // newSR.xyScatterPlot := true ;
      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

   end ; //if it is a TSpectraRanges object
   end;  // for each file selected

   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;
end;






function TForm4.ChooseDisplayType(SpectObj : TSpectraRanges) : boolean ;
// ONLY WORKS FOR SINGLE PRECISION AT PRESENT
var
  t1, t2 : integer ;
  t1x, t1y : integer ;
  imageOffset : integer ;
  s1 : single ;
  TempXY : array[0..1] of single ;
begin


  if (SpectObj.frequencyImage <> true) and (SpectObj.nativeImage <> true) then
  begin
    // 1/ check # spectra = num pixelX x numPixelY
//    t1x := strtoint(Form2.NumColsEB1.Text) ;
//    t1y := strtoint(Form2.NumRowsEB1.Text) ;

    // this only alows for 'image major' type data where each image is in an xPix x yPix block
    imageOffset :=  (t1x * t1y) * (strtoint(Form2.ImageNumberTB1.Text)-1) ; // the offset to the image of interest

    if Form2.Is2DdataRB.Checked and (SpectObj.yCoord.numRows >= (t1x * t1y)) then
      SpectObj.frequencyImage := true
    else
    if Form2.IsNative2DdataRB.Checked {and (SpectObj.yCoord.numRows >= (t1x * t1y))} then
      SpectObj.nativeImage := true ;

    if (SpectObj.yCoord.numRows < (imageOffset+(t1x * t1y)) ) then
    begin
    // messagedlg('Subfile does not seem to be present'+ #13 +'EVect first image' ,mtError,[mbOk],0) ;
      Form2.ImageNumberTB1.Text := '1' ;
      imageOffset :=  0  ; // the offset to the image of interest
    end ;
  end
  else // either image type is desired
  begin
////     t1x := SpectObj.xPix ;
////     t1y := SpectObj.yPix ;
//     t1x := strtoint(Form2.NumColsEB1.Text) ;
//     t1y := strtoint(Form2.NumRowsEB1.Text) ;
    // this only alows for 'image major' type data where each image is in an xPix x yPix block
    imageOffset :=  (t1x * t1y) * (strtoint(Form2.ImageNumberTB1.Text)-1) ; // the offset to the image of interest

  end ;

  t1x := strtoint(Form2.NumColsEB1.Text) ;
  t1y := strtoint(Form2.NumRowsEB1.Text) ;

  // 2/ Extract intensity value and place in image2DSpecR (update FrequencySlider1 max value etc)
  if SpectObj.frequencyImage then
  begin
     if (SpectObj.yCoord.numRows < (t1x * t1y)) then
     begin
       messagedlg('Not enough spectra in file to create '+Form2.NumColsEB1.Text+' by '+Form2.NumRowsEB1.Text+' image'+ #13 +'Change 2D pixel count entry and try again' ,mtError,[mbOk],0) ;
       result := false ;
       exit ;
     end ;
     //SpectObj.yCoord.numRows :=  strtoint(Form2.NumRowsEB1.Text) ;
     //SpectObj.yCoord.numCols :=  strtoint(Form2.NumColsEB1.Text) ;

     SpectObj.xPix := t1x ;
     SpectObj.yPix := t1y ;
     SpectObj.xPixSpacing := strtofloat(Form2.PixelSpaceX_EB.Text) ;
     SpectObj.yPixSpacing := strtofloat(Form2.PixelSpaceY_EB.Text) ;

     if SpectObj.image2DSpecR <> nil then SpectObj.image2DSpecR.Free ;
     SpectObj.image2DSpecR := TSpectraRanges.Create(SpectObj.yCoord.SDPrec div 4,t1y,t1x,@SpectObj.LineColor) ;
     SpectObj.image2DSpecR.GLListNumber :=  SpectObj.GLListNumber ;
     SpectObj.currentSlice :=  SpectObj.yCoord.numCols div 2 ;
     Form2.FrequencySlider1.Max :=  SpectObj.yCoord.numCols ;
     Form2.FrequencySlider1.Position :=  SpectObj.currentSlice ;
     // create xCoord data
     SpectObj.image2DSpecR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     SpectObj.image2DSpecR.xPix := t1x ;
     SpectObj.image2DSpecR.yPix := t1y ;
     SpectObj.image2DSpecR.xPixSpacing := SpectObj.xPixSpacing ;
     SpectObj.image2DSpecR.yPixSpacing := SpectObj.yPixSpacing ;

     SpectObj.image2DSpecR.xyScatterPlot :=  SpectObj.xyScatterPlot ;

     for t1 := 0 to t1x-1 do
     begin
       s1 :=  t1 * SpectObj.xPixSpacing ;
       SpectObj.image2DSpecR.xCoord.F_Mdata.Write(s1,4) ;
     end ;

     SpectObj.SeekFromBeginning(3,1,0) ;
     SpectObj.image2DSpecR.SeekFromBeginning(3,1,0) ;
     // select data from main spectra (single wavelength)
     for t1 := 0 to t1y-1 do
     begin
       for t2 := 1 to t1x do
       begin
         SpectObj.Read_YrYi_Data(SpectObj.currentSlice,(t1*t1x)+t2+imageOffset,@TempXY,true) ;
         SpectObj.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
       end ;
     end ;

     SpectObj.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
     SpectObj.XHigh :=  SpectObj.image2DSpecR.XHigh + SpectObj.xPixSpacing ;
     SpectObj.XLow :=  SpectObj.image2DSpecR.XLow ;
     SpectObj.YHigh :=  (SpectObj.yPix ) * SpectObj.yPixSpacing  ;    // need to spread the image out in the Y direction as much as in X direction
     SpectObj.YLow :=  0 ;

     if  SpectObj.image2DSpecR.yCoord.numRows > 1 then
       SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 9)
     else
     SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)  ;

     // SpectObj.YHigh & SpectObj.YLow should be saved to optimise contrast in the 2D image   Solution: they are stored in SpectObj.image2DSpecR.YHigh and YLow

     SpectObj.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     SpectObj.xCoord.F_Mdata.Read(s1,4) ;
     Form2.Label47.Caption := floattostrF(s1,ffGeneral,5,3 ) ;
     SpectObj.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
     SpectObj.xCoord.F_Mdata.Read(s1,4) ;
     Form2.Label48.Caption := floattostrF(s1,ffGeneral,5,3 ) ;
     SpectObj.xCoord.F_Mdata.Seek((SpectObj.xCoord.SDPrec * SpectObj.currentSlice )-SpectObj.xCoord.SDPrec,soFromBeginning) ;
     SpectObj.xCoord.F_Mdata.Read(s1,4) ;
     Form2.imageSliceValEB.Text  := floattostrF(s1,ffGeneral,5,3 ) ;
  end
  else
  if SpectObj.nativeImage then
  begin
     // Most commonly used to read in scores data from image PCA etc, where each spectra has a score for each PC along a single row
     SpectObj.xPix := t1x ;
     SpectObj.yPix := t1y ;
     SpectObj.xPixSpacing := strtofloat(Form2.PixelSpaceX_EB.Text) ;
     SpectObj.yPixSpacing := strtofloat(Form2.PixelSpaceY_EB.Text) ;

     SpectObj.image2DSpecR := TSpectraRanges.Create(SpectObj.yCoord.SDPrec div 4,t1y,t1x,@SpectObj.LineColor) ;
     SpectObj.image2DSpecR.GLListNumber :=  SpectObj.GLListNumber ;
     SpectObj.currentSlice :=  1 ;

     SpectObj.image2DSpecR.xPix := t1x ;
     SpectObj.image2DSpecR.yPix := t1y ;
     SpectObj.image2DSpecR.xPixSpacing := SpectObj.xPixSpacing ;
     SpectObj.image2DSpecR.yPixSpacing := SpectObj.yPixSpacing ;

     SpectObj.image2DSpecR.xyScatterPlot :=  SpectObj.xyScatterPlot ;

     // create xCoord data
     SpectObj.image2DSpecR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     for t1 := 0 to t1x-1 do
     begin
       s1 :=  t1 * SpectObj.xPixSpacing ;
       SpectObj.image2DSpecR.xCoord.F_Mdata.Write(s1,4) ;
     end ;

     imageOffset := 1 ;
     // select data from main spectra - single image
     for t1 := 0 to t1y-1 do
     begin
       for t2 := 1 to t1x do
       begin
         SpectObj.Read_YrYi_Data((t1*t1x)+t2,imageOffset,@TempXY,true) ;
         SpectObj.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
       end ;
     end ;

     SpectObj.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
     SpectObj.XHigh :=  SpectObj.image2DSpecR.XHigh ;
     SpectObj.XLow :=  SpectObj.image2DSpecR.XLow ;
     SpectObj.YHigh := ( SpectObj.yPix ) * SpectObj.yPixSpacing  ;    // need to spread the image out in the Y direction as much as in X direction
     SpectObj.YLow :=  0 ;

//     if Form2.NoImageCB1.checked = false then
        SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 9) ;
     // SpectObj.YHigh & SpectObj.YLow should be saved to optimise contrast in the 2D image   Solution: they are stored in SpectObj.image2DSpecR.YHigh and YLow
  end
  else
  begin
//     SpectObj.yCoord.numRows :=  strtoint(Form2.NumRowsEB1.Text) ;
//     SpectObj.yCoord.numCols :=  strtoint(Form2.NumColsEB1.Text) ;

{     SpectObj.xCoord.F_Mdata.SetSize(t1x*SpectObj.xCoord.SDPrec);
     SpectObj.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     for t1 := 0 to t1x-1 do
     begin
       s1 :=  t1 * SpectObj.xPixSpacing ;
       SpectObj.xCoord.F_Mdata.Write(s1,4) ;
     end ;  }
    SpectObj.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
    if (SpectObj.lineType > 0) and (SpectObj.lineType <= MAXDISPLAYTYPEFORSPECTRA) then
      SpectObj.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),SpectObj.lineType ) 
    else
      SpectObj.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),1 ) ;

  end ;

end ;



function TForm4.FindStringInFile(compareStr : String; fileStream : TFileStream; startPos : integer) : integer ;
var
  strLength, posString, posInFile, posInStr : integer ;
  byteBuff : PChar;
  tbool : boolean ;
begin
    posInFile := startPos ;
    fileStream.Seek(startPos,soFromBeginning) ; // Seek(DataFile,0) ;
    strLength := length(compareStr) ;
    GetMem(byteBuff, strLength);

    fileStream.Read(byteBuff^,strLength) ;

    while (fileStream.Position < fileStream.Size)  Do
    begin
         tbool := true ;
         posInStr := 0 ;
         while tbool and (posInStr < strLength) do
         begin
           if byteBuff[posInStr] <> compareStr[posInStr+1] then
             tbool := false ;
           inc(posInFile) ;
           inc(posInStr) ;
         end ;
         if posInStr = strLength then
         begin
              posInFile := (posInFile-strLength) ;
              result := posInFile ;
              Break ;
         end ;
         fileStream.Seek(posInFile,soFromBeginning) ;
         fileStream.Read(byteBuff^,strLength) ; // read in next characters for comparison
    end ;

    FreeMem(byteBuff);
    if (fileStream.Position >= fileStream.Size) then
       result := -1 ;

end ;


function TForm4.GetJDXHeaderData(toFind : string; tStrList : TStringList ; headerSize, lineNum : integer) : string ;
var
  tint1, tint2 : integer ;
  tstr1 : string ;
begin

  tint1 := 0  ;
  while (pos(toFind,tStrList.Strings[tint1+lineNum]) = 0)  and (tint1 <= headerSize) do
    inc(tint1) ;

  if tint1 <= headerSize then
  begin
    tstr1 :=  tStrList.Strings[tint1+lineNum] ;
    tint2 := pos( '=', tstr1) ;
    tstr1 := copy(tstr1, tint2+1, length(tstr1)) ;
    tstr1 := trimLeft(tstr1) ;
    if pos('$', tstr1) <> 0 then
       tstr1 := copy(tstr1, 1, pos('$', tstr1)) ;
    result := tstr1 ;
  end
  else
    result := '' ;

end ;


function TForm4.GetJDXHeaderSize(tStrList : TStringList; dataType : String ; lineNum : integer) : integer ; // dataType is '##XYDATA=' or '##XYPOINTS='

var
  headerSize : integer ;
begin
  headerSize := 1 ;
  while (pos(dataType ,tStrList.Strings[lineNum + headerSize]) = 0) and (headerSize <= 50) and ((lineNum + headerSize) < tStrList.Count) do
    inc(headerSize) ;

  if (headerSize >= 50) or (headerSize >= tStrList.Count) then
  begin
    result := 0 ;
  end
  else
    result := (headerSize+1) ;
end ;


function TForm4.GetNumJDXSubFiles(tStrList : TStringList) : integer ;

Var
  headerSize : integer ;
  tstr1 : String ;

begin
  headerSize := GetJDXHeaderSize(tStrList, '##XYDATA=', 0) ;
  if headerSize = 0 then
  begin
    headerSize := GetJDXHeaderSize(tStrList, '##XYPOINTS=', 0) ;
    if headerSize = 0 then
      Exit ;
  end ;

  tstr1 :=  GetJDXHeaderData('##BLOCKS=', tStrList, headerSize, 0) ;
  if tstr1 <> '' then
    result := strtoint( tstr1 )
  else
    result := 1 ;
end ;


function TForm4.GetJDXlineNumofString(tStrList : TStringList; toFind : String; lineNum : integer) : integer ;
begin
  while (pos(toFind,tStrList.Strings[lineNum]) = 0) and (lineNum < tStrList.Count) do
    inc(lineNum) ;

  if lineNum <= tStrList.Count then
    result := lineNum
  else
    result := 0 ;

end ;

function TForm4.ProcessXYYString(SpectraObject : TSpectraRanges; dataString : String) : integer ;
begin
  result := 1 ;
end ;



// loads JDX file data and returns the line number of the ##end= token of last subfile loaded. numFiles is known number of spectra in JDX file
// Only handles single precision data and TSpectraRanges objects
// TSpectraRanges has to have number of files and number of X data and memory required set up before sending
function TForm4.LoadJDXFile(SpectObj : TSpectraRanges; tStrList : TStringList; numFiles, numPoints, whichFile, lineNum : integer) : integer ;
Var
  tint1, headerSize, lineNumofEndToken, totalPoints, spacePos, negPos, commaPos : integer ;
  xSeparation, xData, yData, xFactor, yFactor, firstX, lastX, xIncrement  : single ;
  tstr1, dataType, sampDescription, sampTitle, dataString, yString, xString : String ;
begin
if SpectObj.xCoord.SDPrec = 4 then
begin
    headerSize := GetJDXHeaderSize(tStrList, '##XYDATA=', lineNum) ; // this is the number of lines past the current line number (lineNum) to the data of interest
    if headerSize = 0 then
    begin
       headerSize := GetJDXHeaderSize(tStrList, '##XYPOINTS=', lineNum) ;
       if headerSize = 0 then
         Exit ;
    end ;

//    numPoints :=  strtoint( GetJDXHeaderData('##NPOINTS=', tStrList, headerSize, lineNum)  );
    if numPoints <> SpectObj.xCoord.numCols then
    begin
       messagedlg('LoadJDXFile() Error:'+#13+'Number of points in subfile does not equal number in previous subfiles' ,mtError,[mbOK],0) ;
    end ;

    tstr1   :=   GetJDXHeaderData('##XFACTOR=', tStrList, headerSize, lineNum) ;
    if (tstr1 <> '') then xFactor :=  strtofloat( tstr1 ) else  xFactor := 1.0 ;

    tstr1  :=  GetJDXHeaderData('##YFACTOR=', tStrList, headerSize, lineNum) ;
    if (tstr1 <> '') then yFactor :=  strtofloat( tstr1 )  else  yFactor := 1.0 ;

    tstr1  :=  GetJDXHeaderData('##FIRSTX=', tStrList, headerSize, lineNum) ;
    if (tstr1 <> '') then firstX  :=  strtofloat( tstr1 ) else  firstX := 0.0 ;

    tstr1  :=  GetJDXHeaderData('##LASTX=', tStrList, headerSize, lineNum) ;
    if (tstr1 <> '') then lastX  :=  strtofloat( tstr1 ) else  lastX := 0.0 ;

    xIncrement := (lastX - firstX) / (numPoints - 1) ;
 //   messagedlg('LastX is ' + floattostr(lastX) + 'calculated = ' + floattostr((xIncrement*(numPoints-1))+firstX) ,mtinformation,[mbOK],0) ;

    sampDescription :=  GetJDXHeaderData('##SAMPLE DESCRIPTION=' , tStrList, headerSize, lineNum) ;
    sampTitle :=  GetJDXHeaderData('##TITLE=' , tStrList, headerSize, lineNum)  ;
    dataType  :=  GetJDXHeaderData('##XYDATA=' , tStrList, headerSize, lineNum) ;
    if dataType = '' then
      dataType  :=  GetJDXHeaderData('##XYPOINTS=' , tStrList, headerSize, lineNum) ;

 //   SpectraObject.Filename :=  ExtractFilePath(SpectraObject.Filename) + sampTitle +'_' + sampDescription ;

    totalPoints := 0 ;
    if (dataType = '(X++(Y..Y))') then
    begin
      lineNumofEndToken :=  GetJDXlineNumofString(tStrList, '##END=', lineNum+1) ;
      for tint1 := (lineNum + headerSize) to (lineNumofEndToken-1) do
      begin
         dataString :=  tStrList.Strings[tint1]  ;
         dataString := dataString + ' ' ;
         dataString := trimLeft(dataString) ;
         negPos   := pos('-',dataString) ; // sometime -ve sign is the delimeter
         spacePos := pos(' ',dataString) ;
         if (negPos < spacePos) and (negPos <> 0) then spacePos := negPos ;
         dataString := copy(dataString,spacePos,length(dataString)-spacePos+1) ; // this removes initial X value
         dataString := trimLeft(dataString) ;
         negPos   := pos('-',dataString);
         if (negPos = 1) then  // sometime -ve sign is the delimeter
         begin
            tstr1 := copy(dataString,2,length(dataString)-1) ; // this removes initial -ve sign
            negPos   := pos('-',tstr1) + 1;
            spacePos := pos(' ',tstr1) + 1 ;
            if (negPos < spacePos) and (negPos <> 1) then spacePos := negPos ;
         end
         else
         begin
           spacePos := pos(' ',dataString) ;
           if (negPos < spacePos) and (negPos <> 0) then spacePos := negPos ;
         end ;
         while   spacePos > 0 do
         begin
           yString := copy(dataString,1,spacePos-1) ;
           yData :=  strtofloat(yString) * yFactor ;

           if whichFile = 1 then  // write x data
           begin
             SpectObj.xCoord.F_Mdata.Write(xData,4) ;
             xData :=  firstX + (totalPoints*xIncrement) ;
           end ;
           // write Y data
           SpectObj.yCoord.F_Mdata.Write(yData,4) ;
           
           dataString := copy(dataString,spacePos,length(dataString)-spacePos+1) ; // this removes most recent Y value
           dataString := trimLeft(dataString) ;

           negPos   := pos('-',dataString) ;
           if (negPos = 1) then  // sometime -ve sign is the delimeter
           begin
             tstr1 := copy(dataString,2,length(dataString)-1) ; // this removes initial -ve sign
             negPos   := pos('-',tstr1) + 1;
             spacePos := pos(' ',tstr1) + 1;
             if (negPos < spacePos) and (negPos <> 1) then spacePos := negPos ;
           end
           else
           begin
             spacePos := pos(' ',dataString) ;
             if (negPos < spacePos) and (negpos <> 0) then spacePos := negPos ;
           end ;
           
           inc(totalPoints) ;
         end ;
      end ;
      Form4.StatusBar1.Panels[0].Text :=  'counted  = ' +inttostr(totalPoints) +' points '+ inttostr(numPoints) ;
    end
    else
    if (dataType = '(XY..XY)') then
    begin
       lineNumofEndToken :=  GetJDXlineNumofString(tStrList, '##END=', lineNum+1) ;
       for tint1 := (lineNum + headerSize) to (lineNumofEndToken-1) do
       begin
         dataString :=  tStrList.Strings[tint1]  ;
         dataString := trimLeft(dataString) ;
         spacePos := pos(';',dataString) ; // acually the ; position
         while   spacePos > 0 do
         begin
           commaPos :=  pos(',',dataString) ;
           xString := copy(dataString,1,commaPos-1) ;
           xString := trimLeft(xString) ;

           yString := copy(dataString,commaPos+1,spacePos-(commaPos+1)) ;  // actually and X,Y pair
           yString := trimLeft(yString) ;
           yData :=  strtofloat(yString) * yFactor ;

           if whichFile = 1 then
           begin
             xData :=  strtofloat(xString) * xFactor ;
             SpectObj.xCoord.F_Mdata.Write(xData,4) ;
           end ;
           // write Y data
           SpectObj.yCoord.F_Mdata.Write(yData,4) ;

           dataString := copy(dataString,spacePos+1,length(dataString)-spacePos+2) ; // this removes most recent Y value

           spacePos := pos(';',dataString) ; // acually the ; position
           inc(totalPoints) ;
         end ;
      end ;
      Form4.StatusBar1.Panels[0].Text :=  'counted  = ' +inttostr(totalPoints) +' points '+ inttostr(numPoints) ;
    end ;

    SpectObj.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
    SpectObj.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    if Form4.CheckBox7.Checked = false then  // keep current perspective = false
      Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

    result := lineNumofEndToken   // this is the line position of the currnt '##END=' in the file and is re-passed by this function as lineNum
end
else
   messagedlg('LoadJDXFile() Error:'+#13+'Single precision TSpectraRanges objects only for JDX files' ,mtError,[mbOK],0) ;

end ;


// Only handles single precision data
Procedure TForm4.LoadSPAFileFloat(SpectObj : TSpectraRanges) ; // loads (modified) floating point data from SPA files
var
  tint1, numPoints, defaultRes : integer ;    // numPoints is number of float point values in data, not what is in inteferogram
  maxX1, minX1, xSeparation, xData, yData  : single ;
  hasInterferograms : boolean ;
  tstrm : TMemoryStream ;
begin
if SpectObj.xCoord.SDPrec = 4 then
begin
  try
  tstrm := TMemoryStream.Create() ;
  tstrm.Clear() ;

  tstrm.LoadFromFile(SpectObj.xCoord.Filename) ;
  tstrm.Seek(0,soFromBeginning) ;
  
  tstrm.Seek(564,soFromBeginning) ;   // this is where numPoints is stored (universaly)
  tstrm.Read(numPoints,4) ;     // read in the number of points in the file
  numPoints := numPoints - 1  ;
  tstrm.Seek(8,soFromCurrent) ;
  tstrm.Read(maxX1,4) ;               // this is where maxX1 is stored (universaly)
  tstrm.Read(minX1,4) ;               // this is where minX1 is stored (universaly)
  xSeparation := (maxX1 - minX1 )/ numPoints ; // x data is this distance apart
  defaultRes :=  round(32768 / round(xSeparation*2)) ;

  if  (tstrm.Size - ((numPoints+1)*4)) > ((numPoints+1)*4) then
    hasInterferograms := true
  else
    hasInterferograms := false ;

  if hasInterferograms then
    tint1 :=  tstrm.Size - ((numPoints+1)*4) - (2*defaultRes*4) - 980  // filesize - data size - interferogram size
  else
    tint1 :=  tstrm.Size - ((numPoints+1)*4) ;  // start of data should be here (if no interferogram present) filesize - data size

  tstrm.Seek(tint1,soFromBeginning) ; // data starts here   (byte 1616)

  SpectObj.xCoord.ClearData(1) ; // does not clear filename
  SpectObj.yCoord.ClearData(1) ;
  SpectObj.xCoord.numCols := numPoints+1 ;
  SpectObj.yCoord.numCols := numPoints+1 ;
  SpectObj.xCoord.numRows := 1 ;
  SpectObj.yCoord.numRows := 1 ;
  SpectObj.xCoord.F_Mdata.SetSize(4*(numpoints+1)) ;
  SpectObj.yCoord.F_Mdata.SetSize(4*(numpoints+1)) ;
  SpectObj.SeekFromBeginning(3,1,0) ;

  // read the spectral data and write it to the spectraObject stream as X,Y pairs
  for tint1 := 0 to numPoints do
    begin
      tstrm.Read(yData,4) ;
      xData := (maxX1 - (tint1 * xSeparation)) ;
      SpectObj.xCoord.F_Mdata.Write(xData  ,4) ;
      SpectObj.yCoord.F_Mdata.Write(yData,4) ;
  end ;

  SpectObj.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
  SpectObj.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

  if Form4.CheckBox7.Checked = false then  // keep current perspective = false
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

  finally
    tstrm.Free() ;
  end ;
end
else
   messagedlg('LoadSPAFileFloat() Error:'+#13+'Single precision TSpectraRanges objects only for SPA files' ,mtError,[mbOK],0) ;

end ;


Procedure TForm4.LoadSPAFileFFT(SpectObj : TSpectraRanges) ; // loads original fourier data from SPA file
var
  TempStr2 : String ;
  t1, FSize, t4 : LongInt ;
  Resolution, defaultRes : Variant ;
  TempX, TempY : single ;
  upperLimit, lowerLimit : single ;
  byteBuff : PChar;
  compareStr : String ;
  posResolution : integer ;
  fileStream : TFileStream ;
  spectStream : TSpectraRanges ;
  backStream :  TSpectraRanges ;
//  tstrm : TMemoryStream ;
begin
   messagedlg('LoadSPAFileFFT() not implemented yet' ,mtInformation,[mbOK],0) ;
{  try
    fileStream := TFileStream.Create(SpectObj.xCoord.Filename,fmOpenRead) ;
    FSize := fileStream.Size ;
    defaultRes := strtofloat(Form2.defaultResTextBox.Text) ;   // from 'file import' tab

    TempStr2 :='' ;

    if FSize = 0 then
    begin
      messagedlg('File is empty!' ,mtinformation,[mbOK],0) ;
      exit ;
    end ;

    fileStream.Seek(144*4,sofromBeginning) ;
    fileStream.Read(upperLimit,4) ;
    fileStream.Read(lowerLimit,4) ;

    // for testing - also need to change x spacing in output spectrum to match these values
    MessageDlg('UL= ' + floattostr(upperLimit) +' '+ floattostr(lowerLimit),mtConfirmation, [mbOK], 0) ;

    posResolution := FindStringInFile('Resoultion:', fileStream, 0) ;

    if  posResolution > 0 then
    begin
         GetMem(byteBuff, 45);
         byteBuff[44] := #0 ;
         fileStream.Seek(posResolution,soFromBeginning) ;
         fileStream.Read(byteBuff^,34) ;
         compareStr :=  byteBuff ;
         FreeMem(byteBuff);
         compareStr := trim(compareStr) ;
         t1 := pos('Resolution:',compareStr) ;  // Resolution:	 8.000 from 651.8325 to 3999.7061
         If t1 > 0 Then
         begin
           t1 := pos(':',compareStr) ;
           TempStr2 := Copy(compareStr,t1+1, length(compareStr) ) ;
           TempStr2 := trim(TempStr2) ;
           t1 := pos(' ',TempStr2) ;
           TempStr2 := Copy(TempStr2,1, t1 ) ;
           try
             Resolution := strtoFloat(TempStr2) ;
             //messagedlg('Resolution = ' + TempStr2,mtInformation,[mbOk],0) ;
           except
           on EConvertError do
           if MessageDlg('Resolution not found!  Continue?'+#13+'(default resolution of'+floattostrf(defaultRes,ffGeneral,5,3)+' being used - see file import tab)',mtConfirmation, [mbYes, mbNo], 0) = mrNo then
              exit
           else
              Resolution := defaultRes ;
       end ;
    end ;
    end
    else
    begin
         if MessageDlg('Resolution not found!  Continue?'+#13+'(default resolution of'+floattostrf(defaultRes,ffGeneral,5,3)+' being used - see file import tab)',mtConfirmation, [mbYes, mbNo], 0) = mrNo then
            exit
         else
           Resolution := defaultRes ;
    end ;

    try

      defaultRes :=  32768 / Resolution ;      // defaultRes is number of points in ( real+imaginary ???) interferogram   // i think is only hs a real part due to nature of electronics
      spectStream := TSpectraRanges.Create(1, 1 , defaultRes, nil) ;   // sample spectrum
      backStream :=  TSpectraRanges.Create(1, 1,  defaultRes, nil) ;   // background spectrum
      SpectObj.xCoord.ClearData(1) ;
      SpectObj.yCoord.ClearData(1) ;
      SpectObj.xCoord.numRows := 1 ;
      SpectObj.yCoord.numRows := 1 ;
      SpectObj.xCoord.numCols := defaultRes ;
      SpectObj.yCoord.numCols := defaultRes ;
      SpectObj.xCoord.F_Mdata.SetSize(defaultRes*SpectObj.xCoord.SDPrec) ;
      SpectObj.yCoord.F_Mdata.SetSize(defaultRes*SpectObj.yCoord.SDPrec) ;

      t4 := FSize - (2*defaultRes*4) - 48 ;  //   fine for retrieving background
      fileStream.Seek( t4 ,soFromBeginning) ;
      backStream.SeekFromBeginning(3,1,0) ;
      for t1 := 0 to defaultRes-1 do
      begin
         fileStream.Read(TempY,4) ;
         TempX := t1 * 1.0 ;
         backStream.xCoord.F_Mdata.Write(TempX,4) ;
         backStream.yCoord.F_Mdata.Write(TempY,4) ;
      end ;

      t4 := FSize - (defaultRes*4) - 24 ;      //   for retrieving sample spectrum
      fileStream.Seek( t4 ,soFromBeginning) ;
      spectStream.SeekFromBeginning(3,1,0) ;
      for t1 := 0 to defaultRes-1 do
      begin
         fileStream.Read(TempY,4) ;
         TempX := t1 * 1.0 ;
         spectStream.xCoord.F_Mdata.Write(TempX,4) ;
         spectStream.yCoord.F_Mdata.Write(TempY,4) ;
      end ;

      backStream.ComputeFFTSingle(1,1,1) ;
      spectStream.ComputeFFTSingle(1,1,1) ;

      backStream.SeekFromBeginning(3,1,0) ;
      spectStream.SeekFromBeginning(3,1,0) ;
      SpectObj.SeekFromBeginning(3,1,0) ;

      // TempXYspect, TempXYback
      for t1 := 0 to defaultRes-1 do
      begin
         backStream.yCoord.F_Mdata.Read(TempX, 4) ;
         spectStream.yCoord.F_Mdata.Read(TempY,4) ;
         TempY := (TempY / TempX ) ;  // this is transmittance
         TempY :=  -log10(TempY) ;    // this is absorbance
         //if  TempY < 0 then TempY := 0.0 ;
         backStream.xCoord.F_Mdata.Read(TempX, 4) ;
         SpectObj.xCoord.F_Mdata.Write(TempX,4) ;
         SpectObj.yCoord.F_Mdata.Write(TempY,4) ;
      end ;

      SpectObj.CreateGLList(Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay()) ;
      SpectObj.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      if Form4.CheckBox7.Checked = false then  // keep current perspective = false
        Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
    finally
      spectStream.Free ;
      backStream.Free ;
    end ;


  finally
    fileStream.Free ;
  end ;
  }
end ;

function  TForm4.LoadSPCXrayFile(SpectObj : TSpectraRanges): boolean ;
var
// data part starts at byte 3876 and is 32 bit integer and specifies Y value only
  t1 : integer ;
  xrayCount : integer ;
  xStart, xInc, xval, yval : single ;
  fileStream : TFileStream ;
begin
  try
    fileStream := TFileStream.Create(SpectObj.xCoord.Filename,fmOpenRead) ;
    if fileStream.Size  = 0 then
    begin
      messagedlg('File is empty!' ,mtinformation,[mbOK],0) ;
      result := false ;
      exit ;
    end ;

    SpectObj.xCoord.ClearData(1) ;
    SpectObj.yCoord.ClearData(1) ;
    SpectObj.xCoord.numCols := 4086 ;
    SpectObj.xCoord.numRows := 1 ;
    SpectObj.yCoord.numCols := 4086 ;
    SpectObj.yCoord.numRows := 1 ;
    SpectObj.xCoord.F_Mdata.SetSize(16344) ;
    SpectObj.yCoord.F_Mdata.SetSize(16344) ;
    SpectObj.SeekFromBeginning(3,1,0) ;

    // skip header bit of SPC file
    fileStream.Seek(3876,soFromBeginning) ;

    If Form2.CheckBox3.Checked Then   // if Calculate X values is true
    begin
      xInc := StrToFloat(Form2.Edit16.Text) ;
      xStart := StrToFloat(Form2.Edit29.Text) ;

      for t1 := 0 to  ((20220-3876) div 4)-1  Do    // = 4086 points
      begin
         fileStream.Read(xrayCount,4) ;  // read integer
         yval :=  xrayCount ;       // convert integer
         xval :=  xStart + (t1*xInc) ; // calculate x
         SpectObj.xCoord.F_Mdata.Write(xval,4) ;
         SpectObj.yCoord.F_Mdata.Write(yval,4) ;
      end ;

      SpectObj.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
      SpectObj.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      if not Form4.CheckBox7.Checked then
        Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
      result := true ;
      end
    else  // Calculate X values is false
     begin
       MessageDlg('You need to specify "Calculate X" and an X increment value',mtInformation, [mbOK], 0)  ;
       result := false ;
     end ;

  finally
    fileStream.Free ;
  end ;

end ;



procedure TForm4.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
Var
  TempList : TStringList ;
  TempInt1 : Integer ;
begin

 // moved from form1
TempList := TStringList.Create ;
try
  With TempList Do
   begin
    Try
      add(GetCurrentDir) ;   //final directory used
      add(Form2.MVA_executable) ;
//       messagedlg(GetCurrentDir  ,mtinformation,[mbOk],0) ;
      add(Form2.Edit1.Text) ; //background Red%
      add(Form2.Edit2.Text) ; //background Green%
      Add(Form2.Edit3.Text) ; //background Blue%
      add(Form2.Combobox2.Items.CommaText) ; // add list of units from cursor position combobox2
      add(Form2.ComboBox2.Text) ;
      add(Form2.Combobox4.Items.CommaText) ; // add list of units from file import combobox4
      add(Form2.ComboBox4.Text) ;
      For TempInt1 := 0 to IntensityList.Count-1 Do
        begin
          add(IntensityList.Strings[TempInt1]) ;
        end ;
      SaveToFile(HomeDir+ '\initial.ini') ;
    Except
      on EInOutError Do
    end ;
 end ;
Finally
  TempList.Free ;
   end ;

IntensityList.Free ;
end;


procedure TForm4.OpenFiles1Click(Sender: TObject);
begin
  Form4.Open1Click(Sender) ;
end;


procedure TForm4.GraphicsWindow1Click(Sender: TObject);
begin
  form1.Visible := true ;
end;


procedure TForm4.CheckBox8Click(Sender: TObject);
begin
  form1.Refresh ;
end;



procedure TForm4.N2Ddisplay1Click(Sender: TObject);
// change from linear array to 2D image of data
var
  t1 : integer ;
  selectedRowNum : integer ;
  tSR : TSpectraRanges ;
  s1 : single ;
begin

  if SelectStrLst.Count = 1 then // only for first file in list
  begin
    selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;

    if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

      // this forces a change in numRows and numCols of a spectra
      tSR.yCoord.numRows :=  strtoint(Form2.NumRowsEB1.Text) ;
      tSR.yCoord.numCols :=  strtoint(Form2.NumColsEB1.Text) ;
      tSR.xCoord.F_Mdata.SetSize(tSR.yCoord.numCols*tSR.xCoord.SDPrec);
      tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      tSR.xPixSpacing := strtofloat(Form2.PixelSpaceX_EB.Text) ;
      for t1 := 0 to tSR.yCoord.numCols-1 do
      begin
       s1 :=  t1 * tSR.xPixSpacing ;
       tSR.xCoord.F_Mdata.Write(s1,4) ;
      end ;

      if  (Form2.Not2DdataRB.Checked) then // this is the Radio Item choosing 1D or 2D dispaly
      begin
        tSR.frequencyImage := false ;
        tSR.nativeImage := false ;
 ////       tSR.yCoord.numRows :=  strtoint(Form2.NumRowsEB1.Text) ;
 ////       tSR.yCoord.numCols :=  strtoint(Form2.NumColsEB1.Text) ;

        ChooseDisplayType(tSR) ;
      end
      else
      if   (Form2.Not2DdataRB.Checked = false) then
      begin
        if form2.Is2DdataRB.Checked then  tSR.frequencyImage := true ;
        if form2.IsNative2DdataRB.Checked then  tSR.nativeImage := true ;
////        tSR.yCoord.numRows :=  strtoint(Form2.NumRowsEB1.Text) ;
////        tSR.yCoord.numCols :=  strtoint(Form2.NumColsEB1.Text) ;

        ChooseDisplayType(tSR) ;
      end ;
      
      if ((tSR.frequencyImage) or (tSR.nativeImage)) and ( tSR.image2DSpecR <> nil ) then
         Form4.StringGrid1.Cells[SG1_COL, selectedRowNum] :=  '1-'+inttostr(tSR.image2DSpecR.xPix)+':1-'+inttostr(tSR.image2DSpecR.yPix)
      else
         Form4.StringGrid1.Cells[SG1_COL, selectedRowNum] :=  '1-'+inttostr(tSR.yCoord.numRows)+':1-'+inttostr(tSR.yCoord.numCols)  ;

    end ;  // is  TSpectraRanges
 end ; // only for first file in list
 if not Form4.CheckBox7.Checked then
   form1.UpdateViewRange() ;
 form1.Refresh ;
end;


procedure TForm4.CutText1Click(Sender: TObject);
var
  t1, t2, t3, t4 : integer ;
  max : integer ;
  s1  : single ;
  numVarList, numSpectList, tStrOutput : TStringList ;
  tSR, tSR2   : TSpectraRanges ;
  rowToDisplay : TMemoryStream ;
  selectedRowNum, numSpectra : integer ;
  rowRange : string ;
  colRange : string;
  tStr     : string ;

begin

  if SelectStrLst.Count >= 1 then // make sure a spectrum is selected
  begin
  try
    numVarList :=  TStringList.Create ;
    numSpectList :=  TStringList.Create ;
    tStrOutput :=  TStringList.Create ;

    for t1 := 0 to SelectStrLst.Count-1 do  // 1. count number of variables in each spectraRange selected
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      if TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR 
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
      numVarList.Add(inttostr(tSR.yCoord.numCols))  ;
    end ;

    for t1 := 0 to SelectStrLst.Count-1 do  // 2. count number of spectra selected in each spectraRange selected
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      rowToDisplay := TMemoryStream.Create ;

      if TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR 
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

      rowRange := '' ;
      if tSR.SGDataView <> nil then
        rowRange := tSR.SGDataView.RowStrTextTB.Text ;  // these are the selected spectra out of a group

      if trim(rowRange) = '1-' then                   // otherwise, all the spectra are considered selected
        rowRange := rowRange + inttostr(tSR.yCoord.numRows)
      else
      if trim(rowRange) = '' then
        rowRange := '1-' + inttostr(tSR.yCoord.numRows) ;

      numSpectra := tSR.yCoord.GetTotalRowsColsFromString(rowRange,rowToDisplay) ;  // rowToDisplay is a TMemoryStream ;
      numSpectList.Add(inttostr(numSpectra))  ;
      rowToDisplay.Free ;
    end ;


    // 3. free old memory and create new data block for text buffer for clipboard
    // not needed as clipboard calls 'clear' before each cut or copy opperation
//    if clipboardCharBuff <> nil then
//      Dispose(clipboardCharBuff) ;


    max := 0 ;
    for t1 := 0 to  SelectStrLst.Count-1 do
    begin
      if strtoint(numVarList.Strings[t1])  > max then
        max :=  strtoint(numVarList.Strings[t1]) ;
    end ;
    tStrOutput.Capacity := max ;
    for t1 := 1 to  max  do
    begin
      tStrOutput.Add('') ;
    end ;


     // 4. place data in it: get the spectra, place transposed data in string list
    for t1 := 0 to SelectStrLst.Count-1 do
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      rowToDisplay := TMemoryStream.Create ;

      //tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
      if (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).frequencyImage) or (TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).nativeImage ) then
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]).image2DSpecR
      else
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
        
      rowRange := '' ;
      if tSR.SGDataView <> nil then
        rowRange := tSR.SGDataView.RowStrTextTB.Text ;

      if trim(rowRange) = '1-' then
        rowRange := rowRange + inttostr(tSR.yCoord.numRows)
      else
      if trim(rowRange) = '' then
        rowRange := '1-' + inttostr(tSR.yCoord.numRows) ;

      colRange := '1-' + numVarList.Strings[t1] ;
      tSR2 := TSpectraRanges.Create(tSR.xCoord.SDPrec div 4, strtoint(numSpectList.Strings[t1]),  strtoint(numVarList.Strings[t1]) ,  nil) ;
      tSR2.yCoord.FetchDataFromTMatrix(rowRange, colRange, tSR.yCoord ) ;
      tSR2.yCoord.Transpose ;


      tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      tSR2.SeekFromBeginning(3,1,0) ;
      for t2 := 0 to {tSR2.yCoord.numRows} max -1 do
      begin
        if t2 < tSR2.yCoord.numRows then
        begin
          // Place x coordinate
          tSR.xCoord.F_Mdata.Read(s1,4) ;
          if tStrOutput.Strings[t2] <> '' then
            tStrOutput.Strings[t2] := tStrOutput.Strings[t2] +#9+ floatToStrF(s1,ffExponent,8,3)
          else
            tStrOutput.Strings[t2] :=  floatToStrF(s1,ffExponent,8,3) ;
         // Place each y coordinate
          for t3 := 0 to tSR2.yCoord.numCols-1 do
          begin
            tSR2.yCoord.F_Mdata.Read(s1,4) ;
            tStrOutput.Strings[t2] := tStrOutput.Strings[t2] +#9+ floatToStrF(s1,ffExponent,8,3) ;
          end ;
        end
        else
        begin
          // Place "x" coordinate
          if tStrOutput.Strings[t2] <> '' then
            tStrOutput.Strings[t2] := tStrOutput.Strings[t2] +#9+ ' '
          else
            tStrOutput.Strings[t2] :=  ' ' ;

          for t3 := 0 to tSR2.yCoord.numCols-1 do
          begin
              tStrOutput.Strings[t2] := tStrOutput.Strings[t2] +#9+ ' '
          end ;
        end ;
      end ;

      tSR2.Free ;
      rowToDisplay.Free ;
    end ;

    // 5. Use String List Text property to output as CR+LF delimeted array
    clipboardCharBuff :=  tStrOutput.GetText ;
    Clipboard.SetTextBuf(clipboardCharBuff) ;

  finally
    numVarList.Free ;
    numSpectList.Free ;
    tStrOutput.Free ;
  end ;
  end ;

  Form1.refresh ;


end;


procedure TForm4.Flip1Click(Sender: TObject);
var
  t0, t1, t2 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tXY_s  : array[0..1] of single ;
begin

  SelectStrLst.SortListNumeric ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

        for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin

           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           tXY_s[0] := -1 * tXY_s[0] ;
           if tSR.yImaginary <> nil then
           begin
             tXY_s[1] := -1 * tXY_s[1] ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;

          end ;
          end ;
          tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
          tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;

  end ;
//  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;


procedure TForm4.LoadResultFiles(bFE: TPassBatchFileToExecutable; SGRowNum : integer; fileExtIn : string) ; // pass the executed processes info and its line number
var
  t1, t2, t3 : integer ;
  tSTRLST, tSTRLST2 : TStringList ;  // list of files in the directory
  FileInfo : TSearchRec;
  tSR1 : TSpectraRanges ;
  tempStr : string ;
begin

    tSTRLST := TStringList.Create ;
    if (findfirst( bFE.resultFileDirStr + '*' + fileExtIn ,faAnyFile,FileInfo)=0) then
    begin
        if (FileInfo.Name = '.') then
          findnext(FileInfo)  ;
        while (findnext(FileInfo)=0) do
        begin
          // this is list of all 1st level sub-directories
          tSTRLST.Add(bFE.resultFileDirStr + FileInfo.Name)
        end;
    findclose(FileInfo) ;
    end;

    for t1 := 0 to tSTRLST.Count - 1 do
    begin
      if pos(inttostr(bFE.PID_int),tSTRLST.Strings[t1]) > 0 then  // file exists with correct PID for process so load filenames stored in this file
      begin
         tSTRLST2:= TStringList.Create ;
         tSTRLST2.LoadFromFile(tSTRLST.Strings[t1]);
         for t2 := 0 to tSTRLST2.Count - 1 do
         begin
           if fileexists(tSTRLST2.Strings[t2]) then
           begin
              tSR1 := TSpectraRanges.Create(4,1,1, @bFE.lineCol) ;
              tSR1.LoadSpectraRangeDataBinV2(tSTRLST2.Strings[t2]);

              tSR1.GLListNumber := Form4.GetLowestListNumber ;
              tSR1.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
              tSR1.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR1.lineType) ;

              if  tSR1.yCoord.numRows > 1 then
                Form4.StringGrid1.Cells[t2+2, SGRowNum ] := '1-'+inttostr(tSR1.yCoord.numRows)+':'+'1-'+inttostr(tSR1.yCoord.numCols)
              else
                Form4.StringGrid1.Cells[t2+2, SGRowNum] := '1'+':'+'1-'+inttostr(tSR1.yCoord.numCols) ;

              tempStr := extractfilename(tSR1.yCoord.Filename) ;
              while pos('_',tempStr) > 0 do
              begin
                t3 := pos('_',tempStr) ;
                tempStr := copy(tempstr,t3+1,length(tempStr) - t3) ;
              end;
              tempStr := copy(tempstr,1,length(tempStr)-4) ;
              tSR1.columnLabel := tempStr ;

              Form4.StringGrid1.Objects[t2+2, SGRowNum]  := tSR1 ;
//              Form4.StringGrid1.Cells[t2+2, SGRowNum]    := extractFilename(tSR1.yCoord.Filename) ;

           end;
         end;
      end;
    end;

{    for t1 := 0 to Form4.StringGrid1.ColCount-1 do
    begin
      if t1 <  tSTRLST.Count then
        Form4.StringGrid1.Cells[t1+2, SGRowNum] := extractfilename(tSTRLST.Strings[t1]) ;
    end;  }

end;


procedure TForm4.Timer1Timer(Sender: TObject);
var
  t0 : integer ;
  ProcHandle : cardinal ;
  tSR1 : TSpectraRanges ;
  bFE  : TPassBatchFileToExecutable ;
  doneLoop : boolean ;
  ExitVal : cardinal ;
  retVal : boolean ;
begin
  t0 := 1 ;
  doneLoop := false ;

  while (doneLoop = false) and (t0 <= StringGrid1.RowCount-1) do    // for each row
  begin

     if  (StringGrid1.Objects[1, t0]) <>  nil then
     begin
       if  (StringGrid1.Objects[1, t0]) is  TPassBatchFileToExecutable then
       begin
        bFE := TPassBatchFileToExecutable(Form4.StringGrid1.Objects[1, t0]) ;

        if (bFE.ProcHandle_int <> 0) and GetExitCodeProcess(bFE.ProcHandle_int,ExitVal) then  // test if PID is still running
        begin
         // ProcHandle := OpenProcess(PROCESS_ALL_ACCESS,FALSE,bFE.PID_int) ;  //  PROCESS_SET_INFORMATION
         // retVal := ;
          if  not (ExitVal = STILL_ACTIVE) then
          begin
             Form4.LoadResultFiles(bFE, t0, '.log') ; // pass the executed processes info and its line number and the file extension for files to load
             bFE.Free ;
             Form4.StringGrid1.Objects[1, t0] := nil ;
             Form4.StringGrid1.Cells[1, t0]   := '' ;
             Form4.StatusBar1.Panels[1].Text := 'Exit value: ' + inttostr(ExitVal) ;
             Form1.Refresh ;
          end;

          doneLoop := true ;
        end
        else
        begin
           retVal := bFE.CreateBatchProcess ;  // this calls CreateProcess()
           if retVal = false then
             Form4.StatusBar1.Panels[1].Text := 'Error, not able to execute:' + bFE.exeNameAndPathString
           else
             Form4.StringGrid1.Cells[2,t0]   := 'PID: '+ inttostr(integer(bFE.PID_int)) ;
           doneLoop := true ;
        end;

       end ;
     end;
     inc(t0) ;
  end ;

end;

procedure TForm4.Transpose1Click(Sender: TObject);
var
  t0, t1, t2, t3, tRows: integer ;
  s1, s2 : single ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tXY_s  : array[0..1] of single ;
begin

  SelectStrLst.SortListNumeric ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
          tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
          tSR.Transpose ;

          // place text expression of data range in stringgrid1 cell in correct column (=XorYMatrixData)
          if tSR.yCoord.numRows > 1 then
            Form4.StringGrid1.Cells[SG1_COL,selectedRowNum] := '1-' + inttostr(tSR.yCoord.numRows) + ' : 1-' + inttostr(tSR.xCoord.numCols)
          else
            Form4.StringGrid1.Cells[SG1_COL,selectedRowNum] := '1' + inttostr(tSR.yCoord.numRows) + ' : 1-' + inttostr(tSR.xCoord.numCols)  ;


         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
         tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;
  end ;

 // if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;


end;


{
// Old avrage code created a new line and TSpectraRange
// New one just creates a new GLList using the average data
procedure TForm4.Average1Click(Sender: TObject);
var
  t1 : integer ;
  s1, s2 : single ;
  newSR : TSpectraRanges ;
  tSR   : TSpectraRanges ;
  numVars1, numVars2 : integer ;
  selectedRowNum : integer ;
  tStr : string ;
  tbool : boolean ;
  messageResult : word ;
begin
  tbool := true ;
  SelectStrLst.SortListNumeric ;
  
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
  numVars1 :=  TSpectraRanges(Form4.StringGrid1.Objects[2, selectedRowNum]).xCoord.numCols ;

  if (SelectStrLst.Count > 1) then
  begin
    messageResult := MessageDlg('Multiple files selected...'#13'Combine files and then averaged [YES] or average seperately [NO]',mtInformation, [mbYes, mbNo], 0)  ;
  end
  else
   messageResult := mrNo ;

 if messageResult = mrYes then
 begin
    for t1 := 1 to SelectStrLst.Count-1 do
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      numVars2 :=  TSpectraRanges(Form4.StringGrid1.Objects[2, selectedRowNum]).xCoord.numCols ;
      if numVars1 <> numVars2 then
        tbool := false ;
    end ;

    if (tbool = false) then
    begin
      MessageDlg('At least one file has a different number of variables.'#13'can not complete combine operation',mtError, [mbOK], 0)  ;
      exit ;
    end ;
  // create new line in stringgrid and create TSpectraRanges object
    DoStuffWithStringGrid('', 2, 1, numVars1, true, StringGrid1.RowCount-1 ) ;
    newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;   // this is the new spectraRange created in DoStuffWithStringGrid()

    // *** Copy the Y data  ***
    selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
    tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, selectedRowNum])  ;
     newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
    // the files to be combined are the int value of the string that are in the list.
    // Add files rows to the new TSpectraRanges object
    for t1 := 1 to SelectStrLst.Count-1 do
    begin
       selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
       tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, selectedRowNum])  ;
       newSR.yCoord.AddRowsToMatrix(tSR.yCoord,1,tSR.yCoord.numRows) ;
    end ;

    // *** calculate the average and the standard deviation
    newSR.yCoord.Average ;
    newSR.yCoord.Stddev  ;
    // *** place this data in main data area for display (remove old data)
    newSR.yCoord.F_Mdata.Clear ;
    newSR.yCoord.numRows := 3 ;
    newSR.yCoord.F_Mdata.SetSize( newSR.yCoord.SDPrec * newSR.yCoord.numCols * 3 ) ;
    newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
    // Write the average +- the standard deviation
    newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
    newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
    for t1 := 1 to newSR.yCoord.numCols do
    begin
     newSR.yCoord.F_MAverage.Read(s1, 4) ;
     newSR.yCoord.F_MStdDev.Read(s2, 4) ;
     s1 := s1 + s2 ;
     newSR.yCoord.F_Mdata.Write(s1, 4) ;
    end ;
    newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
    for t1 := 1 to newSR.yCoord.numCols do
    begin
     newSR.yCoord.F_MAverage.Read(s1, 4) ;
     newSR.yCoord.F_Mdata.Write(s1, 4) ;
    end ;
    newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
    newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
    for t1 := 1 to newSR.yCoord.numCols do
    begin
     newSR.yCoord.F_MAverage.Read(s1, 4) ;
     newSR.yCoord.F_MStdDev.Read(s2, 4) ;
     s1 := s1 - s2 ;
     newSR.yCoord.F_Mdata.Write(s1, 4) ;
    end ;
    newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
    newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
    newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;

    // *** Copy the x data ***
    newSR.xCoord.CopyMatrix(tSR.xCoord) ;

    StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
    StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'Combined.bin'   ;
    newSR.xCoord.Filename :=  'Combined.bin'   ;

    newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 8) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
  end
  else if messageResult = mrNo then // average each file seperately
  begin
    for t1 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
      // get data to average
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, selectedRowNum])  ;

      // create new line in string grid and new spectra object
      DoStuffWithStringGrid('', 2, 1, tSR.xCoord.numCols, true, StringGrid1.RowCount-1 ) ;
      newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;   // this is the new spectraRange created in DoStuffWithStringGrid()

      // *** Copy the Y data  ***
      newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
      // *** calculate the average and the standard deviation
      newSR.yCoord.Average ;
      newSR.yCoord.Stddev  ;
      // *** place this data in main data area for display (remove old data)
      newSR.yCoord.F_Mdata.Clear ;
      newSR.yCoord.numRows := 3 ;
      newSR.yCoord.F_Mdata.SetSize( newSR.yCoord.SDPrec * newSR.yCoord.numCols * 3 ) ;
      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
      // Write the average +- the standard deviation
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_MStdDev.Read(s2, 4) ;
        s1 := s1 + s2 ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_MStdDev.Read(s2, 4) ;
        s1 := s1 - s2 ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;

      // *** Copy the x data ***
      newSR.xCoord.CopyMatrix(tSR.xCoord) ;

      StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'Averaged.bin'   ;
      newSR.xCoord.Filename :=  'Averaged.bin'   ;

      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 8) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
    end ;
  end ;
end;  }


procedure TForm4.Colour1Click(Sender: TObject); // change colour of spectral line
var
  t1, selectedRowNum : Integer ;

  tSR : TSpectraRanges ;
  tint : integer ;
  tcol: TColor ;
begin
  If ColorDialog1.Execute Then
  begin

   for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
   begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;

     If Form4.StringGrid1.Objects[SG1_COL, selectedRowNum] <> nil then
     begin
       tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

       tcol := ColorDialog1.Color ;
       tint := $00FF0000 ;
       tint := tint and tcol ;
       asm
        MOV    EAX, tint
        SHR    EAX,16
        MOV    tint , EAX
       end ;
       tSR.LineColor[2] :=  tint/255 ;

       tcol := ColorDialog1.Color ;
       tint := $0000FF00 ;
       tint := tint and tcol ;
       asm
        MOV    EAX, tint
        SHR    EAX,8
        MOV    tint , EAX
       end ;
       tSR.LineColor[1] :=  tint/255 ;

       tcol := ColorDialog1.Color ;
       tint := $000000FF ;
       tint := tint and tcol ;
       tSR.LineColor[0] :=  tint/255 ;

       tSR.CreateGLList('1-', Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType ) ;
       tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      end ;
    end ;
   end ;
 // if not Form4.CheckBox7.Checked then
   // Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  Form1.FormResize(Form2)  ;
end;

procedure TForm4.MeanCentre1Click(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
begin
  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      tSR.yCoord.MeanCentre ;
      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
         tSR.CopyDataTo2DSpecR ;
         tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;

   end ;

  end ;
  if not Form4.CheckBox7.Checked then
  form1.UpdateViewRange() ;
  form1.Refresh ;

end;

procedure TForm4.VarianceScale1Click(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
begin
  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      tSR.yCoord.ColStandardize ;

      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
         tSR.CopyDataTo2DSpecR ;
         tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;

   end ;

  end ;
  if not Form4.CheckBox7.Checked then
    form1.UpdateViewRange() ;
  form1.Refresh ;
end;

procedure TForm4.Unmeancentre1Click(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
begin
  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      tSR.yCoord.F_MAverage.Seek(0,soFromBeginning) ;
      tSR.yCoord.AddVectToMatrixRows(tSR.yCoord.F_MAverage) ;
      tSR.yCoord.meanCentred := false ;
      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
         tSR.CopyDataTo2DSpecR ;
         tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;

   end ;

  end ;
  if not Form4.CheckBox7.Checked then
    form1.UpdateViewRange() ;
  form1.Refresh ;
end;

procedure TForm4.UnvarianceScale1Click(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tempMat : TMatrix ;
begin
  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      tSR.yCoord.F_MStdDev.Seek(0,soFromBeginning) ;
      tempMat := tSR.yCoord.ReturnTMatrixFromTMemStream( tSR.yCoord.F_MStdDev , tSR.yCoord.SDPrec, tSR.yCoord.numRows, tSR.yCoord.numCols) ;
      tSR.yCoord.MultiplyMatrixByVect (tempMat) ;
      tempMat.Free ;
      tSR.yCoord.colStandardized := false ;
      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
         tSR.CopyDataTo2DSpecR ;
         tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
         tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;

   end ;

  end ;
  if not Form4.CheckBox7.Checked then
  form1.UpdateViewRange() ;
  form1.Refresh ;

end;


// uses the first row of the last spectrum as the xCoord data
// but only if the number of columns are the same.
procedure TForm4.UseAsXcoords1Click(Sender: TObject);
Var
  t0, t1, selectedRowNum, lastSelectedNum  : integer ;
  s1  : single ;
  tSR1, tSR2, newSR : TSpectraRanges ;
  tMat1 : TMatrix ;
begin

  SelectStrLst.SortListNumeric ;
  lastSelectedNum  := StrToInt(SelectStrLst.Strings[SelectStrLst.Count-1]) ;
  if Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,lastSelectedNum] is  TSpectraRanges  then
  begin
    // the first row of this TSpectra (tSR1) will be the xCoord data for all other TSpectra selected
    tSR1  :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,lastSelectedNum]) ;
    // this TMatrix will hold the data wanted
    tMat1 := TMatrix.Create2(tSR1.yCoord.SDPrec,1,tSR1.yCoord.numCols) ;
    tSR1.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;
    for t1 := 0 to tSR1.yCoord.numCols - 1 do    // copy over the first lrow of the last TSpectra
    begin
       tSR1.yCoord.F_Mdata.Read(s1, tSR1.yCoord.SDPrec) ;
       tMat1.F_Mdata.Write(s1, tSR1.yCoord.SDPrec)
    end;
    tSR1.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
    tMat1.F_Mdata.Seek(0,soFromBeginning) ;

    for t0 := 0 to SelectStrLst.Count-2 do // for each file selected (but not the last one)
    begin
      selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
      if Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum] is  TSpectraRanges  then
      begin
        tSR2  :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;
        if tSR2.xCoord.numCols = tSR1.xCoord.numCols then // if they have the same number of columns
        begin


          // create new line in stringgrid and create TSpectraRanges object for each TSpectraRanges selected (one at a time)
          DoStuffWithStringGrid('', 2, tSR2.yCoord.numRows, tSR2.yCoord.numCols , true, StringGrid1.RowCount-1 ) ;
          // point pointer newSR to the new TSpectraRange object
          newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2]) ;
          // copy the original data
          newSR.CopySpectraObject(tSR2);

          // *********** this does the actual functionality ***************
          newSR.yCoord.F_MData.Seek(0,soFromBeginning) ;
          // copy the xCoord data from tMat1
          //newSR.xCoord.Free ;
          tMat1.F_Mdata.Seek(0,soFromBeginning) ;
          newSR.xCoord.CopyMatrix(tMat1);

          // do display and interface stuff
          newSR.GLListNumber := GetLowestListNumber ;
          if tSR2.fft.dtime  <> 0 then
            newSR.fft.CopyFFTObject(tSR2.fft) ;
          StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
          StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'new_x_coords' + '_' + Form4.StringGrid1.Cells[1,selectedRowNum] ; // this is the file name displayed in column 2 ;
          // newSR.xyScatterPlot := true ;
          newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
          newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
        end ; //  if they have dsame number of columns
      end;  // if it is a TSpectraRanges object
   end;  // for each file selected
   end ;

   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;
   tMat1.Free ;
end;



{procedure TForm4.All1Click(Sender: TObject);
var
  t1 : integer ;
  newSR : TSpectraRanges ;
  tSR   : TSpectraRanges ;
  numVars1, numVars2 : integer ;
  selectedRowNum : integer ;
  tStr : string ;
  tbool, hasImaginary : boolean ;
  tMat : TMatrix ;
begin
  tbool := true ;

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
  hasImaginary := false ;
  tSr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
  numVars1 := tSr.xCoord.numCols ;
  if tSr.yImaginary <> nil then
       hasImaginary := true ;
  for t1 := 1 to SelectStrLst.Count-1 do
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     tSr :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
     numVars2 := tSr.xCoord.numCols ;
     if numVars1 <> numVars2 then
       tbool := false ;
     if tSR.yImaginary <> nil then
       hasImaginary := true ;
  end ;

  if (tbool = false) then
  begin
    MessageDlg('At least one file has a different number of variables.'#13'can not complete combine operation',mtError, [mbOK], 0)  ;
    exit ;
  end ;

  // create new line in stringgrid and create TSpectraRanges object
  DoStuffWithStringGrid('', 2, 1, numVars1, true, StringGrid1.RowCount-1 ) ;

  newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;  // this is the new combined data in new row of list

  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
  tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
  newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
  // the files to be combined are the int value of the string that are in the list.
  // Add files rows to the new TSpectraRanges object
  for t1 := 1 to SelectStrLst.Count-1 do
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
     newSR.yCoord.AddRowsToMatrix(tSR.yCoord,1,tSR.yCoord.numRows) ;
  end ;

  if hasImaginary then
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
     tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
     if newSR.yImaginary = nil then
       newSR.yImaginary := TMatrix.Create(newSR.yCoord.SDPrec div 4) ;  // create the Imaginary matrix
     if tSR.yImaginary <> nil then
       newSR.yImaginary.CopyMatrix(tSR.yImaginary) ;  // copy the first matrix
     // the files to be combined are the int value of the string that are in the list.
     // Add files rows to the new TSpectraRanges object
     for t1 := 1 to SelectStrLst.Count-1 do
     begin
        selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
        if tSR.yImaginary <> nil then
        begin
          newSR.yImaginary.AddRowsToMatrix(tSR.yImaginary,1,tSR.yImaginary.numRows) ;
        end
        else
        begin
          tMat := TMatrix.Create2(newSR.yCoord.SDPrec div 4,tSR.yCoord.numRows,tSR.yCoord.numCols) ;
          tMat.Zero(tMat.F_Mdata) ;
          newSR.yImaginary.AddRowsToMatrix(tMat,1,tMat.numRows) ;
          tMat.Free ;
        end ;
     end ;
  end ;


  newSR.xCoord.CopyMatrix(tSR.xCoord) ;

  StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
  StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'Combined.bin'   ;
  newSR.xCoord.Filename :=  'Combined.bin'   ;

  newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
  newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType ) ;


end;   }

procedure TForm4.All2Click(Sender: TObject);
var
  t1, t2 : integer ;
  newSR : TSpectraRanges ;
  tSR   : TSpectraRanges ;
  numVars1, numVars2 : integer ;
  selectedRowNum : integer ;
  tStr : string ;
  tbool : boolean ;
begin

  if SelectStrLst.Count = 1 then
  begin
    selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;
    if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
    begin
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;
      if  tSR.yCoord.numRows > 1 then
      begin
        tStr := extractfilename(tSR.xCoord.Filename) ;
        for t1 := 1 to tSR.yCoord.numRows do
        begin
          // create new line in stringgrid and create TSpectraRanges object

          DoStuffWithStringGrid('', 2, 1, tSR.yCoord.numRows , true, StringGrid1.RowCount-1 ) ;


          newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2]) ;
          newSR.yCoord.FetchDataFromTMatrix(inttostr(t1),'1-'+inttostr(tSR.YCoord.numCols),tSR.yCoord) ;
          if tSR.yImaginary <> nil then
          begin
            newSR.yImaginary := TMatrix.Create( newSR.yCoord.SDPrec div 4 ) ;
            newSR.yImaginary.FetchDataFromTMatrix(inttostr(t1),'1-'+inttostr(tSR.yImaginary.numCols),tSR.yImaginary) ;
          end ;
          newSR.xCoord.CopyMatrix(tSR.xCoord) ;
          if tSR.fft.dtime  <> 0 then
            newSR.fft.CopyFFTObject(tSR.fft) ;

          StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
          StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  inttostr(t1)+ '_' + tStr ;
          newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
          newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
        end ;
      end ;
    end ;
  end ;

end;

procedure TForm4.alldata1Click(Sender: TObject);
// display all data (not just averaged data or variance data
var
  t1 : integer ;
  s1, s2 : single ;
  tSR   : TSpectraRanges ;
  selectedRowNum : integer ;
  tStr : string ;
begin

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;


    for t1 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
        // get data to average
        selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
        tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;


        // *** place this data in main data area for display (remove old data)
        tSR.averageIsDisplayed := false ;
        tSR.varianceIsDisplayed := false ;
        StringGrid1.Cells[SG1_COL, selectedRowNum] := ' : '+'1-'+inttostr(tSR.yCoord.numCols) ;

        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),tSR.lineType ) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
   end ;
  if not Form4.CheckBox7.Checked then
    form1.UpdateViewRange() ;
  form1.Refresh ;
end;


// Removes a row at a time and replaces the xCoord matrix with it
procedure TForm4.As2DPlots1Click(Sender: TObject);
var
  t1, t2 : integer ;
  s1 : single ;
  tStr : string ;
  tSR, newSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tempStream : TMemoryStream ;
begin

  tempStream := TMemoryStream.Create ;
  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        // this is the file to be split up into scatter plots
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        if  tSR.yCoord.numRows > 1 then
        begin
          tStr := extractfilename(tSR.xCoord.Filename) ;
          for t2 := 1 to tSR.yCoord.numRows do
          begin
            // create new line in stringgrid and create TSpectraRanges object
            DoStuffWithStringGrid('', 2, 1, tSR.yCoord.numRows , true, StringGrid1.RowCount-1 ) ;
            // point pointer newSR to the new TSpectraRange object
            newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2]) ;
            // copy the original data
            newSR.CopySpectraObject(tSR);
            newSR.GLListNumber := GetLowestListNumber ;
            // modify the xCoord data to be one of the original yCoord rows
            newSR.xCoord.FetchDataFromTMatrix(inttostr(t2),'1-'+inttostr(tSR.YCoord.numCols),newSR.yCoord) ;

            if tSR.fft.dtime  <> 0 then
              newSR.fft.CopyFFTObject(tSR.fft) ;

            StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
            StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  inttostr(t2)+ '_' + tStr ;
            newSR.xyScatterPlot := true ;
            newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
            newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 10) ;
          end ;
        end
     end ;

  end ;

  if not Form4.CheckBox7.Checked then
  Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;




procedure TForm4.FlipXAxis1Click(Sender: TObject);
var
  t1, t2 : integer ;
  s1 : single ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  tempStream : TMemoryStream ;
begin

  tempStream := TMemoryStream.Create ;
  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
          tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

          tempStream.CopyFrom(tSR.xCoord.F_Mdata,0) ;  //  copies whole xCoor data

          tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
          for t2 := 1 to tSr.yCoord.numCols do
          begin
            tempStream.Seek(-(t2*4),soFromEnd) ;
            tempStream.Read(s1,4) ;
            tSR.xCoord.F_Mdata.Write(s1,4) ;
          end ;

          tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
          tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;

  end ;

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;


procedure TForm4.About1Click(Sender: TObject);
var
  ts : string ;
begin
  ts := 'Josh Bowden' ;
  messagedlg('This software copyright ' +ts+ ' 2007. This version is NOT public domain or licensed for use. Use at own risk :-).',mtInformation,[mbOk],0) ;
end;

procedure TForm4.VectorNormalise1Click(Sender: TObject);
var
  t1, t2 : integer ;
  MKLa : pointer ;
  MKLtint : Integer ;
  lengthSSEVects_s : single   ;
  lengthSSEVects_d : double ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;

begin
  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
         tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

         MKLa := tSR.yCoord.F_Mdata.Memory ;
         MKLtint := 1 ;
         // normalise input vector  -
         for t2 := 1 to tSR.yCoord.numRows do
         begin
           if  (tSR.yCoord.SDPrec = 4) and (tSR.yCoord.complexMat=1) then
           begin
             lengthSSEVects_s := snrm2 ( tSR.yCoord.numCols , MKLa, MKLtint ) ;
             if lengthSSEVects_s <> 0 then
             lengthSSEVects_s := 1/lengthSSEVects_s ;
             sscal (tSR.yCoord.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
           end
           else
           if  (tSR.yCoord.SDPrec = 8) and (tSR.yCoord.complexMat=1) then
            begin
              lengthSSEVects_d := dnrm2 ( tSR.yCoord.numCols , MKLa, MKLtint ) ;
              if lengthSSEVects_s <> 0 then
                lengthSSEVects_d := 1/lengthSSEVects_d ;
              dscal (tSR.yCoord.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
            end
           else
           if  (tSR.yCoord.SDPrec = 4) and (tSR.yCoord.complexMat=2) then
           begin
                lengthSSEVects_s := scnrm2 ( tSR.yCoord.numCols , MKLa, MKLtint ) ;
                if lengthSSEVects_s <> 0 then
                lengthSSEVects_s := 1/lengthSSEVects_s ;
                csscal (tSR.yCoord.numCols,lengthSSEVects_s,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_s
           end
           else
           if  (tSR.yCoord.SDPrec = 8) and (tSR.yCoord.complexMat=2) then
           begin
                lengthSSEVects_d := dznrm2 ( tSR.yCoord.numCols , MKLa, MKLtint ) ;
                if lengthSSEVects_s <> 0 then
                lengthSSEVects_d := 1/lengthSSEVects_d ;
                zdscal (tSR.yCoord.numCols,lengthSSEVects_d,MKLa,MKLtint) ;  // multiply each element by 1/lengthSSEVects_d
           end  ;
           MKLa := tSR.yCoord.MovePointer(MKLa,tSR.yCoord.numCols * tSR.yCoord.SDPrec * tSR.yCoord.complexMat) ;
         end ;

         tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
         tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;

  end ;
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;

procedure TForm4.ViewAverageClick(Sender: TObject);
var
  t1 : integer ;
  s1, s2 : single ;
  tSR   : TSpectraRanges ;
  selectedRowNum : integer ;
  tStr : string ;
begin

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;


    for t1 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
      // get data to average
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

      if tSR.averageIsDisplayed = false then
      begin
        // *** calculate the average and the standard deviation
        tSR.yCoord.Average ;
        tSR.yCoord.Stddev  ;
        // *** place this data in main data area for display (remove old data)
        tSR.averageIsDisplayed := true ;
        tSR.varianceIsDisplayed := false ;
        StringGrid1.Cells[SG1_COL, selectedRowNum ] := 'Ave : '+'1-'+inttostr(tSR.yCoord.numCols) ;

        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 8) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
      end ;
   end ;
  if not Form4.CheckBox7.Checked then
    form1.UpdateViewRange() ;
  form1.Refresh ;

end;

procedure TForm4.ExtractAverage1Click(Sender: TObject);
var
  t0, t1 : integer ;
  s1, s2 : single ;
  tSR, newSR   : TSpectraRanges ;
  selectedRowNum : integer ;
  tStr : string ;
begin

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;


    for t0 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
      // get data to average
      selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

           // create new line in string grid and new spectra object
      DoStuffWithStringGrid('', 2, 1, tSR.xCoord.numCols, true, StringGrid1.RowCount-1 ) ;
      newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;   // this is the new spectraRange created in DoStuffWithStringGrid()

      // *** Copy the Y data  ***
      newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
      // *** calculate the average and the standard deviation
      newSR.yCoord.Average ;
      newSR.yCoord.Stddev  ;
      // *** place this data in main data area for display (remove old data)
      newSR.yCoord.F_Mdata.Clear ;
      newSR.yCoord.numRows := 3 ;
      newSR.yCoord.F_Mdata.SetSize( newSR.yCoord.SDPrec * newSR.yCoord.numCols * 3 ) ;
      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
      // Write the average +- the standard deviation
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_MStdDev.Read(s2, 4) ;
        s1 := s1 + s2 ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;
      for t1 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MAverage.Read(s1, 4) ;
        newSR.yCoord.F_MStdDev.Read(s2, 4) ;
        s1 := s1 - s2 ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;
      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MAverage.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MStdDev.Seek( 0,soFromBeginning ) ;

      // *** Copy the x data ***
      newSR.xCoord.CopyMatrix(tSR.xCoord) ;

      StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'line_'+ inttostr( selectedRowNum ) + '_averaged'   ;
      newSR.xCoord.Filename :=  'Averaged.bin'   ;

      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 8) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
   end ;
   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;

end ;



procedure TForm4.ViewVariance1Click(Sender: TObject);
var
  t1 : integer ;
  s1, s2 : single ;
  tSR   : TSpectraRanges ;
  selectedRowNum : integer ;
  tStr : string ;
begin

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;


    for t1 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
      // get data to average
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

      if tSR.varianceIsDisplayed = false then
      begin
        // *** calculate the average and the standard deviation
        tSR.yCoord.Variance ;
        // *** place this data in main data area for display (remove old data)
        tSR.averageIsDisplayed := false  ;
        tSR.varianceIsDisplayed := true ;
        StringGrid1.Cells[SG1_COL, selectedRowNum ] := 'Var : '+'1-'+inttostr(tSR.yCoord.numCols) ;

        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 8) ;  // 8 means plot 3 lines 1st and 3rd are dashed (stdev) and middle one is solid
      end ;
   end ;
  if not Form4.CheckBox7.Checked then
    form1.UpdateViewRange() ;
  form1.Refresh ;

end;

procedure TForm4.ExtractVariance1Click(Sender: TObject);
var
  t1, t2 : integer ;
  s1, s2 : single ;
  tSR, newSR   : TSpectraRanges ;
  selectedRowNum : integer ;
  tStr : string ;
begin

  SelectStrLst.SortListNumeric ;
  selectedRowNum := StrToInt(SelectStrLst.Strings[0]) ;


    for t1 := 0 to SelectStrLst.Count -1 do   // for each file average and make new line on string grid
    begin
      // get data to average
      selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum])  ;

           // create new line in string grid and new spectra object
      DoStuffWithStringGrid('', 2, 1, tSR.xCoord.numCols, true, StringGrid1.RowCount-1 ) ;
      newSR :=  TSpectraRanges(Form4.StringGrid1.Objects[2, StringGrid1.RowCount-2 ]) ;   // this is the new spectraRange created in DoStuffWithStringGrid()

      // *** Copy the Y data  ***
      newSR.yCoord.CopyMatrix(tSR.yCoord) ;  // copy the first matrix
      // *** calculate the average and the standard deviation
      newSR.yCoord.Variance ;

      // *** place this data in main data area for display (remove old data)
      newSR.yCoord.F_Mdata.Clear ;
      newSR.yCoord.numRows := 1 ;
      newSR.yCoord.F_Mdata.SetSize( newSR.yCoord.SDPrec * newSR.yCoord.numCols * 1 ) ;
      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;

      newSR.yCoord.F_MVariance.Seek( 0,soFromBeginning ) ;
      for t2 := 1 to newSR.yCoord.numCols do
      begin
        newSR.yCoord.F_MVariance.Read(s1, 4) ;
        newSR.yCoord.F_Mdata.Write(s1, 4) ;
      end ;

      newSR.yCoord.F_Mdata.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MVariance.Seek( 0,soFromBeginning ) ;
      newSR.yCoord.F_MVariance.Clear ;

      // *** Copy the x data ***
      newSR.xCoord.CopyMatrix(tSR.xCoord) ;

      StringGrid1.Cells[2, StringGrid1.RowCount-2 ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      StringGrid1.Cells[1, StringGrid1.RowCount-2 ] :=  'line_'+ inttostr( selectedRowNum ) + '_variance'   ;
      newSR.xCoord.Filename :=  'line_'+ inttostr( selectedRowNum ) + '_variance'   ;

      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3) ;  // 3 means plot dot with line
   end ;
   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;

end;

end.



