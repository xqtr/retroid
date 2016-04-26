program main;

{$I zglCustomConfig.cfg}

{$mode objfpc}
{$H+}


uses {$IFDEF USE_ZENGL_STATIC}
  zgl_main,
  zgl_application,
  zgl_screen,
  zgl_window,
  zgl_timers,
  zgl_file,
  zgl_keyboard,
  zgl_mouse,
  zgl_ini,
  zgl_types,
  zgl_render_2d,
  zgl_primitives_2d,
  zgl_fx,
  zgl_log,
  zgl_textures,
  zgl_textures_png,
  zgl_textures_tga, // TGA
  zgl_textures_jpg, // JPG
  zgl_font,
  zgl_text,
  zgl_sprite_2d,
  zgl_sound,
  zgl_sound_wav,
  zgl_sound_ogg,
  zgl_video,
  zgl_video_theora,
  zgl_joystick,
  zgl_utils,
  zgl_camera_2d,
  Classes,
  tools,
  contnrs,
  SysUtils,
  thCommonObjects,
  thListViewu,
  thsqlListViewu,
  thhorizontalslideru,
  thverticalslideru,
  thtextvieweru,
  process,
  thobjects
  {$ELSE}
  zglHeader
  {$ENDIF}     ;

const
  max_objects = 100;
  SCREEN_WIDTH = 800;
  SCREEN_HEIGHT = 600;
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

var
  MainTimer: zglPTimer;
  joytimer: zglPTimer;
  keytimer: zglptimer;
  screentimer: zglPTimer;
  camMain: zglTCamera2D;
  Components: TObjectList;
  dir_main: utf8string;
  dir_font: utf8string;
  dir_sound: utf8string;
  dir_theme: utf8string;
  dir_image: utf8string;
  title: utf8string;
  intro_sound: byte;
  fntMain: zglPFont;
  background: zglPTexture;
  bgcolor: longword;
  fullscreen: boolean;
  debug: boolean;
  lineAlpha: byte;
  state: integer;
  joyCount: integer;
  joy1, joy2: boolean;
  gcount: integer;
  Width, Height: integer;
  gstr: utf8string;
  timercommand: utf8string;
  theme: Ttheme;
  loading: boolean;
  time: integer;
  video: word;
  throbber: ththrobber;
  trackinput: integer;
  track: boolean;
  timerdelay: integer;
  hslider: thhorizontalslider;
  vslider: thverticalslider;
  listitem: integer;
  variables: array[0..max_objects - 1] of string;
  sql: thsqlite;
  screen: thscreen;
  quiting: boolean;
  lastscreen: utf8string;
  backscreen: string;
  secs: integer;

  tabindex: record
    index: integer;
    x, y, w, h: single;
    max: integer;
  end;
  showbevel: boolean;
  beveltimer: integer;

  error: record
    title: utf8string;
    Text: utf8string;
  end;
  procedure Timer; forward;
  procedure Del_textures; forward;
  function ExCommand(var Caption: utf8string; str: utf8string): string; forward;
  procedure Findtabindex(enter: boolean); forward;
  function Replacefolders(stra: utf8string): utf8string; forward;
  function ReplaceInternalVariables(stra: utf8string): utf8string; forward;
  procedure Update_theme; forward;
  procedure Quit; forward;

  procedure Text(str: utf8string; x, y: integer; Alpha: byte = 255;
    Color: longword = $ffffff; Flags: longword = 0; scale: single = 1);
  begin
    text_Drawex(fntmain, x, y, scale, 0, str, alpha, color, flags);
  end;

  procedure log(str: utf8string);
  begin
    if debug then
      log_add(str);
  end;

  procedure Seterror(title, Text: string);
  begin
    error.title := title;
    error.Text := Text;
    if debug then
      log_add('<error> - ' + error.title + ' : ' + error.Text);
  end;

  procedure Clearcomponents;
  begin
    while Components.Count > 0 do
    begin
      Components.Delete(Components.Count - 1);
    end;
    Components.Clear;
  end;

  function Objectbyindex(index: integer): TObject;
  var
    z: integer;
  begin
    for z := 0 to Components.Count - 1 do
    begin
      if (Components.items[z] is thclock) then
      begin
        if (index = (Components.items[z] as thclock).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      end;
      if (Components.items[z] is THProgress) then
      begin
        if (index = (Components.items[z] as THProgress).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      end;
      if (Components.items[z] is thgauge) then
      begin
        if (index = (Components.items[z] as thgauge).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      end;
      if (Components.items[z] is thslider) then
      begin
        if (index = (Components.items[z] as thslider).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      end;
      if (Components.items[z] is thvideo) then
      begin
        if (index = (Components.items[z] as thvideo).index) and
          ((Components.items[z] as thvideo).Enabled) then
        begin
          Result := Components.items[z];
          exit;
        end;
      end;

      if (Components.items[z] is thlabel) then
        if (index = (Components.items[z] as thlabel).index) then
        begin
          Result := Components.items[z];
          exit;
        end;

      if (Components.items[z] is thtext) then
        if (index = (Components.items[z] as thtext).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      if (Components.items[z] is thtextviewer) then
        if (index = (Components.items[z] as thtextviewer).index) then
        begin
          Result := Components.items[z];
          exit;
        end;

      if (Components.items[z] is thedittext) then
        if (index = (Components.items[z] as thedittext).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      if (Components.items[z] is thbutton) then
        if (index = (Components.items[z] as thbutton).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      if (Components.items[z] is thlistview) then
        if (index = (Components.items[z] as thlistview).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      if (Components.items[z] is thsqllistview) then
        if (index = (Components.items[z] as thsqllistview).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
      if (Components.items[z] is thswitch) then
        if (index = (Components.items[z] as thswitch).index) then
        begin
          Result := Components.items[z];
          exit;
        end;
    end;
    Result := nil;
  end;


  procedure hor_align(var xx: integer; Width: integer);
  begin
    case xx of
      -1:
      begin
        xx := (screen.Width div 2) - (Width div 2);
      end;
      -2:
      begin
        xx := screen.Width - Width;
      end;
    end;
  end;

  procedure hor_align(var xx: single; Width: single); overload;
  begin
    if xx = -1 then
      xx := (screen.Width / 2) - (Width / 2);
    if xx = -2 then
      xx := screen.Width - Width;
  end;

  procedure ver_align(var yy: integer; Height: integer);
  begin
    case yy of
      -1:
      begin
        yy := (screen.Height div 2) - (Height div 2);
      end;
      -2:
      begin
        yy := screen.Height - Height;
      end;
    end;
  end;

  procedure ver_align(var yy: single; Height: single); overload;
  begin
    if yy = -1 then
      yy := (screen.Height / 2) - (Height / 2);
    if yy = -2 then
      yy := screen.Height - Height;
  end;

  procedure Load_screen(Name: string);
  var
    i, p: integer;
    title: string;
    tmp: utf8string;
  begin
    lastscreen := Name;
    if screen.intrans then
      exit;
    if (screen.trans_out <> 0) and (screen.trans_done = False) then
    begin
      screen.Inittransition(cammain, screen.trans_out, True);
      exit;
    end;
    screen.trans_done := False;
    loading := True;
    screen.intrans := False;
    screen.resetcam(cammain);

    throbber.Visible := False;
    timer_del(maintimer);
    screentimer^.active := False;
    keytimer^.active := False;

    backscreen := '';
    hslider.active := False;
    vslider.active := False;
    listitem := 0;
    trackinput := 0;
    video := 0;
    track := False;
    tabindex.index := 1;
    tabindex.max := 0;
    bgcolor := 0;
    track := False;
    clearcomponents;
    if sql.ds.active then
      sql.ds.Close;
    sql.active := False;
    if ini_loadfromfile(pathchar(dir_theme) + 'standard.ini') then
    begin
      //Load Throbber
      with throbber do
      begin
        log('(o) Loading Throbber settings');
        x := ini_readkeyint('throbber', 'x');
        y := ini_readkeyint('throbber', 'y');
        w := ini_readkeyint('throbber', 'width');
        h := ini_readkeyint('throbber', 'height');
        opacity := ini_readkeyint('throbber', 'opacity');
        timer := 1000;
        throbber.image := tex_LoadFromFile(
          Replacefolders(ini_ReadKeyStr('throbber', 'image')));
        Visible := False;
        timer := 200;
        imgindex := 1;
      end;
    end
    else
      log('<error> INI file for standard components, not found.');
    throbber.Visible := True;
    if file_exists(dir_theme + Name + '.ini') = False then
    begin
      log('<error> Screen ' + dir_theme + Name + '.ini' + ' doesn''t exist...');
      exit;
    end;
    ini_loadfromfile(dir_theme + Name + '.ini');
    background := tex_LoadFromFile(
      Replacefolders(ini_ReadKeyStr('background', 'image')));
    if ini_issection('background') then
    begin
      if ini_IsKey('background', 'color') then
        bgcolor := ini_ReadKeyint('background', 'color');
      if ini_readkeybool('background', 'fade') then
        time := 1
      else
        time := 1000;
      if ini_IsKey('background', 'backscreen') then
        backscreen := ini_ReadKeyStr('background', 'backscreen');
      if ini_IsKey('background', 'clicksound') then
        theme.click_sound := ini_ReadKeyStr('background', 'clicksound');
      theme.click_sound := Replacefolders(theme.click_sound);
      if ini_IsKey('background', 'errorsound') then
        theme.error_sound := ini_ReadKeyStr('background', 'errorsound');
      theme.error_sound := Replacefolders(theme.error_sound);
      if ini_iskey('background', 'trans_in') then
        screen.trans_in := Setintransition(ini_ReadKeyStr('background', 'trans_in'))
      else
        screen.trans_in := 0;
      if ini_iskey('background', 'trans_out') then
        screen.trans_out := setintransition(ini_ReadKeyStr('background', 'trans_out'))
      else
        screen.trans_out := 0;
      if fullscreen then
        screen.Width := scrwidth
      else
        screen.Width := wndwidth;
      if fullscreen then
        screen.Height := scrheight
      else
        screen.Height := wndheight;
    end;
    font_del(fntmain);
    fntmain := nil;
    if ini_iskey('font', 'name') then
    begin
      tmp := Replacefolders(ini_ReadKeyStr('font', 'name'));
      if fileexists(tmp + '.zfi') then
        fntMain := font_LoadFromFile(Replacefolders(ini_ReadKeyStr('font', 'name') + '.zfi'))
      else if fileexists(tmp) then
        fntMain := font_LoadFromFile(Replacefolders(ini_ReadKeyStr('font', 'name')));
    end;
    if ini_iskey('font', 'color') then
      theme.font_color := u_StrToInt(ini_ReadKeyStr('font', 'color'));
    //sqlite
    if ini_issection('sqlite') then
    begin
      title := 'sqlite';
      with sql do
      begin
        table := ini_ReadKeyStr(title, 'tablename');
        filename := Replacefolders(ini_ReadKeyStr(title, 'filename'));
        sql := ini_ReadKeyStr(title, 'sql');
        opendatabase(filename, table);
        log('(o) First item in db:' + ds.fields[0].AsString);
        active := True;
        countitems;
        firstrecord;
      end;
    end;
    Components.add(thdummy.Create);
    //horizontal slider
    if ini_issection('horizontal_slider') then
    begin
      title := 'horizontal_slider';
      with hslider do
      begin
        init;
        y := ini_readkeyint(title, 'y');
        h := ini_readkeyint(title, 'height');
        x := 0;
        w := screen.Width;
        ver_align(y, h);
        opacity := ini_readkeyint(title, 'opacity');
        color := u_StrToInt(ini_ReadKeyStr(title, 'bg_color'));
        tmp := Replacefolders(ini_readkeystr(title, 'items_file'));
        top := ini_readkeyint(title, 'top');
        bottom := ini_readkeyint(title, 'bottom');
        index := ini_readkeyint(title, 'index');
        font := fntmain;
        if fileexists(tmp) then
          items.loadfromfile(tmp);
        getitem(0, Caption, filen, comsel, command);
        ItemIndex := 0;
        listitem := ItemIndex;
        variables[index] := u_inttostr(listitem);
        imgdir := Replacefolders(ini_readkeystr(title, 'image_dir'));
        tmp := Replacefolders(ini_ReadKeyStr(title, 'background'));
        if fileexists(tmp) then
          bgimg := tex_LoadFromFile(tmp)
        else
          bgimg := nil;
        txtcolor := ini_readkeyint(title, 'color');
        if index > tabindex.max then
          tabindex.max := index;
        active := True;
        start;
      end;
    end;
    //vertical slider
    if ini_issection('vertical_slider') then
    begin
      title := 'vertical_slider';
      with vslider do
      begin
        init;
        x := ini_readkeyint(title, 'x');
        w := ini_readkeyint(title, 'width');
        y := 0;
        h := scrheight;
        hor_align(x, w);
        opacity := ini_readkeyint(title, 'opacity');
        color := u_StrToInt(ini_ReadKeyStr(title, 'bg_color'));
        tmp := Replacefolders(ini_readkeystr(title, 'items_file'));
        if fileexists(tmp) then
          items.loadfromfile(tmp);
        getitem(0, Caption, filen, comsel, command);
        left := ini_readkeyint(title, 'left');
        right := ini_readkeyint(title, 'right');
        index := ini_readkeyint(title, 'index');
        font := fntmain;
        listitem := 0;
        variables[index] := u_inttostr(listitem);
        imgdir := Replacefolders(ini_readkeystr(title, 'image_dir'));
        tmp := Replacefolders(ini_ReadKeyStr(title, 'background'));
        if fileexists(tmp) then
          bgimg := tex_LoadFromFile(tmp)
        else
          bgimg := nil;
        txtcolor := ini_readkeyint(title, 'color');
        if index > tabindex.max then
          tabindex.max := index;
        active := True;
        start;
      end;
    end;
    //panels
    i := 0;
    title := 'panel_';
    while ini_issection('panel_' + IntToStr(i + 1)) do
    begin
      Components.add(thpanel.Create);
      with (Components.last as thpanel) do
      begin
        init;
        log('(o) Loading panel_ No ' + IntToStr(i + 1));
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        if index > tabindex.max then
          tabindex.max := index;
        color := u_StrToInt(ini_ReadKeyStr(title + IntToStr(i + 1), 'color'));
        image_t := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_top')));
        image_l := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_left')));
        image_r := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_right')));
        image_b := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_bottom')));
        image_tr := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_topright')));
        image_tl := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_topleft')));
        image_br := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_bottomright')));
        image_bl := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_bottomleft')));
      end;
      i := i + 1;
    end;
    //Video
    if ini_IsSection('video') then
    begin
      Components.add(thvideo.Create);
      with (Components.last as thvideo) do
      begin
        init;
        x := ini_ReadKeyInt('video', 'x');
        y := ini_readkeyint('video', 'y');
        top := ini_readkeyint('video', 'top');
        bottom := ini_readkeyint('video', 'bottom');
        left := ini_readkeyint('video', 'left');
        right := ini_readkeyint('video', 'right');
        filename := Replacefolders(ini_ReadKeyStr('video', 'filename'));
        log('(o) Loding video: ' + filename);
        vid := video_OpenFile(filename);
        w := vid^.Info.Width;
        h := vid^.Info.Height;
        hor_align(x, w);
        ver_align(y, h);
        seek := ini_readkeybool('video', 'seek');
        play := False;
        play := ini_readkeybool('video', 'play');
        opacity := ini_readkeyint('video', 'opacity');
        opac := opacity;
        click := True;
        click := ini_readkeybool('video', 'click');
        Enabled := True;
        index := ini_readkeyint('video', 'index');
        variables[index] := filename;
        for p := 0 to Components.Count - 1 do
          if (Components[p] is thvideo) then
            video := p;
        if index > tabindex.max then
          tabindex.max := index;
      end;
    end;
    i := 0;
    //Buttons
    title := 'button_';
    while ini_issection('button_' + IntToStr(i + 1)) do
    begin
      Components.add(thbutton.Create);
      with (Components.last as thbutton) do
      begin
        init;
        log('(o) Loading Button No ' + IntToStr(i + 1));
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        rf.x := x;
        rf.y := y;
        rf.w := w;
        rf.h := h;
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        Caption := ini_readkeystr(title + IntToStr(i + 1), 'caption');
        color := ini_readkeyint(title + IntToStr(i + 1), 'color');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        color := u_StrToInt(ini_ReadKeyStr(title + IntToStr(i + 1), 'color'));
        opac2 := opacity;
        click := False;
        click := ini_readkeybool(title + IntToStr(i + 1), 'click');
        update := ini_readkeybool(title + IntToStr(i + 1), 'update');
        command := ini_readkeystr(title + IntToStr(i + 1), 'command');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        if index > tabindex.max then
          tabindex.max := index;
        tmp := Replacefolders(ini_ReadKeyStr(title + IntToStr(i + 1), 'image'));
        if fileexists(tmp) then
        begin
          tex_del(image);
          image := tex_LoadFromFile(tmp);
        end;
        variables[index] := Replacefolders(ini_ReadKeyStr(title +
          IntToStr(i + 1), 'image'));
        if ini_ReadKeyStr(title + IntToStr(i + 1), 'image_pressed') = '' then
        begin
          tex_del(image_down);
          image_down := tex_LoadFromFile(
            Replacefolders(ini_ReadKeyStr(title + IntToStr(i + 1), 'image')));
        end;
        resize := False;
        if ini_readkeybool(title + IntToStr(i + 1), 'resize') = False then
        begin
          w := image^.Width;
          h := image^.Height;
          rf.w := w;
          rf.h := h;
          hor_align(x, w);
          ver_align(y, h);
          rf.x := x;
          rf.y := y;
        end;
      end;
      i := i + 1;
    end;
    if ini_IsSection('clock') then
    begin
      Components.add(thclock.Create);
      with (Components.last as thclock) do
      begin
        x := ini_ReadKeyInt('clock', 'x');
        y := ini_readkeyint('clock', 'y');
        format := ini_ReadKeyStr('clock', 'format');
        opacity := ini_readkeyint('clock', 'opacity');
        color := u_StrToInt(ini_ReadKeyStr('clock', 'color'));
        index := ini_readkeyint('clock', 'index');
        variables[index] := ini_ReadKeyStr('clock', 'format');
        ver_align(y, fntmain^.maxheight);
        hor_align(x, trunc(text_GetWidth(fntmain, FormatDateTime(format, now))));
        if index > tabindex.max then
          tabindex.max := index;
      end;
    end;
    //Listview
    i := 1;
    title := 'listview_';
    while ini_issection(title + IntToStr(i)) do
    begin
      Components.add(thlistview.Create);
      with (Components.last as thlistview) do
      begin
        log('(o) Loading Listview No ' + IntToStr(i));
        init;
        x := ini_readkeyint(title + IntToStr(i), 'x');
        y := ini_readkeyint(title + IntToStr(i), 'y');
        w := ini_readkeyint(title + IntToStr(i), 'width');
        h := ini_readkeyint(title + IntToStr(i), 'height');
        textident := ini_readkeyint(title + IntToStr(i), 'text_ident');
        hor_align(x, w);
        ver_align(y, h);
        itemscount := ini_readkeyint(title + IntToStr(i), 'items_count');
        left := ini_readkeyint(title + IntToStr(i), 'left');
        right := ini_readkeyint(title + IntToStr(i), 'right');
        bgcolor := ini_readkeyint(title + IntToStr(i), 'bg_color');
        color := ini_readkeyint(title + IntToStr(i), 'text_color');
        opacity := ini_readkeyint(title + IntToStr(i), 'opacity');
        selopac := ini_readkeyint(title + IntToStr(i), 'selection_opacity');
        txtopac := ini_readkeyint(title + IntToStr(i), 'text_opacity');
        if ini_iskey(title + IntToStr(i), 'separator') then
        begin
          tmp := ini_readkeystr(title + IntToStr(i), 'separator');
          separator := tmp[1];
        end;
        tmp := Replacefolders(ini_ReadKeyStr(title + IntToStr(i), 'selection_image'));
        if fileexists(tmp) then
          itemimg := tex_LoadFromFile(tmp)
        else
          itemimg := nil;
        tmp := Replacefolders(ini_ReadKeyStr(title + IntToStr(i), 'bg_image'));
        if fileexists(tmp) then
        begin
          bgimg := tex_LoadFromFile(tmp);
          w := bgimg^.Width;
          h := bgimg^.Height;
        end
        else
          bgimg := nil;
        font := fntmain;
        listitem := 0;
        case ini_readkeystr(title + IntToStr(i), 'align') of
          'left': align_hor := TEXT_HALIGN_LEFT;
          'right': align_hor := TEXT_HALIGN_RIGHT;
          'center': align_hor := TEXT_HALIGN_CENTER;
          'justify': align_hor := TEXT_HALIGN_JUSTIFY;
        end;
        items.loadfromfile(Replacefolders(ini_readkeystr(title + IntToStr(i), 'items_file')));
        variables[index] := u_inttostr(listitem);
        index := ini_readkeyint(title + IntToStr(i), 'index');
        if items.Count > 0 then
          getitem(0, item, commandsel, command);
        if index > tabindex.max then
          tabindex.max := index;
      end;
      i := i + 1;
    end;
    //SQLListview
    i := 1;
    title := 'sqllistview_';
    while ini_issection(title + IntToStr(i)) do
    begin
      Components.add(thsqllistview.Create);
      with (Components.last as thsqllistview) do
      begin
        log('(o) Loading SQLListview No ' + IntToStr(i));
        init;
        x := ini_readkeyint(title + IntToStr(i), 'x');
        y := ini_readkeyint(title + IntToStr(i), 'y');
        w := ini_readkeyint(title + IntToStr(i), 'width');
        h := ini_readkeyint(title + IntToStr(i), 'height');
        textident := ini_readkeyint(title + IntToStr(i), 'text_ident');
        hor_align(x, w);
        ver_align(y, h);
        sqldb := sql;
        itemscount := ini_readkeyint(title + IntToStr(i), 'items_count');
        left := ini_readkeyint(title + IntToStr(i), 'left');
        right := ini_readkeyint(title + IntToStr(i), 'right');
        bgcolor := ini_readkeyint(title + IntToStr(i), 'bg_color');
        color := ini_readkeyint(title + IntToStr(i), 'text_color');
        opacity := ini_readkeyint(title + IntToStr(i), 'opacity');
        selopac := ini_readkeyint(title + IntToStr(i), 'selection_opacity');
        txtopac := ini_readkeyint(title + IntToStr(i), 'text_opacity');
        commandsel := ini_ReadKeyStr(title + IntToStr(i), 'onselect');
        command := ini_ReadKeyStr(title + IntToStr(i), 'onexecute');

        tmp := Replacefolders(ini_ReadKeyStr(title + IntToStr(i), 'selection_image'));
        if fileexists(tmp) then
          itemimg := tex_LoadFromFile(tmp)
        else
          itemimg := nil;
        tmp := Replacefolders(ini_ReadKeyStr(title + IntToStr(i), 'bg_image'));
        if fileexists(tmp) then
        begin
          bgimg := tex_LoadFromFile(tmp);
          w := bgimg^.Width;
          h := bgimg^.Height;
        end
        else
          bgimg := nil;
        font := fntmain;
        listitem := 0;
        case ini_readkeystr(title + IntToStr(i), 'align') of
          'left': align_hor := TEXT_HALIGN_LEFT;
          'right': align_hor := TEXT_HALIGN_RIGHT;
          'center': align_hor := TEXT_HALIGN_CENTER;
          'justify': align_hor := TEXT_HALIGN_JUSTIFY;
        end;
        variables[index] := u_inttostr(listitem);
        index := ini_readkeyint(title + IntToStr(i), 'index');
        getitems;
        if index > tabindex.max then
          tabindex.max := index;
      end;
      i := i + 1;
    end;
    //Texts
    i := 1;
    title := 'text_';
    while ini_issection(title + IntToStr(i)) do
    begin
      Components.add(thtext.Create);
      with (Components.last as thtext) do
      begin
        log('(o) Loading Text No ' + IntToStr(i));
        init;
        r.x := ini_readkeyint(title + IntToStr(i), 'x');
        r.y := ini_readkeyint(title + IntToStr(i), 'y');
        r.w := ini_readkeyint(title + IntToStr(i), 'width');
        r.h := ini_readkeyint(title + IntToStr(i), 'height');
        hor_align(r.x, r.w);
        ver_align(r.y, r.h);
        top := ini_readkeyint(title + IntToStr(i), 'top');
        bottom := ini_readkeyint(title + IntToStr(i), 'bottom');
        left := ini_readkeyint(title + IntToStr(i), 'left');
        right := ini_readkeyint(title + IntToStr(i), 'right');
        case ini_readkeystr(title + IntToStr(i), 'align_hor') of
          'left': align_hor := TEXT_HALIGN_LEFT;
          'right': align_hor := TEXT_HALIGN_RIGHT;
          'center': align_hor := TEXT_HALIGN_CENTER;
          'justify': align_hor := TEXT_HALIGN_JUSTIFY;
        end;
        case ini_readkeystr(title + IntToStr(i), 'align_ver') of
          'top': align_ver := TEXT_VALIGN_TOP;
          'bottom': align_ver := TEXT_VALIGN_BOTTOM;
          'center': align_ver := TEXT_VALIGN_CENTER;
        end;
        Caption := replaceinternalvariables(ini_readkeystr(title + IntToStr(i), 'text'));
        update := ini_readkeybool(title + IntToStr(i), 'update');
        color := ini_readkeyint(title + IntToStr(i), 'color');
        opacity := ini_readkeyint(title + IntToStr(i), 'opacity');
        click := False;
        click := ini_readkeybool(title + IntToStr(i), 'click');
        command := ini_readkeystr(title + IntToStr(i), 'command');
        timer := False;
        timer := ini_readkeybool(title + IntToStr(i), 'timer');
        index := ini_readkeyint(title + IntToStr(i), 'index');
        variables[index] := Caption;
        if index > tabindex.max then
          tabindex.max := index;
        if update = True then
          if command <> '' then
            excommand(Caption, command);
      end;
      i := i + 1;
    end;
    //TextViewer
    i := 1;
    title := 'textviewer_';
    while ini_issection(title + IntToStr(i)) do
    begin
      Components.add(thtextviewer.Create);
      with (Components.last as thtextviewer) do
      begin
        log('(o) Loading Textviewer No ' + IntToStr(i));
        init;
        r.x := ini_readkeyint(title + IntToStr(i), 'x');
        r.y := ini_readkeyint(title + IntToStr(i), 'y');
        r.w := ini_readkeyint(title + IntToStr(i), 'width');
        r.h := ini_readkeyint(title + IntToStr(i), 'height');
        Width := trunc(r.w);
        Height := trunc(r.h);
        hor_align(r.x, r.w);
        ver_align(r.y, r.h);
        x := trunc(r.x);
        y := trunc(r.y);
        top := ini_readkeyint(title + IntToStr(i), 'top');
        bottom := ini_readkeyint(title + IntToStr(i), 'bottom');
        left := ini_readkeyint(title + IntToStr(i), 'left');
        right := ini_readkeyint(title + IntToStr(i), 'right');
        case ini_readkeystr(title + IntToStr(i), 'align_hor') of
          'left': align_hor := TEXT_HALIGN_LEFT;
          'right': align_hor := TEXT_HALIGN_RIGHT;
          'center': align_hor := TEXT_HALIGN_CENTER;
          'justify': align_hor := TEXT_HALIGN_JUSTIFY;
        end;
        chars := ini_readkeyint(title + IntToStr(i), 'width_chars');
        Lines := ini_readkeyint(title + IntToStr(i), 'lines_no');
        try
          textsl.loadfromfile(replaceinternalvariables(ini_readkeystr(title +
            IntToStr(i), 'filename')));
        except
          textsl.Clear;
          log('File for Textviewer is invalid.');
        end;
        update := ini_readkeybool(title + IntToStr(i), 'update');
        wrap := ini_readkeybool(title + IntToStr(i), 'wrap');
        color := ini_readkeyint(title + IntToStr(i), 'color');
        opacity := ini_readkeyint(title + IntToStr(i), 'opacity');
        click := False;
        click := ini_readkeybool(title + IntToStr(i), 'click');
        command := ini_readkeystr(title + IntToStr(i), 'command');
        index := ini_readkeyint(title + IntToStr(i), 'index');
        variables[index] := textsl.Text;
        if index > tabindex.max then
          tabindex.max := index;
        if update = True then
          if command <> '' then
            excommand(tmp, command);
      end;
      i := i + 1;
    end;
    //progress bar
    i := 0;
    title := 'progress_';
    while ini_issection(title + IntToStr(i + 1)) do
    begin
      Components.add(thprogress.Create);
      with (Components.last as thprogress) do
      begin
        init;
        log('(o) Loading progress No ' + IntToStr(i + 1));
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        vertical := ini_readkeybool(title + IntToStr(i + 1), 'vertical');
        command := ini_readkeystr(title + IntToStr(i + 1), 'command');
        min := ini_readkeyint(title + IntToStr(i + 1), 'min');
        max := ini_readkeyint(title + IntToStr(i + 1), 'max');
        pos := ini_readkeyint(title + IntToStr(i + 1), 'position');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        variables[index] := u_inttostr(pos);
        if index > tabindex.max then
          tabindex.max := index;
        image_empty := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_empty')));
        image_full := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_full')));
      end;
      i := i + 1;
    end;
    //gauge
    i := 0;
    title := 'gauge_';
    while ini_issection(title + IntToStr(i + 1)) do
    begin
      Components.add(thgauge.Create);
      with (Components.last as thgauge) do
      begin
        log('(o) Loading Gauge No ' + IntToStr(i + 1));
        init;
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        bgopac := ini_readkeyint(title + IntToStr(i + 1), 'bg_opacity');
        command := ini_readkeystr(title + IntToStr(i + 1), 'command');
        min := ini_readkeyint(title + IntToStr(i + 1), 'min');
        max := ini_readkeyint(title + IntToStr(i + 1), 'max');
        pos := ini_readkeyint(title + IntToStr(i + 1), 'position');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        variables[index] := u_inttostr(pos);
        if index > tabindex.max then
          tabindex.max := index;
        bgimg := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'bg_image')));
        img := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'needle_image')));
      end;
      i := i + 1;
    end;
    //Sliders
    i := 0;
    title := 'slider_';
    while ini_issection(title + IntToStr(i + 1)) do
    begin
      Components.add(thslider.Create);
      with (Components.last as thslider) do
      begin
        init;
        log('(o) Loading slider_ No ' + IntToStr(i + 1));
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        vertical := ini_readkeybool(title + IntToStr(i + 1), 'vertical');
        Enabled := ini_readkeybool(title + IntToStr(i + 1), 'enabled');
        command := ini_readkeystr(title + IntToStr(i + 1), 'command');
        min := ini_readkeyint(title + IntToStr(i + 1), 'min');
        max := ini_readkeyint(title + IntToStr(i + 1), 'max');
        pos := ini_readkeyint(title + IntToStr(i + 1), 'position');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        variables[index] := u_inttostr(pos);
        if index > tabindex.max then
          tabindex.max := index;
        image_bg := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_bg')));
        image_fg := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'image_knob')));
      end;
      i := i + 1;
    end;
    //Switches
    i := 0;
    title := 'switch_';
    while ini_issection(title + IntToStr(i + 1)) do
    begin
      Components.add(thswitch.Create);
      with (Components.last as thswitch) do
      begin
        log('(o) Loading switch No ' + IntToStr(i + 1));
        init;
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        click := False;
        click := ini_readkeybool(title + IntToStr(i + 1), 'click');
        Checked := ini_readkeybool(title + IntToStr(i + 1), 'checked');
        command_on := ini_readkeystr(title + IntToStr(i + 1), 'command_on');
        command_off := ini_readkeystr(title + IntToStr(i + 1), 'command_off');
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        variables[index] := u_booltostr(Checked);
        if index > tabindex.max then
          tabindex.max := index;
        imageon := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'imageon')));
        imageoff := tex_LoadFromFile(Replacefolders(
          ini_ReadKeyStr(title + IntToStr(i + 1), 'imageoff')));
      end;
      i := i + 1;
    end;
    //Labels
    i := 1;
    title := 'label_';
    while ini_issection(title + IntToStr(i)) do
    begin
      Components.add(thlabel.Create);
      with (Components.last as thlabel) do
      begin
        log('(o) Loading Label No ' + IntToStr(i));
        init;
        x := ini_readkeyint(title + IntToStr(i), 'x');
        y := ini_readkeyint(title + IntToStr(i), 'y');
        ver_align(y, fntmain^.maxheight);
        top := ini_readkeyint(title + IntToStr(i), 'top');
        bottom := ini_readkeyint(title + IntToStr(i), 'bottom');
        left := ini_readkeyint(title + IntToStr(i), 'left');
        right := ini_readkeyint(title + IntToStr(i), 'right');
        len := ini_readkeyint(title + IntToStr(i), 'length');
        case ini_readkeystr(title + IntToStr(i), 'align') of
          'left': align := TEXT_HALIGN_LEFT;
          'right': align := TEXT_HALIGN_RIGHT;
          'center': align := TEXT_HALIGN_CENTER;
        end;
        Caption := replaceinternalvariables(ini_readkeystr(title + IntToStr(i), 'text'));
        color := ini_readkeyint(title + IntToStr(i), 'color');
        update := ini_readkeybool(title + IntToStr(i), 'update');
        opacity := ini_readkeyint(title + IntToStr(i), 'opacity');
        if ini_iskey(title + IntToStr(i), 'scale') then
          scale := strtofloat(ini_readkeystr(title + IntToStr(i), 'scale'));
        click := False;
        click := ini_readkeybool(title + IntToStr(i), 'click');
        command := ini_readkeystr(title + IntToStr(i), 'command');
        timer := False;
        variables[index] := Caption;
        timer := ini_readkeybool(title + IntToStr(i), 'timer');
        index := ini_readkeyint(title + IntToStr(i), 'index');
        if index > tabindex.max then
          tabindex.max := index;
        if update = True then
          if command <> '' then
            excommand(Caption, command);
        //excommand(caption,caption);
        hor_align(x, trunc(text_GetWidth(fntmain, Caption)));

      end;
      i := i + 1;
    end;
    //EditTexts
    i := 0;
    title := 'textedit_';
    while ini_issection(title + IntToStr(i + 1)) do
    begin
      Components.add(thedittext.Create);
      with (Components.last as thedittext) do
      begin
        log('(o) Loading textedit_ No ' + IntToStr(i + 1));
        init;
        x := ini_readkeyint(title + IntToStr(i + 1), 'x');
        y := ini_readkeyint(title + IntToStr(i + 1), 'y');
        w := ini_readkeyint(title + IntToStr(i + 1), 'width');
        h := ini_readkeyint(title + IntToStr(i + 1), 'height');
        hor_align(x, w);
        ver_align(y, h);
        top := ini_readkeyint(title + IntToStr(i + 1), 'top');
        bottom := ini_readkeyint(title + IntToStr(i + 1), 'bottom');
        left := ini_readkeyint(title + IntToStr(i + 1), 'left');
        right := ini_readkeyint(title + IntToStr(i + 1), 'right');
        case ini_readkeystr(title + IntToStr(i + 1), 'align') of
          'left': align := TEXT_HALIGN_LEFT;
          'right': align := TEXT_HALIGN_RIGHT;
          'center': align := TEXT_HALIGN_CENTER;
        end;
        Caption := ini_readkeystr(title + IntToStr(i + 1), 'text');
        color := ini_readkeyint(title + IntToStr(i + 1), 'color');
        opacity := ini_readkeyint(title + IntToStr(i + 1), 'opacity');
        length := ini_readkeyint(title + IntToStr(i + 1), 'length');
        click := False;
        click := ini_readkeybool(title + IntToStr(i + 1), 'click');
        command := ini_readkeystr(title + IntToStr(i + 1), 'command');
        edit := ini_readkeybool(title + IntToStr(i + 1), 'edit');
        variables[index] := Caption;
        index := ini_readkeyint(title + IntToStr(i + 1), 'index');
        if index > tabindex.max then
          tabindex.max := index;
        i := i + 1;
      end;
    end;

    while Components.Count < max_objects do
      Components.add(thdummy.Create);

    if ini_issection('timer') then
    begin
      title := 'timer';
      //screentimer:=timer_add(@timercommands,ini_readkeyint(title, 'interval'););
      screentimer^.interval := ini_readkeyint(title, 'interval');
      timercommand := ini_readkeystr(title, 'command');
      screentimer^.active := True;
    end;

    if ini_IsKey('background', 'command') then
      excommand(tmp, ini_ReadKeyStr('background', 'command'));

    ini_free;
    findtabindex(False);
    loading := False;
    throbber.Visible := False;

    if screen.trans_in <> 0 then
    begin
      screen.Inittransition(cammain, screen.trans_in, False);
    end;
    maintimer := timer_Add(@Timer, 80);
    keytimer^.active := True;
  end;

  function InternalVars(variable: string): string;
  var
    i: byte;
    b: string;
  begin
    case u_strdown(variable) of
      '$error': Result := error.Text;
      '$joysticks': Result := 'Found ' + IntToStr(joycount) + ' joysticks';
      '$dir_main': Result := dir_main;
      '$dir_font': Result := dir_font;
      '$dir_sound': Result := dir_sound;
      '$dir_theme': Result := dir_theme;
      '$dir_image': Result := dir_image;
      '$screen_width': Result := u_inttostr(scrwidth);
      '$screen_height': Result := u_inttostr(scrheight);
      '$theme': Result := theme.Name;
      '$fullscreen': Result := u_booltostr(fullscreen);
      '$mousex': Result := u_inttostr(mouse_x());
      '$mousey': Result := u_inttostr(mouse_y());
      '$title': Result := title;
      '$screen': Result := theme.screen;
      '$listitem': Result := u_inttostr(listitem);
      '$sql_count': Result := u_inttostr(sql.Count);
      '$sql_index': Result := u_inttostr(sql.ItemIndex + 1);
      '$sql_filename': Result := sql.filename;
      '$sql_table': Result := sql.table;
      '$home': Result := getuserdir;
      '$fps': Result := u_inttostr(zgl_Get(RENDER_FPS));
      else
      begin
        b := variable;
        Delete(b, 1, 1);
        Result := GetEnvironmentVariable(b);
      end;
    end;
    for i := 1 to max_objects do
      if u_strdown(variable) = '$var' + format('%0:3.3d', [i - 1]) then
        Result := variables[i - 1];
    if sql.active then
      for i := 0 to sql.ds.fields.Count - 1 do
      begin
        if u_strdown(variable) = '$field' + format('%0:2.2d', [i]) then
          Result := sql.ds.fields[i].AsString;
      end;
  end;

  function Replacefolders(stra: utf8string): utf8string;
  var
    i: byte;
    str: utf8string;
  begin
    str := stra;
    str := StringReplace(str, '$dir_main', internalvars('$dir_main'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_font', internalvars('$dir_font'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_sound', internalvars('$dir_sound'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_theme', internalvars('$dir_theme'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_image', internalvars('$dir_image'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$home', internalvars('$home'), [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$theme', internalvars('$theme'), [rfReplaceAll, rfIgnoreCase]);
    {$IFDEF WIN32}
    str := StringReplace(str, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
  {$ENDIF}
  {$IFDEF LINUX}
    str := StringReplace(str, '//', '/', [rfReplaceAll, rfIgnoreCase]);
  {$ENDIF}
    Result := str;
  end;

  function ReplaceInternalVariables(stra: utf8string): utf8string;
  var
    i: byte;
    str: utf8string;
  begin
    str := stra;
    str := StringReplace(str, '$error', internalvars('$error'), [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$joysticks', internalvars('$joysticks'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_main', internalvars('$dir_main'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_font', internalvars('$dir_font'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_sound', internalvars('$dir_sound'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_theme', internalvars('$dir_theme'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$dir_image', internalvars('$dir_image'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$screen_width', internalvars('$screen_width'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$screen_height', internalvars('$screen_height'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$theme', internalvars('$theme'), [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$fullscreen', internalvars('$fullscreen'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$mousex', internalvars('$mousex'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$mousey', internalvars('$mousey'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$title', internalvars('$title'), [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$screen', internalvars('$screen'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$listitem', internalvars('$listitem'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$sql_count', internalvars('$sql_count'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$sql_index', internalvars('$sql_index'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$sql_filename', internalvars('$sql_filename'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$sql_table', internalvars('$sql_table'),
      [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$home', internalvars('$home'), [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '$fps', internalvars('$fps'), [rfReplaceAll, rfIgnoreCase]);
    for i := 0 to max_objects - 1 do
    begin
      str := StringReplace(str, '$var' + format('%0:3.3d', [i]), internalvars(
        '$var' + format('%0:3.3d', [i])), [rfReplaceAll, rfIgnoreCase]);
    end;
  {$IFDEF WIN32}
    str := StringReplace(str, '\\', '\', [rfReplaceAll, rfIgnoreCase]);
  {$ENDIF}
  {$IFDEF LINUX}
    str := StringReplace(str, '//', '/', [rfReplaceAll, rfIgnoreCase]);
  {$ENDIF}

    str := StringReplace(str, pathsep + pathsep, pathsep, [rfReplaceAll, rfIgnoreCase]);
    str := StringReplace(str, '//', pathsep, [rfReplaceAll, rfIgnoreCase]);

    if sql.active then
    begin
      for i := 0 to sql.ds.fields.Count - 1 do
        str := StringReplace(str, '$field' + format('%0:2.2d', [i]), internalvars(
          '$field' + format('%0:2.2d', [i])), [rfReplaceAll, rfIgnoreCase]);
    end;
    Result := str;
  end;

  procedure Externalcommand(var Caption: utf8string; com: utf8string);
  var
    tmp: utf8string;
    str: utf8string;
  begin
    tmp := com;
    if tmp[1] = '|' then
    begin
      Delete(tmp, 1, 1);
      log('= External Command ===================================');
      log('= ' + tmp);
      tmp := ReplaceInternalVariables(tmp);
      log('= Executing: ' + tmp);
      str := runbig(tmp);
      if str <> '' then
        Caption := str;
      log('= Result: ' + str);
      log('======================================================');
    end;
  end;

  function ExCommand(var Caption: utf8string; str: utf8string): string;
  var
    com: string;
    tmp, t: utf8string;
    multiple: TStringList;
    d, z, k: integer;
    args: TStringList;
    temp, fields: TStringList;
    lv: thlistview;
    bt: boolean;
  begin
    if str = '' then
      exit;
    tmp := str;
    multiple := TStringList.Create;
    args := TStringList.Create;
    try
      SplitText(';', tmp, multiple);
    except
      log('<error> Error in split text (1)');
    end;

    for d := 0 to multiple.Count - 1 do
    begin
      args.Clear;
      tmp := multiple[d];
      try
        //external commands
        if tmp[1] = '|' then
        begin
          Delete(tmp, 1, 1);
          log('= External Command ===================================');
          log('= ' + tmp);
          tmp := ReplaceInternalVariables(tmp);
          log('= Executing: ' + tmp);
          str := runbig(tmp);
          if str <> '' then
            Caption := str;
          log('= Result: ' + str);
          log('======================================================');
        end;
      except
        log('<error> Error in external command');
      end;
      //internal variables
      if tmp[1] = '$' then
      begin
        Caption := internalvars(tmp);
        log('(o) Internal var.: ' + tmp + ' --> ' + Caption);
      end;
      if tmp[1] = '!' then
      begin
        Delete(tmp, 1, 1);
        if pos('(', tmp) > 0 then
        begin
          com := utf8_copy(tmp, 1, pos('(', tmp) - 1);
          Delete(tmp, 1, pos('(', tmp));
          if pos(')', tmp) <= 0 then
          begin
            Result := 'Error - Parenthesis not closed';
            seterror('Error', Result);
            timerdelay := 990;
            multiple.Free;
            exit;
          end;
          Delete(tmp, pos(')', tmp), 1);
          try
            splittext('#', tmp, args);
          except
            log('<error> splitext: error 2');
          end;
          for z := 0 to args.Count - 1 do
          begin
            tmp := args[z];
            if tmp[1] = '$' then
            begin
              tmp := replaceinternalvariables(args[z]);
              args[z] := tmp;
            end
            else
            begin
              externalcommand(tmp, args[z]);
              args[z] := tmp;
            end;
            log('(o) Arg. ' + IntToStr(z) + ' : ' + args[z] + 'Exported to: ' + tmp);
          end;
        end
        else
          com := tmp;
        log('(o) Found command: ' + com);
        case u_strdown(com) of
          'exit':
          begin
            theme.screen := 'exit';
            quit;
            multiple.Free;
            args.Free;
            exit;
          end;
          'themeupdate': update_theme;
          'joystick':
          begin
            joy_close;
            joyCount := joy_Init();
          end;
          'screenrotate':
          begin
            if args.Count < 1 then
            begin
              seterror('screenrotate', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case u_strdown(args[1]) of
              'left':
              begin
                cammain.angle := cammain.angle - 90;
                if cammain.angle < 0 then
                  cammain.angle := 360;
              end;
              'right':
              begin
                cammain.angle := cammain.angle + 90;
                if cammain.angle > 360 then
                  cammain.angle := 0;
              end;
              else
                try
                  cammain.angle := u_strtoint(args[1]);
                except
                  log('(o) Integer conversion fault on ScreenRotate');
                end;
            end;
          end;
          'hslider':
          begin
            if args.Count < 1 then
            begin
              seterror('hslider', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case args[0] of
              'left': hslider.slideleft;
              'right': hslider.slideright;
            end;
          end;
          'vslider':
          begin
            if args.Count < 1 then
            begin
              seterror('vslider', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case args[0] of
              'up': vslider.slideup;
              'down': vslider.slidedown;
            end;
          end;
          'setopacity':
          begin
            if args.Count < 2 then
            begin
              seterror('fade', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thbutton) then
              (objectbyindex(StrToInt(args[0])) as thbutton).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thlabel) then
              (objectbyindex(StrToInt(args[0])) as thlabel).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thtext) then
              (objectbyindex(StrToInt(args[0])) as thtext).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thtextviewer) then
              (objectbyindex(StrToInt(args[0])) as thtextviewer).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thgauge) then
              (objectbyindex(StrToInt(args[0])) as thgauge).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thslider) then
              (objectbyindex(StrToInt(args[0])) as thslider).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thclock) then
              (objectbyindex(StrToInt(args[0])) as thclock).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thlistview) then
              (objectbyindex(StrToInt(args[0])) as thlistview).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thsqllistview) then
              (objectbyindex(StrToInt(args[0])) as thsqllistview).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thhorizontalslider) then
              (objectbyindex(StrToInt(args[0])) as thhorizontalslider).opacity :=
                u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thvideo) then
              (objectbyindex(StrToInt(args[0])) as thvideo).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thpanel) then
              (objectbyindex(StrToInt(args[0])) as thpanel).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thprogress) then
              (objectbyindex(StrToInt(args[0])) as thprogress).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thedittext) then
              (objectbyindex(StrToInt(args[0])) as thedittext).opacity := u_strtoint(args[1]);
            if (objectbyindex(StrToInt(args[0])) is thswitch) then
              (objectbyindex(StrToInt(args[0])) as thswitch).opacity := u_strtoint(args[1]);
          end;
          'fade':
          begin
            if args.Count < 2 then
            begin
              seterror('fade', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thbutton) then
              case lowercase(args[1]) of
                'up': (objectbyindex(StrToInt(args[0])) as thbutton).fade(2);
                'down': (objectbyindex(StrToInt(args[0])) as thbutton).fade(1);
              end;
            if (objectbyindex(StrToInt(args[0])) is thvideo) then
              case lowercase(args[1]) of
                'up': (objectbyindex(StrToInt(args[0])) as thvideo).fade(2);
                'down': (objectbyindex(StrToInt(args[0])) as thvideo).fade(1);
              end;
          end;
          'slide':
          begin
            if args.Count < 2 then
            begin
              seterror('slide', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thbutton) then
              case args[1] of
                'top': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 1;
                'right': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 2;
                'bottom': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 3;
                'left': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 4;
                'fromtop': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 11;
                'fromright': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 12;
                'frombottom': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 13;
                'fromleft': (objectbyindex(StrToInt(args[0])) as thbutton).sliding := 14;
              end;
          end;
          'textviewer':
          begin
            if args.Count < 2 then
            begin
              seterror('textviewer', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thtextviewer) then
              case args[1] of
                'up': (objectbyindex(StrToInt(args[0])) as thtextviewer).keyup;
                'down': (objectbyindex(StrToInt(args[0])) as thtextviewer).keydown;
                'pgup': (objectbyindex(StrToInt(args[0])) as thtextviewer).keypgup;
                'pgdown': (objectbyindex(StrToInt(args[0])) as thtextviewer).keypgdown;
                'left': (objectbyindex(StrToInt(args[0])) as thtextviewer).keyleft;
                'right': (objectbyindex(StrToInt(args[0])) as thtextviewer).keyright;
              end;
          end;
          'screenshot':
          begin
            if args.Count < 1 then
            begin
              seterror('screenshot', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            ScreenToTGA(wndwidth, wndheight, args[0]);
          end;
          'video':
          begin
            if args.Count < 1 then
            begin
              seterror('video', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case u_strdown(args[0]) of
              'play': (Components[video] as thvideo).play := True;
              'pause': (Components[video] as thvideo).play := False;
              else
              begin
                tmp := args[0];
                tmp := replaceinternalvariables(tmp);
                if fileexists(tmp) then
                begin
                  (Components[video] as thvideo).filename := tmp;
                  (Components[video] as thvideo).vid := video_OpenFile(tmp);
                end;
              end;
            end;
          end;
          //saveinistring(<filename>#<section>#<key>#<value>)
          'saveinistring':
          begin
            if args.Count < 4 then
            begin
              seterror('saveinistring', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            saveinistring(args[0], args[1], args[2], args[3]);
          end;
          //getinistring(<index>#<filename>#<section>#<key>)
          'getinistring':
          begin
            if args.Count < 4 then
            begin
              seterror('getinistring', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thtext) then
              (objectbyindex(StrToInt(args[0])) as thtext).Caption :=
                getinistring(args[1], args[2], args[3]);
            if (objectbyindex(StrToInt(args[0])) is thlabel) then
              (objectbyindex(StrToInt(args[0])) as thlabel).Caption :=
                getinistring(args[1], args[2], args[3]);
          end;
          'getiniboolean':
          begin
            if args.Count < 4 then
            begin
              seterror('getiniboolean', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            tmp := getinistring(args[1], args[2], args[3]);
            if lowercase(tmp) = 'true' then
              bt := True
            else
              bt := False;
            if (objectbyindex(StrToInt(args[0])) is thswitch) then
              (objectbyindex(StrToInt(args[0])) as thswitch).Checked := bt;
          end;
          'background':
          begin
            if args.Count < 1 then
            begin
              seterror('background', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if fileexists(args[0]) then
            begin
              background := tex_LoadFromFile(args[0]);
              throbber.Visible := False;
              time := 5;
            end
            else
              seterror('', 'File ' + pathchar(dir_image) + args[0] + ' doesn''t exist');
          end;
          'update':
          begin
            for k := 0 to Components.Count - 1 do
            begin
              if (Components[k] is thlabel) and (Components[k] as thlabel).update then
                excommand((Components[k] as thlabel).Caption, (Components[k] as thlabel).command);
              if (Components[k] is thtext) and (Components[k] as thtext).update then
                excommand((Components[k] as thtext).Caption, (Components[k] as thtext).command);
              if (Components[k] is thtextviewer) and (Components[k] as
                thtextviewer).update then
                excommand(tmp, (Components[k] as thtextviewer).command);
            end;
            for k := 0 to Components.Count - 1 do
            begin
              if (Components[k] is thbutton) then
                if (Components[k] as thbutton).update = True then
                  excommand(tmp, (Components[k] as thbutton).command);
            end;
          end;
          'loadscreen':
          begin
            if args.Count < 1 then
            begin
              seterror('loadscreen', 'Invalid parameters');
              multiple.Free;

              args.Free;

              exit;
            end;
            if fileexists(dir_theme + args[0] + '.ini') then
            begin
              t := args[0];
              load_screen(t);
            end
            else
              seterror('', 'File ' + args[0] + ' doesn''t exist');
          end;
          'getfield':
          begin
            if args.Count < 4 then
            begin
              seterror('getfield', 'Invalid parameters');
              multiple.Free;

              args.Free;

              exit;
            end;
            if fileexists(pathchar(dir_main) + args[1]) then
            begin
              try
                temp := TStringList.Create;
                temp.loadfromfile(pathchar(dir_main) + args[1]);
                fields := TStringList.Create;

                if u_strdown(args[2]) = '$listitem' then
                begin
                  splittext(';', temp[listitem], fields);
                  if (objectbyindex(StrToInt(args[0])) is thtext) then
                    (objectbyindex(StrToInt(args[0])) as thtext).Caption := fields[u_strtoint(args[3]) - 1];
                  if (objectbyindex(StrToInt(args[0])) is thlabel) then
                    (objectbyindex(StrToInt(args[0])) as thlabel).Caption := fields[u_strtoint(args[3]) - 1];
                end
                else
                begin
                  splittext(';', temp[u_strtoint(args[2]) - 1], fields);
                  if (objectbyindex(StrToInt(args[0])) is thtext) then
                    (objectbyindex(StrToInt(args[0])) as thtext).Caption := fields[u_strtoint(args[3]) - 1];
                  if (objectbyindex(StrToInt(args[0])) is thlabel) then
                    (objectbyindex(StrToInt(args[0])) as thlabel).Caption := fields[u_strtoint(args[3]) - 1];
                end;
                fields.Free;

              finally
                temp.Free;

              end;
            end
            else
              seterror('getfield', 'File ' + pathchar(dir_main) + args[1] +
                ' doesn''t exist');
          end;
          'loadfromfile':
          begin
            if args.Count < 2 then
            begin
              seterror('loadfromfile', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            tmp := '';
            t := args[1];
            t := replaceinternalvariables(t);
            if (fileexists(t)) then
            begin
              tmp := t;
              try
                temp := TStringList.Create;
                temp.loadfromfile(tmp);
                if (objectbyindex(StrToInt(args[0])) is thtext) then
                  (objectbyindex(StrToInt(args[0])) as thtext).Caption := temp.Text;
                if (objectbyindex(StrToInt(args[0])) is thtextviewer) then
                begin
                  (objectbyindex(StrToInt(args[0])) as thtextviewer).textsl.Clear;
                  (objectbyindex(StrToInt(args[0])) as thtextviewer).xy := 0;
                  if (objectbyindex(StrToInt(args[0])) as thtextviewer).wrap then
                    wraplist((objectbyindex(StrToInt(args[0])) as thtextviewer).textsl, temp.Text,
                      (objectbyindex(StrToInt(args[0])) as thtextviewer).chars)
                  else
                    (objectbyindex(StrToInt(args[0])) as thtextviewer).textsl.Text := temp.Text;
                end;
                if (objectbyindex(StrToInt(args[0])) is thlabel) then
                  (objectbyindex(StrToInt(args[0])) as thlabel).Caption := temp.Text;
                if (objectbyindex(StrToInt(args[0])) is thslider) then
                  (objectbyindex(StrToInt(args[0])) as thslider).pos := u_strtoint(temp.Text);
                if (objectbyindex(StrToInt(args[0])) is thprogress) then
                  (objectbyindex(StrToInt(args[0])) as thprogress).pos := u_strtoint(temp.Text);
                if (objectbyindex(StrToInt(args[0])) is thgauge) then
                  (objectbyindex(StrToInt(args[0])) as thgauge).pos := u_strtoint(temp.Text);
              except
                temp.Free;
                log('Exception on Loadfromfile');

              end;
            end
            else
              seterror('loadfromfile', 'File ' + tmp + ' doesn''t exist');
          end;
          //getsimilarfile(<index>#<folder>#<filename>)
          'getsimilarfile':
          begin
            if args.Count < 3 then
            begin
              seterror('getsimilarfile', 'Invalid parameters');
              multiple.Free;

              args.Free;

              exit;
            end;
            tmp := removebrackets(removeext(args[2]));
            tmp := replaceinternalvariables(tmp);
            tmp := findromfile(tmp, args[1]);
            //log_add('getsimilarfile: '+tmp);
            if fileexists(pathchar(args[1]) + tmp) then
            begin
              if (objectbyindex(StrToInt(args[0])) is thbutton) then
              begin
                tex_del((objectbyindex(StrToInt(args[0])) as thbutton).image);
                (objectbyindex(StrToInt(args[0])) as thbutton).image :=
                  tex_LoadFromFile(pathchar(args[1]) + tmp);
                log('getsimilarfile: ' + pathchar(args[1]) + tmp);
              end;
            end;
          end;
          //getimagefromfield(<index>#<filename>#<line>#<field>)
          'getimagefromfield':
          begin
            if args.Count < 3 then
            begin
              seterror('getimagefromfield', 'Invalid parameters');
              multiple.Free;

              args.Free;

              exit;
            end;
            if fileexists(pathchar(dir_main) + args[1]) then
            begin
              try
                temp := TStringList.Create;
                temp.loadfromfile(pathchar(dir_main) + args[1]);
                fields := TStringList.Create;

                if u_strdown(args[2]) = '$listitem' then
                begin
                  splittext(';', temp[listitem], fields);
                  if (objectbyindex(StrToInt(args[0])) is thbutton) then
                    (objectbyindex(StrToInt(args[0])) as thbutton).image :=
                      tex_LoadFromFile(fields[u_strtoint(args[3]) - 1]);
                end
                else
                begin
                  splittext(';', temp[u_strtoint(args[2]) - 1], fields);
                  if (objectbyindex(StrToInt(args[0])) is thbutton) then
                    (objectbyindex(StrToInt(args[0])) as thbutton).image :=
                      tex_LoadFromFile(fields[u_strtoint(args[3]) - 1]);
                end;
                fields.Free;

              finally
                temp.Free;

              end;
            end
            else
              seterror('getimagefromfield', 'File ' + pathchar(dir_main) +
                args[1] + ' doesn''t exist');
          end;
          //getitemsfromfield(<index>#<filename>#<field>)
          'getitemsfromfield':
          begin
            if args.Count < 2 then
            begin
              seterror('getitemsfromfield', 'Invalid parameters');
              multiple.Free;

              args.Free;

              exit;
            end;
            if fileexists(pathchar(dir_main) + args[1]) then
            begin
              try
                temp := TStringList.Create;
                temp.loadfromfile(pathchar(dir_main) + args[1]);
                fields := TStringList.Create;
                if (objectbyindex(StrToInt(args[0])) is thlistview) then
                begin
                  lv := (objectbyindex(StrToInt(args[0])) as thlistview);
                  lv.items.Clear;
                  for k := 0 to temp.Count - 1 do
                  begin
                    splittext(';', temp[k], fields);
                    lv.items.add(fields[u_strtoint(args[2]) - 1]);

                  end;
                end;
                log('getitemsfromfield: ' + '1 ' + args[0] + '2 ' + args[1] + '3 ' +
                  args[2] + '4 ' + args[3]);
                fields.Free;

              finally
                temp.Free;

              end;
            end
            else
              seterror('getitemsfromfield', 'File ' + pathchar(dir_main) +
                args[1] + ' doesn''t exist');
          end;
          'setcolor':
          begin
            if args.Count < 2 then
            begin
              seterror('setcolor', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              if (objectbyindex(StrToInt(args[0])) is thtext) then
                (objectbyindex(StrToInt(args[0])) as thtext).color := u_strtoint(args[1]);
              if (objectbyindex(StrToInt(args[0])) is thtextviewer) then
                (objectbyindex(StrToInt(args[0])) as thtextviewer).color := u_strtoint(args[1]);
              if (objectbyindex(StrToInt(args[0])) is thlabel) then
                (objectbyindex(StrToInt(args[0])) as thlabel).color := u_strtoint(args[1]);
              if (objectbyindex(StrToInt(args[0])) is thedittext) then
                (objectbyindex(StrToInt(args[0])) as thedittext).color := u_strtoint(args[1]);
              if (objectbyindex(StrToInt(args[0])) is thbutton) then
                (objectbyindex(StrToInt(args[0])) as thbutton).color := u_strtoint(args[1]);
            except
              seterror('setcolor', 'Integer conversion fault');
            end;
          end;
          'setprogress':
          begin
            if args.Count < 2 then
            begin
              seterror('setprogress', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              case u_strdown(args[1]) of
                'up': (objectbyindex(u_StrToInt(args[0])) as THProgress).increase;
                'down': (objectbyindex(u_StrToInt(args[0])) as THProgress).decrease;
                else
                  (objectbyindex(StrToInt(args[0])) as THProgress).pos := u_StrToInt(trim(args[1]));
              end;
            except
              seterror('setprogress', 'Integer conversion fault');
            end;
          end;
          'setprogressmax':
          begin
            if args.Count < 2 then
            begin
              seterror('setprogressmax', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              (objectbyindex(StrToInt(args[0])) as THProgress).max := u_StrToInt(trim(args[1]));
            except
              seterror('setprogressmax', 'Integer conversion fault');
            end;
          end;
          'setgauge':
          begin
            if args.Count < 2 then
            begin
              seterror('setgauge', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              case u_strdown(args[1]) of
                'up': (objectbyindex(StrToInt(args[0])) as THgauge).increase;
                'down': (objectbyindex(StrToInt(args[0])) as THgauge).decrease;
                else
                begin
                  (objectbyindex(StrToInt(args[0])) as THgauge).pos := u_StrToInt(args[1]);
                end;
              end;
            except
              seterror('setgauge', 'Integer conversion fault');
            end;
          end;
          'setgaugemax':
          begin
            if args.Count < 2 then
            begin
              seterror('setgauge', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              (objectbyindex(StrToInt(args[0])) as THgauge).max := u_StrToInt(args[1]);
            except
              seterror('setgauge', 'Integer conversion fault');
            end;
          end;
          'listview':
          begin
            if args.Count < 2 then
            begin
              seterror('listview', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case u_strdown(args[1]) of
              'up': (objectbyindex(StrToInt(args[0])) as thlistview).keyup;
              'down': (objectbyindex(StrToInt(args[0])) as thlistview).keydown;
              'pgup': (objectbyindex(StrToInt(args[0])) as thlistview).keypgup;
              'pgdown': (objectbyindex(StrToInt(args[0])) as thlistview).keypgdown;
            end;
          end;
          'sqllistview':
          begin
            if args.Count < 2 then
            begin
              seterror('sqllistview', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            case u_strdown(args[1]) of
              'up': (objectbyindex(StrToInt(args[0])) as thsqllistview).keyup;
              'down': (objectbyindex(StrToInt(args[0])) as thsqllistview).keydown;
              //'pgup': (objectbyindex(StrToInt(args[0])) as thsqllistview).keypgup;
              //'pgdown': (objectbyindex(StrToInt(args[0])) as thsqllistview).keypgdown;
            end;
          end;
          'setimage':
          begin
            if args.Count < 2 then
            begin
              seterror('setimage', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            tmp := args[1];
            tmp := replaceinternalvariables(tmp);
            if fileexists(tmp) then
            begin
              log('(o) Loading... ' + tmp);
              (objectbyindex(StrToInt(args[0])) as thbutton).image := tex_loadfromfile(tmp);

            end;
          end;
          'setlabel':
          begin
            if args.Count < 2 then
            begin
              seterror('setlabel', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            (objectbyindex(StrToInt(args[0])) as thlabel).Caption := args[1];
          end;
          'playsound':
          begin
            if args.Count < 1 then
            begin
              seterror('playsound', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            log('(o) Playing sound... ' + args[0]);
            if fileexists(args[0]) then
              soundplay(args[0], theme.sounds);
          end;
          'throbber':
          begin
            if args.Count < 1 then
            begin
              seterror('throbber', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if args[0] = 'on' then
              throbber.Visible := True;
            if args[0] = 'off' then
              throbber.Visible := False;
            if (args[0] <> 'on') and (args[0] <> 'off') then
              seterror('throbber', 'Invalid command');
          end;
          //getsqlitemsfromfield(<index>#<field>)
          'getsqlitemsfromfield':
          begin
            if args.Count < 2 then
            begin
              seterror('getsqlitemsfromfield', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if (objectbyindex(StrToInt(args[0])) is thlistview) then
            begin
              lv := (objectbyindex(StrToInt(args[0])) as thlistview);
              lv.items.Clear;
              sql.ds.First;
              while not sql.ds.EOF do
              begin
                lv.items.add(sql.ds.fields[u_strtoint(args[2]) - 1].AsString);
                sql.ds.Next;
              end;
            end;
          end;
          //getsqlfield(<index>#<field_number)
          'getsqlfield':
          begin
            if (args.Count < 2) or (sql.active = False) then
            begin
              seterror('getsqlfield', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if sql.active then
            begin
              if (objectbyindex(StrToInt(args[0])) is thtext) then
                (objectbyindex(StrToInt(args[0])) as thtext).Caption :=
                  sql.ds.fields[u_strtoint(args[1])].AsString;
              if (objectbyindex(StrToInt(args[0])) is thlabel) then
                (objectbyindex(StrToInt(args[0])) as thlabel).Caption :=
                  sql.ds.fields[u_strtoint(args[1])].AsString;
            end;
          end;
          'getsqlimagefromfield':
          begin
            if args.Count < 2 then
            begin
              seterror('getsqlimagefromfield', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            if fileexists(pathchar(dir_main) + sql.ds.fields[u_strtoint(args[1])].AsString) then
            begin
              if (objectbyindex(StrToInt(args[0])) is thbutton) then
                (objectbyindex(StrToInt(args[0])) as thbutton).image :=
                  tex_LoadFromFile(pathchar(dir_main) + sql.ds.fields[u_strtoint(args[1])].AsString);
            end
            else
              seterror('getimagefromfield', 'File ' + pathchar(dir_main) +
                args[1] + ' doesn''t exist');
          end;
          'sql_next': if sql.active then
              sql.nextrecord
            else
              log('SQL not active!');
          'sql_prev': if sql.active then
              sql.prevrecord
            else
              log('SQL not active!');
          'sql_last': if sql.active then
              sql.lastrecord
            else
              log('SQL not active!');
          'sql_first': if sql.active then
              sql.firstrecord
            else
              log('SQL not active!');
          'sql_delete': if sql.active then
              sql.deleterecord
            else
              log('SQL not active!');
          'sql_exec':
          begin
            if (args.Count < 1) or (sql.active = False) then
            begin
              seterror('sql_exec', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            log('sql_exec: Executing... ' + args[0]);
            try
              tmp := args[0];
              tmp := replaceinternalvariables(tmp);
              sql.sqlexec(tmp);
              log('sql_exec: Success!');
              for k := 0 to Components.Count - 1 do
                if Components[k] is thsqllistview then
                begin
                  (Components[k] as thsqllistview).ItemIndex := 0;
                  (Components[k] as thsqllistview).selected := 0;
                  (Components[k] as thsqllistview).getitems;
                end;
              sql.firstrecord;
            except
              log('sql_exec: Failed on SQL command');
            end;
          end;
          'sql_update':
          begin
            if (args.Count < 1) or (sql.active = False) then
            begin
              seterror('sql_update', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            log('sql_update: Updating... ' + args[0]);
            try
              tmp := args[0];
              tmp := replaceinternalvariables(tmp);
              sql.sqlupdate(tmp);
              log('sql_update: Success!');
            except
              log('sql_update: Failed on SQL command');
            end;
          end;
          'sql_goto':
          begin
            if (args.Count < 1) or (sql.active = False) then
            begin
              seterror('sql_goto', 'Invalid parameters');
              multiple.Free;
              args.Free;
              exit;
            end;
            try
              sql.gotorec(u_strtoint(args[0]));
              log('sql_goto: Current record is: ' + args[0]);
            except
              log('sql_goto: Failed...');
            end;
          end;
        end;
      end;
    end;
    multiple.Free;
    args.Free;
    Result := '<none>';
  end;

  function Getobject(var typeof: byte; idx: byte): TObject;
  var
    i: integer;
  begin
    Result := nil;
    for i := 0 to Components.Count - 1 do
    begin
      if (Components[i] is thslider) then
        if (Components[i] as thslider).index = idx then
        begin
          typeof := 1;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thlabel) then
        if (Components[i] as thlabel).index = idx then
        begin
          typeof := 2;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thedittext) then
        if (Components[i] as thedittext).index = idx then
        begin
          typeof := 3;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thprogress) then
        if (Components[i] as thprogress).index = idx then
        begin
          typeof := 4;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thswitch) then
        if (Components[i] as thswitch).index = idx then
        begin
          typeof := 5;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thvideo) then
        if (Components[i] as thvideo).index = idx then
        begin
          typeof := 6;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thtext) then
        if (Components[i] as thtext).index = idx then
        begin
          typeof := 7;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thbutton) then
        if (Components[i] as thbutton).index = idx then
        begin
          typeof := 8;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thlistview) then
        if (Components[i] as thlistview).index = idx then
        begin
          typeof := 9;
          Result := Components[i];
          exit;
        end; //listview
      if (Components[i] is thgauge) then
        if (Components[i] as thgauge).index = idx then
        begin
          typeof := 10;
          Result := Components[i];
          exit;
        end; //gauge
      if (Components[i] is thtextviewer) then
        if (Components[i] as thtextviewer).index = idx then
        begin
          typeof := 11;
          Result := Components[i];
          exit;
        end;
      if (Components[i] is thsqllistview) then
        if (Components[i] as thsqllistview).index = idx then
        begin
          typeof := 12;
          Result := Components[i];
          exit;
        end; //sqllistview
    end;
  end;

  procedure Findtabindex(enter: boolean);
  var
    z: integer;
    tmp: utf8string;
  begin

    if hslider.active and (tabindex.index = hslider.index) then
    begin
      tabindex.x := hslider.x;
      tabindex.y := hslider.y;
      tabindex.w := hslider.W;
      tabindex.h := hslider.h;
      if enter then
      begin
        soundplay(theme.click_sound, theme.sounds);
        excommand(tmp, hslider.command);
      end;
      exit;
    end;
    if vslider.active and (tabindex.index = vslider.index) then
    begin
      tabindex.x := vslider.x;
      tabindex.y := vslider.y;
      tabindex.w := vslider.W;
      tabindex.h := vslider.h;
      if enter then
      begin
        soundplay(theme.click_sound, theme.sounds);
        excommand(tmp, vslider.command);
      end;
      exit;
    end;

    for z := 0 to Components.Count - 1 do
    begin
      if (Components.items[z] is thclock) then
      begin
        if tabindex.index = (Components.items[z] as thclock).index then
        begin
          tabindex.x := (Components.items[z] as thclock).x;
          tabindex.y := (Components.items[z] as thclock).y;
          tabindex.w := text_GetWidth(fntmain, (Components.items[z] as thclock).Caption);
          tabindex.h := text_GetHeight(fntmain, tabindex.w,
            (Components.items[z] as thclock).Caption, 0.9);
          //if enter then command(clock.command);
          exit;
        end;
      end;
      if (Components.items[z] is thvideo) then
      begin
        if (tabindex.index = (Components.items[z] as thvideo).index) and
          ((Components.items[z] as thvideo).Enabled) then
        begin
          tabindex.x := (Components.items[z] as thvideo).x;
          tabindex.y := (Components.items[z] as thvideo).y;
          tabindex.w := (Components.items[z] as thvideo).vid^.info.Width;
          tabindex.h := (Components.items[z] as thvideo).vid^.info.Height;
          if enter then
          begin
            (Components.items[z] as thvideo).play :=
              not (Components.items[z] as thvideo).play;
            soundplay(theme.click_sound, theme.sounds);
            video := z;
          end;
          exit;
        end;
      end;

      if (Components.items[z] is thlabel) then
        if (tabindex.index = (Components.items[z] as thlabel).index) then
        begin
          tabindex.x := (Components.items[z] as thlabel).x;
          tabindex.y := (Components.items[z] as thlabel).y;
          tabindex.w := text_GetWidth(fntmain, (Components.items[z] as thlabel).Caption);
          tabindex.h := text_GetHeight(fntmain, tabindex.w,
            (Components.items[z] as thlabel).Caption, 0.9);
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thlabel).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;

      if (Components.items[z] is thedittext) then
        if (tabindex.index = (Components.items[z] as thedittext).index) then
        begin
          tabindex.x := (Components.items[z] as thedittext).x;
          tabindex.y := (Components.items[z] as thedittext).y;
          tabindex.w := text_GetWidth(fntmain, (Components.items[z] as
            thedittext).Caption);
          tabindex.h := text_GetHeight(fntmain, tabindex.w,
            (Components.items[z] as thedittext).Caption, 0.9);
          if enter then
          begin
            //command((components.items[z] as thedittext).command);
            (Components[z] as thedittext).trackInput := True;
            trackinput := z;
            track := True;
            key_BeginReadText((Components[trackinput] as thedittext).Caption,
              (Components[trackinput] as thedittext).length);
            if (Components[trackinput] as thedittext).click then
              soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thedittext).index] :=
              (Components[z] as thedittext).Caption;
          end;
          exit;
        end;
      if (Components.items[z] is thbutton) then
        if (tabindex.index = (Components.items[z] as thbutton).index) then
        begin
          tabindex.x := (Components.items[z] as thbutton).x;
          tabindex.y := (Components.items[z] as thbutton).y;
          tabindex.w := (Components.items[z] as thbutton).w;
          tabindex.h := (Components.items[z] as thbutton).h;
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thbutton).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thtextviewer) then
        if (tabindex.index = (Components.items[z] as thtextviewer).index) then
        begin
          tabindex.x := (Components.items[z] as thtextviewer).x;
          tabindex.y := (Components.items[z] as thtextviewer).y;
          tabindex.w := (Components.items[z] as thtextviewer).Width;
          tabindex.h := (Components.items[z] as thtextviewer).Height;
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thtextviewer).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thlistview) then
        if (tabindex.index = (Components.items[z] as thlistview).index) then
        begin
          tabindex.x := (Components.items[z] as thlistview).x;
          tabindex.y := (Components.items[z] as thlistview).y;
          tabindex.w := (Components.items[z] as thlistview).w;
          tabindex.h := (Components.items[z] as thlistview).h;
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thlistview).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thsqllistview) then
        if (tabindex.index = (Components.items[z] as thsqllistview).index) then
        begin
          tabindex.x := (Components.items[z] as thsqllistview).x;
          tabindex.y := (Components.items[z] as thsqllistview).y;
          tabindex.w := (Components.items[z] as thsqllistview).w;
          tabindex.h := (Components.items[z] as thsqllistview).h;
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thsqllistview).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thprogress) then
        if (tabindex.index = (Components.items[z] as thprogress).index) then
        begin
          tabindex.x := (Components.items[z] as thprogress).x;
          tabindex.y := (Components.items[z] as thprogress).y;
          tabindex.w := (Components.items[z] as thprogress).w;
          tabindex.h := (Components.items[z] as thprogress).h;
          if enter then
          begin
            excommand(tmp, (Components.items[z] as thprogress).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thgauge) then
        if (tabindex.index = (Components.items[z] as thgauge).index) then
        begin
          tabindex.x := (Components.items[z] as thgauge).x;
          tabindex.y := (Components.items[z] as thgauge).y;
          tabindex.w := (Components.items[z] as thgauge).w;
          tabindex.h := (Components.items[z] as thgauge).h;
          if enter then
          begin
            variables[(Components[z] as thslider).index] :=
              IntToStr((Components[z] as thgauge).pos);
            excommand(tmp, (Components.items[z] as thgauge).command);
            soundplay(theme.click_sound, theme.sounds);
          end;
          exit;
        end;
      if (Components.items[z] is thslider) then
        if (tabindex.index = (Components.items[z] as thslider).index) then
        begin
          tabindex.x := (Components.items[z] as thslider).x;
          tabindex.y := (Components.items[z] as thslider).y;
          tabindex.w := (Components.items[z] as thslider).w;
          tabindex.h := (Components.items[z] as thslider).h;
          if enter then
          begin
            soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thslider).index] :=
              IntToStr((Components[z] as thslider).pos);
            excommand(tmp, (Components.items[z] as thslider).command);
          end;
          exit;
        end;
      if (Components.items[z] is thswitch) then
        if (tabindex.index = (Components.items[z] as thswitch).index) then
        begin
          tabindex.x := (Components.items[z] as thswitch).x;
          tabindex.y := (Components.items[z] as thswitch).y;
          tabindex.w := (Components.items[z] as thswitch).w;
          tabindex.h := (Components.items[z] as thswitch).h;
          if enter then
          begin
            soundplay(theme.click_sound, theme.sounds);
            (Components.items[z] as thswitch).Checked :=
              not (Components.items[z] as thswitch).Checked;
            if (Components.items[z] as thswitch).Checked then
              excommand(tmp, (Components.items[z] as thswitch).command_on)
            else
              excommand(tmp, (Components.items[z] as thswitch).command_off);
          end;
          exit;
        end;

    end;
    tabindex.x := 0;
    tabindex.y := 0;
    tabindex.w := 0;
    tabindex.h := 0;
  end;

  procedure Del_textures;
  var
    i: integer;
  begin
    tex_del(background);
    if Components.Count <= 0 then
      exit;
    for i := 0 to Components.Count - 1 do
    begin
      if Components[i] is thbutton then
        tex_del((Components[i] as thbutton).image);
      if Components[i] is thswitch then
      begin
        tex_del((Components[i] as thswitch).imageon);
        tex_del((Components[i] as thswitch).imageoff);
      end;
      if Components[i] is thprogress then
      begin
        tex_del((Components[i] as thprogress).image_full);
        tex_del((Components[i] as thprogress).image_empty);
      end;
      if Components[i] is thslider then
      begin
        tex_del((Components[i] as thslider).image_bg);
        tex_del((Components[i] as thslider).image_fg);
      end;
      if Components[i] is thpanel then
      begin
        tex_del((Components[i] as thpanel).image_t);
        tex_del((Components[i] as thpanel).image_r);
        tex_del((Components[i] as thpanel).image_l);
        tex_del((Components[i] as thpanel).image_b);
        tex_del((Components[i] as thpanel).image_tr);
        tex_del((Components[i] as thpanel).image_tl);
        tex_del((Components[i] as thpanel).image_br);
        tex_del((Components[i] as thpanel).image_bl);
      end;
    end;
  end;

  procedure Init;
  var
    i: byte;
  begin
    screen := thscreen.Create;
    screen.init;
    cam2d_Init(camMain);
    screen.Width := scrwidth;
    screen.Height := scrheight;
    snd_Init();
    secs := 0;
    quiting := False;
    Components := TObjectList.Create;
    Components.OwnsObjects := True;
    throbber := ththrobber.Create;

    hslider := thhorizontalslider.Create;
    hslider.init;
    vslider := thverticalslider.Create;
    vslider.init;
    joy1 := False;
    joy2 := False;
    timerdelay := 0;
    for i := 0 to max_objects - 1 do
      variables[i] := '';
    fntmain := nil;
    tabindex.index := 1;
    showbevel := False;
    beveltimer := 0;

    sql := thsqlite.Create;
    sql.init;
    load_screen('main');
    joyCount := joy_Init();
  end;

  procedure Quit;
  var
    op: integer;
  begin
    if quiting then
      exit;
    quiting := True;
    keytimer^.active := False;
    joytimer^.active := False;
    screentimer^.active := False;
    maintimer^.active := False;
    clearcomponents;

    try
      if assigned(Components) then
        Components.Free;
    except
      on E: Exception do
      begin
        log('Exception class name (Components) = ' + E.ClassName);
        log('Exception message (Components) = ' + E.Message);
      end;
    end;

    if assigned(throbber) then
      throbber.Free;

    if assigned(hslider) then
      hslider.Free;

    if assigned(vslider) then
      vslider.Free;

    if assigned(sql) then
      sql.Free;
    screen.Free;
    zgl_Exit();
  end;

  procedure Update(dt: double);
  begin
    // EN: This function is the best way to implement smooth moving of something, because accuracy of timers are restricted by FPS.
    timer_GetTicks;
    if (video <> 0) and (Components[video] as thvideo).play then
      video_Update((Components[video] as thvideo).vid, dt, True);
  end;

  procedure Draw;
  var
    z: integer;
    w: single;
  begin
    if loading then
      exit;
    batch2d_Begin();
    zgl_Disable(COLOR_BUFFER_CLEAR);
    if time <= 255 then
    begin
      ssprite2d_Draw(background, 0, 0, theme.Width, theme.Height, 0, time);
    end
    else
    begin
      if bgcolor = 0 then
        ssprite2d_Draw(background, 0, 0, theme.Width, theme.Height, 0, 255)
      else
      begin
        fx2d_SetColor(bgcolor);
        ssprite2d_Draw(background, 0, 0, theme.Width, theme.Height, 0,
          255, FX_BLEND or FX_COLOR);
      end;
    end;
    cam2d_Set(@camMain);
    case theme.screen of
      'exit': ;
      'main':
      begin
        //Draw Background

        fx_SetBlendMode(FX_BLEND_NORMAL);

        for z := 0 to Components.Count - 1 do
        begin

          if Components[z] is thpanel then
            (Components[z] as thpanel).draw;

          if (Components[z] is thvideo) and (Components[z] as thvideo).play then
            (Components[z] as thvideo).draw;

          if Components[z] is thlistview then
            (Components[z] as thlistview).draw;

          if Components[z] is thsqllistview then
            (Components[z] as thsqllistview).draw;

          if Components[z] is thclock then
            (Components[z] as thclock).draw(fntmain, 255);

          if Components[z] is thbutton then
            (Components[z] as thbutton).draw(fntmain, False);

          if Components[z] is thprogress then
            (Components[z] as thprogress).draw;

          if Components[z] is thgauge then
            (Components[z] as thgauge).draw;

          if Components[z] is thslider then
            (Components[z] as thslider).draw;

          if Components[z] is thswitch then
            (Components[z] as thswitch).draw;

          if Components[z] is thlabel then
            (Components[z] as thlabel).draw(fntmain, (Components[z] as thlabel).opacity);

          if Components[z] is thtext then
            (Components[z] as thtext).draw(fntmain, (Components[z] as thtext).opacity);

          if Components[z] is thtextviewer then
            (Components[z] as thtextviewer).draw(fntmain, (Components[z] as thtextviewer).opacity);

          if Components[z] is thedittext then
            (Components[z] as thedittext).draw(fntmain, (Components[z] as thedittext).opacity);

        end;

        if hslider.active then
          hslider.draw;
        if vslider.active then
          vslider.draw;

        if track then
        begin
          w := text_GetWidth(fntMain, (Components[trackinput] as thedittext).Caption);
          pr2d_Rect((Components[trackinput] as thedittext).x + w + 2,
            (Components[trackinput] as thedittext).y, 10,
            text_GetHeight(fntmain, w, (Components[trackinput] as
            thedittext).Caption, 0.9),
            (Components[trackinput] as thedittext).color, lineAlpha, PR2D_FILL);
        end;


        //mouseover_img(icon[state],( scrwidth - 128 ) div 2,( scrheight - 128 ) div 2,128,128,155);
        if throbber.Visible then
          throbber.draw(screen.Width, screen.Height);

      end;

    end;
    cam2d_Set(nil);
    if showbevel = True then
      pr2d_Rect(tabindex.x - 2, tabindex.y - 2, tabindex.w + 2, tabindex.h + 2,
        theme.font_color, lineAlpha, PR2D_smooth);
    if secs <> 0 then
      text_Drawex(fntmain, 1, 1, 5, 0, u_inttostr(secs), 255, theme.font_color);
    if debug then
    begin
      text_Draw(fntMain, 0, 0, 'FPS: ' + u_IntToStr(zgl_Get(RENDER_FPS)));
      text_Draw(fntMain, 0, 30, 'Fonts: ' + u_IntToStr(managerFont.Count));
    end;
    batch2d_End();
  end;

  procedure timercommands;
  var
    tmp: string;
  begin
    if timercommand <> '' then
      excommand(tmp, timercommand);
  end;

  procedure addseconds;
  begin
    secs := secs + 1;
  end;

  procedure keyboard;
  var
    z: integer;
    tmp: utf8string;
    typeof: byte;
    obj: TObject;
  begin
    if key_press(k_up) or (joy_AxisPos(0, JOY_AXIS_Y) = -1) or
      (joy_AxisPos(1, JOY_AXIS_Y) = -1) then
    begin
      if hslider.active and (tabindex.index = hslider.index) then
      begin
        if hslider.top <> 0 then
          tabindex.index := hslider.top
        else
          soundplay(theme.error_sound, theme.sounds);
      end
      else
      if vslider.active then
      begin
        vslider.slideup;
        listitem := vslider.ItemIndex;
        if u_strup(vslider.comnext) <> 'NIL' then
          excommand(tmp, vslider.comnext);
      end
      else
      begin
        obj := getobject(typeof, tabindex.index);
        case typeof of
          1:
          begin
            (obj as thslider).increase;
            variables[tabindex.index] := IntToStr((obj as thslider).index);
          end;
          2: if (obj as thlabel).top <> 0 then
              tabindex.index := (obj as thlabel).top
            else
              soundplay(theme.error_sound, theme.sounds);
          3: if (obj as thedittext).top <> 0 then
              tabindex.index := (obj as thedittext).top
            else
              soundplay(theme.error_sound, theme.sounds);
          4: if (obj as thprogress).top <> 0 then
              tabindex.index := (obj as thprogress).top
            else
              soundplay(theme.error_sound, theme.sounds);
          5: if (obj as thswitch).top <> 0 then
              tabindex.index := (obj as thswitch).top
            else
              soundplay(theme.error_sound, theme.sounds);
          6: if (obj as thvideo).top <> 0 then
              tabindex.index := (obj as thvideo).top
            else
              soundplay(theme.error_sound, theme.sounds);
          7: if (obj as thtext).top <> 0 then
              tabindex.index := (obj as thtext).top
            else
              soundplay(theme.error_sound, theme.sounds);
          8: if (obj as thbutton).top <> 0 then
              tabindex.index := (obj as thbutton).top
            else
              soundplay(theme.error_sound, theme.sounds);
          9:
          begin
            (obj as thlistview).keyup;
            variables[tabindex.index] := IntToStr((obj as thlistview).ItemIndex);
            listitem := (obj as thlistview).ItemIndex;
            if u_strup((obj as thlistview).commandsel) <> 'NIL' then
              excommand(tmp, (obj as thlistview).commandsel);
          end;
          10: if (obj as thgauge).top <> 0 then
              tabindex.index := (obj as thgauge).top
            else
              soundplay(theme.error_sound, theme.sounds);
          11:
          begin
            (obj as thtextviewer).keyup;
          end;
          12:
          begin
            (obj as thsqllistview).keyup;
            variables[tabindex.index] := IntToStr((obj as thsqllistview).ItemIndex);
            listitem := (obj as thsqllistview).ItemIndex;
            if u_strup((obj as thsqllistview).commandsel) <> 'NIL' then
              excommand(tmp, (obj as thsqllistview).commandsel);
          end;
        end;
      end;
      findtabindex(False);
      showbevel := True;
      beveltimer := 0;
    end;

    if key_press(k_down) or (joy_AxisPos(0, JOY_AXIS_Y) = 1) or
      (joy_AxisPos(1, JOY_AXIS_Y) = 1) then
    begin
      if hslider.active and (tabindex.index = hslider.index) then
      begin
        if hslider.bottom <> 0 then
          tabindex.index := hslider.bottom
        else
          soundplay(theme.error_sound, theme.sounds);
      end
      else if vslider.active then
      begin
        vslider.slidedown;
        listitem := vslider.ItemIndex;
        if u_strup(vslider.comnext) <> 'NIL' then
          excommand(tmp, vslider.comnext);
      end
      else
      begin
        obj := getobject(typeof, tabindex.index);
        case typeof of
          1:
          begin
            (obj as thslider).decrease;
            variables[tabindex.index] := IntToStr((obj as thslider).index);
          end;
          2: if (obj as thlabel).bottom <> 0 then
              tabindex.index := (obj as thlabel).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          3: if (obj as thedittext).bottom <> 0 then
              tabindex.index := (obj as thedittext).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          4: if (obj as thprogress).bottom <> 0 then
              tabindex.index := (obj as thprogress).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          5: if (obj as thswitch).bottom <> 0 then
              tabindex.index := (obj as thswitch).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          6: if (obj as thvideo).bottom <> 0 then
              tabindex.index := (obj as thvideo).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          7: if (obj as thtext).bottom <> 0 then
              tabindex.index := (obj as thtext).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          8: if (obj as thbutton).bottom <> 0 then
              tabindex.index := (obj as thbutton).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          9:
          begin
            (obj as thlistview).keydown;
            variables[tabindex.index] := IntToStr((obj as thlistview).ItemIndex);
            listitem := (obj as thlistview).ItemIndex;
            if u_strup((obj as thlistview).commandsel) <> 'NIL' then
              excommand(tmp, (obj as thlistview).commandsel);
          end;
          10: if (obj as thgauge).bottom <> 0 then
              tabindex.index := (obj as thgauge).bottom
            else
              soundplay(theme.error_sound, theme.sounds);
          11: (obj as thtextviewer).keydown;
          12:
          begin
            (obj as thsqllistview).keydown;
            variables[tabindex.index] := IntToStr((obj as thsqllistview).ItemIndex);
            listitem := (obj as thsqllistview).ItemIndex;
            if u_strup((obj as thsqllistview).commandsel) <> 'NIL' then
              excommand(tmp, (obj as thsqllistview).commandsel);
          end;
        end;
      end;
      findtabindex(False);
      showbevel := True;
      beveltimer := 0;
    end;

    if key_press(K_PAGEDOWN) or joy_down(0, 3) or joy_down(1, 3) then
    begin
      obj := getobject(typeof, tabindex.index);
      case typeof of
        9:
        begin
          (obj as thlistview).keypgdown;
          variables[tabindex.index] := IntToStr((obj as thlistview).index);
          listitem := (obj as thlistview).ItemIndex;
          if u_strup((obj as thlistview).commandsel) <> 'NIL' then
            excommand(tmp, (obj as thlistview).commandsel);
        end;
        11: (obj as thtextviewer).keypgdown;
      end;
    end;

    if key_press(K_PAGEUP) or joy_down(0, 2) or joy_down(1, 2) then
    begin
      obj := getobject(typeof, tabindex.index);
      case typeof of
        9:
        begin
          (obj as thlistview).keypgup;
          variables[tabindex.index] := IntToStr((obj as thlistview).index);
          listitem := (obj as thlistview).ItemIndex;
          if u_strup((obj as thlistview).commandsel) <> 'NIL' then
            excommand(tmp, (obj as thlistview).commandsel);
        end;
        11: (obj as thtextviewer).keypgup;
      end;
    end;

    if key_press(k_left) or (joy_AxisPos(0, JOY_AXIS_X) = -1) or
      (joy_AxisPos(1, JOY_AXIS_X) = -1) then
    begin
      if hslider.active then
      begin
        hslider.slideleft;
        listitem := hslider.ItemIndex;
        if u_strup(hslider.comnext) <> 'NIL' then
          excommand(tmp, hslider.comnext);
      end
      else if vslider.active and (tabindex.index = vslider.index) then
      begin
        if vslider.left <> 0 then
          tabindex.index := vslider.left
        else
          soundplay(theme.error_sound, theme.sounds);
      end
      else
      begin
        obj := getobject(typeof, tabindex.index);
        case typeof of
          1: if (obj as thslider).left <> 0 then
              tabindex.index := (obj as thslider).left
            else
              soundplay(theme.error_sound, theme.sounds);
          2: if (obj as thlabel).left <> 0 then
              tabindex.index := (obj as thlabel).left
            else
              soundplay(theme.error_sound, theme.sounds);
          3: if (obj as thedittext).left <> 0 then
              tabindex.index := (obj as thedittext).left
            else
              soundplay(theme.error_sound, theme.sounds);
          4: if (obj as thprogress).left <> 0 then
              tabindex.index := (obj as thprogress).left
            else
              soundplay(theme.error_sound, theme.sounds);
          5: if (obj as thswitch).left <> 0 then
              tabindex.index := (obj as thswitch).left
            else
              soundplay(theme.error_sound, theme.sounds);
          6: if (obj as thvideo).left <> 0 then
              tabindex.index := (obj as thvideo).left
            else
              soundplay(theme.error_sound, theme.sounds);
          7: if (obj as thtext).left <> 0 then
              tabindex.index := (obj as thtext).left
            else
              soundplay(theme.error_sound, theme.sounds);
          8: if (obj as thbutton).left <> 0 then
              tabindex.index := (obj as thbutton).left
            else
              soundplay(theme.error_sound, theme.sounds);
          9: if (obj as thlistview).left <> 0 then
              tabindex.index := (obj as thlistview).left
            else
              soundplay(theme.error_sound, theme.sounds);
          10: if (obj as thgauge).left <> 0 then
              tabindex.index := (obj as thgauge).left
            else
              soundplay(theme.error_sound, theme.sounds);
          11: if (obj as thtextviewer).left <> 0 then
              tabindex.index := (obj as thtextviewer).left
            else
              soundplay(theme.error_sound, theme.sounds);
          12: if (obj as thsqllistview).left <> 0 then
              tabindex.index := (obj as thsqllistview).left
            else
              soundplay(theme.error_sound, theme.sounds);
        end;
        findtabindex(False);
        showbevel := True;
        beveltimer := 0;
      end;
    end;

    if key_press(K_KP_SUB) then
    begin
      obj := getobject(typeof, tabindex.index);
      case typeof of
        1:
        begin
          (obj as thslider).decrease;
          variables[tabindex.index] := IntToStr((obj as thslider).index);
        end;
      end;
      findtabindex(False);
      showbevel := True;
      beveltimer := 0;
    end;

    if key_press(K_KP_ADD) then
    begin
      obj := getobject(typeof, tabindex.index);
      case typeof of
        1:
        begin
          (obj as thslider).increase;
          variables[tabindex.index] := IntToStr((obj as thslider).index);
        end;
      end;
      findtabindex(False);
      showbevel := True;
      beveltimer := 0;
    end;

    if key_press(k_right) or (joy_AxisPos(0, JOY_AXIS_X) = 1) or
      (joy_AxisPos(1, JOY_AXIS_X) = 1) then
    begin
      if hslider.active then
      begin
        hslider.slideright;
        listitem := hslider.ItemIndex;
        if u_strup(hslider.comnext) <> 'NIL' then
          excommand(tmp, hslider.comnext);
      end
      else if vslider.active and (tabindex.index = vslider.index) then
      begin
        if vslider.right <> 0 then
          tabindex.index := vslider.right
        else
          soundplay(theme.error_sound, theme.sounds);
      end
      else
      begin
        obj := getobject(typeof, tabindex.index);
        case typeof of
          1: if (obj as thslider).right <> 0 then
              tabindex.index := (obj as thslider).right
            else
              soundplay(theme.error_sound, theme.sounds);
          2: if (obj as thlabel).right <> 0 then
              tabindex.index := (obj as thlabel).right
            else
              soundplay(theme.error_sound, theme.sounds);
          3: if (obj as thedittext).right <> 0 then
              tabindex.index := (obj as thedittext).right
            else
              soundplay(theme.error_sound, theme.sounds);
          4: if (obj as thprogress).right <> 0 then
              tabindex.index := (obj as thprogress).right
            else
              soundplay(theme.error_sound, theme.sounds);
          5: if (obj as thswitch).right <> 0 then
              tabindex.index := (obj as thswitch).right
            else
              soundplay(theme.error_sound, theme.sounds);
          6: if (obj as thvideo).right <> 0 then
              tabindex.index := (obj as thvideo).right
            else
              soundplay(theme.error_sound, theme.sounds);
          7: if (obj as thtext).right <> 0 then
              tabindex.index := (obj as thtext).right
            else
              soundplay(theme.error_sound, theme.sounds);
          8: if (obj as thbutton).right <> 0 then
              tabindex.index := (obj as thbutton).right
            else
              soundplay(theme.error_sound, theme.sounds);
          9: if (obj as thlistview).right <> 0 then
              tabindex.index := (obj as thlistview).right
            else
              soundplay(theme.error_sound, theme.sounds);
          10: if (obj as thgauge).right <> 0 then
              tabindex.index := (obj as thgauge).right
            else
              soundplay(theme.error_sound, theme.sounds);
          11: if (obj as thtextviewer).right <> 0 then
              tabindex.index := (obj as thtextviewer).right
            else
              soundplay(theme.error_sound, theme.sounds);
          12: if (obj as thsqllistview).right <> 0 then
              tabindex.index := (obj as thsqllistview).right
            else
              soundplay(theme.error_sound, theme.sounds);
        end;
        findtabindex(False);
        showbevel := True;
        beveltimer := 0;
      end;
    end;

    if mouse_Click(M_BLEFT) then
    begin
      soundplay(theme.click_sound, theme.sounds);
      if hslider.active and hslider.mouseover then
      begin
        soundplay(theme.click_sound, theme.sounds);
        excommand(tmp, hslider.command);
      end;
      if vslider.active and vslider.mouseover then
      begin
        soundplay(theme.click_sound, theme.sounds);
        excommand(tmp, vslider.command);
      end;
      for z := Components.Count - 1 downto 0 do
      begin
        if Components[z] is thclock then
        begin
          if (Components[z] as thclock).click and
            (Components[z] as thclock).mouseover(fntmain) then
          begin
            soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thclock).index] :=
              (Components[z] as thclock).Caption;
            excommand(tmp, (Components[z] as thclock).command);
          end;
        end;
        if Components[z] is thvideo then
        begin
          if ((Components[z] as thvideo).mouseover) and
            ((Components[z] as thvideo).click = True) then
            (Components[z] as thvideo).play := not (Components[z] as thvideo).play;
          variables[(Components[z] as thvideo).index] :=
            u_booltostr((Components[z] as thvideo).play);
          soundplay(theme.click_sound, theme.sounds);
          video := z;
        end;
        if Components[z] is thbutton then
        begin
          if (Components[z] as thbutton).click and
            (Components[z] as thbutton).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            excommand(tmp, (Components[z] as thbutton).command);
          end;
        end;
        if Components[z] is thlistview then
        begin
          if (Components[z] as thlistview).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            tmp := u_IntToStr((Components[z] as thlistview).itemclicked);
            listitem := (Components[z] as thlistview).itemclicked;
            (Components[z] as thlistview).getitem(u_strtoint(tmp),
              (Components[z] as thlistview).item, (Components[z] as thlistview).commandsel,
              (Components[z] as thlistview).command);
            (Components[z] as thlistview).selected :=
              (Components[z] as thlistview).itemclicked - (Components[z] as thlistview).listtop;
            //excommand(tmp, (Components[z] as thlistview).command);
          end;
        end;
        if Components[z] is thsqllistview then
        begin
          if (Components[z] as thsqllistview).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            tmp := u_IntToStr((Components[z] as thsqllistview).itemclicked);
            listitem := (Components[z] as thsqllistview).itemclicked;
            (Components[z] as thsqllistview).getitem(u_strtoint(tmp),
              (Components[z] as thsqllistview).item);
            (Components[z] as thsqllistview).selected :=
              (Components[z] as thsqllistview).itemclicked - (Components[z] as thsqllistview).listtop;
          end;
        end;
        if Components[z] is thslider then
        begin
          if (Components[z] as thslider).Enabled and
            (Components[z] as thslider).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            (Components[z] as thslider).pos :=
              trunc(((Components[z] as thslider).h - (mouse_y - (Components[z] as thslider).y) -
              ((Components[z] as thslider).image_fg^.Height / 2)) * (Components[z] as thslider).max /
              ((Components[z] as thslider).max - (Components[z] as thslider).min));
            variables[(Components[z] as thslider).index] :=
              IntToStr((Components[z] as thslider).pos);
            excommand(tmp, (Components[z] as thslider).command);
          end;
        end;
        if Components[z] is thgauge then
        begin
          if (Components[z] as thgauge).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thgauge).index] :=
              IntToStr((Components[z] as thgauge).pos);
            excommand(tmp, (Components[z] as thgauge).command);
          end;
        end;
        if Components[z] is thprogress then
        begin
          if (Components[z] as thprogress).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thprogress).index] :=
              IntToStr((Components[z] as thprogress).pos);
            excommand(tmp, (Components[z] as thprogress).command);
          end;
        end;
        if Components[z] is thswitch then
        begin
          if (Components[z] as thswitch).click and
            (Components[z] as thswitch).mouseover then
          begin
            soundplay(theme.click_sound, theme.sounds);
            (Components[z] as thswitch).Checked :=
              not (Components[z] as thswitch).Checked;
            variables[(Components[z] as thswitch).index] :=
              u_booltostr((Components[z] as thswitch).Checked);
            if (Components[z] as thswitch).Checked then
              excommand(tmp, (Components[z] as thswitch).command_on)
            else
              excommand(tmp, (Components[z] as thswitch).command_off);
          end;
        end;
        if Components[z] is thlabel then
        begin
          if (Components[z] as thlabel).click and
            (Components[z] as thlabel).mouseover(fntmain) then
          begin
            soundplay(theme.click_sound, theme.sounds);
            variables[(Components[z] as thlabel).index] :=
              (Components[z] as thlabel).Caption;
            excommand((Components[z] as thlabel).Caption,
              (Components[z] as thlabel).command);
          end;
        end;
        if (Components[z] is thedittext) and (Components[z] as
          thedittext).mouseover(fntmain) then
        begin
          (Components[z] as thedittext).trackInput := True;
          trackinput := z;
          track := True;
          key_BeginReadText((Components[trackinput] as thedittext).Caption,
            (Components[trackinput] as thedittext).length);
          variables[(Components[z] as thedittext).index] :=
            (Components[z] as thedittext).Caption;
          if (Components[trackinput] as thedittext).click then
            soundplay(theme.click_sound, theme.sounds);
        end;
      end;
    end;

    if key_Press(K_ENTER) then
    begin
      if track then
      begin
        (Components[trackInput] as thedittext).trackInput := False;
        if (Components[trackInput] as thedittext).click then
          soundplay(theme.click_sound, theme.sounds);
        variables[(Components[trackInput] as thedittext).index] :=
          (Components[trackInput] as thedittext).Caption;
        trackinput := 0;
        track := False;
        key_EndReadText();
      end
      else
        findtabindex(True);
    end;

    if joy_down(0, 0) then
      if not joy1 then
      begin
        joy1 := True;
        secs := 0;
        joytimer^.active := True;
      end;
    if joy_down(0, 1) then
      if not joy2 then
      begin
        joy2 := True;
        secs := 0;
        joytimer^.active := True;
      end;
    if joy_up(0, 0) then
      if joy1 then
      begin
        joytimer^.active := False;
        case secs of
          0..1: findtabindex(True);
          2..10: excommand(tmp, getinistring(pathchar(dir_theme) + 'standard.ini',
              'commands', 'buttonA_' + u_inttostr(secs)));
        end;
        joy1 := False;
        secs := 0;
      end;
    if joy_up(0, 1) then
      if joy2 then
      begin
        joytimer^.active := False;
        case secs of
          0..1:
          begin
            soundplay(theme.click_sound, theme.sounds);
            if backscreen <> '' then
            begin
              //screen.transout:=true;
              load_screen(backscreen);
            end
            else
              zgl_Exit();
          end;
          2..10: excommand(tmp, getinistring(pathchar(dir_theme) + 'standard.ini',
              'commands', 'buttonB_' + u_inttostr(secs)));
        end;
        joy2 := False;
        secs := 0;
      end;

    if track then
    begin
      (Components[trackInput] as thedittext).Caption := key_GetText();
    end;

    if key_Press(K_ESCAPE) then
    begin
      soundplay(theme.click_sound, theme.sounds);
      if backscreen <> '' then
      begin
        //screen.transout:=true;
        load_screen(backscreen);
      end
      else
      begin
        theme.screen := 'exit';
        Quit;
        exit;
      end;
    end;

    key_ClearState();
    mouse_ClearState();
    joy_ClearState();
    //  touch_ClearState;
  end;

  procedure Timer;
  var
    d: integer;
  begin
    if loading or quiting then
      exit;
    if lineAlpha > 5 then
      Dec(lineAlpha, 40)
    else
      lineAlpha := 255;
    screen.draw(cammain);
    if screen.trans_done then
      load_screen(lastscreen);

    if time <= 255 then
      time := time + 10;
    if (intro_sound = 1) and (time > 255) then
    begin
      intro_sound := 0;
      soundplay(theme.intro_sound, theme.sounds);
      throbber.Visible := False;
    end;

    beveltimer := beveltimer + 1;
    if beveltimer >= 60 then
      showbevel := False;

    timerdelay := timerdelay + 1;
    if timerdelay = 1000 then
    begin
      for d := 0 to Components.Count - 1 do
        if Components[d] is thlabel then
          if (Components[d] as thlabel).timer then
          begin
            excommand((Components[d] as thlabel).Caption,
              (Components[d] as thlabel).command);
            (Components[d] as thlabel).draw(fntmain,
              (Components[d] as thlabel).opacity);
          end;
      timerdelay := 0;
    end;

  end;

  procedure Update_theme;
  begin
    if ini_loadfromfile(dir_main + 'settings.ini') = True then
    begin
      dir_theme := pathchar(pathchar(dir_main) + pathchar('theme') +
        ini_ReadKeyStr('theme', 'name'));
      theme.Name := ini_ReadKeyStr('theme', 'name');
      theme.Width := ini_ReadKeyInt('theme', 'width');
      theme.Height := ini_ReadKeyInt('theme', 'height');
      fullscreen := ini_ReadKeyBool('main', 'fullscreen');
      log('theme dir=' + dir_theme);
      dir_image := pathchar(pathchar(dir_theme) + 'images');
      log('image dir=' + dir_image);
      dir_sound := pathchar(pathchar(dir_theme) + 'sounds');
      log('sound dir=' + dir_sound);
      theme.sounds := True;
      theme.sounds := ini_readkeybool('sound', 'enable');
      dir_font := pathchar(pathchar(dir_theme) + 'fonts');
      log('font dir=' + dir_font);
      title := ini_readkeystr('main', 'title');
      theme.screen := 'main';
      ini_Free;
    end
    else
      log('INI file not found');
  end;

  procedure showhelp;
  begin
    writeln;
    writeln('âââââââââââââââââ Retroid Frontend');
    writeln('âââââââââââââââââ');
    writeln('âââââââââââââââââ  A simple GUI for making');
    writeln('âââââââââââââââââ  simple applications.');
    writeln('âââââââââââââââââ');
    writeln;
    writeln(' Optional Parameters:');
    writeln(' -hxxx   : Set screen height');
    writeln(' -wxxx   : Set screen width');
    Writeln(' -f      : Force fullscreen mode');
    Writeln(' -d      : Debug mode');
    writeln;
  end;

begin

  for gcount := 0 to paramcount do
    if u_StrUp(ParamStr(gcount)) = '--HELP' then
    begin
      showhelp;
      exit;
    end;
  {$IFNDEF USE_ZENGL_STATIC}
  if not zglLoad(libZenGL) then
    exit;
  {$ENDIF}
  log_Init;
  time := 10000;
  fullscreen := False;
  debug := False;
  intro_sound := 0;
  title := 'GUI';
  Width := 800;
  Height := 600;

  dir_main := pathchar(file_GetDirectory(ParamStr(0)));
  log('Main dir=' + dir_main);
  update_theme;

  for gcount := 0 to paramcount do
  begin

    if u_StrUp(ParamStr(gcount)) = '-F' then
      fullscreen := True;
    if u_StrUp(ParamStr(gcount)) = '-D' then
      debug := True;

    if pos('-W', u_StrUp(ParamStr(gcount))) > 0 then
    begin
      gstr := u_StrUp(ParamStr(gcount));
      Delete(gstr, 1, 2);
      try
        Width := u_StrToInt(gstr);
      except
        log('Error in width (-W) paramater, returning to normal width in windowed mode');
      end;
    end;

    if (pos('-H', u_StrUp(ParamStr(gcount))) > 0) then
    begin
      gstr := u_StrUp(ParamStr(gcount));
      Delete(gstr, 1, 2);
      try
        Height := u_StrToInt(gstr);
      except
        log('Error in height (-H)  paramater, returning to normal width in windowed mode');
      end;
    end;

    if u_StrUp(ParamStr(gcount)) = '-DESKTOP' then
    begin
      Width := zgl_Get(DESKTOP_WIDTH);
      Height := zgl_Get(DESKTOP_HEIGHT);
      fullscreen := True;
      zgl_Enable(CORRECT_RESOLUTION);
      scr_CorrectResolution(Width, Height);
    end;
  end;

  randomize();
  zgl_Reg(SYS_LOAD, @Init);
  zgl_Reg(SYS_DRAW, @Draw);
  zgl_Reg(SYS_EXIT, @Quit);
  zgl_Reg(SYS_UPDATE, @Update);
  wnd_SetCaption(title);
  wnd_ShowCursor(True);
  scr_SetOptions(Width, Height, REFRESH_MAXIMUM, fullscreen, True);
  joytimer := timer_add(@addseconds, 1000);
  joytimer^.active := False;
  keytimer := timer_add(@keyboard, 128);
  keytimer^.active := False;
  screentimer := timer_add(@timercommands, 1000);
  screentimer^.active := False;
  zgl_Init();

end.
