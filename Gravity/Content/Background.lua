-- наложение градиента
backGradient = display.newRect(
  display.contentCenterX,
  display.contentCenterY,
  display.actualContentWidth, display.actualContentHeight
);
local paint = {
    type = "gradient",
    color1 = { 17/255, 17/255, 17/255 },
    color2 = { 6/255, 52/255, 65/255 }
}
backGradient.fill = paint;

-- изменение оттенка градиента
local blueShade = 0;
local ks = math.random( 0, 10 );
local function setBlueShade()
  if blueShade > ks then
    blueShade = blueShade - 1;
    paint.color2[3] = (65 + blueShade) / 255;
    backGradient.fill = paint;

  elseif blueShade < ks then
    blueShade = blueShade + 1;
    paint.color2[3] = (65 + blueShade) / 255;
    backGradient.fill = paint;

  elseif blueShade == ks then
    ks = math.random( 0, 10 );
  end;
end;
timer.performWithDelay( 500, setBlueShade, -1 );
