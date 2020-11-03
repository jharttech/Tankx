WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 640
VIRTUAL_HEIGHT = 360

Class = require 'class'
push = require 'push'

require 'utility'
require 'Map'
require 'Tank'
require 'Animation'
require 'Fire'
require 'Projectiles'
require 'Effects'
require 'PowerUp'



function love.load()

  math.randomseed(os.time())

  map = Map()

  --keep pixels, does not smooth pixels causing blur
  love.graphics.setDefaultFilter('nearest', 'nearest')

  love.window.setTitle('Tankx')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    --vsync = true
  })

  --Use canvas' to create blue background below info bar
  canvas = love.graphics.newCanvas(VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
  love.graphics.setCanvas(canvas)
    love.graphics.clear()
    love.graphics.setBlendMode("alpha")
    love.graphics.setColor(.30, .30, .30, 1)
    love.graphics.rectangle('fill', 0, 0, VIRTUAL_WIDTH, 36)
    love.graphics.setColor(108/255, 104/255, 1, 1)
    love.graphics.rectangle('fill', 0, 37, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
  love.graphics.setCanvas()

  love.keyboard.keysPressed = {}
  map:init()
end

--Create a was pressed function because lua does not have a native one
function love.keyboard.wasPressed(key)
  return love.keyboard.keysPressed[key]
end

--ability to resize screen
function love.resize(w, h)
  push:resize(w, h)
end

function love.update(dt)
  map:update(dt)

  love.keyboard.keysPressed = {}
end

--Exit game is escape is pressed
function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  end
  love.keyboard.keysPressed[key] = true
end

function love.draw()
  push:apply('start')

  love.graphics.draw(canvas)

  map:render()
  push:apply('end')
end
