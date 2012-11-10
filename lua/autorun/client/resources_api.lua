--
-- Created by IntelliJ IDEA.
-- User: Sam Elmer
-- Date: 8/11/12
-- Time: 9:03 AM
-- To change this template use File | Settings | File Templates.
--

--TODO: Complete Documentation
--TODO: For Developers: You need to fill this file out with your custom RD replacement/whatever.


if (SERVER) then
    AddCSLuaFile("autorun/resources_api.lua")
end



if (CLIENT) then
	 local meta = FindMetaTable("Entity")

	--- Used to draw any connections, "beams", info huds, etc for the devices.
	-- This should go into ENT:Draw() or any other draw functions.
	-- @param ent The entity. Does this really need explanation?
	-- @return nil
	function meta:ResourcesDraw(ent)

    end
end

if (SERVER) then
	--- Used to Consume Resources.
	-- Call it with ENT:ResConsume()
	--@param res The String or table of the resource(s) you want to consume
	--@param amt The amount you want to consume. Can be negative or positive.
	--@returns Amount Not Consumed.. If it is coded by Developers to.
	function meta:ResConsume( res, amt )

	end
	--- Supplies the Resource to the connected network.
	-- Call it with ENT:ResourcesSupply()
	--@param res The string or table of the resource(s) you want to supply to the connected network.
	--@param amt The amount you want to supply
	--@returns Amount not supplied.
	function meta:ResourcesSupply( res, amt )

	end
	--- Get's the Capacity of the entity.
	--@returns The Capcity of the entity. This is the maximum amount of res it can have.
	--@param res The resource you want it to return the capacity of.
	function meta:ResourcesGetCapacity( res )

	end


	--- Set's the Capcity of the entity.
	function meta:ResourcesSetDeviceCapacity( res, amt )

	end

	function meta:ResourcesGetAmount( res )


	end

	function meta:ResourceGetDeviceCapaciy( res )

	end

	function meta:ResourcesLink( ent, ent1)

	end

	function meta:ResourcesGetConnected()
		 local ent = self

	end

	function meta:ResourcesApplyDupeInfo( ply, entity, CreatedEntities )
		local ent = self
	end

	function meta:ResourceBuildDupeInfo()
		local ent = self
	end


end





