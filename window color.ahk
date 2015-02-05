/* Color mode controls the way colors are cycled.
In HSL mode, the color is calculated with S=100%, L=50%, and H makes one
complete revolution from 0 degrees to 360 degrees in one day.
In Cyclic mode, R, G, and B start at equally-spaced predefined values
(0, 85, 170), and each increases at the same speed. To avoid discontinuity,
they count down from 255 once it is reached. For example, in 12 hours, R goes
from 0 to 255, then 255 back to 0 over the next 12 hours.

As these produce different colors, with HSL mode generally producing more
energetic or "loud" colors, they use different Intensities. These values
correspond to the Intensity slider in the control panel.
*/ 
colorMode := "HSL"
cyclicIntensity := 80
HSL_Intensity := 30

#Include dwmColor.ahk  ; Requires _Struct http://www.autohotkey.net/~HotKeyIt/AutoHotkey/_Struct.htm
#Include <HSL>  ; HSL to/from RGB conversion functions by [VxE]. 
			    ; Freely available @ http://www.autohotkey.com/community/viewtopic.php?f=2&t=88707
#Singleinstance, force
#Persistent
; SetFormat, IntegerFast, Hex ; Better way of displaying colors.

Menu, Tray, Add ; Separator line
Menu, Tray, Add, % colorMode, ModeChange

dwmColor.EnableComposition(1) ; turns on Aero
settimer, update, 10000
update:
	secondsSinceMidnight := A_Hour*60*60 + A_Min*60 + A_Sec
	secondsPerDay := 24*60*60

	coef := secondsSinceMidnight / secondsPerDay ; Values between 0 and 1
	if (colorMode == "Cyclic"){
		coef *= 510 ; 2*255, because values go from 0-255 then from 255-0 in one day.
		R := bound(Mod(coef + 0, 510)) ; for smooth transitions, bound(257) == 253; bound(258) == 252
		B := bound(Mod(coef + 85, 510))
		G := bound(Mod(coef + 170, 510))

		argb := (0x69 << 24) | (r << 16) | (b << 8) | g ; A-channel seems to be ignored. 0x69 was the
														; original value on my system.
		dwmColor.set([argb, argb, cyclicIntensity])
	} else if (colorMode == "HSL"){
		argb := HSL_ToRGB(coef*0xFF) ; Use S and L defaults
	    dwmColor.set([argb, argb, HSL_Intensity])
	}
return

ModeChange: ; Called from the tray menu
	oldmode := colorMode
	if (colorMode == "HSL"){
		colorMode := "Cyclic"
	} else {
		colorMode := "HSL"
	}
	Menu, Tray, Rename, % oldmode, % colorMode
	gosub, Update
return

bound(R){
	/* Used in Cyclic mode for smooth transitions
	0, 1, 2, ..., 253, 254, 255, 254, 253 ..., 2, 1, 0
	*/
	if (R > 255){
		return 510-R
	}
	return R
}