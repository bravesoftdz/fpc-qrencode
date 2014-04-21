unit qrenc;

interface

uses
  Windows, SysUtils, struct, Graphics;

procedure qrencodeStructured(const intext: PByte; length: Integer;
  const outfile: PAnsiChar);

procedure qrcode(const intext: PByte; length: Integer; const outfile: PAnsiChar);

procedure qr(str: string);

implementation

uses
  qrencode;

const
  INCHES_PER_METER = 100.0 / 2.54;
  optstring = 'ho:l:s:v:m:d:t:Skci8MV';
  MAX_DATA_SIZE = 7090 * 16; {* from the specification *}

type
  imageType = (
    BMP_TYPE,
    PNG_TYPE,
    EPS_TYPE,
    SVG_TYPE,
    ANSI_TYPE,
    ANSI256_TYPE,
    ASCII_TYPE,
    ASCIIi_TYPE,
    UTF8_TYPE,
    ANSIUTF8_TYPE
  );

var
//  hInput: THandle;
//  hOutput: THandle;
//  hError: THandle;

  casesensitive: Integer = 1;
  eightbit: Integer = 0;
  version: Integer = 0;
  size: Integer = 3;
  margin: Integer = -1;
  dpi: Integer = 72;
  structured: Integer = 0;
  rle: Integer = 0;
  micro: Integer = 0;
  level: QRecLevel = QR_ECLEVEL_L;
  hint: QRencodeMode = QR_MODE_8;
  fg_color: array[0..3] of Cardinal = (0, 0, 0, 255);
  bg_color: array[0..3] of Cardinal = (255, 255, 255, 255);

  image_type: imageType = UTF8_TYPE;

//  options: array[0..18] of option = (
//    (name: 'help'; has_arg: no_argument; flag: nil; val: Ord('h')),
//    (name: 'output'; has_arg: required_argument; flag: nil; val: Ord('o')),
//    (name: 'level'; has_arg: required_argument; flag: nil; val: Ord('l')),
//    (name: 'size'; has_arg: required_argument; flag: nil; val: Ord('s')),
//    (name: 'symversion'; has_arg: required_argument; flag: nil; val: Ord('v')),
//    (name: 'margin'; has_arg: required_argument; flag: nil; val: Ord('m')),
//    (name: 'dpi'; has_arg: required_argument; flag: nil; val: Ord('d')),
//    (name: 'type'; has_arg: required_argument; flag: nil; val: Ord('t')),
//    (name: 'structured'; has_arg: no_argument; flag: nil; val: Ord('S')),
//    (name: 'kanji'; has_arg: no_argument; flag: nil; val: Ord('k')),
//    (name: 'casesensitive'; has_arg: no_argument; flag: nil; val: Ord('c')),
//    (name: 'ignorecase'; has_arg: no_argument; flag: nil; val: Ord('i')),
//    (name: '8bit'; has_arg: no_argument; flag: nil; val: Ord('8')),
//    (name: 'rle'; has_arg: no_argument; flag: @rle; val: 1),
//    (name: 'micro'; has_arg: no_argument; flag: nil; val: Ord('M')),
//    (name: 'foreground'; has_arg: required_argument; flag: nil; val: Ord('f')),
//    (name: 'background'; has_arg: required_argument; flag: nil; val: Ord('b')),
//    (name: 'version'; has_arg: no_argument; flag: nil; val: Ord('V')),
//    (name: nil; has_arg: 0; flag: nil; val: 0)
//  );

//procedure usage(help, longopt: Integer);
//begin
//  wsprintf('qrencode version %s' + #13#10
//    + 'Copyright (C) 2006-2012 Kentaro Fukuchi' + #13#10,
//    QRcode_APIVersionString());
////	fprintf(stderr,
////"qrencode version %s\n"
////"Copyright (C) 2006-2012 Kentaro Fukuchi\n", QRcode_APIVersionString());
//	if help <> 0 then
//  begin
//		if longopt <> 0 then
//    begin
//			Writeln(
//'Usage: qrencode [OPTION]... [STRING]' + #13#10
//+ 'Encode input data in a QR Code and save as a PNG or EPS image.' + #13#10#13#10
//+ '  -h, --help   display the help message. -h displays only the help of short' + #13#10
//+ '               options.' + #13#10#13#10
//+ '  -o FILENAME, --output=FILENAME' + #13#10
//+ '               write image to FILENAME. If ''-'' is specified, the result' + #13#10
//+ '               will be output to standard output. If -S is given, structured' + #13#10
//+ '               symbols are written to FILENAME-01.png, FILENAME-02.png, ...' + #13#10
//+ '               (suffix is removed from FILENAME, if specified)' + #13#10
//+ '  -s NUMBER, --size=NUMBER' + #13#10
//+ '               specify module size in dots (pixels). (default=3)' + #13#10#13#10
//+ '  -l {LMQH}, --level={LMQH}' + #13#10
//+ '               specify error correction level from L (lowest) to H (highest).' + #13#10
//+ '               (default=L)' + #13#10#13#10
//+ '  -v NUMBER, --symversion=NUMBER' + #13#10
//+ '               specify the version of the symbol. (default=auto)' + #13#10#13#10
//+ '  -m NUMBER, --margin=NUMBER' + #13#10
//+ '               specify the width of the margins. (default=4 (2 for Micro)))' + #13#10#13#10
//+ '  -d NUMBER, --dpi=NUMBER' + #13#10
//+ '               specify the DPI of the generated PNG. (default=72)' + #13#10#13#10
//+ '  -t {PNG,EPS,SVG,ANSI,ANSI256,ASCII,ASCIIi,UTF8,ANSIUTF8}, --type={PNG,EPS,' + #13#10
//+ '               SVG,ANSI,ANSI256,ASCII,ASCIIi,UTF8,ANSIUTF8}' + #13#10
//+ '               specify the type of the generated image. (default=PNG)' + #13#10#13#10
//+ '  -S, --structured' + #13#10
//+ '               make structured symbols. Version must be specified.' + #13#10#13#10
//+ '  -k, --kanji  assume that the input text contains kanji (shift-jis).' + #13#10#13#10
//+ '  -c, --casesensitive' + #13#10
//+ '               encode lower-case alphabet characters in 8-bit mode. (default)' + #13#10#13#10
//+ '  -i, --ignorecase' + #13#10
//+ '               ignore case distinctions and use only upper-case characters.' + #13#10#13#10
//+ '  -8, --8bit   encode entire data in 8-bit mode. -k, -c and -i will be ignored.' + #13#10#13#10
//+ '      --rle    enable run-length encoding for SVG.' + #13#10#13#10
//+ '  -M, --micro  encode in a Micro QR Code. (experimental)' + #13#10#13#10
//+ '      --foreground=RRGGBB[AA]' + #13#10
//+ '      --background=RRGGBB[AA]' + #13#10
//+ '               specify foreground/background color in hexadecimal notation.' + #13#10
//+ '               6-digit (RGB) or 8-digit (RGBA) form are supported.' + #13#10
//+ '               Color output support available only in PNG and SVG.' + #13#10
//+ '  -V, --version' + #13#10
//+ '               display the version number and copyrights of the qrencode.' + #13#10#13#10
//+ '  [STRING]     input data. If it is not specified, data will be taken from' + #13#10
//+ '               standard input.' + #13#10
//      );
//		end else begin
//			Writeln(
//'Usage: qrencode [OPTION]... [STRING]' + #13#10
//+ 'Encode input data in a QR Code and save as a PNG or EPS image.' + #13#10#13#10
//+ '  -h           display this message.' + #13#10
//+ '  --help       display the usage of long options.' + #13#10
//+ '  -o FILENAME  write image to FILENAME. If ''-'' is specified, the result' + #13#10
//+ '               will be output to standard output. If -S is given, structured' + #13#10
//+ '               symbols are written to FILENAME-01.png, FILENAME-02.png, ...' + #13#10
//+ '               (suffix is removed from FILENAME, if specified)' + #13#10
//+ '  -s NUMBER    specify module size in dots (pixels). (default=3)' + #13#10
//+ '  -l {LMQH}    specify error correction level from L (lowest) to H (highest).' + #13#10
//+ '               (default=L)' + #13#10
//+ '  -v NUMBER    specify the version of the symbol. (default=auto)' + #13#10
//+ '  -m NUMBER    specify the width of the margins. (default=4 (2 for Micro))' + #13#10
//+ '  -d NUMBER    specify the DPI of the generated PNG. (default=72)' + #13#10
//+ '  -t {PNG,EPS,SVG,ANSI,ANSI256,ASCII,ASCIIi,UTF8,ANSIUTF8}' + #13#10
//+ '               specify the type of the generated image. (default=PNG)' + #13#10
//+ '  -S           make structured symbols. Version must be specified.' + #13#10
//+ '  -k           assume that the input text contains kanji (shift-jis).' + #13#10
//+ '  -c           encode lower-case alphabet characters in 8-bit mode. (default)' + #13#10
//+ '  -i           ignore case distinctions and use only upper-case characters.' + #13#10
//+ '  -8           encode entire data in 8-bit mode. -k, -c and -i will be ignored.' + #13#10
//+ '  -M           encode in a Micro QR Code.' + #13#10
//+ '  --foreground=RRGGBB[AA]' + #13#10
//+ '  --background=RRGGBB[AA]' + #13#10
//+ '               specify foreground/background color in hexadecimal notation.' + #13#10
//+ '               6-digit (RGB) or 8-digit (RGBA) form are supported.' + #13#10
//+ '               Color output support available only in PNG and SVG.' + #13#10
//+ '  -V           display the version number and copyrights of the qrencode.' + #13#10
//+ '  [STRING]     input data. If it is not specified, data will be taken from' + #13#10
//+ '               standard input.' + #13#10
//			);
//		end;
//	end;
//end;

function writeBMP(qrcode: PQRcode; const outfile: PAnsiChar): Integer;
var
  bmp: TBitmap;
  realwidth, x, xx, y, m: Integer;
  row, p, q: PByte;
  bit: Integer;
  pix: PRGBTriple;
begin
  realwidth := (qrcode.width + margin * 2) * size;
  try
    GetMem(row, (realwidth + 7) div 8);
  except
    Abort;
  end;
  bmp := TBitmap.Create;
  try
    p := qrcode.data;
    for y := 0 to qrcode.width - 1 do
    begin
      FillChar(row, (realwidth + 7) div 8, $FF);
      q := PIndex(row, margin * size div 8);
      bit := 7 - (margin * size mod 8);
      for x := 0 to qrcode.width - 1 do
      begin
        for xx := 0 to size - 1 do
        begin
          q^ := q^ xor ((p^ and 1) shl bit);
          Dec(bit);
          if bit < 0 then
          begin
            Inc(q);
            bit := 7;
          end;
        end;
        Inc(p);
      end;
    end;
    bmp.SaveToFile(StrPas(outfile));
  finally
    FreeAndNil(bmp);
  end;
end;

procedure writeUTF8_margin(var fp: Text; realwidth: Integer;
  const white, reset: PAnsiChar; use_ansi: Integer);
var
  x, y: Integer;
begin
	for y := 0 to margin div 2 - 1 do
  begin
    Write(fp, white);
		for x := 0 to realwidth - 1 do
			Write(fp, #226#150#136);
    Writeln(fp, reset);
	end;
end;

function writeUTF8(qrcode: PQRcode; const outfile: PAnsiChar;
  use_ansi: Integer): Integer;
var
  white, reset: PAnsiChar;
  fp: TextFile;
  x, y, realwidth: Integer;
  row1, row2: PByte;
begin
	if use_ansi <> 0 then
  begin
		white := #27 + '[40;37;1m';
		reset := #27 + '[0m';
	end else begin
		white := '';
		reset := '';
	end;

  AssignFile(fp, outfile);
  Rewrite(fp);

	realwidth := (qrcode.width + margin * 2);

	{* top margin *}
	writeUTF8_margin(fp, realwidth, white, reset, use_ansi);

	{* data *}
  y := 0;
  while y < qrcode.width do
  begin
		row1 := PIndex(qrcode.data, y * qrcode.width);
		row2 := PIndex(row1, qrcode.width);

    write(fp, white);

		for x := 0 to margin - 1 do
      write(fp, #226#150#136);

		for x := 0 to qrcode.width - 1 do
    begin
			if (PIndex(row1, x)^ and 1) <> 0 then
      begin
				if (y < qrcode.width - 1) and ((PIndex(row2, x)^ and 1) <> 0) then
        begin
          write(fp, ' ');
				end else begin
					write(fp, #226#150#132);
				end;
			end else begin
				if (y < qrcode.width - 1) and ((PIndex(row2, x)^ and 1) <> 0) then
        begin
					write(fp, #226#150#128);
				end else begin
					write(fp, #226#150#136);
				end;
			end;
		end;

		for x := 0 to margin - 1 do
			write(fp, #226#150#136);

		Writeln(fp, reset);
    Inc(y, 2);
	end;

	{* bottom margin *}
	writeUTF8_margin(fp, realwidth, white, reset, use_ansi);

	CloseFile(fp);

	Result := 0;
end;

function encode(const intext: PByte; length: Integer): PQRcode;
var
  code: PQRcode;
begin
	if micro <> 0 then
  begin
		if eightbit <> 0 then
    begin
			code := QRcode_encodeDataMQR(length, intext, version, level);
		end else begin
			code := QRcode_encodeStringMQR(PAnsiChar(intext), version, level, hint,
        casesensitive);
		end;
	end else begin
		if eightbit <> 0 then
    begin
			code := QRcode_encodeData(length, intext, version, level);
		end else begin
			code := QRcode_encodeString(PAnsiChar(intext), version, level, hint,
        casesensitive);
		end;
	end;

	Result := code;
end;

procedure qrcode(const intext: PByte; length: Integer; const outfile: PAnsiChar);
var
  qrcode: PQRcode;
begin
	qrcode := encode(intext, length);
	if qrcode = nil then
  begin
//		Writeln('Failed to encode the input data');
		Abort;
	end;
	case (image_type) of
    BMP_TYPE: writeBMP(qrcode, outfile);
//		PNG_TYPE:
//			writePNG(qrcode, outfile);
//		EPS_TYPE:
//			writeEPS(qrcode, outfile);
//		SVG_TYPE:
//			writeSVG(qrcode, outfile);
//		ANSI_TYPE,
//    ANSI256_TYPE: 
//			writeANSI(qrcode, outfile);
//		ASCIIi_TYPE:
//			writeASCII(qrcode, outfile,  1);
//		ASCII_TYPE:
//			writeASCII(qrcode, outfile,  0);
		UTF8_TYPE:
			writeUTF8(qrcode, outfile, 0);
		ANSIUTF8_TYPE: 
			writeUTF8(qrcode, outfile, 1);
		else begin
//			Writeln('Unknown image type.');
      QRcode_free(qrcode);
			Abort;
    end;
	end;
	QRcode_free(qrcode);
end;

function encodeStructured(const intext: PByte; length: Integer): PQRcode_List;
var
  list: PQRcode_List;
begin
	if eightbit <> 0 then
  begin
		list := QRcode_encodeDataStructured(length, intext, version, level);
	end else begin
		list := QRcode_encodeStringStructured(PAnsiChar(intext), version, level,
      hint, casesensitive);
	end;

	Result := list;
end;

procedure qrencodeStructured(const intext: PByte; length: Integer;
  const outfile: PAnsiChar);
var
  qrlist, p: PQRcode_List;
  filename: PAnsiChar;
  base, q, suffix: PAnsiChar;
  type_suffix: PAnsiChar;
  i: Integer;
  suffix_size: Integer;
begin
  i := 1;          
	case image_type of
    BMP_TYPE: type_suffix := '.bmp';
		PNG_TYPE: type_suffix := '.png';
		EPS_TYPE: type_suffix := '.eps';
		SVG_TYPE: type_suffix := '.svg';
		ANSI_TYPE,
		ANSI256_TYPE,
		ASCII_TYPE,
		UTF8_TYPE,
		ANSIUTF8_TYPE:
			type_suffix := '.txt';
		else begin
//			Writeln('Unknown image type.');
			Abort;
    end;
	end;

	if outfile = nil then
  begin
//		Writeln('An output filename must be specified to store the structured images.');
		Abort;
	end;
	base := strdup(outfile);
	if base = nil then
  begin
//		Writeln('Failed to allocate memory.');
		Abort;
	end;
	suffix_size := lstrlen(type_suffix);
	if lstrlen(base) > suffix_size then
  begin
		q := base + lstrlen(base) - suffix_size;
		if lstrcmpi(type_suffix, q) = 0 then
    begin
			suffix := strdup(q);
			q^ := #0;
		end;
	end;
	
	qrlist := encodeStructured(intext, length);
	if qrlist = nil then
  begin
//		Writeln('Failed to encode the input data');
		Abort;
	end;

  p := qrlist;
  while p <> nil do
  begin
		if p.code = nil then
    begin
//			Writeln('Failed to encode the input data.');
			Abort;
		end;
		if suffix <> nil then
    begin
      filename := PAnsiChar(Format('%s-%.2d%s', [base, i, suffix]));
		end else begin
      filename := PAnsiChar(Format('%s-%.2d', [base, i]));
		end;
		case image_type of
      BMP_TYPE: writeBMP(p.code, filename);
//			PNG_TYPE:
//				writePNG(p->code, filename);
//			EPS_TYPE:
//				writeEPS(p->code, filename);
//			SVG_TYPE:
//				writeSVG(p->code, filename);
//			ANSI_TYPE:
//			ANSI256_TYPE:
//				writeANSI(p->code, filename);
//			ASCIIi_TYPE:
//				writeASCII(p->code, filename, 1);
//			ASCII_TYPE:
//				writeASCII(p->code, filename, 0);
			UTF8_TYPE:
				writeUTF8(p.code, filename, 0);
			ANSIUTF8_TYPE:
				writeUTF8(p.code, filename, 0);

			else begin
//				Writeln('Unknown image type.');
				Abort;
      end;
		end;
		Inc(i);
    p := p.next;
	end;

	FreeMem(base);
	if suffix <> nil then
		FreeMem(suffix);

	QRcode_List_free(qrlist);
end;

procedure qr(str: string);
var
  pb: PByte;
  s: AnsiString;
begin
  version := 1;
  margin := 2;
  size := 3;  

  s := AnsiString(str);
  try
    GetMem(pb, Length(s) * SizeOf(AnsiChar) + 1);
    ZeroMemory(pb, Length(s) * SizeOf(AnsiChar) + 1);
//    CopyMemory(pb, PAnsiChar(s), Length(s));
//    qrencodeStructured(pb, Length(s) * SizeOf(AnsiChar), 'F:\My Documents\CodeBlocks\qrencode\21.txt');
    structured := 0;
    CopyMemory(pb, PAnsiChar(s), Length(s));
    qrcode(pb, Length(s) * SizeOf(AnsiChar), '22.txt');
    FreeMem(pb);
  except
  end;  
end;

end.
