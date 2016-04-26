unit thtextvieweru;

interface

{$I zglCustomConfig.cfg}
uses
  {$IFDEF USE_ZENGL_STATIC}
  zgl_mouse,
  zgl_window,
  zgl_log,
  zgl_fx,
  zgl_textures,
  zgl_textures_png,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_math_2d,
  zgl_application,
  zgl_collision_2d,
  zgl_video,
  zgl_camera_2d,
  Classes,
  SysUtils,
  tools,
  DB, sqlite3ds
    {$ELSE}
  zglHeader
  {$ENDIF}         ;

type

  thtextviewer = class(TObject)
    x, y: integer;
    Width, Height: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    r: zglTRect;
    align_hor: byte;
    color: longword;
    click: boolean;
    command: utf8string;
    opacity: byte;
    update: boolean;
    index: integer;
    textsl: TStringList;
    xx, xy: integer;
    chars, Lines: integer;
    wrap: boolean;
    opac2: byte;
    constructor init;
    destructor Free;
    procedure draw(font: zglPFont; opac: byte);
    function Mouseover(fnt: zglPFont): boolean;
    procedure keyup;
    procedure keydown;
    procedure keyleft;
    procedure keyright;
    procedure keypgdown;
    procedure keypgup;
  end;

implementation

constructor thtextviewer.init;
begin
  x := 0;
  y := 0;
  wrap := False;
  Width := 500;
  Height := 100;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  color := $ffffff;
  click := False;
  command := '';
  opacity := 255;
  update := False;
  index := 0;
  opac2 := 0;
  r.x := 0;
  r.y := 0;
  r.w := 0;
  r.h := 0;
  align_hor := 0;
  textsl := TStringList.Create;
  xx := 0;
  xy := 0;
  chars := 20;
  Lines := 5;
end;

destructor thtextviewer.Free;
begin
  textsl.Free;
end;

procedure thtextviewer.draw(font: zglPFont; opac: byte);
var
  d: integer;
begin
  if textsl.Text = '' then
    exit;
  d := 0;

  while (d <= Lines - 1) and (d <= textsl.Count - 1) do
  begin
    r.x := x;
    r.w := Width;
    r.y := y + (d * font^.maxheight);
    r.h := font^.maxheight;
    try
      text_DrawInRectex(font, r, 1, 0, copy(textsl[d + xy], xx + 1, chars), opac, color, align_hor or
        TEXT_VALIGN_CENTER);
    except
    end;
    d := d + 1;
    if (d + xy > textsl.Count - 1) then
      exit;
  end;
  opac2 := opac2 + 1;
  if opac2 >= 255 then
    opac2 := 0;
  if xy > 0 then
  begin
    pr2d_Circle(x + Width / 2 - 10, Y + 3, 3, Color, opac2, 16, pr2d_fill);
    pr2d_Circle(x + Width / 2, Y + 3, 3, Color, opac2, 16, pr2d_fill);
    pr2d_Circle(x + Width / 2 + 10, Y + 3, 3, Color, opac2, 16, pr2d_fill);
  end;
  if d + xy < textsl.Count - 1 then
  begin
    pr2d_Circle(r.x + r.w / 2 - 10, r.Y + r.h - 3, 3, Color, opac2, 16, pr2d_fill);
    pr2d_Circle(r.x + r.w / 2, r.Y + r.h - 3, 3, Color, opac2, 16, pr2d_fill);
    pr2d_Circle(r.x + r.w / 2 + 10, r.Y + r.h - 3, 3, Color, opac2, 16, pr2d_fill);
  end;
end;

function thtextviewer.Mouseover(fnt: zglPFont): boolean;
var
  ri: zglTRect;
begin
  ri.X := x;
  ri.Y := y;
  ri.W := chars * (fnt^.chardesc[0]^.Width);
  ri.H := Lines * fnt^.maxheight;
  Result := col2d_PointInRect(mouse_X, mouse_Y, ri);
end;

procedure thtextviewer.keyup;
begin
  xy := xy - 1;
  if xy <= 0 then
    xy := 0;
end;

procedure thtextviewer.keypgup;
begin
  xy := xy - Lines - 1;
  if xy <= 0 then
    xy := 0;
end;

procedure thtextviewer.keydown;
begin
  if xy + Lines >= textsl.Count - 1 then
    exit;
  xy := xy + 1;
end;

procedure thtextviewer.keypgdown;
begin
  if xy + Lines - 1 >= textsl.Count - 1 then
    exit;
  xy := xy + Lines - 1;
end;


procedure thtextviewer.keyleft;
begin
  xx := xx - 1;
  if xx <= 0 then
    xx := 0;
end;

procedure thtextviewer.keyright;
begin
  xx := xx + 1;
end;

begin
end.
