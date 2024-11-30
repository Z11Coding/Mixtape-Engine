package;

import flixel.FlxG;


class COD
{
    public static var deathVar:String;
    public static var missDeath:String;
	public static var missDeath2:String;
    public static var rDeath:String;
	public static var ukTxt:String;
	public static var crossDeath:String;
	public static var instaDeath:String;
	public static var shiftDeath:String;
	public static var swordDeath:String;
	public static var burgDeath:String;
	public static var chompDeath:String;


	public static function deathCheck():Void
	{
		deathVar = "Cause of death: ";
    	missDeath = "missed a note at 0 health.";
		missDeath2 = "missed a note.";
		rDeath = "Pressed R.";
		ukTxt = "unkown.";
		crossDeath = "Got Shot\n(Hint: Press Space When The Crosshair Touches The Strum To Dodge.)";	
		instaDeath = "Pressed An Instakill Note.";
		shiftDeath = "missed A Shifting Note.";
		swordDeath = "missed A Sword Note.";
		burgDeath = "hit A Condom Note.";
		chompDeath = "missed A Chomp Note.";
	}
}