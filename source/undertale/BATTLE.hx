package undertale;

class MonsterConfig {
    public var name:String;
    public var level:Int;
    public var attack:Int;
    public var defense:Int;
    public var health:Int;
    public var speed:Int;
    public var isBoss:Bool;
    public var isGenocide:Bool;

    public function new(name:String, level:Int, attack:Int, defense:Int, health:Int, speed:Int, isBoss:Bool, isGenocide:Bool) {
        this.name = name;
        this.level = level;
        this.attack = attack;
        this.defense = defense;
        this.health = health;
        this.speed = speed;
        this.isBoss = isBoss;
        this.isGenocide = isGenocide;
    }
}

if (isGenocide) {
    human = new SOUL(RED, 'Chara', 20);
    
    var monsterConfig = new MonsterConfig('Z11Tale', 4, 1, 1000000, 9999, 500, false, true);
    monster = new MSOUL(monsterConfig.name, monsterConfig.level, monsterConfig.attack, monsterConfig.defense, monsterConfig.health, monsterConfig.speed, monsterConfig.isBoss, monsterConfig.isGenocide);
    
    monster.initFlavorText = '[setspeed:0.05]Battle against the truly determined...[pause:1][slow:0.4]\nLet\'s see how much he\'ll take before he breaks...';
    
    var flavorTextList = {
        0: [
            '[setspeed:0.05]You feel like you\'ve done this before somewhere...', 
            '[setspeed:0.05]Z11Tale asks his blasters what they want for dinner[pause:2]\nThey\'re still deciding'
        ],
        1: [
            '[setspeed:0.05]Smells like DETERMINATION',
            '[setspeed:0.05]Z11Tale rubs his sword[pause:0.5]\nit shimmers in multiple different colors in response'
        ],
        2: [
            '[setspeed:0.05]Z11Tale reminds himself of your sins[pause:0.5]\nHis grip on his sword tightens',
            '[setspeed:0.05]Z11Tale\'s soul glimmers within him[pause:1]\nYou wonder how many monsters died to make him this strong...'
        ],
        3: [
            '[setspeed:0.05]DETERMINATION'
        ]
    };
    
    monster.flavorTextList = flavorTextList;
}
else {
    // Handle the non-genocide case
}