Fire = Class{}

function Fire:init(map, x, y, rotation, tank, state)
  --Set path for spritesheet for muzzle blasts
  self.texture = love.graphics.newImage('graphics/Effects/shotsFired.png')
  self.frames = generateQuads(self.texture, 48, 48)

  --Set tile size for muzzle blast animations
  self.height = 48
  self.width = 48

  self.map = map
  self.tank = tank

  self.x = x
  self.y = y

  self.rotation = rotation

  self.state = state

  --Set muzzle blast to correct tank, location, and direction
  if self.rotation == 0 or self.rotation == (2 * (math.pi)) then
    self.x = self.x
    self.y = self.y - ((self.height / 2) - 4)
  elseif self.rotation == math.pi then
    self.x = self.x
    self.y = self.y + ((self.height / 2) - 4)
  elseif self.rotation == (.5 * (math.pi)) then
    self.x = self.x + ((self.width / 2) - 4)
    self.y = self.y
  elseif self.rotation == (1.5 * (math.pi)) then
    self.x = self.x - ((self.width / 2) - 4)
    self.y = self.y
  end

  self.animations = {
    ['none'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[6]
      },
      interval = 1,
      --runOnce = false
    },
    ['fire'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4], self.frames [5]
      },
      interval = .10,
      --runOnce = true
    },
  }


  self.behaviors = {
    ['fire'] = function(dt)
      self.animation = self.animations['fire']
      if self.animation.currentFrame == 5 then
        self.animation.currentFrame = 5
        self.animaton = self.animations['none']
        self.state = 'stop'
      end
    end,
    ['none'] = function(dt)
      self.animation = self.animations['none']
    end,
    ['stop'] = function(dt)
      --Sanity to stop multiple muzzle blasts from existing at once
      if self.tank == 'tankOne' then
        self.map.activeOne = false
      elseif self.tank == 'tankTwo' then
        self.map.activeTwo = false
      end
      self.state = 'none'
    end
  }
end

function Fire:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
  if self.state == 'none' then
    self.animation.currentFrame = 1
  end

end



function Fire:render()
  love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), self.rotation, 1, 1, self.width / 2, self.height / 2)
end
