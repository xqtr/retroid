unit tools;
{$mode objfpc}
{$H+}
{$IFDEF Linux}
  {$DEFINE Unix}
  {$ENDIF}

Interface
{$I zglCustomConfig.cfg}
uses
  {$IFDEF USE_ZENGL_STATIC}
  zgl_main,  
  zgl_file,
  zgl_keyboard,
  inifiles,
  zgl_mouse,
  zgl_types,
  zgl_screen,
  zgl_window,
  zgl_render_2d,
  zgl_fx,
  zgl_log,
  zgl_textures,
  zgl_textures_png,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_sound,
  zgl_textures_tga,
  zgl_sound_wav,
  zgl_sound_ogg,
  zgl_math_2d,
  zgl_collision_2d,
  zgl_utils,
  zgl_video,
  zgl_video_theora,
  classes,
  process,
  math,
  sysutils
  {$ELSE}
    zglHeader
  {$ENDIF}
  ;

type
  zglPTGAHeader = ^zglTTGAHeader;

  zglTTGAHeader = packed record
    IDLength: byte;
    CPalType: byte;
    ImageType: byte;
    CPalSpec: packed record
      FirstEntry: word;
      Length: word;
      EntrySize: byte;
    end;
    ImgSpec: packed record
      X: word;
      Y: word;
      Width: word;
      Height: word;
      Depth: byte;
      Desc: byte;
    end;
  end;

const
  {$IFDEF WIN32}
  PathSep = '\';
  CRLF = #13#10;
  OSID = 'Windows';
  OSType = 0;
  {$ENDIF}

  {$IFDEF LINUX}
  PathSep = '/';
  CRLF = #10;
    {$IFDEF CPUARM} OSID = 'Raspberry Pi';
{$ELSE} OSID = 'Linux'; {$ENDIF}
  OSType = 1;
  {$ENDIF}

  {$IFDEF DARWIN}
  PathSep = '/';
  CRLF = #10;
  OSID = 'OSX';
  OSType = 2;
  {$ENDIF}

  {$IFDEF OS2}
  PathSep = '\';
  CRLF = #13#10;
  OSID = 'OS/2';
  OSType = 4;
  {$ENDIF}


const
  Table: array[0..255] of DWord =
    ($00000000, $77073096, $EE0E612C, $990951BA,
    $076DC419, $706AF48F, $E963A535, $9E6495A3,
    $0EDB8832, $79DCB8A4, $E0D5E91E, $97D2D988,
    $09B64C2B, $7EB17CBD, $E7B82D07, $90BF1D91,
    $1DB71064, $6AB020F2, $F3B97148, $84BE41DE,
    $1ADAD47D, $6DDDE4EB, $F4D4B551, $83D385C7,
    $136C9856, $646BA8C0, $FD62F97A, $8A65C9EC,
    $14015C4F, $63066CD9, $FA0F3D63, $8D080DF5,
    $3B6E20C8, $4C69105E, $D56041E4, $A2677172,
    $3C03E4D1, $4B04D447, $D20D85FD, $A50AB56B,
    $35B5A8FA, $42B2986C, $DBBBC9D6, $ACBCF940,
    $32D86CE3, $45DF5C75, $DCD60DCF, $ABD13D59,
    $26D930AC, $51DE003A, $C8D75180, $BFD06116,
    $21B4F4B5, $56B3C423, $CFBA9599, $B8BDA50F,
    $2802B89E, $5F058808, $C60CD9B2, $B10BE924,
    $2F6F7C87, $58684C11, $C1611DAB, $B6662D3D,
    $76DC4190, $01DB7106, $98D220BC, $EFD5102A,
    $71B18589, $06B6B51F, $9FBFE4A5, $E8B8D433,
    $7807C9A2, $0F00F934, $9609A88E, $E10E9818,
    $7F6A0DBB, $086D3D2D, $91646C97, $E6635C01,
    $6B6B51F4, $1C6C6162, $856530D8, $F262004E,
    $6C0695ED, $1B01A57B, $8208F4C1, $F50FC457,
    $65B0D9C6, $12B7E950, $8BBEB8EA, $FCB9887C,
    $62DD1DDF, $15DA2D49, $8CD37CF3, $FBD44C65,
    $4DB26158, $3AB551CE, $A3BC0074, $D4BB30E2,
    $4ADFA541, $3DD895D7, $A4D1C46D, $D3D6F4FB,
    $4369E96A, $346ED9FC, $AD678846, $DA60B8D0,
    $44042D73, $33031DE5, $AA0A4C5F, $DD0D7CC9,
    $5005713C, $270241AA, $BE0B1010, $C90C2086,
    $5768B525, $206F85B3, $B966D409, $CE61E49F,
    $5EDEF90E, $29D9C998, $B0D09822, $C7D7A8B4,
    $59B33D17, $2EB40D81, $B7BD5C3B, $C0BA6CAD,
    $EDB88320, $9ABFB3B6, $03B6E20C, $74B1D29A,
    $EAD54739, $9DD277AF, $04DB2615, $73DC1683,
    $E3630B12, $94643B84, $0D6D6A3E, $7A6A5AA8,
    $E40ECF0B, $9309FF9D, $0A00AE27, $7D079EB1,
    $F00F9344, $8708A3D2, $1E01F268, $6906C2FE,
    $F762575D, $806567CB, $196C3671, $6E6B06E7,
    $FED41B76, $89D32BE0, $10DA7A5A, $67DD4ACC,
    $F9B9DF6F, $8EBEEFF9, $17B7BE43, $60B08ED5,
    $D6D6A3E8, $A1D1937E, $38D8C2C4, $4FDFF252,
    $D1BB67F1, $A6BC5767, $3FB506DD, $48B2364B,
    $D80D2BDA, $AF0A1B4C, $36034AF6, $41047A60,
    $DF60EFC3, $A867DF55, $316E8EEF, $4669BE79,
    $CB61B38C, $BC66831A, $256FD2A0, $5268E236,
    $CC0C7795, $BB0B4703, $220216B9, $5505262F,
    $C5BA3BBE, $B2BD0B28, $2BB45A92, $5CB36A04,
    $C2D7FFA7, $B5D0CF31, $2CD99E8B, $5BDEAE1D,
    $9B64C2B0, $EC63F226, $756AA39C, $026D930A,
    $9C0906A9, $EB0E363F, $72076785, $05005713,
    $95BF4A82, $E2B87A14, $7BB12BAE, $0CB61B38,
    $92D28E9B, $E5D5BE0D, $7CDCEFB7, $0BDBDF21,
    $86D3D2D4, $F1D4E242, $68DDB3F8, $1FDA836E,
    $81BE16CD, $F6B9265B, $6FB077E1, $18B74777,
    $88085AE6, $FF0F6A70, $66063BCA, $11010B5C,
    $8F659EFF, $F862AE69, $616BFFD3, $166CCF45,
    $A00AE278, $D70DD2EE, $4E048354, $3903B3C2,
    $A7672661, $D06016F7, $4969474D, $3E6E77DB,
    $AED16A4A, $D9D65ADC, $40DF0B66, $37D83BF0,
    $A9BCAE53, $DEBB9EC5, $47B2CF7F, $30B5FFE9,
    $BDBDF21C, $CABAC28A, $53B39330, $24B4A3A6,
    $BAD03605, $CDD70693, $54DE5729, $23D967BF,
    $B3667A2E, $C4614AB8, $5D681B02, $2A6F2B94,
    $B40BBE37, $C30C8EA1, $5A05DF1B, $2D02EF8D);

procedure SplitText(aDelimiter: char; const s: string; aList: TStringList);
function pathchar(path: utf8string): utf8string;
function SoundPlay(filename: string; play: boolean): longint;
function MouseOver(x, y, w, h: integer): boolean;
function Runbig(app: string): utf8string;
function ExtCommand(s: utf8string): utf8string;
function LevenshteinDistance(const s1: utf8string; s2: utf8string): integer;
function CompareText(const s1, s2: utf8string): integer;
function removebrackets(s: string): string;
function removeext(ffile: string): string;
function findromfile(romname: string; rompath: string): string;
function getinistring(inif: string; section: string; key: string): string;
function getiniboolean(inif: string; section: string; key: string): boolean;
procedure saveinistring(inif: string; section: string; key, Value: string);
procedure colorizetexture(var txt: zglPTexture; color: longword);
procedure ScreenToTGA(Width, Height: integer; const FileName: string);
function Setintransition(tr: string): byte;
procedure wraplist(var sl: TStringList; str: string; size: integer);
function poscount(const S: string; const C: char): integer;


implementation

procedure SplitText(aDelimiter: char; const s: string; aList: TStringList);
begin
  aList.Delimiter := aDelimiter;
  aList.StrictDelimiter := True; // Spaces excluded from being a delimiter
  aList.DelimitedText := s;
  if alist.Count = 0 then
    alist.add(s);
end;

function pathchar(path: utf8string): utf8string;
begin
  if path[length(path)] <> pathsep then
    Result := path + pathsep
  else
    Result := path;
end;

function SoundPlay(filename: string; play: boolean): longint;
begin
  if not play then
    exit;
  if fileexists(filename) then
    Result := snd_PlayFile(filename);
end;

function MouseOver(x, y, w, h: integer): boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

function Runbig(app: string): utf8string;
const
  READ_BYTES = 2048;
var
  S: TStringList;
  M: TMemoryStream;
  P: TProcess;
  n: longint;
  BytesRead: longint;

begin
  M := TMemoryStream.Create;
  BytesRead := 0;

  P := TProcess.Create(nil);
  P.CommandLine := app;
  P.Options := [poUsePipes];
  P.Execute;
  while P.Running do
  begin
    M.SetSize(BytesRead + READ_BYTES);
    n := P.Output.Read((M.Memory + BytesRead)^, READ_BYTES);
    if n > 0 then
    begin
      Inc(BytesRead, n);
    end
    else
    begin
      // no data, wait 100 ms
      Sleep(100);
    end;
  end;
  repeat
    M.SetSize(BytesRead + READ_BYTES);
    n := P.Output.Read((M.Memory + BytesRead)^, READ_BYTES);
    if n > 0 then
    begin
      Inc(BytesRead, n);
    end;
  until n <= 0;
  if BytesRead > 0 then
    WriteLn;
  M.SetSize(BytesRead);
  S := TStringList.Create;
  S.LoadFromStream(M);
  Result := s.Text;
  S.Free;
  P.Free;
  M.Free;
end;

function ExtCommand(s: utf8string): utf8string;
var
  tmp, tmp1: utf8string;
  multiple: TStringList;
  d: integer;
begin
  tmp := s;
  multiple := TStringList.Create;
  if tmp[1] = '|' then
  begin
    Delete(tmp, 1, 1);
    SplitText(';', tmp, multiple);
    for d := 0 to multiple.Count - 1 do
    begin
      tmp1 := runbig(multiple[d]);
      if tmp1 <> '' then
        Result := tmp1;
      log_add(multiple[d]);
    end;
    multiple.Free;
  end;
end;

procedure CalcCRC32(FileName: string; var CRC32: dword);
var
  F: file;
  BytesRead: dword;
  Buffer: array[1..65521] of byte;
  i: word;
begin
  FileMode := 0;
  CRC32 := $ffffffff;
    {$I-}
  AssignFile(F, FileName);
  Reset(F, 1);
  if IOResult = 0 then
  begin
    repeat
      BlockRead(F, Buffer, SizeOf(Buffer), BytesRead);
      for i := 1 to BytesRead do
        CRC32 := (CRC32 shr 8) xor Table[Buffer[i] xor (CRC32 and $000000FF)];
    until BytesRead = 0;
  end;
  CloseFile(F);
    {$I+}
  CRC32 := not CRC32;
end;


function LevenshteinDistance(const s1: utf8string; s2: utf8string): integer;
var
  length1, length2, i, j, value1, value2, value3: integer;
  matrix: array of array of integer;
begin
  length1 := Length(s1);
  length2 := Length(s2);
  SetLength(matrix, length1 + 1, length2 + 1);
  for i := 0 to length1 do
    matrix[i, 0] := i;
  for j := 0 to length2 do
    matrix[0, j] := j;
  for i := 1 to length1 do
    for j := 1 to length2 do
    begin
      if Copy(s1, i, 1) = Copy(s2, j, 1) then
        matrix[i, j] := matrix[i - 1, j - 1]
      else
      begin
        value1 := matrix[i - 1, j] + 1;
        value2 := matrix[i, j - 1] + 1;
        value3 := matrix[i - 1, j - 1] + 1;
        matrix[i, j] := min(value1, min(value2, value3));
      end;
    end;
  Result := matrix[length1, length2];
end;

{------------------------------------------------------------------------------
  Name:    LevenshteinDistanceText
  Params: s1, s2 - UTF8 encoded strings
  Returns: Minimum number of single-character edits.
  Compare 2 UTF8 encoded strings, case insensitive.
------------------------------------------------------------------------------}
function CompareText(const s1, s2: utf8string): integer;
var
  s1lower, s2lower: string;
begin
  s1lower := LowerCase(s1);
  s2lower := LowerCase(s2);
  Result := LevenshteinDistance(s1lower, s2lower);
end;

function removebrackets(s: string): string;
var
  a, b, i: integer;
  found: boolean;
begin
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

function findromfile(romname: string; rompath: string): string;
var
  i, q: integer;
  Info: TSearchRec;
  Count: longint;
  rom: string;
begin
  Count := 0;
  i := 100;
  q := 0;
  Result := '';
  if rompath <> '' then
  begin
    rompath := IncludeTrailingPathDelimiter(rompath);
    if FindFirst(rompath + '*', faAnyFile and not faDirectory, Info) = 0 then
    begin
      repeat
        Inc(Count);
        with Info do
        begin
          if (Attr and faarchive) = faarchive then
          begin
            q := CompareText(removebrackets(removeext(Name)), romname);
            if i > q then
            begin
              i := q;
              rom := Name;
            end;
          end;
        end;

      until FindNext(info) <> 0;
    end;
    FindClose(Info);
    if i > 10 then
      Result := ''
    else
      Result := rom;
  end;
end;

procedure saveinistring(inif: string; section: string; key, Value: string);
var
  inifile: tinifile;
begin

  if file_exists(inif) = False then
  begin
    log_add('File ' + inif + ' does not exist!');
    inifile.Free;
    exit;
  end;
  inifile := tinifile.Create(inif);
  inifile.WriteString(section, key, Value);
  inifile.Free;

end;

function getinistring(inif: string; section: string; key: string): string;
var
  inifile: tinifile;
begin
  Result := '';
  if file_exists(inif) = False then
  begin
    log_add('File ' + inif + ' does not exist!');
    exit;
  end;
  inifile := tinifile.Create(inif);
  if inifile.ValueExists(section, key) = False then
  begin
    Result := 'Key doesn''t exist';
    inifile.Free;
    exit;
  end;
  Result := inifile.readstring(section, key, '');
  inifile.Free;
end;

function getiniboolean(inif: string; section: string; key: string): boolean;
var
  inifile: tinifile;
begin
  Result := False;
  if file_exists(inif) = False then
  begin
    log_add('File ' + inif + ' does not exist!');
    exit;
  end;
  inifile := tinifile.Create(inif);
  if inifile.ValueExists(section, key) = False then
  begin
    Result := False;
    log_add('Key does not exist.');
    inifile.Free;
    exit;
  end;
  Result := inifile.readbool(section, key, False);
  inifile.Free;
end;

procedure colorizetexture(var txt: zglPTexture; color: longword);
var
  tmp: zglPTexture;
begin
  tmp := tex_Add;
  tmp := tex_CreateZero(txt^.Width, txt^.Height, Color);
  tex_SetMask(txt, tmp);
  tex_del(tmp);
end;


procedure ScreenToTGA(Width, Height: integer; const FileName: string);
var
  i, t: integer;
  tga: zglTTGAHeader;
  f: zglTFile;
  Data: Pointer;
begin
  scr_ReadPixels(Data, 0, 0, Width, Height);

  for i := 0 to Width * Height - 1 do
  begin
    t := PByte(Ptr(Data) + i * 4 + 0)^;
    PByte(Ptr(Data) + i * 4 + 0)^ := PByte(Ptr(Data) + i * 4 + 2)^;
    PByte(Ptr(Data) + i * 4 + 2)^ := t;
    PByte(Ptr(Data) + i * 4 + 3)^ := 255;
  end;

  FillChar(tga, SizeOf(zglTTGAHeader), 0);
  tga.ImageType := 2;
  tga.ImgSpec.Width := Width;
  tga.ImgSpec.Height := Height;
  tga.ImgSpec.Depth := 32;
  tga.ImgSpec.Desc := 8;

  file_Open(f, FileName, FOM_CREATE);
  file_Write(f, tga, SizeOf(zglTTGAHeader));
  file_Write(f, Data^, Width * Height * 4);
  file_Close(f);
  zgl_FreeMem(Data);
end;

function Setintransition(tr: string): byte;
begin
  case U_strup(tr) of
    'SLIDE_LEFT':
    begin
      Result := 2;

    end;
    'SLIDE_RIGHT':
    begin
      Result := 1;

    end;
    'SLIDE_UP':
    begin
      Result := 3;

    end;
    'SLIDE_DOWN':
    begin
      Result := 4;

    end;
    'ZOOM_IN':
    begin
      Result := 5;

    end;
    'ZOOM_OUT':
    begin
      Result := 6;

    end;
    'SLIDE_FROM_LEFT':
    begin
      Result := 7;

    end;
    'SLIDE_FROM_RIGHT':
    begin
      Result := 8;

    end;
    'SLIDE_FROM_TOP':
    begin
      Result := 9;

    end;
    'SLIDE_FROM_BOTTOM':
    begin
      Result := 10;

    end;
    'SWIRL_IN': Result := 11;
    'SWIRL_OUT': Result := 12;
    else
      Result := 0
  end;

end;

procedure wraplist(var sl: TStringList; str: string; size: integer);
var
  s: string;
  dx: integer;
begin
  s := str;
  dx := size;
  while dx <= length(s) do
  begin
    repeat
      dx := dx - 1;
    until (s[dx] = ' ') or (s[dx] = '.') or (s[dx] = ',') or (s[dx] = crlf) or (dx <= 1);
    sl.add(copy(s, 1, dx));
    Delete(s, 1, dx);
    dx := size;
    if length(s) <= size then
    begin
      sl.add(copy(s, 1, length(s)));
    end;
  end;
  sl.add(copy(s, 1, length(s)));
end;

function poscount(const S: string; const C: char): integer;
var
  i: integer;
begin
  Result := 0;
  for i := 1 to Length(S) do
    if S[i] = C then
      Inc(Result);
end;

begin
end.
