SBEP = SBEP or {}

--fill table from file
--not run on execution as you don't always need to fix dupes
--is a console command in case you made changes and want to try it real-time
function SBEP_LoadReplaceTable()
	print("Loading Filename Changes")
	local repTab = {}
	local tableString = file.Read("data/sbep/smallbridge_filename_changes.lua", "LUA")
	if not tableString then 
		print("Couldn't load file lua/data/sbep/smallbridge_filename_changes.lua")
		return
	end

	--try exploding by windows style line endings
	local tableRows = string.Explode("\r\n",tableString)

	--if it failed, try exploding by linux style line endings in case someone checked out the file on linux
	if table.Count(tableRows) == 0 then
		tableRows = string.Explode("\n",tableString)
	end

	for _,row in pairs(tableRows) do
		--returns the pair of strings matched by this pattern
		--currently only finds models, if we change entity names as well this will need changing
		old,new = string.match(row, "^[ \t]*(models/[0-9A-Za-z/, _-]*.mdl)[ \t]*|[ \t]*(models/[0-9A-Za-z/, _-]*.mdl)[ \t]*$")
		if (old and new) then
			repTab[string.Trim(string.lower(old))] = string.Trim(string.lower(new))
		end
	end
	SBEP_ReplaceTable = repTab
	SBEP.ReplaceTable = repTab
end
SBEP.LoadReplaceTable = SBEP_LoadReplaceTable
concommand.Add("SBEP_LoadReplaceTable",SBEP.LoadReplaceTable)

--replaces all instances of models in the replace table with 
function SBEP_FixDupe(_,_,arg)
	--if the replace table hasn't been made yet, remake it
	SBEP.LoadReplaceTable()
	if not SBEP.ReplaceTable then
		print("SBEP_FixDupe failed")
		return
	end
	--print("FixDupe called")
	local filePath = table.concat(arg,' ')
	--print("File Path = ",filePath)
	
	if(!file.Exists(filePath, 'DATA')) then
		print('[ERROR] dupe file "'..filePath..'" does not exists or contains invalid characters in filename, fix them first, then re-run.\r\n')
		return
	end
		
	local fileString = file.Read(filePath)
	if fileString then
		local ReplaceTable = {}
		for w in string.gmatch(fileString, "(models/[0-9A-Za-z/, _-]*.mdl)") do
			local replacement = SBEP.ReplaceTable[string.lower(w)]
			if replacement then
				--replace file renames
				ReplaceTable[w] = replacement
			elseif w != string.lower(w) and not file.Exists(w, "GAME") and file.Exists(string.lower(w), "GAME") then
				--replace every mdl if a lowercased file exists -> case sensitive file systems
				ReplaceTable[w] = string.lower(w)
			elseif not file.Exists(w, "GAME") then
					print("Model missing on disk: " .. w)
			end
		end
		for old,new in pairs(ReplaceTable) do
			print("Replacing "..old.." with "..new)
			fileString = string.Replace(fileString,old,new)
			if not file.Exists(new, "GAME") then
				print("Model missing on disk: " .. new)
			end
		end

		if table.Count(ReplaceTable) > 0 then
			--don't work on the original in case we messes things up
			file.Write(filePath..".new.txt",fileString)			
			print(filePath..".new.txt fixed, done.")
		else
			print("Nothing to replace, done.")
		end
	else
		print(filePath.." is broken, can't do anything")
	end
end
SBEP.FixDupe = SBEP_FixDupe
concommand.Add("SBEP_FixDupe",SBEP.FixDupe)

function SBEP_RecursiveFix(_,_,args)
	local dir = table.concat(args,' ')
	--print("\nRecursive Fix Called, we are in: "..dir)
	local files = file.Find(dir.."/*.txt", "DATA")
	if files then
		--print("Files Found: ")
		--PrintTable(files)
		for _,filePath in pairs(files) do
			SBEP.FixDupe(nil,nil,{dir.."/"..filePath})
		end
	end
	local files, directories = file.Find(dir.."/*","DATA")
	if directories then
		--print("Directories Found: ")
		--PrintTable(directories)
		for _,dirPath in pairs(directories) do
			SBEP_RecursiveFix(nil,nil,{dir.."/"..dirPath})
		end
	end
end
SBEP.RecursiveFix = SBEP_RecursiveFix
concommand.Add("SBEP_FixDupeFolder",SBEP.RecursiveFix)

function SBEP_FixAllDupes()
	--print("Fix Dupes Called")
	SBEP.RecursiveFix(nil,nil,{"adv_duplicator"})
	print("Done!")
end
SBEP.FixAllDupes = SBEP_FixAllDupes
concommand.Add("SBEP_FixAllDupes",SBEP.FixAllDupes)
