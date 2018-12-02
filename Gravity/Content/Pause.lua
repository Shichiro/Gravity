local Notify = display.newGroup();
Notify.alpha = 0;
local hiding_t, showing_t;

---- Обьекты ----
local title = display.newText({
  text = "PAUSE",
  font = "Content/Fonts/1",
  fontSize = 95
});
title.x = display.contentCenterX;
title.y = display.contentCenterY;
title:setFillColor( 0.9, 0.9, 0.9 );
Notify:insert( title );


---- Реализация ----
function Notify:show()
  transition.cancel( Notify );
  transition.fadeIn( Notify, short_tro );
  Notify:toFront();
end;

function Notify:hide()
  transition.cancel( Notify );
  transition.fadeOut( Notify, short_tro );
end;

return Notify;
