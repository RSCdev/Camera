Camera = {}
Camera_mt = { __index = Camera }

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

--- Sets the position of the camera.
-- @param x The new x position for the camera.
-- @param y The new y position for the camera.
function Camera:setPosition( x, y )
	self:getView().x = x
	self:getView().y = y
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
-- @return The converted x and y positions.
function Camera:convertScreenToWorldPosition( x, y )

	local posX, posY = self:getPosition()	
	local scaleX, scaleY = self:getScale()
	
	return x * scaleX + posX, y * scaleY + posY
	
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
	self:updateParallaxPositions() 
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