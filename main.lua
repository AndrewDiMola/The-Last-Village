-- Zhadn's The Last Village

function love.load()
  
  Village, Inn, Menu = true, false, false
  Timer = 0 -- Used for NPC movement
  
  loadBumpWorlds() -- Bump is used for collision detection
  loadImages()
  loadTileset()

  loadAudio() 

  loadCharacter()
  loadVillage()
  
  loadBumpItems()
end

function love.draw()
 
  if not Menu then
    
    if Village then
	  drawVillage() 
	end  
	
	if Inn then
	  drawInn()
    end
	  	 
	-- Always draw the Character	 
	love.graphics.draw(CharacterImage, Character.x, Character.y)	 
	
	-- Reset the volume outside the Main Menu
	TownTheme:setVolume(1)

  else -- Inside the Main Menu
    
	drawMainMenu()
	
	-- Lower the volume inside the Main Menu
	TownTheme:setVolume(0.3)
  end
end

function love.update(dt)
  Timer = Timer + dt -- Used in NPC movement
	
  updateCharacter()	
  updateOutsideVillagers()
  updateClouds(dt)
	
  updateBumpWorlds()

  -- Door outside of the Inn
  if Village and (Character.x > 380 and Character.x < 390) and (Character.y > 315 and Character.y < 325) then
	updateVillage()
  end
	
  -- Door inside of the Inn (and any other future building within the Village)
  if Inn and (Character.x > 380 and Character.x < 390) and (Character.y > 560 and Character.y < 570) then
    updateInn()
  end
	
end

function love.keypressed(key)

  if key == 'return' and Menu == false then
		Menu = true
  else
    if key == 'return' then
        Menu = false
    end
  end 
  
  if key == 'q' then
    love.event.quit()
  end
end

----------------------
-- Helper Functions --
----------------------

------------------------
---- Love.load() -------
------------------------

function loadBumpWorlds()

  -- https://github.com/kikito/bump.lua
  local bump = require 'bump' -- Collision Detection
  
  VillageWorld = bump.newWorld(50)
  InnWorld = bump.newWorld(50)
end

function loadImages()

  CharacterImage = love.graphics.newImage("images/characters/character.png")
  VillagerImage = love.graphics.newImage("images/characters/villager.png")
  SunImage = love.graphics.newImage("images/background/scenery/sun.png")
  MoonImage = love.graphics.newImage("images/background/scenery/moon.png")
  CloudImage = love.graphics.newImage("images/background/scenery/cloud.png")
  TilesetImage = love.graphics.newImage("images/tileset.png")
end

function loadTileset()

  Tileset = {x = 32, y = 32, w = TilesetImage:getWidth(), h = TilesetImage:getHeight()} -- Each tile is 32x32
  
  -- Tiles
  local quadInfo = {
    {0, 0, "t"},    -- 1 = grass
    {32, 0, "s"},   -- 2 = house
    {0, 32, "t"},   -- 3 = road
    {32, 32, "s"},  -- 4 = sky
	{64, 0, "t"},   -- 5 = door
    {64, 32, "s"},  -- 6 = red (bed)
	{96, 0, "s"},   -- 7 = inn sign 
	{96, 32, "s"},  -- 8 = white (bed pillow)
    {128, 0, "s"},  -- 9 = sword sign 
    {128, 32, "s"}, -- 10 = shield sign
	{160, 0, "s"},  -- 11 = house-top
    {160, 32, "s"}, -- 12 = house-bottom
    {192, 0, "s"},  -- 13 = house-left
    {192, 32, "s"}, -- 14 = house-right
    {224, 0, "s"},  -- 15 = house-top-left
    {224, 32, "s"}, -- 16 = house-bottom-left
    {256, 0, "s"},  -- 17 = house-top-right
    {256, 32, "s"}, -- 18 = house-bottom-right
	{288, 0, "s"},  -- 19 = character-home sign
    {288, 32, "s"}, -- 20 = villager-home sign
	{0, 64, "s"},   -- 21 = bed-left
	{32, 64, "s"},  -- 22 = bed-right
	{64, 64, "t"},  -- 23 = road-horizontal
	{96, 64, "t"},  -- 24 = road-vertical
	{128, 64, "t"}, -- 25 = road-left
	{160, 64, "t"}, -- 26 = road-top
	{192, 64, "t"}, -- 27 = road-right
	{224, 64, "t"}, -- 28 = road-bottom
	{256, 64, "t"}, -- 29 = road-top-left
	{288, 64, "t"}, -- 30 = road-top-right
	{0, 96, "t"},   -- 31 = road-bottom-left
	{32, 96, "t"},  -- 32 = road-bottom-right
	{64, 96, "t"}   -- 33 = grass-top
  }
  
  Tiles = {}
  for i,info in ipairs(quadInfo) do
    Tiles[i] = love.graphics.newQuad(info[1], info[2], Tileset.x, Tileset.y, Tileset.w, Tileset.h)
  end		
end

function loadAudio()

  TownTheme = love.audio.newSource("soundtrack/FF1Town.mp3")
  
  TownTheme:play()
  TownTheme:setLooping(true)
end

function loadCharacter()

  Character = {x = 384, y = 560, sx, sy} -- current and starting position
  Character.sx, Character.sy = Character.x, Character.y
end

function loadVillage()

  -- NPCs: Outside
  local villager1 = {x = 50, y = 250}
  local villager2 = {x = 450, y = 85}
  local villager3 = {x = 540, y = 475}
  OutsideVillagers = {villager1, villager2, villager3}
   
  -- NPCs: Inn
  local villager4 = {x = 512, y = 512}
  InnVillagers = {villager4}
  
  -- Clouds: Outside
  local cloud1 = {x = -25, y = 15}
  local cloud2 = {x = 175, y = 15}
  local cloud3 = {x = 375, y = 15}
  local cloud4 = {x = 575, y = 15}
  Clouds = {cloud1, cloud2, cloud3, cloud4}
  
  -- Maps: 
  VillageTable = {
    { 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 },
	{ 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 },
	{33,33,15,11,11,11,17,33,33,33,33,33,33,33,33,33,33,33,15,11,11,11,17,33,33 },
	{ 1, 1,13, 9, 2,10,14, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,13, 2,19, 2,14, 1, 1 },
	{ 1, 1,16,12, 5,12,18, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,16,12, 5,12,18, 1, 1 },
	{ 1, 1,33,33,24,33,33, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,33,33,24,33,33, 1, 1 },
	{ 1, 1, 1, 1,25,23,23,23,23,23,23,23,23,23,23,23,23,23,23,23,27, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1,15,11,11,11,17, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1,13, 2, 7, 2,14, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1,16,12, 5,12,18, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1,33,33,24,33,33, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1 },
	{ 1, 1, 1, 1,31,23,23,23,26,23,23,23, 3,23,23,23,23,23,23,23,27, 1,15,11,17 },
	{ 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,24, 1,13, 2,14 },
	{23,23,23,23,23,23,23,23,32, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,24, 1,13,20,14 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,24, 1,16, 5,18 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1,31,23,23,28,23 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 } 
  }   
  
  InnTable = {
    { 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2,21,22, 8, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2,21,22, 8, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2,21,22, 8, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2,21,22, 8, 2, 2, 5, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 2, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 5, 2, 2, 2, 2, 2, 2, 2, 2, 5 },
	{ 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 2, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5 } 
  }   
end

function loadBumpItems()

  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  for key, villager in pairs(OutsideVillagers) do
    VillageWorld:add(villager, villager.x, villager.y, VillagerImage:getWidth(), VillagerImage:getHeight())
  end
  
  for key, villager in pairs(InnVillagers) do
    InnWorld:add(villager, villager.x, villager.y, VillagerImage:getWidth(), VillagerImage:getHeight())
  end
end

------------------------
---- Love.draw() -------
------------------------

function drawVillage()
  
  -- Draw the Village tiles
  for rowIndex = 1, #VillageTable do
    local row = VillageTable[rowIndex]
    
    for columnIndex = 1, #row do
      local number = row[columnIndex]
      love.graphics.draw(TilesetImage, Tiles[number], (columnIndex - 1 ) * Tileset.x, (rowIndex - 1) * Tileset.y)
    end
  end
    
  --  Draw the Villagers
  for key, villager in pairs(OutsideVillagers) do
    love.graphics.draw(VillagerImage, villager.x, villager.y)
  end  
    
  --  Draw the Clouds
  for key, cloud in pairs(Clouds) do
    love.graphics.draw(CloudImage, cloud.x, cloud.y)
  end  
end

function drawInn()

  -- Draw the Inn tiles  
  for rowIndex = 1, #InnTable do
    local row = InnTable[rowIndex]
  
    for columnIndex = 1, #row do
      local number = row[columnIndex]
      love.graphics.draw(TilesetImage, Tiles[number], (columnIndex - 1) * Tileset.x, (rowIndex - 1) * Tileset.y)
    end	
  end
  
  -- Draw the Villagers
  for key, villager in pairs(InnVillagers) do
    love.graphics.draw(VillagerImage, villager.x, villager.y)
  end
end

function drawMainMenu()
  
  love.graphics.setBackgroundColor(0, 0, 0)
  love.graphics.setNewFont(50)
  love.graphics.print("Main Menu", 265, 100)
end

------------------------
---- Love.update() -----
------------------------

function updateCharacter()

  if (love.keyboard.isDown('up') or love.keyboard.isDown('w')) and Character.y > 65 then

    if Village then
      Character.x, Character.y = VillageWorld:move(Character, Character.x, Character.y - 5)
    end

	if Inn then
	  Character.x, Character.y = InnWorld:move(Character, Character.x, Character.y - 5)
	end
  end
  
  if (love.keyboard.isDown('down') or love.keyboard.isDown('s')) and Character.y < 570 then

    if Village then
	  Character.x, Character.y = VillageWorld:move(Character, Character.x, Character.y + 5)
    end

	if Inn then
	  Character.x, Character.y = InnWorld:move(Character, Character.x, Character.y + 5)
    end
  end

  if (love.keyboard.isDown('left') or love.keyboard.isDown('a')) and Character.x > 0 then
  
	if Village then
	  Character.x, Character.y = VillageWorld:move(Character, Character.x - 5, Character.y)
    end

	if Inn then
	  Character.x, Character.y = InnWorld:move(Character, Character.x - 5, Character.y)
    end
  end

  if (love.keyboard.isDown('right') or love.keyboard.isDown('d')) and Character.x < 765 then
    
	if Village then
	  Character.x, Character.y = VillageWorld:move(Character, Character.x + 5, Character.y)
    end
	  
	if Inn then
	  Character.x, Character.y = InnWorld:move(Character, Character.x + 5, Character.y)
    end
  end  
end

function updateOutsideVillagers()
  
  -- NPC movement
  local villagerSpeed = 10
  local villagerDirection = (math.random(0,1) * 2) - 1

  if Timer > 2 then -- Every 2 seconds a villager moves in a random direction
	local villager1 = OutsideVillagers[1]
	local villager2 = OutsideVillagers[2]

	villager1.x, villager1.y = VillageWorld:move(villager1, villager1.x + villagerSpeed * villagerDirection, villager1.y)
	villager2.x, villager2.y = VillageWorld:move(villager2, villager2.x, villager2.y + villagerSpeed * villagerDirection)
	Timer = 0 
  end
end

function updateClouds(dt)

  -- Clouds
  local cloudSpeed = 25
  local cloudStart, cloudEnd = -25, 800
	
  --- Wrapping
  for key, cloud in pairs(Clouds) do
    if cloud.x > cloudEnd then
      cloud.x = cloudStart
    end
  end
	
  --- Movement
  for key, cloud in pairs(Clouds) do
    cloud.x = cloud.x + (cloudSpeed * dt) 
  end
end

function updateVillage()

  VillageWorld:remove(Character)
  InnWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Inn, Village = true, false

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
end

function updateInn()
  
  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  InnWorld:remove(Character)
  
  Inn, Village = false, true
  
  Character.x, Character.y = VillagePosition.x, VillagePosition.y + 10 -- Regain Village position and move outside of boundary check
end

function updateBumpWorlds()

  if Village then
    VillageWorld:update(Character, Character.x, Character.y)
	
	for key, villager in pairs(OutsideVillagers) do
	  VillageWorld:update(villager, villager.x, villager.y)
	end
  end
  
  if Inn then
	InnWorld:update(Character, Character.x, Character.y)

	for key, villager in pairs(InnVillagers) do
	  InnWorld:update(villager, villager.x, villager.y)
	end
  end
end