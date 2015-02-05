#Include <_Struct>

/* Usage:
dcp := dwmColor.get()
MsgBox % "Current color: " dcp.clrColor
MsgBox % dwmColor.set([0x69FF00FF, 0x69FF00FF]) ? "Failure" : "Success"
dcp.clrColor := 0x6900FF00
MsgBox % dwmColor.set(dcp) ? "Failure" : "Success"

dcp2 := new DWM_COLORIZATION_PARAMS()
dcp2.clrColor := dcp.clrAfterGlow := 0x69CC0044
dcp2.nIntensity := 50
dcp2.fOpaque := 1
dwmColor.set(dcp2)
*/

/* A wrapper around two undocumented dwmapi calls for getting and setting the Aero color scheme
*/
class dwmColor
{
    _Init(){
        /* Stores a pointer to dwmapi.dll as well as references to undocumented functions.
           Can be called manually but is called by Get() and Set() automatically.
        */
        if (!this.lib){
            this.lib := DllCall("LoadLibrary","str","dwmapi","ptr")
            ; DWM_GET_COLORIZATION_PARAMS
            this.dwmapi_127 := DllCall("GetProcAddress","ptr",this.lib,"int",127,"ptr")
            ; DWM_SET_COLORIZATION_PARAMS
            this.dwmapi_131 := DllCall("GetProcAddress","ptr",this.lib,"int",131,"ptr")
        }
        if (!this.dwmapi_127){
            throw "Could not load DWM_GET_COLORIZATION_PARAMS function"
        }
    }
    
    Get(){
        /* Returns a new _Struct instance with the current color params.
           Example usage:
               MsgBox % dwmColor.Get().clrColor
            
        */
        this._Init()
        dcp := new DWM_COLORIZATION_PARAMS()
        if ! DllCall(this.dwmapi_127, "ptr", dcp[""])
            return dcp
    }
    
    Set(vals){
        /*  Takes a sparse array of uints or a dcp _Struct.
            In the case of a sparse array, the struct to pass will first be
            populated with a GetColorizationParameters call.
        */
        this._Init()
        if (vals.size() == 28){
            ; .size() is a method of _Struct instances.
            ; check its existence instead of __Class because _Struct is nonstandard
            return DllCall(this.dwmapi_131, "ptr", vals[""])
        }
        
        ; Otherwise, assume vals to be a sparse array of integers.
        ; Allocate memory for the modified struct
        VarSetCapacity(dcparams, 28, 0)
        ; Call Get first to populate the struct with current values
        DllCall(this.dwmapi_127, "ptr", &dcparams)
        ; Replace each value in the returned struct with the user-provided values.
        for index, val in vals {
            i := index - 1 ; switch to zero-based indexes for easy math
            NumPut(val, dcparams, i * 4, "UInt")
        }
        ; Call Set with the modified struct
        return DllCall(this.dwmapi_131, "ptr", &dcparams)
    }
    
    EnableComposition(b){
        /* Turns Aero on or off 
        */
        return DllCall("dwmapi.dll\DwmEnableComposition", UInt, b)
    }
    
    Unload(){
        DllCall("FreeLibrary","ptr",this.lib)
    }
}
class DWM_COLORIZATION_PARAMS {
    /* Simple wrapper to hold the definition of the dcp struct
	*/
    __New(){
        static definition := "
        (
            uint clrColor;
            uint clrAfterGlow;
            uint nIntensity;
            uint clrAfterGlowBalance;
            uint clrBlurBalance;
            uint clrGlassReflectionIntensity;
            bool fOpaque;
        )"
        return new _Struct(definition)
    }
}