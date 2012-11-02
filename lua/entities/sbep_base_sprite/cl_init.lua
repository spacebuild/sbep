include('shared.lua')
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
local MatTab = {
	SWSH = { Material( "sprites/SWSHblue"		) , { 42 , 30 } } ,
	SWDH = { Material( "sprites/SWDHgreen"		) , { 21 , 30 } } ,
	DWSH = { Material( "sprites/DWSHred"		) , { 42 , 15 } } ,
	DWDH = { Material( "sprites/DWDHyellow"		) , { 42 , 30 } } ,
	INSR = { Material( "sprites/Insert"		) , { 42 , 15 } } ,
	
	ESML = { Material( "sprites/ESML"			) , { 35 , 35 } } ,
	ELRG = { Material( "sprites/ELRG"			) , { 35 , 35 } } ,
	
	LRC1 = { Material( "sprites/LRC1"			) , { 42 , 30 } } ,
	LRC2 = { Material( "sprites/LRC1"			) , { 42 , 30 } } ,
	LRC3 = { Material( "sprites/LRC3"			) , { 42 , 30 } } ,
	LRC4 = { Material( "sprites/LRC3"			) , { 42 , 30 } } ,
	LRC5 = { Material( "sprites/LRC5"			) , { 21 , 30 } } ,
	LRC6 = { Material( "sprites/LRC5"			) , { 21 , 30 } } ,
	
	MBSH = { Material( "sprites/MBSH"			) , { 35 , 35 } } ,
		
	MOD1x1 = { Material( "sprites/mod1x1"		) , { 35 , 35 } } ,
	MOD2x1 = { Material( "sprites/mod2x1"		) , { 35 , 35 } } ,
	MOD3x1 = { Material( "sprites/mod3x1"		) , { 35 , 35 } } ,
	MOD3x2 = { Material( "sprites/mod3x2"		) , { 35 , 35 } } ,
	MOD1x1e = { Material( "sprites/ESML"		) , { 35 , 35 } } ,
	MOD3x2e = { Material( "sprites/ELRG"		) , { 35 , 35 } } ,
				}

ENT.Mat = MatTab.SWSH[1]

--ENT.Mat2 = Material( "cable/blue_elec" )

function ENT:Draw()
	local type = self:GetNWString( "SBEPSpriteType" ) or "SWSH"
	if !MatTab[ type ] then return end
	self.Mat = MatTab[ type ][1]
	local dim1 = MatTab[ type ][2][1]
	local dim2 = MatTab[ type ][2][2]
	
	render.SetMaterial( self.Mat )
	render.DrawSprite( self:GetPos() , dim1 , dim2 , Color(255,255,255,255) )

	--render.SetMaterial( self.Mat2 )
	--render.DrawBeam( self:GetPos() , self:GetPos() + 50 * self:GetForward() , 10 , 0 , 0 , Color(255,255,255,255) )
	
	--render.DrawBeam( self:GetPos() , self:GetPos() + 30 * self:GetUp() , 10 , 0 , 0 , Color(255,255,255,255) )

end

function ENT:DrawTranslucent()

	self:Draw()

end