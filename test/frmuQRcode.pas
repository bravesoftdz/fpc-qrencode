{*******************************************************************************

 *
 * Copyright (C) 2014 Hao Shi <admin@hicpp.com> 
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public
 * License along with this library; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301 USA
                                                               
    revision history
      2014-04-21

*******************************************************************************}

unit frmuQRcode;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
{$IFnDEF FPC}
  Windows,
{$ELSE}
  LCLIntf, LCLType, LMessages,
{$ENDIF}
  Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls, ColorBox;

type

  { TfrmQRcode }

  TfrmQRcode = class(TForm)
    btnGen: TButton;
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
    lbl9: TLabel;
    lbl10: TLabel;
    cbbCode: TComboBox;
    edtOutput: TEdit;
    edtInput: TMemo;
    procedure btnGenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmQRcode: TfrmQRcode;

implementation

{$IFnDEF FPC}
  {$R *.dfm}
{$ELSE}
  {$R *.lfm}
{$ENDIF}

uses
  qrenc;

const
  ID_EDIT = 10001;
  ID_OUTPUT = 10002;

procedure TfrmQRcode.btnGenClick(Sender: TObject);
begin
  try
    qr(
      AnsiString(edtInput.Text),
      AnsiString(edtOutput.Text),
      StrtoIntDef(edtMargin.Text, 2),
      StrToIntDef(edtSize.Text, 3),
      cbbEightBit.ItemIndex,
      cbbCasesens.ItemIndex,
      cbbStructured.ItemIndex,
      cbbLevel.ItemIndex,
      cbbCode.ItemIndex,
      clrbxFore.Selected,
      clrbxBack.Selected
    );
    MessageDlg('Éú³É³É¹¦£¡', mtInformation, [mbOK], -1);
  except
    MessageDlg('Éú³ÉÊ§°Ü£¡', mtInformation, [mbOK], -1);
  end;
end;

procedure TfrmQRcode.FormCreate(Sender: TObject);
begin
  clrbxFore.Selected := clBlack;
  clrbxBack.Selected := clWhite;
  cbbStructured.ItemIndex := 0;
  cbbLevel.ItemIndex := 0;
  cbbCasesens.ItemIndex := 1;
  cbbEightBit.ItemIndex := 0;
  cbbCode.ItemIndex := 0;
end;

procedure TfrmQRcode.FormDestroy(Sender: TObject);
begin

end;

end.
