---------- HUD для игры ----------

local HUD = display.newGroup();
HUD.alpha = 0;

-- Переменные
HUD.skore = 0;
local max_count = 0;
local playing = false;

-- Обьявление обьектов
local continue_btn;
local pause_btn;
local skore_label;
local skore_progress;
local skore_bar;


-- Локальные функции
local function continueOrPauseGame( event )
  if playing then
    Engine.pauseGame();
    pause_btn.isVisible = false;
    continue_btn.isVisible = true;
  else
    Engine.continueGame();
    pause_btn.isVisible = true;
    continue_btn.isVisible = false;
  end;
end;

local function minusOne()
  if playing then
    if HUD.skore > 0 then
      skore_label.alpha = (HUD.skore / max_count) + 0.4;
      skore_progress.alpha = (HUD.skore / max_count) + 0.1;

      HUD.skore = HUD.skore - 1;
      skore_label.text = tostring( HUD.skore );
      skore_progress.width = ( HUD.skore / max_count ) * skore_bar.width;
    else
      Engine.gameOver();
    end;
  end;
end;
timer.performWithDelay( 50, minusOne, -1 );


-- Обьекты
skore_label = display.newText({
  text = "0",
  font = "Content/Fonts/1.TTF",
  fontSize = 40
});
skore_label.x = display.contentCenterX;
skore_label.y = display.screenOriginY + 24;
skore_label:setFillColor( 0.9, 0.9, 0.9 );
HUD:insert( skore_label );

skore_bar = display.newRect( display.contentCenterX, display.screenOriginY + 2, (DISPLAY_WIDTH - ( display.actualContentWidth / 10 )) - (display.screenOriginX + ( display.actualContentWidth / 10 )), 4 );
skore_bar:setFillColor( 0.75, 0.85, 0.95, 0.3 );
HUD:insert( skore_bar );

skore_progress = display.newRect( display.contentCenterX, display.screenOriginY + 2, (DISPLAY_WIDTH - ( display.actualContentWidth / 10 )) - (display.screenOriginX + ( display.actualContentWidth / 10 )), 4 );
skore_progress:setFillColor( 0.9, 0.93, 0.96 );
HUD:insert( skore_progress );


pause_btn = widget.newButton({
  defaultFile = "Content/Textures/pause.png",
  width = 40, height = 34,
  onPress = continueOrPauseGame
});
pause_btn.x = DISPLAY_WIDTH - 35;
pause_btn.y = display.screenOriginY + 24;
pause_btn:setFillColor(  0.88, 0.88, 0.9 );
HUD:insert( pause_btn );

continue_btn = widget.newButton({
  defaultFile = "Content/Textures/play.png",
  width = 36, height = 36,
  onPress = continueOrPauseGame
});
continue_btn.x = DISPLAY_WIDTH - 35;
continue_btn.y = display.screenOriginY + 24;
continue_btn:setFillColor( 0.88, 0.88, 0.9 );
continue_btn.isVisible = false
HUD:insert( continue_btn );


-- Реализация
function HUD:hide()
  transition.fadeOut( HUD, standart_tro );
  playing = false;
end;

function HUD:pause()
  playing = false;
end;

function HUD:contune()
  playing = true;
end;

function HUD:addSkore( s )
  -- проверка на открытие
  if s then
    if not playing then
      HUD.skore = s;
      max_count = s;
      pause_btn.isVisible = true;
      continue_btn.isVisible = false;
      skore_label.text = tostring( HUD.skore );
      playing = true;
      transition.fadeIn( HUD, standart_tro );

    else
      -- добавление счета
      HUD.skore = HUD.skore + s;
      max_count = HUD.skore;
      skore_label.text = tostring( HUD.skore );
    end;
  end;
end;

return HUD;
