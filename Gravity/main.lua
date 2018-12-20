----------------------------------- GRAVITY ------------------------------------
-- Creator: Виталий Махонин (Shichiro)
-- Created by Corona SDK
------------------------------------------------------------------- build v1.7.8

-- Скрыть полосу сверху
display.setStatusBar(display.HiddenStatusBar);

-- Глобальные
widget = require "widget";
PIX_IN_BLOCK = display.actualContentHeight / 15;
DISPLAY_HEIGHT = display.actualContentHeight + display.screenOriginY;
DISPLAY_WIDTH = display.actualContentWidth + display.screenOriginX;

-- transition options
standart_tro = { time = 300, transition = easing.outQuad }; --  ( Blackout, HUD, Player )
short_tro = { time = 300, transition = easing.outQuad }; -- ( Pause, Terrain, Stages menu, Menu )
long_tro = { time = 1000, transition = easing.outQuad }; -- ( Background, Menu.title )

-- Подключаем движок...
require "Engine";
