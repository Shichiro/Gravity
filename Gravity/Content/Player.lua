-- Инклуды
local Physics = require "physics";
local audio = require "audio";

-- Переменные
local lastYpos = 0;
local standartXpos = display.screenOriginX + (PIX_IN_BLOCK * 7);

-- Звуки
local explosionSound = audio.loadSound( "Content/Sound/exxxxplosion.wav" );

-- Обьекты
local Player = display.newGroup();
Player.alpha = 0;
Player.isPlayer = true;

local bodyRadius = PIX_IN_BLOCK * (20 / 36);
local tailmesh = display.newMesh(
  {
    x = 0, y = 0, mode = "fan",
    vertices = { 0, bodyRadius,   -bodyRadius, 0,   0, -bodyRadius };
  }
);
tailmesh:translate( tailmesh.path:getVertexOffset() );
tailmesh.fill = { type = "image", filename = "Content/Textures/tail.png" };
tailmesh:setFillColor( 1, 0.0, 0.1 );

local body = display.newImage( "Content/Textures/player body.png" );
body.width, body.height = bodyRadius * 2, bodyRadius * 2;
body:setFillColor( 0.9, 0.1, 0.2 );

Player:insert( tailmesh );
Player:insert( body );

-- Текст отображения добавленного счёта
local add_label = display.newText({
  text = "+ 0",
  font = "Content/Fonts/1.TTF",
  fontSize = 32
});
add_label.anchorX, add_label.anchorY = 0, 0;
add_label.x = 30;
add_label:setFillColor( 0.9, 0.9, 0.9 );
Player:insert( add_label );
add_label.alpha = 0;

function Player.showAdd( skore )
  transition.cancel( add_label ); -- прервать предидущее всплывание
  add_label.text = "+ " .. tostring( skore );
  add_label.y = -20;
  add_label.alpha = 0;

  -- анимация
  transition.to( add_label, { time = 200, y = -40, alpha = 1 } );
  transition.fadeOut( add_label, { delay = 400, time = 500 } );
end;

-- Лисенеры
local function setAntiGravity( event )
  if event.phase == "began" then
    Player.gravityScale = -Player.gravityScale;
  end;
end;

local Ax, Ay, AB;
local function checkPos()
  -- если вышел за рамки экрана, или существенно сместился по X, то
  if Player.x < display.screenOriginX or Player.y > DISPLAY_HEIGHT or Player.y < display.screenOriginY then
    Engine.gameOver();
  end;

  -- обновить геометрию хвоста
  Ax, Ay = - ( Engine.moving_speed * 10 ), -(( Player.y - lastYpos ) * 3.5 );
  AB = math.sqrt( math.pow( Ax, 2 ) + math.pow( Ay, 2 )); -- длинна от т A до центра тела
  tailmesh.path:setVertex( 2, Ax, Ay ); -- т A
  tailmesh.path:setVertex( 1, (( bodyRadius * Ay ) / AB ), ( ( bodyRadius * (-Ax) ) / AB ) ); -- m C
  tailmesh.path:setVertex( 3, - (( bodyRadius * Ay ) / AB ), - ( ( bodyRadius * (-Ax) ) / AB ) ); -- т -С

  -- стабилизация резкости ускорения по оси Y
  lastYpos = lastYpos + (( Player.y - lastYpos ) * 0.4);
end;


--- Реализация ---
function Player:pause()
  -- снимаем лисенеры
  Runtime:removeEventListener( "enterFrame", checkPos );
  Runtime:removeEventListener( "touch", setAntiGravity );
end;

function Player:continue()
  -- добовляем лисенеры
  Runtime:addEventListener( "enterFrame", checkPos );
  Runtime:addEventListener( "touch", setAntiGravity );
end;

function Player:exxxplosion() -- Мегумин одобряет(
  -- скрыть уваедомление если есть
  transition.cancel( add_label );
  add_label.alpha = 0;

  -- снимаем лисенеры
  Runtime:removeEventListener( "enterFrame", checkPos );
  Runtime:removeEventListener( "touch", setAntiGravity );

  -- эффект взрыва
  local function explode()
    -- удаляем игрока из физической симуляции и скрываем
    Physics.removeBody( Player );
    Player.alpha = 0;

    -- создание физических частиц
    local exxxplosion = display.newGroup();
    local pcount = 15;
    local radius = 300;
    local m = 360 / pcount;
    for i = m, 360, m do
      local particle = display.newCircle( Player.x + math.sin(i) * 2, Player.y + math.cos(i) * 2, 3.7 );
      particle:setFillColor( 0.9, 0.1, 0.2 );
      Physics.addBody( particle, "dynamic", { friction = 0.1, bounce = 0.1 });
      particle.gravityScale = 1;
      particle:setLinearVelocity( math.sin(i) * radius, math.cos(i) * radius );
      exxxplosion:insert( particle );
    end;

    pcount = 10;
    radius = 200;
    m = 360 / pcount;
    for i = m, 360, m do
      local particle = display.newCircle( Player.x + math.sin(i) * 1.5, Player.y + math.cos(i) * 1.5, 3.7 );
      particle:setFillColor( 0.9, 0.1, 0.2 );
      Physics.addBody( particle, "dynamic", { friction = 0.1, bounce = 0.1 });
      particle.gravityScale = 1;
      particle:setLinearVelocity( math.sin(i) * radius, math.cos(i) * radius );
      exxxplosion:insert( particle );
    end;

    -- звук взрыва
    audio.play( explosionSound );

    -- скрытие и удаление частиц после их появления
    transition.fadeOut( exxxplosion, { delay = 500, time = 300, onComplete = function() exxxplosion:removeSelf() end } );
  end;
  -- активация эффекта взрыва (из-за колизион эвент'а у шипов нам прийдётся ждать)
  timer.performWithDelay( 10, explode );
end;

function Player:show()
  -- обновление
  Physics.addBody( Player, "dynamic", { radius = bodyRadius, friction = 0.1, bounce = 0.05 } );
  Player.isSleepingAllowed = false;
  Player.isFixedRotation = true;
  Player.isBodyActive = true;
  Player.gravityScale = 16;
  Player.x, Player.y = standartXpos, DISPLAY_HEIGHT - PIX_IN_BLOCK - bodyRadius;
  Player.isAwake = true;
  lastYpos = Player.y;

  -- появление
  Player.alpha = 0;
  tailmesh.alpha = 0;
  transition.fadeIn( tailmesh,{ time = 100, transition = easing.outQuad } );
  transition.fadeIn( Player, { time = 350, transition = easing.outQuad } );

  -- добовляем лисенеры
  Runtime:addEventListener( "enterFrame", checkPos );
  Runtime:addEventListener( "touch", setAntiGravity );
end;

function Player:hide()
  -- скрыть уваедомление если есть
  transition.cancel( add_label );
  add_label.alpha = 0;

  -- скрытие
  transition.fadeOut( tailmesh, { time = 100, transition = easing.outQuad } );
  transition.fadeOut( Player, standart_tro );

  -- снимаем лисенеры
  Runtime:removeEventListener( "enterFrame", checkPos );
  Runtime:removeEventListener( "touch", setAntiGravity );

  -- заморозить
  Player.isAwake = false;
end;

return Player;
