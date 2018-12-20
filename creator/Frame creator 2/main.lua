create = require "_Logic.Creator"
require "field"
require "_Logic.Serialization"

PIX_IN_BLOCK = display.contentHeight / 15;
DISPLAY_HEIGHT = display.actualContentHeight + display.screenOriginY;
DISPLAY_WIDTH = display.actualContentWidth + display.screenOriginX;

create_thorn = false;

--- Определяем шейдер для фона ---
-- ядро
local kernel = {};
kernel.language = "glsl";
kernel.category = "generator";
kernel.name = "Background";
kernel.isTimeDependent = true;

-- считываем из glsl файла код
local file = io.open( system.pathForFile( "_Shaders/Background.glsl", system.ResourceDirectory ), "r");
kernel.fragment = file:read("*a");

-- определяем эффект
graphics.defineEffect( kernel );

-- затираем память
io.close( file );
kernel = nil;
file = nil;

-- создаём фон
background = display.newRect(
  display.screenOriginX,
  display.screenOriginY,
  DISPLAY_WIDTH - display.screenOriginX,
  DISPLAY_HEIGHT - display.screenOriginY
);
background.anchorX, background.anchorY = 0, 0;
background.fill.effect = "generator.custom.Background";

--- Поле ввода ---
function lis2( event )
  if event.phase == "began" then
    if edited_object then
      if edited_object.type == 3 then
        event.target.text = tostring(edited_object.add);
      end;

    elseif is_set_speed then
      event.target.text = tostring( speed );

    end;
  end;
  if event.phase == "submitted" then
    if edited_object then
      if edited_object.type == 3 then
        edited_object.add = tonumber( event.target.text );
      else
        edited_object.add = tonumber( event.target.text );
      end;
      edited_object = nil;

    elseif is_set_speed then
      is_set_speed = false;
      speed = tonumber( event.target.text );

    elseif create_thorn == false then
      create.newAddSkorePoint( { x = 6, y = 4, add = tonumber( event.target.text ) } );

    else
      create.newThorn( { x = 7, y = 5, width = tonumber( event.target.text ), rotation = 0 } );
      create_thorn = false;
    end;
    event.target.isVisible = false;
    event.target.text = "";
  end;
end;

local function lis( event )
  if event.phase == "submitted" then
    field.show( event.target.text .. ".btdt" ); -- binary terrain data
    event.target.text = "";
    event.target:removeEventListener( "userInput", lis );
    event.target:addEventListener( "userInput", lis2 );
    event.target.isVisible = false;
  end;
end;

input = native.newTextField( display.contentCenterX, display.contentCenterY, 300, 30 );
input:addEventListener( "userInput", lis );
