{*******************************************************************************

 * qrencode - QR Code encoder
 *
 * QR Code encoding tool
 * This code is taken from Kentaro Fukuchi's qrenc.c
 * then editted and packed into a .pas file.
 * Copyright (C) 2006-2011 Kentaro Fukuchi <kentaro@fukuchi.org>
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
      2014-04-14  update from qrencode-3.4.3

*******************************************************************************}

unit qrenc;

{$IFDEF FPC}
  {$MODE Delphi}
{$ENDIF}

interface

uses
  LCLIntf, LCLType, LMessages, SysUtils, struct, strings, cwstring, Graphics;

procedure qr(const AStr: WideString; AOut: ansistring;
  AMargin, ASize, AEightBit, ACasesens, AStructured, ALevel, ACode: integer;
  AFore, ABack: TColor);

implementation

uses
  qrencode;

const
  MAX_DATA_SIZE = 7090 * 16;

type
  imageType = (
    BMP_TYPE
    );

var
  casesensitive: integer = 1;
  eightbit: integer = 0;
  version: integer = 0;
  size: integer = 3;
  margin: integer = -1;
  dpi: integer = 72;
  structured: integer = 0;
  rle: integer = 0;
  micro: integer = 0;
  level: QRecLevel = QR_ECLEVEL_L;
  hint: QRencodeMode = QR_MODE_8;
  fg_color: array[0..3] of byte = (0, 0, 0, 255);
  bg_color: array[0..3] of byte = (255, 255, 255, 255);

  image_type: imageType = BMP_TYPE;

function writeBMP(qrcode: PQRcode; const outfile: PAnsiChar): integer;
var
  bmp: TBitmap;
  realwidth, x, xx, y, yy: integer;
  p: PByte;
  pix, pixNew: PRGBTriple;
begin
  realwidth := (qrcode.Width + margin * 2) * size;
  bmp := TBitmap.Create;
  try
    bmp.PixelFormat := pf24bit;
    bmp.Width := realwidth;
    bmp.Height := realwidth;
    //ÉèÖÃ±³¾°É«£¨Õû¸öÍ¼Æ¬È«²¿ÉèÖÃ³É±³¾°É«£¬È»ºóÉèÖÃÐèÒª¸Ä±äµÄÏñËØÎªÇ°¾°É«£©¿ªÊ¼£¬
    //ÉèÖÃµÚÒ»ÐÐµÄÑÕÉ«
    pix := bmp.ScanLine[0];
    for x := 0 to realwidth - 1 do
    begin
      pix^.rgbtRed := bg_color[0];
      pix^.rgbtGreen := bg_color[1];
      pix^.rgbtBlue := bg_color[2];
      Inc(pix);
    end;
    //ºóÃæÐÐµÄÊý¾Ý¸´ÖÆµÚÒ»ÐÐ
    pix := bmp.ScanLine[0];
    for y := 1 to realwidth - 1 do
    begin
      pixNew := bmp.ScanLine[y];
      Move(pix, pixNew, SizeOf(TRGBTriple) * realwidth);
    end;
    //ÉèÖÃ±³¾°É«½áÊø

    //ÉèÖÃÐèÒª¸Ä±äµÄÏñËØÎªÇ°¾°É«
    for y := 0 to qrcode.Width - 1 do
    begin
      p := PIndex(qrcode.Data, y * qrcode.Width);
      //µ±Ç°ÐèÒª²âÊÔµÄÊý¾Ý
      pix := bmp.ScanLine[(y + margin) * size];
      //µ±Ç°ÐèÒª¸Ä±äÑÕÉ«µÄÏñËØ
      Inc(pix, margin * size);                      //Ìø¹ýÃ¿ÐÐµÄmargin
      for x := 0 to qrcode.Width - 1 do
      begin
        if (p^ and 1) <> 0 then   //ÐèÒª¸Ä±äµÄÏñËØ
        begin
          for xx := 0 to size - 1 do  //ÖØ¸´size´óÐ¡µÄÇ°¾°É«
          begin
            pix^.rgbtRed := fg_color[0];
            pix^.rgbtGreen := fg_color[1];
            pix^.rgbtBlue := fg_color[2];
            Inc(pix);
          end;
        end
        else  //Ìø¹ý²»ÐèÒª¸Ä±äµÄÏñËØ
          Inc(pix, size);
        Inc(p);
      end;
      //×Ü¹²sizeÐÐ£¬ÆäËüÐÐµÄÊý¾Ý¸´ÖÆµ±Ç°ÐÐ
      pix := bmp.ScanLine[(y + margin) * size];
      for yy := 1 to size - 1 do
      begin
        pixNew := bmp.ScanLine[(y + margin) * size + yy];
        Move(pix, pixNew, SizeOf(TRGBTriple) * realwidth);
      end;
    end;

    bmp.SaveToFile(string(StrPas(outfile)));
    Result := 0;
  finally
    FreeAndNil(bmp);
  end;
end;

function encode(const intext: PByte; length: integer): PQRcode;
var
  code: PQRcode;
begin
  if micro <> 0 then
  begin
    if eightbit <> 0 then
    begin
      code := QRcode_encodeDataMQR(length, intext, version, level);
    end
    else
    begin
      code := QRcode_encodeStringMQR(PAnsiChar(intext), version, level,
        hint, casesensitive);
    end;
  end
  else
  begin
    if eightbit <> 0 then
    begin
      code := QRcode_encodeData(length, intext, version, level);
    end
    else
    begin
      code := QRcode_encodeString(PAnsiChar(intext), version, level,
        hint, casesensitive);
    end;
  end;

  Result := code;
end;

procedure qrcode(const intext: PByte; length: integer; const outfile: PAnsiChar);
var
  qrcode: PQRcode;
begin
  qrcode := encode(intext, length);
  if qrcode = nil then
  begin
    Abort;
  end;
  try
    case (image_type) of
      BMP_TYPE: writeBMP(qrcode, outfile);
      else
      begin
        QRcode_free(qrcode);
        Abort;
      end;
    end;
  finally
    QRcode_free(qrcode);
  end;
end;

function encodeStructured(const intext: PByte; length: integer): PQRcode_List;
var
  list: PQRcode_List;
begin
  if eightbit <> 0 then
  begin
    list := QRcode_encodeDataStructured(length, intext, version, level);
  end
  else
  begin
    list := QRcode_encodeStringStructured(PAnsiChar(intext), version,
      level, hint, casesensitive);
  end;

  Result := list;
end;

procedure qrencodeStructured(const intext: PByte; length: integer;
  const outfile: PAnsiChar);
var
  qrlist, p: PQRcode_List;
  filename: PAnsiChar;
  base, q, suffix: PAnsiChar;
  type_suffix: PAnsiChar;
  i: integer;
  suffix_size: integer;
begin
  suffix := nil;
  type_suffix := nil;
  i := 1;
  case image_type of
    BMP_TYPE: type_suffix := '.bmp';
    else
    begin
      Abort;
    end;
  end;

  if outfile = nil then
  begin
    Abort;
  end;
  base := strdup(outfile);
  if base = nil then
  begin
    Abort;
  end;
  suffix_size := strlen(type_suffix);
  if strlen(base) > suffix_size then
  begin
    q := base + strlen(base) - suffix_size;
    if stricomp(type_suffix, q) = 0 then
    begin
      suffix := strdup(q);
      q^ := #0;
    end;
  end;

  qrlist := encodeStructured(intext, length);
  if qrlist = nil then
  begin
    Abort;
  end;

  p := qrlist;
  try
    while p <> nil do
    begin
      if p.code = nil then
      begin
        Abort;
      end;
      if suffix <> nil then
      begin
        filename := PAnsiChar(ansistring(Format('%s-%.2d%s', [base, i, suffix])));
      end
      else
      begin
        filename := PAnsiChar(ansistring(Format('%s-%.2d', [base, i])));
      end;
      case image_type of
        BMP_TYPE: writeBMP(p.code, filename);
        else
        begin
          Abort;
        end;
      end;
      Inc(i);
      p := p.Next;
    end;
  finally
    FreeMem(base);
    if suffix <> nil then
      FreeMem(suffix);
    QRcode_List_free(qrlist);
  end;
end;

procedure qrencode(const AStr: PByte; ALen: integer; AOut: ansistring;
  AMargin, ASize, AEightBit, ACasesens, AStructured, ALevel: integer;
  AFore, ABack: TColor);
begin
  version := 1;
  margin := AMargin;
  size := ASize;
  eightbit := AEightBit;
  casesensitive := casesensitive;
  structured := AStructured;
  level := QRecLevel(ALevel);
  fg_color[0] := AFore and $FF;
  fg_color[1] := (AFore and $FF00) shr 8;
  fg_color[2] := (AFore and $FF0000) shr 16;
  bg_color[0] := ABack and $FF;
  bg_color[1] := (ABack and $FF00) shr 8;
  bg_color[2] := (ABack and $FF0000) shr 16;
  image_type := BMP_TYPE;

  if structured = 1 then
    qrencodeStructured(AStr, ALen, PAnsiChar(AOut))
  else
    qrcode(AStr, ALen, PAnsiChar(AOut));
end;

function LocaleToWide(const AStr: ansistring): WideString;
var
  nLen: integer;
begin
  Result := AStr;
  // TODO: Take another look at this
{  if Result <> '' then
  begin
    nLen := MultiByteToWideChar(CP_ACP, 1, PAnsiChar(AStr), -1, nil, 0);
    SetLength(Result, nLen - 1);
    if nLen > 1 then
      MultiByteToWideChar(CP_ACP, 1, PAnsiChar(AStr), -1, PWideChar(Result),
        nLen - 1);
  end;}
end;

function WideToAnsi(const AStr: WideString; ACode: cardinal = 936): ansistring;
var
  nLen: integer;
begin
  Result := AStr;
  // TODO: Take another look at this
{  if Result <> '' then
  begin
    nLen := WideCharToMultiByte(ACode, 0, PWideChar(AStr),
      lstrlenW(PWideChar(AStr)), PAnsiChar(Result), 0, nil, nil);
    SetLength(Result, nLen - 1);
    if nLen > 1 then
      WideCharToMultiByte(ACode, 0, PWideChar(AStr),
        lstrlenW(PWideChar(AStr)), PAnsiChar(Result), nLen, nil, nil);
  end;}
end;

procedure qr(const AStr: WideString; AOut: ansistring;
  AMargin, ASize, AEightBit, ACasesens, AStructured, ALevel, ACode: integer;
  AFore, ABack: TColor);
var
  sCode: ansistring;
  pw: PWideChar;
  pb: PByte;
  iLen: integer;
begin
  try
    GetMem(pb, MAX_DATA_SIZE);
  except
    Abort;
  end;
  try
    FillByte(pb, MAX_DATA_SIZE, 0);
(*    if ACode = 0 then
    begin
//      pw := PWideChar(LocaleToWide(AStr));
//      sCode := WideToAnsi(LocaleToWide(AStr));
      pw := PWideChar(AStr);
      iLen := WideCharToMultiByte(CP_UTF8, 0, pw, lstrlenW(pw), PAnsiChar(pb),
        MAX_DATA_SIZE, nil, nil);
    end else begin
    iLen := Length(AStr);
    Move(PAnsiChar(AStr), pb, iLen);
        end; *)
    if ACode = 0 then
    begin
      pb := PByte(AnsiToUtf8(AStr));
      iLen := Length(AnsiToUtf8(AStr));
    end;
    qrencode(pb, iLen, AOut, AMargin, ASize, AEightBit,
      ACasesens, AStructured, ALevel, AFore, ABack);
  finally
    FreeMem(pb);
  end;
end;

end.
