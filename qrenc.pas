unit qrenc;

interface

uses
  Windows, struct;

implementation

const
  INCHES_PER_METER = 100.0 / 2.54;
  optstring = 'ho:l:s:v:m:d:t:Skci8MV';  

type
  imageType = (
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

  image_type: imageType = PNG_TYPE;

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

end.
