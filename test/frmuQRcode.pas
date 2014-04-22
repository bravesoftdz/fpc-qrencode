{*******************************************************************************

    Author: [$]+                                    
    QQ: 270965332
    Homepage: http://www.hicpp.com
                                                               
    revision history
      2014-04-21

*******************************************************************************}

unit frmuQRcode;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls {$IF CompilerVersion>=23.0},System.UITypes{$IFEND};

type
  TfrmQRcode = class(TForm)
    btnGen: TButton;
    mmoContent: TMemo;
    edtMargin: TEdit;
    lbl1: TLabel;
    edtSize: TEdit;
    lbl2: TLabel;
    lbl3: TLabel;
    cbbLevel: TComboBox;
    lbl4: TLabel;
    cbbCasesens: TComboBox;
    lbl5: TLabel;
    cbbStructured: TComboBox;
    lbl6: TLabel;
    cbbEightBit: TComboBox;
    lbl7: TLabel;
    lbl8: TLabel;
    clrbxFore: TColorBox;
    clrbxBack: TColorBox;
    edtOutput: TEdit;
    lbl9: TLabel;
    procedure btnGenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmQRcode: TfrmQRcode;

implementation

{$R *.dfm}
{$R WindowsXP}

uses
  qrenc;

procedure TfrmQRcode.btnGenClick(Sender: TObject);
begin
  try
    qr(
      AnsiString(StringReplace(mmoContent.Text, #13#10, '', [rfReplaceAll])),
      AnsiString(edtOutput.Text),
      StrtoIntDef(edtMargin.Text, 2),
      StrToIntDef(edtSize.Text, 3),
      cbbEightBit.ItemIndex,
      cbbCasesens.ItemIndex,
      cbbStructured.ItemIndex,
      cbbLevel.ItemIndex,
      clrbxFore.Selected,
      clrbxBack.Selected
    );
    MessageDlg('生成成功！', mtInformation, [mbOK], -1);
  except
    MessageDlg('生成失败！', mtInformation, [mbOK], -1);
  end;
end;

procedure TfrmQRcode.FormCreate(Sender: TObject);
begin
  mmoContent.Text := '';
  edtOutput.Text := ExtractFilePath(ParamStr(0)) + '1.bmp';
  clrbxFore.Selected := clBlack;
  clrbxBack.Selected := clWhite;
  cbbStructured.ItemIndex := 0;
  cbbLevel.ItemIndex := 0;
  cbbCasesens.ItemIndex := 1;
  cbbEightBit.ItemIndex := 0;
end;

end.
