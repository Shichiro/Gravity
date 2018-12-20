---------- Класс для создания новых графиччческих обьектов в памяти ----------

local grabR = 0;
function dragBlock( event )
  if event.phase == "began" then
    display.getCurrentStage():setFocus( event.target );
    event.target.isFocus = true;
    grabX = (event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    grabY = (event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    cur_object = event.target;


  elseif event.phase == "moved" and event.target.isFocus then
    if can_scaling then
      event.target.width = event.target.width + (((( event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabX ) * PIX_IN_BLOCK );
      event.target.height = event.target.height + (((( event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabY ) * PIX_IN_BLOCK );

    else
      event.target.x = event.target.x + (((( event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabX ) * PIX_IN_BLOCK );
      event.target.y = event.target.y + (((( event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabY ) * PIX_IN_BLOCK );

    end;
    grabX = math.modf( event.x / PIX_IN_BLOCK );
    grabY = math.modf( event.y / PIX_IN_BLOCK );

  elseif event.phase == "ended" or event.phase == "cancelled" then
    display.getCurrentStage():setFocus( nil );
    event.target.isFocus = nil;
    cur_object = nil;
    saveToFile();

  end;
end;

function dragThorn( event )
  if event.phase == "began" then
    display.getCurrentStage():setFocus( event.target );
    event.target.isFocus = true;
    grabX = (event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    grabY = (event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    cur_object = event.target;

  elseif event.phase == "moved" and event.target.isFocus then
    event.target.x = event.target.x + (((( event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabX ) * PIX_IN_BLOCK );
    event.target.y = event.target.y + (((( event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabY ) * PIX_IN_BLOCK );

    grabX = math.modf( event.x / PIX_IN_BLOCK );
    grabY = math.modf( event.y / PIX_IN_BLOCK );

  elseif event.phase == "ended" or event.phase == "cancelled" then
    display.getCurrentStage():setFocus( nil );
    event.target.isFocus = nil;
    cur_object = nil;
    saveToFile();

  end;
end;

function dragASP( event )
  if event.phase == "began" then
    display.getCurrentStage():setFocus( event.target );
    event.target.isFocus = true;
    grabX = (event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    grabY = (event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK;
    cur_object = event.target;

  elseif event.phase == "moved" and event.target.isFocus then
    event.target.x = event.target.x + (((( event.x - (event.x % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabX ) * PIX_IN_BLOCK );
    event.target.y = event.target.y + (((( event.y - (event.y % PIX_IN_BLOCK)) / PIX_IN_BLOCK ) - grabY ) * PIX_IN_BLOCK );

    grabX = math.modf( event.x / PIX_IN_BLOCK );
    grabY = math.modf( event.y / PIX_IN_BLOCK );

  elseif event.phase == "ended" or event.phase == "cancelled" then
    display.getCurrentStage():setFocus( nil );
    event.target.isFocus = nil;
    cur_object = nil;
    saveToFile();

  end;
end;

local Creator = {};

-- создаст новый обьект платформы
function Creator.newBlock( params )
  -- Рисовка прямоугольника
  local block = display.newRect(
    params.x * PIX_IN_BLOCK,
    params.y * PIX_IN_BLOCK,
    params.width * PIX_IN_BLOCK,
    params.height * PIX_IN_BLOCK);

  block.type = 1;
  block.i = #Objects + 1;
  block:setFillColor( 90 / 255, 90 / 255, 101 / 255 );
  block.anchorX, block.anchorY = 0, 0;

  -- добавить обьект в фрейм
  Objects[#Objects + 1] = block;

  block:addEventListener( "touch", dragBlock );
end;

-- создаст новый обьект шипа
function Creator.newThorn( params )
  -- Настройка
  display.setDefault( "textureWrapX", "repeat" );
  display.setDefault( "textureWrapY", "repeat" );

  --  обьект
  local body = display.newRect(
  params.x * PIX_IN_BLOCK,
  params.y * PIX_IN_BLOCK,
  PIX_IN_BLOCK * params.width,
  PIX_IN_BLOCK * 0.4 );

  body.i = #Objects + 1;
  body.type = 2;
  body.fill = { type="image", filename="_Graphics/thorn.png" };
  body.fill.scaleX = PIX_IN_BLOCK / body.width;
  body.fill.scaleY = 1;
  body.anchorX, body.anchorY = 0, 1;
  body.rotation = params.rotation;
  body:setFillColor( 0.9, 0.2, 0.2, 0.9 );

  -- добавить обьект в фрейм
  Objects[#Objects + 1] = body;

  body:addEventListener( "touch", dragThorn );

  -- Настройка
  display.setDefault( "textureWrapX", "clampToEdge" );
  display.setDefault( "textureWrapY", "clampToEdge" );
end;

-- создаст новую точку получения очков
function Creator.newAddSkorePoint( params )
  -- создать обьект
  local body = display.newImage( "_Graphics/particles/particle 2.png" );
  body.width, body.height = 34, 34;
  body.x = (PIX_IN_BLOCK * 0.5) + ( params.x * PIX_IN_BLOCK );
  body.y = ( params.y * PIX_IN_BLOCK ) + (PIX_IN_BLOCK * 0.5);
  body.type = 3;
  body.add = params.add;
  body.i = #Objects + 1;
  body:setFillColor( 0, 1, 1 ); -- бирюзовый
  body:addEventListener( "touch", dragASP );

  -- добавить обьект в фрейм
  Objects[#Objects + 1] = body;
end;

return Creator;
