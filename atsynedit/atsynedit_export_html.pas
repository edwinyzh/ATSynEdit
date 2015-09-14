unit ATSynEdit_Export_HTML;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Graphics, StrUtils,
  ATSynEdit,
  ATSynEdit_CanvasProc;

procedure DoEditorExportToHTML(Ed: TATSynEdit; const AFilename, APageTitle: string);

implementation

function ColorToHtmlColor(C: TColor): string;
begin
  Result:= IntToHex(C, 6);
  Result:= '#'+Copy(Result, 5, 2)+Copy(Result, 3, 2)+Copy(Result, 1, 2);
end;

procedure DoEditorExportToHTML(Ed: TATSynEdit; const AFilename,
  APageTitle: string);
var
  F: TextFile;
  Parts: TATLineParts;
  PPart: ^TATLinePart;
  NColorAfter: TColor;
  i, j: integer;
begin
  if FileExists(AFilename) then
    DeleteFile(AFilename);

  AssignFile(F, AFilename);
  {$I-}
  Rewrite(F);
  {$I+}
  if IOResult<>0 then exit;

  Writeln(F, '<!-- Generated by ATSynEdit Exporter -->');
  Writeln(F, '<html>');

  Writeln(F, '<head>');
  Writeln(F, '  <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
  Writeln(F, '  <title>'+APageTitle+'</title>');
  Writeln(F, '</head>');

  Writeln(F, '<body>');
  Writeln(F, '<font name="Courier New" size="3" color="#000">');
  Writeln(F, '<pre><code>');

  FillChar(Parts, Sizeof(Parts), 0);
  for i:= 0 to Ed.Strings.Count-1 do
  begin
    if not Ed.DoCalcLineHiliteEx(i, Parts, clWhite, NColorAfter) then break;
    for j:= 0 to High(Parts) do
    begin
      PPart:= @Parts[j];
      if PPart^.Len=0 then Break;
      if PPart^.FontBold then Write(F, '<b>');
      if PPart^.FontItalic then Write(F, '<i>');
      if PPart^.FontStrikeOut then Write(F, '<s>');
      Write(F, '<font '+
        IfThen(PPart^.ColorFont<>clBlack, 'color="'+ColorToHtmlColor(PPart^.ColorFont)+'" ')+
        IfThen(PPart^.ColorBG<>clWhite, 'bgcolor="'+ColorToHtmlColor(PPart^.ColorBG)+'" ')+
        '>');
      Write(F, Utf8Encode(Copy(Ed.Strings.Lines[i], PPart^.Offset+1, PPart^.Len)));
      Write(F, '</font>');
      if PPart^.FontStrikeOut then Write(F, '</s>');
      if PPart^.FontItalic then Write(F, '</i>');
      if PPart^.FontBold then Write(F, '</b>');
    end;
    Writeln(F);
  end;

  Writeln(F, '</code></pre>');
  Writeln(F, '</font>');
  Writeln(F, '</body>');
  Writeln(F, '</html>');

  CloseFile(F);
end;

end.
