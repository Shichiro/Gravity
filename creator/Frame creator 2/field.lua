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
    io.close( file );
    file = nil;

    speed = bytes[1];
    size = bytes[2]*256 + bytes[3];
    local readed = 3; -- speed 1byte | size 2byte

    -- Расшифровка и создание первого блока
    local nextId = bytes[readed+5];
    create.newBlock( { x = bytes[readed+1], y = bytes[readed+2], width = bytes[readed+3], height = bytes[readed+4] } );
    xpos = bytes[readed+1];
    readed = readed + 5;

    while readed < #bytes do
      if nextId == 1 then
        -- Расшифровка и создание первого блока
        if bytes[readed+5] then
          nextId = bytes[readed+5];
        end;
        create.newBlock( { x = bytes[readed+1] + xpos, y = bytes[readed+2], width = bytes[readed+3], height = bytes[readed+4] } );
        xpos = bytes[readed+1] + xpos;
        readed = readed + 5;

      elseif nextId == 2 then
        -- Расшифровка и создание шипа
        if bytes[readed+5] then
          nextId = bytes[readed+5];
        end;
        create.newThorn( { x = bytes[readed+1] + xpos, y = bytes[readed+2], width = bytes[readed+3], rotation = (bytes[readed+4] - 1) * 90 } );
        xpos = bytes[readed+1] + xpos;
        readed = readed + 5;

      elseif nextId == 3 then
        -- Расшифровка и создание ASP
        if bytes[readed+4] then
          nextId = bytes[readed+4];
        end;
        create.newAddSkorePoint( { x = bytes[readed+1] + xpos, y = bytes[readed+2], add = bytes[readed+3] } );
        xpos = bytes[readed+1] + xpos;
        readed = readed + 4;
      end;
    end;
  end;

  bytes = nil;
end;

function saveToFile()
  file = io.open( system.pathForFile( path_to_file, system.DocumentsDirectory ), "w");

  -- сортировкао обьектов по X
  local function compare( a, b )
    return ( a.x - tline.x ) / PIX_IN_BLOCK < ( b.x - tline.x ) / PIX_IN_BLOCK;
  end;
  table.sort( Objects, compare );

  -- header : speed 1 byte | size 2 bytes
  local size = ( ( Objects[#Objects].x - tline.x ) / PIX_IN_BLOCK ) + ( Objects[#Objects].height / PIX_IN_BLOCK ); -- длинна (в блоках) карты
  file:write( string.char( speed ) .. string.char( math.floor( size / 256 ) ) .. string.char( size % 256 ) );

  -- запись обьектов в очереди
  for i = 1, #Objects do
    Objects[i].i = i;
    if Objects[i].type == 1 then
      -- x
      if Objects[i-1] then
        file:write( string.char( math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK) - math.floor(( Objects[i-1].x - tline.x ) / PIX_IN_BLOCK) ))
      else
        file:write( string.char( math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK) ) )
      end;

      -- y
      file:write( string.char( math.floor( Objects[i].y / PIX_IN_BLOCK ) ) )

      -- w
      file:write( string.char( math.floor( Objects[i].width / PIX_IN_BLOCK )))

      -- h
      file:write( string.char( math.floor( Objects[i].height / PIX_IN_BLOCK ) ) )

      -- id
      if Objects[i+1] then
        file:write( string.char( Objects[i+1].type ) )
      end;

    elseif Objects[i].type == 2 then
      -- x
      if Objects[i-1] then
        file:write( string.char(  math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK) - math.floor(( Objects[i-1].x - tline.x ) / PIX_IN_BLOCK)));
      else
        file:write( string.char( math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK)));
      end;

      -- y
      file:write( string.char( math.floor( Objects[i].y / PIX_IN_BLOCK )));

      -- w
      file:write( string.char( math.floor(Objects[i].width / PIX_IN_BLOCK)));

      -- rotation
      file:write( string.char( math.floor((Objects[i].rotation + 90) / 90)));

      -- id
      if Objects[i+1] then
        file:write( string.char( Objects[i+1].type ));
      end;

    elseif Objects[i].type == 3 then
      -- x
      if Objects[i-1] then
        file:write( string.char( math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK) - math.floor(( Objects[i-1].x - tline.x ) / PIX_IN_BLOCK)));
      else
        file:write( string.char( math.floor(( Objects[i].x - tline.x ) / PIX_IN_BLOCK)));
      end;

      -- y
      file:write( string.char( math.floor(Objects[i].y / PIX_IN_BLOCK) ));

      -- add
      file:write( string.char( Objects[i].add ));

      -- id
      if Objects[i+1] then
        file:write( string.char( Objects[i+1].type ));
      end;
    end;
  end;

  io.close( file );
  file = nil;
end;

local function keyListener( event )
  if event.phase == "down" then
    if event.keyName == "1" then
      create.newBlock( { x = 6, y = 6, width = 1, height = 1 } );

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

    elseif event.keyName == "up" then
      if cur_object.type == 2 then
        cur_object.rotation = 0;
      end;

    elseif event.keyName == "down" then
      if cur_object.type == 2 then
        cur_object.rotation = 180;
      end;

    elseif event.keyName == "left" then
      if cur_object.type == 2 then
        cur_object.rotation = -90;
      end;

    elseif event.keyName == "right" then
      if cur_object.type == 2 then
        cur_object.rotation = 90;
      end;

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
