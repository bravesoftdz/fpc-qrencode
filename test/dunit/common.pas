unit common;

interface

uses
  Windows, SysUtils, struct, qrinput, bitstream;

const
  modeStr: array[0..4] of PAnsiChar = ('nm', 'an', '8', 'kj', 'st');

var
  levelChar: array[0..3] of PAnsiChar = ('L', 'M', 'Q', 'H');

procedure printQRinput(input: PQRinput);
procedure printQRinputInfo(input: PQRinput);
procedure printFrame(width: Integer; frame: PByte);
procedure printQRcode(code: PQRcode);
procedure testStartReal(const func: PAnsiChar; const name: PAnsiChar);
procedure testEnd(Ret: Integer);
procedure testFinish();
procedure report();
function cmpBin(correct: PAnsiChar; bstream: PBitStream): Integer;
function ncmpBin(correct: PAnsiChar; bstream: PBitStream; len: Integer): Integer;

implementation

var
  tests: Integer = 0;
  failed: Integer = 0;
  assertionFailed: Integer = 0;
  assertionNum: Integer = 0;
  testName: PAnsiChar = nil;
  testFunc: PAnsiChar = nil;

procedure printQRinput(input: PQRinput);
var
  list: PQRinput_list;
  i: Integer;
begin
	list := input.head;
	while (list <> nil) do
  begin
		for i :=0 to list.size - 1 do
    begin
			OutputDebugString(PChar(Format('0x%.2x,', [PIndex(list.data, i)^])));
		end;
		list := list.next;
	end;
  OutputDebugString(#13#10);
end;

procedure printQRinputInfo(input: PQRinput);
var
  list: PQRinput_List;
  b: PBitStream;
  i: Integer;
begin
	OutputDebugString('QRinput info:');
	OutputDebugString(PChar(Format(' version: %d', [input.version])));
	OutputDebugString(PChar(Format(' level  : %c',
    [levelChar[Integer(input.level)]])));
	list := input.head;
	i := 0;
	while list <> nil do
  begin
		Inc(i);
		list := list.next;
	end;
	OutputDebugString(PChar(Format('  chunks: %d', [i])));
	b := QRinput_mergeBitStream(input);
	if b <> nil then
  begin
		OutputDebugString(PChar(Format('  bitstream-size: %d', [BitStream_size(b)])));
		BitStream_free(b);
	end;

	list := input.head;
	i := 0;
	while list <> nil do
  begin
		OutputDebugString(PChar(Format(#9'#%d: mode := %s, size := %d',
      [i, modeStr[Integer(list.mode)], list.size])));
		Inc(i);
		list := list.next;
	end;
end;

procedure printFrame(width: Integer; frame: PByte);
var
  x, y: Integer;
begin
	for y := 0 to width - 1 do
  begin
		for x := 0 to width - 1 do
    begin
			OutputDebugString(PChar(Format('%.2x ', [frame^])));
      Inc(frame);
		end;
		OutputDebugString(#13#10);
	end;
end;

procedure printQRcode(code: PQRcode);
begin
	printFrame(code.width, code.data);
end;

procedure testStartReal(const func: PAnsiChar; const name: PAnsiChar);
begin
	Inc(tests);
	testName := name;
	testFunc := func;
	assertionFailed := 0;
	assertionNum := 0;
	OutputDebugString(PChar(Format('_____%d: %s: %s...', [tests, func, name])));
end;

procedure testEnd(Ret: Integer);
begin
	OutputDebugString(PChar(Format('.....%d: %s: %s, ',
    [tests, testFunc, testName])));
	if Ret <> 0 then
  begin
		OutputDebugString('FAILED.');
		Inc(failed);
	end else begin
		OutputDebugString('PASSED.');
	end;
end;

//#define assert_exp(__exp__, ...) \
//beginassertionNum++;if(!(__exp__)) beginassertionFailed++; printf(__VA_ARGS__);end;end;
//
//#define assert_zero(__exp__, ...) assert_exp((__exp__) = 0, __VA_ARGS__)
//#define assert_nonzero(__exp__, ...) assert_exp((__exp__) <> 0, __VA_ARGS__)
//#define assert_nil(__ptr__, ...) assert_exp((__ptr__) = nil, __VA_ARGS__)
//#define assert_nonnil(__ptr__, ...) assert_exp((__ptr__) <> nil, __VA_ARGS__)
//#define assert_equal(__e1__, __e2__, ...) assert_exp((__e1__) = (__e2__), __VA_ARGS__)
//#define assert_notequal(__e1__, __e2__, ...) assert_exp((__e1__) <> (__e2__), __VA_ARGS__)
//#define assert_nothing(__exp__, ...) beginprintf(__VA_ARGS__); __exp__;end;

procedure testFinish();
begin
	OutputDebugString(PChar(Format('.....%d: %s: %s, ',
    [tests, testFunc, testName])));
	if assertionFailed <> 0 then
  begin
		OutputDebugString(PChar(Format('FAILED. (%d assertions failed.)',
      [assertionFailed])));
		Inc(failed);
	end else begin
		OutputDebugString(PChar(Format('PASSED. (%d assertions passed.)',
      [assertionNum])));
	end;
end;

procedure report();
begin
	OutputDebugString(PChar(Format('Total %d tests, %d fails.', [tests, failed])));
	if failed <> 0 then
    Abort;
end;

function ncmpBin(correct: PAnsiChar; bstream: PBitStream; len: Integer): Integer;
var
  i, bit: Integer;
  p: PAnsiChar;
begin

	if (len <> BitStream_size(bstream)) then
  begin
		OutputDebugString(PChar(Format('Length is not match: %d, %d expected.',
      [BitStream_size(bstream), len])));
		Result := -1;
	end;

	p := correct;
	i := 0;
	while p^ <> #0 do
  begin
		while p^ = ' ' do
    begin
			Inc(p);
		end;
    if p^ = '1' then
      bit := 1
    else
      bit := 0;

		if PIndex(bstream.data, i)^ <> bit then
      Result := -1;
		Inc(i);
		Inc(p);
		if i = len then
      break;
	end;

	Result := 0;
end;

function cmpBin(correct: PAnsiChar; bstream: PBitStream): Integer;
var
  len: Integer;
  p: PAnsiChar;
begin
	len := 0;

  p := correct;
  while p^ <> #0 do
  begin
    if p^ <> ' ' then
      Inc(len);
    Inc(p);
  end;
  Result := ncmpBin(correct, bstream, len);
end;

end.
