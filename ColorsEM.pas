unit ColorsEM;

interface

uses
  Windows, OpenGL, Messages, SysUtils,  Classes, Graphics, Controls, Forms, Dialogs,
  Menus, StdCtrls, Checklst, FileCtrl, Buttons, ComCtrls, Math, Grids,
  ExtCtrls, PCResultsObjects, BLASLAPACKfreePas, TSpectraRangeObject, TBatchBasicFunctions;

type
  TForm2 = class(TForm)
    SpeedButton1: TSpeedButton;
    GroupBox2: TGroupBox;
    Edit10: TEdit;
    Edit11: TEdit;
    ComboBox2: TComboBox;
    Label8: TLabel;
    Label18: TLabel;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    CheckBox3: TCheckBox;
    Edit16: TEdit;
    GroupBox1: TGroupBox;
    Label15: TLabel;
    Label16: TLabel;
    Label17: TLabel;
    XDataRowColEdit: TEdit;
    YDataRangeEdit: TEdit;
    ComboBox3: TComboBox;
    ComboBox4: TComboBox;
    TabSheet2: TTabSheet;
    Label5: TLabel;
    Label6: TLabel;
    Edit14: TEdit;
    CheckBox2: TCheckBox;
    Button2: TButton;
    Edit15: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    TabSheet3: TTabSheet;
    Label11: TLabel;
    Label12: TLabel;
    CheckListBox1: TCheckListBox;
    FileListBox1: TFileListBox;
    Edit12: TEdit;
    Edit13: TEdit;
    CheckBox1: TCheckBox;
    TabSheet5: TTabSheet;
    SpeedButton6: TSpeedButton;
    Label21: TLabel;
    Label22: TLabel;
    Edit25: TEdit;
    Button3: TButton;
    Memo2: TMemo;
    TabSheet6: TTabSheet;   // object in col(0)=TBitmap; col(1)=TSpectraRanges; col(2)=TMemoryStream; 
    Edit26: TEdit;
    Edit27: TEdit;
    Edit28: TEdit;
    DelimiterEditBox: TEdit;
    Bevel2: TBevel;
    Bevel5: TBevel;
    SpeedButton5: TSpeedButton;
    SpeedButton7: TSpeedButton;
    Label7: TLabel;
    Panel2: TPanel;
    Fourier: TTabSheet;
    Bevel6: TBevel;
    FFTButton1: TButton;
    Edit29: TEdit;
    CheckBox9: TCheckBox;
    TabSheet9: TTabSheet;
    Panel3: TPanel;
    ForwardFFTRB1: TRadioButton;
    ReverseFFTRB1: TRadioButton;
    Button5: TButton;
    hannWindowCB1: TCheckBox;
    ComboBox1: TComboBox;
    ViewRealCB12: TCheckBox;
    ViewImaginaryCB13: TCheckBox;
    TabSheet10: TTabSheet;
    Button8: TButton;
    RadioButton11: TRadioButton;
    RadioButton12: TRadioButton;
    Edit34: TEdit;
    Edit35: TEdit;
    Label13: TLabel;
    SpeedButton8: TSpeedButton;
    Edit36: TEdit;
    Edit37: TEdit;
    Label29: TLabel;
    Label31: TLabel;
    Label32: TLabel;
    Panel4: TPanel;
    Label35: TLabel;
    Button9: TButton;
    Label33: TLabel;
    RadioButton13: TRadioButton;
    RadioButton14: TRadioButton;
    CheckBox15: TCheckBox;
    Button10: TButton;
    DataInColsRadButton: TRadioButton;
    DataInRowsRadButton: TRadioButton;
    XRangeEditBox: TEdit;
    Label10: TLabel;
    defaultResTextBox: TEdit;
    Label20: TLabel;
    Label26: TLabel;
    RBXData: TRadioButton;
    RBYData: TRadioButton;
    ShowCursor: TCheckBox;
    n2DImagingGB: TGroupBox;
    NumColsEB1: TEdit;
    Label27: TLabel;
    Label28: TLabel;
    NumRowsEB1: TEdit;
    Label43: TLabel;
    ImageNumberTB1: TEdit;
    FrequencySlider1: TTrackBar;
    Label48: TLabel;
    Label47: TLabel;
    Label46: TLabel;
    Label4: TLabel;
    PixelSpaceX_EB: TEdit;
    Is2DdataRB: TRadioButton;
    IsNative2DdataRB: TRadioButton;
    Not2DdataRB: TRadioButton;
    Label34: TLabel;
    LinearInterpol1: TRadioButton;
    Label14: TLabel;
    Label36: TLabel;
    InterpolStart1: TEdit;
    InterpolStep1: TEdit;
    InterpolExecute1: TButton;
    AxisLabelsGB1: TGroupBox;
    CheckBox4: TCheckBox;
    Label25: TLabel;
    Edit30: TEdit;
    AverReduceGB1: TGroupBox;
    ReduceBtn: TButton;
    XVarRB: TRadioButton;
    SpectraRB: TRadioButton;
    Spectra2D: TRadioButton;
    AveReduceNumTB: TEdit;
    Label23: TLabel;
    Edit5: TEdit;
    Edit17: TEdit;
    SmoothGB1: TGroupBox;
    Button4: TButton;
    ZeroDataCB1: TCheckBox;
    Edit33: TEdit;
    Edit32: TEdit;
    Label24: TLabel;
    Label30: TLabel;
    ComboBox5: TComboBox;
    FourierSmoothRB1: TRadioButton;
    AverageSmoothRB1: TRadioButton;
    Label19: TLabel;
    YAxisTypeDDB1: TComboBox;
    PixelSpaceY_EB: TEdit;
    ScaleImageEditBox1: TEdit;
    Label37: TLabel;
    NoImageCB1: TCheckBox;
    Edit4: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Button1: TButton;
    Edit20: TEdit;
    Label38: TLabel;
    Label39: TLabel;
    Label40: TLabel;
    Label41: TLabel;
    Label42: TLabel;
    Button6: TButton;
    Edit21: TEdit;
    Label44: TLabel;
    Edit22: TEdit;
    Button7: TButton;
    CheckBox5: TCheckBox;
    CheckBox6: TCheckBox;
    difButton: TButton;
    Edit23: TEdit;
    SubfirstSpectFromRestB: TButton;
    RemoveImaginaryMatBtn: TButton;
    BaselineCorrectBtn: TButton;
    BaselineCorrSB9: TSpeedButton;
    SnapToPointsCB: TCheckBox;
    Edit24: TEdit;
    Edit31: TEdit;
    Label52: TLabel;
    Edit38: TEdit;
    Edit39: TEdit;
    PeakHeightCB: TCheckBox;
    Label53: TLabel;
    NormaliseByIntegBtn: TButton;
    imageSliceValEB: TEdit;
    TTabSheet11: TTabSheet;
    Label9: TLabel;
    Edit1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Edit2: TEdit;
    Edit3: TEdit;
    Label3: TLabel;
    Label49: TLabel;
    Label50: TLabel;
    CalBarPosXEB1: TEdit;
    CalBarSizeEB1: TEdit;
    Label51: TLabel;
    CalBarPosYEB1: TEdit;
    CalBarMoveCB1: TCheckBox;
    CalBarResizeCB1: TCheckBox;
    CalBarHideCB1: TCheckBox;
    ImageMaxColorValEB: TEdit;
    ImageMaxColorCB: TCheckBox;
    LineTypeComboBox: TComboBox;
    Label54: TLabel;
    Label55: TLabel;
    ImageMinColorValEB: TEdit;
    ImageMinColorCB: TCheckBox;
    CaptureImageBTN: TButton;
    Label56: TLabel;
    Edit40: TEdit;
    Edit41: TEdit;
    Edit42: TEdit;
    TrackBar1: TTrackBar;
    TrackBar3: TTrackBar;
    TrackBar4: TTrackBar;
    TrackBar5: TTrackBar;
    TrackBar6: TTrackBar;
    TrackBar7: TTrackBar;
    Image1: TImage;
    SetStartTo1stValue: TCheckBox;
    Label57: TLabel;
    ImageColorPresetCB: TComboBox;
    Edit43: TEdit;
    Edit44: TEdit;
    Edit45: TEdit;
    Edit46: TEdit;
    Edit47: TEdit;
    Edit48: TEdit;
    CropXLabel: TLabel;
    CropMinTB: TEdit;
    CropMaxTB: TEdit;
    xUnitsCB: TCheckBox;
    CropXRangeBtn: TButton;
    YDataRB1: TRadioButton;
    XDataRB1: TRadioButton;
    BetweenPts: TCheckBox;
    MinNoisePreprocessCB: TRadioButton;
    ZeroFillLabelLB: TLabel;
    SwapBytesInRAWfile: TCheckBox;
    RescaleXBtn: TButton;
    Label61: TLabel;
    GroupBox3: TGroupBox;
    ColRangeEB: TEdit;
    Label62: TLabel;
    Label60: TLabel;
    RowRangeEB: TEdit;
    NumberOfBinsEB: TEdit;
    Label59: TLabel;
    DataFromRowsRB: TRadioButton;
    DataFromColsRB: TRadioButton;
    CreateHistogramBtn: TButton;
    UseBLASCB1: TCheckBox;
    DendroControlGB: TGroupBox;
    DendroPlacePeakstCB: TCheckBox;
    DendroAddSB: TSpeedButton;
    DendroSubtractSB: TSpeedButton;
    DendroAverageRingStrutureBTN: TButton;
    DendroYearEB: TEdit;
    DendroBackYearSB: TSpeedButton;
    DendroForwardYearSB: TSpeedButton;
    DendroYearViewableLabel1: TLabel;
    DendroAddPointToSelectedRowLabel1: TLabel;
    DendroAddPointsToRowEB: TEdit;
    DendroOffsetTraceLabel: TLabel;
    DendroOffsetTracePercent: TEdit;
    Button11: TButton;
    DendroSumOverYearBTN: TButton;
    DendroSumOverYearsPnl: TPanel;
    DendroIntegrateStepRB: TRadioButton;
    DendroSumFullStepRB: TRadioButton;
    DendroSOYStartEB: TEdit;
    DendroSOYStepEB: TEdit;
    DendroSOYStartLBL: TLabel;
    DendroSOYStepLBL: TLabel;
    DendroAddYearsToDataBTN: TButton;
    DendroMODISDataCB: TCheckBox;
    DendroMODISNumberOfBands: TEdit;
    DendroMODISNumBandsLBL: TLabel;
    DendroFindScaleMODIS_CB: TCheckBox;
    InterpolateMODISBtn: TButton;
    MODISInterpolValueEditBx: TEdit;
    DendroSOYXStepEB: TEdit;
    Label45: TLabel;
    DendroIntegDiskAreaCB: TCheckBox;
    RAWInputOffsetBytesTB: TEdit;
    RAWByteOffset: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit1MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckListBox1ClickCheck(Sender: TObject);
    procedure Edit12MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit12MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure CheckListBox1Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure Edit8MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit8MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit9MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit13MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure CheckBox2Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Copy1Click(Sender: TObject);
    procedure CheckBox4Click(Sender: TObject);
    procedure StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormResize(Sender: TObject);
    procedure SpeedButton7Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure CheckBox3Click(Sender: TObject);
    procedure CheckBox9Click(Sender: TObject);
    procedure difButtonClick(Sender: TObject);
    procedure FFTButton1Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
    procedure hannWindowCB1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Button8Click(Sender: TObject);
    procedure SpeedButton8Click(Sender: TObject);
    procedure Button9Click(Sender: TObject);
    procedure RadioButton13Click(Sender: TObject);
    procedure RadioButton14Click(Sender: TObject);
    procedure Button10Click(Sender: TObject);
    procedure PCRClick(Sender: TObject);
    procedure Save1Click(Sender: TObject);
    procedure DataInColsRadButtonClick(Sender: TObject);
    procedure DataInRowsRadButtonClick(Sender: TObject);
    procedure XRangeEditBoxChange(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure Edit30KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ReduceBtnClick(Sender: TObject);
    procedure ShowCursorClick(Sender: TObject);
    procedure NumColsEB1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FrequencySlider1Change(Sender: TObject);
    procedure ImageNumberTB1Change(Sender: TObject);
    procedure ImageNumberTB1KeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure InterpolExecute1Click(Sender: TObject);
    procedure ComboBox3Exit(Sender: TObject);
    procedure ComboBox3DblClick(Sender: TObject);
    procedure ComboBox4DblClick(Sender: TObject);
    procedure ComboBox4Exit(Sender: TObject);
    procedure ComboBox2DblClick(Sender: TObject);
    procedure ComboBox2Exit(Sender: TObject);
    procedure Edit30Change(Sender: TObject);
    procedure YAxisTypeDDB1Change(Sender: TObject);
    procedure ViewRealCB12Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button6Click(Sender: TObject);
    procedure Button7Click(Sender: TObject);
    procedure CheckBox5Click(Sender: TObject);
    procedure CalBarPosXEB1Change(Sender: TObject);
    procedure CalBarPosYEB1Change(Sender: TObject);
    procedure CalBarMoveCB1Click(Sender: TObject);
    procedure CalBarResizeCB1Click(Sender: TObject);
    procedure SubfirstSpectFromRestBClick(Sender: TObject);
    procedure RemoveImaginaryMatBtnClick(Sender: TObject);
    procedure BaselineCorrSB9Click(Sender: TObject);
    procedure BaselineCorrectBtnClick(Sender: TObject);
    procedure PeakHeightCBClick(Sender: TObject);
    procedure CheckBox15Click(Sender: TObject);
    procedure imageSliceValEBKeyPress(Sender: TObject; var Key: Char);
    procedure CaptureImageBTNClick(Sender: TObject);
    procedure ImageMaxColorCBClick(Sender: TObject);
    procedure ImageMinColorCBClick(Sender: TObject);
    procedure ImageMaxColorValEBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImageMaxColorValEBExit(Sender: TObject);
    procedure ImageMinColorValEBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure ImageMinColorValEBExit(Sender: TObject);
    procedure CalBarHideCB1Click(Sender: TObject);
    procedure LineTypeComboBoxChange(Sender: TObject);
    procedure TrackBar1Change(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ImageColorPresetCBChange(Sender: TObject);
    procedure Edit43MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit43MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure ImageNumberTB1Click(Sender: TObject);
    procedure CropXRangeBtnClick(Sender: TObject);
    procedure NoImageCB1Click(Sender: TObject);
    procedure RescaleXBtnClick(Sender: TObject);
    procedure CreateHistogramBtnClick(Sender: TObject);
    procedure DendroForwardYearSBClick(Sender: TObject);
    procedure DendroBackYearSBClick(Sender: TObject);
    procedure DendroYearEBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure DendroYearEBEnter(Sender: TObject);
    procedure DendroYearEBClick(Sender: TObject);
    procedure DendroOffsetTracePercentKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DendroAddPointsToRowEBKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DendroPlacePeakstCBClick(Sender: TObject);
    procedure DendroYearEBKeyUp(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure DendroAverageRingStrutureBTNClick(Sender: TObject);
    procedure DendroSumOverYearBTNClick(Sender: TObject);
    procedure DendroAddYearsToDataBTNClick(Sender: TObject);
    procedure DendroMODISDataCBClick(Sender: TObject);
    procedure InterpolateMODISBtnClick(Sender: TObject);
//    procedure DendroPlacePeakstCBClick(Sender: TObject);

  private
    { Private declarations }
  public
    MVA_executable : string ;  // external exe for running some processes
    procedure AverageSmooth ;  // Smooth data using moving average
    procedure FourierSmooth ;
    procedure MinNoisePreprocess ; // subtracts following spectra from the one before (until end, which is zeroed)
    procedure SelfDeconvolution  ;
    procedure InstrumentalDeconvolution ;
    function  GetWhichLineToDisplay : integer ;
    procedure LinearInterpolate(tSR, newSR: TSpectraRanges; start, step: single) ;

    procedure DendroStretchViewToYear(start, finish :single) ;  // sets OrthoVarXMin and OrthoVarXMax to input range (start/finish)
    function DendroSumFullStep(startIn, stepIn, xStepIn : Single ; IntegDiskBool :boolean;  TraceDRIn : TSpectraRanges) : TSpectraRanges ;
    function DendroSumContinuous(startIn, stepIn, xStepIn : Single ;  IntegDiskBool :boolean; TraceDRIn : TSpectraRanges) : TSpectraRanges ;

    { Public declarations }
  end;

var
  Form2: TForm2;
  MouseDownMat : boolean ;
  originalTBText : single ;
  PalletColorsBitMap : TBitmap ;  // added for holding bitmap of colors being used for pallet of 2D image textures

implementation

Uses EmissionGL,  SpectraLibrary, FileInfo, TMatrixObject, batchEdit ;
{$R *.DFM}


procedure TForm2.FormCreate(Sender: TObject);
Var
  TempList : TStringList ;
  TempStr1 : String ;
  TempInt1, TempInt2 : Integer ;
  t1, t2, t3 : integer ;
  b1 : byte ;
  P : PByteArray;

begin
  TempList := TStringList.Create ;
  IntensityList := TStringList.Create ; // list for reference spectra colors and max intensity

  try
   With TempList Do
    Try
      LoadFromFile(HomeDir+ '\initial.ini') ;
    Except
      on EFOpenError Do
    end ;
    lastFileExt := TempList.Strings[1] ;
    Form2.MVA_executable := TempList.Strings[2] ;  // this is the executable to run externalanalyses
    Edit1.Text := TempList.Strings[3] ;
    Edit2.Text := TempList.Strings[4] ;
    Edit3.Text := TempList.Strings[5] ;
    BKGRed   :=  StrToFloat(Edit1.Text)  ;
    BKGGreen :=  StrToFloat(Edit2.Text)   ;
    BKGBlue  :=  StrToFloat(Edit3.Text)   ;

    //no I/O exceptions raised ...
    FileListBox1.Items.BeginUpdate ;
    FileListBox1.Directory := HomeDir+'\refdata\'  ;
    FileListBox1.Mask := '*.rsp' ;
    FileListBox1.Items.EndUpdate ;

    CheckListBox1.Font.Color := clRed ;
    For TempInt1 := 0 to FileListBox1.Items.Count-1 Do
    begin
      TempStr1 :=  FileListBox1.Items.Strings[TempInt1] ;
      TempInt2 := Pos('.rsp',TempStr1) ;
      TempStr1 := Copy(TempStr1,1,TempInt2-1) ; // copy all but '.rsp '
      CheckListBox1.Items.Add(TempStr1) ;
    end ;

    // *** Remember to change the 10 here if the header strings are added/subtracted ****
    For TempInt1 := 10 to TempList.Count-1 Do                  // FileListBox1.Items.Count-1
    begin
       IntensityList.Add(TempList.Strings[TempInt1]) ; // color data starts here *************************
    end ;

  ComboBox2.Items.Clear  ;
  ComboBox3.Items.Clear  ;
  ComboBox4.Items.Clear  ;

  TempStr1 := TempList.Strings[6] ;

// X data values
  ComboBox2.Items.CommaText := TempList.Strings[6] ;
  ComboBox3.Items.CommaText := TempList.Strings[6] ;
  ComboBox2.text := TempList.Strings[7] ;
  ComboBox3.text := TempList.Strings[7] ;
// Y data values
  ComboBox4.Items.CommaText := TempList.Strings[8] ;
  ComboBox4.text :=  TempList.Strings[9] ;

{$I-}
  if SetCurrentDir(TempList.Strings[0]) = false then
     SetCurrentDir(HomeDir) ;
{$I+}
  Form2.Edit8.Text := FloatToStrf(OrthoVarYMax,ffFixed,5,3) ;
  Form2.Edit9.Text := FloatToStrf(OrthoVarYMin,ffFixed,5,3) ;
  Finally
    TempList.Free ;
  end ;

  CheckBox1.Checked := True ;  // include charge on reference line

  // added for holding bitmap of colors being used for pallet of 2D image textures
  PalletColorsBitMap := TBitmap.Create ;
  PalletColorsBitMap.PixelFormat :=  pf32bit ;
  PalletColorsBitMap.Height := 1 ;
  PalletColorsBitMap.Width  := 512 ;
  P := PalletColorsBitMap.ScanLine[0];
  for t1 := 0 to PalletColorsBitMap.width -1 do
  begin
    b1 := t1 div 2 ;
    for t3 := 0 to 3 do  // for each byte
    begin
      P[(t1 * 4) + t3] :=  b1 ;
    end ;
  end ;

  Image1.Picture.Bitmap :=   PalletColorsBitMap ;



//   If (IsNative2DdataRB.Checked) or (Is2DdataRB.Checked) Then  Checkbox4.Checked := false ;  // initially no y scale for 2D images
end;



procedure TForm2.Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(TEdit(Sender).Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.001*(-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        TEdit(Sender).Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;


procedure TForm2.Edit1MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Screen.Cursor := crSizeNS ;
MouseDownMat := True ;
end;

procedure TForm2.Edit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tSR : TSpectraRanges ;
  t0, selectedRowNum : integer ;
  tLC : TGLLineColor ;
begin
   MouseDownMat := False ;
   BKGRed   :=  StrToFloat(Edit1.Text)  ;
   BKGGreen :=  StrToFloat(Edit2.Text)   ;
   BKGBlue  :=  StrToFloat(Edit3.Text)   ;
   MouseArrayX[0]:= 0;
   MouseArrayY[0] := 0;
   MouseArrayX[1] := 0;
   MouseArrayY[1] := 0;

  tLC[0] := strtofloat(Edit40.Text) ;
  tLC[1] := strtofloat(Edit41.Text) ;
  tLC[2] := strtofloat(Edit42.Text) ;

  SelectStrLst.SortListNumeric ;

  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      tSR.LineColor := tLC ;
      if (tSR.frequencyImage = false) and (tSR.nativeImage = false) then
      begin
        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;
   end ;
  end ;  // for each file selected

  Form1.Refresh ;
end;

// for each item selected in the list of 'reference' spectra
// load the data and create an OpenGL list for use with display functiion (FormPaint(Sender: TObject) procedure)
procedure TForm2.CheckListBox1ClickCheck(Sender: TObject);
Var
 TempList1 : TStringList ;
 TempInt1, TempInt2, TempInt3 : Integer ;
 TempStr1, TempStr2, ChargeStr : String ;
 MaxIntensity, CurrentIntensity, DesiredMaxIntensity, BaseLine : glFloat ;
 RefCol_r, RefCol_g, RefCol_b : glFloat ;
begin
//MaxIntensity := null ;
ActivateRenderingContext(Form1.Canvas.Handle,RC); // make context drawable
BaseLine := StrToFloat(Edit13.Text) ;
// BuildOutLineFont('Arial',12) ;
glNewList(REF_LIST, GL_COMPILE);  // reference lines to overlay spectra
  For TempInt1 := 0 to Form2.CheckListBox1.Items.Count-1 Do
    begin
      If Form2.CheckListBox1.Checked[TempInt1] Then
        begin
             TempList1 := TStringList.Create ;
             With TempList1 Do
             Try
                LoadFromFile(HomeDir+'\refdata\'+CheckListBox1.Items.Strings[TempInt1]+'.rsp') ;
             except
               on  EFOpenError Do
             end ;

             TempStr1 := IntensityList.Strings[TempInt1] ;   // GET CURRENT INTENSITY VALUE AND line color RED/GREEN/BLUE VALUE
             TempInt2 := Pos(' ',TempStr1) ;
             DesiredMaxIntensity := StrToFloat(copy(TempStr1,1,TempInt2-1)) ;
             TempStr1 := copy(TempStr1,TempInt2+1,Length(TempStr1)) ;
             TempStr1 := TrimLeft(TempStr1) ;
             TempInt2 := Pos(' ', TempStr1) ;
             RefCol_r := StrToFloat(copy(TempStr1,1,TempInt2-1)) ;
             TempStr1 := copy(TempStr1,TempInt2+1,Length(TempStr1)) ;
             TempStr1 := TrimLeft(TempStr1) ;
             TempInt2 := Pos(' ', TempStr1) ;
             RefCol_g := StrToFloat(copy(TempStr1,1,TempInt2-1)) ;
             TempStr1 := copy(TempStr1,TempInt2+1,Length(TempStr1)) ;
             TempStr1 := TrimLeft(TempStr1) ;
             TempInt2 := Pos(' ', TempStr1) ;
             RefCol_b := StrToFloat(copy(TempStr1,1,TempInt2-1)) ;


               For TempInt2 := 3 to TempList1.Count-1 Do   // Get maximum intensity value
                 begin
                   TempStr1 := TempList1.Strings[TempInt2] ;
                   TempInt3 := Pos(',',TempStr1) ;
                   TempStr2 := Copy(TempStr1,1,TempInt3-1) ; //Intensity(=y)
                   CurrentIntensity := StrToFloat(TempStr2) ;
                   If MaxIntensity < CurrentIntensity Then
                     MaxIntensity := CurrentIntensity ;
                 end ;

               MaxIntensity := DesiredMaxIntensity/MaxIntensity ;

               For TempInt2 := 3 to TempList1.Count-1 Do
                 begin
                   TempStr1 := TempList1.Strings[TempInt2] ;  //structure= Intensity(=y) : Wavelength(=x) : Charge
                   TempInt3 := Pos(',',TempStr1) ;
                   TempStr2 := Copy(TempStr1,1,TempInt3-1) ;  // Intensity
                   TempStr1 := Copy(TempStr1,TempInt3+1,Length(TempStr1)) ;
                   TempInt3 := Pos(',', TempStr1) ;
                   If CheckBox1.Checked Then
                     begin
                       ChargeStr := Copy(TempStr1,TempInt3+1,Length(TempStr1)) ;
                     end ;
                   TempStr1 := Copy(TempStr1,1,TempInt3-1) ;

                   SingPrec1GL := StrToFloat(TempStr1) ;
                   SingPrec2GL := StrToFloat(TempStr2)*MaxIntensity ;
                   glBegin(GL_LINE_STRIP) ;
                     glColor3f(RefCol_r,RefCol_g,RefCol_b) ;
                     glVertex2f(SingPrec1GL-0.01, BaseLine) ;
                     glVertex2f(SingPrec1GL,SingPrec2GL+BaseLine) ;
                     glVertex2f(SingPrec1GL+0.01, BaseLine) ;
                   glEnd ;    // end GL_LINE_STRIP
                   If CheckBox1.Checked Then   // "include charge" checkbox
                     begin
                       glRasterPos2f(SingPrec1GL, SingPrec2GL+(HeightPerPix1*3) +Baseline) ;
                       glListBase(1); // indicate the start of display lists for the glyphs.
                       glCallLists(Length(ChargeStr),GL_UNSIGNED_BYTE,@ChargeStr[1]) ;
                     end ;
                 end ;
              //   glRasterPos2f(
         end ;
      end ;
glEndList() ;       // end SPECTRALIST[x]
wglMakeCurrent(0,0); // another way to release control of context
Form1.FormResize(Sender) ;
Form1.Refresh;

end;


procedure TForm2.Edit12MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit12.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1000)  Then
      begin
        TempFloat := TempFloat + (0.001*(-Y)) ;
        If TempFloat > 1000 Then TempFloat := 1000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit12.Text := FloatToStrf(TempFloat,ffFixed,3,3) ;
      end ;
   end ;

end;

procedure TForm2.Edit12MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Screen.Cursor := crHourGlass;
MouseDownMat := False ;
MouseArrayX[0]:= 0;
MouseArrayY[0] := 0;
MouseArrayX[1] := 0;
MouseArrayY[1] := 0;
CheckListBox1Click(Sender) ;
CheckListBox1ClickCheck(Sender) ;
Form1.Refresh ;
Screen.Cursor := crArrow ;
end;

procedure TForm2.CheckListBox1Click(Sender: TObject);   // Updates ref. spectra max intensity values
Var
 TempInt1, TempInt2 : Integer ;
 TempStr1 : String ;
begin
For TempInt1 := 0 to CheckListBox1.Items.Count-1 Do
  begin
    If CheckListBox1.Selected[TempInt1] Then
      begin
        TempStr1 := IntensityList.Strings[TempInt1]  ;
        TempInt2 := Pos(' ', TempStr1) ;
        TempStr1 := Copy(TempStr1,TempInt2,Length(TempStr1)) ;
        TempStr1 := TrimLeft(TempStr1) ;
        TempStr1 := Edit12.Text + ' ' + TempStr1 ;
        IntensityList.Strings[TempInt1] := TempStr1 ;
      end ;
  end ;

end;

procedure TForm2.CheckBox1Click(Sender: TObject);
begin
MouseDownMat := False ;
MouseArrayX[0]:= 0;
MouseArrayY[0] := 0;
MouseArrayX[1] := 0;
MouseArrayY[1] := 0;
//CheckListBox1Click(Sender) ; // do not need to update ref. spectra intensity data
//CheckListBox1ClickCheck(Sender) ;
//Form1.Refresh ;
end;


procedure TForm2.Edit8MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MouseDownMat := False ;
MouseArrayX[0]:= 0;
MouseArrayY[0] := 0;
MouseArrayX[1] := 0;
MouseArrayY[1] := 0;
     StartLineX := 0 ;
     StartLineY := 0 ;
     EndLineX := 0 ;
     EndLineY := 0 ;
Form1.FormResize(Sender) ;
//Form1.Refresh ;
end;


procedure TForm2.Edit8MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
     TempFloat := StrToFloat(Edit8.Text) ;
      try
        TempFloat := TempFloat + (0.001*(Y)*TempFloat) ;
      except
         on EOverFlow  do
           TempFloat := TempFloat - (0.01*(Y)*TempFloat) ;
      end;
        Edit8.Text := FloatToStrf(TempFloat,ffFixed,4,3) ;
        OrthoVarYMax := TempFloat ;
      Refresh ;
   end ;

end;



procedure TForm2.Edit9MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
  If MouseDownMat Then
  begin
     TempFloat := StrToFloat(Edit9.Text) ;
       try
         TempFloat := TempFloat + (0.001*(Y)*TempFloat) ;
       except
         on EOverFlow  do
           TempFloat := TempFloat - (0.01*(Y)*TempFloat) ;
      //   on EUnderFlow do
      //      TempFloat := TempFloat - ((Y)*TempFloat) ;
       end;
        Edit9.Text := FloatToStrf(TempFloat,ffFixed,4,3) ;
        OrthoVarYMin := TempFloat ;
      Refresh ;
   end ;

end;

procedure TForm2.Edit6MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
  If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit6.Text) ;

        try
            TempFloat := TempFloat + (0.001*(-Y)*TempFloat) ;
         except
         on EOverFlow  do
           TempFloat := TempFloat - (0.01*(Y)*TempFloat) ;
         end;

        Edit6.Text := FloatToStrf(TempFloat,ffFixed,5,3) ;
        OrthoVarXMin := TempFloat ;

      Refresh ;
   end ;

end;

procedure TForm2.Edit7MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
  If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit7.Text) ;
         try
            TempFloat := TempFloat + (0.001*(-Y)*TempFloat) ;
         except
         on EOverFlow  do
           TempFloat := TempFloat - (0.01*(Y)*TempFloat) ;
         end;
        Edit7.Text := FloatToStrf(TempFloat,ffFixed,5,3) ;
        OrthoVarXMax := TempFloat ;

      Refresh ;
   end ;

end;

procedure TForm2.Edit13MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit13.Text) ;
    If (TempFloat >= -2.0) and (TempFloat <=StrToFloat(Edit12.Text))  Then
      begin
        TempFloat := TempFloat + (0.001*(-Y)) ;
     //   If TempFloat > StrToFloat(Edit12.Text)  Then TempFloat := StrToFloat(Edit12.Text) ;
        If TempFloat < -2.0 Then TempFloat := -2.000 ;
        Edit13.Text := FloatToStrf(TempFloat,ffFixed,3,3) ;
      end ;
   end ;

end;


procedure TForm2.CheckBox2Click(Sender: TObject);
begin
If Not CheckBox2.Checked Then
  begin
    Edit15.Text := '0.00' ;
  end ;
end;


procedure TForm2.Button2Click(Sender: TObject);   // moves x data along by specified amount  - "Update X"
Var
  TempStr : String ;
  offSet: glFloat ;
begin
If StrToFloat(Edit14.Text) <> 0.0 Then    // Edit14.Text = offset value to move x values up or down
  begin
    offSet := strtofloat(edit14.text) ;

    If offSet > 0 Then
      TempStr := 'higher'
    else
      TempStr := 'lower' ;

    Case MessageDlg('This will shift data' + TempStr + ' by ' + copy(trim(Edit14.Text),1,length(trim(Edit14.Text))) ,mtConfirmation,[mbOK,mbCancel],0) of
    idOK:
      begin
        If Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges Then
          begin
            TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]).ShiftData(offSet) ;  // reset pointer to start of data
          end ;
        TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]).CreateGLList('1-',Form1.Canvas.Handle, RC, GetWhichLineToDisplay(), 1)  ;
        TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]).SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        //if CheckBox7.Checked = false then    // dont keep current perspective
        Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

        Form1.FormResize(Sender)  ;
      end ;
      end ;

  end ; // end case statement
  Form1.Refresh ;
end;



procedure TForm2.SpeedButton1Click(Sender: TObject); // "R" reset button
Var
  TempArray : TGLRangeArray ;
  XorYData : integer ;
begin
  if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
  begin
    TempArray := Form4.GetOrthoVarValues(Form4.StringGrid1.Selection.Top)   ;

    If not Form2.CheckBox9.Checked Then  // invert x axis
    begin
       OrthoVarXMax := TempArray[0]  ;
       OrthoVarXMin := TempArray[1]  ;
    end
    else
    begin
       OrthoVarXMax := TempArray[1]  ;
       OrthoVarXMin := TempArray[0]  ;
    end ;
     If not Form2.CheckBox5.Checked Then  // invert y axis
    begin
       OrthoVarYMax := TempArray[2]  ;
       OrthoVarYMin := TempArray[3]  ;
    end
    else
    begin
       OrthoVarYMax := TempArray[3]  ;
       OrthoVarYMin := TempArray[2]  ;
    end ;


    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified - now column specific
  end ;

  EyeX := 0 ;
  EyeY := 0 ;
  CenterX := 0 ;
  CenterY := 0 ;
  Form1.FormResize(Sender) ;
end;


procedure TForm2.SpeedButton5Click(Sender: TObject);
begin
 SpeedButton6.Down := False ;  // integrate between lines
 BaselineCorrSB9.Down := False ;
 SpeedButton8.Down := False ;  // deconvolution peak selection
 SpeedButton7.Down := False ;  // zoom selected rectangle
end;

procedure TForm2.SpeedButton7Click(Sender: TObject);
begin
 SpeedButton6.Down := False ; // integrate between lines
 BaselineCorrSB9.Down := False ;
 SpeedButton8.Down := False ; // deconvolution peak selection
 SpeedButton5.Down := False ;
end;

{
procedure TForm2.SpeedButton2Click(Sender: TObject);
begin
SpeedButton6.Down := False ;  // integrate between lines
BaselineCorrSB9.Down := False ;
SpeedButton8.Down := False ;  // deconvolution peak selection
end;     }

procedure TForm2.SpeedButton8Click(Sender: TObject);
begin
 SpeedButton6.Down := False ; // integrate between lines
 BaselineCorrSB9.Down := False ;
 SpeedButton7.Down := False ; // zoom selected rectangle
 SpeedButton5.Down := False ; // zoom between lines
end;


procedure TForm2.Button3Click(Sender: TObject);  // Intergration or Normalisation function
Var
  t0, t1, t2, t3, NearStartPosInt, NearEndPosInt, StartTime, StopTime, currentSpecNum  : LongInt ;
  s1, s2,  X1, Y1, X2, Y2, BkgSubtract, IntegArea  : GLFloat ;
  SectionSlope, SectionConst, LineX, LineY, YB1, YB2, FullArea, SubtractedArea, RunningTotalArea  : single ;
  BkgSlope, BkgConst : single ;
  Edit25_F, Edit26_f : GLFloat ;
  LinesParallel : Bool ;
  tSR : TSpectraRanges ;
  tMat : TMatrix ;
  selectedRowNum : integer ;
  YYData : TGLRangeArray ;
  tString : string ;
begin

  if not CheckBox15.Checked then // FFT check box
  begin
  If (Edit25.Text = '') or (Edit26.Text = '') or (Edit27.Text = '') or (Edit28.Text = '') Then
  begin
    messagedlg('Please select area on graph for integration',mtInformation,[mbOk],0) ;
    Exit ;  // exit out of subroutine
  end ;
  end ;

SelectStrLst.SortListNumeric ;


if (not CheckBox15.Checked) and (not PeakHeightCB.Checked) then   // do standard integration (not FFT)
  begin
//  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
//  begin
  currentSpecNum := 0 ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
  If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum] is  TSpectraRanges  then
  begin

    tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;
    tMat := TMatrix.Create2(tSR.yCoord.SDPrec div 4,tSR.yCoord.numRows,1) ;  // this is used to determine average for normalisation

    Memo2.Lines.Add(extractfilename(tSR.xCoord.filename)) ;
    s1 := 0.00000 ;


    If (StrToFloat(Edit25.Text) < tSR.xLow) or (StrToFloat(Edit26.Text) > tSR.xHigh) Then
    begin
      messagedlg('Error: Integration points are beyond the data range',mtInformation,[mbOk],0) ;
      Exit ;  // exit out of subroutine
    end ;

    NearStartPosInt := 0 ;
    tSR.SeekFromBeginning(3,1,0) ;
    Edit25_F := StrToFloat(Edit25.Text) ; // 'integration' tab page text box
    Edit26_F := StrToFloat(Edit26.Text) ; // 'integration' tab page text box

    BkgSlope := StrToFloat(Edit27.Text) ;
    BkgConst := StrToFloat(Edit28.Text) ;


    tSR.xCoord.F_MData.Read(s1,4) ;
    tSR.xCoord.F_MData.Seek(0,soFromBeginning) ;
    // find start and end data value
    if s1 <   Edit25_F then
    begin
      While s1 <  Edit25_F do
      begin
        NearStartPosInt := NearStartPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      NearEndPosInt := NearStartPosInt ;
      Memo2.Lines.Add('StartX: ' +FloatToStrf(s1,ffGeneral,6,3)) ;
      While s1 <  Edit26_F do
      begin
        NearEndPosInt := NearEndPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      Memo2.Lines.Add('end X: ' +FloatToStrf(s1,ffGeneral,6,3)) ;
      Memo2.Lines.Add('EndPos-StartPos (number of points included): ' + IntToStr(NearEndPosInt-NearStartPosInt) ) ;
    end
    else
    begin
      While s1 >  Edit26_F  do
      begin
        NearStartPosInt := NearStartPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      NearEndPosInt := NearStartPosInt;
      Memo2.Lines.Add('EndX: ' +FloatToStrf(s1,ffGeneral,6,3)) ;
      While s1 >  Edit25_F do
      begin
        NearEndPosInt := NearEndPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      Memo2.Lines.Add('Start X: ' +FloatToStrf(s1,ffGeneral,6,3)) ;
      Memo2.Lines.Add('EndPos-StartPos (number of points included): ' + IntToStr(abs(NearEndPosInt-NearStartPosInt)) ) ;
    end ;


  for  currentSpecNum := 1 to tSR.yCoord.numRows do  // for each spectrum in single TSpectraRanges object
  begin
    tSR.SeekFromBeginning(3,1,(((NearEndPosInt-1)* tSR.xCoord.SDPrec))) ;
    X1 := 0.0 ;
    tSR.xCoord.F_MData.Read(X1,4) ;

    EndLineX := X1 ; //************used on update of position of lines between which area is integrated
    EndLineY := (BKGSlope*X1)+BkgConst ;

    tSR.SeekFromBeginning(3,currentSpecNum,((NearStartPosInt-1)*tSR.xCoord.SDPrec)) ;
    X1 := 0.0 ;
    X2 := 0.0 ;
    Y1 := 0.0 ;
    Y2 := 0.0 ;
    tSR.xCoord.F_MData.Read(X1,4) ;
    tSR.yCoord.F_MData.Read(Y1,4) ;
    tSR.xCoord.F_MData.Read(X2,4) ;
    tSR.yCoord.F_MData.Read(Y2,4) ;


    StartLineX := X1 ;   //*************used on update of position of lines between which area is integrated
    StartLineY := (BKGSlope*X1)+BkgConst ;

    RunningTotalArea := 0.0 ;

    for t1 := 1 to (NearEndPosInt-NearStartPosInt) do
    begin
      LinesParallel := False ;

      try
        SectionSlope := (Y1-Y2)/(X1-X2) ;  // = m = slope of section
      Except
       on EZeroDivide  Do
         begin
          // LinesParallel := True ;
         end ;
      end ;
      SectionConst := Y1 - (SectionSlope*X1) ; // c = y - mx

     { try
        LineX := (BkgConst-SectionConst)/(SectionSlope-BkgSlope) ; // value of X for which lines cross
      Except
      on EZeroDivide  Do
        begin
          LinesParallel := True ;
        end ;
      end ; }

     if (SectionSlope-BkgSlope = 0) then
      LinesParallel := True
     else
     begin
       LineX := (BkgConst-SectionConst)/(SectionSlope-BkgSlope) ; // value of X for which lines cross
     end ;

     IntegArea := ABS(X2-X1) ;

     If (LineX <= X1) or (LineX >= X2) or LinesParallel Then
       begin
         If SectionSlope>=0 Then //*****calculate area under section to subtract...
            FullArea :=((SectionSlope*sqr(IntegArea))/2) + (SectionConst*IntegArea) +  ABS( (IntegArea*    (((SectionSlope*X1)+SectionConst)-SectionConst))  )  // BkgSlope.X^2 + BkgConst.X + C   for +ve slope
         else
            FullArea :=  ((SectionSlope*sqr(IntegArea))/2) + (SectionConst*IntegArea) -  ABS( (IntegArea*   (((SectionSlope*X1)+SectionConst) -SectionConst))  ) ; // BkgSlope.X^2 + BkgConst.X - C   for -ve slope
         If BkgSlope>=0 Then   //*****calculate area under baseline to subtract...
            BkgSubtract := ((BkgSlope*sqr(IntegArea))/2) + (BkgConst*IntegArea) +  ABS( (IntegArea*    (((BKGSlope*X1)+BkgConst)-BkgConst))  )  // BkgSlope.X^2 + BkgConst.X + C   for +ve slope
         else
            BkgSubtract := ((BkgSlope*sqr(IntegArea))/2) + (BkgConst*IntegArea) -  ABS( (IntegArea*   (((BKGSlope*X1)+BkgConst) -BkgConst))  ) ; // BkgSlope.X^2 + BkgConst.X - C   for -ve slope
      //   TotalBkg := TotalBkg + BkgSubtract ;
      //   TotalFullArea := TotalFullArea + FullArea ;
         SubtractedArea := FullArea - BkgSubtract ;
     //    If  SubtractedArea >= 0 Then // make sure area of segment is > background
            RunningTotalArea := RunningTotalArea + SubtractedArea ;
        end
      else
        begin
          YB1 :=  BkgSlope*X1 + BkgConst ;
          YB2 :=  BkgSlope*X2 + BkgConst ;
          LineY := BkgSlope*LineX + BkgConst ;
          If Y1>YB1 Then
            begin
              If BkgSlope>=0 Then
                FullArea := (ABS(Y1-LineY)*ABS(LineX-X1)*0.5) + (ABS(LineY-YB1)*ABS(LineX-X1)* 0.5)
              Else
                FullArea := (ABS(Y1-LineY)*ABS(LineX-X1)*0.5) - (ABS(YB1-LineY)*ABS(LineX-X1)* 0.5) ;
              RunningTotalArea := RunningTotalArea + FullArea ;
            end
          Else // Y1<BY1
            begin
              If BkgSlope>=0 Then
                FullArea :=  ((ABS(Y2-LineY)*ABS(X2-LineX))*0.5) - (ABS(YB2-LineY)*ABS(X2-LineX)*0.5)
              else
                FullArea :=  ((ABS(Y2-LineY)*ABS(X2-LineX))*0.5) + (ABS(YB2-LineY)*ABS(X2-LineX)*0.5) ;
              RunningTotalArea := RunningTotalArea + FullArea ;
            end ;
        end ;

     X1 := X2 ;
     Y1:= Y2 ;
     tSR.xCoord.F_MData.Read(X2,4) ;
     tSR.yCoord.F_MData.Read(Y2,4) ;
    end ;

    If  NearEndPosInt > NearStartPosInt Then
    begin
    //Form2.Memo2.Lines.Add('Total area: '+FloatToStrf(TotalFullArea,ffGeneral,6,3)) ;
    //Form2.Memo2.Lines.Add('Total Bkg: '+FloatToStrf(TotalBkg,ffGeneral,6,3)) ;
//    Memo2.Lines.Add('Total area: ' +FloatToStrf(RunningTotalArea,ffGeneral,6,3)) ;
      Memo2.Lines.Add(FloatToStrf(RunningTotalArea,ffGeneral,6,3)) ;

      if sender =  NormaliseByIntegBtn then
      begin
       //RunningTotalArea := sqrt(RunningTotalArea) ;
       tSR.SeekFromBeginning(3,currentSpecNum,0) ;
       for t1 := 1 to tSR.xCoord.numCols do
       begin
         tSR.yCoord.F_MData.Read(Y1,tSR.yCoord.SDPrec) ;
         if RunningTotalArea <> 0 then
         Y1 := Y1 / RunningTotalArea ;
         tSR.yCoord.F_Mdata.Seek(-tSR.yCoord.SDPrec,soFromCurrent) ;
         tSR.yCoord.F_MData.Write(Y1,tSR.yCoord.SDPrec) ;
       end ;
      end ;

     tMat.F_Mdata.Write(runningTotalArea,4) ;



   end
   else
   begin
    messagedlg('Area selected is between two data points ' +#13+'and can not be calculated with algorithm available',mtInformation,[mbOk],0) ;
    exit ;
   end ;




  end ; // for  currentSpecNum := 0 to tSR.yCoord.numRows do

    tMat.Average ;
    tMat.F_MAverage.Seek(0,soFromBeginning) ;
    tMat.F_MAverage.Read(YYData[0],4) ;
    tString := 'Ave: ' + floattostrf(YYData[0],ffGeneral,7,7) ;
    tMat.Free ;
    Memo2.Lines.Add( tString ) ;

    if sender =  NormaliseByIntegBtn then   // this normalises around the average value
    begin
      for t2 := 1 to tSR.yCoord.numRows do
      begin
        tSR.SeekFromBeginning(3,t2,0) ;
        for t3 := 1 to tSR.xCoord.numCols do
        begin
          tSR.yCoord.F_MData.Read(Y1,tSR.yCoord.SDPrec) ;
          Y1 := Y1 * YYData[0] ;   // multiply by the average value
          tSR.yCoord.F_Mdata.Seek(-tSR.yCoord.SDPrec,soFromCurrent) ;
          tSR.yCoord.F_MData.Write(Y1,tSR.yCoord.SDPrec) ;
        end ;
      end ;
    end ;


end  // end not FFT integration
end
end
else
if not PeakHeightCB.Checked then
begin // FFT integration
  If Form4.StringGrid1.Objects[Form4.StringGrid1.Col,t1] is TSpectraRanges Then
  begin
 {   tSR.IntegrateUsingFFT(TSpectraRanges(Form4.StringGrid1.Objects[1,t1])) ;
    ///////////////////////////////////////////////////////////////////////////////////
    // Create glList for integrated spectra data points
    ///////////////////////////////////////////////////////////////////////////////////
    tSR.CreateGLList(Canvas.Handle, RC, GetWhichLineToDisplay())  ;
    tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified }
  end ;
   messagedlg('IntegrateUsingFFT() not implemented' ,mtInformation,[mbOK],0) ;

end
else

if PeakHeightCB.Checked then
begin

  currentSpecNum := 0 ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
    s1 := StrToFloat(Edit25.Text) ;
    selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
    If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum] is  TSpectraRanges  then
    begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum])  ;
        tMat := TMatrix.Create2(tSR.yCoord.SDPrec div 4,tSR.yCoord.numRows,1) ;
        Memo2.Lines.Add(extractfilename(tSR.xCoord.filename)) ;

        t1 := tSR.ReturnIndexOfClosestXPosition( @s1 ) ;

        tSR.SeekFromBeginning(3,1,(t1-1)*tSR.XCoord.SDPrec) ;
        tSR.xCoord.F_Mdata.Read( s1 , tSR.XCoord.SDPrec) ;

        Memo2.Lines.Add('Peak position: (desired)' + Edit25.Text) ;
        Memo2.Lines.Add('Peak position: (actual)' + floatToStrf(s1,ffGeneral,7,5) ) ;
        Memo2.Lines.Add('Peak index: (actual)' + inttostr(t1)  ) ;

        // for each spectrum in the TSpectraRanges object
        for t2 := 1 to tSR.yCoord.numRows do
        begin
          tSR.Read_YrYi_Data(t1,t2,@YYData,true) ;
          tString := floatToStrf(YYData[0],ffGeneral,7,5) ;
          if tSR.yImaginary <> nil then
            tString := tString + floatToStrf(YYData[1],ffGeneral,7,5) ;

          Memo2.Lines.Add( tString ) ;
          tMat.F_Mdata.Write( YYData[0] , 4) ; // add value to TMatrix so we can put average value at end of file list
       //   tMat.

          if sender =  NormaliseByIntegBtn then  // this divides by the peak height
          begin
            tSR.SeekFromBeginning(3,t2,0) ;
            for t3 := 1 to tSR.xCoord.numCols do
            begin
              tSR.yCoord.F_MData.Read(Y1,tSR.yCoord.SDPrec) ;
              if YYData[0] <> 0.0 then
                Y1 := Y1 / YYData[0] ;
              tSR.yCoord.F_Mdata.Seek(-tSR.yCoord.SDPrec,soFromCurrent) ;
              tSR.yCoord.F_MData.Write(Y1,tSR.yCoord.SDPrec) ;
            end ;
          end ;
        end ;  // for each spectrum

        tMat.Average ;
        tMat.F_MAverage.Seek(0,soFromBeginning) ;
        tMat.F_MAverage.Read(YYData[0],4) ;
        tString := 'Ave: ' + floattostrf(YYData[0],ffGeneral,7,7) ;
        tMat.Free ;
        Memo2.Lines.Add( tString ) ;

        if sender =  NormaliseByIntegBtn then   // this normalises around the average value
          begin
            tSR.SeekFromBeginning(3,t2,0) ;
            for t3 := 1 to tSR.xCoord.numCols do
            begin
              tSR.yCoord.F_MData.Read(Y1,tSR.yCoord.SDPrec) ;
              Y1 := Y1 * YYData[0] ;   // multiply by the average value
              tSR.yCoord.F_Mdata.Seek(-tSR.yCoord.SDPrec,soFromCurrent) ;
              tSR.yCoord.F_MData.Write(Y1,tSR.yCoord.SDPrec) ;
            end ;
          end ;


    end ;
  end ;
end ;
  if sender =  NormaliseByIntegBtn then
  begin
     tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
     tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
     if not Form4.CheckBox7.Checked then
       Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  end ;
  Form1.Refresh ;
end;



procedure TForm2.Button4Click(Sender: TObject); // Smooth data function
begin
     if AverageSmoothRB1.Checked then  AverageSmooth()
     else
     if  FourierSmoothRB1.Checked then FourierSmooth() 
     else
     if  MinNoisePreprocessCB.Checked then MinNoisePreprocess() ;
end ;



procedure TForm2.MinNoisePreprocess ; // subtracts following spectra from the one before (until end, which is zeroed)
var
  t1, t2, selectedRowNum, colNum : Integer ;
  s1, s2 : single ;
  tSR, newTSR : TSpectraRanges ;
begin

  SelectStrLst.SortListNumeric ;
  colNum :=  Form4.StringGrid1.Selection.Right ;
  
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;

     If Form4.StringGrid1.Objects[colNum,selectedRowNum] is TSpectraRanges then
     begin
       tSR := TSpectraRanges(Form4.StringGrid1.Objects[colNum,selectedRowNum]) ;
       newTSR := TSpectraRanges.Create(tSR.yCoord.SDPrec div 4,0,0,@tSR.LineColor)  ;

       newTSR.CopySpectraObject(tSR) ;
       newTSR.Transpose ;  // transpose here to make memory access sequential on subtraction
       newTSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
       // tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
       // start the algorithm
       newTSR.yCoord.F_Mdata.Read(s1,4) ;
       newTSR.yCoord.F_Mdata.Read(s2,4) ;
       for t2 := 1 to (newTSR.yCoord.numRows * newTSR.yCoord.numCols)-1  do
       begin
         s1 := s1-s2 ;
         newTSR.yCoord.F_Mdata.Seek(-8,soFromCurrent) ;
         newTSR.yCoord.F_Mdata.Write(s1,4) ;
         s1 := s2 ;
         newTSR.yCoord.F_Mdata.Seek(4,soFromCurrent) ;
         newTSR.yCoord.F_Mdata.Read(s2,4) ;
       end ;
       newTSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
       newTSR.Transpose ;

       ///////////////////////////////////////////////////////////////////////////////////
       // Create glList for smoothed spectra data points
       ///////////////////////////////////////////////////////////////////////////////////
        // tResiduals is the 'residuals' matrix
       Form4.StringGrid1.Objects[4,selectedRowNum] := newTSR ;
       newTSR.GLListNumber := Form4.GetLowestListNumber ;

       newTSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
       newTSR.zHigh :=  0 ;
       newTSR.zLow :=   0  ;
       if (newTSR.lineType > MAXDISPLAYTYPEFORSPECTRA) or (newTSR.lineType < 1)  then newTSR.lineType := 1 ;  //
       newTSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(),  newTSR.lineType )   ;
       Form4.StringGrid1.Cells[4,selectedRowNum] := '1-'+ inttostr(newTSR.yCoord.numRows) +' : 1-' + inttostr(newTSR.yCoord.numCols) ;
       newTSR.xString := tSR.xString ;
       newTSR.yString := tSR.yString  ;
    end ;
  end ;

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  Form1.FormResize(Form2)  ;


end ;



procedure TForm2.FourierSmooth ;
var
  t1, selectedRowNum, colNum : Integer ;
  tfloat, tfloat2 : single ;
  tbool : boolean ;
  P : Pchar ;
  tstr: array[0..2] of Char;
  zeroFillIn : integer ;
  tSR : TSpectraRanges ;

begin
//  messagedlg('FourierSmooth() not implemented yet' ,mtInformation,[mbOK],0) ;

  SelectStrLst.SortListNumeric ;

  P := tstr ;
  ComboBox1.GetTextBuf(P,3) ; // this is the amount of zero filling 
  zeroFillIn := strtoint(string(tstr)) ;

  colNum :=  Form4.StringGrid1.Selection.Right ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;

     If Form4.StringGrid1.Objects[colNum,selectedRowNum] <> nil then
     begin
       tSR := TSpectraRanges(Form4.StringGrid1.Objects[colNum,selectedRowNum]) ;
       tfloat := strtofloat(Edit32.Text) / 100 ;
       tfloat2 := strtofloat(Edit33.Text) ;
       // middle value of fft data is the numerical average of the data, setting to = zero will drop all data to the baseline
       //   if ZeroDataCB1.Checked then tbool := true  // zero data
       //   else tbool := false ;

       if hannWindowCB1.Checked then tSR.fft.hanningWindow :=  true
        else  tSR.fft.hanningWindow :=  false ;

       tSR.fft.FFTBandPass(tfloat, tfloat2, ZeroDataCB1.Checked, zeroFillIn, tSR ) ;
       ///////////////////////////////////////////////////////////////////////////////////
       // Create glList for smoothed spectra data points
       ///////////////////////////////////////////////////////////////////////////////////
       tSR.CreateGLList('1-', Form1.Canvas.Handle, RC, GetWhichLineToDisplay(), tSR.lineType ) ;
       tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    end ;
  end ;

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  Form1.FormResize(Form2)  ;

end ;


procedure TForm2.AverageSmooth ; // Smooth data using moving average
var
  GridRow : LongInt ;
  tSR : TSpectraRanges ;
begin
GridRow :=  Form4.StringGrid1.Selection.Top ;

If Form4.StringGrid1.Objects[2,GridRow] <> nil then
begin
  tSR  := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,GridRow]) ;
  tSR.yCoord.AverageSmooth(StrToInt(Trim(copy(Form2.ComboBox5.Text,1,pos(' ',Form2.ComboBox5.Text)-1)))) ;

  ///////////////////////////////////////////////////////////////////////////////////
  // Create glList for smoothed spectra data points
  ///////////////////////////////////////////////////////////////////////////////////
  tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;
  tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified

  Form2.Edit12.Text := FloatToStrF(OrthoVarYMax,ffGeneral,3,2) ;
  Form4.StringGrid1Click(Form2) ;

end ;
end;



procedure TForm2.Copy1Click(Sender: TObject);
begin
Form4.Copy1Click(sender) ;
end;


procedure TForm2.CheckBox4Click(Sender: TObject);
begin
Form1.Refresh ;
end;


procedure TForm2.StringGrid1DrawCell(Sender: TObject; Col, Row: Integer;
  Rect: TRect; State: TGridDrawState);
var
  tStr : string ;
begin

  // this draws the bitmap in column 1 (=0)
  // could replace with standard TRect code and remove need for TBitmap
  {
    SG2.Canvas.Brush.Color := $02E0E0E0			 ;
    SG2.Canvas.FillRect(Rect) ;
    SetTextColor(SG2.Canvas.Handle, clBlack ) ;
    tstr :=  SG2.Cells[Colx,Rowx] ;
    DrawText(SG2.Canvas.Handle, PChar(tstr),StrLen(PChar(tstr)),Rect,DT_LEFT) ;
  }


end;


procedure TForm2.FormResize(Sender: TObject);
begin
If Form2.PageControl1.ClientWidth > 325 Then
 CheckListBox1.Columns := 3
else If
Form2.PageControl1.ClientWidth <= 325 Then
  CheckListBox1.Columns := 2 ;

end;



procedure TForm2.BaselineCorrSB9Click(Sender: TObject);
begin
 SpeedButton6.Down := False ; // integrate between lines
 SpeedButton7.Down := False ; // zoom selected rectangle
 SpeedButton5.Down := False ; // zoom between lines
end;


procedure TForm2.SpeedButton6Click(Sender: TObject);   // integrate between lines
begin
SpeedButton8.Down := False ; // deconvolution peak selection
BaselineCorrSB9.Down := False ;
Speedbutton5.Down := False ;
Speedbutton7.Down := False ;

end;



procedure TForm2.PageControl1Change(Sender: TObject);
begin
     if PageControl1.ActivePage <> TabSheet5 then
     begin
        SpeedButton6.Down := false ;
        BaselineCorrSB9.Down := False ;
     end ;
     if PageControl1.ActivePage <> TabSheet2 then
        CheckBox2.Checked := false ;

end;

procedure TForm2.CheckBox3Click(Sender: TObject);
begin
     if CheckBox3.Checked then
     begin
          edit16.Enabled := true ;
          edit29.Enabled := true ;
          edit29.Text := '0' ;
     end
     else
     begin
          edit16.Enabled := false ;
          edit29.Enabled := false ;
          edit29.Text := 'start x value' ;
     end ;

end;

procedure TForm2.CheckBox9Click(Sender: TObject);    // INVERT X AXIS
Var
 TempFloat2 : glFloat ;
begin

  TempFloat2 := StrToFloat(Edit7.Text) ;
  Edit7.Text := Edit6.Text ;
  Edit6.Text := FloatToStr(TempFloat2) ;
  OrthoVarXMax := OrthoVarXMin + (30*WidthPerPix1) ;// StrToFloat(Edit7.Text) ;
  OrthoVarXMin := StrToFloat(Edit6.Text) + (30*WidthPerPix1) ;

  Form1.FormResize(sender) ;

end;


procedure TForm2.difButtonClick(Sender: TObject);
var
  t1 : integer ;
  selectedRowNum, colNum : integer ;
  tSR : TSpectraRanges ;
  TempXY : array[0..1] of glFloat ;
  order : integer ;  // order of differential to calculate (1 = 1st derivative etc.)
  zeroFillIn : integer ;
  P : Pchar ;
  tstr: array[0..2] of Char;
begin
  SelectStrLst.SortListNumeric ;
  colNum :=  Form4.StringGrid1.Selection.Right ;
  order := strtoint(Edit23.text) ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
    selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
    If Form4.StringGrid1.Objects[colNum,selectedRowNum] IS TSpectraRanges Then
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[colNum,selectedRowNum]) ;

      P := tstr ;
      Form2.ComboBox1.GetTextBuf(P,3) ;
      zeroFillIn := strtoint(string(tstr)) ;

      if hannWindowCB1.Checked then tSR.fft.hanningWindow :=  true
        else  tSR.fft.hanningWindow :=  false ;

      tSR.fft.DiffOrIntUsingFFT(tSR, order, zeroFillIn) ;

      ///////////////////////////////////////////////////////////////////////////////////
      // Create glList for differentiated spectra data points
      ///////////////////////////////////////////////////////////////////////////////////
      tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
      tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    end ;
  end ; // end for each file selected

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  Form1.FormResize(Sender)  ;
end;



procedure TForm2.FFTButton1Click(Sender: TObject);  // FFT button in "Fourier" tab
var
  t1, colNum : Integer ;
  GR : TGridRect ;
  P : Pchar ;
  tstr: array[0..2] of Char;
  ZeroFillIn : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
begin

  SelectStrLst.SortListNumeric ;
  colNum :=  Form4.StringGrid1.Selection.Right ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;

     P := tstr ;
     ComboBox1.GetTextBuf(P,3) ;
     ZeroFillIn := strtoint(string(tstr)) ;

     If Form4.StringGrid1.Objects[colNum,selectedRowNum] <> nil then  // file is a TSpectraRange
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[colNum,selectedRowNum]) ;

        if hannWindowCB1.Checked then tSR.fft.hanningWindow :=  true
        else  tSR.fft.hanningWindow :=  false ;

        if ForwardFFTRB1.Checked then
        begin
           tSR.fft.ComputeFFTSingle(1,ZeroFillIn, tSR)
        end
        else
        if ReverseFFTRB1.Checked then  // forced reverse FFT
        begin
           tSR.fft.ComputeFFTSingle(-1, ZeroFillIn, tSR) ;
        end ;
     end ;

     ///////////////////////////////////////////////////////////////////////////////////
     // Create glList for fourier transformed data spectra data points
     ///////////////////////////////////////////////////////////////////////////////////
     tSR.CreateGLList('1-', Form1.Canvas.Handle, RC, GetWhichLineToDisplay(),tSR.lineType) ;
     tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
     Form4.StringGrid1.Cells[colNum,selectedRowNum] := '1-'+ inttostr(tSR.yCoord.numRows) +' : 1-' + inttostr(tSR.yCoord.numCols) ;

  end ;

 if Form4.CheckBox7.Checked = false then
   Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
 Form1.FormResize(Sender)  ;
end;



procedure TForm2.Button5Click(Sender: TObject);
begin
   messagedlg('SaveFFT() not implemented yet' ,mtInformation,[mbOK],0) ;
    // TSpectraRanges(Form4.StringGrid1.Objects[1,Form4.StringGrid1.Selection.Top]).SaveFFT(Form4.SaveDialog1) ;

end;


procedure TForm2.hannWindowCB1Click(Sender: TObject);
begin
//      messagedlg('FFT() not implemented yet' ,mtInformation,[mbOK],0) ;

{     if hannWindowCB1.Checked = true then
       If Form4.StringGrid1.Objects[1,Form4.StringGrid1.Selection.Top] is TSpectraRanges Then
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).hanningWindow := true ;
     if hannWindowCB1.Checked = false then
       If Form4.StringGrid1.Objects[1,Form4.StringGrid1.Selection.Top] is TSpectraRanges Then
        TSpectraRanges(Form4.StringGrid1.Objects[2,Form4.StringGrid1.Selection.Top]).hanningWindow := false ;     }
end;

procedure TForm2.ComboBox1Change(Sender: TObject);
var
   P : Pchar ;
   tstr: array[0..2] of Char;
   tint : integer ;
begin
{     P := tstr ;
     ComboBox1.GetTextBuf(P,3) ;
     tint := strtoint(string(tstr)) ;
     If StringGrid1.Objects[1,StringGrid1.Selection.Top] IS TSpectraRanges Then
       TSpectraRanges(Form4.StringGrid1.Objects[1,StringGrid1.Selection.Top]).ZeroFill :=  tint ; }
end;


Function TForm2.GetWhichLineToDisplay : integer ;   // real or imaginary
begin
     if (ViewRealCB12.State = cbChecked) and (ViewImaginaryCB13.State = cbChecked) then
       Result := 3
     else if (ViewImaginaryCB13.State = cbChecked) then
       Result := 2
     else if (ViewRealCB12.State = cbChecked) then
       Result := 1
     else
       Result := 0 ;
end ;



 // Instrument deconvolution
procedure TForm2.Button8Click(Sender: TObject);
begin
     if RadioButton11.Checked then  SelfDeconvolution()
     else
     if  RadioButton12.Checked then InstrumentalDeconvolution() ;
end;


procedure TForm2.SelfDeconvolution();
var
  GridRow : Integer ;
  percNyq, degree : single ;

begin

end ;


procedure TForm2.InstrumentalDeconvolution();
var
  GridRow, InstrumentFuncSource, tint : Integer ;
  minX, maxX : single ;
  s1, s2 : single ;
  d1 : double ;
  tspec : TSpectraRanges ;
  tSRInstrument    : TSpectraRanges ;
begin
  messagedlg('InstrumentalDeconvolution() not implemented yet' ,mtInformation,[mbOK],0) ;
{  GridRow :=  Form4.StringGrid1.Selection.Top ;
  If Form4.StringGrid1.Objects[1,GridRow] <> nil then
    begin
      If (Edit36.Text = '') or (Edit37.Text = '') Then
      begin
        messagedlg('Please select a peak area first',mtInformation,[mbOk],0) ;
        Exit ;  // exit out of subroutine
      end ;

      InstrumentFuncSource := strtoint(Form2.Label32.Hint) ;

      minX := strtofloat(Edit36.Text) ;
      maxX := strtofloat(Edit37.Text) ;

      try
      if  ((Form4.StringGrid1.Objects[1,InstrumentFuncSource]) is TSpectraRanges) then
      begin
        tSRInstrument := TSpectraRanges(Form4.StringGrid1.Objects[1,InstrumentFuncSource]) ;
        if  extractFilename(tSRInstrument.xCoord.filename) <> Label32.Caption then
          Exit ;  // exit if Instrument function is closed or has moved

        // onstructor Create(singleOrDouble: integer; numSpectra, numXCoords : integer; lc : pointer);
        tspec :=  TSpectraRanges.Create(tSRInstrument.xCoord.SDPrec, 1, tSRInstrument.xCoord.numCols, nil)  ;

        tspec.SeekFromBeginning(3,1,0) ;
        tSRInstrument.SeekFromBeginning(3,1,0) ;

        tSRInstrument.xCoord.F_MData.Read(s1,4) ;
        tSRInstrument.yCoord.F_MData.Read(s2,4) ;
        if s1 > minX then
        begin
           tSRInstrument.SeekFromBeginning(3,1,0) ;
        end
        else
        begin
          while (s1 <= minX) do  // move to first value of instrument peak
          begin
            s2 := 0.0 ;
            tspec.xCoord.F_MData.Write(s1,4) ;
            tspec.yCoord.F_MData.Write(s2,4) ;
            tSRInstrument.xCoord.F_MData.Read(s1,4) ;
            tSRInstrument.yCoord.F_MData.Read(s2,4) ;
          end ;
        end ;

        while (s1 < maxX) and (tSRInstrument.xCoord.F_MData.Position < tSRInstrument.xCoord.F_MData.Size) do
        begin                        // copy instrument peak
          tSRInstrument.xCoord.F_MData.Read(s1,4) ;
          tSRInstrument.yCoord.F_MData.Read(s2,4) ;
          tspec.xCoord.F_MData.Write(s1,4) ;
          tspec.yCoord.F_MData.Write(s2,4) ;
        end ;

        for tint := (tspec.xCoord.F_MData.Position div 4) to (tspec.xCoord.F_MData.Size div 4) do  // fill last values
        begin
          tSRInstrument.xCoord.F_MData.Read(s1,4) ;
          tSRInstrument.yCoord.F_MData.Read(s2,4) ;
          s2 := 0.0 ;
          tspec.xCoord.F_MData.Write(s1,4) ;
          tspec.yCoord.F_MData.Write(s2,4) ;
        end ;


        tSRInstrument.FFTDeconvolution(tspec) ;

        ///////////////////////////////////////////////////////////////////////////////////
        // Create glList for new spectra data points
        ///////////////////////////////////////////////////////////////////////////////////
        tSRInstrument.CreateGLList(Form1.Canvas.Handle, RC, GetWhichLineToDisplay()) ;
        tSRInstrument.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
        SpeedButton1Click(Form2) ; // Reset button - displays full x,y data range
        Form1.FormResize(Form2)  ;
      end ;
      finally
        tspec.Free ;
      end ;

    end ;   }
end ;



procedure TForm2.Button9Click(Sender: TObject);
var
 GridRow, FFT1, FFT2, tint : Integer ;
begin
     messagedlg('ConvolveByFFT() not implemented' ,mtInformation,[mbOK],0) ;
 {    FFT1 := strtoint(Form2.RadioButton13.Hint) ;
     FFT2 := strtoint(Form2.RadioButton14.Hint) ;

     try
      if  ((Form4.StringGrid1.Objects[2,FFT1]) is TSpectraRanges) then
      begin
        if  extractFilename(TSpectraRanges(Form4.StringGrid1.Objects[2,FFT1]).xCoord.filename) <> RadioButton13.Caption then
          Exit ;  // exit if Instrument function is closed or has moved
      end
      else
          exit ;
      if  ((Form4.StringGrid1.Objects[2,FFT2]) is TSpectraRanges) then
      begin
        if  extractFilename(TSpectraRanges(Form4.StringGrid1.Objects[2,FFT2]).xCoord.filename) <> RadioButton14.Caption then
          Exit ;  // exit if Instrument function is closed or has moved
      end
      else
          exit ;

      TSpectraRanges(Form4.StringGrid1.Objects[2,FFT1]).ConvolveByFFT(TSpectraRanges(Form4.StringGrid1.Objects[2,FFT1]),TSpectraRanges(Form4.StringGrid1.Objects[2,FFT2])) ;

      ///////////////////////////////////////////////////////////////////////////////////
      // Create glList for new spectra data points
        ///////////////////////////////////////////////////////////////////////////////////
      TSpectraRanges(Form4.StringGrid1.Objects[2,FFT1]).CreateGLList(Form1.Canvas.Handle, RC, GetWhichLineToDisplay()) ;
      TSpectraRanges(Form4.StringGrid1.Objects[2,FFT1]).SetOpenGLXYRange(GetWhichLineToDisplay()) ; // finds max and min values in xy data
      Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
      SpeedButton1Click(Form2) ; // Reset button - displays full x,y data range
      Form1.FormResize(Form2)  ;
     finally

     end ;       }

end;



procedure TForm2.RadioButton13Click(Sender: TObject);
begin
     Form2.RadioButton13.Caption := ExtractFileName(TSpectraRanges(Form4.StringGrid1.Objects[1,Form4.StringGrid1.Selection.Top]).xCoord.filename) ;
     Form2.RadioButton13.Hint := inttostr(Form4.StringGrid1.Selection.Top) ;
end;

procedure TForm2.RadioButton14Click(Sender: TObject);
begin
     Form2.RadioButton14.Caption := ExtractFileName(TSpectraRanges(Form4.StringGrid1.Objects[1,Form4.StringGrid1.Selection.Top]).xCoord.filename) ;
     Form2.RadioButton14.Hint := inttostr(Form4.StringGrid1.Selection.Top) ;
end;



procedure TForm2.Button10Click(Sender: TObject);
var
 GridRow, FFT1, FFT2, tint : Integer ;
begin
     messagedlg('CorrelateByFFT() not implemented yet' ,mtInformation,[mbOK],0) ;
  {   FFT1 := strtoint(Form2.RadioButton13.Hint) ;
     FFT2 := strtoint(Form2.RadioButton14.Hint) ;

     try
      if  ((Form4.StringGrid1.Objects[1,FFT1]) is TSpectraRanges) then
      begin
        if  extractFilename(TSpectraRanges(Form4.StringGrid1.Objects[1,FFT1]).xCoord.filename) <> RadioButton13.Caption then
          Exit ;  // exit if Instrument function is closed or has moved
      end
      else
          exit ;
      if  ((Form4.StringGrid1.Objects[1,FFT2]) is TSpectraRanges) then
      begin
        if  extractFilename(TSpectraRanges(Form4.StringGrid1.Objects[1,FFT2]).xCoord.filename) <> RadioButton14.Caption then
          Exit ;  // exit if Instrument function is closed or has moved
      end
      else
          exit ;

      TSpectraRanges(Form4.StringGrid1.Objects[1,FFT1]).CorrelateByFFT(TSpectraRanges(Form4.StringGrid1.Objects[1,FFT1]),TSpectraRanges(Form4.StringGrid1.Objects[1,FFT2])) ;

      ///////////////////////////////////////////////////////////////////////////////////
      // Create glList for new spectra data points
        ///////////////////////////////////////////////////////////////////////////////////
      TSpectraRanges(Form4.StringGrid1.Objects[1,FFT1]).CreateGLList(Form1.Canvas.Handle, RC, GetWhichLineToDisplay()) ;
      TSpectraRanges(Form4.StringGrid1.Objects[1,FFT1]).SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
      SpeedButton1Click(Form2) ; // Reset button - displays full x,y data range
      Form1.FormResize(Form2)  ;
     finally

     end ; }
end;





procedure TForm2.PCRClick(Sender: TObject);
Var
  tPCRReg : TPCResults ;
begin
 {    If RegSG.Objects[1,0] is  TRegression then
      begin
        tReg :=  TRegression(RegSG.Objects[1,0]) ;

        // do the PCA if not already done
        if not tReg.PCResults.dataCreated then
        begin
          PCAClick(Sender);
        end  ;

        // get y data
        if tReg.YdataInXMatrix then
          tReg.GetDataMatrix(RegSG.Cells[1,9],RegSG.Cells[1,10],tReg.allXData,tReg.YMatrix )
        else
          tReg.GetDataMatrix(RegSG.Cells[1,9],RegSG.Cells[1,10],tReg.allYData,tReg.YMatrix ) ;

        // now create model
         tReg.PCResults.CreatePCRModelMatrix(tReg.XMatrix, '1-'+inttostr(TRegression(RegSG.Objects[1,0]).PCResults.numPCs), tReg.YMatrix )   ; // +inttostr(TRegression(RegSG.Objects[1,0]).PCResults.numPCs)

         tReg.PCResults.EVectNormalsied.SaveMatrixDataTxt('EVects_output.txt',#9) ;
         tReg.PCResults.ScoresNormalised.SaveMatrixDataTxt('scores_output.txt',#9) ;
      end
      else
        messagedlg('Load data first by double clicking list above.' ,mtinformation,[mbOK],0) ;    }
end;



procedure TForm2.Save1Click(Sender: TObject);
begin

end;


// "Load  XY text data file" changes
procedure TForm2.DataInColsRadButtonClick(Sender: TObject);
begin
   Label15.Caption := 'X data row:' ;
end;

// "Load  XY text data file"
procedure TForm2.DataInRowsRadButtonClick(Sender: TObject);
begin
   Label15.Caption := 'X data column:' ;
end;


procedure TForm2.DendroAddPointsToRowEBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t1 : integer ;
begin

try
  t1 :=  strtoint(DendroAddPointsToRowEB.Text) ;  // the original numerical value

  if (Key = 38) or (Key=39) then  // arrow key on keyboard increment image number
  begin
     if SelectStrLst.Count > t1 then
      begin
        inc(t1) ;
        DendroAddPointsToRowEB.Text := inttostr(t1) ;    // max is checked in FrequencySlider1Change()
      end;
  end
  else
  if (Key = 37) or (Key=40) then  // arrow key on keyboard decrement image number
  begin
     if t1 > 1 then
     begin
       dec(t1) ;
       DendroAddPointsToRowEB.Text := inttostr(t1) ;
     end;
   end ;
except
   DendroAddPointsToRowEB.Text := '1'  ;
end;
  form1.Refresh ;
end;

procedure TForm2.DendroAddYearsToDataBTNClick(Sender: TObject);
Var
  t0, selectedRowNum, TraceCol, posAdded : integer ;
  first_x1, last_x1,  addedYCoordData  : single ;
  ringsSR : TSpectraRanges ;
  start, step : single ;
  tMS : TMemoryStream ;
begin

  SelectStrLst.SortListNumeric ;
  SelectColList.SortListNumeric ;

  if SelectColList.Count = 1 then   // make sure only 1 column is selected
  begin
  TraceCol := StrToInt(SelectColList.Strings[0]);

  // for each row selected, except last one which has averaged intra ring boundary information
  for t0 := 0 to SelectStrLst.Count-1 do
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
    if Form4.StringGrid1.Objects[ TraceCol ,selectedRowNum] is  TSpectraRanges  then
    begin
      ringsSR  :=  TSpectraRanges(Form4.StringGrid1.Objects[ TraceCol,selectedRowNum]) ;
      start := strtofloat(DendroSOYStartEB.Text) ;
      step  := strtofloat(DendroSOYStepEB.Text) ;

      ringsSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      ringsSR.xCoord.F_Mdata.Read(first_x1, 4) ;
      ringsSR.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
      ringsSR.xCoord.F_Mdata.Read(last_x1, 4) ;
      ringsSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;


      tMS := TMemoryStream.Create ;
      addedYCoordData := 500.00 ;
      tMS.Size := ringsSR.xCoord.SDPrec  ;
      tMS.Write(addedYCoordData,sizeof(single))   ;
      while (start < last_x1 ) do  // for each sample point
      begin
        posAdded := ringsSR.AddData(start,tMS) ;
        tMS.Seek(0,soFromBeginning) ;
        start := start + step ;
      end;
      tMS.Free ;

      // do display and interface stuff
      Form4.StringGrid1.Cells[TraceCol, selectedRowNum ] := '1-'+inttostr(ringsSR.yCoord.numRows)+' : '+'1-'+inttostr(ringsSR.yCoord.numCols) ;
      ringsSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      ringsSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), ringsSR.lineType ) ;

    end;  // if selected column contains a TSpectraRanges object
   end;
   end
   else
   begin
        Form4.StatusBar1.Panels[1].Text := 'Error: Select single columns of data only'  ;
   end;

   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;



end;



// requires the average x position data to be at bottom of list
// which is created through "Average / RMSE-> Extract Ave X data" right button menu
// making sure you extract the middle data
procedure TForm2.DendroAverageRingStrutureBTNClick(Sender: TObject);
Var
  t0, t1, t2, selectedRowNum, TraceCol, RingCol  : integer ;
  numSamplesInYear, totalSamplesRead : integer ;
  s1, s2, year  : single ;
  avePoint1     : single ;
  TraceSR, RingSR, AveRingDataSR, newSR : TSpectraRanges ;
  tMS1 : TMemoryStream ;
begin

  SelectStrLst.SortListNumeric ;
  SelectColList.SortListNumeric ;

  if SelectColList.Count = 2 then   // make sure only 2 columns are selected
  begin
  TraceCol := StrToInt(SelectColList.Strings[0]);
  RingCol  := StrToInt(SelectColList.Strings[1]);


  // AveRingDataSR is at bottom of list and was created through "Average / RMSE-> Extract Ave X data" right button menu
  if Form4.StringGrid1.Objects[TraceCol, strtoint(SelectStrLst.Strings[SelectStrLst.Count-1])] is  TSpectraRanges  then
    AveRingDataSR := TSpectraRanges(Form4.StringGrid1.Objects[TraceCol, strtoint(SelectStrLst.Strings[SelectStrLst.Count-1])])
  else
  if Form4.StringGrid1.Objects[RingCol, strtoint(SelectStrLst.Strings[SelectStrLst.Count-1])] is  TSpectraRanges  then
    AveRingDataSR := TSpectraRanges(Form4.StringGrid1.Objects[RingCol, strtoint(SelectStrLst.Strings[SelectStrLst.Count-1])])
  else
    exit ;  // exit if either of bottom row columns does not contain a TSpectraRange (the average ring data)

  // for each row selected, except last one which has averaged intra ring boundary information
  for t0 := 0 to SelectStrLst.Count-2 do
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
  // 1st column is the X (density) trace data
  if Form4.StringGrid1.Objects[ TraceCol ,selectedRowNum] is  TSpectraRanges  then
  begin
  // 2nd column is the intra-ring data
  if Form4.StringGrid1.Objects[ RingCol ,selectedRowNum] is  TSpectraRanges  then
  begin
    // The first row of the Y data (tSR1 = column 3)
    // will be the xCoord data for the TSpectra in the X Data column
    TraceSR  :=  TSpectraRanges(Form4.StringGrid1.Objects[ TraceCol,selectedRowNum]) ;
    RingSR   :=  TSpectraRanges(Form4.StringGrid1.Objects[ RingCol ,selectedRowNum]) ;

    // this TMatrix will hold the number of points in the trace that occurs within a ring increment
    tMS1 := TMemoryStream.Create ;
    tMS1.SetSize(RingSR.xCoord.numCols * sizeof(integer));
    totalSamplesRead := 0 ;
    TraceSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    RingSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

    for t1 := 0 to RingSR.xCoord.numCols - 1 do  // for each ring
    begin
       numSamplesInYear := 0 ;
       RingSR.xCoord.F_Mdata.Read(s1, RingSR.yCoord.SDPrec) ;
       TraceSR.xCoord.F_Mdata.Read(s2, TraceSR.yCoord.SDPrec) ;
       while (s2 < s1) and (totalSamplesRead < TraceSR.xCoord.numCols) do  // for each ring
       begin  // count number of data points that are within the ring
          inc(numSamplesInYear) ;
          inc(totalSamplesRead) ;
          TraceSR.xCoord.F_Mdata.Read(s2, TraceSR.xCoord.SDPrec) ;
       end;
       inc(numSamplesInYear) ;
       inc(totalSamplesRead) ;
       tMS1.Write(numSamplesInYear, sizeof(integer))  ;
    end;

    if  Form4.StringGrid1.Objects[RingCol+1, selectedRowNum] = nil then
    begin
      // create TSpectraRanges object for each TSpectraRanges selected (one at a time)
      newSR :=  TSpectraRanges.Create(TraceSR.yCoord.SDPrec,TraceSR.yCoord.numRows, TraceSR.yCoord.numCols,@TraceSR.LineColor );
      // point pointer newSR to the new TSpectraRange object
      Form4.StringGrid1.Objects[RingCol+1, selectedRowNum] := newSR ;
      // copy the original data
      newSR.CopySpectraObject(TraceSR);

      tMS1.Seek(0, soFromBeginning)  ;
      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      AveRingDataSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      year := 0 ;

      for t1 := 0 to RingSR.xCoord.numCols - 1 do  // for each ring
      begin
         s2 := 0 ;
         tMS1.Read(numSamplesInYear, sizeof(integer))  ;
         AveRingDataSR.yCoord.F_Mdata.Read(avePoint1, sizeof(integer))  ;
         // stretch xCoord data to fit between
         s1 :=  ( (avePoint1 - year) / numSamplesInYear ) ;
         for t2 := 0 to numSamplesInYear -1 do
         begin
           s2 := year + (t2*s1) ;
           newSR.xCoord.F_Mdata.Write(s2, newSR.xCoord.SDPrec) ;
         end;
         year := avePoint1 ;
      end;
      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      // do display and interface stuff
      newSR.GLListNumber := Form4.GetLowestListNumber ;
      if TraceSR.fft.dtime  <> 0 then
        newSR.fft.CopyFFTObject(TraceSR.fft) ;
      Form4.StringGrid1.Cells[RingCol+1, selectedRowNum ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      newSR.xCoord.Filename :=  'xCoord_scaled_to_ave_struct.bin'   ;
      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

    end;
     //   Form4.StatusBar1.Panels[1].Text := 'Error: X data and Y data differ in number of columns'  ;
     tMS1.Free ;
   end;  // if it is a TSpectraRanges object
   end ; // if it is a TSpectraRanges object
   end;  // for each row selected
   end
   else
   begin
        Form4.StatusBar1.Panels[1].Text := 'Error: Need to select 2 columns of data only'  ;
   end;

   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;

end;

procedure TForm2.DendroBackYearSBClick(Sender: TObject);
var
  s1 : single ;
begin

try
   s1  := strtofloat(DendroYearEB.Text) -1  ;
   if (s1) >= 1  then
     DendroYearEB.Text := floattostr((s1)) ;

   // shift viewable range and update screen
   DendroStretchViewToYear( s1-1, s1) ;

except on EConvertError do
   DendroYearEB.Text := '1' ;
end;
   
end;

procedure TForm2.DendroForwardYearSBClick(Sender: TObject);
var
  s1 : single ;
begin
try
   s1 := strtofloat(DendroYearEB.Text) +1 ;
   DendroYearEB.Text := floattostr((s1)) ;
   DendroStretchViewToYear( s1-1, s1) ;
except on EConvertError do
   DendroYearEB.Text := '1' ;
end;
end;



procedure TForm2.DendroMODISDataCBClick(Sender: TObject);
begin
     if DendroMODISDataCB.Checked then
     begin
        CheckBox3.Checked := true ;
        DataInColsRadButton.Checked := true ;
        XDataRowColEdit.Text := '6' ;
        XRangeEditBox.Text   := '6-6' ;
        YDataRangeEdit.Text := '9-' ;
     end
     else
        CheckBox3.Checked := false ;
end;

procedure TForm2.DendroOffsetTracePercentKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t1 : integer ;
begin

try
  t1 :=  strtoint(copy(DendroOffsetTracePercent.Text,1,length(trim(DendroOffsetTracePercent.Text))-1)) ;

  if (Key = 38) or (Key=39) then  // arrow key on keyboard increment image number
  begin
       t1 := t1 + 2 ;
       DendroOffsetTracePercent.Text := inttostr(t1) + '%' ;    // max is checked in FrequencySlider1Change()
  end
  else
  if (Key = 37) or (Key=40) then  // arrow key on keyboard decrement image number
  begin
       t1 := t1 - 2 ;
       DendroOffsetTracePercent.Text := inttostr(t1) + '%' ;
   end ;
except on EconvertError do
   DendroOffsetTracePercent.Text := '+10%'  ;
end;
  form1.Refresh ;
end;

procedure TForm2.DendroPlacePeakstCBClick(Sender: TObject);
begin
  form1.Refresh ;
end;

procedure TForm2.DendroYearEBClick(Sender: TObject);
var
  s1 : single ;
begin
try
   s1 := strtofloat(DendroYearEB.Text) ;
   // shift viewable range and update screen
   DendroStretchViewToYear( s1-1, s1) ;
except on EConvertError do
   DendroYearEB.Text := '1' ;
end;

end;

procedure TForm2.DendroYearEBEnter(Sender: TObject);
var
  s1 : single ;
begin
try
   s1 := strtofloat(DendroYearEB.Text) ;
   // shift viewable range and update screen
   DendroStretchViewToYear( s1-1, s1) ;
except on EConvertError do
   DendroYearEB.Text := '1' ;
end;
end;


procedure TForm2.DendroStretchViewToYear(start, finish :single) ;
begin
  // shift viewable range and update screen
   if DendroPlacePeakstCB.Checked then
   begin
     OrthoVarXMin := start ;
     OrthoVarXMax := finish   ;
     Form1.FormResize(Form2)  ;
   end;
end;



function TForm2.DendroSumFullStep(startIn, stepIn, xStepIn : Single ;  IntegDiskBool :boolean; TraceDRIn : TSpectraRanges) : TSpectraRanges ;
Var
  t0, t1, t2, numPointsAdded : integer ;
  x_s1, x_s2, y_s1, y_s2, sum, startInCopy, currentRadius  : single ;
   newSR : TSpectraRanges ;
begin
      // create new line in stringgrid and create TSpectraRanges object for each TSpectraRanges selected (one at a time)
      newSR :=  TSpectraRanges.Create(TraceDRIn.yCoord.SDPrec,1, 0,@TraceDRIn.LineColor );
      // point pointer newSR to the new TSpectraRange object

      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      t2 := 1 ;
      numPointsAdded := 0 ;
      startInCopy := startIn ;
      TraceDRIn.xCoord.F_Mdata.Read(x_s1,TraceDRIn.xCoord.SDPrec)  ;
      TraceDRIn.yCoord.F_Mdata.Read(y_s1,TraceDRIn.xCoord.SDPrec)  ;
      x_s2 := x_s1 ;
      while (t2 < TraceDRIn.xCoord.numCols) do  // for each sample point
      begin
         sum := 0 ;

         if (xStepIn = 0.0) then  // use the distance between the xCoord data points for the area
         begin
           while (x_s1 <= startIn) and (t2 < TraceDRIn.xCoord.numCols) do
           begin
             TraceDRIn.xCoord.F_Mdata.Read(x_s2,TraceDRIn.xCoord.SDPrec)  ;
             TraceDRIn.yCoord.F_Mdata.Read(y_s2,TraceDRIn.xCoord.SDPrec)  ;
              if IntegDiskBool then
               y_s1 := ((y_s1 + y_s2) / 2) * pi * ((x_s2*x_s2) - (x_s1*x_s1) )
             else
               y_s1 := ((y_s1 + y_s2) / 2) * (x_s2 - x_s1 );

             sum := sum + y_s1 ;
             inc(t2) ;
             x_s1 := x_s2 ;
             y_s1 := y_s2 ;
           end;
         end
         else // use the xStepIn as the x coordinate value for integration
          begin
           while (x_s1 <= startIn) and (t2 < TraceDRIn.xCoord.numCols) do
           begin
             TraceDRIn.xCoord.F_Mdata.Read(x_s2,TraceDRIn.xCoord.SDPrec)  ;
             TraceDRIn.yCoord.F_Mdata.Read(y_s2,TraceDRIn.xCoord.SDPrec)  ;
             if IntegDiskBool then
             begin
               // currentRadius := numPointsAdded * xStepIn ;
               currentRadius := t2 * xStepIn ;
               y_s1 := ((y_s1 + y_s2) / 2) * pi * (((currentRadius+xStepIn)*(currentRadius+xStepIn))-(currentRadius*currentRadius ) ) ;
             end
             else
               y_s1 := ((y_s1 + y_s2) / 2) * xStepIn;

             sum := sum + y_s1 ;
             inc(t2) ;
             x_s1 := x_s2 ;
             y_s1 := y_s2 ;
           end;
         end ;
         inc(numPointsAdded) ;

         newSR.xCoord.numCols := newSR.xCoord.numCols + 1 ;
         newSR.yCoord.numCols := newSR.yCoord.numCols + 1 ;
         newSR.xCoord.F_Mdata.SetSize(numPointsAdded * 4);
         newSR.yCoord.F_Mdata.SetSize(numPointsAdded * 4);

         newSR.xCoord.F_Mdata.Write(startIn, 4 ) ;
         newSR.yCoord.F_Mdata.Write(sum, 4 ) ;

         startIn := startInCopy + (stepIn*numPointsAdded) // startIn + stepIn ;
      end;
      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      // return the new TSpectraRanges object
      result := newSR ;

end;

function TForm2.DendroSumContinuous(startIn, stepIn, xStepIn : Single ;  IntegDiskBool :boolean; TraceDRIn : TSpectraRanges) :TSpectraRanges ;
Var
  t0, t1, t2 : integer ;
  x_s1, x_s2, y_s1, y_s2, sum, pointVal, startInCopy, currentRadius  : single ;
  newSR : TSpectraRanges ;
begin
         // create new line in stringgrid and create TSpectraRanges object for each TSpectraRanges selected (one at a time)
      newSR :=  TSpectraRanges.Create(TraceDRIn.yCoord.SDPrec,TraceDRIn.yCoord.numRows, TraceDRIn.xCoord.numCols,@TraceDRIn.LineColor );
      // point pointer newSR to the new TSpectraRange object

      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      TraceDRIn.xCoord.F_Mdata.Read(x_s1,TraceDRIn.xCoord.SDPrec)  ;
      TraceDRIn.yCoord.F_Mdata.Read(y_s1,TraceDRIn.xCoord.SDPrec)  ;
      x_s2 := x_s1 ;
      t2 := 0 ;
      startInCopy := startIn ;
      for t0 := 0 to TraceDRIn.xCoord.numCols -1 do  // for each sample point
      begin
         sum := 0 ;
         if (xStepIn = 0.0) then // use the distance between the xCoord data points for the area
         begin
           while (x_s1 <= startIn) and (t2 < TraceDRIn.xCoord.numCols) do
           begin
             TraceDRIn.xCoord.F_Mdata.Read(x_s2,TraceDRIn.xCoord.SDPrec)  ;
             TraceDRIn.yCoord.F_Mdata.Read(y_s2,TraceDRIn.xCoord.SDPrec)  ;
             if IntegDiskBool then
               y_s1 := ((y_s1 + y_s2) / 2) * pi * ((x_s2*x_s2) - (x_s1*x_s1) )
             else
               y_s1 := ((y_s1 + y_s2) / 2) * (x_s2 - x_s1 );
             sum := sum + y_s1 ;
             inc(t2) ;
             newSR.xCoord.F_Mdata.Write(x_s1, 4 ) ;
             newSR.yCoord.F_Mdata.Write(sum, 4 ) ;
             x_s1 := x_s2 ;
             y_s1 := y_s2 ;
         end;
         end
         else
         begin
           while (x_s1 <= startIn) and (t2 < TraceDRIn.xCoord.numCols) do
           begin
             TraceDRIn.xCoord.F_Mdata.Read(x_s2,TraceDRIn.xCoord.SDPrec)  ;
             TraceDRIn.yCoord.F_Mdata.Read(y_s2,TraceDRIn.xCoord.SDPrec)  ;
             if IntegDiskBool then
             begin
               // currentRadius := t0 * xStepIn ;
               currentRadius := t2 * xStepIn ;
               y_s1 := ((y_s1 + y_s2) / 2) * pi * (((currentRadius+xStepIn)*(currentRadius+xStepIn))-(currentRadius*currentRadius ) ) ;
             end
             else
               y_s1 := ((y_s1 + y_s2) / 2) * xStepIn;
             sum := sum + y_s1 ;
             inc(t2) ;
             newSR.xCoord.F_Mdata.Write(x_s1, 4 ) ;
             newSR.yCoord.F_Mdata.Write(sum, 4 ) ;
             x_s1 := x_s2 ;
             y_s1 := y_s2 ;
         end;
         end;
         startIn := startInCopy + ((t0+1)*stepIn) ;// startIn + stepIn ;
      end;

      newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
      TraceDRIn.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

      // return the new TSpectraRanges object
      result := newSR ;
end;

procedure TForm2.DendroSumOverYearBTNClick(Sender: TObject);
Var
  t0, t1, t2, selectedRowNum, TraceCol, numPointsAdded : integer ;
  x_s1, x_s2, y_s, sum, pointVal  : single ;
  TraceSR, newSR : TSpectraRanges ;
  start, step, xstep : single ;
begin

  SelectStrLst.SortListNumeric ;
  SelectColList.SortListNumeric ;

  if SelectColList.Count = 1 then   // make sure only 1 column is selected
  begin
  TraceCol := StrToInt(SelectColList.Strings[0]);

  // for each row selected, except last one which has averaged intra ring boundary information
  for t0 := 0 to SelectStrLst.Count-1 do
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
  if Form4.StringGrid1.Objects[ TraceCol ,selectedRowNum] is  TSpectraRanges  then
  begin
  if Form4.StringGrid1.Objects[ TraceCol+1 ,selectedRowNum] =  nil  then
  begin

      TraceSR  :=  TSpectraRanges(Form4.StringGrid1.Objects[ TraceCol,selectedRowNum]) ;
      start := strtofloat(DendroSOYStartEB.Text) ;
      step  := strtofloat(DendroSOYStepEB.Text) ;
      xstep := strtofloat(DendroSOYXStepEB.Text) ;
      if DendroSumFullStepRB.Checked then
      begin
          newSR := DendroSumFullStep(start, step, xstep, DendroIntegDiskAreaCB.checked, TraceSR ) ;
      end
      else
      begin
         newSR := DendroSumContinuous(start, step, xstep, DendroIntegDiskAreaCB.checked, TraceSR ) ;
      end;

      // point the cell of interest to the new SR
      Form4.StringGrid1.Objects[TraceCol+1, selectedRowNum] := newSR ;
      // do display and interface stuff
      newSR.GLListNumber := Form4.GetLowestListNumber ;
      if TraceSR.fft.dtime  <> 0 then
        newSR.fft.CopyFFTObject(TraceSR.fft) ;
      Form4.StringGrid1.Cells[TraceCol+1, selectedRowNum ] := '1-'+inttostr(newSR.yCoord.numRows)+' : '+'1-'+inttostr(newSR.yCoord.numCols) ;
      newSR.xCoord.Filename :=  'xCoord_scaled_to_ave_struct.bin'   ;
      newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

   end ;  // new column does not contain an object
   end;  // if selected column contains a TSpectraRanges object
   end;  // for each row selected
   end
   else
   begin
        Form4.StatusBar1.Panels[1].Text := 'Error: Select single columns of data only'  ;
   end;

   if not Form4.CheckBox7.Checked then
     form1.UpdateViewRange() ;
   form1.Refresh ;


end;

procedure TForm2.DendroYearEBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s1 : single ;
begin

if trim(DendroYearEB.Text) <> '' then
begin
try
  s1 :=  strtofloat(DendroYearEB.Text) ;
  originalTBText := s1 ;
  if (Key = 38) or (Key=39) then  // arrow key on keyboard increment image number
  begin
       s1 := s1 + 1 ;
       DendroYearEB.Text := floattostr(s1) ;    // max is checked in FrequencySlider1Change()
       // shift viewable range and update screen
       DendroStretchViewToYear( s1-1, s1) ;
  end
  else
  if (Key = 37) or (Key=40) then  // arrow key on keyboard decrement image number
  begin
     if s1 > 1 then
     begin
       s1 := s1 - 1 ;
       DendroYearEB.Text := floattostr(s1) ;
     end;

      DendroStretchViewToYear( s1-1, s1) ;
   end ;

   if  (Key > 64) and (Key < 91) then
     DendroYearEB.Text := floattostr(s1) ;


except on EConvertError do
   DendroYearEB.Text := '1'  ;
end;
end ;

end;

procedure TForm2.DendroYearEBKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if  (Key > 64) and (Key < 91) then   // if not a number
     DendroYearEB.Text := floattostr(originalTBText) ;
end;

// for verification of format of "Load  XY text data file" information
procedure TForm2.XRangeEditBoxChange(Sender: TObject);
var
  tStr1 : string ;
  t1 : integer ;
  XStart, XFin : integer ;
begin
  try
    tStr1 := Form2.XRangeEditBox.text ;
    t1 := pos('-',tStr1) ;
    if t1 > 0 then
    begin
      XStart := strtoint(copy(tStr1,1,t1-1)) ;
      tStr1 :=  copy(tStr1,t1+1,Length(tStr1)-t1) ;
      tStr1 := trim(tStr1) ;
      if Length(tStr1) > 0 then
      begin
         XFin := strtoint(tStr1);
         if XStart > XFin then
  //         raise EConvertError.Create('Edit error: Incorrect input parameters'+#13+'Format example: 1-200 or 1- (for full range)')
         end ;
      end
      else
        XFin := 0 ;

  except on EConvertError do
  begin
   // messagedlg('Edit error: Incorrect input parameters'+#13+'Format example: 1-200 or 1- (for full range)' ,mtError,[mbOK],0) ;
    Form2.XRangeEditBox.text := '' ;
  end ;
  end ;

end;

procedure TForm2.ComboBox2Change(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
begin
  if pos('/',Edit30.Text) = 0 then
    Edit30.Text :=  Edit30.Text + ' / ' + ComboBox2.Text
  else
    Edit30.Text :=  copy(Edit30.Text,1,pos('/',Edit30.Text)) + ' ' + ComboBox2.Text  ;

  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        tSR.xString := Edit30.Text ;
     end ;
  end ;
//  Form1.UpdateViewRange() ;
  Form1.Refresh ;
end;

procedure TForm2.Edit30KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
{  if pos('/',Edit30.Text) = 0 then
    Edit30.Text :=  Edit30.Text + '/' ;

  form1.Refresh ;  }
end;

procedure TForm2.ReduceBtnClick(Sender: TObject);
var
  t1, t2 : integer ;
  numX, numY : integer ;
  tSR : TSpectraRanges ;
  numAveIn : integer ;
  roworcols : integer ;
  tMat, tMatAve, tMatAve_returned : TMatrix ;
  xVarRangeString, yVarRangeString : string ;
  xx, yy, add_y : integer ;
  rowOrCol: RowsOrCols ;
begin
// get input data from form2

  numAveIn := strtoint(AveReduceNumTB.Text);
//  tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,strtoint(SelectStrLst.Strings[t1])])  ;
  numX := strtoint(Edit5.Text);
  numY := strtoint(Edit17.Text);

  if (XVarRB.Checked) or  (SpectraRB.Checked) then  // reduce in X variable (column) direction or Spectra (rows) direction
  begin
    if XVarRB.Checked then
      roworcol := Cols
    else
    if SpectraRB.Checked then
      roworcol := Rows ;

    for t1 := 0 to   SelectStrLst.Count -1 do  // for each spectra in list
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,strtoint(SelectStrLst.Strings[t1])]) ;
      tSR.AverageReduce(numAveIn,roworcol) ;
      if tSR.nativeImage then
      begin
        if XVarRB.Checked then
        begin
          tSR.xPix :=  tSR.xPix div numAveIn ;
          tSR.xPixSpacing := tSR.xPixSpacing * numAveIn ;
        end
        else if SpectraRB.Checked then
        begin
          tSR.yPix :=  tSR.yPix div numAveIn ;
          tSR.yPixSpacing := tSR.yPixSpacing * numAveIn ;
        end ;
      end ;

      tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

      Form4.StringGrid1.Cells[2,strtoint(SelectStrLst.Strings[t1])] :=  '1-'+inttostr(tSR.yCoord.numRows) + ':1-' +  inttostr(tSR.xCoord.numCols) ;
    end ;
  end
  else
  if  Spectra2D.Checked then
  begin
  try
    tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,strtoint(SelectStrLst.Strings[0])])  ;
    tMat := TMatrix.Create(tSR.yCoord.SDPrec div 4)  ;
    tMatAve := TMatrix.Create(tSR.yCoord.SDPrec div 4)  ;

    for t1 := 0 to   SelectStrLst.Count -1 do
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[2,strtoint(SelectStrLst.Strings[t1])])  ;

      if (numX * numY) <> tSR.yCoord.numRows then
      begin
         MessageDlg('2D Dimensions provided do not match number of spectra present.' +#13+ 'Operation will not be completed.' ,mtError, [mbOK], 0) ;
         exit ;
      end ;

      xVarRangeString := '1-' + inttostr(tSR.yCoord.numCols) ;

       // fetch data
       yy := 0 ;
       add_y := 0 ;
       xx := 1 ;
       yVarRangeString := '' ;

       while yy < numY do
       begin
         while xx+1 <= numX do
         begin
           yVarRangeString := inttostr(xx+add_y)+','+inttostr(xx+1+add_y) +','+inttostr(numX+xx+add_y) +','+inttostr(numX+xx+1+add_y)  ;
           xx := xx + 2 ;
           tMatAve.FetchDataFromTMatrix( yVarRangeString, xVarRangeString , tSR.yCoord ) ;
           tMatAve_returned := tMatAve.AverageReduce(4,Rows) ;
           tMat.AddRowToEndOfData(tMatAve_returned,1,tSR.yCoord.numCols) ;
           yVarRangeString := '' ;
           tMatAve_returned.Free ;
           // tMatAve.ClearData(tSR.yCoord.SDPrec div 4) ;  // not needed as done in FetchDataFromTMatrix() function
         end ;
         yy := yy + 2 ;
         add_y :=  (yy * numX)  ;
         xx := 1 ;
       end ;

       tSR.yCoord.ClearData(tSR.yCoord.SDPrec div 4) ;
       tSR.yCoord.CopyMatrix(tMat) ;

       tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
       tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 1) ;

        Form4.StringGrid1.Cells[2,strtoint(SelectStrLst.Strings[t1])] :=  '1-'+inttostr(tSR.yCoord.numRows) + ':1-' +  inttostr(tSR.xCoord.numCols) ;

        tMat.ClearData(tSR.yCoord.SDPrec div 4) ;
    end ;  // for each file in list

    // AddRowsToMatrix
    finally
      tMat.Free ;
      tMatAve.Free ;
    end ;
  end ;

  form1.Refresh ;

end;


procedure TForm2.ShowCursorClick(Sender: TObject);
begin
  Form1.refresh
end;


procedure TForm2.NumColsEB1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
var
  t1, t2 : integer ;
  s1 : single ;
begin
  If MouseDownMat Then
  begin
  {  t1 := strtoint(edit18.Text) ;
    t2 := Y div 10 ;
    if t2 > 0 then
      t1 := t1 - (t2 div 100);
    Edit18.Text := inttostr(t1) ;     }
  end ;

end;

procedure TForm2.FrequencySlider1Change(Sender: TObject);
var
  t1, t2 : integer ;
 // t1x, t1y : integer ;
  SpectObj : TSpectraRanges ;
  pixSpace : single ;
  s1 : single ;
  TempXY : array[0..1] of single ;
  imageOffset : integer ;
begin
  if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
  begin
    SpectObj := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]) ;

    if SpectObj.interleaved = 1  then // standard "all positions at a single angle first" data arrangement
    begin
       imageOffset :=  (SpectObj.xPix * SpectObj.yPix) * (SpectObj.currentImageNumber-1) ; // the offset to the image of interest
    end
    else
    if SpectObj.interleaved = 2  then // usually due to being processed as IR-polarisation code
    begin
       imageOffset := SpectObj.currentImageNumber ; // the offset to the image of interest
    end  ;

    Form2.Label34.Caption := 'Image offset: '+ inttostr( imageOffset ) ;


    if SpectObj.frequencyImage then
    begin
       if (SpectObj.yCoord.numRows < (imageOffset+(SpectObj.xPix * SpectObj.yPix)) ) then
       begin
         //  messagedlg('Subfile does not seem to be present'+ #13 +'EVect first image' ,mtError,[mbOk],0) ;
         Form2.ImageNumberTB1.Text := '1' ;
         imageOffset :=  0  ; // the offset to the image of interest
       end ;

       if sender = FrequencySlider1 then
         SpectObj.currentSlice :=  Form2.FrequencySlider1.Position   ;

       SpectObj.image2DSpecR.SeekFromBeginning(3,1,0) ;
       if SpectObj.interleaved = 2  then    // this is IR-pol format, where each polarisation angle spectra at an individual pixel is one after another
       begin
         for t1 := 0 to SpectObj.yPix-1 do
         begin
           for t2 := 1 to SpectObj.xPix do
           begin
             SpectObj.Read_YrYi_Data(SpectObj.currentSlice,((((t1*SpectObj.xPix)+t2)-1)*(SpectObj.numImagesOrAngles))+imageOffset,@TempXY,true) ;
             SpectObj.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
           end ;
         end ;
       end
       else
       if SpectObj.interleaved = 1  then     // this is standard interleaved format with image in large block (i.e. 32x32 spectra, followed by another 32x32 etc)
       begin
         for t1 := 0 to SpectObj.yPix-1 do
         begin
           for t2 := 1 to SpectObj.xPix do
           begin
             SpectObj.Read_YrYi_Data(SpectObj.currentSlice,(t1*SpectObj.xPix)+t2+imageOffset,@TempXY,true) ;
             SpectObj.image2DSpecR.Write_YrYi_Data(t2,t1+1,@TempXY,false) ;
           end ;
         end ;
       end ;

       SpectObj.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
       SpectObj.XHigh :=  SpectObj.image2DSpecR.XHigh ;
       SpectObj.XLow :=  SpectObj.image2DSpecR.XLow ;
       SpectObj.YHigh :=  SpectObj.yPix * SpectObj.yPixSpacing ;
       SpectObj.YLow :=  0 ;
       if  SpectObj.image2DSpecR.yCoord.numRows > 1 then
         SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), SpectObj.image2DSpecR.lineType)
       else
         SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 3)  ;

       SpectObj.xCoord.F_Mdata.Seek((SpectObj.xCoord.SDPrec * SpectObj.currentSlice )-SpectObj.xCoord.SDPrec,soFromBeginning) ;
       SpectObj.xCoord.F_Mdata.Read(s1,4) ;
       Form2.imageSliceValEB.Text  := floattostrF(s1,ffGeneral,5,3 ) ; // image slice position
       Form4.StatusBar1.Panels[1].Text := 'image range = ' + floattostrf(SpectObj.image2DSpecR.yLow,ffgeneral,5,3) +' to '+  floattostrf(SpectObj.image2DSpecR.yHigh,ffgeneral,5,3) ;
    end
    else
    if SpectObj.nativeImage then
    begin
     // Most commonly used to read in scores data from image PCA etc, where each spectra has a score for each PC along a single row

     if ((SpectObj.yCoord.F_Mdata.Size div SpectObj.yCoord.SDPrec) < (imageOffset+(SpectObj.xPix * SpectObj.yPix)) ) then
     begin
         //  messagedlg('Subfile does not seem to be present'+ #13 +'EVect first image' ,mtError,[mbOk],0) ;
         Form2.ImageNumberTB1.Text := '1' ;
         imageOffset :=  0  ; // the offset to the image of interest
     end ;
     if SpectObj.image2DSpecR <> nil then
     begin
       SpectObj.image2DSpecR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
       SpectObj.yCoord.F_Mdata.Seek(imageOffset*SpectObj.yCoord.SDPrec,soFromBeginning) ;
       // select data from main spectra (single wavelength)
       for t1 := 1 to (SpectObj.yPix*SpectObj.xPix) do
       begin
         SpectObj.Read_YrYi_Data(t1,1,@TempXY,false) ;
         SpectObj.image2DSpecR.Write_YrYi_Data(t1,1,@TempXY,false) ;
       end ;

       SpectObj.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
       SpectObj.XHigh :=  SpectObj.image2DSpecR.XHigh ;
       SpectObj.XLow :=  SpectObj.image2DSpecR.XLow ;
       SpectObj.YHigh :=  SpectObj.yPix * SpectObj.yPixSpacing  ;    // need to spread the image out in the Y direction as much as in X direction
       SpectObj.YLow :=  0 ;

       SpectObj.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), SpectObj.image2DSpecR.lineType) ;
     // SpectObj.YHigh & SpectObj.YLow should be saved to optimise contrast in the 2D image   Solution: they are stored in SpectObj.image2DSpecR.YHigh and YLow
       Form4.StatusBar1.Panels[1].Text := 'image range = ' + floattostrf(SpectObj.image2DSpecR.yLow,ffgeneral,5,3) +' to '+  floattostrf(SpectObj.image2DSpecR.yHigh,ffgeneral,5,3) ;
     end ;
  end

  end ;

  form1.Refresh ;

end;

procedure TForm2.ImageNumberTB1Change(Sender: TObject);
var
  SpectObj : TSpectraRanges ;
begin
  if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
  begin
    SpectObj := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]) ;
    try
      SpectObj.currentImageNumber :=   strtoint(Form2.ImageNumberTB1.Text) ;
    except on EConvertError do
    begin
      if trim(Form2.ImageNumberTB1.Text) <> '' then
      begin
        Form2.ImageNumberTB1.Text := '1' ;
        SpectObj.currentImageNumber := 1 ;
      end ;
    end ;
    end ;
  end ;
  FrequencySlider1Change(sender) ;
end;



procedure TForm2.ImageNumberTB1KeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  t1 : integer ;
  SpectObj : TSpectraRanges ;
begin
//     messagedlg('key pressed: '+ inttostr(Key) ,mtError,[mbOk],0) ;
  if (Key = 38) or (Key=39) then  // increment image number
       ImageNumberTB1.Text := inttostr(strtoint(ImageNumberTB1.Text)+1) ;    // max is checked in FrequencySlider1Change()
  if (Key = 37) or (Key=40) then  // decrement image number
  begin
     if strtoint(ImageNumberTB1.Text) > 1 then
       ImageNumberTB1.Text := inttostr(strtoint(ImageNumberTB1.Text)-1)
     else
     if strtoint(ImageNumberTB1.Text) = 1 then  // rotate around to max image number
     begin
        if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
        begin
          SpectObj := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]) ;
          if SpectObj.frequencyImage then
            t1 :=  SpectObj.yCoord.numRows div (SpectObj.xPix * SpectObj.yPix)
          else
          if SpectObj.nativeImage then
            t1 :=  SpectObj.yCoord.numRows * ( SpectObj.yCoord.numCols div (SpectObj.xPix * SpectObj.yPix)) ;

          ImageNumberTB1.Text := inttostr(t1)   ;
        end ;
     end ;
   end ;
end;

procedure GetClosestHighAndLowX(directionForward : boolean; newSR : TSpectraRanges;  current_point: single; var closest_high, closest_low : single; var pos_high : integer) ;
var
  t1, t2 : integer ;
begin

    newSR.xCoord.F_Mdata.Seek(pos_high*newSR.xCoord.SDPrec,soFromBeginning) ;

    if directionForward then
    begin
    if current_point >= closest_high then
    begin
      t1 := pos_high ;
      while  (closest_high <= current_Point) and (t1 < newSR.xCoord.numCols) do
      begin
       newSR.xCoord.F_Mdata.Read(closest_high, newSR.xCoord.SDPrec ) ;
       inc(t1) ;
      end ;
      newSR.xCoord.F_Mdata.Seek(-2*newSR.xCoord.SDPrec,soFromCurrent) ;
      newSR.xCoord.F_Mdata.Read(closest_low, newSR.xCoord.SDPrec ) ;
      newSR.xCoord.F_Mdata.Seek(newSR.xCoord.SDPrec,soFromCurrent) ;
      pos_high := t1 ;
    end  ;
    end
    else   // directionForward = false
    begin
    if current_point <= closest_low then
    begin
      t1 := pos_high ;
      while  (closest_low >= current_Point) and (t1 < newSR.xCoord.numCols) do
      begin
       newSR.xCoord.F_Mdata.Read(closest_low, newSR.xCoord.SDPrec ) ;
       inc(t1) ;
      end ;
      newSR.xCoord.F_Mdata.Seek(-2*newSR.xCoord.SDPrec,soFromCurrent) ;
      newSR.xCoord.F_Mdata.Read(closest_high, newSR.xCoord.SDPrec ) ;
      newSR.xCoord.F_Mdata.Seek(newSR.xCoord.SDPrec,soFromCurrent) ;
      pos_high := t1 ;
    end  ;

    end ;
    // otherwise closest_high, closest_low  keep original values
end ;


procedure TForm2.LinearInterpolate(tSR, newSR: TSpectraRanges; start, step: single) ;
var
     t1, t2 : integer ;
     first, last : single  ;
     current_pointx : single ;
     calc_pointy : single ;
     closest_highx, closest_lowx : single ; // these are the two points surrounding in the original data that surround the new point of interest
     closest_highy, closest_lowy : single ;
     slope, intercept : single ;
     number : integer ;
     pos_high : integer ;
     dirForwar : boolean ;
begin
  // get first and last x value  so we can count total
  // number of new interpolated points we are calculating
  tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  tSR.xCoord.F_Mdata.Read(first,4) ;
  tSR.xCoord.F_Mdata.Seek(-4,soFromEnd) ;
  tSR.xCoord.F_Mdata.Read(last,4) ;
  tSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;

  dirForwar := true ;
  // 1. count number of points to be created
  if first >  last then  // make sure xCoord data is in assumed low to high direction
  begin
    calc_pointy :=  first ;
    first := last ;
    last :=  calc_pointy ;
    dirForwar := false ;
  end ;
  // Check that 'start' is within the available xCoord range
  if start < first then
    messagedlg('Interpolate error:'+#13+'start value is lower than data in xCoord' ,mtError,[mbOK],0) ;

  current_pointx :=  start ;
  number := 1 ;
  // 1.2 Count the number of points needed to span the original data
  number := round(abs((last-first)/step))  ;
//  while  current_pointx < last do
//  begin
//    current_pointx := current_pointx + step_d ;
//    inc(number) ;
//  end ;
//  dec(number) ;

  // 2. set x data of interpolated spectra
  newSR.xCoord.F_Mdata.SetSize(4 * number) ;
  newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
  newSR.xCoord.numRows := 1 ;
  newSR.xCoord.numCols := number ;
  if dirForwar then
  begin
    for t1 := 0 to number-1 do
    begin
     current_pointx := start +  (t1 * step) ;
     newSR.xCoord.F_Mdata.Write(current_pointx,4) ;
    end ;
  end
  else   // dirForwar = false
  begin
   for t1 := 0 to number-1 do
    begin
     current_pointx :=  (start + ((number-1)*step)) - (t1*step) ;
     newSR.xCoord.F_Mdata.Write(current_pointx,4) ;
    end ;
  end ;

  // 3. set size of y data
  newSR.yCoord.F_Mdata.SetSize(4 * number * tSR.yCoord.numRows) ;
  newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
  newSR.yCoord.numRows := tSR.yCoord.numRows ;
  newSR.yCoord.numCols := number ;

  // 4. Interpolate for each row in original data
  for t1 := 1 to newSR.yCoord.numRows do
  begin
     pos_high := 0 ;
     newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
     tSR.yCoord.F_Mdata.Seek((((t1-1)*tSR.yCoord.numCols)*tSR.yCoord.SDPrec),soFromBeginning) ;
     newSR.xCoord.F_Mdata.Read(current_pointx,4) ;
     closest_highx := current_pointx ;
     closest_lowx  := current_pointx ;
     for t2 := 1 to newSR.yCoord.numCols do   // create each data point
     begin
        // this returns position of y data in 'pos_high'
         if  dirForwar  then
           GetClosestHighAndLowX(dirForwar, tSR, current_pointx, closest_highx, closest_lowx, pos_high)
         else  // swap  closest_lowx, closest_highx paramaters
           GetClosestHighAndLowX(dirForwar, tSR, current_pointx, closest_lowx, closest_highx , pos_high) ;

        // Get Y data for desired xCoord of original data
        tSR.yCoord.F_Mdata.Seek((((t1-1)*tSR.yCoord.numCols)*tSR.yCoord.SDPrec)+ ((pos_high-2)*tSR.yCoord.SDPrec),soFromBeginning) ;
        tSR.yCoord.F_Mdata.Read(closest_lowy,newSR.yCoord.SDPrec);
        tSR.yCoord.F_Mdata.Read(closest_highy,newSR.yCoord.SDPrec);

        // calculate and write interpolated point
        slope :=   (closest_highy - closest_lowy) /  (closest_highx - closest_lowx)  ;
        intercept :=  closest_lowy - (slope* closest_lowx);
        calc_pointy := (slope * current_pointx) +  intercept ;
        newSR.yCoord.F_Mdata.Write(calc_pointy, newSR.yCoord.SDPrec) ;

        // read next current point
        newSR.xCoord.F_Mdata.Read(current_pointx,4) ;
     end ;

  end ;

  newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;


end ;

// this removes values from the yCoord data that are of a cirtain value
// and replaces them with the average of either side points.

procedure TForm2.InterpolateMODISBtnClick(Sender: TObject);
var
     t1, t2 : integer ;
     tSR, newSR : TSpectraRanges ;
     selectedRowNum : integer ;
     first, second, third : array[0..2] of single ;
     valueToReplace : single ;
begin

  SelectStrLst.SortListNumeric ;

  valueToReplace := strtofloat(MODISInterpolValueEditBx.Text) ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin


        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        if tSR.yCoord.numRows = 1 then
        begin
          newSR :=  TSpectraRanges.Create(tSR.xCoord.SDPrec div 4,1,tSR.yCoord.numCols,nil) ;
          tSR.SeekFromBeginning(3,1,0);
          newSR.SeekFromBeginning(3,1,0);
          tSR.Read_XYrYi_Data(1,1,@second,false) ;  // reads first x, yr, yi data
          for t2 := 2 to tSR.yCoord.numCols  do
          begin
             tSR.Read_XYrYi_Data(t2,1,@third,true) ;
             if second[1] = valueToReplace then
             begin
                if (t2 > 2) and (t2 < tSR.yCoord.numCols)  then
                begin
                   if third[1] <> valueToReplace then
                     second[1] := (first[1] + third[1]) / 2
                   else
                     second[1] := first[1] ;

                   newSR.Write_YrYi_Data(t2,1,@second[1],true) ;
                end
                else  // the first data point is to be replace
                if (t2 =2) then
                begin
                  newSR.Write_YrYi_Data(1,1,@third[1],true) ;
                end
                else  // the last data point is to be replaced
                if (t2 = tSR.yCoord.numCols)  then
                begin

                end;
                first[1] := second[1] ;
             end;

             
          end;
          tSR.SeekFromBeginning(3,1,0);
          newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
          newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
          newSR.LineColor := tSR.LineColor ;
          newSR.GLListNumber := tSR.GLListNumber ;
          newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
          newSR.lineType := tSR.lineType ;
          newSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),newSR.lineType) ;
          Form4.StringGrid1.Objects[SG1_COL+1, selectedRowNum] := newSR ;
          Form4.StringGrid1.Cells[SG1_COL+1,selectedRowNum]    :=  '1-'+inttostr(newSR.yCoord.numRows) + ':1-' +  inttostr(newSR.xCoord.numCols) ;
        end;
     end ;
  end ;

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;


// interpolate button on 'interpol.' tab sheet
procedure TForm2.InterpolExecute1Click(Sender: TObject);
var
     t1 : integer ;
     tSR, newSR : TSpectraRanges ;
     selectedRowNum : integer ;
     start, step : single ;
     start_orig, step_orig : single ;
     slope_orig, inter_orig : single ;
begin
  if  LinearInterpol1.Checked = true then
  begin
  SelectStrLst.SortListNumeric ;
  start := strtofloat( InterpolStart1.Text ) ;
  step  := strtofloat( InterpolStep1.Text ) ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
      //  DoStuffWithStringGrid('', mouse_UpCol, 1, 1, true, Form4.StringGrid1.Row-1 ) ;
        newSR :=  TSpectraRanges.Create(tSR.xCoord.SDPrec div 4,1,1,nil) ;
       // if  LinearInterpol1.Checked = true then

        LinearInterpolate(tSR, newSR, start, step) ;

        newSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;
        newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
        newSR.LineColor := tSR.LineColor ;
        newSR.GLListNumber := tSR.GLListNumber ;
        newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
        newSR.lineType := tSR.lineType ;
        tSR.Free ;
        newSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),newSR.lineType) ;
        Form4.StringGrid1.Objects[SG1_COL, selectedRowNum] := newSR ;
        Form4.StringGrid1.Cells[SG1_COL,selectedRowNum]    :=  '1-'+inttostr(newSR.yCoord.numRows) + ':1-' +  inttostr(newSR.xCoord.numCols) ;
     end ;
  end ;
  end;
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;
end;



procedure TForm2.ComboBox3Exit(Sender: TObject);
var
 t1   : integer ;
 tstr : string ;
begin

  t1 := pos(ComboBox3.Text,ComboBox3.Items.CommaText) ;
  if  t1 = 0 then
  begin
    if keyDownV = 0 then
    ComboBox3.Items.CommaText := ComboBox3.Items.CommaText + ',' + ComboBox3.Text
  end  ;

end;



procedure TForm2.ComboBox3DblClick(Sender: TObject);
var
 t1   : integer ;
 tstr : string ;
begin
  t1 := pos(ComboBox3.Text,ComboBox3.Items.CommaText) ;
  if t1 > 0 then
  begin
     tstr := copy(ComboBox3.Items.CommaText,1,t1-1) + copy(ComboBox3.Items.CommaText,t1+length(ComboBox3.Text)+1,length(ComboBox3.Items.CommaText)) ;
     t1 := ComboBox3.Items.IndexOf( ComboBox3.Text ) ;
     ComboBox3.Items.Delete( t1 ) ;
     ComboBox3.Text := '' ;
  end ;
end;


procedure TForm2.ComboBox4Exit(Sender: TObject);
var
 t1   : integer ;
begin
  t1 := pos(ComboBox4.Text,ComboBox4.Items.CommaText) ;
  if  t1 = 0 then
  begin
    ComboBox4.Items.CommaText := ComboBox4.Items.CommaText + ',' + ComboBox4.Text  ;
  end  ;
end;


procedure TForm2.ComboBox4DblClick(Sender: TObject);
var
 t1   : integer ;
 tstr : string ;
begin
  t1 := pos(ComboBox4.Text,ComboBox4.Items.CommaText) ;
  if t1 > 0 then
  begin
     t1 := ComboBox4.Items.IndexOf( ComboBox4.Text ) ;
     ComboBox4.Items.Delete( t1 ) ;
     ComboBox4.Text := '' ;
  end ;
end;



procedure TForm2.ComboBox2DblClick(Sender: TObject);
var
 t1   : integer ;
begin
  t1 := pos(ComboBox2.Text,ComboBox2.Items.CommaText) ;
  if t1 > 0 then
  begin
     t1 := ComboBox2.Items.IndexOf( ComboBox2.Text ) ;
     ComboBox2.Items.Delete( t1 ) ;
     ComboBox2.Text := '' ;
  end ;
end;

procedure TForm2.ComboBox2Exit(Sender: TObject);
var
 t1   : integer ;
begin

  t1 := pos(ComboBox2.Text,ComboBox2.Items.CommaText) ;
  if  t1 = 0 then
  begin
    ComboBox2.Items.Add(ComboBox2.Text) ;
  end  ;

end;

procedure TForm2.Edit30Change(Sender: TObject);
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
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        tSR.xString := Edit30.Text ;
     end ;
  end ;
  Form1.Refresh ;

end;



procedure TForm2.YAxisTypeDDB1Change(Sender: TObject);
var
  t0, t1, t2 : integer ;
  s1     : single ;
  tSR    : TSpectraRanges ;
  tXY_s  : array[0..1] of single ;
  selectedRowNum : integer ;
  originalFormat, newFormat : string ;
begin

  SelectStrLst.SortListNumeric ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
    selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
    if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

      originalFormat := tSR.yString ;
      newFormat := YAxisTypeDDB1.Text ;

      if (newFormat <> originalFormat) and (originalFormat <> '')  then
      begin
        if (originalFormat = 'Absorbance') and  (newFormat = 'Transmission') then  // absorbance to transmittance
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 := Power(10, tXY_s[0]) ;
           s1 := 1 / s1 ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 := Power(10, tXY_s[1]) ;    // this could be dodgy imaginary arithmatic
             s1 := 1 / s1 ;
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Absorbance') and  (newFormat = 'Absorptance') then
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 := Power(10, tXY_s[0]) ;
           s1 := 1 / s1 ;
           s1 := 1 - s1 ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 := Power(10, tXY_s[1]) ;    // this could be dodgy imaginary arithmatic
             s1 := 1 / s1 ;
             s1 := 1 - s1 ;
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Absorbance') and  (newFormat = 'Kubelka-Munk') then  // absorbance to transmittance to K-M
        begin
          for t1 := 1 to tSr.yCoord.numRows do    // for eaxh spectra
          begin
          for t2 := 1 to tSr.yCoord.numCols do    // for each point
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 := Power(10, tXY_s[0]) ;
           s1 := 1 / s1 ;
           s1 := ((1 - s1) * (1 - s1)) / (2*s1) ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 := Power(10, tXY_s[1]) ;
             s1 := 1 / s1 ;
             s1 := ((1 - s1) * (1 - s1)) / (2*s1) ;
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Transmission') and  (newFormat = 'Kubelka-Munk') then  //  transmittance to K-M
        begin
          for t1 := 1 to tSr.yCoord.numRows do    // for eaxh spectra
          begin
          for t2 := 1 to tSr.yCoord.numCols do    // for each point
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 :=  tXY_s[0] ;
           s1 := ((1 - s1) * (1 - s1)) / (2*s1) ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 :=  tXY_s[1] ;
             s1 := ((1 - s1) * (1 - s1)) / (2*s1) ;
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Kubelka-Munk') and  (newFormat = 'Transmission') then  // Kubelka-Munk to Transmittance
        begin
          for t1 := 1 to tSr.yCoord.numRows do    // for eaxh spectra
          begin
          for t2 := 1 to tSr.yCoord.numCols do    // for each point
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           // use quadratic formula to alculate roots of KM equation
           s1 := 2 * (tXY_s[0] + 1) ;
           s1 := ( (s1 - sqrt((s1 * s1)-4)) / 2 ) ;

           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             // use quadratic formula to alculate roots of KM equation
             s1 := 2 * (tXY_s[1] + 1) ;
             s1 := (( s1 - sqrt((s1 * s1)-4)) / 2 ) ;  // this could be dodgy imaginary arithmatic
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Kubelka-Munk') and  (newFormat = 'Absorbance') then  // Kubelka-Munk to Transmitance to Absorbance
        begin
          for t1 := 1 to tSr.yCoord.numRows do    // for eaxh spectra
          begin
          for t2 := 1 to tSr.yCoord.numCols do    // for each point
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           // use quadratic formula to alculate roots of KM equation
           s1 := 2 * (tXY_s[0] + 1) ;
           s1 := ( (s1 - sqrt((s1 * s1)-4)) / 2 ) ;   // this is now transmitance
           s1 := log10(1/s1) ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             // use quadratic formula to alculate roots of KM equation
             s1 := 2 * (tXY_s[1] + 1) ;
             s1 := ( (s1 - sqrt((s1 * s1)-4)) / 2 ) ;  // this could be dodgy imaginary arithmatic
             s1 := log10(1/s1) ;
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Transmission') and  (newFormat = 'Absorptance') then
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           tXY_s[0] := 1 - tXY_s[0] ;
           if tSR.yImaginary <> nil then
           begin
             tXY_s[1] := 1 - tXY_s[1] ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Absorptance') and  (newFormat = 'Transmission') then
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           tXY_s[0] := 1 - tXY_s[0] ;
           if tSR.yImaginary <> nil then
           begin
             tXY_s[1] := 1 - tXY_s[1] ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Transmission') and  (newFormat = 'Absorbance') then  // absorbance to transmittance
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 := log10(1/tXY_s[0]) ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 := log10(1/tXY_s[1]) ;    // this could be dodgy imaginary arithmatic
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end
        else
        if (originalFormat = 'Absorptance') and  (newFormat = 'Absorbance') then  // absorbance to transmittance
        begin
          for t1 := 1 to tSr.yCoord.numRows do
          begin
          for t2 := 1 to tSr.yCoord.numCols do
          begin
           tSR.Read_YrYi_Data(t2,t1,@tXY_s,true) ;
           s1 := log10(1/(1-tXY_s[0])) ;
           tXY_s[0] := s1 ;
           if tSR.yImaginary <> nil then
           begin
             s1 := log10(1/(1-tXY_s[1])) ; ;    // this could be dodgy imaginary arithmatic
             tXY_s[1] := s1 ;
           end ;
           tSR.Write_YrYi_Data(t2,t1,@tXY_s,true) ;
          end ;
          end ;
        end ;

        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ;
        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
        tSR.yString := YAxisTypeDDB1.Text ;
      end   // newFormat <> originalFormat
      else
      if  (originalFormat = '')  then
      begin
         tSR.yString := YAxisTypeDDB1.Text ;
      end ;

    end ; // end if is TSpectraRanges

  end ; // end for each file selected

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;




procedure TForm2.ViewRealCB12Click(Sender: TObject);
var
  GridRow : Integer ;
begin
  GridRow :=  Form4.StringGrid1.Selection.Top ;
  if Form4.StringGrid1.Objects[SG1_COL,GridRow] is  TSpectraRanges then
  begin
    TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,GridRow]).CreateGLList('1-',Form1.Canvas.Handle, RC, GetWhichLineToDisplay(), 1) ;
    TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,GridRow]).SetOpenGLXYRange(GetWhichLineToDisplay()) ; // finds max and min values in xy data
    if not Form4.CheckBox7.Checked then
      Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
    Form1.Refresh ;
  end ;
end;




procedure TForm2.Button1Click(Sender: TObject);     // calculate birefringence (on interpol. tab page)
var
     t1, t2 : integer ;
     tSR : TSpectraRanges ;
     selectedRowNum : integer ;
     start, step : single ;
     trans_loss, coef_b, coef_c, thickness_nm, wavelength : single ;
     s1, s2 : single ;
begin

  SelectStrLst.SortListNumeric ;
  trans_loss := strtofloat( Edit4.Text ) ;
  coef_b  := strtofloat( Edit18.Text ) ;
  coef_c := strtofloat( Edit19.Text ) ;
  thickness_nm  := strtofloat( Edit20.Text ) ;
  wavelength  := strtofloat( Edit21.Text ) ;

  coef_b := coef_b - coef_c ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

        for t2 := 1 to tSR.yCoord.F_Mdata.Size div tSR.yCoord.SDPrec do
        begin
           tSR.yCoord.F_Mdata.Read(s1,4) ;
           tSR.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
           s1 := s1 * trans_loss ;
           s1 := s1 / coef_b ;
           s1 :=    arcsin( sqrt(s1) )  ;  // 2 *
           s1 := s1 / pi  ;   // s1 is now percentage retardance    // / 2 removed ;  * 100  removed
           s1 := s1 * wavelength ;  // s1 now in nm retardance          / 100 removed
           s1 := s1 / thickness_nm ;  // s1 is now birefringence
           tSR.yCoord.F_Mdata.Write(s1,4) ;
        end ;

        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;
  end ;
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;


procedure TForm2.Button6Click(Sender: TObject);  // retardance calculation
var
     t1, t2 : integer ;
     tSR : TSpectraRanges ;
     selectedRowNum : integer ;
     start, step : single ;
     trans_loss, coef_b, coef_c, thickness_nm, wavelength : single ;
     s1, s2 : single ;
begin

  SelectStrLst.SortListNumeric ;
  trans_loss := strtofloat( Edit4.Text ) ;
  coef_b  := strtofloat( Edit18.Text ) ;
  coef_c := strtofloat( Edit19.Text ) ;
  thickness_nm  := strtofloat( Edit20.Text ) ;
  wavelength  := strtofloat( Edit21.Text ) ;

  coef_b := coef_b - coef_c ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
        tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

        for t2 := 1 to tSR.yCoord.F_Mdata.Size div tSR.yCoord.SDPrec do
        begin
           tSR.yCoord.F_Mdata.Read(s1,4) ;
           tSR.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
           s1 := s1 * trans_loss ;
           s1 := s1 / coef_b ;
           s1 := arcsin( sqrt(s1) )  ;  // 2 *
           s1 := s1 / pi  ;   // s1 is now percentage retardance    // / 2 removed ;  * 100  removed
           s1 := s1 * wavelength ;  // s1 now in nm retardance          / 100 removed
           tSR.yCoord.F_Mdata.Write(s1,4) ;
        end ;

        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;
  end ;
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;

procedure TForm2.Button7Click(Sender: TObject);   // simple maths operations  ./ .* .+ .-
var
     t1, t2, t3 : integer ;
     tSR : TSpectraRanges ;
     tMatXorY : TMatrix ;
     selectedRowNum : integer ;
     start, step : single ;
     maths_calc_str, argument_str, origString : string ;
     s1, argument_num : single ;
     if_bool : boolean ;
     if_num_string : string ;
     if_num : single ;
     if_clause_string : string ; // =1 '<' ; =2 '<=' ; =3 '='; =4 '>='; =5 '>' ;
     MKLint1, MKLint2 : integer ;
begin

  SelectStrLst.SortListNumeric ;
  maths_calc_str := Edit22.Text ;
  origString     := maths_calc_str ;  // this is used for multiple spectra
  try
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
           tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;
           if YDataRB1.Checked then
             tMatXorY := tSR.yCoord
           else
             tMatXorY := tSR.xCoord ;

           tMatXorY.F_Mdata.Seek(0,soFromBeginning) ;

           if_bool := false ;
           if pos('if', maths_calc_str) > 0 then
           begin
              if_bool := true ;
              t3 := pos('if', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+2,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if_clause_string := copy(maths_calc_str,1,t3) ;
              if_clause_string := trim(if_clause_string) ;
              maths_calc_str := copy(maths_calc_str,t3+1,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if_num_string := copy(maths_calc_str,1,t3) ;
              if_num := strtofloat( if_num_string ) ;
              maths_calc_str := copy(maths_calc_str,t3+1,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
           end
           else
             if_num := 0 ;

           if pos('./', maths_calc_str) > 0 then
           begin
              t3 := pos('./', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+2,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := copy(maths_calc_str,1,t3) ;
              argument_num := strtofloat( maths_calc_str ) ;
              if (argument_num <> 0.0) then
              begin
              if if_bool = false then
              begin
                 if UseBLASCB1.Checked = true then
                begin
                     MKLint1 := tMatXorY.numRows * tMatXorY.numCols ;
                     MKLint2 := 1 ;
                     argument_num := 1 / argument_num ;
                     sscal( MKLint1,  argument_num,   tMatXorY.F_Mdata.Memory, MKLint2) ;
                end
                else
                begin
                  for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                  begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := s1 / argument_num ;
                   tMatXorY.F_Mdata.Write(s1,4) ;
                  end ;
                end;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                         s1 := s1 / argument_num ;
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                         s1 := s1 /+ argument_num ;
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                         s1 := s1 / argument_num ;
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                         s1 := s1 / argument_num ;
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := s1 / argument_num ;
                   end
                   else
                   s1 := s1 / argument_num ;

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

              end ; // if argument <> 0
           end
           else
           if pos('.*', maths_calc_str) > 0 then
           begin
              t3 := pos('.*', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+2,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := copy(maths_calc_str,1,t3) ;
              argument_num := strtofloat( maths_calc_str ) ;
              if if_bool = false then
              begin

                if UseBLASCB1.Checked = true then
                begin
                     MKLint1 := tMatXorY.numRows * tMatXorY.numCols ;
                     MKLint2 := 1 ;
                     sscal( MKLint1,  argument_num,   tMatXorY.F_Mdata.Memory, MKLint2) ;
                end
                else
                begin
                  for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                  begin
                    tMatXorY.F_Mdata.Read(s1,4) ;
                    tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                    s1 := s1 * argument_num ;
                    tMatXorY.F_Mdata.Write(s1,4) ;
                  end ;
                end;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                         s1 := s1 * argument_num ;
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                         s1 := s1 * argument_num ;
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                         s1 := s1 * argument_num ;
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                         s1 := s1 * argument_num ;
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := s1 * argument_num ;
                   end
                   else
                   s1 := s1 * argument_num ;

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end
           else
           if pos('.+', maths_calc_str) > 0 then
           begin
              t3 := pos('.+', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+2,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := copy(maths_calc_str,1,t3) ;
              argument_num := strtofloat( maths_calc_str ) ;

              if if_bool = false then
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := s1 + argument_num ;
                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                         s1 := s1 + argument_num ;
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                         s1 := s1 + argument_num ;
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                         s1 := s1 + argument_num ;
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                         s1 := s1 + argument_num ;
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := s1 + argument_num ;
                   end
                   else
                   s1 := s1 + argument_num ;

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end
           else
           if pos('.-', maths_calc_str) > 0 then
           begin
              t3 := pos('.-', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+2,length(maths_calc_str)) ;
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := copy(maths_calc_str,1,t3) ;
              argument_num := strtofloat( maths_calc_str ) ;
              if if_bool = false then
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := s1 - argument_num ;
                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                         s1 := s1 - argument_num ;
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                         s1 := s1 - argument_num ;
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                         s1 := s1 - argument_num ;
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                         s1 := s1 - argument_num ;
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := s1 - argument_num ;
                   end
                   else
                   s1 := s1 - argument_num ;

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end
           else
           if pos('log', maths_calc_str) > 0 then
           begin
              t3 := pos('log', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+3,length(maths_calc_str)) ;    // remove the 'log part
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := trim(copy(maths_calc_str,1,t3))
              else
                 maths_calc_str := '10' ;

              if maths_calc_str = 'e' then  maths_calc_str := '2.71828182845904523536' ;
              try
              argument_num := strtofloat( maths_calc_str ) ;
              except on EConvertError do
               Exit ; end ;
              if if_bool = false then
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := logN(argument_num, s1 );
                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                          s1 := logN(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                          s1 := logN(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                          s1 := logN(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                          s1 := logN(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := logN(argument_num, s1 );
                   end
                   else
                    s1 := logN(argument_num, s1 );

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end
           else  // ^
           if pos('pow', maths_calc_str) > 0 then
           begin
              t3 := pos('pow', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+3,length(maths_calc_str)) ;    // remove the 'pow' part
              maths_calc_str := trim(maths_calc_str) ;
              t3 := pos(' ',maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := trim(copy(maths_calc_str,1,t3))
              else
                 maths_calc_str := '10' ;

              if maths_calc_str = 'e' then  maths_calc_str := '2.71828182845904523536' ;

              try
              argument_num := strtofloat( maths_calc_str ) ;
              except on EConvertError do
               Exit ; end ;
              if argument_num < 0 then Exit ;
              if if_bool = false then
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := Power(argument_num, s1 );
                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                          s1 := Power(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                          s1 := Power(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                          s1 := Power(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                          s1 := Power(argument_num, s1 );
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := Power(argument_num, s1 );
                   end
                   else
                    s1 := Power(argument_num, s1 );

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end
           else  // ^
           if pos('^', maths_calc_str) > 0 then
           begin
              t3 := pos('^', maths_calc_str) ;
              maths_calc_str := copy(maths_calc_str,t3+1,length(maths_calc_str)) ;    // remove the '^' part
              maths_calc_str := trim(maths_calc_str) ;
              t3 := length(maths_calc_str) ;
              if t3 > 0 then
                 maths_calc_str := trim(copy(maths_calc_str,1,t3))
              else
                 maths_calc_str := '1' ;

              try
              argument_num := strtofloat( maths_calc_str ) ;
              except on EConvertError do
               Exit ; end ;

              if ((tSR.yLow < 0) and (abs(argument_num) < 1)) and ( (if_clause_string = '') or (if_clause_string = '<') or (if_clause_string = '<=') or (if_num < 0))  then
              begin
                  messagedlg('Fractional exponents require positive arguments. Calculation stoped. Selected file on line: '+inttostr(t1+1),mtInformation,[mbOk],0) ;
                  Exit ;
              end ;

              if if_bool = false then
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   s1 := Power(s1, argument_num );
                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end
              else
              begin
                for t2 := 1 to tMatXorY.F_Mdata.Size div tMatXorY.SDPrec do
                begin
                   tMatXorY.F_Mdata.Read(s1,4) ;
                   tMatXorY.F_Mdata.Seek(-4,soFromCurrent) ;
                   if if_clause_string = '<' then
                   begin
                      if s1 < if_num then
                          s1 := Power(s1, argument_num );
                   end
                   else
                   if if_clause_string = '<=' then
                   begin
                      if s1 <= if_num then
                          s1 := Power(s1, argument_num );
                   end
                   else
                   if if_clause_string = '=' then
                   begin
                      if s1 = if_num then
                          s1 := Power(s1, argument_num );
                   end
                   else
                   if if_clause_string = '>=' then
                   begin
                      if s1 >= if_num then
                          s1 := Power(s1, argument_num );
                   end
                   else
                   if if_clause_string = '>' then
                   begin
                      if s1 > if_num then
                         s1 := Power(s1, argument_num );
                   end
                   else
                    s1 := Power(s1, argument_num );

                   tMatXorY.F_Mdata.Write(s1,4) ;
                end ;
              end ;

           end  ;
           tMatXorY.F_Mdata.Seek(0,soFromBeginning) ;

        maths_calc_str := origString  ;
        tSR.SetOpenGLXYRange(  Form2.GetWhichLineToDisplay() ) ;
        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;
  end ;
  except
  on EOverflow  do
     messagedlg('A floating point overflow error was encountered. Your data may be corrupted. selected file on line: '+inttostr(t1+1),mtInformation,[mbOk],0) ;
  on EUnderflow  do
     messagedlg('A floating point underflow error was encountered. Your data may be corrupted. selected file on line: '+inttostr(t1+1),mtInformation,[mbOk],0) ;
  on EZeroDivide  do
     messagedlg('You are trying to divide by zero. selected file on line: '+inttostr(t1+1),mtInformation,[mbOk],0) ;
  end ;

  if not form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;
end;


// invert Y axis
procedure TForm2.CheckBox5Click(Sender: TObject);
Var
 TempFloat2 : glFloat ;
begin

  TempFloat2 := StrToFloat(Edit8.Text) ;
  Edit8.Text := Edit9.Text ;
  Edit9.Text := FloatToStr(TempFloat2) ;
  OrthoVarXMax := OrthoVarXMin + (30*WidthPerPix1) ;// StrToFloat(Edit7.Text) ;
  OrthoVarXMin := StrToFloat(Edit9.Text) + (30*WidthPerPix1) ;

  Form1.FormResize(sender) ;

end;

procedure TForm2.CalBarPosXEB1Change(Sender: TObject);
begin
  if StrtoFloat(Form2.CalBarPosXEB1.Text) > 1 then
    Form2.CalBarPosXEB1.Text := '1.0'
  else
  if StrtoFloat(Form2.CalBarPosXEB1.Text) < 0 then
    Form2.CalBarPosXEB1.Text := '0.0'

end;

procedure TForm2.CalBarPosYEB1Change(Sender: TObject);
begin
  if StrtoFloat(Form2.CalBarPosYEB1.Text) > 1 then
    Form2.CalBarPosYEB1.Text := '1.0'
  else
  if StrtoFloat(Form2.CalBarPosYEB1.Text) < 0 then
    Form2.CalBarPosYEB1.Text := '0.0'
end;

procedure TForm2.CalBarMoveCB1Click(Sender: TObject);
begin
    if CalBarResizeCB1.Checked then CalBarResizeCB1.Checked := false ;
end;

procedure TForm2.CalBarResizeCB1Click(Sender: TObject);
begin
  if CalBarMoveCB1.Checked then CalBarMoveCB1.Checked := false ;
end;

procedure TForm2.SubfirstSpectFromRestBClick(Sender: TObject);
var
     t1, t2, t3 : integer ;
     tSR : TSpectraRanges ;
     selectedRowNum : integer ;
     start, step : single ;
     trans_loss, coef_b, coef_c, thickness_nm, wavelength : single ;
     s1, s2 : single ;
     d1, d2 : double ;
     p1 : pointer ;
begin

  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
     selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
     if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
     begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) ;

        if tSR.yImaginary <> nil then
          tSR.yCoord.MakeComplex(tSR.yImaginary) ;
        tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

        GetMem(p1,tSR.yCoord.SDPrec * tSR.yCoord.complexMat) ;

        // get first spectra
        tSR.yCoord.Fcols.SetSize(tSR.yCoord.numCols * tSR.yCoord.SDPrec * tSR.yCoord.complexMat) ;
        tSR.yCoord.Fcols.Seek(0,soFromBeginning) ;
        for t2 := 1 to tSR.yCoord.numCols  do
        begin
           tSR.yCoord.F_Mdata.Read(p1^, tSR.yCoord.SDPrec * tSR.yCoord.complexMat ) ;
           tSR.yCoord.Fcols.Write( p1^, tSR.yCoord.SDPrec * tSR.yCoord.complexMat ) ;
        end ;
        tSR.yCoord.Fcols.Seek(0,soFromBeginning) ;
        tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;

        if  tSR.yCoord.SDPrec = 4 then
        begin
          for t2 := 1 to tSR.yCoord.numRows do
          begin
            for t3 := 1 to tSR.yCoord.numCols * tSR.yCoord.complexMat do
            begin
               tSR.yCoord.Fcols.Read(s1,4) ;
               tSR.yCoord.F_Mdata.Read(s2,4) ;
               s2 := s2 - s1 ;
               tSR.yCoord.F_Mdata.Seek(-4,soFromCurrent) ;
               tSR.yCoord.F_Mdata.Write(s2,4) ;
            end ;
            tSR.yCoord.Fcols.Seek(0,soFromBeginning) ;
          end ;
        end
        else
        if  tSR.yCoord.SDPrec = 8 then
        begin
          for t2 := 1 to tSR.yCoord.numRows do
          begin
            for t3 := 1 to tSR.yCoord.numCols * tSR.yCoord.complexMat do
            begin
               tSR.yCoord.Fcols.Read(d1,8) ;
               tSR.yCoord.F_Mdata.Read(d2,8) ;
               d2 := d2 - d1 ;
               tSR.yCoord.F_Mdata.Seek(-8,soFromCurrent) ;
               tSR.yCoord.F_Mdata.Write(d2,8) ;
            end ;
            tSR.yCoord.Fcols.Seek(0,soFromBeginning) ;
          end ;
        end  ;
        FreeMem(p1,tSR.yCoord.SDPrec * tSR.yCoord.complexMat) ;

        if tSR.yCoord.complexMat = 2 then
        begin
          tSR.yCoord.MakeUnComplex(tSR.yImaginary) ;
          tSR.yImaginary.F_Mdata.Seek(0,soFromBeginning) ;
        end ;
        tSR.yCoord.F_Mdata.Seek(0,soFromBeginning) ;



        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
        tSR.SetOpenGLXYRange( Form2.GetWhichLineToDisplay() ) ;
     end ;
  end ;

  if not form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;

procedure TForm2.RemoveImaginaryMatBtnClick(Sender: TObject);
var
     t1, t2 : integer ;
     s1 : single ;
     d1 : double ;
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
        if tSR.yImaginary <> nil then
        begin
          tSR.yImaginary.F_Mdata.Seek(0,soFromBeginning) ;
          if tSR.yImaginary.SDPrec = 4 then
          begin
            for t2 := 0 to (tSR.yImaginary.numRows * tSR.yImaginary.numCols) - 1 do
            begin
               tSR.yImaginary.F_Mdata.Read(s1,tSR.yImaginary.SDPrec)   ;
               s1 := s1 + -1 ;
               tSR.yImaginary.F_Mdata.Seek(-tSR.yImaginary.SDPrec,soFromCurrent) ;
               tSR.yImaginary.F_Mdata.Write(s1,tSR.yImaginary.SDPrec) ;
            end;
          end
          else
          if tSR.yImaginary.SDPrec = 8 then
          begin
            for t2 := 0 to (tSR.yImaginary.numRows * tSR.yImaginary.numCols) - 1 do
            begin
               tSR.yImaginary.F_Mdata.Read(d1,tSR.yImaginary.SDPrec)   ;
               d1 := d1 + -1 ;
               tSR.yImaginary.F_Mdata.Seek(-tSR.yImaginary.SDPrec,soFromCurrent) ;
               tSR.yImaginary.F_Mdata.Write(d1,tSR.yImaginary.SDPrec) ;
            end;
          end  ;
            
        end ;
        tSR.CreateGLList('1-',Form1.Canvas.Handle,RC,  Form2.GetWhichLineToDisplay(),tSR.lineType) ;
     end ;
  end ;
  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ;
  Form1.Refresh ;

end;


 // sets xCoord  data to new values as indicated in Edit29(=start) and Edit16(=step)
procedure TForm2.RescaleXBtnClick(Sender: TObject);
var
  t1, t2 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  startVal, incXval : single ;
  startVal_double : double ;
begin
//  procedure FillXCoordData(startVal, increment: single; direction : integer) ;
  SelectStrLst.SortListNumeric ;
  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin

   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;
      startVal := strtofloat(Edit29.Text) ;
      incXval  := strtofloat(Edit16.Text) ;
      startVal_double := startVal ;
      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
        tSR.image2DSpecR.xCoord.F_MData.Seek(0,soFromBeginning) ;
        if tSR.image2DSpecR.xCoord.SDPrec = 4 then
        begin
        for t2 := 0 to tSR.image2DSpecR.xCoord.numCols - 1 do
        begin
           tSR.image2DSpecR.xCoord.F_MData.Write(startVal,tSR.image2DSpecR.xCoord.SDPrec) ;
           startVal := startVal +  incXval ;
        end
        end
        else
        if tSR.image2DSpecR.xCoord.SDPrec = 8 then
        begin
        for t2 := 0 to tSR.image2DSpecR.xCoord.numCols - 1 do
        begin
           tSR.image2DSpecR.xCoord.F_MData.Write(startVal_double,tSR.image2DSpecR.xCoord.SDPrec) ;
           startVal_double := startVal_double +  incXval ;
        end
        end;
        tSR.image2DSpecR.xCoord.F_MData.Seek(0,soFromBeginning) ;
        tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
        tSR.xCoord.F_MData.Seek(0,soFromBeginning) ;
        if tSR.xCoord.SDPrec = 4 then
        begin
        for t2 := 0 to tSR.xCoord.numCols - 1 do
        begin
           tSR.xCoord.F_MData.Write(startVal,tSR.xCoord.SDPrec) ;
           startVal := startVal +  incXval ;
        end
        end
        else
        if tSR.xCoord.SDPrec = 8 then
        begin
        for t2 := 0 to tSR.xCoord.numCols - 1 do
        begin
           tSR.xCoord.F_MData.Write(startVal_double,tSR.xCoord.SDPrec) ;
           startVal_double := startVal_double +  incXval ;
        end
        end;
        tSR.xCoord.F_MData.Seek(0,soFromBeginning) ;
        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;
   end ;

  end ;  // for each file selected

  form1.Refresh ;

end;



procedure TForm2.BaselineCorrectBtnClick(Sender: TObject);
Var
  t0, t1, NearStartPosInt, NearEndPosInt, currentSpecNum  : LongInt ;
  s1, s2 : single ;
  startX, startY, finX, finY, spectraSlope, spectraConst, subY  : single ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  swapped : boolean ;
  //XYData : TGLRangeArray ;
begin

  If (Edit24.Text = '') or (Edit31.Text = '') or (Edit38.Text = '') or (Edit39.Text = '') Then
  begin
    messagedlg('Please select points on graph for baseline correction',mtInformation,[mbOk],0) ;
    Exit ;  // exit out of subroutine
  end ;

  SelectStrLst.SortListNumeric ;
  currentSpecNum := 0 ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
  selectedRowNum := StrToInt(SelectStrLst.Strings[t0]) ;
  If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,selectedRowNum] is  TSpectraRanges  then
  begin

    tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,selectedRowNum]) ;

    If (StrToFloat(Edit24.Text) < tSR.xLow) or (StrToFloat(Edit38.Text) > tSR.xHigh) Then
    begin
      messagedlg('Error: Baseline points are beyond the data',mtInformation,[mbOk],0) ;
      Exit ;  // exit out of subroutine
    end ;

    s1 := 0.00000 ;

    NearStartPosInt := 0 ;
    tSR.SeekFromBeginning(3,1,0) ;
    startX := StrToFloat(Edit24.Text) ; // 'baseline/integration' tab page text box
    finX := StrToFloat(Edit38.Text) ; // 'baseline/integration' tab page text box

    // find start and end X data value
    tSR.xCoord.F_MData.Read(s1,4) ;
    if s1 < startX then
    begin
      While s1 <  startX do
      begin
        NearStartPosInt := NearStartPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;

      NearEndPosInt := NearStartPosInt ;
      startX := s1 ;
      Edit24.Text :=  FloatToStrf(s1,ffGeneral,6,3)  ;

      While s1 <  finX do
      begin
        NearEndPosInt := NearEndPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      finX := s1 ;
      Edit38.Text := FloatToStrf(s1,ffGeneral,6,3) ;
    end
    else // s1 > startX
    begin
      NearEndPosInt := 1 ;
      While s1 >  finX do
      begin
        NearEndPosInt := NearEndPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      NearStartPosInt := NearEndPosInt ;
      finX := s1 ;
      Edit38.Text :=  FloatToStrf(s1,ffGeneral,6,3)  ;
      While s1 >  startX do
      begin
        NearStartPosInt := NearStartPosInt +1 ;
        tSR.xCoord.F_MData.Read(s1,4) ;
      end ;
      startX := s1 ;
      Edit24.Text := FloatToStrf(s1,ffGeneral,6,3) ;
    end ;

    // get Y value for line
    if  not Form2.SnapToPointsCB.Checked then
    begin
       startY := StrToFloat(Edit31.Text) ;
       finY := StrToFloat(Edit39.Text) ;
    end ;

    If  NearEndPosInt = NearStartPosInt Then
    begin
       messagedlg('Area selected is between two data points ' +#13+'and can not be calculated with algorithm available',mtInformation,[mbOk],0) ;
       exit ;
    end ;

    for  currentSpecNum := 1 to tSR.yCoord.numRows do  // for each spectrum in single TSpectraRanges object
    begin

      if  Form2.SnapToPointsCB.Checked then
      begin
        tSR.SeekFromBeginning(3,currentSpecNum,(((NearStartPosInt-1)* tSR.xCoord.SDPrec))) ;
        tSR.yCoord.F_MData.Read(s1,4) ;
        tSR.SeekFromBeginning(3,currentSpecNum,(((NearEndPosInt-1)* tSR.xCoord.SDPrec))) ;
        tSR.yCoord.F_MData.Read(s2,4) ;
        startY := s1 ;
        finY   := s2 ;
      end ;

      spectraSlope :=  ( startY - finY ) / ( startX - finX ) ;
      spectraConst := startY - (spectraSlope*startX) ;  // const = y - mx

      // this is the subtraction bit
      // a/ one baseline for all points
      if BetweenPts.Checked = false then
      begin
        tSR.SeekFromBeginning(3,currentSpecNum,0) ;
        for t1 := 1 to tSR.yCoord.numCols do
        begin
         tSR.xCoord.F_MData.Read(s2,4) ;
         subY := (spectraSlope * s2) +  spectraConst ;

         tSR.yCoord.F_MData.Read(s1,4) ;
         s1 := s1 - subY ;
         tSR.yCoord.F_MData.Seek(-4,soFromCurrent) ;
         tSR.yCoord.F_MData.Write(s1,4) ;
        end ;
      end
      else  // b/ baseline used between points only
      if BetweenPts.Checked = true then
      begin
        swapped := false ;
        if  NearStartPosInt > NearEndPosInt then
        begin
           t1 := NearStartPosInt ;
           NearStartPosInt :=  NearEndPosInt ;
           NearEndPosInt := t1 ;
           swapped := true ;
        end ;
        tSR.SeekFromBeginning(3,currentSpecNum,(NearStartPosInt-1)* tSR.xCoord.SDPrec) ;      //
        for t1 := 1 to abs((NearStartPosInt-NearEndPosInt)) do
        begin

         tSR.xCoord.F_MData.Read(s2,4) ;
         subY := (spectraSlope * s2) +  spectraConst ;

         tSR.yCoord.F_MData.Read(s1,4) ;
         s1 := s1 - subY ;
         tSR.yCoord.F_MData.Seek(-4,soFromCurrent) ;
         tSR.yCoord.F_MData.Write(s1,4) ;
        end ;

        if  swapped = true then
        begin
           t1 := NearStartPosInt ;
           NearStartPosInt :=  NearEndPosInt ;
           NearEndPosInt := t1 ;
           swapped := false ;
        end ;
      end

    end  ;  // for  currentSpecNum := 0 to tSR.yCoord.numRows do

    tSR.CreateGLList('1-', Form1.Canvas.Handle, RC, GetWhichLineToDisplay(), tSR.lineType ) ;
    tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data

  end ;   // for each file selected

  if not Form4.CheckBox7.Checked then
    Form1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
  Form1.Refresh ;

end;
end ;




procedure TForm2.PeakHeightCBClick(Sender: TObject);
begin
  if PeakHeightCB.Checked then      // turn off FFT integration
      CheckBox15.Checked := false ;

end;

procedure TForm2.CheckBox15Click(Sender: TObject);
begin
  if CheckBox15.Checked then       // turn off peak height integration
      PeakHeightCB.Checked := false ;
end;


procedure TForm2.imageSliceValEBKeyPress(Sender: TObject; var Key: Char);
var
  s1, s2, tmax, tmin : single ;
  t1 : integer ;
  SpectObj : TSpectraRanges ;
  reverse : boolean ;
begin
  // 13 = enter key
  if (integer(Key) = 13)  then  // validate and shift to closest point in specra range
  begin

    if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges then
    begin
      SpectObj := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]) ;

      if SpectObj.frequencyImage then
      begin
      try
        s1 :=   strtofloat(Form2.imageSliceValEB.Text) ;

        SpectObj.SeekFromBeginning(3,1,0) ;
        SpectObj.xCoord.F_Mdata.Read(tmin,SpectObj.xCoord.SDPrec) ;
        SpectObj.SeekFromBeginning(3,1,(SpectObj.xCoord.numCols*SpectObj.xCoord.SDPrec)-SpectObj.xCoord.SDPrec) ;
        SpectObj.xCoord.F_Mdata.Read(tmax,SpectObj.xCoord.SDPrec) ;


        SpectObj.SeekFromBeginning(3,1,0) ;
        reverse := false ;
        if tmin > tmax then
        begin
          s2 := tmin ;
          tmin := tmax ;
          tmax := s2 ;
          reverse := true ;
        end ;

        if (s1 > tmin) and (s1 < tmax) then
        begin
          t1 := 0 ;

          if not reverse then
          begin
            while s2 < s1 do
            begin
              SpectObj.xCoord.F_Mdata.Read(s2,SpectObj.xCoord.SDPrec) ;
              inc(t1) ;
            end ;
          end
          else  // x data goes from big vals to small vals
          begin
            while s2 > s1 do
            begin
              SpectObj.xCoord.F_Mdata.Read(s2,SpectObj.xCoord.SDPrec) ;
              inc(t1) ;
            end ;
          end ;
          SpectObj.currentSlice := t1 ;
          Form2.FrequencySlider1.Position := t1 ;
          Form2.imageSliceValEB.Text :=  floattostrf(s2,ffGeneral,7,5) ;
        end
        else
        if (s1 < tmin) then
        begin
          if not reverse then
            SpectObj.currentSlice := 1
          else
          begin
            SpectObj.currentSlice := SpectObj.xCoord.numCols ;
            SpectObj.SeekFromBeginning(3,1,(SpectObj.xCoord.numCols * SpectObj.xCoord.SDPrec)-SpectObj.xCoord.SDPrec) ;
          end ;
          SpectObj.xCoord.F_Mdata.Read(s2,SpectObj.xCoord.SDPrec);
          Form2.imageSliceValEB.Text :=  floattostrf(s2,ffGeneral,8,6) ;
        end
        else
        if (s1 > tmax) then
        begin
          if reverse then
            SpectObj.currentSlice := 1
          else
          begin
            SpectObj.currentSlice := SpectObj.xCoord.numCols ;
            SpectObj.SeekFromBeginning(3,1,(SpectObj.xCoord.numCols * SpectObj.xCoord.SDPrec)-SpectObj.xCoord.SDPrec) ;
          end ;

          SpectObj.xCoord.F_Mdata.Read(s2,SpectObj.xCoord.SDPrec) ;
          Form2.imageSliceValEB.Text :=  floattostrf(s2,ffGeneral,8,6) ;
        end

      except on EConvertError do
      begin
        if trim(Form2.imageSliceValEB.Text) <> '' then
        begin
          SpectObj.xCoord.F_Mdata.Seek((SpectObj.currentSlice*SpectObj.xCoord.SDPrec)-SpectObj.xCoord.SDPrec,soFromBeginning) ;
          SpectObj.xCoord.F_Mdata.Read(s1,SpectObj.xCoord.SDPrec) ;
          Form2.imageSliceValEB.Text :=  floattostrf(s1,ffGeneral,7,5) ;
        end ;
      end ;
      end ;
    end ;
    FrequencySlider1Change(sender) ;

    end ; //if SpectObj.frequencyImage then


  end ;

end;

procedure TForm2.CaptureImageBTNClick(Sender: TObject);
Var
  Source1, Dest1 : TRect ;
  filename : string ;
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

  filename := 'image_' + Form2.imageSliceValEB.Text + '.bmp'  ;

  Form1.Image1.Picture.SaveToFile(filename)  ;

  Form1.Image1.Visible := False ;
  Form1.refresh ;

end;

procedure TForm2.ImageMaxColorCBClick(Sender: TObject);
var
  tSR : TSpectraRanges ;
begin

   if  (Form4.StringGrid1.Objects[SG1_COL, SG1_ROW]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]) ;

      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
        tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end ;
   end ;
   form1.Refresh ;

end;

procedure TForm2.ImageMinColorCBClick(Sender: TObject);
var
  tSR : TSpectraRanges ;
begin

   if  (Form4.StringGrid1.Objects[SG1_COL, SG1_ROW]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,SG1_ROW]) ;

      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
        tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end ;
   end ;
   form1.Refresh ;


end;

procedure TForm2.ImageMaxColorValEBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s1 : single ;

begin
  if (integer(Key) = 13)  then  // validate and shift to closest point in specra range
  begin
  try
    s1 :=  strtofloat(Form2.ImageMaxColorValEB.Text) ;

  except on EConvertError do
  begin
    if trim(Form2.ImageMaxColorValEB.Text) <> '' then
    begin
      Form2.ImageMaxColorValEB.Text :=  '1.0' ;
    end ;
  end ;
  end ;
  end

end;


procedure TForm2.ImageMaxColorValEBExit(Sender: TObject);
var
  s1 : single ;

begin
  try
    s1 :=  strtofloat(Form2.ImageMaxColorValEB.Text) ;

  except on EConvertError do
  begin
    if trim(Form2.ImageMaxColorValEB.Text) <> '' then
    begin
      Form2.ImageMaxColorValEB.Text :=  '1.0' ;
    end ;
  end ;
  end ;

end;

procedure TForm2.ImageMinColorValEBKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  s1 : single ;

begin
  if (integer(Key) = 13)  then  // validate and shift to closest point in specra range
  begin
  try
    s1 :=  strtofloat(Form2.ImageMinColorValEB.Text) ;

  except on EConvertError do
  begin
    if trim(Form2.ImageMinColorValEB.Text) <> '' then
    begin
      Form2.ImageMinColorValEB.Text :=  '0.0' ;
    end ;
  end ;
  end ;
  end

end;

procedure TForm2.ImageMinColorValEBExit(Sender: TObject);
var
  s1 : single ;

begin
  try
    s1 :=  strtofloat(Form2.ImageMinColorValEB.Text) ;

  except on EConvertError do
  begin
    if trim(Form2.ImageMinColorValEB.Text) <> '' then
    begin
      Form2.ImageMinColorValEB.Text :=  '0.0' ;
    end ;
  end ;
  end ;

end;


procedure TForm2.CalBarHideCB1Click(Sender: TObject);
begin
   form1.Refresh ;
end;


procedure TForm2.LineTypeComboBoxChange(Sender: TObject);
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

      if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
      begin
        tSR.image2DSpecR.lineType :=  LineTypeComboBox.ItemIndex+1 ;
        tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end
      else
      begin
        tSR.lineType :=  LineTypeComboBox.ItemIndex+1 ;
        tSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType) ;
      end ;
   end ;

  end ;  // for each file selected

  form1.Refresh ;


end;



procedure TForm2.TrackBar1Change(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  changedColor : boolean ;
  P : PByteArray;  // pointer to bitmap (PalletColorsBitMap) data holding pallet of colors for textures of 2D images
  sR, fR, sB, fB, sG, fG : single ;
begin
  changedColor := false ;
  SelectStrLst.SortListNumeric ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;
   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      if changedColor = false then
      begin
        ActivateRenderingContext(Form1.Canvas.Handle,RC) ;
        if TrackBar1.Position = TrackBar3.Position then TrackBar1.Position := TrackBar1.Position -1 ;
        if TrackBar4.Position = TrackBar5.Position then TrackBar4.Position := TrackBar4.Position -1 ;

        P := PalletColorsBitMap.ScanLine[0]; // this is pointer to first line of bitmap used to display current LUT
        sR :=  (511 * strtofloat(Edit43.Text)) ;
        fR :=  (511 * strtofloat(Edit44.Text)) ;
        sG :=  (511 * strtofloat(Edit45.Text)) ;
        fG :=  (511 * strtofloat(Edit46.Text)) ;
        sB :=  (511 * strtofloat(Edit47.Text)) ;
        fB :=  (511 * strtofloat(Edit48.Text)) ;
        tSR.SetUpGLPixelTransfer(P,sR, TrackBar1.Position,TrackBar3.Position,fR,sG, TrackBar4.Position,TrackBar5.Position,fG, sB, TrackBar6.Position,TrackBar7.Position, fB) ;
        Image1.Picture.Bitmap :=   PalletColorsBitMap ;
        Image1.Repaint ;
        changedColor := true ;
        wglMakeCurrent(0,0);
      end ;

      if ((tSR.frequencyImage = true) or (tSR.nativeImage = true)) {and ((MouseDown_DrawLine = false) and (MouseDownBool = false))} then
      begin
        tSR.image2DSpecR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
        tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.image2DSpecR.lineType) ;
      end ;
   end ;

  end ;
  form1.Refresh ;

end;

procedure TForm2.FormDestroy(Sender: TObject);
begin
  PalletColorsBitMap.FreeImage ; // may not be needed???
end;

procedure TForm2.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Application.Terminate;   // terminate if escape kill pressed
  if (Key = 'a') or (Key = 'A') then
     Form2.DendroAddSB.Down :=  not Form2.DendroAddSB.Down ;
  if (Key = 's') or (Key = 'S') then
     Form2.DendroSubtractSB.Down :=  not Form2.DendroSubtractSB.Down ;

end;

procedure TForm2.ImageColorPresetCBChange(Sender: TObject);
var
  tSR : TSpectraRanges ;
begin

   if ImageColorPresetCB.ItemIndex+1 = 1 then // greyscale
   begin
      Edit43.Text := '0.0' ;
      Edit44.Text := '1.0' ;
      Edit45.Text := '0.0' ;
      Edit46.Text := '1.0' ;
      Edit47.Text := '0.0' ;
      Edit48.Text := '1.0' ;

      TrackBar1.Position := 0 ;
      TrackBar3.Position := 512 ;
      TrackBar4.Position := 0 ;
      TrackBar5.Position := 512 ;
      TrackBar6.Position := 0 ;
      TrackBar7.Position := 512 ;

   end
   else
   if ImageColorPresetCB.ItemIndex+1 = 2 then  // flame red
   begin
      Edit43.Text := '0.0' ;
      Edit44.Text := '1.0' ;
      Edit45.Text := '0.0' ;
      Edit46.Text := '1.0' ;
      Edit47.Text := '0.0' ;
      Edit48.Text := '1.0' ;

      TrackBar1.Position := 0 ;
      TrackBar3.Position := 100 ;
      TrackBar4.Position := 100 ;
      TrackBar5.Position := 400 ;
      TrackBar6.Position := 400 ;
      TrackBar7.Position := 512 ;
   end ;
   TrackBar1Change(Sender) ;
//   form1.Refresh ;


end;



procedure TForm2.Edit43MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(TEdit(Sender).Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.001*(-Y)) ;
        If TempFloat > 1.0 Then TempFloat := 1.0 ;
        If TempFloat < 0.0 Then TempFloat := 0.0 ;
        TEdit(Sender).Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm2.Edit43MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  tSR : TSpectraRanges ;
  t0, selectedRowNum : integer ;
  tLC : TGLLineColor ;
begin
   MouseDownMat := False ;

   MouseArrayX[0]:= 0;
   MouseArrayY[0] := 0;
   MouseArrayX[1] := 0;
   MouseArrayY[1] := 0;

   TrackBar1Change(Sender) ;

//  Form1.Refresh ;

end;

procedure TForm2.ImageNumberTB1Click(Sender: TObject);
var
  t1 : integer ;
  tStr1 : string ;
begin
  t1 := strtoint(ImageNumberTB1.Text) ;
  t1 := t1 + 1 ;
  ImageNumberTB1.Text := inttostr(t1) ;

end;

procedure TForm2.CropXRangeBtnClick(Sender: TObject);
var
  t0, t1, t2, currentSpecNum : integer ;
  s1 : single ;
  d1 : double ;
  tSR, newSR : TSpectraRanges ;
  xVarRange, XsampleRange : string ;
  bB : TBatchBasics ;  // functions like : LeftSideOfEqual() etc
begin
try
  bB :=  TBatchBasics.Create ;
  If (CropMinTB.Text = '') or (CropMaxTB.Text = '') Then
  begin
    messagedlg('Please enter range of data to crop',mtInformation,[mbOk],0) ;
    Exit ;  // exit out of subroutine
  end ;

  if StrToFloat(CropMinTB.Text) >  StrToFloat(CropMaxTB.Text) then   // get order from low to high value
  begin
     xVarRange := CropMaxTB.Text ;
     CropMaxTB.Text :=  CropMinTB.Text ;
     CropMinTB.Text :=  xVarRange ;
  end ;
  xVarRange := '' ;

  // concatenate strings
  xVarRange := CropMinTB.Text +'-'+ CropMaxTB.Text ;

  //add (false text) units if range is in x units
  if  xUnitsCB.Checked = true then
     xVarRange := xVarRange + ' cm-1' ;


  SelectStrLst.SortListNumeric ;
  currentSpecNum := 0 ;
  for t0 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
    currentSpecNum := StrToInt(SelectStrLst.Strings[t0]) ;
    If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,currentSpecNum] is  TSpectraRanges  then
    begin

      tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,currentSpecNum]) ;
      newSR := TSpectraRanges.Create(tSR.yCoord.SDPrec div 4, 1,1, nil) ;

      If ((StrToFloat(CropMinTB.Text) < tSR.xLow) or (StrToFloat(CropMaxTB.Text) > tSR.xHigh)) and (xUnitsCB.Checked = true) Then
      begin
        messagedlg('Error: Baseline points are beyond the data',mtInformation,[mbOk],0) ;
        Exit ;  // exit out of subroutine
      end
      else
      if ((StrToFloat(CropMinTB.Text) < 1) or (StrToFloat(CropMaxTB.Text) > tSR.xCoord.numCols )) and (xUnitsCB.Checked = false) then
      begin
        messagedlg('Error: Baseline points are beyond the data',mtInformation,[mbOk],0) ;
        Exit ;  // exit out of subroutine
      end  ;

      newSR.CopySpectraObject(tSR) ;

     if  xUnitsCB.Checked = true then
     begin
//     do not need to trim off cm-1 string part here
//     xVarRange := trim(copy(xVarRange,1,pos(' ',xVarRange))) ;
     xVarRange :=  bB.ConvertValueStringToPosString(xVarRange, tSR.xCoord) ;
     if  xVarRange = '' then
     begin
        MessageDlg('Crop Data Error...'#13'x var range values not appropriate: '+xVarRange,mtError, [mbOK], 0)  ;
        exit ;
     end ;
    end ;

     // *****************   Get the y data of TSpectraRanges object *****************
    XsampleRange := '1-' + inttostr(tSR.yCoord.numRows) ;
    // *****************  This actually retrieves the data  ********************
    newSR.yCoord.FetchDataFromTMatrix( XsampleRange, xVarRange , tSR.yCoord ) ;
    if tSR.yImaginary <> nil then
    begin
      newSR.yImaginary := TMatrix.Create(newSR.yCoord.SDPrec div 4) ;
      newSR.yImaginary.FetchDataFromTMatrix( XsampleRange, xVarRange , tSR.yImaginary ) ;
    end ;

    newSR.xString := tSR.xString ;
    newSR.yString := tSR.yString ;
    newSR.xCoord.numCols :=  newSR.yCoord.numCols ;
    newSR.xCoord.numRows := 1 ;
    newSR.xCoord.Filename :=  tSR.xCoord.Filename ;
    newSR.xCoord.F_Mdata.SetSize(newSR.xCoord.numCols * 1 * newSR.xCoord.SDPrec) ;
    newSR.xCoord.F_Mdata.Seek(0,soFromBeginning) ;
    // COPY X DATA VALUES FROM INPUT TSPECTRARANGES TO NEW TSPECTRARANGE in new row
    t2 := newSR.xCoord.GetTotalRowsColsFromString(xVarRange, newSR.xCoord.Fcols) ;
    newSR.xCoord.Fcols.Seek(0,soFromBeginning) ;
    for t1 := 1 to newSR.xCoord.numCols do
    begin
       newSR.xCoord.Fcols.Read(t2,4) ;
       tSR.xCoord.F_Mdata.Seek(t2*tSR.xCoord.SDPrec,soFromBeginning) ;
       if tSR.xCoord.SDPrec = 4 then
       begin
        tSR.xCoord.F_Mdata.Read(s1, 4) ;
        newSR.xCoord.F_Mdata.Write(s1,4) ;
       end
       else
       if tSR.xCoord.SDPrec = 8 then
       begin
        tSR.xCoord.F_Mdata.Read(d1, 8) ;
        newSR.xCoord.F_Mdata.Write(d1,8) ;
       end ;
    end ;


 //   newSR.CopySpectraObject( tSR ) ;
    newSR.GLListNumber :=  tSR.GLListNumber ;
    newSR.LineColor := tSR.LineColor ;

    tSR.Free ;
    Form4.StringGrid1.Objects[Form4.StringGrid1.Col,currentSpecNum] := nil ;
    Form4.StringGrid1.Objects[Form4.StringGrid1.Col,currentSpecNum] := newSR ;
    newSR.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
    newSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), newSR.lineType) ;
    Form4.StringGrid1.Cells[Form4.StringGrid1.Col,currentSpecNum] := '1-'+ inttostr(newSR.yCoord.numRows) +' : 1-' + inttostr(newSR.yCoord.numCols) ;

    newSR := nil ;

  end ;
  end ;
finally
  bB.Free ;
end ;

  Form1.Refresh ;


end;




procedure TForm2.CreateHistogramBtnClick(Sender: TObject);
var
  t1 : integer ;
  tSR : TSpectraRanges ;
  selectedRowNum : integer ;
  rowRange, colRange : string ;
  bins               : integer ;
  selectedData, newAve : TSpectraRanges ;
begin

  SelectStrLst.SortListNumeric ;
  rowRange :=  RowRangeEB.Text ;
  colRange :=  ColRangeEB.Text ;
  bins :=  strtoint(NumberOfBinsEB.Text) ;

  for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
  begin
   selectedRowNum := StrToInt(SelectStrLst.Strings[t1]) ;


   if  (Form4.StringGrid1.Objects[SG1_COL, selectedRowNum]) is  TSpectraRanges then
   begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,selectedRowNum]) ;

      if pos('-',rowRange) = length(trim(rowRange)) then       // sampleRange string is open ended (e.g. '12-')
         rowRange := rowRange + inttostr(tSR.yCoord.numRows) ;
      if pos('-',colRange) = length(trim(colRange)) then       // sampleRange string is open ended (e.g. '12-')
         colRange := colRange + inttostr(tSR.yCoord.numCols) ;

 //      newAve := AverageBetweenGivenRanges(tSR,0.001)   ;



      newAve.SetOpenGLXYRange(Form2.GetWhichLineToDisplay()) ; // finds max and min values in xy data
      newAve.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), newAve.lineType) ;

   end ;

  end ;
  form1.Refresh ;

end;






procedure TForm2.NoImageCB1Click(Sender: TObject);
var
   t1, currentSpecNum : integer ;
   tSR : TSpectraRanges ;
begin

   SelectStrLst.SortListNumeric ;
   currentSpecNum := 0 ;
   if NoImageCB1.Checked = false then
   begin
     for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
     begin
       currentSpecNum := StrToInt(SelectStrLst.Strings[t1]) ;
       If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,currentSpecNum] is  TSpectraRanges  then
       begin
         tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,currentSpecNum]) ;
         if (tSR.lineType <> 7) and (tSR.lineType <> 9) then
           tSR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), tSR.lineType)
         else
         if ((tSR.lineType = 7) or (tSR.lineType = 9)) and (tSR.image2DSpecR <> nil) then
           tSR.image2DSpecR.CreateGLList('1-',Form1.Canvas.Handle, RC, Form2.GetWhichLineToDisplay(), 9) ;
       end ;
     end ;
   end
   else
   //if NoImageCB1.Checked = true then
   begin
     for t1 := 0 to SelectStrLst.Count-1 do    // for each file selected
     begin
       currentSpecNum := StrToInt(SelectStrLst.Strings[t1]) ;
       If Form4.StringGrid1.Objects[Form4.StringGrid1.Col ,currentSpecNum] is  TSpectraRanges  then
       begin
         tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,currentSpecNum]) ;
         ActivateRenderingContext(Form1.Canvas.Handle,RC); // make context drawable
         glDeleteLists(tSR.GLListNumber,1) ;
         wglMakeCurrent(0,0); // another way to release control of context
       end ;
     end ;

   end ;

   Form1.Refresh ;    
   
end;

end.




