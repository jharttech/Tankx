map = Map

-- create function to slice sprite sheets into quads based on
-- given tile height and widths
function generateQuads(atlas, tilewidth, tileheight)
  local sheetWidth = atlas:getWidth() / tilewidth
  local sheetHeight = atlas:getHeight() / tileheight

  local sheetCounter = 1
  local quads = {}

  --NOTE: must do some fancy footwork due to lua starting index at 1 and pixels at 0
  for y = 0, sheetHeight - 1 do
    for x = 0, sheetWidth - 1 do
      quads[sheetCounter] = love.graphics.newQuad(x * tilewidth, y * tileheight, tilewidth, tileheight, atlas:getDimensions())
      sheetCounter = sheetCounter + 1
    end
  end
  return quads
end
