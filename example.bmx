SuperStrict
Framework BRL.Blitz
Import Elephant.MumblePosAudio
Import BRL.GLMax2D
Import BRL.Max2D
Import BRL.Timer
Import BRL.StandardIO

Const UNIT_MULTIPLIER:Float = 0.1

Local link:TMumbleLink = MumbleInitLink()
If link = Null Then	RuntimeError("Mumble is not running. :(")
link.SetPlayerContext("bar")
link.SetPluginInfo("Fratti's Test Plugin", "Lolomat")

Type TPlayer
	Global List:TList = New TList
	Field x:Float
	Field z:Float
	Field rotation:Float
	
	Method New()
		List.AddLast(Self)
	EndMethod
	
	Method Control()
		Self.rotation = (Self.rotation + (KeyDown(KEY_RIGHT) - KeyDown(KEY_LEFT)) * 4) Mod 360
		Self.x = Self.x + Cos(Self.rotation) * (KeyDown(KEY_UP) - KeyDown(KEY_DOWN)) * 3
		Self.z = Self.z + Sin(Self.rotation) * (KeyDown(KEY_UP) - KeyDown(KEY_DOWN)) * 3
	EndMethod
	
	Method Draw()
		SetOrigin(Self.x, Self.z)
		SetRotation(Self.rotation)
		SetHandle(20,20)
		DrawPoly([0.0, 0.0, 0.0, 40.0, 40.0, 20.0])
		SetHandle(0,0)
		SetRotation(0)
		SetOrigin(0, 0)
	EndMethod
EndType

Graphics(800,600)
Local FrameTimer:TTimer = CreateTimer(60)
Local lplayer:TPlayer = New TPlayer
lplayer.x = 400
lplayer.z = 300

link.SetPlayerIdentity(Input("Choose an identity: "))

While Not KeyHit(KEY_ESCAPE)
	Cls
	lplayer.Control()
	For Local p:TPlayer = EachIn TPlayer.List
		p.Draw()
	Next
	
	SetColor(255,0,0)
	DrawLine(lplayer.x, lplayer.z, lplayer.x + Cos(lplayer.rotation)*30, lplayer.z + Sin(lplayer.rotation)*30)
	SetColor(255,255,255)
	
	link.SetAvatar(-Cos(lplayer.rotation), 0, -Sin(lplayer.rotation), 0, 1.0, 0, lplayer.x * UNIT_MULTIPLIER, 0, lplayer.z * UNIT_MULTIPLIER)
	link.SetCameraToAvatar()
	link.Update()
	
	DrawText("X: " + lplayer.x + ", sent to Mumble: " + lplayer.x * UNIT_MULTIPLIER, 0, 0)
	DrawText("Z: " + lplayer.z + ", sent to Mumble: " + lplayer.z * UNIT_MULTIPLIER, 0, 12)
	Flip 0
	WaitTimer(FrameTimer)
Wend
End