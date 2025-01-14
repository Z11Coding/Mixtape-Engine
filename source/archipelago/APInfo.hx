package archipelago;

class APInfo {
    public static var ap:Client;
    public static var apGame:APGameState;

    public static final baseGame:Array<String> = 
	[
		'Bopeebo', 'Fresh', 'Dad Battle',
	 	'Spookeez', 'South', 'Monster',
	 	'Pico', 'Philly Nice', 'Blammed',
	 	'Satin Panties', 'High', 'Milf',
	 	'Cocoa', 'Eggnog', 'Winter Horrorland',
	 	'Senpai', 'Roses', 'Thorns',
	 	'Ugh', 'Guns', 'Stress',
	 	'Darnell', 'Lit Up', '2Hot', 'Blazin',
		'Darnell (BF Mix)'
	];

	public static final baseErect:Array<String> = 
	[
		'Bopeebo Erect', 'Fresh Erect', 'Dad Battle Erect',
	 	'Spookeez Erect', 'South Erect',
	 	'Pico Erect', 'Philly Nice Erect', 'Blammed Erect',
	 	'Satin Panties Erect', 'High Erect',
	 	'Cocoa Erect', 'Eggnog Erect',
	 	'Senpai Erect', 'Roses Erect', 'Thorns Erect',
	 	'Ugh Erect'
	];

	public static final basePico:Array<String> = 
	[
		'Bopeebo (Pico mix)', 'Fresh (Pico mix)', 'Dad Battle (Pico mix)',
	 	'Spookeez (Pico mix)', 'South (Pico mix)',
	 	'Pico (Pico mix)', 'Philly Nice (Pico mix)', 'Blammed (Pico mix)',
	 	'Eggnog (Pico mix)',
	 	'Ugh (Pico mix)', 'Guns (Pico mix)'
	];

	public static final secrets:Array<String> = [
		'Small Argument', 
		'Beat Battle', 
		'Beat Battle 2'
	];

    public static final baseIDCode:Int = 6900000;
    public static var locationSongIDList:Map<String, Int> = [];
	public static var locationIDSongList:Map<Int, String> = [];
	public static var itemSongIDList:Map<String, Int> = [];
	public static var itemIDSongList:Map<Int, String> = [];

    public static function giveSongsID(songList:Array<String>) {
        var id = 28;
        for (song in songList)
        {
			trace('Song Location Name: '+ song + "\nSong Location ID: " + baseIDCode + id);
            locationSongIDList.set(song, baseIDCode + (id > 0 ? id : 0));
			locationIDSongList.set(baseIDCode + id, song);
            id++;
        }

		id = 50;
		for (song in songList)
        {
			trace('Song Item Name: '+ song + "\nSong Item ID: " + baseIDCode + id);
            itemSongIDList.set(song, baseIDCode + id);
			itemIDSongList.set(baseIDCode + (id > 0 ? id : 0), song);
            id++;
        }

    }

}