unit thobjects;

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
  {$ENDIF}       ;

const
  TRANS_SLIDE_LEFT = 1;
  TRANS_SLIDE_RIGHT = 2;
  TRANS_SLIDE_UP = 3;
  TRANS_SLIDE_DOWN = 4;
  TRANS_ZOOM_IN = 5;
  TRANS_ZOOM_OUT = 6;
  TRANS_SLIDE_FROM_LEFT = 7;
  TRANS_SLIDE_FROM_RIGHT = 8;
  TRANS_SLIDE_FROM_TOP = 9;
  TRANS_SLIDE_FROM_BOTTOM = 10;
  TRANS_SWIRL_IN = 11;
  TRANS_SWIRL_OUT = 12;

type

  TAppSettings = record
    index: integer;

  end;

  thscreen = class(TObject)
    x, y: single;
    Width, Height: integer;
    direction: byte;
    trans_in: byte;
    speed: single;
    trans_out: byte;
    trans_done: boolean;
    //camera:zglTCamera2D;
    intrans: boolean;
    transout: boolean;
    constructor Init;
    destructor Free;
    procedure draw(var cam: zglTCamera2D);
    procedure resetcam(var cam: zglTCamera2D);
    procedure Inittransition(var camera: zglTCamera2D; tr: byte; outtrans: boolean);

  end;

  thsqlite = class(TObject)
    filename: utf8string;
    sql: utf8string;
    active: boolean;
    ItemIndex: integer;
    Count: integer;
    table: utf8string;
    ds: TSQLite3Dataset;
    constructor Init;
    destructor Free;
    procedure opendatabase(s: utf8string; tablename: utf8string);
    procedure sqlexec(sqls: string);
    procedure deleterecord;
    procedure gotorec(d: integer);
    procedure nextrecord;
    procedure prevrecord;
    procedure firstrecord;
    procedure lastrecord;
    procedure applyupdates;
    procedure countitems;
    function getfield(n: byte): utf8string;
    procedure sqlupdate(sqls: string);
  end;

  thgauge = class(TObject)
    y, h, x, w: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    opacity: byte;
    bgopac: byte;
    img: zglPTexture;
    bgimg: zglPTexture;
    min, max, pos: integer;
    index: integer;
    command: utf8string;
    angle: single;
    constructor Init;
    destructor Free;
    procedure Draw;
    function Mouseover: boolean;
    procedure Increase;
    procedure Decrease;
  end;

  THButton = class(TObject)
    Caption: utf8string;
    color: longword;
    rf: zglTRect;
    x, y, w, h: single;
    image: zglPTexture;
    image_down: zglPTexture;
    click: boolean;
    command: utf8string;
    opacity: byte;
    opac2: byte;
    index: integer;
    sliding: byte;
    resize: boolean;
    update: boolean;
    slide_pos: integer;
    speed: single;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    fadedir: byte;
    constructor Init;
    destructor Free;
    procedure SlidefromLeft;
    procedure Fade(dir: byte);
    procedure Draw(font: zglPfont; pressed: boolean);
    function Mouseover: boolean;
  end;

  THProgress = class(TObject)
    x, y, w, h: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    image_empty: zglPTexture;
    image_full: zglPTexture;
    vertical: boolean;
    min, max, pos: integer;
    command: utf8string;
    opacity: byte;
    index: integer;
    constructor Init;
    destructor Free;
    procedure Draw;
    function Mouseover: boolean;
    procedure Increase;
    procedure Decrease;
  end;

  THSlider = class(TObject)
    x, y, w, h: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    image_bg: zglPTexture;
    image_fg: zglPTexture;
    vertical: boolean;
    min, max, pos: integer;
    command: utf8string;
    opacity: byte;
    index: integer;
    Enabled: boolean;
    constructor Init;
    destructor Free;
    procedure Draw;
    function Mouseover: boolean;
    procedure Increase;
    procedure Decrease;
  end;

  THpanel = class(TObject)
    x, y, w, h: integer;
    image_tl, image_t, image_tr, image_l, image_r, image_bl,
    image_b, image_br: zglPTexture;
    color: longword;
    Enabled: boolean;
    opacity: byte;
    index: integer;
    constructor Init;
    destructor Free;
    procedure Draw;
    function Mouseover: boolean;
  end;

  THswitch = class(TObject)
    x, y, w, h: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    imageon, imageoff: zglPTexture;
    color: longword;
    click: boolean;
    command_on: utf8string;
    command_off: utf8string;
    opacity: byte;
    Checked: boolean;
    index: integer;
    constructor Init;
    destructor Free;
    procedure draw;
    function Mouseover: boolean;
  end;


  THVideo = class(TObject)
    x, y, w, h: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    vid: zglPVideoStream;
    filename: utf8string;
    seek: boolean;
    Enabled: boolean;
    click: boolean;
    play: boolean;
    index: integer;
    opacity, opac: byte;
    fadedir: byte;
    constructor init;
    destructor Free;
    procedure draw;
    procedure fade(dir: byte);
    function Mouseover: boolean;
  end;


  thlabel = class(TObject)
    x, y: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    align: byte;
    Caption: utf8string;
    capt2: utf8string;
    color: longword;
    click: boolean;
    command: utf8string;
    opacity: byte;
    update: boolean;
    timer: boolean;
    scale: single;
    index: integer;
    len: integer;
    dir: byte;
    mi: integer;
    td: integer;
    constructor Init;
    destructor Free;
    function marqee: utf8string;
    procedure draw(font: zglPFont; opac: byte);
    function Mouseover(fnt: zglPFont): boolean;
  end;

  thtext = class(TObject)
    x, y: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    r: zglTRect;
    align_hor: byte;
    align_ver: byte;
    Caption: utf8string;
    color: longword;
    click: boolean;
    command: utf8string;
    opacity: byte;
    timer: boolean;
    update: boolean;
    index: integer;
    constructor init;
    destructor Free;
    procedure draw(font: zglPFont; opac: byte);
    function Mouseover(fnt: zglPFont): boolean;
  end;

  thedittext = class(TObject)
    x, y, w, h: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    align: byte;
    Caption: utf8string;
    color: longword;
    click: boolean;
    command: utf8string;
    opacity: byte;
    edit: boolean;
    trackinput: boolean;
    length: byte;
    index: integer;
    constructor Init;
    destructor Free;
    procedure Draw(font: zglPFont; opac: byte);
    function Mouseover(fnt: zglPFont): boolean;
  end;

procedure timerbb;

implementation

procedure timerbb;
begin
  //asd
end;

constructor thscreen.Init;
begin
  x := 0;
  y := 0;
  Width := 0;
  Height := 0;
  speed := 1;
  direction := 0;
  intrans := False;
  trans_in := 0;
  trans_out := 0;
  trans_done := False;
  transout := False;
end;

destructor thscreen.Free;
begin
  //asd

end;

procedure thscreen.resetcam(var cam: zglTCamera2D);
begin
  cam2d_Init(cam);
end;

procedure thscreen.Inittransition(var camera: zglTCamera2D; tr: byte; outtrans: boolean);
begin
  case tr of
    TRANS_SLIDE_LEFT:
    begin
      direction := tr;
      camera.x := -1;
      camera.y := 0;
      speed := 1.3;
    end;
    TRANS_SLIDE_RIGHT:
    begin
      direction := tr;
      camera.x := 1;
      camera.y := 0;
      speed := 1.3;
    end;
    TRANS_SLIDE_UP:
    begin
      direction := tr;
      camera.x := 0;
      camera.y := 1;
      speed := 1.3;
    end;
    TRANS_SLIDE_DOWN:
    begin
      direction := tr;
      camera.x := 0;
      camera.y := -1;
      speed := 1.3;
    end;
    TRANS_ZOOM_IN:
    begin
      direction := tr;
      cam2d_init(camera);
      speed := 1.1;
    end;
    TRANS_ZOOM_OUT:
    begin
      direction := tr;
      cam2d_init(camera);
      camera.zoom.x := 4;
      camera.zoom.y := 4;
      speed := 1.1;
    end;
    trans_SWIRL_IN:
    begin
      direction := tr;
      cam2d_init(camera);
      speed := 1.1;
    end;
    trans_SWIRL_OUT:
    begin
      direction := tr;
      cam2d_init(camera);
      camera.angle := 45;
      camera.zoom.x := 4;
      camera.zoom.y := 4;
      speed := 1.1;
    end;
    TRANS_SLIDE_FROM_LEFT:
    begin
      direction := tr;
      camera.x := Width;
      camera.y := 0;
      speed := 1.3;
    end;
    TRANS_SLIDE_FROM_RIGHT:
    begin
      direction := tr;
      camera.x := -Width;
      camera.y := 0;
      speed := 1.3;
    end;
    TRANS_SLIDE_FROM_bottom:
    begin
      direction := tr;
      camera.x := 0;
      camera.y := -Height;
      speed := 1.3;
    end;
    TRANS_SLIDE_FROM_top:
    begin
      direction := tr;
      camera.x := 0;
      camera.y := Height;
      speed := 1.3;
    end;

  end;
{
  TRANS_SLIDE_LEFT = 1;
  TRANS_SLIDE_RIGHT = 2;
  TRANS_SLIDE_UP = 3;
  TRANS_SLIDE_DOWN = 4;
  TRANS_ZOOM_IN = 5;
  TRANS_ZOOM_OUT = 6;
  TRANS_SLIDE_FROM_LEFT = 7;
  TRANS_SLIDE_FROM_RIGHT = 8;
  TRANS_SLIDE_FROM_TOP = 9;
  TRANS_SLIDE_FROM_BOTTOM = 10;
}

  intrans := True;
  transout := outtrans;
end;

procedure thscreen.draw(var cam: zglTCamera2D);
begin
  if not intrans then
    exit;
  case direction of
    TRANS_SLIDE_left:
    begin

      cam.x := cam.x * speed;
      if cam.x <= -Width then
      begin
        cam.x := 0;
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_right:
    begin

      cam.x := cam.x * speed;
      if cam.x >= Width then
      begin
        intrans := False;
        cam.x := 0;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_UP:
    begin
      cam.y := cam.y * speed;
      if cam.y >= Height then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_DOWN:
    begin
      cam.y := cam.y * speed;
      if cam.y <= -Height then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
        cam.y := 0;
      end;
    end;
    TRANS_ZOOM_IN:
    begin
      cam.zoom.x := cam.zoom.x * speed;
      cam.zoom.y := cam.zoom.y * speed;
      if cam.zoom.x >= 4 then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
        cam2d_init(cam);
      end;
    end;
    TRANS_ZOOM_OUT:
    begin
      cam.zoom.x := cam.zoom.x / speed;
      cam.zoom.y := cam.zoom.y / speed;
      if cam.zoom.x <= 1 then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
        cam2d_init(cam);
      end;
    end;
    TRANS_SWIRL_IN:
    begin
      cam.angle := cam.angle + (3 * speed);
      cam.zoom.x := cam.zoom.x * speed;
      cam.zoom.y := cam.zoom.y * speed;
      if cam.zoom.x >= 4 then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
        cam2d_init(cam);
      end;
    end;
    TRANS_SWIRL_OUT:
    begin
      cam.angle := cam.angle - (3 * speed);
      cam.zoom.x := cam.zoom.x / speed;
      cam.zoom.y := cam.zoom.y / speed;
      if cam.zoom.x <= 1 then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
        cam2d_init(cam);
      end;
    end;
    TRANS_SLIDE_FROM_right:
    begin
      cam.x := cam.x / speed;
      if cam.x >= -1 then
      begin
        intrans := False;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_FROM_left:
    begin
      cam.x := cam.x / speed;
      if cam.x <= 1 then
      begin
        intrans := False;
        cam.x := 0;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_FROM_top:
    begin
      cam.y := cam.y / speed;
      if cam.y <= 1 then
      begin
        intrans := False;
        cam.y := 0;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;
    TRANS_SLIDE_FROM_bottom:
    begin
      cam.y := cam.y / speed;
      if cam.y >= -1 then
      begin
        intrans := False;
        cam.y := 0;
        cam2d_Init(cam);
        if transout then
          trans_done := True;
      end;
    end;

  end;
end;


constructor thgauge.Init;
begin
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  opacity := 100;
  bgopac := 255;
  img := nil;
  bgimg := nil;
  min := 0;
  max := 100;
  pos := 0;
  command := '';
  angle := 0;
  index := 0;
end;

destructor thgauge.Free;
begin
  tex_del(img);
  tex_del(bgimg);

end;

procedure thgauge.Draw;
begin
  angle := 360 * pos / max;
  ssprite2d_Draw(bgimg, x, y, bgimg^.Width, bgimg^.Height, 0, bgopac);
  ssprite2d_Draw(img, x, y, img^.Width, img^.Height, angle, opacity);
end;

function thgauge.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

procedure thgauge.Increase;
begin
  pos := pos + 1;
  if pos > max then
    pos := max;
end;

procedure thgauge.Decrease;
begin
  pos := pos - 1;
  if pos < min then
    pos := min;
end;

constructor thvideo.init;
begin
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  vid := nil;
  filename := '';
  seek := False;
  Enabled := False;
  play := False;
  click := True;
  opac := opacity;
  fadedir := 0;
  index := 0;
end;

destructor thvideo.Free;
begin
  //asd

end;

procedure thvideo.fade(dir: byte);
begin
  case dir of
    1: fadedir := 1;
    2: fadedir := 2;
  end;
  opac := opacity;
end;

procedure thvideo.draw;
begin
  if not assigned(vid) then
    exit;
  case fadedir of
    1:
    begin
      opac := opac - 1;
      if opac <= 0 then
      begin
        opac := 0;
        fadedir := 0;
      end;
    end;
    2:
    begin
      opac := opac + 1;
      if opac >= 255 then
      begin
        opac := 255;
        fadedir := 0;
      end;
    end;
  end;
  ssprite2d_Draw(vid^.Texture, x, y, vid^.Info.Width, vid^.Info.Height, 0, opac);
end;

function thvideo.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thlabel.init;
begin
  x := 0;
  y := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  align := 0;
  Caption := '';
  color := $ffffff;
  scale := 1;
  click := False;
  command := '';
  update := False;
  opacity := 255;
  timer := False;
  index := 0;
  len := 0;
  dir := 0;
  mi := 1;
  capt2 := marqee;
  td := 0;
end;

destructor thlabel.Free;
begin
  //asd

end;

function thlabel.marqee: utf8string;
begin
  if (len = 0) or (length(Caption) <= len) then
  begin
    Result := Caption;
    dir := 0;
    exit;
  end;
  Result := copy(Caption, mi, len);
  td := td + 1;
  if td < appfps div 2 then
    exit;
  td := 0;
  case dir of
    1:
    begin //left
      mi := mi - 1;
      if mi = 1 then
        dir := 2;
    end;
    2:
    begin
      mi := mi + 1;
      if mi + len >= length(Caption) + 1 then
        dir := 1;
    end;
    0: dir := 2;
  end;

end;

procedure thlabel.draw(font: zglPFont; opac: byte);
begin

  if click and mouseover(font) then
    text_Drawex(font, x, y, scale, 0, capt2, 255, color, align)
  else
    text_Drawex(font, x, y, scale, 0, capt2, opacity, color, align);
  capt2 := marqee;
end;

function thlabel.Mouseover(fnt: zglPFont): boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := text_GetWidth(fnt, Caption);
  r.H := text_GetHeight(fnt, r.w, Caption, scale);
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

//thtext
constructor thtext.init;
begin
  x := 0;
  y := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  Caption := '';
  color := $ffffff;
  click := False;
  command := '';
  opacity := 255;
  timer := False;
  update := False;
  index := 0;
  r.x := 0;
  r.y := 0;
  r.w := 0;
  r.h := 0;
  align_hor := 0;
  align_ver := 0;
end;

destructor thtext.Free;
begin
  //asd

end;

procedure thtext.draw(font: zglPFont; opac: byte);
begin
  if Caption = '' then
    exit;
  text_DrawInRectex(font, r, 1, 0, Caption, opac, color, align_hor or align_ver);
end;

function thtext.Mouseover(fnt: zglPFont): boolean;
var
  ri: zglTRect;
begin
  ri.X := x;
  ri.Y := y;
  ri.W := text_GetWidth(fnt, Caption);
  ri.H := text_GetHeight(fnt, r.w, Caption, 0.9);
  Result := col2d_PointInRect(mouse_X, mouse_Y, ri);
end;

//thedittext

constructor thedittext.init;
begin
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  align := 0;
  Caption := '';
  color := $ffffff;
  click := False;
  command := '';
  opacity := 255;
  edit := False;
  trackinput := False;
  length := 254;
  index := 0;
end;

destructor thedittext.Free;
begin
  //asd

end;

procedure thedittext.Draw(font: zglPFont; opac: byte);
begin
  text_Drawex(font, x, y, 1, 0, Caption, opacity, color, align);
end;

function thedittext.Mouseover(fnt: zglPFont): boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := text_GetWidth(fnt, Caption);
  r.H := text_GetHeight(fnt, r.w, Caption, 0.9);
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thbutton.init;
begin
  image := nil;
  image_down := nil;
  Caption := '';
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  rf.x := 0;
  rf.y := 0;
  rf.w := 0;
  rf.h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  click := False;
  update := False;
  command := '';
  opacity := 255;
  opac2 := 255;
  index := 0;
  sliding := 0;
  resize := False;
  slide_pos := 1;
  speed := 1.2;
  fadedir := 0;
  color := $000000;
end;

destructor thbutton.Free;
begin
  tex_del(image);
  tex_del(image_down);
end;

procedure thbutton.SlidefromLeft;
begin
  sliding := 4;
end;

procedure thbutton.fade(dir: byte);
begin
  case dir of
    1: fadedir := 1;
    2: fadedir := 2;
  end;
  opac2 := opacity;
end;

procedure Thbutton.Draw(font: zglPfont; pressed: boolean);
begin
  case sliding of
    1:
    begin
      y := y / speed;
      if y < -h then
        sliding := 0;
    end;
    2:
    begin
      x := x * speed;
      if x >= wndwidth then
        sliding := 0;
    end;
    3:
    begin
      y := y * speed;
      if y >= wndHeight then
        sliding := 0;
    end;
    4:
    begin
      x := x / speed;
      if x < -w then
        sliding := 0;
    end;
    11:
    begin
      y := y / speed;
      if y <= (wndheight / 2) - (h / 2) then
        sliding := 0;
    end;
    12:
    begin
      x := x * speed;
      if x >= (wndwidth / 2) - (w / 2) then
        sliding := 0;
    end;
    13:
    begin
      y := y * speed;
      if y >= (wndheight / 2) - (h / 2) then
        sliding := 0;
    end;
    14:
    begin
      x := x / speed;
      if x < (wndwidth / 2) - (w / 2) then
        sliding := 0;
    end;
  end;
  case fadedir of
    1:
    begin
      opac2 := opac2 - 1;
      if opac2 <= 0 then
      begin
        opac2 := 0;
        fadedir := 0;
      end;
    end;
    2:
    begin
      opac2 := opac2 + 1;
      if opac2 >= 255 then
      begin
        opac2 := 255;
        fadedir := 0;
      end;
    end;
  end;
  if color = $00000 then
    if mouseover and click then
      ssprite2d_Draw(image_down, x, y, w, h, 0, opac2)
    else
      ssprite2d_Draw(image, x, y, w, h, 0, opac2)
  else
  begin
    fx2d_SetColor(color);
    if mouseover and click then
      ssprite2d_Draw(image_down, x, y, w, h, 0, opac2, FX_BLEND or FX_COLOR)
    else
      ssprite2d_Draw(image, x, y, w, h, 0, opac2, FX_BLEND or FX_COLOR);
  end;
  text_DrawInRectex(font, rf, 1, 0, Caption, opacity, color, TEXT_HALIGN_CENTER or
    TEXT_VALIGN_CENTER);
end;

function Thbutton.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thslider.init;
begin
  image_bg := nil;
  image_fg := nil;
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  vertical := True;
  min := 0;
  max := 100;
  pos := 0;
  command := '';
  opacity := 255;
  index := 0;
  Enabled := True;
end;

destructor thslider.Free;
begin
  tex_del(image_fg);
  tex_del(image_bg);

end;

procedure thslider.Draw;
var
  dx: integer;
  iy: single;
begin
  iy := pos * (h - image_fg^.Height) / max;

  dx := (image_bg^.Width - image_fg^.Width) div 2;
  ssprite2d_Draw(image_bg, x, y,
    w, h, 0, opacity);
  ssprite2d_Draw(image_fg, x + dx,
    y + h - image_fg^.Height - iy,
    image_fg^.Width, image_fg^.Height,
    0, opacity);

end;

function thslider.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

procedure thslider.Increase;
begin
  pos := pos + 1;
  if pos > max then
    pos := max;
end;

procedure thslider.Decrease;
begin
  pos := pos - 1;
  if pos < min then
    pos := min;
end;

constructor thprogress.init;
begin
  image_empty := nil;
  image_full := nil;
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  image_empty := nil;
  image_full := nil;
  vertical := True;
  min := 0;
  max := 100;
  pos := 0;
  command := '';
  opacity := 255;
  index := 0;
end;

destructor thprogress.Free;
begin
  tex_del(image_empty);
  tex_del(image_full);

end;

procedure thprogress.Draw;
var
  r: zglTRect;
begin
  ssprite2d_Draw(image_empty, x, y, w, h, 0, opacity);
  if not vertical then
  begin
    r.X := 0;
    r.Y := 0;
    r.W := (pos - min) * w / (max - min);
    r.H := h;
    csprite2d_Draw(image_full, x, y, r.w, h, 0, r, opacity);
  end
  else
  begin
    r.X := 0;
    r.Y := 0;
    r.W := w;
    r.H := (pos - min) * h / max - min;
    csprite2d_Draw(image_full, x, y, w, r.h, 0, r, opacity);
  end;
end;

procedure thprogress.Increase;
begin
  pos := pos + 1;
  if pos > max then
    pos := max;
end;

procedure thprogress.Decrease;
begin
  pos := pos - 1;
  if pos < min then
    pos := min;
end;

function thprogress.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thswitch.init;
begin
  imageon := nil;
  imageoff := nil;
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  top := 0;
  bottom := 0;
  left := 0;
  right := 0;
  color := $000000;
  click := True;
  command_on := '';
  command_off := '';
  opacity := 255;
  Checked := False;
  index := 0;
end;

destructor thswitch.Free;
begin
  tex_del(imageon);
  tex_del(imageoff);

end;

procedure thswitch.draw;
begin
  if Checked then
    ssprite2d_Draw(imageon,
      x, y,
      w, h, 0,
      opacity)
  else
    ssprite2d_Draw(imageoff,
      x, y,
      w, h, 0,
      opacity);
end;

function thswitch.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thpanel.init;
begin
  image_tl := nil;
  image_t := nil;
  image_tr := nil;
  image_l := nil;
  image_r := nil;
  image_bl := nil;
  image_b := nil;
  image_br := nil;
  x := 0;
  y := 0;
  w := 0;
  h := 0;
  color := $000000;
  Enabled := True;
  opacity := 255;
  index := 0;
end;

destructor thpanel.Free;
begin
  tex_del(image_tl);
  tex_del(image_t);
  tex_del(image_tr);
  tex_del(image_l);
  tex_del(image_r);
  tex_del(image_bl);
  tex_del(image_b);
  tex_del(image_br);

end;

procedure thpanel.draw;
var
  k: byte;
begin
  fx_SetBlendMode(FX_BLEND_NORMAL);
  pr2d_Rect(x + 5, y + 5, w - 10, h - 10, color, opacity, PR2D_fill);
  k := 0;
  while (k * image_l^.Height) <= h - image_tr^.Height - image_br^.Height do
  begin
    ssprite2d_Draw(image_l, x, y + image_tl^.Height + (k * image_l^.Height),
      image_l^.Width,
      image_l^.Height, 0, opacity);
    k := k + 1;
  end;
  k := 0;
  while (k * image_r^.Height) < h - image_br^.Height - image_tr^.Height do
  begin
    ssprite2d_Draw(image_r, x + w - image_r^.Width, y + image_tr^.Height +
      (k * image_r^.Height), image_r^.Width, image_r^.Height, 0, opacity);
    k := k + 1;
  end;
  k := 0;
  while (k * image_t^.Width) <= w - image_tr^.Width - image_tl^.Width do
  begin
    ssprite2d_Draw(image_t, x + image_tr^.Width + (k * image_t^.Width),
      y, image_t^.Width,
      image_t^.Height, 0, opacity);
    k := k + 1;
  end;
  k := 0;
  while (k * image_b^.Width) <= w - image_br^.Width - image_bl^.Width do
  begin
    ssprite2d_Draw(image_b, x + image_bl^.Width + (k * image_b^.Width),
      y + h - image_br^.Height,
      image_b^.Width, image_b^.Height, 0, opacity);
    k := k + 1;
  end;
  ssprite2d_Draw(image_bl, x, y + h - image_bl^.Height, image_bl^.Width,
    image_bl^.Height, 0, opacity);
  ssprite2d_Draw(image_br, x + w - image_br^.Width, y + h - image_br^.Height,
    image_br^.Width, image_br^.Height, 0, opacity);
  ssprite2d_Draw(image_tl, x, y, image_tl^.Width, image_tl^.Height, 0, opacity);
  ssprite2d_Draw(image_tr, x + w - image_tr^.Width, y, image_tr^.Width,
    image_tr^.Height, 0, opacity);

end;

function thpanel.Mouseover: boolean;
var
  r: zglTRect;
begin
  r.X := x;
  r.Y := y;
  r.W := w;
  r.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, r);
end;

constructor thsqlite.Init;
begin
  filename := '';
  sql := '';
  ItemIndex := 0;
  active := False;
  table := '';
  Count := 0;
  ds := TSqlite3Dataset.Create(nil);
end;

destructor thsqlite.Free;
begin
  ds.Free;

end;

procedure thsqlite.opendatabase(s: utf8string; tablename: utf8string);
begin
  if ds.active = True then
    ds.Close;
  if fileexists(s) = False then
  begin
    log_add('[e101] Database does not exist. Press any key to continue...');
  end
  else
  begin
    try
      with ds do
      begin
        FileName := s;
        ds.tablename := tablename;
        sql := 'PRAGMA encoding = "el.utf8"';
        execsql;
        Sql := 'select * from games';
        Open;
        while not ds.EOF do
        begin
          Count := Count + 1;
          ds.Next;
        end;
        firstrecord;
      end;
    except
      log_add('Error opening database. Press any key to continue...');
    end;
  end;
end;

procedure thsqlite.sqlexec(sqls: string);
begin
  if ds.active = True then
    ds.Close;
  ds.Sql := sqls;
  ds.Open;
  firstrecord;
  countitems;
end;

procedure thsqlite.sqlupdate(sqls: string);
begin
  ds.execsql(sqls);
  ds.applyupdates;
end;

procedure thsqlite.applyupdates;
begin
  ds.applyupdates;
end;

procedure thsqlite.nextrecord;
begin
  if ds.active then
  begin
    ds.Next;
    ItemIndex := ItemIndex + 1;
    if ItemIndex > Count - 1 then
      ItemIndex := Count - 1;
  end;
end;

procedure thsqlite.prevrecord;
begin
  if ds.active then
  begin
    ds.prior;
    ItemIndex := ItemIndex - 1;
    if ItemIndex < 0 then
      ItemIndex := 0;
  end;
end;

procedure thsqlite.firstrecord;
begin
  if ds.active then
  begin
    ds.First;
    ItemIndex := 0;
  end;
end;

procedure thsqlite.lastrecord;
begin
  if ds.active then
  begin
    ds.last;
    ItemIndex := ds.RecordCount - 1;
  end;
end;

procedure thsqlite.gotorec(d: integer);
var
  i: integer;
begin
  while not ds.EOF do
  begin
    firstrecord;
    for i := 1 to d - 1 do
      nextrecord;
  end;
end;

procedure thsqlite.deleterecord;
begin
  try
    ds.Delete;
    ds.applyupdates;
    Count := Count - 1;
    if Count < 0 then
      Count := 0;
    ItemIndex := ItemIndex - 1;
    if ItemIndex < 0 then
      ItemIndex := 0;
    log_add('Sqlite: Record deleted succesful');
  except
    log_add('Sqlite: Error while deleting record');
  end;
end;

procedure thsqlite.countitems;
begin
  Count := 0;
  while not ds.EOF do
  begin
    Count := Count + 1;
    ds.Next;
  end;
  ds.First;
end;

function thsqlite.getfield(n: byte): utf8string;
begin
  if (ds.active) and (ds.fields.Count <= n) then
    Result := ds.fields[n].AsString;
end;

begin
end.
