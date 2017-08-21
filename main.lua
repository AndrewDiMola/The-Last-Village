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
  
    -- Starting location
    if Village then drawVillage() end
    
	-- Buildings inside Village
	if Inn then drawInn() end
    if Armory then drawArmory() end
    if Home then drawHome() end
    if Residence then drawResidence() end
	
	-- Outside Village
	if Forest then drawForest() end

	-- NPC dialogue
    if Dialogue then drawDialogue(CollidedVillager) end

    -- Always draw the Character	 
    love.graphics.draw(CharacterImage, Character.x, Character.y)	 
  
    -- Reset the volume outside the Main Menu
    TownTheme:setVolume(1)

  else -- Inside the Main Menu

    drawMainMenu()
    
	-- DEBUG
	-- love.graphics.print(Character.x, 50, 100)
	-- love.graphics.print(Character.y, 50, 125)
	
    -- Lower the volume inside the Main Menu
    TownTheme:setVolume(0.3)
	
  end
end

function love.update(dt)
	Timer = Timer + dt -- Used in NPC movement

	updateCharacter()	

	if Village then
		updateOutsideVillagers()
		updateClouds(dt)
		updateSunAndMoon()
	end
  
	if Inn then
		updateInnVillagers()
	end

	if Forest then
		updateForestMonsters()
	end
  
  -- Reserved space for future movement updates in other locations
 
  updateBumpWorlds()

  -- Get rid of the below magic numbers
  
  -- Door outside of the Inn
  if Village and (Character.x > 380 and Character.x < 390) and (Character.y > 320 and Character.y < 330) then
    updateInn()
  end
  
  -- Door outside of the Armory
  if Village and (Character.x > 123 and Character.x < 133) and (Character.y > 128 and Character.y < 138) then
    updateArmory()
  end
  
  -- Door outside of the Home
  if Village and (Character.x > 636 and Character.x < 646) and (Character.y > 128 and Character.y < 138) then
    updateHome()
  end
  
  -- Door outside of the Residence
  if Village and (Character.x > 732 and Character.x < 742) and (Character.y > 512 and Character.y < 522) then
    updateResidence()
  end  
  
    -- Pathway to Forest
  if Village and Character.y > 560 then
    updateToForest()
  end  
  
  -- Pathway from Forest
  if Forest and Character.y < 5 then
	updateFromForest()
  end
  
  -- Door inside a Village building
  if (not Village and not Forest) and (Character.x > 380 and Character.x < 390) and (Character.y > 560 and Character.y < 570) then
    updateFromBuilding()
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
  
  if key == 'lshift' then
	TownTheme:pause()
	BattleTheme:pause()
  end
  
  if key == 'rshift' and Village == true then
	TownTheme:play()
  end
  if key == 'rshift' and Forest == true then
	BattleTheme:play()
  end
  
end

----------------------
-- Helper Functions --
----------------------

------------------------
---- Love.load() -------
------------------------
function loadGameSettings()

  Village, Inn, Menu, Armory, Home, Residence, Village = true, false, false, false, false, false, false
  Dialogue = false

  Direction = 1

  -- I completely forget why I'm starting at 1 -> (Width - 1)
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
  ForestWorld = bump.newWorld(50)
end

function loadImages()

  CharacterImage = love.graphics.newImage("images/characters/character.png")
  VillagerImage = love.graphics.newImage("images/characters/villager.png")
  MonsterImage = love.graphics.newImage("images/characters/monster.png")
  SunImage = love.graphics.newImage("images/background/scenery/sun.png")
  MoonImage = love.graphics.newImage("images/background/scenery/moon.png")
  CloudImage = love.graphics.newImage("images/background/scenery/cloud.png")
  PointerImage = love.graphics.newImage("images/background/menu/pointer.png")
  TilesetImage = love.graphics.newImage("images/tileset.png")
end

function loadTileset()

  Tileset = {x = 32, y = 32, w = TilesetImage:getWidth(), h = TilesetImage:getHeight()} -- Each tile is 32x32
  
  -- Tiles
  QuadInfo = {
    {0, 0, "t"},      -- 1 = grass
    {32, 0, "t"},     -- 2 = house / floor
    {0, 32, "t"},     -- 3 = road
    {32, 32, "s"},    -- 4 = sky
    {64, 0, "t"},     -- 5 = door (black)
    {64, 32, "t"},    -- 6 = carpet (orange)
    {96, 0, "s"},     -- 7 = inn sign 
    {96, 32, "s"},    -- 8 = white (bed pillow)
    {128, 0, "s"},    -- 9 = sword sign 
    {128, 32, "s"},   -- 10 = shield sign
    {160, 0, "s"},    -- 11 = house-top
    {160, 32, "s"},   -- 12 = house-bottom
    {192, 0, "s"},    -- 13 = house-left
    {192, 32, "s"},   -- 14 = house-right
    {224, 0, "s"},    -- 15 = house-top-left
    {224, 32, "s"},   -- 16 = house-bottom-left
    {256, 0, "s"},    -- 17 = house-top-right
    {256, 32, "s"},   -- 18 = house-bottom-right
    {288, 0, "s"},    -- 19 = character-home sign
    {288, 32, "s"},   -- 20 = villager-home sign
    {0, 64, "s"},     -- 21 = bed-left
    {32, 64, "s"},    -- 22 = bed-right
    {64, 64, "t"},    -- 23 = road-horizontal
    {96, 64, "t"},    -- 24 = road-vertical
    {128, 64, "t"},   -- 25 = road-left
    {160, 64, "t"},   -- 26 = road-top
    {192, 64, "t"},   -- 27 = road-right
    {224, 64, "t"},   -- 28 = road-bottom
    {256, 64, "t"},   -- 29 = road-top-left
    {288, 64, "t"},   -- 30 = road-top-right
    {0, 96, "t"},     -- 31 = road-bottom-left
    {32, 96, "t"},    -- 32 = road-bottom-right
    {64, 96, "t"},    -- 33 = grass-top
    {96, 96, "s"},    -- 34 = wall (black)
    {128, 96, "t"},   -- 35 = sunflower-center
    {160, 96, "t"},   -- 36 = sunflower-right
    {192, 96, "t"},   -- 37 = sunflower-left
    {224, 96, "t"},   -- 38 = wildflower-center
    {256, 96, "t"},   -- 39 = wildflower-right
    {288, 96, "t"},   -- 40 = wildflower-left
    {0, 128, "t"},    -- 41 = stairs
    {32, 128, "t"},   -- 42 = carpet-left
    {64, 128, "t"},   -- 43 = carpet-top
    {96, 128, "t"},   -- 44 = carpet-left
    {128, 128, "t"},  -- 45 = carpet-top-left
    {160, 128, "t"},  -- 46 = carpet-top-right
    {192, 128, "s"},  -- 47 = bookshelf
    {224, 128, "t"},  -- 48 = grass-left
    {256, 128, "t"},  -- 49 = grass-right
    {288, 128, "t"},  -- 50 = grass-bottom
    {0, 160, "t"},    -- 51 = grass-top-left
    {32, 160, "t"},   -- 52 = grass-bottom-right
    {64, 160, "t"}    -- 53 = bridge
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
  BattleTheme = love.audio.newSource("soundtrack/DunkirkBattle.mp3")


  TownTheme:play()
  TownTheme:setLooping(true)
end

function loadCharacter()

  Character = {x = 386, y = 560, sx, sy, isCharacter = true} -- current and starting position
  Character.sx, Character.sy = Character.x, Character.y
end

-- split into load*Screen*
function loadVillage()

  -- NPCs: Outside
  local villager1 = {x = 50, y = 250, sx, sy, m = "Hooligan! Leave me to my pacing!!!", isVillager = true}
  villager1.sx, villager1.sy = villager1.x, villager1.y
  local villager2 = {x = 440, y = 85, sx, sy, m = "The moon hasn't looked the same lately...", isVillager = true}
  villager2.sx, villager2.sy = villager2.x, villager2.y
  local villager3 = {x = 540, y = 375, sx, sy, m = "Welcome to The Last Village.", isVillager = true}
  villager3.sx, villager3.sy = villager3.x, villager3.y

  OutsideVillagers = {villager1, villager2, villager3}
  
  -- NPCs: Inn
  local villager1 = {x = 514, y = 514, sx, sy, m = "50G for the night? Why?", isVillager = true}
  villager1.sx, villager1.sy = villager1.x, villager1.y
  local villager2 = {x = 674, y = 68, sx, sy, m = "Members only. Beat it.", isVillager = true}
  villager2.sx, villager2.sy = villager2.x, villager2.y
  local villager3 = {x = 400, y = 275, sx, sy, m = "RAWR! I'm a monster!!!", isVillager = true}
  villager3.sx, villager3.sy = villager3.x, villager3.y
  local villager4 = {x = 650, y = 275, sx, sy, m = "GIVE BACK THE PRINCESS!!!", isVillager = true}
  villager4.sx, villager4.sy = villager4.x, villager4.y
  local villager5 = {x = 525, y = 200, m = "I love them both...but sometimes I just want a break", isVillager = true}
  villager5.sx, villager5.sy = villager5.x, villager5.y

  InnVillagers = {villager1, villager2, villager3, villager4, villager5}
  
  -- NPCS: Armory
  local villager1 = {x = 194, y = 227, sx, sy, m = "Welcome to the Weapon Shop...Hey, that was pretty good, right?", isVillager = true}
  villager1.sx, villager1.sy = villager1.x, villager1.y
  local villager2 = {x = 578, y = 227, sx, sy, m = "DAMNIT. I hate standing here. We haven't sold anything in years!", isVillager = true}
  villager2.sx, villager2.sy = villager2.x, villager2.y
  local villager3 = {x = 388, y = 300, sx, sy, m = "The armory is a family heirloom. I'll never sell it.", isVillager = true}
  villager3.sx, villager3.sy = villager3.x, villager3.y

  ArmoryVillagers = {villager1, villager2, villager3}
  
  -- Villager you're speaking with
  CollidedVillager = {}
  
  -- Forest Monsters and Villager
  local monster1 = {x = 194, y = 427, sx, sy, m = "RAWR!!!", isMonster = true}
  monster1.sx, monster1.sy = monster1.x, monster1.y
  local monster2 = {x = 578, y = 327, sx, sy, m = "GROWL!!!", isMonster = true}
  monster2.sx, monster2.sy = monster2.x, monster2.y
  local monster3 = {x = 388, y = 500, sx, sy, m = "HISS!!!", isMonster = true}
  monster3.sx, monster3.sy = monster3.x, monster3.y
  local villager1 = {x = 386, y = 230, sx, sy, m = "You can't leave without a weapon!", isVillager = true}
  villager1.sx, villager1.sy = villager1.x, villager1.y
  
  ForestMonsters = {monster1, monster2, monster3}
  ForestVillagers = {villager1}
  
  -- Clouds: Outside
  local cloud1 = {x = -25, y = 15}
  local cloud2 = {x = 175, y = 15}
  local cloud3 = {x = 375, y = 15}
  local cloud4 = {x = 575, y = 15}
  Clouds = {cloud1, cloud2, cloud3, cloud4}

  -- Sun and Moon
  Sun = {x = 75, y = 65, sx, sy, xChange = 0.5, yChange = -0.1}
  Sun.sx, Sun.sy = Sun.x, Sun.y

  Moon = {x = GameWidthMax - Sun.x, y = Sun.y, sx, sy}
  Moon.sx, Moon.sy = Moon.x, Moon.y
  
  -- Move maps
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
    {34, 2, 2, 2, 2, 2, 2, 2,34,47,47,47,47,47,47,47,47,47,47,34,34,41,34,34,34 },
    {34, 2, 2,21,22, 8, 2, 2,34,47,47,47,47,47,47,47,47,47,47,34,34, 2,34,34,34 },
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
    {34, 2, 2,21,22, 8, 2, 2,34, 2, 2,45,43,46, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2,42, 6,44, 2,34, 2, 2, 2, 2, 2, 2, 2, 2,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 } 
  }
  
  ArmoryTable = {
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34,47,47,47,47,47,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34,47,47,47,47,47,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2,34, 2, 2, 2, 2, 2, 2, 2,34,34 },	
    {34,34,34,34,34,34, 2,34,34,34, 2, 2, 2, 2, 2,34,34,34, 2,34,34,34,34,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,10, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 9, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,10, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 9, 2, 2, 2, 2, 2, 2, 2,45,43,46, 2, 2, 2, 2, 2, 2, 2,10, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2,42, 6,44, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
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
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2,45,43,46, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2,42, 6,44, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
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
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2,45,43,46, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34, 2, 2, 2, 2, 2, 2, 2, 2, 2,42, 6,44, 2, 2, 2, 2, 2, 2, 2, 2, 2,34,34 },
    {34,34,34,34,34,34,34,34,34,34,34,34, 6,34,34,34,34,34,34,34,34,34,34,34,34 }
  }  
  
  ForestTable = { 
    {36,35,35,35,35,35,35,35,35,35,35,37,24,39,38,38,38,38,38,38,38,38,38,38,40 },
    {36,35,35,35,35,35,35,35,35,35,35,37,24,39,38,38,38,38,38,38,38,38,38,38,40 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{23,23,23,23,23,23,23,23,23,23,23,23, 3,23,23,23,23,23,23,23,23,23,23,23,23 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,24, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1,50,50,50,50,50,24,50,50,50,50,50,50,50,50,50,50,50,50 },
	{ 1, 1, 1, 1, 1, 1,49, 4, 4, 4, 4, 4,53, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 },
	{50,50,50,50,50,50,52, 4, 4, 4, 4, 4,53, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4, 4 },
	{ 4, 4, 4, 4, 4, 4, 4, 4, 4,51,33,33, 1,33,33,33,33,33,33,33,33,33,33,33,33 },
    { 4, 4, 4, 4, 4, 4, 4, 4, 4,48, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{33,33,33,33,33,33,33,33,33, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },	
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
    { 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 }
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
  
  loadNPCS(ForestVillagers, ForestWorld)
  loadNPCS(ForestMonsters, ForestWorld)
  loadTiledMap(ForestTable, ForestWorld)

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

function drawForest()

  -- Draw the Forest tiles  
  drawTiledMap(ForestTable)  
  
  -- Draw the villagers and monsters
  drawObjects(ForestVillagers, VillagerImage)
  drawObjects(ForestMonsters, MonsterImage)
end

function drawMainMenu()

  love.graphics.draw(PointerImage, 300, 300)
  love.graphics.setNewFont(50)
  love.graphics.print("Main Menu", 265, 100)
  love.graphics.setNewFont(25)
  love.graphics.print("Inventory", 350, 300)
  love.graphics.print("Sound", 350, 350)
  love.graphics.setNewFont("fonts/verdanab.ttf", 14) -- Revert to game font
end

function drawDialogue(villager)

  local villagerMessage = villager.m

  local rectangleX = villager.x + 30
  local rectangleY = villager.y - 19
  local rectangleLineHeight = 18

  local textLineWidth = Font:getWidth(villagerMessage) + 10
  local textLineHeight = 19

  if textLineWidth + rectangleX > GameWidthMax then
    rectangleX = rectangleX - (textLineWidth + VillagerImage:getWidth()) - 3
  end 

  
  love.graphics.setColor(255,255,255) -- White border
  love.graphics.rectangle("line", rectangleX, rectangleY, textLineWidth, rectangleLineHeight) -- Rectangle behind dialog
  
  love.graphics.setColor(0,0,0) -- Black background
  love.graphics.rectangle("fill", rectangleX, rectangleY, textLineWidth, rectangleLineHeight)
  
  love.graphics.setColor(255,255,255) -- White text
  love.graphics.print(villagerMessage, rectangleX + 5, rectangleY) -- Draw dialog
end  

function removeDialogue(villager)

  local villagerMessage = villager.m

  local rectangleX = villager.x + 30
  local rectangleY = villager.y - 19
  local rectangleLineHeight = 18

  local textLineWidth = Font:getWidth(villagerMessage) + 10
  local textLineHeight = 19

  if textLineWidth + rectangleX > GameWidthMax then
    rectangleX = rectangleX - (textLineWidth + VillagerImage:getWidth()) - 3
  end 

  
  love.graphics.setColor(255,255,255) -- White border
  love.graphics.rectangle("line", rectangleX, rectangleY, textLineWidth, rectangleLineHeight) -- Rectangle behind dialog
  
  love.graphics.setColor(0,0,0) -- Black background
  love.graphics.rectangle("fill", rectangleX, rectangleY, textLineWidth, rectangleLineHeight)
  
  love.graphics.setColor(255,255,255) -- White text
  love.graphics.print(villagerMessage, rectangleX + 5, rectangleY) -- Draw dialog
end  

function drawTiledMap(location)

  for rowIndex = 1, #location do
    local row = location[rowIndex]

    for columnIndex = 1, #row do
      local number = row[columnIndex]
          
        if Village and rowIndex < 3 then
          drawSunAndMoon()
        end   

        love.graphics.draw(TilesetImage, Tiles[number], (columnIndex - 1 ) * Tileset.x, (rowIndex - 1) * Tileset.y)
    end
  end  
end  

function drawObjects(objects, image)

  for key, value in pairs(objects) do
    love.graphics.draw(image, value.x, value.y)
  end    
end  

function drawSunAndMoon()
  
  love.graphics.draw(SunImage, Sun.x, Sun.y)
  love.graphics.draw(MoonImage, Moon.x, Moon.y)
end
------------------------
---- Love.update() -----
------------------------

function updateCharacter()

  local numCollisions = 0
  local playerMovementIncrement = 5
  
  local playerFilter = function(item, other)
    return 'touch'
  end

  if not Menu then

	  -- Below is gross and should be moved to keypressed
	  if (love.keyboard.isDown('up') or love.keyboard.isDown('w')) and Character.y > GameHeightMin then

		if Village then Character.x, Character.y, collissions, numCollisions = VillageWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end
		if Inn then Character.x, Character.y, collissions, numCollisions = InnWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end
		if Armory then Character.x, Character.y, collissions, numCollisions = ArmoryWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end
		if Home then Character.x, Character.y, collissions, numCollisions = HomeWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end
		if Residence then Character.x, Character.y, collissions, numCollisions = ResidenceWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end	 
		if Forest then Character.x, Character.y, collissions, numCollisions = ForestWorld:move(Character, Character.x, Character.y - playerMovementIncrement, playerFilter) end	 
		
	  end

	  if (love.keyboard.isDown('down') or love.keyboard.isDown('s')) and (Character.y + CharacterImage:getHeight()) < GameHeightMax then

		if Village then Character.x, Character.y, collissions, numCollisions = VillageWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter) end
		if Inn then Character.x, Character.y, collissions, numCollisions = InnWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter) end
		if Armory then Character.x, Character.y, collissions, numCollisions = ArmoryWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter) end
		if Home then Character.x, Character.y, collissions, numCollisions = HomeWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter)end
		if Residence then Character.x, Character.y, collissions, numCollisions = ResidenceWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter) end
		if Forest then Character.x, Character.y, collissions, numCollisions = ForestWorld:move(Character, Character.x, Character.y + playerMovementIncrement, playerFilter) end	 
	  end

	  if (love.keyboard.isDown('left') or love.keyboard.isDown('a')) and Character.x > GameWidthMin then

		if Village then Character.x, Character.y, collissions, numCollisions = VillageWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end
		if Inn then Character.x, Character.y, collissions, numCollisions = InnWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end
		if Armory then Character.x, Character.y, collissions, numCollisions = ArmoryWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end
		if Home then Character.x, Character.y, collissions, numCollisions = HomeWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end
		if Residence then Character.x, Character.y, collissions, numCollisions = ResidenceWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end
		if Forest then Character.x, Character.y, collissions, numCollisions = ForestWorld:move(Character, Character.x - playerMovementIncrement, Character.y, playerFilter) end	 
	  end

	  if (love.keyboard.isDown('right') or love.keyboard.isDown('d')) and (Character.x + CharacterImage:getWidth()) < GameWidthMax then

		if Village then Character.x, Character.y, collissions, numCollisions = VillageWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end
		if Inn then Character.x, Character.y, collissions, numCollisions = InnWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end
		if Armory then Character.x, Character.y, collissions, numCollisions = ArmoryWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end
		if Home then Character.x, Character.y, collissions, numCollisions = HomeWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end
		if Residence then Character.x, Character.y, collissions, numCollisions = ResidenceWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end
		if Forest then Character.x, Character.y, collissions, numCollisions = ForestWorld:move(Character, Character.x + playerMovementIncrement, Character.y, playerFilter) end	 
	  end  
  
  end
  

  for i = 1, numCollisions do
    local other = collissions[i].other
  
  if tonumber(other) == nil then -- background tiles are represented by numbers (which we are avoiding)
    if other.isVillager or other.isMonster then
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

function updateInnVillagers()

    local villagerFilter = function(item, other)
      return 'touch'
    end

    local villager3 = InnVillagers[3]
    local villager4 = InnVillagers[4]
    local numCollisions = 0

    if villager3.x < villager3.sx or villager4.x > villager4.sx then
      Direction = 1
    end
  
    villager3.x, villager3.y, collissions, numCollisions = InnWorld:move(villager3, villager3.x + (5 * Direction), villager3.y, villagerFilter)
    villager4.x, villager4.y, collissions, numCollisions = InnWorld:move(villager4, villager4.x - (5 * Direction), villager4.y, villagerFilter)
  
    for i = 1, numCollisions do
      local item = collissions[i].item
      local other = collissions[i].other
  
      if other.isVillager then
        Direction = Direction * -1
      end 
    end
end

function updateForestMonsters()
	
	-- Monster movement
	local monsterSpeed = 10
	local monster1Direction = (math.random(0,1) * 2) - 1
	local monster2Direction = (math.random(0,1) * 2) - 1
	local monster3Direction = (math.random(0,1) * 2) - 1
	
	
	local monster1 = ForestMonsters[1]
	local monster2 = ForestMonsters[2]
	local monster3 = ForestMonsters[3]

	if Timer > 2 then
		monster1.x, monster1.y = ForestWorld:move(monster1, monster1.x + monsterSpeed * monster1Direction, monster1.y)
		monster2.x, monster2.y = ForestWorld:move(monster2, monster2.x, monster2.y + monsterSpeed * monster2Direction)
		monster3.x, monster3.y = ForestWorld:move(monster3, monster3.x + monsterSpeed * monster3Direction, monster3.y)
		
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

-- No updateVillage? Also. Abstract city.
function updateInn()

  Dialogue = false -- Close out any dialogue from the previous screen

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  InnWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence, Forest = false, true, false, false, false, false
end

function updateArmory()

  Dialogue = false -- Close out any dialogue from the previous screen

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  ArmoryWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence, Forest = false, false, true, false, false, false
end

function updateHome()

  Dialogue = false -- Close out any dialogue from the previous screen

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  HomeWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence, Forest = false, false, false, true, false, false
end

function updateResidence()

  Dialogue = false -- Close out any dialogue from the previous screen

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.x, Character.y = Character.sx, Character.sy -- Move the Character to the bottom of the screen
  
  VillageWorld:remove(Character)
  ResidenceWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence, Forest = false, false, false, false, true, false
end

function updateToForest()

  Dialogue = false -- Close out any dialogue from the previous screen

  TownTheme:stop()
  BattleTheme:play()
  BattleTheme:setLooping(true)

  VillagePosition = {x = Character.x, y = Character.y} -- Preserve Village position
  Character.y = (GameHeightMax - Character.sy) -- Move the Character to the top of the screen
  
  VillageWorld:remove(Character)
  ForestWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
  
  Village, Inn, Armory, Home, Residence, Forest = false, false, false, false, false, true
  
  resetVillagers(ForestMonsters)
end

function updateFromForest()

  Dialogue = false -- Close out any dialogue from the previous screen

  BattleTheme:stop()
  TownTheme:play()

  Character.y = GameHeightMax - 50 -- Move Character to the bottom of the screen

  ForestWorld:remove(Character)
  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())

  Village, Inn, Armory, Home, Residence, Forest = true, false, false, false, false, false
  
  resetVillagers(OutsideVillagers)
end

function updateFromBuilding()

  Dialogue = false -- Close out any dialogue from the previous screen

  if Inn then 
    InnWorld:remove(Character) 
    resetVillagers(InnVillagers) 
  end

  if Armory then ArmoryWorld:remove(Character) end
  if Home then HomeWorld:remove(Character) end
  if Residence then ResidenceWorld:remove(Character) end

  resetVillagers(OutsideVillagers)

  Village, Inn, Armory, Home, Residence, Forest = true, false, false, false, false, false

  Character.x, Character.y = VillagePosition.x, VillagePosition.y + 10 -- Regain Village position and move outside of boundary check
  VillageWorld:add(Character, Character.x, Character.y, CharacterImage:getWidth(), CharacterImage:getHeight())
end

function resetVillagers(villagers)

  for key, villager in pairs(villagers) do
    villager.x = villager.sx
    villager.y = villager.sy
  end
end

function updateSunAndMoon()

    if (Sun.y < GameHeightMin) then Sun.yChange = -(Sun.yChange) end
    if Sun.x > (GameWidthMax - Sun.sx) then Sun.xChange = -(Sun.xChange) end
    if Sun.y > (2 * Sun.sy) then Sun.yChange = -(Sun.yChange) end
    if Sun.x < Sun.sx then Sun.xChange = -(Sun.xChange) end

    Sun.x, Sun.y = Sun.x + Sun.xChange, Sun.y + Sun.yChange
    Moon.x, Moon.y = Moon.x - Sun.xChange, Moon.y - Sun.yChange -- Moon is a reflection of the Sun
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
  
  if Forest then
    ForestWorld:update(Character, Character.x, Character.y)
	
	for key, monster in pairs(ForestMonsters) do
      ForestWorld:update(monster, monster.x, monster.y)
    end
	
  end  
end