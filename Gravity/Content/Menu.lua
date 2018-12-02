---------- Меню ----------

local Menu = {};

-- Обьекты --
local title = display.newText({
  text = "NO TITLE",
  font = "Content/Fonts/1",
  fontSize = 93
});
title.x = display.contentCenterX;
title:setFillColor( 0.9, 0.9, 0.9 );
title.alpha = 0;

local text = display.newText({
  text = "- 0% -",
  font = "Content/Fonts/1",
  fontSize = 40
});
text.x = display.contentCenterX;
text:setFillColor( 0.9, 0.9, 0.9, 0.8 );
text.alpha = 0;

local exit = display.newText({
  text = "EXIT STAGE",
  font = "Content/Fonts/1",
  fontSize = 55
});
exit.x = display.contentCenterX;
exit.y = display.contentCenterY + 135;
exit:setFillColor( 0.8, 0.8, 0.8 );
exit.alpha = 0;

local function exitTouchLis( event )
  if event.phase == "began" then
    Engine.openStagesMenu();
  end;
end;

local function restartTouchLis( event )
  if event.phase == "began" then
    Engine.restartGame();
  end;
end;


-- Реализация --
function Menu:show( title_text, little_text )
  transition.cancel( title );
  transition.cancel( text );
  transition.cancel( exit );

  -- обновление
  title.alpha = 0;
  text.alpha = 0;
  exit.alpha = 0;
  title.y = display.contentCenterY;
  text.y = display.contentCenterY + 70;

  exit:addEventListener( "touch", exitTouchLis );

  -- эффект появления
  transition.fadeIn( title, { time = 3000, transition = easing.outQuad } );
  transition.to( title, { delay = 1500, time = 1500, y = display.contentCenterY - 35, transition = easing.outQuad } );
  transition.to( text, { delay = 1700, time = 1500, y = display.contentCenterY + 35, alpha = 1, transition = easing.outQuad } );

  transition.fadeIn( exit, { delay = 1500, time = 850, transition = easing.inOutQuad } );

  -- текст
  title.text = title_text;
  text.text = little_text;
end;

function Menu:hide()
  if title.alpha > 0 and text.alpha > 0 then
    transition.cancel( title );
    transition.cancel( text );
    transition.cancel( exit );

    title.alpha = 1;
    text.alpha = 1;
    exit.alpha = 1;

    transition.fadeOut( title, short_tro );
    transition.fadeOut( text, short_tro );
    transition.fadeOut( exit, short_tro );
    exit:removeEventListener( "touch", exitTouchLis );
  end;
end;

return Menu;
