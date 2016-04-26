unit thCommonObjects;

interface

{$I zglCustomConfig.cfg}
uses
  {$IFDEF USE_ZENGL_STATIC}
  zgl_main,
  zgl_mouse,
  zgl_textures,
  zgl_textures_png,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_math_2d,
  zgl_collision_2d,
  zgl_utils,
  zgl_timers,
  Classes,
  process,
  SysUtils,
  tools
    {$ELSE}
  zglHeader
  {$ENDIF}  ;

type

  thtimer = class(TObject)
    timer: zglPTimer;
    interval: integer;
    commands: TStringList;
    ItemIndex: integer;
    constructor Init;
    destructor Free;
    procedure StopTimer;
    procedure StartTimer;
    procedure Timerab;
    procedure AddCommand(s: utf8string);
    procedure DelCommand(idx: integer);
  end;

  Ththrobber = class(TObject)
    x, y, w, h: integer;
    image: zglPTexture;
    opacity: byte;
    Visible: boolean;
    timer: integer;
    imgindex: word;
    constructor Init;
    destructor Free;
    procedure Draw(Width, Height: integer);
  end;

  Thclock = class(TObject)
    x, y: integer;
    w: integer;
    click: boolean;
    command: utf8string;
    format: utf8string;
    Caption: utf8string;
    color: longword;
    opacity: byte;
    index: integer;
    constructor Init;
    destructor Free;
    procedure draw(font: zglPFont; opac: byte);
    function Mouseover(fnt: zglPFont): boolean;
  end;

  ttheme = record
    Name: utf8string;
    Width: integer;
    Height: integer;
    screen: utf8string;
    intro_sound: utf8string;
    click_sound: utf8string;
    error_sound: utf8string;
    font_color: integer;
    sounds: boolean;
  end;

  THDummy = class(TObject)
    a: byte;
    constructor Init;
    destructor Free;
  end;

implementation

constructor thtimer.init;
begin
  timer := nil;
  interval := 1000;
  ItemIndex := 0;
  commands := TStringList.Create;
end;

destructor thtimer.Free;
begin
  if assigned(timer) then
    timer_del(timer);
  commands.Free;

end;

procedure thtimer.StartTimer;
begin
  //asd
end;

procedure thtimer.StopTimer;
begin
  timer_del(timer);
end;

procedure thtimer.AddCommand(s: utf8string);
begin
  commands.add(s);
end;

procedure thtimer.DelCommand(idx: integer);
begin
  commands.Delete(idx);
end;

procedure thtimer.timerab;
begin
  //asd
end;

constructor ththrobber.Init;
begin
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  image := nil;
  opacity := 255;
  Visible := True;
  timer := 1;
  imgindex := 1;
end;

destructor ththrobber.Free;
begin
  tex_del(image);

end;

procedure ththrobber.Draw(Width, Height: integer);
begin
  imgindex := imgindex + 1;
  if imgindex >= 360 then
    imgindex := 1;
  ssprite2d_Draw(image, (Width - w) div 2,
    (Height - h) div 2, w, h, imgindex,
    opacity);
end;

//thclock

constructor thclock.Init;
begin
  x := 0;
  y := 0;
  format := 'yyyy mm dd hh:mm';
  Caption := FormatDateTime(format, now);
  color := $ffffff;
  w := 0;
  opacity := 255;

  index := 0;

end;

destructor thclock.Free;
begin
  //asd

end;

procedure thclock.draw(font: zglPFont; opac: byte);
begin
  text_Drawex(font, x, y, 1, 0, FormatDateTime(format, now), opac, color, 0);
  Caption := FormatDateTime(format, now);
end;

function thclock.Mouseover(fnt: zglPFont): boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := text_GetWidth(fnt, FormatDateTime(format, now));
  r.H := text_GetHeight(fnt, r.w, FormatDateTime(format, now), 0.9);
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thdummy.init;
begin
  //as
end;

destructor thdummy.Free;
begin
  //asd

end;

begin
end.
