Map = Class {}

-- Set names for quads
GRASS_POND_TLEFT = 1
GRASS_POND_TOP = 2
GRASS_POND_TRIGHT = 3
GRASS_FOUR = 4
GRASS_FIVE = 5
TREE = 6
DIRT_SEVEN = 7
GRASS_POND_LEFT = 8
BLANK_NINE = 9
GRASS_POND_RIGHT = 10
GRASS_ELEVEN = 11
GRASS_TWELVE = 12
GRASS_THIRTEEN = 13
DIRT_FOURTEEN = 14
GRASS_POND_BLEFT = 15
GRASS_POND_BOTTOM = 16
GRASS_POND_BRIGHT = 17
GRASS_EIGHTEEN = 18
GRASS_NINETEEN = 19
GRASS_TWENTY = 20
DIRT_TWENTYONE = 21

function Map:init()

  --Set spritesheet to sheet path
  self.spritesheet = love.graphics.newImage('graphics/Grass.png')

  --Set size of tiles on spritesheet
  self.tilewidth = 16
  self.tileheight = 16

  --set how many tiles can exist on map
  self.mapWidth = 40
  self.mapHeight = 23

  --Create empty table of tiles
  self.tiles = {}

  --Create quads
  self.tileSprites = generateQuads(self.spritesheet, self.tilewidth, self.tileheight)

  self.mapWidthPixels = self.mapWidth * self.tilewidth
  self.mapHeightPixels = self.mapHeight * self.tileheight

  --Check to see if there is a pond in X spot
  self.pondInX = false

  --Set match count to 1 to see if first played match or not
  self.match = 1

  --Create tanks
  self.tankOne = Tank(self, 0, math.random(0, self.mapHeightPixels - 48), 'brown', 'right', 'playerOne', state)
  self.tankTwo = Tank(self, self.mapWidthPixels - 48, math.random(0, self.mapHeightPixels - 48), 'blue', 'left', 'playerTwo', state)

  --Initialize all sanity checks
  self.activeOne = false
  self.activeTwo = false
  self.shotOne = false
  self.shotTwo = false
  self.player = nil

  --Set initial match Count for each player
  self.playerOneMatchCount = 0
  self.playerTwoMatchCount = 0

  --Set type of shell for the first powerup
  self.shell = math.random(2,3)

  --Create first powerup
  self.powerUp = PowerUp(self, math.random(0, VIRTUAL_WIDTH - 50), math.random(48, VIRTUAL_HEIGHT - 50), self.shell, 1)

  --Set different font sizes for game
  scoreFont = love.graphics.newFont('fonts/font.otf', 12)
  welcomeFont = love.graphics.newFont('fonts/font.otf', 24)
  largeFont = love.graphics.newFont('fonts/font.otf', 32)

  self.sounds = {
    ['tankHit'] = love.audio.newSource('sounds/tanks/TankHit.wav', 'static'),
    ['tankExplode'] = love.audio.newSource('sounds/tanks/TankExplode.wav', 'static')
  }

  --Check to see if this is the first match played or not
  if self.match == 1 then
    self.gameState = 'startGame'
  else
    self.gameState = 'play'
  end

  --fill map with empty tiles
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      self:setTile(x, y, BLANK_NINE)
    end
  end

  -- increment scan line
  self.nextX = 1

  --create a table for tiling grass only
  local grass_table = {
    [1] = GRASS_FOUR,
    [2] = GRASS_FIVE,
    [3] = GRASS_ELEVEN,
    [4] = GRASS_TWELVE,
    [5] = GRASS_THIRTEEN,
    [6] = GRASS_EIGHTEEN,
    [7] = GRASS_NINETEEN,
    [8] = GRASS_TWENTY,
  }

  --Create a table for Dirt tiles
  local dirt_table = {
    [1] = DIRT_SEVEN,
    [2] = DIRT_FOURTEEN,
    [3] = DIRT_TWENTYONE
  }


  -- Loop through the map and create it using tiles
  while self.nextX <= self.mapWidth do
    for y = 0, self.mapHeight do
      if y < 2 then
        local randomDirt = math.random(1,3)
        self:setTile(self.nextX, y, BLANK_NINE)
      elseif y == 2 then
        self:setTile(self.nextX, y, GRASS_POND_BOTTOM)
      elseif y > 2 then
        local randomGrassTile = math.random(1,8)
        local makeGrass = grass_table[randomGrassTile]
        if(makeGrass) then
          self:setTile(self.nextX, y, makeGrass)
        else
          love.event.quit()
        end
      end
    end
    self.nextX = self.nextX + 1
  end

  self.nextX = 1
  --Loop through the map again and create ponds and trees
  while self.nextX <= self.mapWidth do
    for y = 4, self.mapHeight,3 do
      self:makePond(y)
      self:makeTree(self.pondInX, y)
    end
    if self.pondInX == true then
      self.nextX = self.nextX + 3
      self.pondInX = false
    else
      self.nextX = self.nextX + 1
    end
  end
end

-- create ponds
function Map:makePond(y)
  local pond_table = {
    [1] = GRASS_POND_TLEFT,
    [2] = GRASS_POND_TOP,
    [3] = GRASS_POND_TRIGHT,
    [4] = GRASS_POND_LEFT,
    [5] = BLANK_NINE,
    [6] = GRASS_POND_RIGHT,
    [7] = GRASS_POND_BLEFT,
    [8] = GRASS_POND_BOTTOM,
    [9] = GRASS_POND_BRIGHT
  }
  if self.nextX > 4 and self.nextX < self.mapWidth - 4 then
    if math.random(10) == 1 then
      local pondStart = y
      self:setTile(self.nextX, pondStart, pond_table[5])
      self:setTile(self.nextX - 1, pondStart - 1, pond_table[1])
      self:setTile(self.nextX, pondStart - 1, pond_table[2])
      self:setTile(self.nextX + 1, pondStart - 1, pond_table[3])
      self:setTile(self.nextX - 1, pondStart, pond_table[4])
      self:setTile(self.nextX + 1, pondStart, pond_table[6])
      self:setTile(self.nextX - 1, pondStart + 1, pond_table[7])
      self:setTile(self.nextX, pondStart + 1, pond_table[8])
      self:setTile(self.nextX + 1, pondStart + 1, pond_table[9])
      self.pondInX = true
    end
  end
end

--Create tree if no pond in X exists
function Map:makeTree(pond, y)
  local tree_table = {
    [1] = TREE
  }
  local pondCheck = pond
  local treeY = y
  if math.random(20) == 1 then
    if pondCheck == false then
      self:setTile(self.nextX, treeY, tree_table[1])
    end
  end
end

--Set collidables for tanks
function Map:collides(tile)
  local collidables = {
    BLANK_NINE, TREE
  }

  for _, v in ipairs(collidables) do
    if tile.id == v then
      return true
    end
  end
  return false
end

function Map:setTile(x, y, id)
  self.tiles[(y - 1) * self.mapWidth + x] = id
end

function Map:getTile(x,y)
  return self.tiles[(y - 1) * self.mapWidth + x]
end

function Map:update(dt)
  --Check game state and adjust game depending on current state
  if self.gameState == 'startGame' then
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
      self.gameState = 'matchStart'
    end
  elseif self.gameState == 'matchStart' then
    self:resetScene()
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
      self.gameState = 'play'
    end
  elseif self.gameState == 'gameOver' then
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') or love.keyboard.wasPressed('space') then
      self:init()
      self.gameState = 'matchStart'
    end
  elseif self.gameState == 'play' then
    self.tankOne:update(dt)
    self.tankTwo:update(dt)
    --Create muzzle blast, projectile, projectile type, projectile direction, and set sanity check shotOne for tank One upon firing with space key
    if love.keyboard.wasPressed('space') and self.shotOne ~= true and (self.tankOne.hitCount > 0 and self.tankTwo.hitCount > 0) and (self.tankOne.state ~= 'rotateLeft' and self.tankOne.state ~= 'rotateRight') then
      self.fireOne = Fire(self, self.tankOne.x, self.tankOne.y, self.tankOne.rotation, 'tankOne', state, start)
      self.activeOne = true
      self.projectileOne = Projectiles(self, self.tankOne.x, self.tankOne.y, self.tankOne.rotation, 'tankOne', state, dy)
      self.projectileOne.bullet = self.currentLoadOutOne
      self.shotOne = true
    end

    --Create muzzle blast, projectile, projectile type, projectile direction, and set sanity check shotTwo for tank Two upon firing with enter key
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') and self.shotTwo ~= true and (self.tankOne.hitCount > 0 and self.tankTwo.hitCount > 0) and (self.tankTwo.state ~= 'rotateLeft' and self.tankTwo.state ~= 'rotateRight') then
      self.fireTwo = Fire(self, self.tankTwo.x, self.tankTwo.y, self.tankTwo.rotation, 'tankTwo', state, start)
      self.activeTwo = true
      self.projectileTwo = Projectiles(self, self.tankTwo.x, self.tankTwo.y, self.tankTwo.rotation, 'tankTwo', state, dy)
      self.projectileTwo.bullet = self.currentLoadOutTwo
      self.shotTwo = true
    end

    --Run muzzle blast animation if activeOne or activeTwo is true
    if self.activeOne == true then
      self.fireOne:update(dt)
    elseif self.activeTwo == true then
      self.fireTwo:update(dt)
    end

    if self.shotOne == true then
      self.projectileOne:update(dt)
      --Reset projectile if it leaves the play area
      if self.projectileOne.y < 0 or self.projectileOne.y > VIRTUAL_HEIGHT or self.projectileOne.x < 0 or self.projectileOne.x > VIRTUAL_WIDTH then
      self.projectileOne:reset(self.tankOne.x, self.tankOne.y, 'tankOne', false)
      end
      --Adjust hitCount if tank is hit by projectile and reset the projectile
      if(self:shotHit('projectileOne', 'tankTwo')) then
        self.sounds['tankHit']:play()
        self.projectileOne.hit = true
        self.projectileOne:reset(self.tankOne.x, self.tankOne.y, 'tankOne', false)
        self.tankTwoHit = true
        if self.currentLoadOutOne == 1 then
          self.tankTwo.hitCount = self.tankTwo.hitCount - 1
        elseif self.currentLoadOutOne == 2 then
          self.tankTwo.hitCount = self.tankTwo.hitCount - 3
        elseif self.currentLoadOutOne == 3 then
          if self.tankTwo.hitCount ~= 1 then
            self.tankTwo.hitCount = 1
          else
            self.tankTwo.hitCount = self.tankTwo.hitCount - 1
          end
        end
        if self.tankTwo.hitCount <= 0 then
          self.playerOneMatchCount = self.playerOneMatchCount + 1
        end
      end
    end
    if self.shotTwo == true then
      self.projectileTwo:update(dt)
      --Reset projectile if it leaves the play area
      if self.projectileTwo.y < 0 or self.projectileTwo.y > VIRTUAL_HEIGHT or self.projectileTwo.x < 0 or self.projectileTwo.x > VIRTUAL_WIDTH then
      self.projectileTwo:reset(self.tankTwo.x, self.tankTwo.y, 'tankTwo', false)
      end
      --Adjust hitCount if tank is hit by projectile and reset the projectile
      if(self:shotHit('projectileTwo', 'tankOne')) then
        self.sounds['tankHit']:play()
        self.projectileTwo.hit = true
        self.projectileTwo:reset(self.tankTwo.x, self.tankTwo.y, 'tankTwo', false)
        self.tankOneHit = true
        if self.currentLoadOutTwo == 1 then
          self.tankOne.hitCount = self.tankOne.hitCount - 1
        elseif self.currentLoadOutTwo == 2 then
          self.tankOne.hitCount = self.tankOne.hitCount - 3
        elseif self.currentLoadOutTwo == 3 then
          if self.tankOne.hitCount ~= 1 then
            self.tankOne.hitCount = 1
          else
            self.tankOne.hitCount = self.tankOne.hitCount - 1
          end
        end
        if self.tankOne.hitCount <= 0 then
          self.playerTwoMatchCount = self.playerTwoMatchCount + 1
        end
      end
    end

    --Run impact animation if tank is hit
    if self.tankOneHit == true then
      self.impactOne:update(dt)
    end
    if self.tankTwoHit == true then
      self.impactTwo:update(dt)
    end

    --Add smoke or flames, or destroy animations depending on Tanks hitCount
    if self.tankTwo.hitCount < 3 and self.tankTwo.hitCount > 0 then
      self.smokeTankTwo:update(dt)
      self.smokeTankTwo.x = (self.tankTwo.x + (self.tankTwo.width / 2) - (self.smokeTankTwo.width / 2))
      self.smokeTankTwo.y = (self.tankTwo.y + (self.smokeTankTwo.height / 2) - self.smokeTankTwo.height / 2)
    end
    if self.tankTwo.hitCount == 1 and self.tankTwo.hitCount > 0 then
      self.flameTankTwo:update(dt)
      self.flameTankTwo.x = (self.tankTwo.x + (self.tankTwo.width / 2 + 5) - (self.flameTankTwo.width / 2))
      self.flameTankTwo.y = (self.tankTwo.y + (self.flameTankTwo.height / 2 + 5) - (self.flameTankTwo.height / 2))
    elseif self.tankTwo.hitCount <= 0 then
      self.sounds['tankExplode']:play()
      self.explodeTankTwo:update(dt)
      self.explodeTankTwo.x = (self.tankTwo.x + (self.tankTwo.width / 2) - (self.explodeTankTwo.width / 2))
      self.explodeTankTwo.y = (self.tankTwo.y + (self.tankTwo.height / 2) - (self.explodeTankTwo.height / 2))
    end
    if self.tankOne.hitCount < 3 and self.tankOne.hitCount > 0 then
      self.smokeTankOne:update(dt)
      self.smokeTankOne.x = (self.tankOne.x + (self.tankOne.width / 2) - (self.smokeTankOne.width / 2))
      self.smokeTankOne.y = (self.tankOne.y + (self.smokeTankOne.height / 2) - self.smokeTankOne.height / 2)
    end
    if self.tankOne.hitCount == 1 then
      self.flameTankOne:update(dt)
      self.flameTankOne.x = (self.tankOne.x + (self.tankOne.width / 2 + 5) - (self.flameTankOne.width / 2))
      self.flameTankOne.y = (self.tankOne.y + (self.flameTankOne.height / 2 + 5) - (self.flameTankOne.height / 2))
    elseif self.tankOne.hitCount <= 0 then
      self.sounds['tankExplode']:play()
      self.explodeTankOne:update(dt)
      self.explodeTankOne.x = (self.tankOne.x + (self.tankOne.width / 2) - (self.explodeTankOne.width / 2))
      self.explodeTankOne.y = (self.tankOne.y + (self.tankOne.height / 2) - (self.explodeTankOne.height / 2))
    end

    --Set the winner for first player to 3 matches
    if self.playerOneMatchCount == 3 or self.playerTwoMatchCount == 3 then
      if self.playerOneMatchCount == 3 then
        self.player = '1'
      elseif self.playerTwoMatchCount == 3 then
        self.player = '2'
      end
    end
  end

  self.powerUp:update(dt)

  --Check for collection of powerup through coordinate positions
  if(self.tankOne:checkPowerUpCollisionRight()) or (self.tankOne:checkPowerUpCollisionLeft()) or (self.tankOne:checkPowerUpCollisionUp()) or (self.tankOne:checkPowerUpCollisionDown()) then
    self.currentLoadOutOne = self.tankOne.whichPowerUp
    --Create new powerup spawn
    self.shell = math.random(2,3)
    self.powerUp:init(self, math.random(0, VIRTUAL_WIDTH - (self.powerUp.width * 2)), math.random(0, VIRTUAL_HEIGHT - (self.powerUp.height * 2)), self.shell, 1)
  else
    self.currentLoadOutOne = self.tankOne.whichPowerUp
  end
  if(self.tankTwo:checkPowerUpCollisionRight()) or (self.tankTwo:checkPowerUpCollisionLeft()) or (self.tankTwo:checkPowerUpCollisionUp()) or (self.tankTwo:checkPowerUpCollisionDown()) then
    self.currentLoadOutTwo = self.tankTwo.whichPowerUp
    self.shell = math.random(2,3)
    self.powerUp:init(self, math.random(0, VIRTUAL_WIDTH - (self.powerUp.width * 2)), math.random(0, VIRTUAL_HEIGHT - (self.powerUp.height * 2)), self.shell, 1)
  else
    self.currentLoadOutTwo = self.tankTwo.whichPowerUp
  end
end

--Check if tank is hit through coordinate placement
function Map:shotHit(projectile, tank)
  if projectile == 'projectileOne' and tank == 'tankTwo' then
    if (self.projectileOne.x + (self.projectileOne.width / 2) > self.tankTwo.x + 5) and (self.projectileOne.x + (self.projectileOne.width / 2) < self.tankTwo.x + (self.tankTwo.width - 5)) and (self.projectileOne.y + (self.projectileOne.height / 2) > self.tankTwo.y + 5) and (self.projectileOne.y + (self.projectileOne.height / 2) < self.tankTwo.y + self.tankTwo.height - 5) then
      --if tank is hit then create needed Effects
      self.impactTwo = Effects(self, self.tankTwo.x, self.tankTwo.y, 'impact', self.tankOne.rotation, 1.5)
      self.smokeTankTwo = Effects(self, self.tankTwo.x, self.tankTwo.y, 'smoke', 0, 1.5)
      self.flameTankTwo = Effects(self, self.tankTwo.x, self.tankTwo.y, 'flame', 0, 1.5)
      self.explodeTankTwo = Effects(self, self.tankTwo.x, self.tankTwo.y, 'explode', 0, 2)
      return true
    end
  end
  if projectile == 'projectileTwo' and tank == 'tankOne' then
    if (self.projectileTwo.x + (self.projectileTwo.width / 2) > self.tankOne.x + 5) and (self.projectileTwo.x + (self.projectileTwo.width / 2) < self.tankOne.x + (self.tankOne.width - 5)) and (self.projectileTwo.y + (self.projectileTwo.height / 2) > self.tankOne.y + 5) and (self.projectileTwo.y + (self.projectileTwo.height / 2) < self.tankOne.y + self.tankOne.height - 5) then
      self.impactOne = Effects(self, self.tankOne.x, self.tankOne.y, 'impact', self.tankTwo.rotation, 1.5)
      self.smokeTankOne = Effects(self, self.tankOne.x, self.tankOne.y, 'smoke', 0, 1.5)
      self.flameTankOne = Effects(self, self.tankOne.x, self.tankOne.y, 'flame', 0, 1.5)
      self.explodeTankOne = Effects(self, self.tankOne.x, self.tankOne.y, 'explode', 0, 2)
      return true
    end
  end
  return false
end

function Map:render()
  for y = 1, self.mapHeight do
    for x = 1, self.mapWidth do
      love.graphics.draw(self.spritesheet, self.tileSprites[self:getTile(x, y)], (x - 1) * self.tilewidth, (y - 1) * self.tileheight)
    end
  end

  if self.gameState == 'play' then
    self.tankOne:render()
    self.tankTwo:render()
    --render powerups if tank is not currently collecting powerup
    if not (self.tankOne:checkPowerUpCollisionRight()) or not (self.tankOne:checkPowerUpCollisionLeft()) or not (self.tankOne:checkPowerUpCollisionUp()) or not (self.tankOne:checkPowerUpCollisionDown()) then
      self.powerUp:render()
      self.tankOne.powerUpActive = true
    end
    if not (self.tankTwo:checkPowerUpCollisionRight()) or not (self.tankTwo:checkPowerUpCollisionLeft()) or not (self.tankTwo:checkPowerUpCollisionUp()) or not (self.tankTwo:checkPowerUpCollisionDown()) then
      self.powerUp:render()
      self.tankTwo.powerUpActive = true
    end

    --render muzzle blast if sanity checks pass
    if self.activeOne == true and self.fireOne.state == 'fire' then
      self.fireOne:render()
    end
    if self.activeTwo == true and self.fireTwo.state == 'fire' then
      self.fireTwo:render()
    end

    --render projectiles if sanity checks pass
    if self.shotOne == true then
      self.projectileOne:render()
    end
    if self.shotTwo == true then
      self.projectileTwo:render()
    end

    --render impact effects if sanity checks pass
    if self.tankTwoHit == true and self.impactTwo.state == 'impact' then
      self.impactTwo:render()
    end
    if self.tankOneHit == true and self.impactOne.state == 'impact' then
      self.impactOne:render()
    end

    --render smoke if tank if slightly damaged
    if self.tankTwo.hitCount < 3 and self.tankTwo.hitCount > 0 then
      self.smokeTankTwo:render()
    end
    if self.tankOne.hitCount < 3 and self.tankOne.hitCount > 0 then
      self.smokeTankOne:render()
    end

    --render flames if take is severly damaged
    if self.tankTwo.hitCount == 1 then
      self.flameTankTwo:render()
    elseif self.tankTwo.hitCount == 0 then
      self.explodeTankTwo:render()
    end
    if self.tankOne.hitCount == 1 then
      self.flameTankOne:render()
    elseif self.tankOne.hitCount == 0 then
      self.explodeTankOne:render()
    end
  end

  --Display game info
  self:display()
  --Display debug info if needed
  --self:debug()
end

function Map:tileAt(x,y)
  return {
    x = math.floor(x / self.tilewidth) + 1,
    y = math.floor(y / self.tileheight) + 1,
    id = self:getTile(math.floor(x / self.tilewidth) + 1, math.floor(y / self.tileheight) + 1)
  }
end

--Reset the game if a player has won
function Map:resetScene()
  self.tankOne.hitCount = 3
  self.tankTwo.hitCount = 3
  self.activeOne = false
  self.activeTwo = false
  self.shotOne = false
  self.shotTwo = false
  self.tankOneHit = false
  self.tankTwoHit = false
  self.currentLoadOutOne = 1
  self.currentLoadOutTwo = 1
  self.tankOne.whichPowerUp = 1
  self.tankTwo.whichPowerUp = 1
  if self.match ~= 1 then
    self.tankOne.y = (math.random(3,22) * self.tileheight)
    self.tankTwo.y = (math.random(3,22) * self.tileheight)
  end
end

function Map:resetHitCount()
  self.tankOne.hitCount = 3
  self.tankTwo.hitCount = 3
end

function Map:display()
  if self.gameState == 'startGame' then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(welcomeFont)
    love.graphics.printf("Welcome to Tankx!", 0, math.floor(VIRTUAL_HEIGHT / 2 - 15), math.floor(VIRTUAL_WIDTH), 'center')
    love.graphics.printf("Press Enter to start match", 0, math.floor(VIRTUAL_HEIGHT / 2 + 15), math.floor(VIRTUAL_WIDTH), 'center')
  elseif self.gameState == 'matchStart' then
    love.graphics.setFont(welcomeFont)
    love.graphics.printf("Match " ..tostring(self.match) .." Begin", 0, math.floor(VIRTUAL_HEIGHT / 2 -15), math.floor(VIRTUAL_WIDTH), 'center')
    love.graphics.printf("Press Enter or Space to play", 0, math.floor(VIRTUAL_HEIGHT / 2 + 15), math.floor(VIRTUAL_WIDTH), 'center')
  elseif self.gameState == 'gameOver' then
    love.graphics.setFont(largeFont)
    love.graphics.printf("Game Over", 0, math.floor(VIRTUAL_HEIGHT / 2 - 15), math.floor(VIRTUAL_WIDTH), 'center')
    love.graphics.printf("Player " ..tostring(self.player) .." wins!", 0, math.floor(VIRTUAL_HEIGHT / 2 + 15), math.floor(VIRTUAL_WIDTH), 'center')
  elseif self.gameState == 'play' then
    love.graphics.setFont(scoreFont)
    love.graphics.printf("Player 1", 0, 0, math.floor(VIRTUAL_WIDTH / 2), 'left')
    love.graphics.printf("HP: " ..tostring(self.tankOne.hitCount), 0, 0, math.floor(VIRTUAL_WIDTH / 2), 'center')
    love.graphics.printf("Match Count: " ..tostring(self.playerOneMatchCount), 0, 0, (math.floor(VIRTUAL_WIDTH / 2 - 10)), 'right')
    love.graphics.printf("Match Count: " ..tostring(self.playerTwoMatchCount), math.floor(VIRTUAL_WIDTH / 2 + 10), 0, math.floor(VIRTUAL_WIDTH), 'left')
    love.graphics.printf("HP: " .. tostring(self.tankTwo.hitCount), math.floor(VIRTUAL_WIDTH / 2), 0, math.floor(VIRTUAL_WIDTH  / 2), 'center')
    love.graphics.printf("Player 2", math.floor(VIRTUAL_WIDTH / 2), 0, math.floor(VIRTUAL_WIDTH / 2), 'right')
  end

end


function Map:debug()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.setFont(scoreFont)
  love.graphics.printf("TankX: " ..tostring(self.tankOne.x), 0, 10, VIRTUAL_WIDTH, 'left')
  love.graphics.printf("TankY: " ..tostring(self.tankOne.y), 0, 20, VIRTUAL_WIDTH, 'left')
  love.graphics.printf("State: " ..tostring(self.tankOne.state), 0, 30, VIRTUAL_WIDTH, 'left')
  love.graphics.printf("Tank One Fire :" ..tostring(self.shotOne), 0, 40, VIRTUAL_WIDTH, 'left')
  love.graphics.printf("TankX: " ..tostring(self.tankTwo.x), 0, 10, VIRTUAL_WIDTH, 'right')
  love.graphics.printf("TankY: " ..tostring(self.tankTwo.y), 0, 20, VIRTUAL_WIDTH, 'right')
  love.graphics.printf("whichPowerUp: " ..tostring(self.tankOne.whichPowerUp), 0, 70, VIRTUAL_WIDTH, 'center')
  love.graphics.printf("powerupActive: " ..tostring(self.tankOne.powerUpActive), 0, 30, VIRTUAL_WIDTH, 'center')
  if self.shotOne == true then
    love.graphics.printf("Bullet: " ..tostring(self.projectileOne.bullet), 0, 40, VIRTUAL_WIDTH, 'center')
    love.graphics.printf("state: " ..tostring(self.projectileOne.state), 0, 50, VIRTUAL_WIDTH, 'center')
    --love.graphics.printf("state: " ..tostring(self.impactTwo.state), 0, 60, VIRTUAL_WIDTH, 'center')
  end

end
