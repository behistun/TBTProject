--This is the true level 1 of this game 


--composer stuff
local composer = require("composer")
local cWidth = display.contentCenterX
local cHeight = display.contentCenterY
local dusk = require("Dusk.dusk")

--scene starter
local scene = composer.newScene()


--wrap texture for background setup
display.setDefault("textureWrapX", "repeat")

local background = display.newRect(display.contentCenterX, display.contentCenterY, 6288, 1000)
background.fill = {type = "image", filename = "assets/images/background_1.png" }

local function animateBackground()
    transition.to( background.fill, { time=150000, x=1, delta=true, onComplete=animateBackground } )
end

animateBackground()


--Top Layer of Background
display.setDefault("textureWrapX","repeat")
timer.performWithDelay(100000,1)
local background = display.newRect(100, 100, 1477, 316)
background.fill = {type = "image", filename = "assets/images/planet_extra.png" }

local function animateBackground()
    transition.to( background.fill, { time=60000, x=1, delta=true, onComplete=animateBackground } )
end

animateBackground()
--


--game globals
local level = 1
local resource = 75
local energy = 100
local shipMoveX = 0
local shipMoveY = 0
local ship
local speed = 2.5
local shootbtn
local ultbtn
local enemyArray = {}
local astArray = {}
local enemyNum = 0
local astNum = 0
local gameActive = true
local canFireBullet = true


--global function
local createGame
local createEnemy
local createAsteroid
local shoot = {}
local newGame
local nextLevel
local backgroundMusic
local setGameOver = false 
local removeEnemy
local removeAsteroid

--physics engine init
local physics = require ("physics")
physics.start()
physics.setGravity (0,0)
physics.setDebugErrorsEnabled (enabled) -- physics and collider debugger

--groupings
local enemies = display.newGroup()
local asteroids = display.newGroup()

--sprite sheet
local gameSheetInfo = require("propAssets")
local gameSheet = graphics.newImageSheet("assets/images/propAssets.png", gameSheetInfo:getSheet())
local guiSheetInfo = require("assets.images.ingameguii")
local guiSheet = graphics.newImageSheet("assets/images/ingameguii.png", guiSheetInfo:getSheet())

--audio
local shot = audio.loadSound("assets/sounds/laser.mp3")
--local backgroundsnd = audio.loadStream ("") 

--<PH> background </PH>
dusk.loadMap("level001wip.json")
--dusk.buildMap("level001wip.json")


--<PH> Text Scoring </PH>
alloyNum = display.newText("Alloy: " .. resource, 15, 5, nil, 8)
energyNum = display.newText("Energy: ".. energy, 22, 15, nil, 8)
levelNum = display.newText ("Level: ".. level, 15, 25, nil, 8)
--[[
	the buttons are not scaling b/c the dimensions are static, according to Burton.
	He recommended using this code piece instead.
	-->	display.contentHeight x .75
]]
--<PH> GamePad </PH>
local leftArrow = display.newSprite( guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark04")}})
leftArrow.x = 48
leftArrow.y = 300
leftArrow:scale(0.5, 0.5)
local rightArrow = display.newSprite( guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark05")}})
rightArrow.x = 86
rightArrow.y = 300
rightArrow:scale(0.5, 0.5)
local upArrow = display.newSprite(guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark02")}})
upArrow.x = 67
upArrow.y = 280
upArrow:scale(0.5, 0.5)
local downArrow = display.newSprite(guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark09")}})
downArrow.x = 67
downArrow.y = 320
downArrow:scale(0.5, 0.5)


-- --fire button
shootbtn = display.newSprite( guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark35")}})
shootbtn.x = display.contentWidth - 45
shootbtn.y = display.contentHeight - 55
shootbtn:scale(0.5, 0.5)

ultbtn = display.newSprite( guiSheet, {frames={guiSheetInfo:getFrameIndex("flatDark36")}})
ultbtn.x = display.contentWidth - 70
ultbtn.y = display.contentHeight - 25
ultbtn:scale(0.5, 0.5)


local function stopShip(event)
	if event.phase == "ended" then
			shipMoveX = 0 
	end
	if event.phase == "ended" then
			shipMoveY = 0
	end
end

local function moveShip(event)
	if ship.x >= 50 and ship.x <= display.contentWidth - 50 	then 
		ship.x = ship.x + shipMoveX
	else
		if ship.x < display.contentCenterX then
			ship.x = 50
		else
			ship.x = display.contentWidth - 50
		end
	end
	if ship.y >= 50 and ship.y <= display.contentHeight - 50 then
		ship.y = ship.y + shipMoveY
	else
		if ship.y < display.contentCenterY then
			ship.y = 50
		else
			ship.y = display.contentHeight - 50
		end
	end
end



function leftArrowtouch()
	shipMoveX = -speed
end

function rightArrowtouch()
	shipMoveX = speed
end

function upArrowtouch()
	shipMoveY = -speed
end

function downArrowtouch()
	shipMoveY = speed
end

function shootBtntouch()
	shoot()
end

function ultBtntouch()
	ult()
end

--player ship generated
function createShip()
	--collisions inside function for player
	local playerCollisionFilter = { categoryBits=1, maskBits = 6}
	ship = display.newImage(_G.playerShip)--display.newSprite (gameSheet, {frames={gameSheetInfo:getFrameIndex(_G.playerShip)}})--"RedRacer_skin125")}})
	physics.addBody( ship, {filter = playerCollisionFilter } )
	physics.setScale(10)
	ship.x = 70
	ship.y = display.contentCenterY
	ship.myName = "ship"
	ship:scale(0.5,0.5)
	
end

--player fire mechanism
function shoot(tap, event)
	if(canFireBullet == true) then
	--bullet collider
		local bulletCollisionFilter = {categoryBits = 8, maskBits = 6}
		local bullet = display.newSprite( gameSheet , {frames={gameSheetInfo:getFrameIndex("RedRacer_genericbullet25")}})
		physics.addBody(bullet, {"static", filter = bulletCollisionFilter})
		bullet.x = ship.x + 40
		bullet.y = ship.y 
		bullet.gravityScale = 0
		bullet.name = "bullet"
		bullet.isBullet = true
		
		canFireBullet = false
		audio.play(shot)
		
		bullet:scale(0.5,0.5)
		
		transition.to (bullet, {time = 1000, x  =1000, y = ship.y, 
			onComplete = function(self) self.parent:remove(self); self = nil;
			end
			})
	else
		return
	end
		local function enableBulletFire()
			canFireBullet = true
		end
		timer.performWithDelay(300, enableBulletFire, 1)
end

function ult(tap, event)

	local ultCollisionFilter = {categoryBits = 16, maskBits = 6}
	local ult = display.newSprite( gameSheet , {frames={gameSheetInfo:getFrameIndex("RedRacer_genericbullet25")}})
	physics.addBody(ult, {"static", filter = ultCollisionFilter})
	ult.x = ship.x + 40
	ult.y = ship.y
	ult.gravityScale = 0
	ult.name = "ultimate"
	ult.isBullet = true
	
	audio.play(shot)  --<PH>
	
	ult:scale(0.5, 0.5)
	
	transition.to (ult, {time = 1000, x = 1000, y = ship.y,
		onComplete = function(self) self.parent:remove(self); self = nil;
		end
		})
	print(energy -75)
	return
	
	timer.performWithDelay(300, 1)
end
--things to still code into here
--enemy, asteroid, level progression
--on level progression the game will reset the scene to 0 increase the level text by 1 and change the spawns based on code




function startGame()
createShip()


shootbtn:addEventListener("tap", shootBtntouch)
ultbtn:addEventListener("tap", ultBtntouch)
rightArrow:addEventListener ("touch", rightArrowtouch)
leftArrow:addEventListener("touch", leftArrowtouch)
upArrow:addEventListener("touch", upArrowtouch)
downArrow:addEventListener("touch", downArrowtouch)
Runtime:addEventListener("enterFrame", moveShip)
Runtime:addEventListener("touch", stopShip)






end

startGame()
return scene