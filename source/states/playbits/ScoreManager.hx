package states.playbits;

class ScoreManager
{
    
	public var ratingsData:Array<Rating> = Rating.loadDefault();
    
    public var combo:Int = 0;
	public var songScore:Int = 0;
	public var songHits:Int = 0;
	public var songMisses:Int = 0;
	
	public var comboOpp:Int = 0;
	
	public var gfBopCombo:Int = 0;
	public var gfBopComboBest:Int = 0;
	public var gfHits:Int = 0;
	public var gfMisses:Int = 0;
}