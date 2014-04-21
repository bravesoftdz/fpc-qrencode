unit bitstreamTests;

interface

uses
  bitstream,
  TestFrameWork;

type
  bitstreamGlobalsTests = class(TTestCase)
  private

  protected

//    procedure SetUp; override;
//    procedure TearDown; override;

  published

    // Test methods
    procedure TestBitStream_new;
    procedure TestBitStream_append;
    procedure TestBitStream_appendNum;
    procedure TestBitStream_appendBytes;
    procedure TestBitStream_size;
    procedure TestBitStream_toByte;
    procedure TestBitStream_free;
    procedure Test_num();

  end;

implementation

uses
  struct, common;

{ bitstreamGlobalsTests }

procedure bitstreamGlobalsTests.TestBitStream_append;
var
  bs1, bs2: PBitStream;
  c1, c2, c3, c4, c5: PAnsiChar;
  ret: Integer;
begin
	c1 := '00';
	c2 := '0011';
	c3 := '01111111111111111';
	c4 := '001101111111111111111';
	c5 := '0011011111111111111111111111111111';

//	testStart('Append two BitStreams');

	bs1 := BitStream_new();
	bs2 := BitStream_new();
	ret := BitStream_appendNum(bs1, 1, 0);
	ret := BitStream_appendNum(bs2, 1, 0);

	ret := BitStream_append(bs1, bs2);
	CheckEquals(ret, 0, 'Failed to append.');
	CheckEquals(cmpBin(c1, bs1), 0, 'Internal data is incorrect.');

	ret := BitStream_appendNum(bs1, 2, 3);
	CheckEquals(ret, 0, 'Failed to append.');
	CheckEquals(cmpBin(c2, bs1), 0, 'Internal data is incorrect.');

	ret := BitStream_appendNum(bs2, 16, 65535);
	CheckEquals(ret, 0, 'Failed to append.');
	CheckEquals(cmpBin(c3, bs2), 0, 'Internal data is incorrect.');

	ret := BitStream_append(bs1, bs2);
	CheckEquals(ret, 0, 'Failed to append.');
	CheckEquals(cmpBin(c4, bs1), 0, 'Internal data is incorrect.');

	ret := BitStream_appendNum(bs1, 13, 16383);
	CheckEquals(ret, 0, 'Failed to append.');
	CheckEquals(cmpBin(c5, bs1), 0, 'Internal data is incorrect.');

//	testFinish();

	BitStream_free(bs1);
	BitStream_free(bs2);
end;

procedure bitstreamGlobalsTests.TestBitStream_appendBytes;
begin

end;

procedure bitstreamGlobalsTests.TestBitStream_appendNum;
begin

end;

procedure bitstreamGlobalsTests.TestBitStream_free;
begin

end;

procedure bitstreamGlobalsTests.TestBitStream_new;
begin

end;

procedure bitstreamGlobalsTests.TestBitStream_size;
begin

end;

procedure bitstreamGlobalsTests.TestBitStream_toByte;
begin

end;

procedure bitstreamGlobalsTests.Test_num;
var
  bstream: PBitStream;
  data: Cardinal;
  correct: PAnsiChar;
begin
  data := $13579bdf;
	correct := '0010011010101111001101111011111';

  

//	testStart('New from num');
	bstream := BitStream_new();
	BitStream_appendNum(bstream, 31, data);
	testEnd(cmpBin(correct, bstream));

	BitStream_free(bstream);
end;

initialization

  TestFramework.RegisterTest('bitstreamTests Suite',
    bitstreamGlobalsTests.Suite);

end.
