Camera = {}
Camera_mt = { __index = Camera }

local abs = math.abs
local floor = math.floor

--- Create a new instance of a Camera object.
-- @return The newly created Camera instance.
function Camera:new()
	
	local self = {}

	setmetatable( self, Camera_mt )
	
	self._view = display.newGroup()
	self._layers = {}
	
	return self
	
end

--- Adds an object to the camera.
-- @param layer The name of the layer to add the object to. Optional.
-- @param object The object to add.
function Camera:addObject( layer, object )
	
	if type( layer ) == "string" and type( object ) == "table" then
		
		if self._layers[ layer ] then
			self._layers[ layer ]._view:insert( object )
		else
			print( "Camera: Layer not found - " .. layer )
		end
		
	elseif type( layer ) == "table" then
		self._view:insert( layer )
	end
	
end

--- Removes an object from the camera.
-- @param layer The name of the layer to remove the object from. Only required if it was added to a specific layer.
-- @param object The object to remove.
function Camera:removeObject( layer, object )

	if type( layer ) == "string" and type( object ) == "table" then
		
		if self._layers[ layer ] then
			self._layers[ layer ]._view:remove( object )
		else
			print( "Camera: Layer not found - " .. layer )
		end
		
	elseif type( layer ) == "table" then
		self._view:remove( layer )
	end

end

--- Create a new layer on the camera.
-- @param name
-- @param scale
function Camera:newLayer( name, scale )
	
	self._layers[ name ] = 
	{ 
		_view = display.newGroup(), 
		_scale = scale 
	}
	
	self:getView():insert( self._layers[ name ]._view )
	
end

--- Moves the camera.
-- @param x
-- @param y
function Camera:move( dx, dy )
	self._view.x = self._view.x + ( dx or 0 )
	self._view.y = self._view.y + ( dy or 0 )
end

--- Scales the camera.
-- @param sx
-- @param sy
function Camera:scale( sx, sy )
	sx = sx or 1
	self._view.xScale = self._view.xScale * sx
	self._view.yScale = self._view.yScale * ( sy or sx )
end

--- Rotates the camera.
-- @param dr The amount to rotate by in degrees.
function Camera:rotate( dr )
	self._view.rotation = self._view.rotation + dr
end

--- Shows all objects in the camera.
function Camera:show()
	self._view.isVisible = true
end

--- Hides all objects in the camera.
function Camera:hide()
	self._view.isVisible = false
end

--- Toggles the visibility of the camera.
function Camera:toggleVisibility()
	self._view.isVisible = not self._view.isVisible
end

--- Gets a layer on the camera.
-- @param name The name of the layer.
function Camera:getLayer( name )
	return self._layers[ name ]
end

--- Shows all objects in a layer.
-- @param name The name of the layer.
function Camera:showLayer( name )
	if self:getLayer( name ) then
		self:getLayer( name )._view.isVisible = true
	end
end

--- Hides all objects in a layer.
-- @param name The name of the layer.
function Camera:hideLayer( name )
	if self:getLayer( name ) then
		self:getLayer( name )._view.isVisible = false
	end
end

--- Toggles the visibility of a layer.
-- @param name The name of the layer.
function Camera:toggleVisibility( name )
	if self:getLayer( name ) then
		self:getLayer( name )._view.isVisible = not self:getLayer( name )._view.isVisible
	end
end

--- Gets the cameras view group.
-- @return The cameras view.
function Camera:getView()
	return self._view
end

--- Clamps a position to within bounds.
-- @param x The X position to clamp.
-- @param y The Y position to clamp.
-- @param bounds The bounding box for the clamping. A table with x, y, width and height. X and y are top left corner.
-- @return The clamped X position.
-- @return The clamped Y position.
function Camera:clampPosition( x, y, bounds )
	
	if bounds then
	
		if not bounds.offset then
			bounds.offset = { x = 0, y = 0 }
		end
	
		if x > bounds.x then
			x = bounds.x
		elseif abs( x ) > ( bounds.width - bounds.offset.x ) - display.contentWidth then
			x = - ( ( bounds.width - bounds.offset.x ) - display.contentWidth ) 
		end

		if y > bounds.y then
			y = bounds.y
		elseif abs( y ) > ( bounds.height - bounds.offset.y ) - display.contentHeight then
			y = - ( ( bounds.height - bounds.offset.y ) - display.contentHeight )
		end
		
	end
	
	return x, y
	
end

--- Calculates the viewpoint to use when setting the camera position. Called automatically, nothing to see here.
-- @param x The x position for the camera.
-- @param y The y position for the camera.
function Camera:calculateViewpoint( x, y )

	local group = self:getView()
	
	local xPos = x or ( group.x + ( group.width * 0.5 ) ) -- Don't like this
	local yPos = y or ( group.y + ( group.height * 0.5 ) ) -- Don't like this

	local actualPosition = { x = xPos, y = yPos }
	local centreOfView = { x = display.contentWidth * 0.5 , y = display.contentHeight * 0.5 }
	
	local viewPoint = { x = centreOfView.x - actualPosition.x, y = centreOfView.y - actualPosition.y }
         
	return viewPoint
	
end

--- Sets the position of the camera.
-- @param x The new x position for the camera.
-- @param y The new y position for the camera.
function Camera:setPosition( x, y )

	local viewPoint = self:calculateViewpoint( x, y )
	
	self:getView().x = floor( viewPoint.x )
	self:getView().y = floor( viewPoint.y )
	
	if self._bounds then
		self:getView().x, self:getView().y = self:clampPosition( self:getView().x, self:getView().y, self._bounds )
	end
	
end

--- Gets the position of the camera.
-- @return The x and y positions.
function Camera:getPosition()
	return self:getView().x, self:getView().y
end

--- Sets the scale of the camera.
-- @param x The new x scale for the camera.
-- @param y The new y scale for the camera.
function Camera:setScale( x, y )
	self:getView().xScale = x
	self:getView().yScale = y
end

--- Gets the scale of the camera.
-- @return The x and y scale amounts.
function Camera:getScale()
	return self:getView().xScale, self:getView().yScale
end

--- Sets the rotation of the camera.
-- @param angle The new angle for the camera.
function Camera:setRotation( angle )
	self:getView().rotation = angle
end

--- Gets the rotation of the camera.
-- @return The rotation in degrees.
function Camera:getRotation()
	return self:getView().rotation
end

--- Converts a screen position to a world position.
-- @param x The screen X position.
-- @param y The screen Y position.
-- @param centred If true the position will be offset to return it as if it is the centre of the screen.
-- @return The converted x and y positions.
function Camera:convertScreenToWorldPosition( x, y, centred )

	local posX, posY = self:getPosition()	
	local scaleX, scaleY = self:getScale()
	
	local newX, newY = -x * scaleX + posX, -y * scaleY + posY
	
	if centred then
		newX = newX + display.contentWidth / 2
		newY = newY + display.contentHeight / 2
	end
	
	return newX, newY
	
end

--- Updates the position of all layers if using parallax.
function Camera:updateParallaxPositions()
	
	local x, y = self:getPosition()

	table.sort( self._layers, function( a, b ) return a._scale < b._scale end )
	
	for _, v in pairs( self._layers ) do
		v._view.x = x * v._scale
		v._view.y = y * v._scale
	end
	
end

--- Updates the camera.
-- @param event enterFrame event table.
function Camera:update( event )

	if self._focus and self._focus.object then
		self:setPosition( self._focus.object.x + self._focus.offset.x, self._focus.object.y + self._focus.offset.y )
	end
	self:updateParallaxPositions() 
	
end

--- Sets the focus of the camera. When updated the camera will follow it.
-- @param event enterFrame event table.
function Camera:setFocus( object, offset )
	self._focus = 
	{
		object = object,
		offset = offset or { x = 0, y = 0 }
	}
end

--- Transitions the camera.
-- @param transitionParams A table containing all the data you would usually use for a transition.
function Camera:transitionTo( transitionParams )

	if self._transition then
		transition.cancel( self._transition )
		self._transition = nil
	end

	self._transition = transition.to( self:getView(), transitionParams )
	
	return self._transition
	
end

function Camera:drag( event )
	
	if self._transition then
		transition.cancel( self._transition )
		self._transition = nil
	end
	
	local view = self:getView()
	
	if event.phase == "began" then

		view._touchPosition = {}
    	view._touchPosition.x = event.x - view.x
        view._touchPosition.y = event.y - view.y

    elseif event.phase == "moved" then

		if not view._touchPosition then
			view._touchPosition = {}
	    	view._touchPosition.x = event.x - view.x
	        view._touchPosition.y = event.y - view.y
		end
		
   		view.x = event.x - view._touchPosition.x
        view.y = event.y - view._touchPosition.y

    end
    
   	if self._bounds then
		view.x, view.y = self:clampPosition( view.x, view.y, self._bounds )
	end 
    
end

-- Sets the clamping bounds.
-- @params x The x position of the bounds.
-- @params y The y position of the bounds.
-- @params width The width of the bounds.
-- @params height The height of the bounds.
function Camera:setClampingBounds( x, y, width, height )

	if not self._bounds then
		self._bounds = {}
		self._bounds.offset = { x = 0, y = 0 }
	end
	
	self._bounds.x = x
	self._bounds.y = y
	self._bounds.width = width
	self._bounds.height = height
	
end

-- Gets the size of the content in the Camera.
-- @return The width and height of the content.
function Camera:getContentSize()
	return self:getView().contentWidth, self:getView().contentHeight
end

--- Cleans up the camera.
function Camera:cleanUp()

	if self._transition then
		transition.cancel( self._transition )
		self._transition = nil
	end
	
	self._view:removeSelf()
	self._view = nil
	
	for _, v in pairs( self._layers ) do
		if v._view and v._view[ "removeSelf" ] then
			v._view:removeSelf()
			v._view = nil
		end
	end
	
	self._layers = nil
	
end