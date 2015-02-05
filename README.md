Change Aero color scheme with AutoHotkey
===

<img alt="Clock with colored background" src="clock.png">

DwmColor.ahk is an AutoHotkey v1.1+ wrapper around some undocumented functions in
dwmapi.dll. It provides the capability to change the color of window
borders and the taskbar. A class (dwmColor) holds pointers to the loaded dwmapi
library and its functions.

Window Color.ahk, inspired by [What colour is it?](http://whatcolourisit.scn9a.org/),
gradually alters the color scheme such that the general time of day can be determined by the color
of windows. It can cycle around the [HSL color space](http://jsfiddle.net/afkLY/64/) or generate colors based
on an RGB starting point. Unlike What colour is it, the transitions are smooth, and no
two similar colors are ever displayed far apart within a 24-hour period.

For a quick demonstration of the RGB cycle method, see [this adaption](http://clentner.github.io/color.html) of 
the What colour is it site.

Thanks to KarmaCon for implementing the DwmGetColorizationParameters (I have added x64
compatibility), [VxE] and various Wikipedia editors for a lossless HSL implementation,
and HotKeyIt for _Struct.