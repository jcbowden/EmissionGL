{$A+,B-,C+,D+,E-,F-,G+,H+,I+,J+,K-,L+,M-,N+,O+,P+,Q+,R+,S-,T+,U-,V+,W+,X+,Y+,Z1}
{$MINSTACKSIZE $00004000}
{$MAXSTACKSIZE $01100000}
{$IMAGEBASE $00800000}
{$APPTYPE GUI}
unit emissionGL;

interface

uses
  Windows, Messages, OpenGL, SysUtils, Classes,  Controls, Forms, Dialogs,
  Menus, StdCtrls, Buttons, ExtCtrls, Clipbrd,  FileCtrl, Graphics, Math, comctrls,
  Grids, ShellAPI, TSpectraRangeObject, TMatrixObject ;

const
  REF_LIST=257 ; //name of OpenGL list to store reference spectra
  PRESENT_LIST=258 ;// OpenGL list containing names of reference spectra for top LHS corner

Var
    BKGRed, BKGGreen, BKGBlue : GLClampf ; // background color of OpenGL window
    RC    : HGLRC;
type
  TForm1 = class(TForm)
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormResize(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormShow(Sender: TObject);
    procedure FormDragOver(Sender, Source: TObject; X, Y: Integer;
      State: TDragState; var Accept: Boolean);

    procedure FormActivate(Sender: TObject);
    Procedure UpdateViewRange ;
    procedure Revert1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);

  private
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;


  public
    procedure wmDropFiles(var Msg: TWMDropFiles); message WM_DROPFILES;
    Procedure BuildOutLineFont(afontname:String; FontSize:byte);
    Procedure DrawColorRange(tSR : TSpectraRanges) ;  // for 2D image files, draws color scale
    Procedure DrawMeasureLines ;
    Procedure ZoomLines ; // if speedbutton2.down = true
    Procedure ZoomRectangle ;
    Procedure SurroundRectangle ;
    Procedure IntegrateDrawLines(startX,startY, finishX,finishY: single) ; // if speedbutton6.down = true
    Procedure DrawXScale( tStr_x : string )  ;
    procedure DrawYScale ;

    { Public declarations }
  end;


var
  Form1: TForm1;
  CurrentFileName : String ;
  CenterX, CenterY, CenterZ, EyeY, EyeZ, EyeX {, BkgSlope, BkgConst }: GLDouble ;
  MouseArrayX: array[0..1] of Integer ; //XDown, XPos : Integer ;
  MouseArrayY: array[0..1] of Integer ; //YDown, YPos : Integer
  MouseDownBool, MouseDown_DrawLine : bool ;
  SingPrec1GL, SingPrec2GL, OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin : glFloat ;
  StartLineXO, StartLineYO, EndLineXO, EndLineYO : glFloat ;
  StartLineX, StartLineY, EndLineX, EndLineY, HeightPerPix1, WidthPerPix1 : glFloat ;
  FirstXValue, LastXValue : glFloat ;
  drawDotX, drawDotY : glFloat ; // used for cross hair
  FontName : String  ;
  FontSize : ShortInt ;
  GLLineColors : Array[1..9] of TGLLineColor ;
  keyDownV : integer ;  // 0 = no key down, 1 = Ctrl, 2 = Shift, 3 = Ctrl and Shift... used for selecting multiple file from spectra graph window
  mapPointer : TMemoryStream ; // used for color values of texture mapping of 2D images

implementation

uses  SpectraLibrary, FileInfo, batchEdit, ColorsEM;


{$R *.DFM}



procedure TForm1.FormCreate(Sender: TObject);
var
  LM_Amb,  L0_POS,  L0_AMBI, L0_Dif, L0_Spec, L0_Dir : Array[0..3] of single ;
  Mat_Amb,  Mat_DIf, Mat_Spec, Mat_Emi : Array[0..3] of single ; 
  SpotEx, SpotCutOff, Shine : single ;
  t1, t2 : integer ;
  s1, s2 : single ;


begin
  MouseDownBool := false ;
  OrthoVarXMax := 1000 ;
  OrthoVarXMin := 0 ;
  OrthoVarYMax := 100;   // initialy low so as to find Maximum value by comparison with SingPrec2GL
  OrthoVarYMin := -1.2 ; // initialy high so as to find minimum value by comparison with SingPrec2GL

  HeightPerPix1 := (OrthoVarYMax-OrthoVarYMin)/Form1.ClientHeight ; // used to position text
  WidthPerPix1 := (OrthoVarXMax-OrthoVarXMin)/Form1.ClientWidth ;   // used to position text
  EyeX := 0 ;
  EyeY := 0 ;
  EyeZ := 150 ;  // gluLookAt
  CenterX := 0 ;
  CenterY := 0 ;
  CenterZ := 0 ;

  drawDotX := 0.0 ;
  drawDotY := 0.0 ;

  InitOpenGL ;
  
  RC:=CreateRenderingContext(Canvas.Handle,[opDoubleBuffered],32,0);

  ActivateRenderingContext(Form1.Canvas.Handle,RC); // make context drawable
    FontName := Form4.FontDialog1.Font.Name ;
    FontSize := Form4.FontDialog1.Font.Size ;
    Form1.BuildOutLineFont(FontName, FontSize);
  wglMakeCurrent(0,0); // another way to release control of context
end;





Procedure TForm1.BuildOutLineFont(afontname:String; FontSize:byte);
Var
  aLF : TLogFont;
  afont, oldfont : HFont;
Begin   //  If fRenderDC<>0 then
  FillChar(aLF,SizeOf(aLF),0);
  With aLF do
  Begin
    lfHeight:=FontSize;
    lfEscapement:=0 ;
    lfOrientation:=0;
//    lfOrientation:=lfEscapement;
    lfWeight:=FW_Normal;
    lfItalic:=0;
    lfUnderline:=0;
    lfStrikeOut:=0;
    lfCharSet:=ANSI_CHARSET;
    lfOutPrecision:=Out_TT_Precis;
    lfClipPrecision:=Clip_Default_Precis;
    lfQuality:=Default_Quality;
    lfPitchAndfamily:=DEFault_Pitch;
    If (length(aFontname)>0) and (Length(aFontname)<31) then
     strpcopy(lfFacename,aFontname)
//   strpcopy(@lfFacename,aFontname)
    else
     lfFacename:='Arial';
  end;
  aFont:=CreateFontIndirect(aLF);
  If aFont<>0 then
   Begin
    OldFont:=SelectObject(Form1.Canvas.Handle,aFont);
    wglUseFontBitmaps(Form1.Canvas.Handle, 0, 255, 1);
    SelectObject(Form1.Canvas.Handle,OldFont);
    DeleteObject(aFont);
   end;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  DestroyRenderingContext(RC);
  mapPointer.Free ;
//  GLStream.Free ;
end;




Procedure TForm1.DrawMeasureLines ;
begin
glColor3f(0.0,0.0,0.0) ;
      glbegin(GL_LINES) ;
        glVertex2f(StartLineX,StartLineY) ; // draw horizontal lines
        glVertex2f(EndLineX,StartLineY) ;
        glVertex2f(StartLineX,OrthoVarYMax) ;    // draw two vertical lines
        glVertex2f(StartLineX,OrthoVarYMin) ;
        glVertex2f(EndLineX,OrthoVarYMax) ;
        glVertex2f(EndLineX,OrthoVarYMin) ;
      glEnd ;
end ;

Procedure TForm1.ZoomLines ; // if speedbutton2.down = true
begin
     glColor3f(0.0,0.0,0.0) ;
      glbegin(GL_LINES) ;
        glVertex2f(StartLineX,OrthoVarYMax) ;
        glVertex2f(StartLineX,OrthoVarYMin) ;
        glVertex2f(EndLineX,OrthoVarYMax) ;
        glVertex2f(EndLineX,OrthoVarYMin) ;
      glEnd ;
end ;

Procedure TForm1.ZoomRectangle ;
begin
     glColor3f(0.0,0.0,0.0) ;
      glBegin(GL_LINE_LOOP) ;
        glVertex2f(StartLineX,StartLineY);
        glVertex2f(StartLineX,EndLineY);
        glVertex2f(EndLineX,EndLineY);
        glVertex2f(EndLineX,StartLineY);
      glEnd ;
end ;

Procedure TForm1.SurroundRectangle ;
begin
     glColor3f(0.0,0.0,0.0) ;
     glLineWidth(2.0) ;
 //    glEnable(GL_LINE_SMOOTH) ;
      glBegin(GL_LINE_LOOP) ;
      glVertex2f(OrthoVarXMin+EyeX,OrthoVarYMax-HeightPerPix1);
        glVertex2f(OrthoVarXMax-WidthPerPix1+EyeX,OrthoVarYMax);
        glVertex2f(OrthoVarXMax-WidthPerPix1+EyeX,OrthoVarYMin+HeightPerPix1);
        glVertex2f(OrthoVarXMin+EyeX+WidthPerPix1,OrthoVarYMin+HeightPerPix1);
      glEnd ;
  //  gldisable(GL_LINE_SMOOTH) ;
    glLineWidth(1.0) ;
end ;

Procedure TForm1.IntegrateDrawLines( startX,startY, finishX,finishY  : single )  ; // if speedbutton6.down = true
begin
     glColor3f(0.0,0.0,0.0) ;
      glbegin(GL_LINES) ;
        // draw horizontal line
        glVertex2f(startX,startY) ;
        glVertex2f(finishX,finishY) ;
        // draw two vertical lines
        glVertex2f(startX,OrthoVarYMax) ;
        glVertex2f(startX,OrthoVarYMin) ;
        glVertex2f(finishX,OrthoVarYMax) ;
        glVertex2f(finishX,OrthoVarYMin) ;
      glEnd ;
end ;



Procedure TForm1.DrawColorRange(tSR : TSpectraRanges) ;
var
  tStr : string ;// floattostrf(SpectObj.image2DSpecR.yLow,ffgeneral,5,3)
  logval : single ;
  trans_x, trans_y : single ;
  strPosX, strPosY : single ;
  logvalInt : integer ;
  colorRatio : single ;
  squash     : single ;
begin
    try
      strPosX := Strtofloat(Form2.CalBarPosXEB1.Text) ;
    except
    on EConvertError do
      Form2.CalBarPosXEB1.Text := copy(Form2.CalBarPosXEB1.Text,1,length(Form2.CalBarPosXEB1.Text)-1) ;
    end ;
    try
      strPosY := Strtofloat(Form2.CalBarPosYEB1.Text) ;
    except
    on EConvertError do
     Form2.CalBarPosYEB1.Text := copy(Form2.CalBarPosYEB1.Text,1,length(Form2.CalBarPosYEB1.Text)-1) ;
    end ;


    glPushMatrix() ; // glPopMatrix  GL_MODELVIEW_MATRIX
      trans_x := WidthPerPix1 * (strPosX-0.10) * Form1.ClientWidth ;
      trans_y := HeightPerPix1 * strPosY * Form1.ClientHeight ;

      squash :=   ((50 / 1200) * tSR.image2DSpecR.XHigh ) / 50    ;
      glTranslatef(trans_x, trans_y, 0.0) ;
      glScalef(squash,1,1) ;

      if (tSR.image2DSpecR.YHigh > 0) and (tSR.image2DSpecR.YLow >= 0) then
      begin

         glColor3f(1.0,1.0,1.0) ;
         glbegin(GL_QUADS) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*80)) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*-20)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*-20)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*80)) ;
        glEnd ;

        glbegin(GL_Triangles) ;
          glColor3f(0.0,0.0,0.0) ;
          glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ; //
          glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;  //
          glColor3f(0.0,0.0,1.0) ;
          glVertex2f(0,OrthoVarYMin+(HeightPerPix1*60)) ;
          glColor3f(0.0,0.0,0.0) ;
          glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;
          glColor3f(0.0,0.0,1.0) ;
          glVertex2f(0,OrthoVarYMin+(HeightPerPix1*60)) ;
          glVertex2f(50,OrthoVarYMin+(HeightPerPix1*60)) ;
        glEnd ;

         if tSR.image2DSpecR.yHigh <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yHigh)) ;
           logvalInt := Round(logval) + 1 ;
         end
         else  logvalInt := 1 ;
         glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*65)) ;
         tStr :=  floattostrf(tSR.image2DSpecR.yHigh,ffgeneral,logvalInt,0)  ;
         glListBase(1); // indicate the start of display lists for the glyphs.
         glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;

         if tSR.image2DSpecR.yLow <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yLow)) ;
           logvalInt := Round(logval) + 1;
         end
         else  logvalInt := 1 ;

         glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*-15)) ;
         tStr :=  floattostrf(tSR.image2DSpecR.yLow,ffgeneral,logvalInt,0)  ;
         glListBase(1); // indicate the start of display lists for the glyphs.
         glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;
     end
     else
     if (tSR.image2DSpecR.YHigh > 0) and (tSR.image2DSpecR.YLow < 0) then
     begin
        glColor3f(1.0,1.0,1.0) ;
         glbegin(GL_QUADS) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*80)) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*-80)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*-80)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*80)) ;
        glEnd ;

        // determine amount of smaller range to scale color bar by
        if  abs(tSR.image2DSpecR.YHigh) > abs(tSR.image2DSpecR.YLow) then
        begin
           colorRatio :=  abs(tSR.image2DSpecR.YLow / tSR.image2DSpecR.YHigh) ;
        end
        else
        if abs(tSR.image2DSpecR.YHigh) < abs(tSR.image2DSpecR.YLow) then
        begin
           colorRatio :=  abs(tSR.image2DSpecR.YHigh / tSR.image2DSpecR.YLow) ;  // larger absolute value is the negative (green)
        end ;


        glbegin(GL_Triangles) ;
         glColor3f(0.0,0.0,0.0) ;
         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ; //
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;  //
         if abs(tSR.image2DSpecR.YHigh) > abs(tSR.image2DSpecR.YLow) then
           glColor3f(0.0,0.0,1.0)
         else
           glColor3f(0.0,0.0,colorRatio) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*60)) ;
         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;
         if abs(tSR.image2DSpecR.YHigh) > abs(tSR.image2DSpecR.YLow) then
           glColor3f(0.0,0.0,1.0)
         else
           glColor3f(0.0,0.0,colorRatio) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*60)) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*60)) ;

         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ; //
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;  //
         if abs(tSR.image2DSpecR.YHigh) < abs(tSR.image2DSpecR.YLow) then
           glColor3f(0.0,1.0,0.0)
         else
           glColor3f(0.0,colorRatio,0.0) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ;
        glEnd ;

        if tSR.image2DSpecR.yHigh <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yHigh)) ;
           logvalInt := Round(logval) + 1;
         end
         else  logvalInt := 1 ;
        glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*65)) ;
        tStr :=  floattostrf(tSR.image2DSpecR.yHigh,ffgeneral,logvalInt,0)  ;
        glListBase(1); // indicate the start of display lists for the glyphs.
        glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;

        if tSR.image2DSpecR.yLow <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yLow)) ;
           logvalInt := Round(logval) + 1;
         end
         else  logvalInt := 1 ;
        glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*-75)) ;
        tStr :=  floattostrf(tSR.image2DSpecR.yLow,ffgeneral,logvalInt,0)  ;
        glListBase(1); // indicate the start of display lists for the glyphs.
        glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;
      end
      else
      if (tSR.image2DSpecR.YHigh <= 0) and (tSR.image2DSpecR.YLow < 0) then
      begin
        glColor3f(1.0,1.0,1.0) ;
         glbegin(GL_QUADS) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*20)) ;
           glVertex2f(-20,OrthoVarYMin+(HeightPerPix1*-80)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*-80)) ;
           glVertex2f(90,OrthoVarYMin+(HeightPerPix1*20)) ;
        glEnd ;

        glbegin(GL_Triangles) ;
         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ; //
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*0)) ;  //
         glColor3f(0.0,1.0,0.0) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glVertex2f(50,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*-60)) ;
         glColor3f(0.0,0.0,0.0) ;
         glVertex2f(0,OrthoVarYMin+(HeightPerPix1*0)) ;
        glEnd ;

        if tSR.image2DSpecR.yHigh <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yHigh)) ;
           logvalInt := Round(logval) + 1;
         end
         else  logvalInt := 1 ;
        glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*5)) ;
        tStr :=  floattostrf(tSR.image2DSpecR.yHigh,ffgeneral,logvalInt,0)  ;
        glListBase(1); // indicate the start of display lists for the glyphs.
        glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;

        if tSR.image2DSpecR.yLow <> 0 then
         begin
           logval := log10(abs(tSR.image2DSpecR.yLow)) ;
           logvalInt := Round(logval) + 1;
         end
         else  logvalInt := 1 ;
        glRasterPos2f(0,OrthoVarYMin+(HeightPerPix1*-75)) ;
        tStr :=  floattostrf(tSR.image2DSpecR.yLow,ffgeneral,logvalInt,0)  ;
        glListBase(1); // indicate the start of display lists for the glyphs.
        glCallLists(Length(tStr),GL_UNSIGNED_BYTE,@tStr[1]) ;
     end ;

    glPopMatrix()  // glPopMatrix      GL_MODELVIEW_MATRIX

end ;


Procedure TForm1.DrawXScale( tStr_x : string) ;
Var
  TempStr1 : String ;
  TempInt1: LongInt ;
  TempFloat1, TempFloat2 : glFloat ;
  numPrecission, decimalPlaces : integer ;
//  y_pos : single ;
begin
{   if Form2.CheckBox5.Checked then
     y_pos := (HeightPerPix1 * Form1.ClientHeight - 37)
   else
    y_pos := 1 ;  }

   glbegin(GL_LINES) ;  // this draws the line across
     glVertex2f((OrthoVarXMin+eyeX+WidthPerPix1*30),OrthoVarYMin+(HeightPerPix1*37)) ;
     glVertex2f(OrthoVarXMax+eyeX,OrthoVarYMin+(HeightPerPix1*37)) ;
   glEnd ;

   TempStr1 := tStr_x ;
   glRasterPos2f(OrthoVarXMin+(Form1.ClientWidth*WidthPerPix1/2)-(Length(TempStr1)*6*WidthPerPix1/2)+EyeX,OrthoVarYMin+(HeightPerPix1*6)) ;
   glListBase(1); // indicate the start of display lists for the glyphs.
   if length(TempStr1) > 0 then   
   glCallLists(Length(TempStr1),GL_UNSIGNED_BYTE,@TempStr1[1]) ;


   if OrthoVarXMax <>  OrthoVarXMin then
   begin
     TempFloat1 := ( (Abs((OrthoVarXMax+EyeX)-(OrthoVarXMin+EyeX))) / 10 ) ;
     For TempInt1 := 1 to 10 Do  // draws 10 equal spaced vertical lines
     begin

       glbegin(GL_LINES) ; // this draws short vertical lines
         glVertex2f(eyeX + OrthoVarXMin + (TempInt1*TempFloat1),OrthoVarYMin+(HeightPerPix1*37)) ;
         glVertex2f(eyeX +OrthoVarXMin + (TempInt1*TempFloat1),OrthoVarYMin+(HeightPerPix1*32)) ;
       glEnd ;

       TempFloat2 := eyeX +OrthoVarXMin + (TempInt1*TempFloat1) ;
       if  TempFloat2 = 0 then
         TempFloat2 := 1 ;

       numPrecission := round(log10(abs(TempFloat2))) + 1  ;
       if  TempFloat1 <> 0 then
         decimalPlaces :=  round(log10(TempFloat1)) - 1 
       else
         decimalPlaces := 0 ;

       if decimalPlaces < 0 then decimalPlaces := abs(decimalPlaces) + 1
       else decimalPlaces := 1 ;
       numPrecission := numPrecission + decimalPlaces ;
       TempStr1 := FloatToStrf(TempFloat2,ffFixed,numPrecission,decimalPlaces) ;
      // TempStr1 := FloatToStrf(eyeX +OrthoVarXMin + (TempInt1*TempFloat1),ffFixed,5,7) ;

       glRasterPos2f(eyeX +OrthoVarXMin + ((TempInt1*TempFloat1)-(WidthPerPix1*12)),OrthoVarYMin+(HeightPerPix1*20)) ;  // position of number value of X
       glListBase(1); // indicate the start of display lists for the glyphs.
       glCallLists(Length(TempStr1),GL_UNSIGNED_BYTE,@TempStr1[1]) ;
      end ; // For TempInt1 := 0 to 10
     end ;
end;


procedure TForm1.DrawYScale ;
Var
  TempStr1 : String ;
  TempInt1, TempInt2, NumberDrawn : LongInt ;
  TempFloat1, TempFloat2, FullScale : glFloat ;
begin
glbegin(GL_LINES) ;
  glVertex2f((OrthoVarXMin+WidthPerPix1*30)+EyeX,OrthoVarYMin+(HeightPerPix1*37)) ;
  glVertex2f((OrthoVarXMin+WidthPerPix1*30)+EyeX,OrthoVarYMax) ;
glEnd ;
if (OrthoVarYMax-OrthoVarYMin) > 0 then
   FullScale :=  (Int(Log10(OrthoVarYMax-OrthoVarYMin)))  
else    FullScale := 1 ;  // xxx this needs changing
  For TempInt1 := 0 to 20 do
    begin
      TempFloat1 := (TempInt1*Power(10,(FullScale))) ;
      If (TempFloat1<OrthoVarYMax) and (TempFloat1>OrthoVarYMin) Then
          NumberDrawn := NumberDrawn + 1 ;
    end ;

  For TempInt1 := 0 to 20 do
    begin
      TempFloat1 := (TempInt1*Power(10,(FullScale))) ;
      If (TempFloat1<OrthoVarYMax) and (TempFloat1>OrthoVarYMin) Then
      begin
        glbegin(GL_LINES) ;
          glVertex2f((OrthoVarXMin+WidthPerPix1*30)+EyeX,TempFloat1) ;
          glVertex2f((OrthoVarXMin+WidthPerPix1*26)+EyeX,TempFloat1) ;
        glEnd ;
        TempStr1 := FloatToStrf(TempFloat1,ffgeneral,4,3) ;
        If TempInt1 = 0 Then
        glRasterPos2f((OrthoVarXMin+WidthPerPix1*4)+EyeX,TempFloat1+(HeightPerPix1))
        else
        glRasterPos2f((OrthoVarXMin+WidthPerPix1*4)+EyeX,TempFloat1-(HeightPerPix1*4)) ;
        glListBase(1); // indicate the start of display lists for the glyphs.
        glCallLists(Length(TempStr1),GL_UNSIGNED_BYTE,@TempStr1[1]) ;
      end ;
      For TempInt2 := 1 to 9 Do
        begin
          TempFloat2 := TempInt2*(power(10,FullScale)/10) ;
          If (TempFloat2<OrthoVarYMax) and (TempFloat2>OrthoVarYMin) and (NumberDrawn>0) Then
            begin
              If (Form1.ClientHeight/NumberDrawn) > (HeightPerPix1*14)    Then
              begin
              glbegin(GL_LINES) ;
                glVertex2f((OrthoVarXMin+WidthPerPix1*30)+EyeX,TempFloat1+TempFloat2) ;
                glVertex2f((OrthoVarXMin+WidthPerPix1*28)+EyeX,TempFloat1+TempFloat2) ;
              glEnd ;
              If (Form1.ClientHeight/NumberDrawn) > (10*Form4.FontDialog1.Font.Size*1.2)    Then
              begin
              TempStr1 := FloatToStrf(TempFloat1+TempFloat2,ffgeneral,4,3) ;
              If TempInt2 = 0 Then
              glRasterPos2f((OrthoVarXMin+WidthPerPix1*4)+EyeX,TempFloat1+TempFloat2+(HeightPerPix1))
              else
              glRasterPos2f((OrthoVarXMin+WidthPerPix1*4)+EyeX,TempFloat1+TempFloat2-(HeightPerPix1*4)) ;
              glListBase(1); // indicate the start of display lists for the glyphs.
              glCallLists(Length(TempStr1),GL_UNSIGNED_BYTE,@TempStr1[1]) ;
              end ;
              end ;
            end ;  
        end ;
    end ;
end ;


procedure TForm1.FormPaint(Sender: TObject);
Var
  TempInt1 : Integer ;
  ScalePerX : Single ;
  TempStr : String ;
  XorYData : integer ;
  scaleY, centreY, scaleZ : single ;
  tSR : TSpectraRanges ;
begin  // draw somthing useful
  Screen.Cursor := crHourglass ;
  ActivateRenderingContext(Canvas.Handle,RC); // make context drawable

  glClearColor(BKGRed,BKGGreen,BKGBlue,1.0); // background color of the context
  glClear(GL_COLOR_BUFFER_BIT or GL_DEPTH_BUFFER_BIT); // clear background and depth buffer
  glMatrixMode(GL_ModelView); // activate the transformation matrix
  glLoadIdentity;             // set it to initial state
  ScalePerX := (StrtoFloat(Form2.Edit7.Text) - StrToFloat(Form2.Edit6.Text))/Form1.Width ;
  If MouseDownBool and Not Form2.Speedbutton2.down and Not Form2.SpeedButton3.Down and Not Form2.SpeedButton6.Down and Not Form2.SpeedButton8.Down and Not Form2.BaselineCorrSB9.Down then
  begin //  moving spectra left or right
     CenterX := CenterX - (MouseArrayX[1]-MouseArrayX[0])* ScalePerX  ;
     EyeX := CenterX ;
  end ;

  Form2.Edit6.Text := FloatToStrf((OrthoVarXMin+EyeX),ffGeneral,5,6) ;   // update minimum X visible range
  Form2.Edit7.Text := FloatToStrf((OrthoVarXMax+EyeX),ffGeneral,5,6) ;   // update maximum X visible range
  Form2.Edit9.Text := FloatToStrf((OrthoVarYMin+EyeY),ffGeneral,5,6) ;   // update minimum X visible range
  Form2.Edit8.Text := FloatToStrf((OrthoVarYMax+EyeY),ffGeneral,5,6) ;   // update maximum X visible range

  gluLookAt(EyeX,EyeY,EyeZ,CenterX,CenterY,CenterZ,0,1,0); // set up a viewer position and view point

  // this allows X data to be viewed when 'filename' column is selected
  if Form4.StringGrid1.Col = 1 then
    XorYData := 2
  else
    XorYData := Form4.StringGrid1.Col ;


  if Form4.CheckBox8.checked then  // all spectra full screen
  begin
    // get max and min Y of first selected spectra
    // stretch to fit
    scaleY :=  OrthoVarYMax - OrthoVarYMin ;
    centreY :=  OrthoVarYMin + (scaleY / 2) ;
  end ;

//  glEnable(GL_DEPTH_TEST); // enable depth testing
  If Form4.CheckBox6.Checked Then   // display selected files
  begin
    For TempInt1 := 1 to SelectStrLst.Count Do
    begin
      glPushMatrix() ;
        glTranslatef(0,0,0) ;
        If Form4.StringGrid1.Objects[SG1_COL ,StrToInt(SelectStrLst.Strings[TempInt1-1])] is TSpectraRanges  Then
        begin
          tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,StrToInt(SelectStrLst.Strings[TempInt1-1])]) ;
          if Form4.CheckBox8.checked then  // all spectra full screen
          begin
           // scaleY := (tSR.yHigh+(5*HeightPerPix1)) - (tSR.yLow-(41*HeightPerPix1))  ;
            scaleY := tSR.yHigh - tSR.yLow  +(46*HeightPerPix1) ;
            scaleY := (OrthoVarYMax - OrthoVarYMin) / scaleY ;
            glScalef(1.0,scaleY,1.0) ;
          end ;
        //  if tSR.
 //       scaleZ :=
          glCallList(tSR.GLListNumber) ;
        end ;
        glCallList(REF_LIST) ;
      glPopMatrix() ;
    end ;
  end
  else  // display all files
    begin
    For TempInt1 := 1 to Form4.StringGrid1.RowCount-1 Do
      begin
        glPushMatrix() ;
         glTranslatef(0,0,0) ;
           If Form4.StringGrid1.Objects[SG1_COL,TempInt1] is TSpectraRanges Then
           begin
              tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL,TempInt1])  ;
             if Form4.CheckBox8.checked then  // all spectra full screen
             begin
               scaleY := tSR.yHigh - tSR.yLow ;
               scaleY := (OrthoVarYMax - OrthoVarYMin) / scaleY ;
               glScalef(1.0,scaleY,1.0) ;
             end ;
             glCallList(tSR.GLListNumber) ;
           end ;
         glCallList(REF_LIST) ;
        glPopMatrix() ;
      end ;
    end ;

  glPushMatrix() ;
    glTranslatef(EyeX,0,0) ;
    glCallList(PRESENT_LIST) ;   // list containing names of reference spectra for top LHS corner
  glPopMatrix() ;

 // SurroundRectangle ; //draw surrounding box
  glColor3f(0.0,0.0,0.0) ;

  If (Form2.Checkbox6.Checked) Then   // draw x scale
  begin
    if (Form4.StringGrid1.Objects[SG1_COL, Form4.StringGrid1.Selection.Top]) is  TSpectraRanges then
    begin
      tSR := TSpectraRanges(Form4.StringGrid1.Objects[SG1_COL, Form4.StringGrid1.Selection.Top])  ;
      DrawXScale(tSR.xString)  ;
    end
    else
     DrawXScale('Wavenumber / cm-1')  ;
  end ;

  If (Form2.Checkbox4.Checked) Then
  DrawYScale ;

  TempStr := FloatToStrf(abs(StartLineX-EndLineX),ffFixed,5,3)+ ' nm' ;
  If (Form2.SpeedButton2.Down) or (Form2.SpeedButton8.Down) Then // Draw vertical lines for zoom between lines tool
    begin
      ZoomLines ; // procedure "zoomlines"
      If StartLineX < EndLineX Then
        glRasterPos2f(StartLineX+((EndLineX-StartLineX)/3),StartLineY)
      else
        glRasterPos2f(EndLineX+((StartLineX-EndLineX)/3),StartLineY) ;
      glListBase(1); // indicate the start of display lists for the glyphs.
      glCallLists(Length(TempStr),GL_UNSIGNED_BYTE,@TempStr[1]) ;   // show text of range between lines drawn
    end ;

  If Form2.SpeedButton6.Down and MouseDownBool Then // draw baseline and range for integration
      IntegrateDrawLines(StartLineX,StartLineY, EndLineX, EndLineY) ;

  If Form2.BaselineCorrSB9.Down and MouseDownBool Then // draw baseline and range for baseline subtraction
      IntegrateDrawLines(StartLineX,StartLineY, EndLineX, EndLineY) ;

  If Form2.SpeedButton3.Down and MouseDownBool Then    // draw rectangle
      ZoomRectangle ;

  If MouseDown_DrawLine Then
    Form2.Edit15.Text := TempStr ;

  If Form2.CheckBox2.Checked Then  // measure range on screen
    begin
      DrawMeasureLines ;
    end ;

 if not Form2.CalBarHideCB1.Checked then
 begin
 if Form4.StringGrid1.Objects[XorYData,Form4.StringGrid1.Row] is TSpectraRanges then
 begin
   tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[XorYData,Form4.StringGrid1.Row]) ;
   if (tSR.nativeImage = true) or (tSR.frequencyImage = true) then
   begin
      DrawColorRange(tSR) ;
   end ;
 end ;
 end ;



//
  glBlendFunc(GL_ONE_MINUS_SRC_ALPHA,GL_SRC_ALPHA) ;

  if Form2.ShowCursor.Checked  then
  begin
    glEnable( GL_BLEND  ) ;
     if tSR <> nil then
     begin
 {  glPointsize(3.0) ;
    glbegin(GL_POINTS) ;
      glColor3f(1.0,0.0,0.0) ;
      glVertex2f(drawDotX ,drawDotY) ;
   glEnd ;  }
       glbegin(GL_LINES) ;
       glColor4f(1.0,0.0,0.0,0.5) ;
       glVertex2f(drawDotX , tSR.YHigh) ;
       glVertex2f(drawDotX ,tSR.YLow) ;
       glVertex2f(tSR.XHigh ,drawDotY) ;
       glVertex2f(tSR.XLow ,drawDotY) ;
       glEnd ;
     end ;
     glDisable( GL_BLEND  ) ;
  end ;


  SwapBuffers(Canvas.Handle); // copy back buffer to front
  Screen.Cursor := crArrow ;
  DeactivateRenderingContext; // release control of context
end;




procedure TForm1.FormKeyPress(Sender: TObject; var Key: Char);
begin
  if Key = #27 then Application.Terminate;   // terminate if escape kill pressed
end;




procedure TForm1.FormResize(Sender: TObject);
Var
// TempList1 : TStringList ;
 TempInt1, TempInt2, ListCount1 : Integer ;
 TempStr1 : String ;
  RefCol_r, RefCol_g, RefCol_b  : glFloat ;
  XorYData : integer ;
  aspectRatioImage, aspectRatioScreen : single ;
  tSR : TSpectraRanges ;
begin // handle form resizing (viewport must be adjusted)
  ListCount1 := 0 ;

  wglMakeCurrent(Canvas.Handle,RC); // another way to make context drawable
  glViewport(0,0,Form1.ClientWidth,Form1.ClientHeight); // specify a viewport (has not necessarily to be the entire window)

  // glulookat
  glMatrixMode(GL_PROJECTION); // activate projection matrix
    glLoadIdentity;              // set initial state
  //  gluPerspective(80,Form1.ClientWidth/Form1.ClientHeight,0.01,1000); // specify perspective params (see OpenGL.hlp)
    glOrtho(OrthoVarXMin,OrthoVarXMax,OrthoVarYMin,OrthoVarYMax,1500,-1500)     ;

    HeightPerPix1 := (OrthoVarYMax-OrthoVarYMin)/Form1.ClientHeight ; // used to position drawing objects
    WidthPerPix1 := (OrthoVarXMax-OrthoVarXMin)/Form1.ClientWidth ;   // used to position drawing objects
  glMatrixMode(GL_ModelView);


  if Form4.StringGrid1.Col = 1 then
    XorYData := 2
  else
    XorYData := Form4.StringGrid1.Col ;
 if Form4.StringGrid1.Objects[XorYData,Form4.StringGrid1.Row] is TSpectraRanges then
 begin
   tSR :=  TSpectraRanges(Form4.StringGrid1.Objects[XorYData,Form4.StringGrid1.Row]) ;
   if (tSR.nativeImage = true) or (tSR.frequencyImage = true) then
   begin
     aspectRatioScreen :=   WidthPerPix1 / HeightPerPix1 ;
//    aspectRatioImage  := (tSR.xPix * tSr.xPixSpacing) / (tSR.yPix * tSr.yPixSpacing) ;
     Form4.StatusBar1.Panels[0].Text := 'Aspect ratio = '+ floattostrf(aspectRatioScreen,ffGeneral,5,3) ;   //  + floattostrf(aspectRatioImage,ffGeneral,5,3) +' / '
   end ;
 end ;

  Try
  glNewList(PRESENT_LIST,GL_COMPILE) ;
  if   Form2.CheckListBox1  <> nil  then
  begin
  For TempInt1 := 0 to Form2.CheckListBox1.Items.Count-1 Do
    begin
      If Form2.CheckListBox1.Checked[TempInt1] Then
        begin
             ListCount1 := ListCount1+1 ;
             TempStr1 := IntensityList.Strings[TempInt1] ;   // GET CURRENT INTENSITY VALUE AND RED/GREEN/BLUE VALUE
             TempInt2 := Pos(' ',TempStr1) ;
           //  DesiredMaxIntensity := StrToFloat(copy(TempStr1,1,TempInt2-1)) ;
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

             glColor3f(RefCol_r,RefCol_g,RefCol_b) ;
             TempStr1 := Form2.CheckListBox1.Items.Strings[TempInt1] ;
             glRasterPos2f(OrthoVarXMin+(19*WidthPerPix1), OrthoVarYMax-(ListCount1*(FontSize+4)*HeightPerPix1)) ;
             glCallLists(Length(TempStr1),GL_UNSIGNED_BYTE,@TempStr1[1]) ;  // list reference spectra in top LH corner
       end ;
    end ;
    glEndList() ;
    end ;
  Except
    on EAccessViolation do
  end ;

  wglMakeCurrent(0,0); // another way to release control of context
  Refresh;             // cause redraw
end;


procedure TForm1.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin // avoid clearing the background (causes flickering and speed penalty)
  Message.Result:=1;

end;


Procedure TForm1.UpdateViewRange() ; // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
var
  GridRow, GridCol : integer ;
  tSR : TSpectraRanges ;
begin
    GridRow :=  Form4.StringGrid1.Selection.Top ; // the file i am messing with is in this row of the stringgrid
    GridCol :=  Form4.StringGrid1.Selection.Left ;
    
    if Form4.StringGrid1.Objects[GridCol,GridRow] is TSpectraRanges then
    begin
        tSR := TSpectraRanges(Form4.StringGrid1.Objects[GridCol,GridRow]) ;

        WidthPerPix1:=(tSR.XHigh-tSR.XLow)/ (Form1.ClientWidth-16) ;
        if WidthPerPix1 = 0 then
        begin
          WidthPerPix1 := 1 ;
          OrthoVarXMin := tSR.XLow - 1 ;
          OrthoVarXMax := tSR.XHigh + 1;
        end
        else
        begin
          OrthoVarXMin := tSR.XLow - (35*WidthPerPix1) ;
          OrthoVarXMax := tSR.XHigh + (3*WidthPerPix1) ;
        end ;

        HeightPerPix1 := ((tSR.YHigh-tSR.YLow)/(Form1.ClientHeight-46)) ;
        if HeightPerPix1 = 0 then
        begin
          HeightPerPix1 := 1 ;
          OrthoVarYMin := tSR.YLow - 1 ;
          OrthoVarYMax := tSR.YHigh + 1 ;
        end
        else
        begin
          OrthoVarYMin := tSR.YLow-(41*HeightPerPix1) ;
          OrthoVarYMax := tSR.YHigh+(5*HeightPerPix1) ;
        end ;

      If Form2.CheckBox9.Checked Then  // invert x axis
      begin
        OrthoVarXMax := tSR.XLow   ;
        OrthoVarXMin := tSR.XHigh + (30*WidthPerPix1);
      end ;
      If Form2.CheckBox5.Checked Then  // invert y axis
      begin
        OrthoVarYMax := tSR.YLow   ;
        OrthoVarYMin := tSR.YHigh + (30*HeightPerPix1);
      end ;

      Form2.Edit12.Text := FloatToStrF(OrthoVarYMax,ffGeneral,3,2) ;
    end ;
    Form1.FormResize(nil) ;
end ;


Function MaxGL (StartLine, EndLine : GLFloat) : GLFloat ;
begin
   if StartLine > Endline Then
     Result := StartLine
   else
     Result := EndLine ;
   end ;

Function MinGL (StartLine, EndLine : GLFloat) : GLFloat ;
begin
   if StartLine < Endline Then
     Result := StartLine
   else
     Result := EndLine ;
end ;

Procedure InitialiseStartEndValues ;
begin
     StartLineX := 0 ;
     StartLineY := 0 ;
     EndLineX := 0 ;
     EndLineY := 0 ;
end ;

Procedure InitialiseMouseArray ;
begin
   MouseArrayX[0]:= 0;
   MouseArrayY[0] := 0;
   MouseArrayX[1] := 0;
   MouseArrayY[1] := 0;
end ;


procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
   If  Form2.CheckBox2.Checked Then   // "Measure" check box for shifting data
     MouseDown_DrawLine  := True
   else
     MouseDownBool := True ;

   StartLineX :=  OrthoVarXMin+(X/Width)*(OrthoVarXMax-OrthoVarXMin)+EyeX ;
   StartLineY :=  OrthoVarYMin+((Form1.ClientHeight-Y)/Form1.ClientHeight)*(OrthoVarYMax-OrthoVarYMin) + EyeY ;

   MouseArrayX[1]:= 0;      //Current X Pos
   MouseArrayY[1] := 0;     //Current Y Pos
   MouseArrayX[0] := X ;    //Storage of X Down position
   MouseArrayY[0]:= Y ;     //Storage of Y Down position

end;


procedure TForm1.FormMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
Var
  CursorPosX, CursorPosY :  GlFloat ;
  tSR : TSpectraRanges ;
  closestX, closestY : integer ;
  s1_x, s1_y : single ;
  i1_x, i1_y : integer ;
begin
If MouseDownBool Then
  begin
      If MouseArrayX[1] > MouseArrayX[0] Then
        begin
          If X < MouseArrayX[1] Then
            begin
              MouseArrayX[0] := X ;
              MouseArrayX[1] := X ;
            end
          else
            MouseArrayX[1] := X ;
        end
     else
        If MouseArrayX[1] < MouseArrayX[0] Then
          begin
            If X > MouseArrayX[1] Then
              begin
                MouseArrayX[0] := X ;
                MouseArrayX[1] := X ;
              end 
            else
                MouseArrayX[1] := X ;
          end
     else
       If MouseArrayX[1] = MouseArrayX[0] Then
          MouseArrayX[1] := X ;


     If MouseArrayY[1] > MouseArrayY[0] Then
        begin
          If Y < MouseArrayY[1] Then
            begin
              MouseArrayY[0] := Y ;
              MouseArrayY[1] := Y ;
            end
          else
            MouseArrayY[1] := Y ;
        end
     else
        If MouseArrayY[1] < MouseArrayY[0] Then
          begin
            If Y > MouseArrayY[1] Then
              begin
                MouseArrayY[0] := Y ;
                MouseArrayY[1] := Y ;
              end
            else
                MouseArrayY[1] := Y ;
          end
     else
       If MouseArrayY[1] = MouseArrayY[0] Then
          MouseArrayY[1] := Y ;

   repaint ;  
  end ; // end if MouseDownBool


 if (Form2.CalBarMoveCB1.Checked) and (ssCtrl in Shift) then
 begin  // move the calibration bar
    Form2.CalBarPosXEB1.Text := FloattoStr(X / Form1.ClientWidth) ;
    Form2.CalBarPosYEB1.Text := FloattoStr((Form1.ClientHeight-Y) / Form1.ClientHeight) ;
    repaint ; 
 end ;


  EndLineX := OrthoVarXMin+(X/Form1.ClientWidth)*(OrthoVarXMax-OrthoVarXMin)+EyeX ;
  EndLineY := OrthoVarYMin+((Form1.ClientHeight-Y)/Form1.ClientHeight)*(OrthoVarYMax-OrthoVarYMin) + EyeY ;

  If MouseDown_DrawLine  Then
    repaint
  else
  

  CursorPosX := EndLineX ;
  CursorPosY := EndLineY ;


  Form2.Edit10.Text := FloatToStrf(CursorPosX,ffGeneral,7,7) ;  // Cursor X Position edit box
  Form2.Edit11.Text := FloatToStrf(CursorPosY,ffGeneral,7,7) ;  // Cursor Y Position edit box

  // determine what spectra number is closest to cursor in 2D image and display in status bar
  if Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top] is TSpectraRanges Then
  begin
    tSR := TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]) ;
    if (tSR.frequencyImage = true) or (tSR.nativeImage = true) then
    begin
      i1_x :=   Round(CursorPosX /  tSR.xPixSpacing) ;
      i1_x := i1_x + (tSR.xPix * tSR.yPix  * (strtoint(form2.ImageNumberTB1.Text)-1)) + 1;  // form2.Edit22.Text is 'image number' for multi image files (files with more spectra than pixels)
      if i1_x < 1 then i1_x := 1
      else
      if i1_x > tSR.xPix then i1_x := tSR.xPix ;

      i1_y :=   Round(CursorPosY /  tSR.yPixSpacing) ;
      i1_y := i1_y + (tSR.xPix * tSR.yPix  * (strtoint(form2.ImageNumberTB1.Text)-1)) + 1 ;
      if i1_y < 1 then i1_y := 1
      else
      if i1_y > tSR.yPix then i1_y := tSR.yPix ;

      Form4.StatusBar1.Panels[0].Text := 'spectra ' + inttostr(i1_x) +','+  inttostr(i1_y) ;

      if tSR.nativeImage then
      begin
        i1_x := (i1_x) + ((i1_y -1)* tSR.xPix) ; // this is position of data
        tSR.yCoord.F_Mdata.Seek((i1_x-1) *  tSR.yCoord.SDPrec, soFromBeginning) ;
        tSR.yCoord.F_Mdata.Read(s1_x,4) ;
      end
      else
      if tSR.frequencyImage then
      begin
        i1_x := (i1_x) + ((i1_y -1)* tSR.xPix) ;  // this is position of data
        tSR.yCoord.F_Mdata.Seek(((i1_x-1) *  tSR.yCoord.SDPrec * tSR.yCoord.numCols)+(tSR.currentSlice *  tSR.yCoord.SDPrec)  , soFromBeginning) ;
        tSR.yCoord.F_Mdata.Read(s1_x,4) ;
      end ;

      tSR.yCoord.F_Mdata.Seek(0, soFromBeginning) ;
      Form4.StatusBar1.Panels[0].Text := Form4.StatusBar1.Panels[0].Text  + ' ('+  inttostr(i1_x)  +') value ' + floattostrf(s1_x,ffGeneral,7,5) ;
    end
  end ;


end;





procedure TForm1.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
Var
  TempFloat : Single ;
  tBkgSlp, tBkgCnst  : single ;
begin
  MouseDownBool := False ;

  If MouseDown_DrawLine Then
  begin
    TempFloat := abs(StartLineX-EndLineX) ;
    Form2.Edit15.Text := FloatToStrf(TempFloat,ffFixed,5,3) ; // Measure edit box value
    Form2.Edit14.Text := Form2.Edit15.Text ; // OffsetX Data value
  end ;  
  MouseDown_DrawLine := False ;

  If Form2.SpeedButton3.Down Then  // draw box around area selected
     begin
       If  (StartLineX < MaxGL(StartLineXO,EndLineXO)) and (StartLineX > MinGL(StartLineXO,EndLineXO)) and (StartLineY <  MaxGL(StartLineYO,EndLineYO)) and (StartLineY > MinGL(StartLineYO,EndLineYO)) Then
         begin
             // Form1.UpdateViewRange () ;  // updates  OrthoVarXMax, OrthoVarXMin, OrthoVarYMax, OrthoVarYMin. Used when XY data is modified
              OrthoVarXMax := MaxGL(StartLineXO,EndLineXO) - EyeX ;
              OrthoVarXMin := MinGl(StartLineXO,EndLineXO) - EyeX ;
              OrthoVarYMax := MaxGL(StartLineYO,EndLineYO) - EyeY ;
              OrthoVarYMin := MinGL(StartLineYO,EndLineYO) - EyeY ;
              If Form2.CheckBox9.Checked Then  // invert x axis
              begin
                 TempFloat :=  OrthoVarXMin ;
                 OrthoVarXMin := OrthoVarXMax ;
                 OrthoVarXMax := TempFloat ;
              end ;
              If Form2.CheckBox5.Checked Then  // invert y axis
              begin
                 TempFloat :=  OrthoVarYMin ;
                 OrthoVarYMin := OrthoVarYMax ;
                 OrthoVarYMax := TempFloat ;
              end ;
              Form2.Edit6.Text := FloatToStrf((OrthoVarXMin+EyeX),ffGeneral,5,6) ;   // update minimum X visible range
              Form2.Edit7.Text := FloatToStrf((OrthoVarXMax+EyeX),ffGeneral,5,6) ;   // update maximum X visible range
              Form2.Edit8.Text := FloatToStrf(OrthoVarYMax,ffFixed,5,3) ;
              Form2.Edit9.Text := FloatToStrf(OrthoVarYMin,ffFixed,5,3) ;
              InitialiseMouseArray ; // dont know if this is needed
              InitialiseStartEndValues ;
              Form1.Resize ;
         end
       else
         begin
         Refresh ;
         end ;
     end ;


  If Form2.SpeedButton2.Down Then  // zoom to correct width
  begin
    If  (StartLineX < MaxGL(StartLineXO,EndLineXO)) and (StartLineX > MinGL(StartLineXO,EndLineXO)) Then
      begin
        OrthoVarXMax := MaxGL(StartlineXO,EndLineXO) - EyeX ;
        OrthoVarXMin := MinGL(StartLineXO,EndLineXO) - EyeX ;
        InitialiseMouseArray ;
        InitialiseStartEndValues ;
        Form1.Resize ;
      end
    else
      Refresh ;
  end ;

  If Form2.SpeedButton6.Down Then  // update integration tab
  begin
    If Not (StartLineX = EndlineX) Then
      begin
        Form2.Edit25.Text := FloatToStrf(MinGL(StartLineX,EndLineX),ffGeneral,6,3)  ;
        Form2.Edit26.Text := FloatToStrf(MaxGL(StartLineX,EndLineX),ffGeneral,6,3)  ;

        tBkgSlp := (StartLineY-EndLineY)/(StartLineX-EndLineX) ;
        tBkgCnst := StartLineY - (tBkgSlp*StartLineX) ;  // const = y - mx

        Form2.Edit27.Text := FloatToStrf(tBkgSlp,ffGeneral,7,4)  ;
        Form2.Edit28.Text := FloatToStrf(tBkgCnst,ffGeneral,6,3)  ;
      end
    else
      begin
        Form2.Edit25.Text := ''  ;
        Form2.Edit26.Text := ''  ;
        tBkgSlp := 0.0 ;
        tBkgCnst := 0.0 ;
        Form2.Edit27.Text := FloatToStrf(tBkgSlp,ffGeneral,7,4)  ;
        Form2.Edit28.Text := FloatToStrf(tBkgCnst,ffGeneral,6,3)  ;
      end ;
  end ;


  If Form2.BaselineCorrSB9.Down Then  // update Baseline tab
  begin
    If Not (StartLineX = EndlineX) Then
      begin
        Form2.Edit24.Text := FloatToStrf(MinGL(StartLineX,EndLineX),ffGeneral,6,3)  ;  // startX
        if MinGL(StartLineX,EndLineX) =  StartLineX then
          Form2.Edit31.Text := FloatToStrf(StartLineY,ffGeneral,6,3)   // startY
        else
          Form2.Edit31.Text := FloatToStrf(EndLineY,ffGeneral,6,3)  ; // startY

        Form2.Edit38.Text := FloatToStrf(MaxGL(StartLineX,EndLineX),ffGeneral,6,3)  ;  // endX
        if MaxGL(StartLineX,EndLineX) =  StartLineX then
          Form2.Edit39.Text := FloatToStrf(StartLineY,ffGeneral,6,3)   // startY
        else
          Form2.Edit39.Text := FloatToStrf(EndLineY,ffGeneral,6,3)  ; // startY
      end
    else
      begin
        Form2.Edit24.Text := ''  ;
        Form2.Edit31.Text := ''  ;
        Form2.Edit38.Text := ''  ;
        Form2.Edit39.Text := ''  ;
      end ;
  end ;

  If Form2.SpeedButton8.Down Then  // update Instrumental Deconvolution tab
  begin
    If Not (StartLineX = EndlineX) Then
      begin
        Form2.Edit36.Text := FloatToStrf(MinGL(StartLineX,EndLineX),ffGeneral,6,3)  ;
        Form2.Edit37.Text := FloatToStrf(MaxGL(StartLineX,EndLineX),ffGeneral,6,3)  ;
        Form2.Label32.Caption := ExtractFileName(TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,Form4.StringGrid1.Selection.Top]).xCoord.filename) ;
        Form2.Label32.Hint := inttostr(Form4.StringGrid1.Selection.Top) ;
      end
    else
      begin
        Form2.Edit36.Text := ''  ;
        Form2.Edit37.Text := ''  ;
      end ;
  end ;

  StartLineXO := StartLineX ;
  StartLineYO := StartLineY ;
  EndLineXO := EndLineX ;
  EndLineYO := EndLineY ;

  InitialiseStartEndValues ;
  InitialiseMouseArray ;
  Refresh ;
end;


procedure TForm1.FormShow(Sender: TObject);
begin
 Form1.Refresh ;
end;


procedure TForm1.FormDragOver(Sender, Source: TObject; X, Y: Integer;
  State: TDragState; var Accept: Boolean);
begin
  If Sender is TDragObject Then Accept := True ;
end;


procedure TForm1.FormActivate(Sender: TObject);
begin
//Set this application to accept files dragged and dropped from Explorer
  DragAcceptFiles(Handle, True);
end;


procedure TForm1.wmDropFiles(var Msg: TWMDropFiles); //message WM_DROPFILES;
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
      Form4.InitializeSpectraData( strList, count) ;  // drag and drop opening  // load each file dropped
    end;
  finally
    Msg.Result := 0;
    DragFinish(Msg.Drop);
   // if SetCurrentDir(ExtractFileDir(strList.Strings[0])) then
    //   messagedlg('new directory is'+ExtractFileDir(strList.Strings[0]) ,mtError,[mbOk],0) ;
    ChDir(ExtractFileDir(strList.Strings[0]))  ;
 //   messagedlg(GetCurrentDir  ,mtinformation,[mbOk],0) ;
    Form4.OpenDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
    Form4.SaveDialog1.InitialDir := ExtractFileDir(strList.Strings[0]) ;
    strList.Free ;
    Form1.Refresh;
  end;
end;


procedure TForm1.Revert1Click(Sender: TObject);
Var
  GridRow :   integer ;
begin
{
    GridRow :=  Form4.StringGrid1.Selection.Top ; // the file i am messing with is in this row of the stringgrid
    if ( UpperCase(ExtractFileExt(Filename)) = '.SPA') then
       LoadSPAFile(TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,GridRow]))
    Else If Form2.RadioButton3.Checked Then    // load x,y data into  TSpectraRanges object
       LoadCommaFile(TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,GridRow]))
    Else If Form2.RadioButton4.Checked Then
       LoadImportInfoFile(TSpectraRanges(Form4.StringGrid1.Objects[Form4.StringGrid1.Col,GridRow])) ;    }
end;



{procedure TForm1.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and not ((ssAlt in Shift) or (ssShift in Shift)) then  // only Ctrl is down
    keyDownV := 1   // Ctrl is down
  else
  if (ssShift in Shift) and not ((ssAlt in Shift) or (ssCtrl in Shift)) then  // only Shift is down
    keyDownV := 2   // Shift is down
  else
  if ((ssCtrl in Shift) and  (ssShift in Shift)) and not (ssAlt in Shift) then  //  Ctrl and Shift are down
    keyDownV := 3   // Ctrl and Shift are down
  else
    keyDownV := 0 ;
end;    }
{
procedure TForm1.FormKeyUp(Sender: TObject; var Key: Word;
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
end;   }

procedure TForm1.Image1Click(Sender: TObject);
begin
  drawDotX := EndLineX ;
  drawDotY := EndLineY ;
//  refresh ;
end;



end.

{   // Light strength
    L0_Ambi[0] := 0.1 ;    // N.B. Directional light => nulify SpotEx and SpotCutOff
    L0_Ambi[1] := 0.1 ;
    L0_Ambi[2] := 0.1 ;
    L0_Ambi[3] := 0.0 ;
    L0_Dif[0] := 0.71 ;
    L0_Dif[1] := 0.71 ;
    L0_Dif[2] := 0.71 ;
    L0_Dif[3] := 1.0 ;
    L0_Spec[0] := 0.81 ;
    L0_Spec[1] := 0.81 ;
    L0_Spec[2] := 0.81 ;
    L0_Spec[3] := 1.0;
    glLightfv(GL_LIGHT0, GL_AMBIENT, @L0_AMBI[0]) ;
    glLightfv(GL_LIGHT0,GL_DIFFUSE, @L0_Dif[0]) ;
    glLightfv(GL_LIGHT0,GL_SPECULAR, @L0_Spec[0]) ;

    // Light position and direction
    L0_POS[0] := 0.0 ;
    L0_POS[1] := 0.0 ;
    L0_POS[2] := 5000.0 ;
    L0_POS[3] := 0.0 ;   // determines if light is directional(0.0) or positional(1.0)
    glLightfv(GL_LIGHT0, GL_POSITION, @L0_POS[0]) ;
    L0_Dir[0] := 0;
    L0_Dir[1] := 0 ;
    L0_Dir[2] := -1 ;
    glLightfv(GL_LIGHT0,GL_SPOT_DIRECTION, @L0_Dir[0]) ;

    LM_Amb[0] := 0.0 ;
    LM_Amb[1] := 0.0;
    LM_Amb[2] := 0.0;
    LM_Amb[3] := 0.0;
    glLightModelfv(GL_LIGHT_MODEL_AMBIENT, @LM_Amb[0]) ;
    glLightModelf(GL_LIGHT_MODEL_LOCAL_VIEWER,1.0) ; // infinite (0.0) or local (1.0) light Model
    glLightModelf(GL_LIGHT_MODEL_TWO_SIDE, 0.0 ) ; // Turns model black when = 1.0 (two sided lighting)

    SpotEx := 15 ;
    SpotCutOff := 180 ;

    glLightf(GL_LIGHT0, GL_SPOT_EXPONENT,SpotEx);
    glLightf(GL_LIGHT0, GL_SPOT_CUTOFF, SpotCutOff) ;
    glLightf(GL_LIGHT0, GL_CONSTANT_ATTENUATION, 0.5);
    glLightf(GL_LIGHT0, GL_LINEAR_ATTENUATION, 0.0);
    glLightf(GL_LIGHT0, GL_QUADRATIC_ATTENUATION, 0.0);


    Mat_Amb[0] := 0.33 ;
    Mat_Amb[1] := 0.22 ;
    Mat_Amb[2] := 0.03 ;
    Mat_Amb[3] := 1.0 ;
    Mat_Dif[0] := 0.78 ;
    Mat_Dif[1] := 0.57;
    Mat_Dif[2] := 0.11;
    Mat_Dif[3] := 1.0  ;
    Mat_Spec[0] := 0.99 ;
    Mat_Spec[1] := 0.94;
    Mat_Spec[2] := 0.81;
    Mat_Spec[3] := 1.0 ;
    Mat_Emi[0] := 0.00 ;
    Mat_Emi[1] := 0.00;
    Mat_Emi[2] := 0.00;
    Mat_Emi[3] := 0.00 ;// StrToFloat(form3.Edit19.Text);
    Shine      := 28.0 ;

    glMaterialfv(GL_FRONT,GL_AMBIENT, @Mat_Amb[0]) ;
    glMaterialfv(GL_FRONT,GL_DIFFUSE, @Mat_DIf[0]) ;
    glMaterialfv(GL_FRONT,GL_SPECULAR,@Mat_Spec[0]) ;
    glMaterialfv(GL_FRONT,GL_Emission,@Mat_Emi[0]) ;
    glMaterialfv(GL_FRONT, GL_SHININESS,@Shine);


    glShadeModel(GL_Smooth)  ; // GL_Flat
    glPolygonMode(GL_FRONT_AND_BACK,GL_FILL) ;  // GL_FRONT
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
    glFrontFace(GL_CCW) ;
                               }

