Projectiles = Class{}

INBOUND = 300

function Projectiles:init(map, x, y, rotation, tank, currentFiring)
  --Set spritesheet path
  self.texture = love.graphics.newImage('graphics/Projectiles/projectiles.png')
  self.frames = generateQuads(self.texture, 32, 32)
  self.height = 32
  self.width = 32

  self.map = map
  self.tank = tank

  self.x = x
  self.y = y
  self.dx = 0
  self.dy = 0

  --Set sanity check variables
  self.hit = false
  self.currentFiring = false

  self.sounds = {
    ['defaultShot'] = love.audio.newSource('sounds/tanks/DefaultShot.wav', 'static'),
    ['mediumShot'] = love.audio.newSource('sounds/tanks/MediumShot.wav', 'static'),
    ['sniperShot'] = love.audio.newSource('sounds/tanks/SniperShot.wav', 'static')
  }

  self.state = 'none'

  self.animations = {
    ['none'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[2]
      },
      interval = 1,
    },
    ['ordinance'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1]
      },
      interval = 1,
    },
    ['mediumShell'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[2]
      },
      interval = 1
    },
    ['sniperShell'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[3]
      },
      interval = 1
    }
  }

  self.behaviors = {
    ['ordinance'] = function(dt)
      self.animation = self.animations['ordinance']
    end,
    ['mediumShell'] = function(dt)
      self.animation = self.animations['mediumShell']
    end,
    ['sniperShell'] = function(dt)
      self.animation = self.animations['sniperShell']
    end,
    ['none'] = function(dt)
      self.animation = self.animations['none']
    end
  }
end

function Projectiles:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
  --Check for fire key being pressed, if pressed then set bullet animation, direction, and speed.
  if self.tank == 'tankOne' then
    if love.keyboard.wasPressed('space') and self.currentFiring == false then
      self.currentFiring = true
      --Set sound effect of fire depending on bullet type
      if self.bullet == 2 then
        self.sounds['mediumShot']:play()
      elseif self.bullet == 3 then
        self.sounds['sniperShot']:play()
      else
        self.sounds['defaultShot']:play()
      end
      self.rotation = self.map.tankOne.rotation
      if self.rotation == 0 or self.rotation == (2 * (math.pi)) then
        self.x = self.x + 8
        self.y = self.y - ((self.height / 2) - 4)
        if self.bullet == 2 then
          self.dy = -(INBOUND - 15)
        elseif self.bullet == 3 then
          self.dy = -(INBOUND + 100)
        else
          self.dy = -INBOUND
        end
      elseif self.rotation == math.pi then
        self.x = self.x + 8
        self.y = self.y + ((self.height / 2) - 4)
        if self.bullet == 2 then
          self.dy = (INBOUND - 15)
        elseif self.bullet == 3 then
          self.dy = (INBOUND + 100)
        else
          self.dy = INBOUND
        end
      elseif self.rotation == (.5 * (math.pi)) then
        self.x = self.x + ((self.width / 2) - 4)
        self.y = self.y + 8
        if self.bullet == 2 then
          self.dx = (INBOUND - 15)
        elseif self.bullet == 3 then
          self.dx = (INBOUND + 100)
        else
          self.dx = INBOUND
        end
      elseif self.rotation == (1.5 * (math.pi)) then
        self.x = self.x + ((self.width / 2) - 4)
        self.y = self.y + 8
        if self.bullet == 2 then
          self.dx = -(INBOUND - 15)
        elseif self.bullet == 3 then
          self.dx = -(INBOUND + 100)
        else
          self.dx = -INBOUND
        end
      end
      if self.bullet == 2 then
        self.state = 'mediumShell'
      elseif self.bullet == 3 then
        self.state = 'sniperShell'
      else
        self.state = 'ordinance'
      end
    end
  end
  if self.tank == 'tankTwo' then
    if (love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return')) and self.currentFiring == false then
      self.currentFiring = true
      --Set sound effect of fire depending on bullet type
      if self.bullet == 2 then
        self.sounds['mediumShot']:play()
      elseif self.bullet == 3 then
        self.sounds['sniperShot']:play()
      else
        self.sounds['defaultShot']:play()
      end
      self.rotation = self.map.tankTwo.rotation
      if self.rotation == 0 or self.rotation == (2 * (math.pi)) then
        self.x = self.x + 8
        self.y = self.y - ((self.height / 2) - 4)
        if self.bullet == 2 then
          self.dy = -(INBOUND - 15)
        elseif self.bullet == 3 then
          self.dy = -(INBOUND + 100)
        else
          self.dy = -INBOUND
        end
      elseif self.rotation == math.pi then
        self.x = self.x + 8
        self.y = self.y + ((self.height / 2) - 4)
        if self.bullet == 2 then
          self.dy = (INBOUND - 15)
        elseif self.bullet == 3 then
          self.dy = (INBOUND + 100)
        else
          self.dy = INBOUND
        end
      elseif self.rotation == (.5 * (math.pi)) then
        self.x = self.x + ((self.width / 2) - 4)
        self.y = self.y + 8
        if self.bullet == 2 then
          self.dx = (INBOUND - 15)
        elseif self.bullet == 3 then
          self.dx = (INBOUND + 100)
        else
          self.dx = INBOUND
        end
      elseif self.rotation == (1.5 * (math.pi)) then
        self.x = self.x + ((self.width / 2) - 4)
        self.y = self.y + 8
        if self.bullet == 2 then
          self.dx = -(INBOUND - 15)
        elseif self.bullet == 3 then
          self.dx = -(INBOUND + 100)
        else
          self.dx = -INBOUND
        end
      end
      if self.bullet == 2 then
        self.state = 'mediumShell'
      elseif self.bullet == 3 then
        self.state = 'sniperShell'
      else
        self.state = 'ordinance'
      end
    end
  end

  --Start movement of bullet
  self.x = self.x + self.dx * dt
  self.y = self.y + self.dy * dt
end

--Reset bullet
function Projectiles:reset(x, y, tank)
  self.dx = 0
  self.dy = 0
  self.state = 'none'
  if tank == 'tankOne' then
    self.map.shotOne = false
  elseif tank == 'tankTwo' then
    self.map.shotTwo = false
  end
  self.x = x
  self.y = y
end



function Projectiles:render()
  local scaleX = .33
  local scaleY = .33

  --Change scale for drawing bullet based on what bullet to be drawn
  if self.state == 'mediumShell' then
    scaleX = .50
    scaleY = .50
  elseif self.state == 'sniperShell' then
    scaleX = .50
    scaleY = .75
  end

  love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), self.rotation, scaleX, scaleY, self.width / 2, self.height / 2)
end
