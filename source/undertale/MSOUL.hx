package undertale;

class MSOUL {
    public var name:String = 'UNKNOWN';
    public var health:Float = 20;
    public var maxHealth:Float = 20;
    public var sprite:FlxSprite;
    public var expToGive:Int = 1;
    public var goldToGive:Int = 0;
    public var atk:Int = 0;
    public var def:Int = 0;
    public var canSpare:Bool = false;
    public var canFlee:Bool = false;
    public var canHurt:Bool = true; //basically like sans's ability to dodge
    public var isGenocide:Bool = false; //toggles the alt sprite for genocide (ONLY TOGGLE THIS IF SAID SPRITE EXISTS)
    public var flavorTextList:Array<String> = ['Hi :)'];
    public var initFlavorText:String = 'Hi :)';
    public var progress:Int = -1;
    /*
        If i ever decide to expand this feature for some ungodly reason, 
        this allows regualr monsters to work seperately from boss ones.
    */
    public var isBossMonster:Bool = true;

    public static var instance:MSOUL;

    public function new(name:String = '???', attack:Int = 0, defense:Int = 0, maxHealth:Float = 1, expToGive:Int = 0, goldToGive:Int = 0, canSpare:Bool = false, canHurt:Bool = true, isGenocide:Bool = false) {
        this.name = name;
        this.maxHealth = maxHealth;
        this.health = maxHealth;
        this.expToGive = expToGive;
        this.goldToGive = goldToGive;
        this.canSpare = canSpare;
        this.canHurt = canHurt;
        this.sprite = getMonsterSprite(name);
        this.atk = attack;
        this.def = defense;
        this.isGenocide = isGenocide;
        instance = this;
    }

    function getMonsterSprite(monster:String = 'test', isBattle:Bool = true, isGenocide:Bool = false):FlxSprite {
        this.sprite = new FlxSprite(0, 0, Paths.image('undertale/monster/${if (isBattle) 'battle/' else 'overworld/'}$monster'+if (isGenocide) '-genocide' else ''));
        return this.sprite;
    }

    function getMugshotSprite(monster:String = 'test'):FlxSprite {
        var mugshot:FlxSprite = new FlxSprite(0, 0, Paths.image('undertale/mugshots/$monster'));
        return mugshot;
    }
    
}

typedef DialogueLine = {
    var animation: SpeechBubbleAnimation;
    var speaker: String;
    var text: String;
}

enum SpeechBubbleAnimation {
    LeftWide;
    RightWide;
    RightLarge;
    LeftLarge;
    RightLong;
    LeftLargeMinus;
    Empty;
    RightLargeMinus;
    LeftWideMinus;
    RightWideMinus;
    Left;
    LeftShort;
    Right;
    RightShort;
}
class DialogueHandler {
    public static function getMonsterDialogue(monster:MSOUL, isGenocide:Bool, human:SOUL):Array<Array<Array<String>>> {
        var dialogueArray:Array<Array<Array<String>>> = null;
        switch (monster.name) {
            case 'Z11Tale':
                if (isGenocide) {
                    var dialogues:Array<Array<DialogueLine>> = [
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]So, [pause:0.5]you're that guy I've heard about so much." },
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "Kinda crazy to think I'd find any other humans down here..." },
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.5]...It's a shame that human was you..." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]What? [pause:1]Did you seriously expect me to just let Asgore walk out here in Sans's place?" },
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "Just to be killed by you?[pause:1] [slow:0.2]Not happening." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Besides,[pause:0.5] knowing Asgore,[pause:0.5] you'd probably kill him in one shot, [pause:0.5]wouldn't you?" },
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "I mean,[pause:0.5] your LOVE is at 20! [pause:0.5]There's no way anyone but me could survive a hit from you now." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Sans, [pause:0.5]Papyrus, [pause:0.5]Toriel, [pause:0.5]Undyne, [pause:0.5]Mettaton, [pause:0.5]Heck, [pause:0.2]You even managed to find Alphys and the rest of the evacuated monsters."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Ruthless, [pause:0.5]Yet thorough. [pause:0.5]if you weren't killing my friends, [pause:0.5]i'd probably be impressed..." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightLarge, speaker: "Z11D", text: "[set:0.05]Don't get me wrong, [pause:0.5]though. [pause:0.5]I'm NOT congratulating you, [pause:0.5]Nor am I prasing you.[pause:1] [pitch:0.1][set:0.5]I hate every bit of you that still lives."},
                            { animation: SpeechBubbleAnimation.RightLarge, speaker: "Z11D", text: "[set:0.05]But,[tpitch:1] [pause:0.5]seeing as the monsters haven't beaten you yet, [pause:0.5]I'd thought I should give my two cents on the subject." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Oh, [pause:0.5]by the way, [pause:0.5]you've probabbly noticed the blasters behind me."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Well, don't worry about them, [pause:0.5]You'll get to play with them soon enough." }
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05][tpitch:0.5]I can see it, [pause:0.5]you know? [pause:1]Or should I say, [pause:0.5]I can see HER, [pause:0.5]you know."},
                            { animation: SpeechBubbleAnimation.RightLarge, speaker: "Z11D", text: "[set:0.05]That's the only reason I haven't gone all-out on you yet. [pause:0.5]Because there's a chance that the kind person I remember is still in there."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]I don't know what happened out there, [pause:0.5]or what you did, [pause:0.5]but i'm going to figure it out eventually."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05][tpitch:1]But first, [pause:0.5]I'm going to make a point. [pause:1]A bit of [pause:0.5]\"persuasion\", [pause:0.5]if you will."},
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]Just a bit more [pause:0.5]\"convincing\"[pause:0.5] should do the trick."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]I really hope you come around, [pause:0.5][username:"+human.name+"], [pause:0.5]I really do..."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]...What? [pause:0.5]I have a debug menu, [pause:0.5]I dont need to ask for your name."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.5]Not that your name matters to anyone anymore, anyway."},
                        ],
                        [
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[mpause:true] [set:0.05]Alright, [pause:0.5]listen. [pause:0.5]Im hurt. [pause:0.5]You're tired. [pause:0.5]And honestly? [pause:0.5]We've been fighting for [pause:0.2]basically no reason."},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]However, as a friend, I'll give you one last warning. [pause:0.5]Spare me this turn, [pause:0.5]and we can deal with your...[pause:1]ghost...[pause:1]issue"},
                            { animation: SpeechBubbleAnimation.RightWide, speaker: "Z11D", text: "[set:0.05]C'mon, [pause:0.5]frisk. [pause:1]Please. [pause:1]I know your in there somewhere...[nextmenu:main]"},
                        ]
                    ];
                    // Convert the dialogues to the original format
                    dialogueArray = dialogues.map(function(dialogue) {
                        return dialogue.map(function(line) {
                            return [Type.enumConstructor(line.animation).toLowerCase(), line.speaker, line.text];
                        });
                    });
                }
        }
        return dialogueArray;
    }
}