-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
///																HANGARS																	      ///
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local HMT = {}
			HMT[ "models/Slyfo/cdeck_single.mdl"  					] = { "Deck"				, "MedBridge"   , { Deck  = { ship = nil , weld = nil , pos = Vector(0,0,256) , 
																												 canface = { Angle(0,90,0)  ,Angle(0,270,0)  ,Angle(0,180,0)  ,Angle(0,0,0),
																															 Angle(0,90,180),Angle(0,270,180),Angle(0,180,180),Angle(0,0,180)} } } }
			HMT[ "models/Slyfo/cdeck_double.mdl"  					] = { "DeckDouble"			, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0,256,256) , 
																												 canface = { Angle(0,90,0)	,Angle(0,270,0)	 ,Angle(0,180,0)  ,Angle(0,0,0),
																															 Angle(0,90,180),Angle(0,270,180),Angle(0,180,180),Angle(0,0,180)} } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-256,256) , 
																												 canface = { Angle(0,90,0)  ,Angle(0,270,0)  ,Angle(0,180,0)  ,Angle(0,0,0),
																															 Angle(0,90,180),Angle(0,270,180),Angle(0,180,180),Angle(0,0,180)} } } }
			HMT[ "models/Slyfo/cdeck_doublewide.mdl"  				] = { "DeckDoubleWide"		, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0,512,256) , 
																												 canface = { Angle(0,90,0)  ,Angle(0,270,0)  ,Angle(0,180,0)  ,Angle(0,0,0),
																															 Angle(0,90,180),Angle(0,270,180),Angle(0,180,180),Angle(0,0,180)} } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-512,256) , 
																												 canface = { Angle(0,90,0)  ,Angle(0,270,0)  ,Angle(0,180,0)  ,Angle(0,0,0),
																															 Angle(0,90,180),Angle(0,270,180),Angle(0,180,180),Angle(0,0,180)} } } }
			HMT[ "models/Slyfo/hangar_singleside.mdl"  			] = { "SWORDHangarSingle"	, "MedBridge"   , { Side  = { ship = nil , weld = nil , pos = Vector(0,-172,-20) ,
																												 canface = { Angle(0,0,0)   ,Angle(0,180,0)  ,Angle(0,0,180)  ,Angle(0,180,180)} ,
																												 pexit   = Vector(0,100,-100)} } }
			HMT[ "models/Slyfo/shangar.mdl"  						] = { "mbhangarside2"		, "MedBridge"   , { Side  = { ship = nil , weld = nil , pos = Vector(0,214,0) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,100,-100) } } }
			HMT[ "models/SmallBridge/Station Parts/SBdockCs.mdl"  	] = { "sbclamp"				, "SmallBridge" , { Clamp = { ship = nil , weld = nil , pos = Vector(-128,0,0) , 
																												 canface = {Angle(0,90,0),Angle(0,270,0),Angle(0,90,180),Angle(0,270,180)} ,
																												 pexit   = Vector(0,0,0) } } }
			HMT[ "models/SmallBridge/Hangars/sbdb3m.mdl"  			] = { "sbHangar"			, "SmallBridge" , { Bay   = { ship = nil , weld = nil , pos = Vector(0,0,0) , 
																												 canface = {Angle(0,0,0), Angle(0,180,0)} ,
																												 pexit   = Vector(0,0,10) } } }
			HMT[ "models/SmallBridge/Station Parts/SBhangarLu.mdl" ] = { "sbfighterbay1"		, "SmallBridge" , { Right = { ship = nil , weld = nil , pos = Vector(0,320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,256,0) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,-256,0) } } }
			HMT[ "models/SmallBridge/Station Parts/SBhangarLud.mdl"] = { "sbfighterbay2"		, "SmallBridge" , { Right = { ship = nil , weld = nil , pos = Vector(0,320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,256,0) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,-256,0) } } }
			HMT[ "models/SmallBridge/Station Parts/SBhangarLd.mdl" ] = { "sbfighterbay3"		, "SmallBridge" , { Right = { ship = nil , weld = nil , pos = Vector(0,320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,256,0) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-320,80) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,-256,0) } } }
			HMT["models/SmallBridge/Station Parts/SBhangarLud2.mdl"] = { "sbfighterbay4"		, "SmallBridge" , { Right = { ship = nil , weld = nil , pos = Vector(0,448,0) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,320,0) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-448,0) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0)} ,
																												 pexit   = Vector(0,-320,0) } } }
			HMT[ "models/SmallBridge/Hangars/SBDBcomp1.mdl"  		] = { "sbHangar"			, "SmallBridge" , { Bay   = { ship = nil , weld = nil , pos = Vector(0,0,0) , 
																												 canface = {Angle(0,0,0), Angle(0,180,0)} ,
																												 pexit   = Vector(-250,0,10) } } }
			HMT[ "models/Slyfo/hangar1.mdl"  						] = { "SWORDHangar"			, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0,400,-40) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,200,-100) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-400,-40) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-200,-100) } } }
			HMT[ "models/Slyfo/hangar2.mdl"  						] = { "SWORDHangarLarge"	, "MedBridge"   , { ["Top Right"] = { ship = nil , weld = nil , pos = Vector(0, 400, -20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0, 200, -100) } ,
																												["Top Left"]  = { ship = nil , weld = nil , pos = Vector(0,-400, -20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-200,-100) } ,
																												["Bottom Right"] = { ship = nil , weld = nil , pos = Vector(0, 400, -220) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0, 200,-300) } ,
																												["Botton Left"]  = { ship = nil , weld = nil , pos = Vector(0,-400, -220) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-200,-300) } } }
			HMT[ "models/Slyfo/hangar3.mdl"  						] = { "SWORDHangarSpacious" , "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0, 400, -150) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0, 200,-300) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0,-400, -150) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-200,-300) } } }
			HMT[ "models/Slyfo/capturehull1.mdl"  					] = { "DockingClamp"		, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(425,0,80) , 
																												 canface = {Angle(0,90,0),Angle(0,270,0),Angle(0,90,180),Angle(0,270,180)} ,
																												 pexit   = Vector(150,0,10) } } }
			HMT[ "models/Slyfo/doubleclamp.mdl"  					] = { "DockingClampT"		, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0,-600,-20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-300,-85) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0, 600,-20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0, 300,-85) } } }
			HMT[ "models/Slyfo/doubleclamp_x.mdl"  				] = { "DockingClampX"		, "MedBridge"   , { Right = { ship = nil , weld = nil , pos = Vector(0,-600,-20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,-300,-85) } ,
																												Left  = { ship = nil , weld = nil , pos = Vector(0, 600,-20) , 
																												 canface = {Angle(0,0,0),Angle(0,180,0),Angle(0,0,180),Angle(0,180,180)} ,
																												 pexit   = Vector(0,  300,-85) } } }
			HMT[ "models/Spacebuild/pad.mdl"  						] = { "LandingPad"			, "MedBridge"   , { Pad   = { ship = nil , weld = nil , pos = Vector(0,0,175) , 
																												 canface = {Angle(0,90,0),Angle(0,270,0),Angle(0,180,0),Angle(0,0,0)} ,
																												 pexit   = Vector(-300,-225,2) } } }

for k,v in pairs( HMT ) do
	list.Set( "SBEP_HangarModels", k , v )
end