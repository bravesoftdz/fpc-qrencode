unit qrencode;

interface

uses
  Windows, struct;

{**
 * Instantiate an input data object. The version is set to 0 (auto-select)
 * and the error correction level is set to QR_ECLEVEL_L.
 * @return an input object (initialized). On error, NULL is returned and errno
 *         is set to indicate the error.
 * @throw ENOMEM unable to allocate memory.
 *}
function QRinput_new(): PQRinput;

{**
 * Instantiate an input data object.
 * @param version version number.
 * @param level Error correction level.
 * @return an input object (initialized). On error, NULL is returned and errno
 *         is set to indicate the error.
 * @throw ENOMEM unable to allocate memory for input objects.
 * @throw EINVAL invalid arguments.
 *}
function QRinput_new2(version: Integer; level: QRecLevel): PQRinput;

{**
 * Instantiate an input data object. Object's Micro QR Code flag is set.
 * Unlike with full-sized QR Code, version number must be specified (>0).
 * @param version version number (1--4).
 * @param level Error correction level.
 * @return an input object (initialized). On error, NULL is returned and errno
 *         is set to indicate the error.
 * @throw ENOMEM unable to allocate memory for input objects.
 * @throw EINVAL invalid arguments.
 *}
function QRinput_newMQR(version: Integer; level: QRecLevel): PQRinput;

{**
 * Append data to an input object.
 * The data is copied and appended to the input object.
 * @param input input object.
 * @param mode encoding mode.
 * @param size size of data (byte).
 * @param data a pointer to the memory area of the input data.
 * @retval 0 success.
 * @retval -1 an error occurred and errno is set to indeicate the error.
 *            See Execptions for the details.
 * @throw ENOMEM unable to allocate memory.
 * @throw EINVAL input data is invalid.
 *
 *}
function QRinput_append(input: PQRinput; mode: QRencodeMode; size: Integer;
  const data: PByte): Integer;

{**
 * Append ECI header.
 * @param input input object.
 * @param ecinum ECI indicator number (0 - 999999)
 * @retval 0 success.
 * @retval -1 an error occurred and errno is set to indeicate the error.
 *            See Execptions for the details.
 * @throw ENOMEM unable to allocate memory.
 * @throw EINVAL input data is invalid.
 *
 *}
function QRinput_appendECIheader(input: PQRinput; ecinum: Cardinal): Integer;

{**
 * Get current version.
 * @param input input object.
 * @return current version.
 *}
function QRinput_getVersion(input: PQRinput): Integer;

{**
 * Set version of the QR code that is to be encoded.
 * This function cannot be applied to Micro QR Code.
 * @param input input object.
 * @param version version number (0 = auto)
 * @retval 0 success.
 * @retval -1 invalid argument.
 *}
function QRinput_setVersion(input: PQRinput; version: Integer): Integer;

{**
 * Get current error correction level.
 * @param input input object.
 * @return Current error correcntion level.
 *}
function QRinput_getErrorCorrectionLevel(input: PQRinput): QRecLevel;

{**
 * Set error correction level of the QR code that is to be encoded.
 * This function cannot be applied to Micro QR Code.
 * @param input input object.
 * @param level Error correction level.
 * @retval 0 success.
 * @retval -1 invalid argument.
 *}
function QRinput_setErrorCorrectionLevel(input: PQRinput; level: QRecLevel): Integer;

{**
 * Set version and error correction level of the QR code at once.
 * This function is recommened for Micro QR Code.
 * @param input input object.
 * @param version version number (0 = auto)
 * @param level Error correction level.
 * @retval 0 success.
 * @retval -1 invalid argument.
 *}
function QRinput_setVersionAndErrorCorrectionLevel(input: PQRinput;
  version: Integer; level: QRecLevel): Integer;

{**
 * Free the input object.
 * All of data chunks in the input object are freed too.
 * @param input input object.
 *}
procedure QRinput_free(input: PQRinput);

{**
 * Validate the input data.
 * @param mode encoding mode.
 * @param size size of data (byte).
 * @param data a pointer to the memory area of the input data.
 * @retval 0 success.
 * @retval -1 invalid arguments.
 *}
function QRinput_check(mode: QRencodeMode; size: Integer;
  const data: PByte): Integer;

{**
 * Set of QRinput for structured symbols.
 *}
//typedef struct _QRinput_Struct QRinput_Struct;

{**
 * Instantiate a set of input data object.
 * @return an instance of QRinput_Struct. On error, NULL is returned and errno
 *         is set to indicate the error.
 * @throw ENOMEM unable to allocate memory.
 *}
//extern QRinput_Struct *QRinput_Struct_new(void);

{**
 * Set parity of structured symbols.
 * @param s structured input object.
 * @param parity parity of s.
 *}
procedure QRinput_Struct_setParity(s: PQRinput_Struct; parity: Byte);

{**
 * Append a QRinput object to the set. QRinput created by QRinput_newMQR()
 * will be rejected.
 * @warning never append the same QRinput object twice or more.
 * @param s structured input object.
 * @param input an input object.
 * @retval >0 number of input objects in the structure.
 * @retval -1 an error occurred. See Exceptions for the details.
 * @throw ENOMEM unable to allocate memory.
 * @throw EINVAL invalid arguments.
 *}
function QRinput_Struct_appendInput(s: PQRinput_Struct; input: PQRinput): Integer;

{**
 * Free all of QRinput in the set.
 * @param s a structured input object.
 *}
procedure QRinput_Struct_free(s: PQRinput_Struct);

{**
 * Split a QRinput to QRinput_Struct. It calculates a parity, set it, then
 * insert structured-append headers. QRinput created by QRinput_newMQR() will
 * be rejected.
 * @param input input object. Version number and error correction level must be
 *        set.
 * @return a set of input data. On error, NULL is returned, and errno is set
 *         to indicate the error. See Exceptions for the details.
 * @throw ERANGE input data is too large.
 * @throw EINVAL invalid input data.
 * @throw ENOMEM unable to allocate memory.
 *}
function QRinput_splitQRinputToStruct(input: PQRinput): PQRinput_Struct;

{**
 * Insert structured-append headers to the input structure. It calculates
 * a parity and set it if the parity is not set yet.
 * @param s input structure
 * @retval 0 success.
 * @retval -1 an error occurred and errno is set to indeicate the error.
 *            See Execptions for the details.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory.
 *}
function QRinput_Struct_insertStructuredAppendHeaders(s: PQRinput_Struct): Integer;

{**
 * Set FNC1-1st position flag.
 *}
function QRinput_setFNC1First(input: PQRinput): Integer;

{**
 * Set FNC1-2nd position flag and application identifier.
 *}
function QRinput_setFNC1Second(input: PQRinput; appid: Byte): Integer;


{**
 * Create a symbol from the input data.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param input input data.
 * @return an instance of QRcode class. The version of the result QRcode may
 *         be larger than the designated version. On error, NULL is returned,
 *         and errno is set to indicate the error. See Exceptions for the
 *         details.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory for input objects.
 *}
function QRcode_encodeInput(input: PQRinput): PQRcode;

{**
 * Create a symbol from the string. The library automatically parses the input
 * string and encodes in a QR Code symbol.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param string input string. It must be NUL terminated.
 * @param version version of the symbol. If 0, the library chooses the minimum
 *                version for the given input data.
 * @param level error correction level.
 * @param hint tell the library how Japanese Kanji characters should be
 *             encoded. If QR_MODE_KANJI is given, the library assumes that the
 *             given string contains Shift-JIS characters and encodes them in
 *             Kanji-mode. If QR_MODE_8 is given, all of non-alphanumerical
 *             characters will be encoded as is. If you want to embed UTF-8
 *             string, choose this. Other mode will cause EINVAL error.
 * @param casesensitive case-sensitive(1) or not(0).
 * @return an instance of QRcode class. The version of the result QRcode may
 *         be larger than the designated version. On error, NULL is returned,
 *         and errno is set to indicate the error. See Exceptions for the
 *         details.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory for input objects.
 * @throw ERANGE input data is too large.
 *}
function QRcode_encodeString(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode;

{**
 * Same to QRcode_encodeString(), but encode whole data in 8-bit mode.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
function QRcode_encodeString8bit(const str: PAnsiChar; version: Integer;
  level: QRecLevel): PQRcode;

{**
 * Micro QR Code version of QRcode_encodeString().
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
function QRcode_encodeStringMQR(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode;

{**
 * Micro QR Code version of QRcode_encodeString8bit().
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
function QRcode_encodeString8bitMQR(const str: PAnsiChar; version: Integer;
  level: QRecLevel): PQRcode;

{**
 * Encode byte stream (may include '\0') in 8-bit mode.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param size size of the input data.
 * @param data input data.
 * @param version version of the symbol. If 0, the library chooses the minimum
 *                version for the given input data.
 * @param level error correction level.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory for input objects.
 * @throw ERANGE input data is too large.
 *}
function QRcode_encodeData(size: Integer; const data: PByte; version: Integer;
  level: QRecLevel): PQRcode;

{**
 * Micro QR Code version of QRcode_encodeData().
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
function QRcode_encodeDataMQR(size: Integer; const data: PByte; version: Integer;
  level: QRecLevel): PQRcode;

{**
 * Free the instance of QRcode class.
 * @param qrcode an instance of QRcode class.
 *}
procedure QRcode_free(qrcode: PQRcode);

{**
 * Create structured symbols from the input data.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param s
 * @return a singly-linked list of QRcode.
 *}
function QRcode_encodeInputStructured(s: PQRinput_Struct): PQRcode_List;

{**
 * Create structured symbols from the string. The library automatically parses
 * the input string and encodes in a QR Code symbol.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param string input string. It must be NUL terminated.
 * @param version version of the symbol.
 * @param level error correction level.
 * @param hint tell the library how Japanese Kanji characters should be
 *             encoded. If QR_MODE_KANJI is given, the library assumes that the
 *             given string contains Shift-JIS characters and encodes them in
 *             Kanji-mode. If QR_MODE_8 is given, all of non-alphanumerical
 *             characters will be encoded as is. If you want to embed UTF-8
 *             string, choose this. Other mode will cause EINVAL error.
 * @param casesensitive case-sensitive(1) or not(0).
 * @return a singly-linked list of QRcode. On error, NULL is returned, and
 *         errno is set to indicate the error. See Exceptions for the details.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory for input objects.
 *}
function QRcode_encodeStringStructured(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode_List;

{**
 * Same to QRcode_encodeStringStructured(), but encode whole data in 8-bit mode.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
function QRcode_encodeString8bitStructured(const str: PAnsiChar;
  version: Integer; level: QRecLevel): PQRcode_List;

{**
 * Create structured symbols from byte stream (may include '\0'). Wholde data
 * are encoded in 8-bit mode.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 * @param size size of the input data.
 * @param data input dat.
 * @param version version of the symbol.
 * @param level error correction level.
 * @return a singly-linked list of QRcode. On error, NULL is returned, and
 *         errno is set to indicate the error. See Exceptions for the details.
 * @throw EINVAL invalid input object.
 * @throw ENOMEM unable to allocate memory for input objects.
 *}
function QRcode_encodeDataStructured(size: Integer; const data: PByte;
  version: Integer; level: QRecLevel): PQRcode_List;

{**
 * Return the number of symbols included in a QRcode_List.
 * @param qrlist a head entry of a QRcode_List.
 * @return number of symbols in the list.
 *}
function QRcode_List_size(qrlist: PQRcode_List): Integer;

{**
 * Free the QRcode_List.
 * @param qrlist a head entry of a QRcode_List.
 *}
procedure QRcode_List_free(qrlist: PQRcode_List);


{******************************************************************************
 * System utilities
 ******************************************************************************}

{**
 * Return a string that identifies the library version.
 * @param major_version
 * @param minor_version
 * @param micro_version
 *}
procedure QRcode_APIVersion(major_version: PInteger; minor_version: PInteger;
  micro_version: PInteger);

{**
 * Return a string that identifies the library version.
 * @return a string identifies the library version. The string is held by the
 * library. Do NOT free it.
 *}
function QRcode_APIVersionString(): PAnsiChar;

{**
 * Clear all caches. This is only for debug purpose. If you are attacking a
 * complicated memory leak bug, try this to reduce the reachable blocks record.
 * @warning This function is THREAD UNSAFE when pthread is disabled.
 *}
procedure QRcode_clearCache();

implementation

uses
  rscode, qrinput, qrspec;

type
{******************************************************************************
 * Raw code
 *****************************************************************************}

  PRSblock = ^TRSblock;
  TRSblock = record
    dataLength: Integer;
    data: PByte;
    eccLength: Integer;
    ecc: PByte;
  end;

  PQRRawCode = ^QRRawCode;
  QRRawCode = record
    version: Integer;
    dataLength: Integer;
    eccLength: Integer;
    datacode: PByte;
    ecccode: PByte;
    b1: Integer;
    blocks: Integer;
    rsblock: PRSblock;
    count: Integer;
  end;

procedure RSblock_initBlock(block: PRSblock; dl: Integer; data: PByte;
  el: Integer; ecc: PByte; rs: PRS);
begin
	block.dataLength := dl;
	block.data := data;
	block.eccLength := el;
	block.ecc := ecc;

	encode_rs_char(rs, PData_t(data), PData_t(ecc));
end;

function RSblock_init(blocks: PRSblock; spec: array of Integer;
  data, ecc: PByte): Integer;
var
  i, el, dl: Integer;
  block: PRSblock;
  dp, ep: PByte;
  rs: PRS;
begin
	dl := QRspec_rsDataCodes1(spec);
	el := QRspec_rsEccCodes1(spec);
	rs := init_rs(8, $11d, 0, 1, el, 255 - dl - el);
	if rs = nil then
  begin
    Result := -1;
    Exit;
  end;

	block := blocks;
	dp := data;
	ep := ecc;
	for i := 0 to QRspec_rsBlockNum1(spec) - 1 do
  begin
		RSblock_initBlock(block, dl, dp, el, ep, rs);
		Inc(dp, dl);
		Inc(ep, el);
		Inc(block);
	end;

	if QRspec_rsBlockNum2(spec) = 0 then
  begin
    Result := 0;
    Exit;
  end;

	dl := QRspec_rsDataCodes2(spec);
	el := QRspec_rsEccCodes2(spec);
	rs := init_rs(8, $11d, 0, 1, el, 255 - dl - el);
	if rs = nil then
  begin
    Result := -1;
    Exit;
  end;
	for i := 0 to QRspec_rsBlockNum2(spec) - 1 do
  begin
		RSblock_initBlock(block, dl, dp, el, ep, rs);
		Inc(dp, dl);
		Inc(ep, el);
		Inc(block);
	end;

	Result := 0;
end;

procedure QRraw_free(raw: PQRRawCode);
begin
	if raw <> nil then
  begin
		FreeMem(raw.datacode);
		FreeMem(raw.ecccode);
		FreeMem(raw.rsblock);
		FreeMem(raw);
	end;
end;

function QRraw_new(input: PQRinput): PQRRawCode;
var
  spec: array[0..4] of Integer;
  ret: Integer;
begin
  try
    GetMem(Result, sizeof(QRRawCode));
  except
    Result := nil;
    Exit;
  end;

	Result.datacode := QRinput_getByteStream(input);
	if Result.datacode = nil then
  begin
		FreeMem(Result);
		Result := nil;
    Exit;
	end;

	QRspec_getEccSpec(input.version, input.level, PInteger(@spec));

	Result.version := input.version;
	Result.b1 := QRspec_rsBlockNum1(spec);
	Result.dataLength := QRspec_rsDataLength(spec);
	Result.eccLength := QRspec_rsEccLength(spec);
  try
    GetMem(Result.ecccode, Result.eccLength);
  except
    FreeMem(Result.datacode);
    FreeMem(Result);
    Result := nil;
    Exit;
  end;

	Result.blocks := QRspec_rsBlockNum(spec);
	Result.rsblock := (RSblock *)calloc(Result.blocks, sizeof(RSblock));
	if(Result.rsblock = nil then
  begin
		QRraw_free(Result);
		Result := nil;
    Exit;
	end;
	ret := RSblock_init(raw.rsblock, spec, raw.datacode, raw.ecccode);
	if ret < 0 then
  begin
		QRraw_free(Result);
    Result := nil;
    Exit;
	end;

	Result.count := 0;
end;

function QRinput_new(): PQRinput;
begin

end;

function QRinput_new2(version: Integer; level: QRecLevel): PQRinput;
begin

end;

function QRinput_newMQR(version: Integer; level: QRecLevel): PQRinput;
begin

end;

function QRinput_append(input: PQRinput; mode: QRencodeMode; size: Integer;
  const data: PByte): Integer;
begin

end;

function QRinput_appendECIheader(input: PQRinput; ecinum: Cardinal): Integer;
begin

end;

function QRinput_getVersion(input: PQRinput): Integer;
begin

end;

function QRinput_setVersion(input: PQRinput; version: Integer): Integer;
begin

end;

function QRinput_getErrorCorrectionLevel(input: PQRinput): QRecLevel;
begin

end;

function QRinput_setErrorCorrectionLevel(input: PQRinput; level: QRecLevel): Integer;
begin

end;

function QRinput_setVersionAndErrorCorrectionLevel(input: PQRinput;
  version: Integer; level: QRecLevel): Integer;
begin

end;

procedure QRinput_free(input: PQRinput);
begin

end;

function QRinput_check(mode: QRencodeMode; size: Integer;
  const data: PByte): Integer;
begin

end;

procedure QRinput_Struct_setParity(s: PQRinput_Struct; parity: Byte);
begin

end;

function QRinput_Struct_appendInput(s: PQRinput_Struct; input: PQRinput): Integer;
begin

end;

procedure QRinput_Struct_free(s: PQRinput_Struct);
begin

end;

function QRinput_splitQRinputToStruct(input: PQRinput): PQRinput_Struct;
begin

end;

function QRinput_Struct_insertStructuredAppendHeaders(s: PQRinput_Struct): Integer;
begin

end;

function QRinput_setFNC1First(input: PQRinput): Integer;
begin

end;

function QRinput_setFNC1Second(input: PQRinput; appid: Byte): Integer;
begin

end;

function QRcode_encodeInput(input: PQRinput): PQRcode;
begin

end;

function QRcode_encodeString(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode;
begin

end;

function QRcode_encodeString8bit(const str: PAnsiChar; version: Integer;
  level: QRecLevel): PQRcode;
begin

end;

function QRcode_encodeStringMQR(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode;
begin

end;

function QRcode_encodeString8bitMQR(const str: PAnsiChar; version: Integer;
  level: QRecLevel): PQRcode;
begin

end;

function QRcode_encodeData(size: Integer; const data: PByte; version: Integer;
  level: QRecLevel): PQRcode;
begin

end;

function QRcode_encodeDataMQR(size: Integer; const data: PByte; version: Integer;
  level: QRecLevel): PQRcode;
begin

end;

procedure QRcode_free(qrcode: PQRcode);
begin

end;

function QRcode_encodeInputStructured(s: PQRinput_Struct): PQRcode_List;
begin

end;

function QRcode_encodeStringStructured(const str: PAnsiChar; version: Integer;
  level: QRecLevel; hint: QRencodeMode; casesensitive: Integer): PQRcode_List;
begin

end;

function QRcode_encodeString8bitStructured(const str: PAnsiChar;
  version: Integer; level: QRecLevel): PQRcode_List;
begin

end;

function QRcode_encodeDataStructured(size: Integer; const data: PByte;
  version: Integer; level: QRecLevel): PQRcode_List;
begin

end;

function QRcode_List_size(qrlist: PQRcode_List): Integer;
begin

end;

procedure QRcode_List_free(qrlist: PQRcode_List);
begin

end;

procedure QRcode_APIVersion(major_version: PInteger; minor_version: PInteger;
  micro_version: PInteger);
begin

end;

function QRcode_APIVersionString(): PAnsiChar;
begin

end;

procedure QRcode_clearCache();
begin

end;

end.
