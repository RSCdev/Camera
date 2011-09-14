display.setStatusBar( display.HiddenStatusBar )

require( "camera" )

local camera = Camera:new()

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

local onUpdate = function( event )
	camera:update( event )
end

Runtime:addEventListener( "enterFrame", onUpdate )