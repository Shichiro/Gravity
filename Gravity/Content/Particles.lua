-- частицы
local particles = display.newGroup();
local ychange = 1;

-- создание частицы в множестве
local function createParticle()
  local particle = display.newCircle(
    math.random( display.screenOriginX, DISPLAY_WIDTH ),
    math.random( display.screenOriginY, DISPLAY_HEIGHT ),
    2
  );
  particle:setFillColor( 0.7, 0.8, 0.9, 0.8 );
  particle.yForse = math.random( 8, 10 ) * 0.1;
  particles:insert( particle );
end;

-- движение частиц
local function particleMoving()
  -- обход всех  частиц
  for i = 1, particles.numChildren do
    -- проверка на выход за границы экрана
    if particles[i].x < display.screenOriginX then
      particles[i].x = math.random( DISPLAY_WIDTH, DISPLAY_WIDTH + 10 );
      particles[i].yForse = math.random( 8, 10 ) * 0.1;

    elseif particles[i].y < display.screenOriginY - 5 then
      particles[i].y = math.random( DISPLAY_HEIGHT, DISPLAY_HEIGHT );
      particles[i].yForse = math.random( 8, 10 ) * 0.1;

    else
      -- движение
      particles[i].x = particles[i].x - Engine.moving_speed * 0.9;
      particles[i].y = particles[i].y - particles[i].yForse * ychange;

    end;
  end;
end;
timer.performWithDelay( 10, particleMoving, -1 );

-- добавление частиц
math.randomseed( 9241 );
for i = 1, 22 do
  createParticle();
end;


-- Реализация
particles.alpha = 0;
function particles:show()
  transition.fadeIn( particles, { time = 2950, transition = easing.outQuad } );
end;

function particles:pause()
  ychange = 0;
end;

function particles:continue()
  ychange = 1;
end;

return particles;
