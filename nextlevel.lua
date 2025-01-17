--This scene will also show potential upgrades for the player to use
--for the next levels and will stay persistent through the levels till
--player is defeated. Since there is not a save game that sticks after
--game over.



local composer = require( "composer" )
local scene = composer.newScene()

local widget = require( "widget" )
local myData = require( "mydata" )
local utility = require( "utility" )
 
local nextLevelText
local params

-- Function to handle button events
local function handleButtonEvent( event )

    if ( "ended" == event.phase ) then
        composer.removeScene( "game", false )
        composer.gotoScene( "game", { effect = "crossFade", time = 333 } )
    end
end

--
-- Start the composer event handlers
--
function scene:create( event )
    local sceneGroup = self.view

    params = event.params
        
    myData.settings.currentLevel = myData.settings.currentLevel + 1
    utility.saveTable(myData.settings, "settings.json")
    --
    -- setup a page background, really not that important though composer
    -- crashes out if there isn't a display object in the view.
    --
    local background = display.newRect( 0, 0, 570, 360 )
    background.x = display.contentCenterX
    background.y = display.contentCenterY
    sceneGroup:insert(background)
    --I assume this is the text for the level completion.  The group decided we liked this text better than 'woohoo'.
    local wooHooOptions = { text = "Good job, Cadet!", fontSize = 42, font = native.systemFontBold, align = "center"}

    local wooHooText = display.newText( wooHooOptions )
    wooHooText.x = display.contentCenterX 
    wooHooText.y = 40
    wooHooText:setFillColor( 0 )
    sceneGroup:insert(wooHooText)


    nextLevelText = display.newText("Next Level " .. myData.settings.currentLevel, display.contentCenterX, display.contentCenterY, native.systemFontBold, 48)
    nextLevelText:setFillColor( 0 )
    sceneGroup:insert(nextLevelText)

    -- Create the widget
    local doneButton = widget.newButton({
        id = "button1",
        label = "Next Level",
        width = 100,
        height = 32,
        onEvent = handleButtonEvent
    })
    doneButton.x = display.contentCenterX 
    doneButton.y = display.contentHeight - 40
    sceneGroup:insert( doneButton )
    
    --Store button
    upgradeoptionstext = display.newText("Upgrades" .. myData.settings.currentLevel, display.contentCenterX, display.contentCenterX, display.contentCenterY, native.systemFontBold, 48)
    upgradeoptionstext:setFillColor( 0 )
    sceneGroup:insert(upgradeoptionstext)
    
    -- Create widget
    local doneButton = widget.newButton({
        id = "upgradebutton",
        label = "Upgrades",
        width = 100,
        height = 32,
        onEvent = handleButtonEvent
    })
    doneButton.x = display.contentCenterX
    doneButton.y = display.contentHeight - 40
    sceneGroup:insert( doneButton )

end

function scene:show( event )
    local sceneGroup = self.view

    params = event.params

    if event.phase == "did" then
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    
    if event.phase == "will" then
    end

end

function scene:destroy( event )
    local sceneGroup = self.view
    
end

---------------------------------------------------------------------------------
-- END OF IMPLEMENTATION
---------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
