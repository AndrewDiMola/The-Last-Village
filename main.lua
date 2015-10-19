-- Zhadn's The Last Village

function love.load()

  loadGameSettings()

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

    if Armory then
      drawArmory()
    end

    if Home then
      drawHome()
    end

    if Residence then
      drawResidence()
    end

    if Dialogue then
      drawDialogue(CollidedVillager)
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
  if Village and (Character.x > 380 and Character.x < 390) and (Character.y > 320 and Character.y < 330) then
    updateInn()
    Dialogue = false
  end
  
  -- Door outside of the Armory
  if Village and (Character.x > 123 and Character.x < 133) and (Character.y > 128 and Character.y < 138) then
    updateArmory()
    Dialogue = false
  end
  
  -- Door outside of the Home
  if Village and (Character.x > 636 and Character.x < 646) and (Character.y > 128 and Character.y < 138) then
    updateHome()
    Dialogue = false
  end
  
  -- Door outside of the Residence
  if Village and (Character.x > 732 and Character.x < 742) and (Character.y > 512 and Character.y < 522) then
    updateResidence()
    Dialogue = false
  end  
  
  -- Door inside building
  if not Village and (Character.x > 380 and Character.x < 390) and (Character.y > 560 and Character.y < 570) then
    updateFromBuilding()
    Dialogue = false
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
function loadGameSettings()

  Village, Inn, Menu, Armory, Home, Residence = true, false, false, false, false, false
  Dialogue = false

  GameWidthMin = 1
  GameWidthMax = love.graphics.getWidth() - 1

  GameHeightMin = 1
  GameHeightMax = love.graphics.getHeight() - 1

  Timer = 0 -- Used for NPC movement
  
  Font = love.graphics.setNewFont("fonts/verdanab.ttf", 14)	
end

function loadBumpWorlds()

  -- https://github.com/kikito/bump.lua
  local bump = require 'bump' -- Collision Detection
  
  VillageWorld = bump.newWorld(50)
  InnWorld = bump.newWorld(50)
  ArmoryWorld = bump.newWorld(50)
  HomeWorld = bump.newWorld(50)
  ResidenceWorld = bump.newWorld(50)
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
  QuadInfo = {
    {0, 0, "t"},    -- 1 = grass
    {32, 0, "t"},   -- 2 = house / floor
    {0, 32, "t"},   -- 3 = road
    {32, 32, "s"},  -- 4 = sky
    {64, 0, "t"},   -- 5 = door (black)
    {64, 32, "t"},  -- 6 = carpet (red)
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
    {64, 96, "t"},  -- 33 = grass-top
    {96, 96, "s"},  -- 34 = wall (black)
    {128, 96, "t"}, -- 35 = sunflower-center
    {160, 96, "t"}, -- 36 = sunflower-right
    {192, 96, "t"}, -- 37 = sunflower-left
    {224, 96, "t"}, -- 38 = wildflower-center
    {256, 96, "t"}, -- 39 = wildflower-right
    {288, 96, "t"}  -- 40 = wildflower-left
  }

  Tiles = {}
  for i, info in ipairs(QuadInfo) do
    Tiles[i] = love.graphics.newQuad(info[1], info[2], Tileset.x, Tileset.y, Tileset.w, Tileset.h)
  end		
  
  BumpTiles = {}
  for i, info in ipairs(QuadInfo) do
    BumpTiles[i] = info[3]
  end
end

function loadAudio()

  TownTheme = love.audio.newSource("soundtrack/FF1Town.mp3")

  TownTheme:play()
  TownTheme:setLooping(true)
end

function loadCharacter()

  Character = {x = 386, y = 560, sx, sy} -- current and starting position
  Character.sx, Character.sy = Character.x, Character.y
end

function loadVillage()

  -- NPCs: Outside
  local villager1 = {x = 50, y = 250, m = "Hooligan! Leave me to my pacing!!!", isVillager = true}
  local villager2 = {x = 440, y = 85, m = "The moon hasn't looked the same lately...", isVillager = true}
  local villager3 = {x = 540, y = 375, m = "Welcome to The Last Village", isVillager = true}
  OutsideVillagers = {villager1, villager2, villager3}
  
  -- NPCs: Inn
  local villager4 = {x = 514, y = 514, m = "50G for the night? Why?", isVillager = true}
  InnVillagers = {villager4}
  
  -- NPCS: Armory
  local villager5 = {x = 162, y = 227, m = "Welcome to the Weapon Shop...Hey, that was pretty good, right?", isVillager = true}
  local villager6 = {x = 610, y = 227, m = "Damnit. Why do I have to stand here. We haven't sold anything in years!", isVillager = true}
  ArmoryVillagers = {villager5, villager6}
  
  -- Villager you're speaking with
  CollidedVillager = {}
  
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
    { 1, 1,13, 9,12,10,14, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,13, 2,19, 2,14, 1, 1 },
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
    { 1, 1, 1, 1, 1, 1, 1, 1,24,36,35,37,24,39,38,38,38,38,38,40,24, 1,13, 2,14 },
    {23,23,23,23,23,23,23,23,32,36,35,37,24,39,38,38,38,38,38,40,24, 1,13,20,14 },
    {36,35,35,35,35,35,35,35,35,35,35,37,24,39,38,38,38,38,38,40,24, 1,16, 5,18 },
    {36,35,35,35,35,35,35,35,35,35,35,37,24,39,38,38,38,38,38,40,31,23,23,28,23 },
    {36,35,35,35,35,35,35,35,35,35,35,37,24,39,38,38,38,38,38,38,38,38,38,38,40 } 
  }   
  
  InnTable = {
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2,21,22, 8, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2,21,22, 8, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2,21,22, 8, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34,34,34,34,34,34,34,34,34 },
    {34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2,21,22, 8, 2, 2,34, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 6, 6, 6, 2,34, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 } 
  }
  
  ArmoryTable = {
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },	
    {34,34,34,34,34, 2,34,34,34,34, 2, 2, 2, 2, 2,34,34,34,34, 2,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 }
  }
  
  HomeTable = {
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2,21,22, 8, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34,34, 2,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 }
  }
  
  ResidenceTable = {
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 6, 6, 6, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 }
  }  

end

function loadBumpItems()

  -- Character
  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  -- Locations / Villagers
  loadNPCS(OutsideVillagers, VillageWorld)
  loadTiledMap(VillageTable, VillageWorld)
  
  loadNPCS(InnVillagers, InnWorld)
  loadTiledMap(InnTable, InnWorld)
  
  loadNPCS(ArmoryVillagers, ArmoryWorld)
  loadTiledMap(ArmoryTable, ArmoryWorld)
  
  loadTiledMap(HomeTable, HomeWorld)
  
  loadTiledMap(ResidenceTable, ResidenceWorld)
end

function loadTiledMap(location, world)

  local uID = 0

  for rowIndex = 1, #location do
    local row = location[rowIndex]

    for columnIndex = 1, #row do
      local number = row[columnIndex]
      local x, y = (columnIndex - 1 ) * Tileset.x, (rowIndex - 1) * Tileset.y

      if BumpTiles[number] == "s" then
        world:add(uID, x, y, Tileset.x, Tileset.y)
        uID = uID + 1
      end
    end
  end
end

function loadNPCS(villagers, world)

  for key, villager in pairs(villagers) do
    world:add(villager, villager.x, villager.y, VillagerImage:getWidth(), VillagerImage:getHeight())
  end
end

------------------------
---- Love.draw() -------
------------------------

function drawVillage()

  -- Draw the Village tiles
  drawTiledMap(VillageTable)
  
  --  Draw the Villagers
  drawObjects(OutsideVillagers, VillagerImage)
  
  --  Draw the Clouds
  drawObjects(Clouds, CloudImage)
end

function drawInn()

  -- Draw the Inn tiles 
  drawTiledMap(InnTable)  
  
  -- Draw the Villagers
  drawObjects(InnVillagers, VillagerImage)
  end
  
  function drawArmory()
  
  -- Draw the Armory tiles 
  drawTiledMap(ArmoryTable)  
  
  -- Draw the Villagers
  drawObjects(ArmoryVillagers, VillagerImage)
end

function drawHome()

  -- Draw the Home tiles 
  drawTiledMap(HomeTable)  
end

function drawResidence()

  -- Draw the Residence tiles  
  drawTiledMap(ResidenceTable)  
end

function drawMainMenu()

  love.graphics.setNewFont(50)
  love.graphics.print("Main Menu", 265, 100)
  love.graphics.setNewFont("fonts/verdanab.ttf", 14) -- Revert to game font
end

function drawDialogue(villager)

  local villagerMessage = villager.m

  local rectangleX = villager.x + 30
  local rectangleY = villager.y - 19
  local rectangleLineHeight = 18

  local textLineWidth = Font:getWidth(villagerMessage)
  local textLineHeight = 19

  if textLineWidth + rectangleX > GameWidthMax then
    rectangleX = rectangleX - (textLineWidth + VillagerImage:getWidth()) - 3
  end 

  love.graphics.setColor(0,0,0) -- Black background
  love.graphics.rectangle("fill", rectangleX, rectangleY, textLineWidth, rectangleLineHeight) -- Rectangle behind dialogue
  love.graphics.setColor(255,255,255) -- Reset background
  love.graphics.print(villagerMessage, rectangleX, rectangleY) -- Draw dialogue
end  

function drawTiledMap(location)

  for rowIndex = 1, #location do
    local row = location[rowIndex]

    for columnIndex = 1, #row do
      local number = row[columnIndex]
      love.graphics.draw(TilesetImage, Tiles[number], (columnIndex - 1 ) * Tileset.x, (rowIndex - 1) * Tileset.y)
    end
  end  
end  

function drawObjects(objects, image)

  for key, value in pairs(objects) do
    love.graphics.draw(image, value.x, value.y)
  end    
end  
------------------------
---- Love.update() -----
------------------------

function updateCharacter()

  local numCollisions = 0

  local playerFilter = function(item, other)
    return 'touch'
  end

if (love.keyboard.isDown('up') or love.keyboard.isDown('w')) and Character.y > GameHeightMin then

  if Village then Character.x, Character.y, colissions, numCollisions = VillageWorld:move(Character, Character.x, Character.y - 5, playerFilter) end
  if Inn then Character.x, Character.y, colissions, numCollisions = InnWorld:move(Character, Character.x, Character.y - 5, playerFilter) end
  if Armory then Character.x, Character.y, colissions, numCollisions = ArmoryWorld:move(Character, Character.x, Character.y - 5, playerFilter) end
  if Home then Character.x, Character.y, colissions, numCollisions = HomeWorld:move(Character, Character.x, Character.y - 5, playerFilter) end
  if Residence then Character.x, Character.y, colissions, numCollisions = ResidenceWorld:move(Character, Character.x, Character.y - 5, playerFilter) end	
end

if (love.keyboard.isDown('down') or love.keyboard.isDown('s')) and (Character.y + CharacterImage:getHeight()) < GameHeightMax then

  if Village then Character.x, Character.y, colissions, numCollisions = VillageWorld:move(Character, Character.x, Character.y + 5, playerFilter) end
  if Inn then Character.x, Character.y, colissions, numCollisions = InnWorld:move(Character, Character.x, Character.y + 5, playerFilter) end
  if Armory then Character.x, Character.y, colissions, numCollisions = ArmoryWorld:move(Character, Character.x, Character.y + 5, playerFilter) end
  if Home then Character.x, Character.y, colissions, numCollisions = HomeWorld:move(Character, Character.x, Character.y + 5, playerFilter)end
  if Residence then Character.x, Character.y, colissions, numCollisions = ResidenceWorld:move(Character, Character.x, Character.y + 5, playerFilter) end
end

if (love.keyboard.isDown('left') or love.keyboard.isDown('a')) and Character.x > GameWidthMin then

  if Village then Character.x, Character.y, colissions, numCollisions = VillageWorld:move(Character, Character.x - 5, Character.y, playerFilter) end
  if Inn then Character.x, Character.y, colissions, numCollisions = InnWorld:move(Character, Character.x - 5, Character.y, playerFilter) end
  if Armory then Character.x, Character.y, colissions, numCollisions = ArmoryWorld:move(Character, Character.x - 5, Character.y, playerFilter) end
  if Home then Character.x, Character.y, colissions, numCollisions = HomeWorld:move(Character, Character.x - 5, Character.y, playerFilter) end
  if Residence then Character.x, Character.y, colissions, numCollisions = ResidenceWorld:move(Character, Character.x - 5, Character.y, playerFilter) end
end

if (love.keyboard.isDown('right') or love.keyboard.isDown('d')) and (Character.x + CharacterImage:getWidth()) < GameWidthMax then

  if Village then Character.x, Character.y, colissions, numCollisions = VillageWorld:move(Character, Character.x + 5, Character.y, playerFilter) end
  if Inn then Character.x, Character.y, colissions, numCollisions = InnWorld:move(Character, Character.x + 5, Character.y, playerFilter) end
  if Armory then Character.x, Character.y, colissions, numCollisions = ArmoryWorld:move(Character, Character.x + 5, Character.y, playerFilter) end
  if Home then Character.x, Character.y, colissions, numCollisions = HomeWorld:move(Character, Character.x + 5, Character.y, playerFilter) end
  if Residence then Character.x, Character.y, colissions, numCollisions = ResidenceWorld:move(Character, Character.x + 5, Character.y, playerFilter) end
end  


  for i = 1, numCollisions do
    local other = colissions[i].other
  
  if tonumber(other) == nil then -- background tiles are represented by numbers (which we are avoiding)
    if other.isVillager then
      Dialogue = true
      CollidedVillager = other
    end
  end 
end

end

function updateOutsideVillagers()

  -- NPC movement
  local villagerSpeed = 10
  local villager1Direction = (math.random(0,1) * 2) - 1
  local villager2Direction = (math.random(0,1) * 2) - 1


  if Timer > 2 then -- Every 2 seconds a villager moves in a random direction
    local villager1 = OutsideVillagers[1]
    local villager2 = OutsideVillagers[2]
  
    if villager1.x < (GameWidthMin + (VillagerImage:getWidth()) - 5) and villager1Direction == -1 then
      villager1Direction = 1  
    end  
  
    villager1.x, villager1.y = VillageWorld:move(villager1, villager1.x + villagerSpeed * villager1Direction, villager1.y)
  
    villager2.x, villager2.y = VillageWorld:move(villager2, villager2.x, villager2.y + villagerSpeed * villager2Direction)
  
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

function updateInn()

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  InnWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence = false, true, false, false, false
end

function updateArmory()

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  ArmoryWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence = false, false, true, false, false
end

function updateHome()

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  HomeWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence = false, false, false, true, false
end

function updateResidence()

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  ResidenceWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence = false, false, false, false, true
end

function updateFromBuilding()

  if Inn then InnWorld:remove(Character) end
  if Armory then ArmoryWorld:remove(Character) end
  if Home then HomeWorld:remove(Character) end
  if Residence then ResidenceWorld:remove(Character) end

  Village, Inn, Armory, Home, Residence = true, false, false, false, false

  Character.x, Character.y = VillagePosition.x, VillagePosition.y + 10 -- Regain Village position and move outside of boundary check
  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
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

  if Armory then
    ArmoryWorld:update(Character, Character.x, Character.y)

    for key, villager in pairs(ArmoryVillagers) do
      ArmoryWorld:update(villager, villager.x, villager.y)
    end
  end

  if Home then
    HomeWorld:update(Character, Character.x, Character.y)
  end

  if Residence then
    ResidenceWorld:update(Character, Character.x, Character.y)
  end  
end