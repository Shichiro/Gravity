field = {};

Objects = {};

local path_to_file = "";
cur_object = nil;
is_set_speed = false;
edited_object = nil;
can_scaling = false;
can_rotate = false;
speed = 1;

local function visualizeFile()
  local file = io.open( system.pathForFile( path_to_file, system.DocumentsDirectory ), "r");

  if file then
    local bytes = Serialization.stringBytes( file:read("*a") );
    print(file:read("*a"))
    io.close( file );
    file = nil;

    speed = bytes[1];
    print(speed)

    local readed = 3; -- speed 1byte | size 2byte
    local frame = 0;

    while readed < #bytes do
      -- frame header
      local Objects, thorns, asps = bytes[readed + 1], bytes[readed + 2], bytes[readed + 3];
      readed = readed + 3;

      -- read Objects
      for i = 1, blocks do
        if bytes[readed + 1] and bytes[readed + 2] and bytes[readed + 3] and bytes[readed + 4] and bytes[readed + 5] then
          create.newBlock( { x = (frame * 32) + bytes[readed + 1], y = bytes[readed + 2], width = bytes[readed + 3], height = bytes[readed + 4] } );
          readed = readed + 5;
        end;
      end;

      -- read thorns
      for i = 1, thorns do
        if bytes[readed + 1] and bytes[readed + 2] and bytes[readed + 3] and bytes[readed + 4] then
          create.newThorn( { x = (frame * 32) + bytes[readed + 1], y = bytes[readed + 2], width = bytes[readed + 3] } );
          readed = readed + 4;
        end;
      end;

      -- read ASPs
      for i = 1, asps do
        if bytes[readed + 1] and bytes[readed + 2] and bytes[readed + 3] then
          create.newAddSkorePoint( { x = (frame * 32) + bytes[readed + 1], y = bytes[readed + 2], add = bytes[readed + 3] } );
          readed = readed + 3;
        end;
      end;

      frame = frame + 1;
    end;

    bytes = nil;
  end;
end;

function saveToFile()
  file = io.open( system.pathForFile( path_to_file, system.DocumentsDirectory ), "w");

  print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

  local sort_objects = {};
  local size = 0;


  -- сортировка
  for i = 1, #Blocks do
    local xpos = ( Blocks[i].x - tline.x ) / PIX_IN_BLOCK;
    local ypos = Blocks[i].y / PIX_IN_BLOCK;
    local w = Blocks[i].width / PIX_IN_BLOCK;
    local h = Blocks[i].height / PIX_IN_BLOCK;

    if xpos >= 0 and xpos < 0 and ypos < 15 and ypos >= 0 and w < 32 and w > 0 and h < 10 and h > 0 then
        size = xpos + w;
    else
      print( "\nsaving err: block out of" );
      if xpos < 0 then
        print( "xpos = " .. xpos );
      end;
      if ypos > 256 or ypos <= 0 then
        print( "ypos = " .. ypos );
      end;
      if w > 256 or w < 0 then
        print( "w    = " .. w );
      end;
      if h > 256 or h < 0 then
        print( "h    = " .. h );
      end;
    end;
  end;

  for i = 1, #Thorns do
    local xpos = ( Thorns[i].x - tline.x ) / PIX_IN_BLOCK;
    local ypos = Thorns[i].y / PIX_IN_BLOCK;
    local w = Thorns[i].width / PIX_IN_BLOCK;

    if xpos >= 0 and ypos < 256 and ypos >= 0 and w < 256 and w > 0 then
      if not frames[math.floor( xpos / 32 ) + 1] then
        frames[math.floor( xpos / 32 ) + 1] = { blocks = {}, thorns = {}, asps = {} };
      end;
      frames[math.floor( xpos / 32 ) + 1].thorns[#frames[math.floor( xpos / 32 ) + 1].thorns + 1] = Thorns[i];
    else
      print( "\nsaving err: thorn out of" );
      if xpos < 0 then
        print( "xpos = " .. xpos );
      end;
      if ypos > 256 or ypos <= 0 then
        print( "ypos = " .. ypos );
      end;
      if w > 256 or w < 0 then
        print( "w    = " .. w );
      end;
    end;
  end;

  for i = 1, #ASPs do
    local xpos = ( ( ASPs[i].x - tline.x ) - ( ( ASPs[i].x - tline.x ) % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    local ypos = ( ASPs[i].y - ( ASPs[i].y % PIX_IN_BLOCK)) / PIX_IN_BLOCK;

    if xpos >= 0 and ypos < 256 and ypos >= 0 and ASPs[i].add < 255 and ASPs[i].add > 0 then
      if not frames[math.floor( xpos / 32 ) + 1] then
        frames[math.floor( xpos / 32 ) + 1] = { blocks = {}, thorns = {}, asps = {} };
      end;
      frames[math.floor( xpos / 32 ) + 1].asps[#frames[math.floor( xpos / 32 ) + 1].asps + 1] = ASPs[i];
    else
      print( "\nsaving err: ASP out of" );
      if xpos < 0 then
        print( "xpos = " .. xpos );
      end;
      if ypos > 256 or ypos <= 0 then
        print( "ypos = " .. ypos );
      end;
      if ASPs[i].add > 255 or ASPs[i].add < 0 then
        print( "add = " .. ASPs[i].add );
      end;
    end;
  end;

  -- запись
  local content = string.char( speed ) .. string.char( math.floor( size / 255 ) ) .. string.char( size % 255 );
  for frame_num = 1, #frames do
    -- frame header
    content = content .. string.char( #frames[frame_num].blocks ) .. string.char( #frames[frame_num].thorns ) .. string.char( #frames[frame_num].asps );

    -- blocks
    for i = 1, #frames[frame_num].blocks do
      content = content .. string.char( (( frames[frame_num].blocks[i].x - tline.x ) / PIX_IN_BLOCK) % 32 );
      content = content .. string.char( frames[frame_num].blocks[i].y / PIX_IN_BLOCK );
      content = content .. string.char( frames[frame_num].blocks[i].width / PIX_IN_BLOCK );
      content = content .. string.char( frames[frame_num].blocks[i].height / PIX_IN_BLOCK );
    end;

    -- thorns
    for i = 1, #frames[frame_num].thorns do
      content = content .. string.char( (( frames[frame_num].thorns[i].x - tline.x ) / PIX_IN_BLOCK) % 32 );
      content = content .. string.char( frames[frame_num].thorns[i].y / PIX_IN_BLOCK );
      content = content .. string.char( frames[frame_num].thorns[i].width / PIX_IN_BLOCK );
    end;

    -- asps
    for i = 1, #frames[frame_num].asps do
      content = content .. string.char( (( ( frames[frame_num].asps[i].x - tline.x ) - ( ( frames[frame_num].asps[i].x - tline.x ) % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) % 32 );
      content = content .. string.char( ( frames[frame_num].asps[i].y - ( frames[frame_num].asps[i].y % PIX_IN_BLOCK)) / PIX_IN_BLOCK );
      content = content .. string.char( frames[frame_num].asps[i].add );
    end;
  end;

  print( "\nSaved: " .. tostring( #content ) .. " bytes");

  file:write( content );

  io.close( file );
  file = nil;
  content = nil;
  frames = nil;
end;

function saveToFile()
  file = io.open( system.pathForFile( path_to_file, system.DocumentsDirectory ), "w");

  print("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n");

  -- сортировка по X
  while
  for i = 1, #Objects do
    local xpos = ( Objects[i].x - tline.x ) / PIX_IN_BLOCK;


  end;

  -- первые три байта: speed 2 | size 1
  local size = ( ( Objects[#Objects].x - tline.x ) / PIX_IN_BLOCK ) + ( Objects[#Objects].height / PIX_IN_BLOCK ); -- длинна (в блоках) карты
  content = string.char( speed ) .. string.char( math.floor( size / 255 ) ) .. string.char( size % 255 );

  -- запись в фаил
  for i = 1, #Objects do
     file:write( content );
  end;

  io.close( file );
  file = nil;
  content = nil;
end;

local function keyListener( event )
  if event.phase == "down" then
    if event.keyName == "1" then
      create.newBlock( Objects, { x = 6, y = 6, width = 1, height = 1 } );

    elseif event.keyName == "2" and not input.isVisible then
     create_thorn = true;
     input.isVisible = true;

   elseif event.keyName == "3" and not input.isVisible then
      create_thorn = false;
      input.isVisible = true;

    elseif event.keyName == "leftShift" then
      can_scaling = true;

    elseif event.keyName == "f5" then
      saveToFile();

    elseif event.keyName == "s" and not input.isVisible then
      if cur_object then
        if cur_object.type == 3 then
          edited_object = cur_object;
          input.isVisible = true;
        end;

      else
        is_set_speed = true;
        edited_object = nil;
        input.isVisible = true;
      end;

    elseif event.keyName == "a" and cur_object and not input.isVisible then
      if not cur_object.type == 3 then
        edited_object = cur_object;
        input.isVisible = true;
      end;

    elseif event.keyName == "r" then
      can_rotate = true;

    elseif event.keyName == "deleteBack" or event.keyName == "deleteForward" and cur_object then
      table.remove( Objects, cur_object.i );
      local i = cur_object.i;
      while i <= #Objects do
         Objects[i].i = Objects[i].i - 1;
         i = i + 1;
       end;

      if cur_object.type == 1 then
        cur_object:removeEventListener( "touch", dragBlock );

      elseif cur_object.type == 2 then
         cur_object:removeEventListener( "touch", dragThorn );

      elseif cur_object.type == 3 then
         cur_object:removeEventListener( "touch", dragASP );
      end;

      cur_object:removeSelf();
      cur_object = nil;
    end;

  elseif event.keyName == "leftShift" then
    can_scaling = false;

    if cur_object then
      display.getCurrentStage():setFocus( nil );
      cur_object.isFocus = nil;
      cur_object = nil;
    end;

  elseif event.keyName == "r" then
    can_rotate = false;
  end;
end;

local grabX;
local function dragField( event )
  if event.phase == "began" then
    grabX = (event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK;

  elseif event.phase == "moved" and not cur_object then
    local drag = (((( event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabX ) * PIX_IN_BLOCK );

    tline.x = tline.x + drag;
    for i = 1, #Objects do
      Objects[i].x = Objects[i].x + drag;
    end;

    grabX = math.modf( event.x / PIX_IN_BLOCK );
  end;
end;

function field.show( frame_id )
  path_to_file = frame_id;
  visualizeFile();
  Runtime:addEventListener( "key", keyListener );
  Runtime:addEventListener( "touch", dragField );

  tline = display.newLine( 0, 0, 0, DISPLAY_HEIGHT );
  tline:setStrokeColor( 0.9, 0, 0, 0.4 );
  tline.strokeWidth = 2;
end;
