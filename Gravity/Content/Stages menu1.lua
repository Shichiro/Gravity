---------- Меню выбра этапа ----------

local Stages_menu = {};

-- Загрузка сохраненных рекордов и создание постеров
Stages_menu.stages = {};

-- Переменные
local last_end_pos = 150;
local deltaX = 0;
local tpos = -1;
local pos = 0;

local function enercia()
  if deltaX > 2 then
    deltaX = deltaX - 2;

  elseif deltaX < -2 then
    deltaX = deltaX + 2;
  end;
end;
timer.performWithDelay( 10, enercia, -1 );

local function movstages()
  for i = 1, #Stages_menu.stages do
    Stages_menu.stages[i].x = Stages_menu.stages[i].x + deltaX;
  end;
end;
timer.performWithDelay( 50, movstages, -1 );

-- Лисенер по нажатию
local function movlis( event )
    if event.phase == "moved" then
      deltaX = (deltaX + ((pos + ( event.x - event.xStart )) - tpos)) / 2;
      print(deltaX)
      tpos = pos + ( event.x - event.xStart );

    elseif event.phase == "ended" or event.phase == "cancelled" then
      print(deltaX)
      pos = Stages_menu.stages[1].x;

    end;
end;

local function ptlis( event )
  if event.target.alpha == 1 then
    if event.target:isOpen() then
      Engine.startGame( event.target:getStageId() );
    end;
  end;
end;

-- cоздание нового постера
local function newPoster( info )
  local poster = display.newGroup();
  local title;
  local text;

  -- методы
  function poster:setInfo( inf )
    text.text = "- " .. inf .. " -";
    title:setFillColor( 0.9, 0.9, 0.9, 0.85 );
    text:setFillColor( 0.8, 0.8, 0.8, 0.85 );
  end;

  -- ( возвратит nil если этап не открыт )
  function poster:getInfo()
    local num, type = string.match( text.text, "(%d+)(.)" );
    if num and type then
        return tonumber( num ), type;
    end;
  end;

  function poster:getStageId()
    return tonumber( string.match( title.text, "(%d+)" ) );
  end;

  function poster:isOpen()
    -- если есть число в тексте, значит этот этап открыт
    if string.match( text.text, "(%d+)" ) then
      return true;
    else
      return false;
    end;
  end;

  -- фон
  local background = display.newImage( "Content/Textures/poster.png" );
  background.x = last_end_pos + 40;
  background.y = display.contentCenterY;
  last_end_pos = background.x + background.width;
  poster:insert( background );

  -- заголовок
  title = display.newText({
    parent = poster,
    text = "STAGE " .. #Stages_menu.stages + 1,
    font = "Content/Fonts/1.TTF",
    fontSize = 60
  });
  title.x = background.x;
  title.y = display.contentCenterY - 20;

  -- текст
  text = display.newText({
    parent = poster,
    text = "- NOT OPEN -",
    font = "Content/Fonts/1.TTF",
    fontSize = 30
  });
  text.x = background.x;
  text.y = display.contentCenterY + 30;

  -- записать информацию если предоставлена
  if info then
    poster:setInfo( info );
  else
    title:setFillColor( 0.6, 0.65, 0.7, 0.8 );
    text:setFillColor( 0.6, 0.65, 0.7, 0.8 );
  end;

  poster:addEventListener( "tap", ptlis );

  poster.alpha = 0;

  Stages_menu.stages[#Stages_menu.stages + 1] = poster;
end;

-- открыть фаил на чтение
local file = io.open( system.pathForFile( "OSR.txt", system.DocumentsDirectory ), "r" ); -- open stages records
if file then -- если фаил открылся
  -- создать 22 постера, и записать их рекорды из файла
  for i = 1, 22 do
    newPoster( file:read( "*l" ) );
  end;
  io.close( file );
  file = nil;
else
  -- попробуем создать новый фаил (если не получится, то вылетай пожалуйста)
  local file = io.open( system.pathForFile( "OSR.txt", system.DocumentsDirectory ), "w" );
  file:write( "0%" ); -- для 1ого этапа 0%
  io.close( file );
  file = nil;

  -- создать 22 постера
  newPoster( "0%" );
  for i = 2, 22 do
    newPoster();
  end;
end;

last_end_pos = nil;


-- Реализация
function Stages_menu:saveStageInfo( stage_num, info )
  -- изменить постер
  Stages_menu.stages[stage_num]:setInfo( info );

  -- сохраниить
  local file = io.open( system.pathForFile( "OSR.txt", system.DocumentsDirectory ), "w" );
  local info, type = Stages_menu.stages[1]:getInfo();
  file:write( info .. type );
  for i = 2, #Stages_menu.stages do
    info, type = Stages_menu.stages[i]:getInfo();
    if info and type then
      file:write( "\n" .. info .. type );
    end;
  end;
  io.close( file );
  file = nil;
end;

function Stages_menu:show()
  Runtime:addEventListener( "touch", movlis );

  -- эффект появления
  for i = 1, #Stages_menu.stages do
    transition.cancel( Stages_menu.stages[i] ); -- сброс других эффектов
    transition.fadeIn( Stages_menu.stages[i], { delay = 200, time = 500, transition = easing.outQuad } );
  end;
end;

function Stages_menu:hide()
  Runtime:removeEventListener( "touch", movlis );

  -- эффект скрытия
  for i = 1, #Stages_menu.stages do
    transition.cancel( Stages_menu.stages[i] ); -- сброс других эффектов
    transition.fadeOut( Stages_menu.stages[i], { time = 300, transition = easing.outQuad } );
  end;
end;

return Stages_menu;
