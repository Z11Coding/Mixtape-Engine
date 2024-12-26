package;

import flixel.FlxG;


class COD
{
    public static var deathVar:String;
    var missDeath:String;
	var missDeath2:String;
    var rDeath:String;
	var ukTxt:String;
	var COD:String;
	public static var scriptCOD:String;

	public static function initCOD():Void
	{
		deathVar = "Cause of death: ";
    	missDeath = "Missed a note at 0 health.";
		missDeath2 = "Missed a note.";
		rDeath = "Pressed R.";
		ukTxt = "Unknown.";
		scriptCOD = "???";
		COD = "???";
	}

	public static function setCOD(?note:Note, ?reason:String)
	{
		if (scriptCOD != "???")
			COD = scriptCOD;
		else if (note.cod != "???")
			COD = note.cod;
		else
		{
			switch (reason)
			{
				case "miss0":
					COD = missDeath;
				case "miss":
					COD = missDeath2;
				case "r":
					COD = rDeath;
				default:
					COD = ukTxt;
			}
		}
	}

	public static function getCOD():String
		return deathVar+"\n[pause:0.5]"+COD;
}