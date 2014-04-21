// Uncomment the following directive to create a console application
// or leave commented to create a GUI application... 
// {$APPTYPE CONSOLE}

program QRcodeTests;

uses
  TestFramework {$IFDEF LINUX},
  QForms,
  QGUITestRunner {$ELSE},
  Forms,
  GUITestRunner {$ENDIF},
  TextTestRunner,
  bitstream in '..\..\bitstream.pas',
  struct in '..\..\struct.pas',
  mask in '..\..\mask.pas',
  mmask in '..\..\mmask.pas',
  mqrspec in '..\..\mqrspec.pas',
  qrencode in '..\..\qrencode.pas',
  qrinput in '..\..\qrinput.pas',
  qrspec in '..\..\qrspec.pas',
  rscode in '..\..\rscode.pas',
  split in '..\..\split.pas',
  bitstreamTests in 'bitstreamTests.pas',
  common in 'common.pas';

{$R *.RES}

begin
  Application.Initialize;

{$IFDEF LINUX}
  QGUITestRunner.RunRegisteredTests;
{$ELSE}
  if System.IsConsole then
    TextTestRunner.RunRegisteredTests
  else
    GUITestRunner.RunRegisteredTests;
{$ENDIF}

end.

 