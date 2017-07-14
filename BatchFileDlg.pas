unit BatchFileDlg;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

type
  TBatchFileModDlg = class(TForm)
    Edit1: TEdit;
    Label1: TLabel;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Edit1DblClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  BatchFileModDlg: TBatchFileModDlg;

implementation

Uses BatchEdit ;
{$R *.DFM}

procedure TBatchFileModDlg.Button1Click(Sender: TObject);
var
  t1 : integer ;
  tStrList : TStringList ;
  tstr1, searchStr, replaceStr : string ;
begin
//  BatchFileModDlg.Visible := false ;

  tStrList := TStringList.Create ;

  tStrList.AddStrings(Form3.BatchMemo1.Lines) ;
  Form3.BatchMemo1.Lines.Clear ;

  tstr1 := BatchFileModDlg.Label1.Caption ;

  searchStr := lowerCase(trim(copy(tstr1,1,pos('=',tstr1)-1)))  ;
  replaceStr :=  searchStr + ' = ' + Edit1.Text ;

  t1 := 0 ;
  while t1 <  tStrList.Count-1 do
  begin
    tstr1 := tStrList.Strings[t1] ;
    if lowerCase(trim(copy(tstr1,1,pos('=',tstr1)-1))) = searchStr then
     tStrList.Strings[t1] :=  replaceStr ;
    inc(t1) ;
  end ;

  if searchStr = 'pcs to fit' then    // needed for PCA and PCR - standard replace replaces 'pcs to fit'
  begin
    searchStr := 'number of pcs' ;
    replaceStr :=  searchStr + ' = ' + Edit1.Text ;

    t1 := 0 ;
    while t1 <  tStrList.Count-1 do
    begin
      tstr1 := tStrList.Strings[t1] ;
      if lowerCase(trim(copy(tstr1,1,pos('=',tstr1)-1))) = searchStr then
       tStrList.Strings[t1] :=  replaceStr ;
      inc(t1) ;
    end ;

  end ;



  Form3.BatchMemo1.Lines.AddStrings(tStrList) ;
  tStrList.Free ;
end;

procedure TBatchFileModDlg.Edit1DblClick(Sender: TObject);
begin
  if lowercase(edit1.Text) = 'true' then
    edit1.Text := 'false'
  else
  if lowercase(edit1.Text) = 'false' then
    edit1.Text := 'true' ;

end;

end.
