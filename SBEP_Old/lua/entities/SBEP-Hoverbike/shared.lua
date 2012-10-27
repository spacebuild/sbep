ENT.Type 			= "anim"
ENT.Base 			= "base_gmodentity"
ENT.PrintName		= "Hoverbike"
ENT.Author			= "Paradukes + SlyFo"
ENT.Category		= "SBEP-Rover Gear"

local found = file.Exists("../models/hoverbike.mdl")

ENT.Spawnable		= found
ENT.AdminSpawnable	= found
ENT.Owner			= nil
ENT.CPL				= nil

ENT.EPrs			= false
ENT.TSpeed			= 75
ENT.LTog			= false
ENT.MTog			= false
ENT.MCC				= false
ENT.MChange			= false
ENT.Speed			= 0
ENT.Active			= false
ENT.Launchy			= false
ENT.Pitch			= 0
ENT.Yaw				= 0
ENT.Roll			= 0
ENT.WInfo			= "Hoverbike"