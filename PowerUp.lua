PowerUp = Class{}


function PowerUp:init(map, x, y, shellType, scale)
  --Set path to icons spritesheet
  self.texture = love.graphics.newImage('graphics/icons.png')
  self.frames = generateQuads(self.texture, 48, 48)

  --Set PowerUp icon sizes
  self.height = 48
  self.width = 48

  self.map = map

  self.x = x
  self.y = y
  self.scaleX = scale
  self.scaleY = scale

  self.shellType = shellType

  --Set powerup animation
  if self.shellType == 2 then
    self.state = 'mediumShell'
  elseif self.shellType == 3 then
    self.state = 'sniperShell'
  end

  self.animations = {
    ['none'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[9]
      },
      interval = 1
    },
    ['mediumShell'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2], self.frames[3], self.frames[4], self.frames[3], self.frames[2]
      },
      interval = .15
    },
    ['sniperShell'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5], self.frames[6], self.frames[7], self.frames[8], self.frames[7], self.frames[6]
      },
      interval = .15
    }
  }

  self.behaviors = {
    ['none'] = function(dt)
      self.animation = self.animations['none']
    end,
    ['mediumShell'] = function(dt)
      self.animation = self.animations['mediumShell']
    end,
    ['sniperShell'] = function(dt)
      self.animation = self.animations['sniperShell']
    end
  }
end

function PowerUp:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
end

function PowerUp:render()
    love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), 0, self.scaleX, self.scaleY, self.width / 2, self.height / 2)
end
