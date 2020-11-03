Effects = Class{}

function Effects:init(map, x, y, typeOfEffect, rotation, scale)
  --Set path to spritesheet for effects
  self.texture = love.graphics.newImage('graphics/Effects/effects.png')
  self.frames = generateQuads(self.texture, 32, 32)

  --Set pixel size of effects
  self.height = 32
  self.width = 32

  self.map = map
  self.tank = tank

  self.x = x
  self.y = y

  self.scaleX = scale
  self.scaleY = scale

  self.rotation = rotation

  self.typeOfEffect = typeOfEffect

  --Set initial state based on type of effect being needed
  if self.typeOfEffect == 'impact' then
    self.state = 'impact'
  elseif self.typeOfEffect == 'smoke' then
    self.state = 'smoke'
  elseif self.typeOfEffect == 'flame' then
    self.state = 'flame'
  elseif self.typeOfEffect == 'explode' then
    self.state = 'explode'
  else
    self.state = 'none'
  end

  self.animations = {
    ['none'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1]
      },
      interval = 1,
    },
    ['smoke'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[2], self.frames[3], self.frames[4], self.frames[1], self.frames[1], self.frames[3],
      },
      interval = .25,
    },
    ['impact'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5], self.frames[6], self.frames[7], self.frames[8], self.frames[1]
      },
      interval = .15,
    },
    ['flame'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[9], self.frames[10], self.frames[11], self.frames[10]
      },
      interval = .30
    },
    ['explode'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[12], self.frames[13], self.frames[14], self.frames[15], self.frames[16], self.frames[17], self.frames[18], self.frames[19]
      },
      interval = .15
    }
  }

  self.behaviors = {
    ['none'] = function(dt)
      self.animation = self.animations['none']
    end,
    ['flame'] = function(dt)
      self.animation = self.animations['flame']
    end,
    ['smoke'] = function(dt)
      self.animation = self.animations['smoke']
    end,
    ['explode'] = function(dt)
      self.animation = self.animations['explode']
      if self.animation.currentFrame == 8 then
        self.map.match = self.map.match + 1
        if self.map.playerOneMatchCount == 3 or self.map.playerTwoMatchCount == 3 then
          self.map.gameState = 'gameOver'
        else
          self.map.gameState = 'matchStart'
        end
      end
    end,
    ['impact'] = function(dt)
      self.animation = self.animations['impact']
      if self.animation.currentFrame == 5 then
        self.animation.currentFrame = 5
        self.map.tankTwoHit = false
        self.animation = self.animations['none']
        self.state = 'none'
      end
    end
  }
end

function Effects:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
end

function Effects:render()
  love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), self.rotation, self.scaleX, self.scaleY, self.width / 2, self.height / 2)
end
