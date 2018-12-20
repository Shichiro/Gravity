---------- Глобальный класс для управления всеми элементами игры ----------
-- тип системы

Engine = {};

-- Аудио
local audio = require "audio";
local addskoreSound = audio.loadSound( "Content/Sound/addskore.wav" );
local buttonpressSound = audio.loadSound( "Content/Sound/buttonpress.wav" );

-- Геймплей
local Physics = require "physics";
require "Content.Background";
local Particles = require "Content.Particles";
local Map = require "Content.Map";
local Player = require "Content.Player";

-- UI
local Pause = require "Content.Pause";
local Stages_menu = require "Content.Stages menu";
local Menu = require "Content.Menu";
local GameHUD = require "Content.Game HUD";




-- Переменные
local plaing = false;
local cur_stage = 1;
local mov_t;
local save_speed = 0;
local inResultsMenu = false;
Engine.max_speed = 1;
Engine.moving_speed = 0;


local function plsSpeed()
  if Engine.moving_speed < Engine.max_speed then
    Engine.moving_speed = Engine.moving_speed + 0.35;
  elseif mov_t then
    Engine.moving_speed = Engine.max_speed;
    timer.cancel( mov_t );
    mov_t = nil;
  end;
end;

local function minusSpeed()
  if Engine.moving_speed > 0 then
    Engine.moving_speed = Engine.moving_speed - 2;
  elseif mov_t then
    Engine.moving_speed = 0;
    timer.cancel( mov_t );
    mov_t = nil;
  end;
end;

local function startMovement()
  -- если есть сторонний таймер то остановить его
  if mov_t then
    timer.cancel( mov_t );
    mov_t = nil;
  end;
  -- увеличение скорости
  mov_t = timer.performWithDelay( 30, plsSpeed, -1 );
end;

local function stopMovement()
  -- если есть сторонний таймер то остановить его
  if mov_t then
    timer.cancel( mov_t );
    mov_t = nil;
  end;
  -- уменьшение скорости
  mov_t = timer.performWithDelay( 20, minusSpeed, -1 );
end;


-- Реализация ---
function Engine.startGame( stage_id )
  if not plaing then
    Map:setResourse( stage_id );

    audio.play( buttonpressSound );

    -- переход
    Menu:hide();
    Stages_menu:hide();

    Physics.start();

    startMovement();

    Player:show();
    Map:show();
    Particles:continue();

    cur_stage = stage_id;

    plaing = true;
  end;
end;

function Engine.pauseGame()
  if plaing then
    Particles:pause()
    Pause:show();
    Physics.pause();
    Player:pause();
    GameHUD:pause();
    audio.play( buttonpressSound );

    -- грубая остановка дыиженияЫ
    if mov_t then
      timer.cancel( mov_t );
      mov_t = nil;
    end;
    save_speed = Engine.moving_speed;
    Engine.moving_speed = 0;
  end;
end;

function Engine.continueGame()
  if plaing then
    Particles:continue()
    Pause:hide();
    Physics.start();
    Player:continue();
    GameHUD:contune();
    audio.play( buttonpressSound );

    -- запуск движения
    if save_speed < Engine.max_speed then
      Engine.moving_speed = save_speed;
      startMovement();
    else
      Engine.moving_speed = Engine.max_speed;
    end;
    save_speed = 0;
  end;
end;

local function openResultsMenu()
  if not inResultsMenu then
    inResultsMenu = true;
    Map.hide();
    GameHUD:hide();
    Physics.pause();

    local persents = Map:getPersents();
    local record, rtype = Stages_menu.stages[cur_stage]:getInfo();

    -- выход в меню с проверкой побитого рекорда
    if GameHUD.skore > 0 then
      -- определение заголовка и текста меню
      if rtype == "%" then
        Menu:show( "STAGE PASSED", "- " .. tostring( GameHUD.skore ) .. "x -" );
        Stages_menu:saveStageInfo( cur_stage, tostring( GameHUD.skore ) .. "x" );
        Stages_menu:saveStageInfo( cur_stage + 1, "0%" );

      elseif rtype == "x" then
        if GameHUD.skore > record then
          Menu:show( "NEW RECORD!", "- " .. tostring( GameHUD.skore ) .. "x -" );
          Stages_menu:saveStageInfo( cur_stage, tostring( GameHUD.skore ) .. "x" );
        else
          Menu:show( "STAGE PASSED", "- " .. tostring( GameHUD.skore ) .. "x -" );
        end;
      end;
    else
      -- определение заголовка и текста меню
      if rtype == "%" then
        if persents > record then
          Menu:show( "NEW RECORD!", "- " .. tostring( persents ) .. "% -" );
          Stages_menu:saveStageInfo( cur_stage, tostring( persents ) .. "%" );

        else
          Menu:show( "GAME OVER", "- " .. tostring( persents ) .. "% -" );
        end;

      elseif rtype == "x" then
        Menu:show( "GAME OVER", "- " .. tostring( persents ) .. "% -" );
      end;
    end;
  end
end;

function Engine.gameOver()
  if plaing then
    GameHUD.skore = 0;
    Pause:hide();
    GameHUD:pause();
    Player:exxxplosion();
    Particles:continue();

    stopMovement();

    plaing = false;

    timer.performWithDelay( 800, openResultsMenu );
  end;
end;

function Engine.stagePassed()
  if plaing then
    Pause:hide();
    Player:hide();
    Particles:continue();
    GameHUD:pause();

    stopMovement();

    plaing = false;

    timer.performWithDelay( 800, openResultsMenu );
  end;
end;

function Engine.openStagesMenu()
  if inResultsMenu then
    inResultsMenu = false;

    Menu:hide();
    Map.hide();

    audio.play( buttonpressSound );

    Stages_menu:show();
  end;
end;

function Engine.addSkore( add )
  if plaing then
    GameHUD:addSkore( add );
  	Player.showAdd( add );

    audio.play( addskoreSound );
  end;
end;

local function helloGame()
  -- Обьекты
  local title = display.newText({
    text = "GRAVITY FORCE",
    font = "Content/Fonts/1.TTF",
    fontSize = 93
  });
  title.x = display.contentCenterX;
  title.y = display.contentCenterY;
  title:setFillColor( 0.9, 0.9, 0.9 );
  title.alpha = 0;

  Particles:show();

  -- анимация
  transition.fadeIn( title, { time = 1500, transition = easing.inOutQuad } );

  transition.to( title, { delay = 1600, time = 700, alpha = 0, y = display.contentCenterY - 35, transition = easing.inOutQuad,
  onComplete = function() Stages_menu:show() end } );
end;

helloGame();
