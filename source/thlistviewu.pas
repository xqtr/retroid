unit thListViewu;
Interface
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
  classes,
  sysutils,
  tools
    {$ELSE}
  zglHeader
  {$ENDIF}
  ;
  
type 

Thlistview=class(tobject)
	y,h,x,w		: integer;
    top			: byte;
    bottom		: byte;
    left		: byte;
    right		: byte;    
    opacity		: byte;
    selopac		: byte;
    txtopac		: byte;
    itemimg     : zglPTexture;
    bgimg	     : zglPTexture;
    color		: longword;
    bgcolor		: longword;
    items		: tstringlist;
    active		: boolean;
    index		: integer;
    align_hor	: byte;
    itemindex	: integer;
    font		: zglPFont;
    r			: zglTRect;
    itemscount  : integer;
    listtop		: integer;
    selected	: integer;
    textident	: integer;
    command,
    commandsel,
    item		: utf8string;
    separator	: char;
    Constructor Init;
    Destructor  Free;
    Procedure 	Draw;
    function 	Mouseover:boolean; 
    procedure 	keyup;
    procedure 	keydown;
    procedure	getitem(idx:integer; var str:utf8string; var comsel:utf8string; var comex:utf8string);
    function	itemclicked:integer;
    procedure 	keypgdown;
    procedure 	keypgup;
 end;
 
Implementation 
 
 Constructor thlistview.Init;
    begin
	    y:=0;
	    h:=0;
	    x:=0;
	    w:=0;
	    top:=0;
	    bottom:=0;
	    align_hor:=TEXT_HALIGN_LEFT;
	    left:=0;
	    right:=0;
	    opacity:=255;
	    txtopac:=255;
	    selopac:=100;
	    itemimg:=nil;
	    bgimg:=nil;
	    color:=$ffffff;
	    bgcolor:=$00000;
	    items:=tstringlist.create;
	    items.clear;
	    active:=false;
	    textident:=0;
	    index:=0;
	    itemindex:=0;
	    font:=nil;
	    r.x:=x;
	    r.y:=y;
	    r.w:=w;
	    r.h:=h;
	    itemscount:=0;
	    selected:=0;
	    separator:='%';
		listtop:=0;
    end;
    
    Destructor  thlistview.Free;
    begin
		items.free;
		freeandnil(items);
    end;

 function thlistview.Mouseover:boolean;  
 var
  ri: zglTRect;
  begin
	ri.X := x;
	ri.Y := y;
	ri.W := w;
	ri.H := h;
	Result := col2d_PointInRect(mouse_X, mouse_Y, ri);  
end;  

procedure 	thlistview.keyup;
begin
if items.count=0 then exit;
  itemindex:=itemindex-1;
  if itemindex<=0 then itemindex:=0;
  if listtop > itemindex then listtop:=listtop-1;
  if listtop<=0 then listtop:=0;
  getitem(itemindex,item,commandsel,command);
  selected:=selected-1;
  if selected<=0 then selected:=0;
end;

procedure 	thlistview.keypgup;
begin
if items.count=0 then exit;
  itemindex:=itemindex-itemscount;
  if itemindex<0 then itemindex:=0;
  if listtop > itemindex then listtop:=listtop-itemscount;
  if listtop<0 then listtop:=0;
  getitem(itemindex,item,commandsel,command);
  selected:=selected-itemscount;
  if selected<0 then selected:=0;
end;

procedure thlistview.keydown;
begin
  if items.count=0 then exit;
  itemindex:=itemindex+1;
  if itemindex>=items.count-1 then itemindex:=items.count-1;
  getitem(itemindex,item,commandsel,command);
  selected:=selected+1;
  if selected>=items.count-1 then selected:=items.count-1;
  if selected>itemscount-1 then begin
    selected:=itemscount-1;
    listtop:=listtop+1;
    if listtop + itemscount>=items.count then listtop:=items.count-itemscount;
  end;
end;

procedure thlistview.keypgdown;
begin
if items.count=0 then exit;
  itemindex:=itemindex+itemscount;
  if itemindex>items.count-1 then itemindex:=items.count-1;
  getitem(itemindex,item,commandsel,command);
  selected:=selected+itemscount;
  if selected>=items.count-1 then selected:=items.count;
  if selected>itemscount-1 then begin
    selected:=itemscount-1;
    listtop:=listtop+itemscount;
    if listtop + itemscount>=items.count then listtop:=items.count-itemscount;
  end;
end;

function thlistview.itemclicked:integer;
var
  d:integer;
  t,c,cs:utf8string;
  ri: zglTRect;
begin
  d:=0;
  ri.w:=itemimg^.width;
  ri.h:=itemimg^.height;
  ri.x:=x+2;
  while (d<=itemscount-1) and (d+listtop<=items.count-1) do begin
  getitem(d+listtop,t,cs,c);
  ri.y:=y+(d*itemimg^.height)+2;
  if col2d_PointInRect(mouse_X, mouse_Y, ri) then begin
	result:=d+listtop;
	exit;
  end;
  d:=d+1;
  end;
end;

procedure thlistview.getitem(idx:integer; var str:utf8string; var comsel:utf8string; var comex:utf8string);
var
  s,c:utf8string;
  sl:tstringlist;
begin
  sl:=tstringlist.create;
  splittext(separator,items[idx],sl);
  str:=sl[0];
  comsel:=sl[1];
  comex:=sl[2];
  sl.free;
end;

Procedure thlistview.Draw;
var
  d:integer;
  t,c,cs:utf8string;
  ri: zglTRect;
begin
  if not assigned(bgimg) then pr2d_Rect(x, y, w, h, bgcolor, opacity, PR2D_fill) else ssprite2d_Draw(bgimg,x,y,w,h,0,opacity);
  if itemimg=nil then pr2d_Rect(x+1, y+1, w-2, 20, color, selopac, PR2D_fill) else ssprite2d_Draw(itemimg,x,y+(selected*itemimg^.height),itemimg^.width,itemimg^.height,0,selopac);
  d:=0;
  ri.w:=itemimg^.width;
  ri.h:=itemimg^.height;
  ri.x:=x+textident;
  
	  if items.count<=0 then exit;
	  while (d<=itemscount-1) and (d+listtop<=items.count-1) do begin
	  getitem(d+listtop,t,cs,c);
	  ri.y:=y+(d*itemimg^.height)+2;
	  text_DrawInRectex(font, ri, 1, 0,t,txtopac,color,align_hor or TEXT_VALIGN_CENTER);
	  d:=d+1;
	  end;
end;

Begin
End.
