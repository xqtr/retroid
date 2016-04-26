//INSERT INTO "main"."games" ("id","title","platform","release","overview","esrb","genre","developer","publisher","rating","banner","screenshot","box_front","box_back","logo","crc","rom","emulator") VALUES (?1,?2,?3,?4,?5,?6,?7,?8,?9,?10,?11,?12,?13,?14,?15,?16,?17,?18)

program makelist;

{$GOTO ON}

{$mode objfpc}{$H+}
{$IFDEF Linux}
  {$DEFINE Unix}
  {$ENDIF}

uses
  baseunix,
  SysUtils,
  regexpr,
  crt,
  strutils,
  fileutil,
  Classes;

var
  t: string;

  ss: TStringList;

  procedure log(str: string);
  begin
    writeln(str);
  end;

  function removespchar(str: string): string;
  var
    tmp: string;
  begin
    tmp := str;
    tmp := StringReplace(tmp, '''', ' ', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '/', '-', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '\', '-', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, ';', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '#', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '*', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '.', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, ':', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '&amp', 'and', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, ',', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, '-', '', [rfReplaceAll, rfIgnoreCase]);
    tmp := StringReplace(tmp, ' ', '', [rfReplaceAll, rfIgnoreCase]);
    Result := tmp;
  end;


  procedure savestringtofile(s, f: string);
  var
    filevar: textfile;
  begin
    assignfile(filevar, f);
    {$I+}
    try
      rewrite(filevar);
      writeln(filevar, s);
      closefile(filevar);
    except
      on E: EInOutError do
      begin
        writeln('File error');
      end;
    end;
  end;

  function isodate(s: string): string;
  begin
    Result := copy(s, 7, 4) + copy(s, 4, 2) + copy(s, 1, 2);
  end;

  function removebrackets(str: string): string;
  var
    a, b, i: integer;
    found: boolean;
    s: string;
  begin
    s := str;
    found := True;
    repeat
      if pos('(', s) > 0 then
      begin
        a := pos('(', s);
        b := pos(')', s);
        Delete(s, a, b - a + 1);
        Result := s;
      end
      else
        found := False;
    until found = False;
    found := True;
    repeat
      if pos('[', s) > 0 then
      begin
        a := pos('[', s);
        b := pos(']', s);
        Delete(s, a, b - a + 1);
        Result := trim(s);
      end
      else
        found := False;
    until found = False;
    a := pos('GBA', s);
    if a > 0 then
      Delete(s, a, 3);
    a := pos('#', s);
    if a > 0 then
      Delete(s, a, 1);
    Result := s;
  end;

  function removeext(ffile: string): string;
  var
    s: string;
    i: integer;
  begin
    s := ffile;

    for i := length(s) downto 1 do
      if s[i] = '.' then
      begin
        Delete(s, i, length(s) - i + 1);
        break;
      end;
    Result := s;
  end;

  procedure savetexttofile(txt: string; filename: string);
  var
    ff: textfile;
  begin
    assignfile(ff, filename);
  {$I+}
    try
      rewrite(ff);
      writeln(ff, txt);
      closefile(ff);
    except
      writeln('Could not save textfile');
    end;
  end;

  procedure help;
  begin
    writeln('Retroid List Tool...');
    writeln;
    writeln('Usage:');
    writeln('  ' + ExtractFileName(ParamStr(0)) +
      ' <path> <file_masks> <command> <listfile> <options>');
    writeln;
    writeln(' <path>       : Path to search for files and write to list');
    writeln(' <file_masks> : Mask for files to search for ex. *.pas;*.pp;*.p;*.inc');
    writeln('                Multiple masks supported, seperate with semicolon');
    writeln(' <command>    : The command to execute when list item is selected');
    writeln(' <listfile>   : File to save the list');
    writeln;
    writeln(' Options:');
    writeln(' -r           : Search in subdirs also');
    writeln;
  end;

var
  files: TStringList;
  i: integer;
  recursive: boolean;
  tmp: string;

begin
  if paramcount < 4 then
  begin
    help;
    exit;
  end;
  recursive := False;
  for i := 1 to paramcount do
    if lowercase(ParamStr(i)) = '-r' then
      recursive := True;
  Files := FindAllFiles(ParamStr(1), ParamStr(2), recursive);
  for i := 0 to files.Count - 1 do
  begin
    tmp := files[i];
    tmp := removeext(ExtractFilename(tmp));
    files[i] := tmp + '%!update%|' + ParamStr(3) + ' ' + '"' + files[i] + '"';
  end;
  files.savetofile(ParamStr(4));
  files.Free;

end.
