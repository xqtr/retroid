unit thverticalslideru;

interface

{$I zglCustomConfig.cfg}
uses
  {$IFDEF USE_ZENGL_STATIC}
  zgl_main,
  zgl_mouse,
  zgl_textures,
  zgl_textures_png,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_math_2d,
  zgl_collision_2d,
  zgl_utils,
  Classes,
  process,
  SysUtils,
  tools
    {$ELSE}
  zglHeader
  {$ENDIF}         ;

type

  thverticalslider = class(TObject)
  public
    y, h, x, w, speed: single;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    imgopac: byte;
    txtopac: byte;
    itemimg, bgimg: zglPTexture;
    imgdir, Caption, command, comsel, comnext, filen: utf8string;
    ready: boolean;
    color: longword;
    txtcolor: longword;
    opacity: integer;
    items: TStringList;
    active: boolean;
    index: integer;
    ItemIndex: integer;
    xa, xb: single;
    issliding: boolean;
    returning: boolean;
    font: zglPFont;
    r: zglTRect;
    direction: byte;
    constructor Init;
    destructor Free;
    function Mouseover: boolean;
    procedure draw;
    procedure getitem(ind: integer; var title: utf8string; var filename: utf8string;
      var coms: utf8string; var com: utf8string);
    procedure loadprevitem;
    procedure loadnextitem;
    procedure slidedown;
    procedure slideup;
    procedure start;
    function getcurrentonloadcommand: utf8string;
  end;

implementation


constructor thverticalslider.init;
begin
  y := 0;
  h := 0;
  x := 0;
  w := 0;
  top := 0;
  bottom := 0;
  imgopac := 255;
  imgdir := '';
  left := 0;
  right := 0;
  speed := 1;
  itemimg := nil;
  bgimg := nil;
  ready := False;
  color := $ffffff;
  opacity := 100;
  bottom := 0;
  items := TStringList.Create;
  Caption := '';
  command := '';
  ItemIndex := 0;
  active := False;
  issliding := False;
  direction := 0;
  xa := x;
  xb := 0;
  returning := False;
  txtopac := 0;
  txtcolor := $ffffff;
  comsel := '';
end;

destructor thverticalslider.Free;
begin
  tex_del(itemimg);
  if bgimg <> nil then
    tex_del(bgimg);
  items.Free;

end;

function thverticalslider.Mouseover: boolean;
var
  ri: zglTRect;
begin
  ri.X := x;
  ri.Y := y;
  ri.W := w;
  ri.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, ri);
end;

procedure thverticalslider.start;
var
  t, f, cs, c: utf8string;
begin
  ItemIndex := 0;
  getitem(ItemIndex, t, f, cs, c);
  itemimg := tex_LoadFromFile(pathchar(imgdir) + f);
  Caption := t;
  command := c;
  comsel := cs;
  ready := True;
  returning := False;
  issliding := False;
  imgopac := 255;
  txtopac := 0;
  r.x := x;
  r.w := w;
  r.y := y;
  r.h := h;
  xb := 2;
end;

procedure thverticalslider.loadnextitem;
var
  t, f, cs, c: utf8string;
begin
  ItemIndex := ItemIndex + 1;
  if ItemIndex > items.Count - 1 then
    ItemIndex := 0;
  getitem(ItemIndex, t, f, cs, c);
  tex_del(itemimg);
  itemimg := tex_LoadFromFile(pathchar(imgdir) + f);
  Caption := t;
  command := c;
  comsel := cs;
  xa := x + w;
  returning := True;
  xb := 1;
end;

procedure thverticalslider.loadprevitem;
var
  t, f, c, cs: utf8string;
begin
  ItemIndex := ItemIndex - 1;
  if ItemIndex < 0 then
    ItemIndex := items.Count - 1;
  getitem(ItemIndex, t, f, cs, c);
  tex_del(itemimg);
  itemimg := tex_LoadFromFile(pathchar(imgdir) + f);
  Caption := t;
  command := c;
  comsel := cs;
  //xa:=x-itemimg^.width;
  returning := True;
  xb := 1;
end;


function thverticalslider.getcurrentonloadcommand: utf8string;
var
  t, f, c, cs: utf8string;
begin
  getitem(ItemIndex, t, f, cs, c);
  Result := cs;
end;

procedure thverticalslider.getitem(ind: integer; var title: utf8string;
  var filename: utf8string; var coms: utf8string; var com: utf8string);
var
  xlist: TStringList;
begin
  xlist := TStringList.Create;
  SplitText('%', items[ind], xlist);
  title := xlist[0];
  filename := xlist[1];
  coms := xlist[2];
  com := xlist[3];
  xlist.Free;
end;

procedure thverticalslider.slidedown;
var
  t, f, c, cs: utf8string;
  p: integer;
begin
  p := ItemIndex - 1;
  if p < 0 then
    p := items.Count - 1;
  getitem(p, t, f, comnext, cs);
  direction := 1;
  issliding := True;
  xa := 0;
  returning := False;
  txtopac := 0;
  xb := 1;
end;

procedure thverticalslider.slideup;
var
  t, f, c, cs: utf8string;
  p: integer;
begin
  p := ItemIndex + 1;
  if p > items.Count - 1 then
    p := 0;
  getitem(p, t, f, comnext, cs);
  direction := 2;
  xa := 0;
  issliding := True;
  returning := False;
  txtopac := 0;
  xb := 1;
end;


procedure thverticalslider.draw;
begin
  //draw background
  if not ready then
    exit;
  pr2d_Rect(x, y, w, h, color, opacity, pr2d_fill);
  
  if issliding and (returning = False) then
  begin
    speed := speed * 1.2;
    case direction of
      2:
      begin //up
        xa := xa - speed;
        if imgopac > 0 then
          imgopac := imgopac - 1;
        if xa <= -h / 2 then
        begin
          loadnextitem;
          xa := h / 2;
          returning := True;
        end;
      end;
      1:
      begin //down
        xa := xa + speed;
        if xa >= h / 2 then
        begin
          loadprevitem;
          xa := y - h / 2;
          returning := True;
        end;
      end;
    end;
  end;

  if issliding and (returning = True) then
  begin
    speed := speed / 1.07;
    if imgopac < 255 then
      imgopac := imgopac + 1;
    case direction of
      2:
      begin //up
        xa := xa - speed;
        if xa <= 0 then
        begin
          returning := False;
          issliding := False;
          xa := 0;
          imgopac := 255;
          speed := 1;
          xb := 2;

        end;
      end;
      1:
      begin //down
        xa := xa + speed;
        if xa >= 0 then
        begin
          returning := False;
          issliding := False;
          xa := 0;
          imgopac := 255;
          speed := 1;
          xb := 2;

        end;
      end;
    end;
  end;

  if xb = 2 then
    txtopac := txtopac + 1;
  if txtopac = 255 then
  begin
    xb := 1;
  end;
  if assigned(bgimg) then
    ssprite2d_Draw(bgimg, x + (w / 2) - (bgimg^.Width / 2), y + (h / 2) -
      (bgimg^.Height / 2), bgimg^.Width, bgimg^.Height, 0, opacity);
  ssprite2d_Draw(itemimg, x + (w / 2) - (itemimg^.Width / 2), xa + (h / 2) -
    (itemimg^.Height / 2), itemimg^.Width, itemimg^.Height, 0, imgopac);
  text_DrawInRectex(font, r, 1, 0, Caption, txtopac, txtcolor, TEXT_HALIGN_CENTER or
    TEXT_VALIGN_BOTTOM);

end;

begin
end.
