unit Colorsemission;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, ExtCtrls;

type
  TForm3 = class(TForm)
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Edit1: TEdit;
    Label2: TLabel;
    Edit2: TEdit;
    Label3: TLabel;
    Edit3: TEdit;
    Button2: TButton;
    GroupBox2: TGroupBox;
    RadioButton1: TRadioButton;
    RadioButton2: TRadioButton;
    RadioButton3: TRadioButton;
    RadioButton4: TRadioButton;
    RadioButton5: TRadioButton;
    RadioButton6: TRadioButton;
    RadioButton7: TRadioButton;
    RadioButton8: TRadioButton;
    GroupBox3: TGroupBox;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Edit4: TEdit;
    Edit5: TEdit;
    Edit6: TEdit;
    Edit7: TEdit;
    Edit8: TEdit;
    Edit9: TEdit;
    Edit10: TEdit;
    Edit11: TEdit;
    Edit12: TEdit;
    Edit13: TEdit;
    Edit14: TEdit;
    Edit15: TEdit;
    Edit16: TEdit;
    Edit17: TEdit;
    Edit18: TEdit;
    Edit19: TEdit;
    Edit20: TEdit;
    RadioButton9: TRadioButton;
    RadioButton10: TRadioButton;
    Label9: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label12: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
{    procedure RadioButton1Click(Sender: TObject);
    procedure RadioButton2Click(Sender: TObject);
    procedure RadioButton3Click(Sender: TObject);
    procedure RadioButton4Click(Sender: TObject);
    procedure RadioButton5Click(Sender: TObject);
    procedure RadioButton6Click(Sender: TObject);
    procedure RadioButton7Click(Sender: TObject);
    procedure RadioButton8Click(Sender: TObject);
    procedure RadioButton9Click(Sender: TObject);   }
    procedure Edit4MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure GroupBox3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit4MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Edit4MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit5MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit6MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit7MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit8MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit9MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit10MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit11MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit12MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit13MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit14MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit15MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit16MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit17MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit18MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit19MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit20MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
//    procedure RadioButton10Click(Sender: TObject);
    procedure Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit2MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit3MouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure Edit1MouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormActivate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form3: TForm3;
  MouseDownMat : Bool ;
  Mat_Xdown, Mat_Ydown : Single ;
implementation

uses  emissionGL;   
{$R *.DFM}





procedure TForm3.FormCreate(Sender: TObject);
Var
 TempList : TStrings ;
begin
  HomeDir := GetCurrentDir ;
  TempList := TStringList.Create ;
  try
   With TempList Do
    Try
      LoadFromFile(HomeDir+ '\initial.ini') ;
    Except
      on EFOpenError Do
    end ;
{$I-}
  ChDir(TempList.Strings[0]);   //change to directory where last file was opened
  if IOResult <> 0 then
      ChDir(HomeDir);    //if directory not exist then change to program directory
{$I+}
    Edit1.Text := TempList.Strings[1] ;
    Edit2.Text := TempList.Strings[2] ;
    Edit3.Text := TempList.Strings[3] ;

    BKGRed   :=  StrToFloat(Edit1.Text)  ;
    BKGGreen :=  StrToFloat(Edit2.Text)   ;
    BKGBlue  :=  StrToFloat(Edit3.Text)   ;

  Finally
    TempList.Free ;
  end ;
end;

procedure TForm3.Button2Click(Sender: TObject);
begin
Form3.Visible := False ;                                                              
end;

{procedure TForm3.RadioButton1Click(Sender: TObject);     //Gold
begin
Edit4.Text := '0.33'  ;Edit5.Text := '0.22' ;Edit6.Text := '0.03' ;Edit7.Text := '1.00' ;
Edit8.Text := '0.78'   ;Edit9.Text := '0.57' ;Edit10.Text := '0.11' ;Edit11.Text := '1.00' ;
Edit12.Text :='0.99'   ;Edit13.Text := '0.94' ;Edit14.Text := '0.81' ;Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ;Edit19.Text := '0.00' ;
Edit20.Text := '28'  ;
Form3.Refresh ;
Form1.

end ;

procedure TForm3.RadioButton2Click(Sender: TObject);    //Bronze
begin
Edit4.Text := '0.25'  ;Edit5.Text := '0.15' ;Edit6.Text := '0.06' ;Edit7.Text := '1.00' ;
Edit8.Text := '0.40'   ;Edit9.Text := '0.24' ;Edit10.Text := '0.10' ;Edit11.Text := '1.00' ;
Edit12.Text :='0.77'   ;Edit13.Text := '0.46' ;Edit14.Text := '0.20' ;Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ;Edit19.Text := '0.00' ;
Edit20.Text := '77'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton3Click(Sender: TObject); //Chrome
begin
Edit4.Text := '0.25'  ;Edit5.Text := '0.25' ;Edit6.Text := '0.25' ;Edit7.Text := '1.00' ;
Edit8.Text := '0.40'   ;Edit9.Text := '0.40' ;Edit10.Text := '0.40' ;Edit11.Text := '1.00' ;
Edit12.Text :='0.77'   ;Edit13.Text := '0.77' ;Edit14.Text := '0.77' ;Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ;Edit19.Text := '0.00' ;
Edit20.Text := '77'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton4Click(Sender: TObject);   //Copper
begin
Edit4.Text := '0.23'  ; Edit5.Text := '0.09' ;Edit6.Text := '0.03' ;Edit7.Text := '1.00' ;
Edit8.Text := '0.55'   ;Edit9.Text := '0.21' ;Edit10.Text := '0.07' ;Edit11.Text := '1.00' ;
Edit12.Text :='0.58'   ;Edit13.Text := '0.22' ;Edit14.Text := '0.07' ;Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ;Edit19.Text := '0.00' ;
Edit20.Text := '51'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton5Click(Sender: TObject); //Black Plastic
begin
Edit4.Text := '0.00'  ;Edit5.Text := '0.00' ;  Edit6.Text  := '0.00' ; Edit7.Text := '1.0' ;
Edit8.Text := '0.01'   ;Edit9.Text := '0.01' ; Edit10.Text := '0.01' ; Edit11.Text := '1.00' ;
Edit12.Text :='0.50'   ;Edit13.Text := '0.50' ;Edit14.Text := '0.50' ; Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ; Edit19.Text := '0.00' ;
Edit20.Text := '32'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton6Click(Sender: TObject); //Emerald
begin
Edit4.Text := '0.02'  ;Edit5.Text := '0.17'   ;Edit6.Text  := '0.02' ; Edit7.Text := '0.55'  ;
Edit8.Text := '0.08'   ;Edit9.Text := '0.61'  ;Edit10.Text := '0.08' ; Edit11.Text := '0.55' ;
Edit12.Text :='0.63'   ;Edit13.Text := '0.73' ;Edit14.Text := '0.63' ; Edit15.Text := '0.55' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00'; Edit19.Text := '0.00'  ;
Edit20.Text := '77' ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton7Click(Sender: TObject); //Ruby
begin
Edit4.Text := '0.17' ;Edit5.Text := '0.01' ;Edit6.Text := '0.01' ;Edit7.Text := '0.55' ;
Edit8.Text := '0.61'  ;Edit9.Text := '0.04'; Edit10.Text := '0.04' ;Edit11.Text := '0.55' ;
Edit12.Text :='0.73'  ;Edit13.Text := '0.63';Edit14.Text := '0.63' ;Edit15.Text := '0.55' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ;Edit19.Text := '0.00' ;
Edit20.Text := '77'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton8Click(Sender: TObject);  //Pearl
begin
Edit4.Text := '0.25'   ;Edit5.Text := '0.21' ; Edit6.Text  := '0.21' ; Edit7.Text  := '0.92' ;
Edit8.Text := '1.00'   ;Edit9.Text := '0.83' ; Edit10.Text := '0.83' ; Edit11.Text := '0.92' ;
Edit12.Text :='0.30'   ;Edit13.Text := '0.30' ;Edit14.Text := '0.30' ; Edit15.Text := '0.92' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ; Edit19.Text := '0.00' ;
Edit20.Text := '11'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;

procedure TForm3.RadioButton9Click(Sender: TObject);  //Pewter
begin
Edit4.Text := '0.11'   ;Edit5.Text := '0.06' ; Edit6.Text  := '0.11' ; Edit7.Text := '1.0' ;
Edit8.Text := '0.43'   ;Edit9.Text := '0.47' ; Edit10.Text := '0.54' ; Edit11.Text := '1.00' ;
Edit12.Text :='0.33'   ;Edit13.Text := '0.33' ;Edit14.Text := '0.52' ; Edit15.Text := '1.00' ;
Edit16.Text := '0.00'  ;Edit17.Text := '0.00' ;Edit18.Text := '0.00' ; Edit19.Text := '0.00' ;
Edit20.Text := '10'  ;
Form3.Refresh ;
MainForm.ReInitialize(Sender) ;
end;                                             }




procedure TForm3.Edit4MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
Screen.Cursor := crSizeNS ;
MouseDownMat := True ;
end;

procedure TForm3.GroupBox3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
begin
Screen.Cursor := crDefault ;
end;

procedure TForm3.Edit4MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MouseDownMat := False ;
//RadioButton10.OnClick(Sender) ;
//RadioButton10.Checked := True ;
end;

procedure TForm3.Edit4MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit4.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit4.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;     


end;

procedure TForm3.Edit5MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit5.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit5.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;     

end;

procedure TForm3.Edit6MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit6.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit6.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;
end;

procedure TForm3.Edit7MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit7.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit7.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit8MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit8.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit8.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit9MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit9.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit9.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;     

end;

procedure TForm3.Edit10MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit10.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit10.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit11MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit11.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit11.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit12MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit12.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit12.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit13MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit13.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit13.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit14MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit14.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit14.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit15MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit15.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit15.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit16MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit16.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit16.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit17MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit17.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit17.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit18MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit18.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit18.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit19MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit19.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit19.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit20MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit20.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=128.0)  Then
      begin
        TempFloat := TempFloat + (0.1*(Mat_Ydown-Y)) ;
        If TempFloat > 128.00000 Then TempFloat := 128.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit20.Text := FloatToStrf(TempFloat,ffFixed,3,0) ;
      end ;
   end ;

end;

{procedure TForm3.RadioButton10Click(Sender: TObject);
begin
Form3.Refresh ;
//MainForm.ReInitialize(Sender) ;
end;          }

procedure TForm3.Edit1MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit1.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit1.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;
end;

procedure TForm3.Edit2MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit2.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit2.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit3MouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
Var
  TempFloat : Single ;
begin
If MouseDownMat Then
  begin
    TempFloat := StrToFloat(Edit3.Text) ;
    If (TempFloat >= 0.0) and (TempFloat <=1.0)  Then
      begin
        TempFloat := TempFloat + (0.0001*(Mat_Ydown-Y)) ;
        If TempFloat > 1.00000 Then TempFloat := 1.0000 ;
        If TempFloat < 0.000 Then TempFloat := 0.000 ;
        Edit3.Text := FloatToStrf(TempFloat,ffFixed,2,2) ;
      end ;
   end ;

end;

procedure TForm3.Edit1MouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
MouseDownMat := False ;
BKGRed   :=  StrToFloat(Edit1.Text)  ;
BKGGreen :=  StrToFloat(Edit2.Text)   ;
BKGBlue  :=  StrToFloat(Edit3.Text)   ;
  XPos := 0 ;
  YPos := 0 ;
  XDown := 0 ;
  YDown := 0 ;
Form1.Refresh ;
end;

procedure TForm3.FormActivate(Sender: TObject);
begin
Form3.Left := Form1.Left+Form1.Width ;
Form3.Top := Form1.Top + 23 ;
{Form1.Left := MainForm.Left+MainForm.Width ;
Form1.Top := MainForm.Top  ;  }
end;

end.
