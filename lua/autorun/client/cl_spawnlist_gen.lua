--[[
Copyright (C) 2012-2013 Spacebuild Development Team

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.
]]--
-- Created by IntelliJ IDEA.
-- User: Sam
-- Date: 16/12/12
-- Time: 8:28 AM
-- To change this template use File | Settings | File Templates.
--
SBEP.FolderName = "SBEP"


--TODO: Create a way to check FolderName (SBEP or SBMP)


function LoadContent( number, pnl )
	local models = Nodes[number].models
	for _,v in ipairs(models) do
		--Based off Vanilla GMod Code
		local cp = spawnmenu.GetContentType( "model" )
		if (cp) then
			cp( pnl, {model = v})
		end
	end
end

function LoadAllContent( mode, pnl )
	local lists = file.Find("addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\SMB\\*","GAME")

	for k,v in ipairs(lists) do
		DebugMessage("V = "..v)
		local data = file.Read("addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\SMB\\"..v,"GAME")
		print(data)
		local models = util.KeyValuesToTable(data)
		for i,j in ipairs(models) do
			--Based off Vanilla GMod Code
			local cp = spawnmenu.GetContentType( "model" )
			if (cp) then
				cp( pnl, {model = j})
			end
		end
	end
end


hook.Add("PopulateContent", "SBEP Models", function( pnlContent, tree, node)


	local files,folders = file.Find( "addons/SBEP/models/*","GAME")

	local ViewPanel = vgui.Create( "ContentContainer", pnlContent )
	ViewPanel:SetVisible(false)

	local MyNode = node:AddNode( "SBEP Models", "icon16/folder_database.png" )

	local SmbNode = MyNode:AddNode( "SmallBridge Parts", "icon16/folder_database.png")
	SmbNode.DoClick = function()
		   --TODO: Show all SmallBridge models.
			ViewPanel:Clear( true )
			LoadAllContent( "SMB",ViewPanel )
			pnlContent:SwitchPanel( ViewPanel )
		end
	--Then cycle through all folders under Data\ModelListt\SMB)
	local path = "addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\SMB\\"
	local lists = file.Find(path .. "*","GAME")
	Nodes = {}

	local counter = 1


	--[[if ( cp ) then
		cp( ViewPanel, { model = [Read from file] )
	end  ]]--
	for k,v in ipairs(lists) do
		Nodes[counter] = {}
		local temp = string.Explode( ".txt", v )
		Nodes[counter].name = temp[1]
		Nodes[counter].node = SmbNode:AddNode( Nodes[counter].name, "icon16/folder_database.png") --TODO: Find better image.
		Nodes[counter].models = {}
		local data = file.Read(path..v,"GAME")

		local models = util.KeyValuesToTable(data)
		for i,j in ipairs(models) do
			--Add the models to the button's information so we can easily load it later.
			table.insert(Nodes[counter].models, j)
		end

		counter = counter + 1
	end
	PrintTable(Nodes)

	--Then setup what happens when you click on each node
	local counter = 1
	for k,v in pairs(Nodes) do
		local folder = v.node
		folder.DoClick = function()
				ViewPanel:Clear( true )
				LoadContent( k, ViewPanel )
				pnlContent:SwitchPanel( ViewPanel )
			end

	end



	--[[for k,v in SortedPairs(folders) do
		local mdls, folders = file.Find("Addons\\SBEP\\models\\"..v.."\\*","GAME")
		if (folders) then   --if there are subfolders
			subdir = MyNode:AddNode( v:sub(1,1):upper()..v:sub(2), "icon16/folder_database.png")   --  Create a button
			CreateButtons( v )
		end
	end   ]]--
--local models = MyNode:AddNode( v:sub(1,1):upper()..v:sub(2), "icon16/bricks.png"
end)


