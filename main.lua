display.setStatusBar( display.HiddenStatusBar )

require( "camera" )

local camera = Camera:new()

-- COMMENT IN THIS FIRST BLOCK TO SEE PARALLAX SCROLLING

--[[
camera:newLayer( "back", 2 )
camera:newLayer( "middle", 1 )
camera:newLayer( "front", 0.5 )

for i = 1, 3, 1 do

	local back = display.newImage( "layer_back.png" )
	back.x = back.contentWidth * i - ( back.contentWidth / 2 )
	camera:addObject( "back", back )
	
	local middle = display.newImage( "layer_middle.png" )
	middle.x = back.x
	camera:addObject( "middle", middle )
	
	local front = display.newImage( "layer_front.png" )
	front.x = back.x
	camera:addObject( "front", front )
	
end

local onMoveRightTransitionComplete
local onMoveLeftTransitionComplete
local moveRight
local moveLeft

moveRight = function()
	camera:transitionTo{ x = -350, time = 5000, onComplete = onMoveRightTransitionComplete }
end

moveLeft = function()
	camera:transitionTo{ x = 0, time = 5000, onComplete = onMoveLeftTransitionComplete }
end

onMoveRightTransitionComplete = function( event )
	moveLeft()
end

onMoveLeftTransitionComplete = function( event )
	moveRight()
end

moveRight()
--]]

-- COMMENT IN THIS SECOND BLOCK TO SEE CAMERA FOCUS

--[[
for i = 1, 3, 1 do

	local back = display.newImage( "layer_back.png" )
	back.x = back.contentWidth * i - ( back.contentWidth / 2 )
	camera:addObject( back )
	
	local middle = display.newImage( "layer_middle.png" )
	middle.x = back.x
	camera:addObject( middle )
	
	local front = display.newImage( "layer_front.png" )
	front.x = back.x
	camera:addObject( front )
	
end

local player = display.newRect( 0, 0, 50, 50 )
camera:addObject( player )
camera:setFocus( player )

local width, height = camera:getContentSize()
camera:setClampingBounds( 0, 0, width, height )

local onUpdate = function( event )
	player.x = player.x + 1
	camera:update( event )
end

Runtime:addEventListener( "enterFrame", onUpdate )
--]]

-- COMMENT IN THIS FIRST BLOCK TO SEE CAMERA DRAGGING

for i = 1, 3, 1 do

	local back = display.newImage( "layer_back.png" )
	back.x = back.contentWidth * i - ( back.contentWidth / 2 )
	camera:addObject( back )
	
	local middle = display.newImage( "layer_middle.png" )
	middle.x = back.x
	camera:addObject( middle )
	
	local front = display.newImage( "layer_front.png" )
	front.x = back.x
	camera:addObject( front )
	
end

local width, height = camera:getContentSize()
camera:setClampingBounds( 0, 0, width, height )

local onTouch = function( event )
	camera:drag( event )
end

Runtime:addEventListener( "touch", onTouch )