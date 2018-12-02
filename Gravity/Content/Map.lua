---- Переменные ---
local s_pos = math.ceil( DISPLAY_WIDTH / PIX_IN_BLOCK ) + PIX_IN_BLOCK; -- крайняя позиция спавна

-- генерируемые обьекты на экране
local Objects = display.newGroup();
Objects.alpha = 0;

-- позиция последнего блока в последнем фрейме
local cur_block = 0;

-- бинарные данные о текущей карте
local map_data = "";
local readed = 2;

-- пройденно блоков
local completed_blocks = 7;
local size = 0;

---- Локальные функции ----
-- Cоздаст новый обьект платформы
local function CreateNewBlock( params )
    -- Обьект
    local body = display.newRect(
      (cur_block + params.x) * PIX_IN_BLOCK,
      display.screenOriginY + params.y * PIX_IN_BLOCK,
      params.width * PIX_IN_BLOCK,
      params.height * PIX_IN_BLOCK );

    function body.collision( event )
      if event.phase == "began" then
        audio.play( collideSound );
      end;
    end;
    body:addEventListener( "collision" );

    body:setFillColor( 40/255, 65/255, 82/255 );
    body.anchorX, body.anchorY = 0, 0;
    body.rotation = params.rotation;
    physics.addBody( body, "kinematic", { isSensor = false, friction = 100 } );
    Objects:insert( body );
end;

-- Cоздаст новый обьект шипа
local function CreateNewThorn( params )
  -- Настройка
  display.setDefault( "textureWrapX", "repeat" );
  display.setDefault( "textureWrapY", "repeat" );

  --  обьект
  local body = display.newRect(
  ((cur_block + params.x) * PIX_IN_BLOCK),
  display.screenOriginY + params.y * PIX_IN_BLOCK,
  PIX_IN_BLOCK * params.width,
  PIX_IN_BLOCK * 0.4 );

  body.fill = { type="image", filename="Content/Textures/thorn.png" };
  body.fill.scaleX = 0.333 / params.width;
  body.fill.x = 1 / params.width;
  body.fill.scaleY = 1;
  body.anchorX, body.anchorY = 0, 1;
  body.rotation = params.rotation;
  body:setFillColor( 0.9, 0.2, 0.2, 0.9 );

  -- лисенер столкновений
  physics.addBody( body, "static", { isSensor = true } );
  function body.collision( self, event )
    if event.phase == "began" then
      Engine.gameOver();
    end;
  end;
  body:addEventListener( "collision" );

  Objects:insert( body );
end;

-- Cоздаст новую точку получения очков
local function CreateNewAddSkorePoint( params )
  -- создать обьект
  local body = display.newRect(
    (cur_block + params.x) * PIX_IN_BLOCK,
    display.screenOriginY + params.y * PIX_IN_BLOCK,
    PIX_IN_BLOCK,
    PIX_IN_BLOCK );

  body.alpha = 0;
  body.anchorX, body.anchorY = 0, 0;

  -- сенсор на столкновение с обьектом
  physics.addBody( body, "static", { isSensor = true } );

  -- лисенер столкновений
  function body.collision( self, event )
    if event.phase == "began" and event.other.isPlayer then
      Engine.addSkore( params.add );
      body:removeSelf();
    end;
  end;
  body:addEventListener( "collision" );

  -- добавить обьект в фрейм
  Objects:insert( body );
end;

-- возвращает таблицу с байтами входной строки
local function stringBytes( str )
  -- разбираем строку str на символы и кидаем всё в таблицу
  local str_bytes_table = {};
  for l = 1, #str do
    str_bytes_table[l] = string.byte(str, l);
  end;

  return str_bytes_table;
end;

-- Добавляет в таблицу Objects элементы из загруженного фрейма
local function addNextFrame()
  if readed < #map_data then
    -- фрейм хеадер
    local blocks, thorns, asps = map_data[readed + 1], map_data[readed + 2], map_data[readed + 3];
    readed = readed + 3;

    -- read blocks
    for i = 1, blocks do
      if map_data[readed + 1] and map_data[readed + 2] and map_data[readed + 3] and map_data[readed + 4] and map_data[readed + 5] then
        CreateNewBlock( Blocks, { x = map_data[readed + 1], y = map_data[readed + 2], width = map_data[readed + 3], height = map_data[readed + 4], rotation = map_data[readed + 5] * 3 } );
        readed = readed + 5;
      end;
    end;

    -- read thorns
    for i = 1, thorns do
      if map_data[readed + 1] and map_data[readed + 2] and map_data[readed + 3] and map_data[readed + 4] then
        CreatenewThorn( Thorns, { x = map_data[readed + 1], y = map_data[readed + 2], width = map_data[readed + 3], rotation = map_data[readed + 4] * 3 } );
        readed = readed + 4;
      end;
    end;

    -- read ASPs
    for i = 1, asps do
      if map_data[readed + 1] and map_data[readed + 2] and map_data[readed + 3] then
        CreateNewAddSkorePoint( ASPs, { x =map_data[readed + 1], y = map_data[readed + 2], add = map_data[readed + 3] } );
        readed = readed + 3;
      end;
    end;

    cur_block = cur_block + 32;
  end;
end;

-- Передвижение влево и отслеживание границы
local function move( event )
  -- обновление позиции
  completed_blocks = completed_blocks + ( Engine.moving_speed / PIX_IN_BLOCK );
  if completed_blocks >= size - 32 then
    Engine.stagePassed();
  else
    cur_block = cur_block - ( Engine.moving_speed / PIX_IN_BLOCK );
    if cur_block <= s_pos then
      addNextFrame();
    end;
  end;

  --     проходимся по всем обьектам и смещаем их,      --
  -- но если обьект вышел за левую границу, удаляем его --

  -- обьекты
  local i = 1;
  while i <= Objects.numChildren do
    if Objects[i].x + Objects[i].width >= display.screenOriginX then
      Objects[i].x = Objects[i].x - Engine.moving_speed;
      i = i + 1;
    else
      -- полное удаление
      Objects[i]:removeSelf();
    end;
  end;
end;
timer.performWithDelay( 10, move, -1 );


---- Реализация ----
local Map = {};

-- Возвращает количество пройденной карты в процентах
function Map:getPersents()
  local fix = completed_blocks - (size - 32);
  if fix > 0 then
    return math.floor( ( math.floor(completed_blocks - fix) / (size - 32)) * 100 );
  else
    return math.floor( ( math.floor(completed_blocks) / (size - 32)) * 100 );
  end;
end;

function Map:show()
  transition.fadeIn( Objects, short_tro );
end;

function Map:hide()
  transition.fadeOut( Objects, short_tro );
end;

-- изменение файла из которого будут читаться данные
function Map:setResourse( stage_id )
  -- Смена ресурса --
  local file = io.open( system.pathForFile( "Content/Maps/" .. stage_id .. ".btdt", system.ResourceDirectory ), "r");
  map_data = stringBytes( file:read("*a") );
  io.close( file );

  Engine.max_speed = map_data[1];
  size = ((map_data[2] * 255 ) + map_data[3]);
  readed = 3; -- speed 1byte | size 2byte
  completed_blocks = 7;

  -- Очистка старой локации --
  cur_block = 0;

  -- обьекты
  while Objects.numChildren > 0 do
    Objects[1]:removeSelf();
  end;
end;

return Map;
