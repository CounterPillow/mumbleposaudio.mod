Import "mumblelink.c"
?Linux
Import "-lrt"
?

Rem
bbdoc: Link for Mumble's Positional Audio
EndRem
Module Elephant.MumblePosAudio
ModuleInfo "Version: 0.9"
ModuleInfo "Author: Propellator/Fratti"
ModuleInfo "License: zlib/libpng"
ModuleInfo ""

Private
Extern "C"
	Function testStuff( stuff:Short Ptr )
	Function initMumble_C:Int()
	Function updateMumble_C()
	Function setPluginInfo_C( name:Short Ptr, description:Short Ptr )
	Function setPlayerIdentity_C( identity:Short Ptr )
	Function setPlayerContext_C( context:Short Ptr )
	Function setAvatarFront_C( vx:Float, vy:Float, vz:Float )
	Function setAvatarTop_C( vx:Float, vy:Float, vz:Float )
	Function setAvatarPosition_C( x:Float, y:Float, z:Float )
	Function setCameraFront_C( vx:Float, vy:Float, vz:Float )
	Function setCameraTop_C( vx:Float, vy:Float, vz:Float )
	Function setCameraPosition_C( x:Float, y:Float, z:Float )
EndExtern

Public
Type TMumbleLink
	Field af_x:Float, af_y:Float, af_z:Float
	Field at_x:Float, at_y:Float, at_z:Float
	Field ap_x:Float, ap_y:Float, ap_z:Float
	Field cf_x:Float, cf_y:Float, cf_z:Float
	Field ct_x:Float, ct_y:Float, ct_z:Float
	Field cp_x:Float, cp_y:Float, cp_z:Float
	
	Method SetPlayerIdentity( identity:String )
		setPlayerIdentity_C(identity.ToWString())
	EndMethod
	
	Method SetPlayerContext( context:String )
		setPlayerContext_C(context.ToWString())
	EndMethod
	
	Method SetPluginInfo( name:String, description:String )
		Rem
		***I have no clue why I did this, I thought a glitch in MumblePAHelper was a problem of a buffer overflow somewhere.***
		
		Local mname:Short Ptr = Short Ptr(MemAlloc(256))
		MemClear(mname, 256)
		Local mdescription:Short Ptr = Short Ptr(MemAlloc(2048))
		MemClear(mdescription, 2048)
		Local wname:Short Ptr = name.ToWString()
		Local wdescription:Short Ptr = description.ToWString()
		MemCopy(mname, wname, Len(name) * 2)
		MemCopy(mdescription, wdescription, Len(description) * 2)
		setPluginInfo_C(mname, mdescription)
		EndRem
		setPluginInfo_C(name.ToWString(), description.ToWString())
	EndMethod
	
	Method SetAvatar( front_x:Float, front_y:Float, front_z:Float, top_x:Float, top_y:Float, top_z:Float, pos_x:Float, pos_y:Float, pos_z:Float )
		af_x = front_x
		af_y = front_y
		af_z = front_z
		at_x = top_x
		at_y = top_y
		at_z = top_z
		ap_x = pos_x
		ap_y = pos_y
		ap_z = pos_z
	EndMethod
	
	Method SetCamera( front_x:Float, front_y:Float, front_z:Float, top_x:Float, top_y:Float, top_z:Float, pos_x:Float, pos_y:Float, pos_z:Float )
		cf_x = front_x
		cf_y = front_y
		cf_z = front_z
		ct_x = top_x
		ct_y = top_y
		ct_z = top_z
		cp_x = pos_x
		cp_y = pos_y
		cp_z = pos_z
	EndMethod
	
	Method SetCameraToAvatar()
		cf_x = af_x
		cf_y = af_y
		cf_z = af_z
		ct_x = at_x
		ct_y = at_y
		ct_z = at_z
		cp_x = ap_x
		cp_y = ap_y
		cp_z = ap_z
	EndMethod
	
	Method Update()
		updateMumble_C()
		setAvatarFront_C(af_x, af_y, af_z)
		setAvatarTop_C(at_x, at_y, at_z)
		setAvatarPosition_C(ap_x, ap_y, ap_z)
		setCameraFront_C(cf_x, cf_y, cf_z)
		setCameraTop_C(ct_x, ct_y, ct_z)
		setCameraPosition_C(cp_x, cp_y, cp_z)
	EndMethod
EndType

Rem
bbdoc: Initializes the Mumble link
returns: a new instance of TMumbleLink or Null if it's not successful (e.g. Mumble is not running)
about: Only one instance of the Mumble Link should be running
EndRem
Function MumbleInitLink:TMumbleLink()
	Local ml:TMumbleLink = New TMumbleLink
	If initMumble_C() Then
		Return ml
	Else
		Return Null
	EndIf
EndFunction

Function TestWString(s:String)
	testStuff(s.ToWString())
EndFunction