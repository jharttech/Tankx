Tank = Class{}

MOVE_VERTICAL = 60
MOVE_HORIZ = 60
function Tank:init(map, x, y, tankColor, direction, player)
  --Set size of tank sprites
  self.width = 48
  self.height = 48

  self.map = map

  --Set starting positions
  self.x = x
  self.y = y

  self.player = player

  self.dx = 0
  self.dy = 0

  --Set rotation in terms of pi
  self.origin = 0
  self.upZero = 0
  self.upThreeSixty = (2 * (math.pi))
  self.downOneEighty = math.pi
  self.horizNinty = (.5 * (math.pi))
  self.horizTwoSeventy = (1.5 * (math.pi))
  --Set starting direction of each player
  if self.player == 'playerOne' then
    self.rotation = self.horizNinty
  elseif self.player == 'playerTwo' then
    self.rotation = self.horizTwoSeventy
  end
  --Set the amount to change rotation by during a rotation
  self.degreesChange = .06
  self.rotationFinish = 'false'

  --Set initial hit count to 3
  self.hitCount = 3

  self.powerUpActive = nil

  --Set path to tank spritesheet depending on color of tank (will be used more when ability to choose tank style is added)
  if tankColor == 'brown' then
    self.path = 'graphics/Tanks/Brown/BrownTank.png'
  elseif tankColor == 'blue' then
    self.path = 'graphics/Tanks/Blue/BlueTank.png'
  end

  --Set path to each spritesheet
  self.texture = love.graphics.newImage(self.path)
  self.frames = generateQuads(self.texture, 48, 48)

  self.state = 'idleDefault'
  self.direction = direction

  --Set trackmarks (may be moved or removed depending on use when track marks are added)
  --self.tireTracksX = nil
  --self.tireTracksY = nil

  --Sanity check on if tank is firing or not
  self.fire = false

  --Set default
  self.whichPowerUp = 1

  self.sounds = {
    ['motor'] = love.audio.newSource('sounds/tanks/Motor.wav', 'static'),
    ['upgrade'] = love.audio.newSource('sounds/tanks/Upgrade.wav', 'static')
  }

  self.animations = {
    ['idleDefault'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1]
      },
      interval = 1
    },
    ['idleMedium'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[3]
      },
      interval = 1
    },
    ['idleSniper'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5]
      },
      interval = 1
    },
    ['idleDouble'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[7]
      },
      interval = 1
    },
    ['moveDefault'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[1], self.frames[2]
      },
      interval = .15
    },
    ['moveMedium'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[3], self.frames[4]
      },
      interval = .15
    },
    ['moveSniper'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[5], self.frames[6]
      },
      interval = .15
    },
    ['moveDouble'] = Animation {
      texture = self.texture,
      frames = {
        self.frames[7], self.frames[8]
      },
      interval = .15
    }
  }

  self.animation = self.animations['idleDefault']

  self.behaviors = {
    ['idleDefault'] = function(dt)
      self.dy = 0
      self.dx = 0
      --Set idle animation needed depending on powerups
      if self.whichPowerUp == 1 then
        self.animation = self.animations['idleDefault']
      elseif self.whichPowerUp == 2 then
        self.animation = self.animations['idleMedium']
      elseif self.whichPowerUp == 3 then
        self.animation = self.animations['idleSniper']
      end
      --Player One tank controls
      if self.player == 'playerOne' then
        if love.keyboard.isDown('d') then
          if self.direction == 'up' then
            self.rotation = self.upZero
            self.state = 'rotateRight'
          elseif self.direction == 'down' then
            self.state = 'rotateLeft'
          else
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('a') then
          if self.direction == 'up' then
            self.rotation = self.upThreeSixty
            self.state = 'rotateLeft'
          elseif self.direction == 'down' then
            self.state = 'rotateRight'
          elseif self.direction == 'right' or self.direction == 'left' then
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('w') then
          if self.direction == 'right' then
            self.state = 'rotateLeft'
          elseif self.direction == 'left' then
            self.state = 'rotateRight'
          else
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('s') then
          if self.direction == 'right' then
            self.state = 'rotateRight'
          elseif self.direction == 'left' then
            self.state = 'rotateLeft'
          else
            self.state = 'moveDefault'
          end
        end
      --Player Two tank controls
      elseif self.player == 'playerTwo' then
        if love.keyboard.isDown('right') then
          if self.direction == 'up' then
            self.rotation = self.upZero
            self.state = 'rotateRight'
          elseif self.direction == 'down' then
            self.state = 'rotateLeft'
          else
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('left') then
          if self.direction == 'up' then
            self.rotation = self.upThreeSixty
            self.state = 'rotateLeft'
          elseif self.direction == 'down' then
            self.state = 'rotateRight'
          else
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('up') then
          if self.direction == 'right' then
            self.state = 'rotateLeft'
          elseif self.direction == 'left' then
            self.state = 'rotateRight'
          else
            self.state = 'moveDefault'
          end
        end
        if love.keyboard.isDown('down') then
          if self.direction == 'right' then
            self.state = 'rotateRight'
          elseif self.direction == 'left' then
            self.state = 'rotateLeft'
          else
            self.state = 'moveDefault'
          end
        end
      end
    end,
    ['rotateRight'] = function(dt)
      self.dy = 0
      self.dx = 0
      self.sounds['motor']:play()
      if(self:rotateRight()) then
        if self.direction == 'up' then
          self.direction = 'right'
        elseif self.direction == 'right' then
          self.direction = 'down'
        elseif self.direction == 'down' then
          self.direction = 'left'
        elseif self.direction == 'left' then
          self.direction = 'up'
        end
        self.state = 'idleDefault'
      end
    end,
    ['rotateLeft'] = function(dt)
      self.dy = 0
      self.dx = 0
      self.sounds['motor']:play()
      if(self:rotateLeft()) then
        if self.direction == 'up' then
          self.direction = 'left'
        elseif self.direction == 'left' then
          self.direction = 'down'
        elseif self.direction == 'down' then
          self.direction = 'right'
        elseif self.direction == 'right' then
          self.direction = 'up'
        end
        self.state = 'idleDefault'
      end
    end,
    ['moveDefault'] = function(dt)
      if self.player == 'playerOne' then
        --Set animations and movement speed of player one tank depending on type of weapon equipped
        self.sounds['motor']:play()
        if love.keyboard.isDown('d') then
          if love.keyboard.wasPressed('space') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dy = 0
          if self.whichPowerUp == 1 then
            self.dx = MOVE_HORIZ
          elseif self.whichPowerUp == 2 then
            self.dx = MOVE_HORIZ - 20
          elseif self.whichPowerUp == 3 then
            self.dx = MOVE_HORIZ - 10
          end
          self:checkCollisionRight()
          self:checkPowerUpCollisionRight()
        elseif love.keyboard.isDown('a') then
          if love.keyboard.wasPressed('space') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dy = 0
          if self.whichPowerUp == 1 then
            self.dx = -MOVE_HORIZ
          elseif self.whichPowerUp == 2 then
            self.dx = -MOVE_HORIZ + 20
          elseif self.whichPowerUp == 3 then
            self.dx = -MOVE_HORIZ + 10
          end
          self:checkCollisionLeft()
          self:checkPowerUpCollisionLeft()
        elseif love.keyboard.isDown('w') then
          if love.keyboard.wasPressed('space') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dx = 0
          if self.whichPowerUp == 1 then
            self.dy = -MOVE_VERTICAL
          elseif self.whichPowerUp == 2 then
            self.dy = -MOVE_VERTICAL + 30
          elseif self.whichPowerUp == 3 then
            self.dy = -MOVE_VERTICAL + 10
          end
          self:checkCollisionUp()
          self:checkPowerUpCollisionUp()
        elseif love.keyboard.isDown('s') then
          if love.keyboard.wasPressed('space') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dx = 0
          if self.whichPowerUp == 1 then
            self.dy = MOVE_VERTICAL
          elseif self.whichPowerUp == 2 then
            self.dy = MOVE_VERTICAL - 30
          elseif self.whichPowerUp == 3 then
            self.dy = MOVE_VERTICAL - 10
          end
          self:checkCollisionDown()
          self:checkPowerUpCollisionDown()
        else
          self.dy = 0
          self.dx = 0
          self.state = 'idleDefault'
        end
      end
      --Set animations and movement speed of player two tank depending on type of weapon equipped
      if self.player == 'playerTwo' then
        self.sounds['motor']:play()
        if love.keyboard.isDown('right') then
          if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dy = 0
          if self.whichPowerUp == 1 then
            self.dx = MOVE_HORIZ
          elseif self.whichPowerUp == 2 then
            self.dx = MOVE_HORIZ - 20
          elseif self.whichPowerUp == 3 then
            self.dx = MOVE_HORIZ - 10
          end
          self:checkCollisionRight()
          self:checkPowerUpCollisionRight()
        elseif love.keyboard.isDown('left') then
          if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dy = 0
          if self.whichPowerUp == 1 then
            self.dx = -MOVE_HORIZ
          elseif self.whichPowerUp == 2 then
            self.dx = -MOVE_HORIZ + 20
          elseif self.whichPowerUp == 3 then
            self.dx = -MOVE_HORIZ + 10
          end
          self:checkCollisionLeft()
          self:checkPowerUpCollisionLeft()
        elseif love.keyboard.isDown('up') then
          if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dx = 0
          if self.whichPowerUp == 1 then
            self.dy = -MOVE_VERTICAL
          elseif self.whichPowerUp == 2 then
            self.dy = -MOVE_VERTICAL + 30
          elseif self.whichPowerUp == 3 then
            self.dy = -MOVE_VERTICAL + 10
          end
          self:checkCollisionUp()
          self:checkPowerUpCollisionUp()
        elseif love.keyboard.isDown('down') then
          if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
            self.fire = true
          end
          if self.whichPowerUp == 1 then
            self.animation = self.animations['moveDefault']
          elseif self.whichPowerUp == 2 then
            self.animation = self.animations['moveMedium']
          elseif self.whichPowerUp == 3 then
            self.animation = self.animations['moveSniper']
          end
          self.dx = 0
          if self.whichPowerUp == 1 then
            self.dy = MOVE_VERTICAL
          elseif self.whichPowerUp == 2 then
            self.dy = MOVE_VERTICAL - 30
          elseif self.whichPowerUp == 3 then
            self.dy = MOVE_VERTICAL - 10
          end
          self:checkCollisionDown()
          self:checkPowerUpCollisionDown()
        else
          self.dy = 0
          self.dx = 0
          self.state = 'idleDefault'
        end
      end
    end,
  }
end

function Tank:update(dt)
  self.behaviors[self.state](dt)
  self.animation:update(dt)
  --Do not allow movement on opposite axis
  if self.direction == 'left' or self.direction == 'right' then
    self.dy = 0
    self.x = self.x + self.dx * dt
  elseif self.direction == 'up' or self.direction == 'down' then
    self.dx = 0
    self.y = self.y + self.dy * dt
  end

  if love.keyboard.wasPressed('space') then
    self.fire = true
  end

  --Set play boundary
  if self.dy < 0 then
    self.y = math.max(16, self.y + self.dy * dt)
  elseif self.dy > 0 then
    self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
  end
  if self.dx < 0 then
    self.x = math.max(0, self.x + self.dx * dt)
  elseif self.dx > 0 then
    self.x = math.min(VIRTUAL_WIDTH - self.width, self.x + self.dx * dt)
  end
end

--Function to handle all rotation calculations when rotating right
function Tank:rotateRight()
  self.dy = 0
  self.dx = 0
  if self.direction == 'right' then
    if self.rotation < self.downOneEighty then
      self.rotation = self.rotation + self.degreesChange
      return false
    end
    self.rotation = self.downOneEighty
  elseif self.direction == 'left' then
    if self.rotation < self.upThreeSixty then
      self.rotation = self.rotation + self.degreesChange
      return false
    end
    self.rotation = self.upZero
  elseif self.direction == 'up' then
    if self.rotation < self.horizNinty then
      self.rotation = self.rotation + self.degreesChange
      return false
    end
    self.rotation = self.horizNinty
  elseif self.direction == 'down' then
    if self.rotation < self.horizTwoSeventy then
      self.rotation = self.rotation + self.degreesChange
      return false
    end
    self.rotation = self.horizTwoSeventy
  end
  return true
end

--Function to handle all rotation calculations when rotating left
function Tank:rotateLeft()
  self.dy = 0
  self.dx = 0
  if self.direction == 'right' then
    if self.rotation > self.upZero then
      self.rotation = self.rotation - self.degreesChange
      return false
    end
    self.rotation = self.upThreeSixty
  elseif self.direction == 'left' then
    if self.rotation > self.downOneEighty then
      self.rotation = self.rotation - self.degreesChange
      return false
    end
    self.rotation = self.downOneEighty
  elseif self.direction == 'up' then
    if self.rotation > self.horizTwoSeventy then
      self.rotation = self.rotation - self.degreesChange
      return false
    end
    self.rotation = self.horizTwoSeventy
  elseif self.direction == 'down' then
    if self.rotation > self.horizNinty then
      self.rotation = self.rotation - self.degreesChange
      return false
    end
    self.rotation = self.horizNinty
  end
  return true
end

--Checks for collision into ponds or trees (need to add tank on tank collision)
function Tank:checkCollisionRight()
  if self.dx > 0 then
    if self.map:collides(self.map:tileAt(self.x + self.width, self.y + 15)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + self.height - 15)) or self.map:collides(self.map:tileAt(self.x + self.width, self.y + (self.height / 2))) then
      self.dx = 0
      self.x = self.x
    end
  end
end

--Checks for collision into powerups
function Tank:checkPowerUpCollisionRight()
  if self.powerUpActive == true and self.dx > 0 then
    if ((self.x + (self.width - 10) > (self.map.powerUp.x + 10)) and ((self.x + self.width) < (self.map.powerUp.x + self.map.powerUp.width)) and ((self.y + self.height / 2) >= self.map.powerUp.y) and ((self.y + self.height / 2) <= self.map.powerUp.y + self.map.powerUp.height)) then
      self.sounds['upgrade']:play()
      if self.map.shell == 2 then
        self.whichPowerUp = 2
      elseif self.map.shell == 3 then
        self.whichPowerUp = 3
      end
      self.state = 'idleDefault'
      return true
    end
    return false
  end
end

--Checks for collision into ponds or trees (need to add tank on tank collision)
function Tank:checkCollisionLeft()
  if self.dx < 0 then
    if self.map:collides(self.map:tileAt(self.x, self.y + 15)) or self.map:collides(self.map:tileAt(self.x, self.y + self.height - 15)) or self.map:collides(self.map:tileAt(self.x, self.y + (self.height / 2))) then
      self.dx = 0
      self.x = self.x
    end
  end
end

--Checks for collision into powerups
function Tank:checkPowerUpCollisionLeft()
  if self.powerUpActive == true and self.dx < 0 then
    if ((self.x + 10 < (self.map.powerUp.x + self.map.powerUp.width - 10)) and ((self.x) > (self.map.powerUp.x)) and (self.y + self.height / 2) >= self.map.powerUp.y and (self.y + self.height / 2) <= (self.map.powerUp.y + self.map.powerUp.height)) then
      self.sounds['upgrade']:play()
      if self.map.shell == 2 then
        self.whichPowerUp = 2
      elseif self.map.shell == 3 then
        self.whichPowerUp = 3
      end
      self.state = 'idleDefault'
      return true
    end
    return false
  end
end

--Checks for collision into ponds or trees (need to add tank on tank collision)
function Tank:checkCollisionUp()
  if self.dy < 0 then
    if self.map:collides(self.map:tileAt(self.x + 15, self.y)) or self.map:collides(self.map:tileAt(self.x + self.width - 15, self.y)) or self.map:collides(self.map:tileAt(self.x + (self.width / 2), self.y)) then
      self.dy = 0
      self.y = self.y
    end
  end
end

--Checks for collision into powerups
function Tank:checkPowerUpCollisionUp()
  if self.powerUpActive == true and self.dy < 0 then
    if ((self.y + 10 < (self.map.powerUp.y + self.map.powerUp.height) - 10) and ((self.y + self.height) > (self.map.powerUp.y)) and (self.x + self.width / 2) >= self.map.powerUp.x and (self.x + self.width / 2) <= (self.map.powerUp.x + self.map.powerUp.width)) then
      self.sounds['upgrade']:play()
      if self.map.shell == 2 then
        self.whichPowerUp = 2
      elseif self.map.shell == 3 then
        self.whichPowerUp = 3
      end
      self.state = 'idleDefault'
      return true
    end
    return false
  end
end

--Checks for collision into ponds or trees (need to add tank on tank collision)
function Tank:checkCollisionDown()
  if self.dy > 0 then
    if self.map:collides(self.map:tileAt(self.x + 15, self.y + self.height)) or self.map:collides(self.map:tileAt(self.x + self.width - 15, self.y + self.height)) or self.map:collides(self.map:tileAt(self.x + (self.width / 2), self.y + self.height)) then
      self.dy = 0
      self.y = self.y
    end
  end
end

--Checks for collision into powerups
function Tank:checkPowerUpCollisionDown()
  if self.powerUpActive == true and self.dy > 0 then
    if ((self.y + self.height - 10) > (self.map.powerUp.y + 10)) and (self.y < (self.map.powerUp.y + self.map.powerUp.height)) and (self.x + self.width / 2) >= self.map.powerUp.x and ((self.x + self.width / 2) <= (self.map.powerUp.x + self.map.powerUp.width)) then
      self.sounds['upgrade']:play()
      if self.map.shell == 2 then
        self.whichPowerUp = 2
      elseif self.map.shell == 3 then
        self.whichPowerUp = 3
      end
      self.state = 'idleDefault'
      return true
    end
    return false
  end
end


function Tank:render()
  local scaleX = .8
  local scaleY = .8

  love.graphics.draw(self.texture, self.animation:getCurrentFrame(), math.floor(self.x + self.width / 2), math.floor(self.y + self.height / 2), self.rotation, scaleX, scaleY, self.width / 2, self.height / 2)

end
