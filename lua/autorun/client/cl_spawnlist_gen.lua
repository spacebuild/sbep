--[[
Copyright (C) 2012-2014 Spacebuild Development Team

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
]]--
-- Created by IntelliJ IDEA.
-- User: Sam
-- Date: 16/12/12
-- Time: 8:28 AM
-- To change this template use File | Settings | File Templates.
--
SBEP.FolderName = "SBEP"


--TODO: Create a way to check FolderName (SBEP or SBMP)
--TODO: Get Better icons...
--TODO: Maybe load names from line 1 of each file
--TODO: Either write a function to lower case the whole file or lower case them using Npp.

function LoadContent( mode, pnl, ViewPanel,pnlContent  )
	ViewPanel:Clear( true )

	DebugMessage(mode)
	local data = file.Read("addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\"..mode,"GAME")
		local models = util.KeyValuesToTable(data)
		for i,j in ipairs(models) do
			--Based off Vanilla GMod Code
			local cp = spawnmenu.GetContentType( "model" )
			if (cp) then
				cp( ViewPanel, {model = j})
			end
		end
	pnlContent:SwitchPanel( ViewPanel )
end

function LoadAllContent( mode, pnl )
	local lists = file.Find("addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\"..mode.."\\*","GAME")

	for k,v in ipairs(lists) do
		local data = file.Read("addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\"..mode.."\\"..v,"GAME")
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

function DoMedbridge( pnlContent, tree, node, MainNode, ViewPanel )



	local MedNode = MainNode:AddNode( "MedBridge Parts", "icon16/folder_database.png")
	MedNode.DoClick = function()
	--TODO: Show all SmallBridge models.
		ViewPanel:Clear( true )
		LoadAllContent( "Med",ViewPanel )
		pnlContent:SwitchPanel( ViewPanel )
	end
	--Then cycle through all folders under Data\ModelListt\SMB)
	local path = "addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\Med\\"
	local lists = file.Find(path .. "*","GAME")

	for k,v in ipairs(lists) do

		local temp = string.Explode( ".txt", v )
		local name = temp[1]
		local MyNode = MedNode:AddNode( name, "icon16/folder_database.png") --TODO: Find better image.
		MyNode.DoClick = function() LoadContent("Med\\"..v.."", MyNode, ViewPanel,pnlContent ) end


	end

end

function DoSmallBridge( pnlContent, tree, node, ViewPanel  )

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



	--[[if ( cp ) then
		cp( ViewPanel, { model = [Read from file] )
	end  ]]--
	for k,v in ipairs(lists) do

		local temp = string.Explode( ".txt", v )
		local name = temp[1]
		local MyNode = SmbNode:AddNode( name, "icon16/folder_database.png") --TODO: Find better image.
		MyNode.DoClick = function() LoadContent("SMB\\"..v.."", MyNode, ViewPanel,pnlContent ) end
	end

	--Then setup what happens when you click on each node
	return MyNode

end

function DoModBridge( pnlContent, tree, node, MainNode, ViewPanel )


	local ModNode = MainNode:AddNode( "ModBridge Parts", "icon16/folder_database.png")
	ModNode.DoClick = function()
	--TODO: Show all SmallBridge models.
		ViewPanel:Clear( true )
		LoadAllContent( "Mod",ViewPanel )
		pnlContent:SwitchPanel( ViewPanel )
	end
	--Then cycle through all folders under Data\ModelListt\SMB)
	local path = "addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\Mod\\"
	local lists = file.Find(path .. "*","GAME")

	for k,v in ipairs(lists) do

		local temp = string.Explode( ".txt", v )
		local name = temp[1]
		local MyNode = ModNode:AddNode( name, "icon16/folder_database.png") --TODO: Find better image.
		MyNode.DoClick = function() LoadContent("Mod\\"..v.."", MyNode, ViewPanel,pnlContent ) end


	end

end

function DoSBMP( pnlContent, tree, node, MainNode, ViewPanel )
	local SBMPNode = MainNode:AddNode( "SBMP Parts", "icon16/folder_database.png")
	SBMPNode.DoClick = function()
	--TODO: Show all SmallBridge models.
		ViewPanel:Clear( true )
		LoadAllContent( "SBMP",ViewPanel )
		pnlContent:SwitchPanel( ViewPanel )
	end
	--Then cycle through all folders under Data\ModelListt\SMB)
	local path = "addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\SBMP\\"
	local lists = file.Find(path .. "*","GAME")

	for k,v in ipairs(lists) do

		local temp = string.Explode( ".txt", v )
		local name = temp[1]
		local MyNode = SBMPNode:AddNode( name, "icon16/folder_database.png") --TODO: Find better image.
		MyNode.DoClick = function() LoadContent("SBMP\\"..v.."", MyNode, ViewPanel,pnlContent ) end


	end

end

function DoOther( pnlContent, tree, node, MainNode, ViewPanel )
	local OtherNode = MainNode:AddNode( "Other", "icon16/folder_database.png")
	OtherNode.DoClick = function()
	--TODO: Show all SmallBridge models.
		ViewPanel:Clear( true )
		LoadAllContent( "Other",ViewPanel )
		pnlContent:SwitchPanel( ViewPanel )
	end
	--Then cycle through all folders under Data\ModelListt\SMB)
	local path = "addons\\"..SBEP.FolderName.. "\\data\\ModelLists\\Other\\"
	local lists = file.Find(path .. "*","GAME")

	for k,v in ipairs(lists) do

		local temp = string.Explode( ".txt", v )
		local name = temp[1]
		local MyNode = OtherNode:AddNode( name, "icon16/folder_database.png") --TODO: Find better image.
		MyNode.DoClick = function() LoadContent("Other\\"..v.."", MyNode, ViewPanel,pnlContent ) end


	end

end


hook.Add("PopulateContent", "SBEP Models", function( pnlContent, tree, node)
	--Setup SmallBridge
	local ViewPanel = vgui.Create( "ContentContainer", pnlContent )
	ViewPanel:SetVisible(false)
	local MasterNode = DoSmallBridge( pnlContent, tree, node, ViewPanel )

	--Start of Medbridge Node
	DebugMessage("Doing Medbridge")
	DoMedbridge( pnlContent, tree, node, MasterNode, ViewPanel )


	DebugMessage("Doing ModBridge")
	DoModBridge( pnlContent, tree, node, MasterNode, ViewPanel )

	DebugMessage("Doing SBMP")
	DoSBMP( pnlContent, tree, node, MasterNode, ViewPanel )

	DebugMessage("Doing Anything contained in the Other folder")
	DoOther( pnlContent, tree, node, MasterNode, ViewPanel )

--local models = MyNode:AddNode( v:sub(1,1):upper()..v:sub(2), "icon16/bricks.png"
end)


