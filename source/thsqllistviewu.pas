unit thsqlListViewu;

interface

{$I zglCustomConfig.cfg}
uses
  {$IFDEF USE_ZENGL_STATIC}
  zgl_mouse,
  zgl_textures,
  zgl_textures_png,
  zgl_primitives_2d,
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_math_2d,
  zgl_collision_2d,
  Classes,
  SysUtils,
  thobjects,
  tools
    {$ELSE}
  zglHeader
  {$ENDIF}  ;

type

  Thsqllistview = class(TObject)
    y, h, x, w: integer;
    top: byte;
    bottom: byte;
    left: byte;
    right: byte;
    opacity: byte;
    selopac: byte;
    txtopac: byte;
    itemimg: zglPTexture;
    bgimg: zglPTexture;
    color: longword;
    bgcolor: longword;
    active: boolean;
    index: integer;
    align_hor: byte;
    ItemIndex: integer;
    font: zglPFont;
    r: zglTRect;
    itemscount: integer;
    listtop: integer;
    selected: integer;
    textident: integer;
    sqldb: thsqlite;
    command, commandsel, item: utf8string;
    separator: char;
    items: TStringList;
    constructor Init;
    destructor Free;
    procedure Draw;
    function Mouseover: boolean;
    procedure keyup;
    procedure keydown;
    procedure getitem(idx: integer; var str: utf8string);
    function itemclicked: integer;
    procedure getitems;
  end;

implementation

constructor Thsqllistview.Init;
begin
  y := 0;
  h := 0;
  x := 0;
  w := 0;
  top := 0;
  bottom := 0;
  align_hor := TEXT_HALIGN_LEFT;
  left := 0;
  right := 0;
  opacity := 255;
  txtopac := 255;
  selopac := 100;
  itemimg := nil;
  separator := '%';
  bgimg := nil;
  color := $ffffff;
  bgcolor := $00000;
  active := False;
  textident := 0;
  index := 0;
  ItemIndex := 0;
  font := nil;
  r.x := x;
  r.y := y;
  r.w := w;
  r.h := h;
  sqldb := nil;
  itemscount := 0;
  selected := 0;
  items := TStringList.Create;
  listtop := 0;
end;

destructor Thsqllistview.Free;
begin
  sqldb := nil;
  items.Free;
end;

function Thsqllistview.Mouseover: boolean;
var
  ri: zglTRect;
begin
  ri.X := x;
  ri.Y := y;
  ri.W := w;
  ri.H := h;
  Result := col2d_PointInRect(mouse_X, mouse_Y, ri);
end;

procedure Thsqllistview.keyup;
begin
  if sqldb.ds.RecordCount = 0 then
    exit;
  ItemIndex := ItemIndex - 1;
  if ItemIndex <= 0 then
    ItemIndex := 0;
  if listtop > ItemIndex then
    listtop := listtop - 1;
  if listtop <= 0 then
    listtop := 0;
  sqldb.ds.prior;
  selected := selected - 1;
  if selected <= 0 then
    selected := 0;
end;

procedure Thsqllistview.keydown;
begin
  if sqldb.ds.RecordCount = 0 then
    exit;
  ItemIndex := ItemIndex + 1;
  if ItemIndex >= sqldb.ds.RecordCount - 1 then
    ItemIndex := sqldb.ds.RecordCount - 1;
  sqldb.ds.Next;
  selected := selected + 1;
  if selected >= sqldb.ds.RecordCount - 1 then
    selected := sqldb.ds.RecordCount - 1;
  if selected > itemscount - 1 then
  begin
    selected := itemscount - 1;
    listtop := listtop + 1;
    if listtop + itemscount >= sqldb.ds.RecordCount then
      listtop := sqldb.ds.RecordCount - itemscount;
  end;
end;

function Thsqllistview.itemclicked: integer;
var
  d: integer;
  t: utf8string;
  ri: zglTRect;
begin
  d := 0;
  ri.w := itemimg^.Width;
  ri.h := itemimg^.Height;
  ri.x := x + 2;
  while (d <= itemscount - 1) and (d + listtop <= sqldb.ds.RecordCount - 1) do
  begin
    getitem(d + listtop, t);//,cs,c);
    ri.y := y + (d * itemimg^.Height) + 2;
    if col2d_PointInRect(mouse_X, mouse_Y, ri) then
    begin
      Result := d + listtop;
      exit;
    end;
    d := d + 1;
  end;
end;

procedure Thsqllistview.getitem(idx: integer; var str: utf8string);
begin
  sqldb.gotorec(idx);
  str := sqldb.ds.fields[0].AsString;
end;

procedure Thsqllistview.getitems;
begin
  items.Clear;
  sqldb.ds.First;
  while not sqldb.ds.EOF do
  begin
    items.add(sqldb.ds.fields[0].AsString);
    sqldb.ds.Next;
  end;
end;

procedure Thsqllistview.Draw;
var
  d: integer;
  t: utf8string;
  ri: zglTRect;
begin
  if not assigned(bgimg) then
    pr2d_Rect(x, y, w, h, bgcolor, opacity, PR2D_fill)
  else
    ssprite2d_Draw(bgimg, x, y, w, h, 0, opacity);
  if itemimg = nil then
    pr2d_Rect(x, y + (selected * itemimg^.Height), w - 2, font^.maxheight,
      color, selopac, PR2D_fill)
  else
    ssprite2d_Draw(itemimg, x, y + (selected * itemimg^.Height), itemimg^.Width,
      itemimg^.Height, 0, selopac);
  d := 0;
  ri.w := itemimg^.Width;
  ri.h := itemimg^.Height;
  ri.x := x + textident;

  if sqldb.ds.RecordCount <= 0 then
    exit;
  while (d <= itemscount - 1) and (d + listtop <= sqldb.ds.RecordCount - 1) do
  begin
    t := items[d + listtop];
    ri.y := y + (d * itemimg^.Height) + 2;
    text_DrawInRectex(font, ri, 1, 0, t, txtopac, color, align_hor or TEXT_VALIGN_CENTER);
    d := d + 1;
  end;
end;

begin
end.
