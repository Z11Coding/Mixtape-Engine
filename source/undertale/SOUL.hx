package undertale;

import flixel.FlxSprite;
import undertale.BULLETPATTERN;

enum SOULTYPES
{
    RED;
    BLUE;
    YELLOW;
    PURPLE;
}

class SOUL {
    public var health:Float = 20;
    public var maxHealth:Float = 20;
    public var type:SOULTYPES = RED;
    public var name:String = 'UNKNOWN';
    public var storage:Array<String>;
    public var curWeapon:String = 'Stick';
    public var curArmor:String = 'Bandage';
   @:isVar public var weapon(get, set):ITEM;
   @:isVar public var armor(get, set):ITEM;
    public var LOVE:Int = 1;
    public var gold:Int = 0;
    public var atk:Int = 1;
    public var addAtk:Int = 0;
    public var def:Int = 0;
    public var addDef:Int = 0;
    public var sprite:FlxSprite;
    public static var instance:SOUL;
    private var damageCooldown:Float = 0;
    private var cooldownTime:Float = 1.0; // 1 second cooldown

    public function new(type:SOULTYPES = RED, name:String = 'UNKNOWN', LOVE:Int = 1, daWeapon:String = 'Stick', daArmor:String = 'Bandage') {
        this.type = type;
        this.name = name;
        this.LOVE = LOVE;
        this.sprite = getSoulSprite();
        this.storage = [];
        this.curWeapon = daWeapon;
        this.curArmor = daArmor;
        for (item in new ITEMS().items.keys()) {
            this.storage.push(item);
        }
        instance = this;
        setStats(LOVE);
    }

    function setStats(LOVE:Int) {
        if (LOVE <= 19)
        {
            this.health = Std.int(16 + (4 * LOVE));
            this.maxHealth = Std.int(16 + (4 * LOVE));
            this.atk = Std.int(-2 + (2 * LOVE)+1);
            this.def = Std.int((LOVE - 1) / 4);
            ITEMS.instance.useItem(curWeapon);
            ITEMS.instance.useItem(curArmor);
        }
        else
        {
            this.health = 99;
            this.maxHealth = 99;
            this.atk = 38;
            this.def = 4;
            this.LOVE = 20;
            ITEMS.instance.useItem(curWeapon);
            ITEMS.instance.useItem(curArmor);
        }
    }

    function getSoulSprite():FlxSprite {
        this.sprite = new FlxSprite(0, 0, Paths.image('undertale/soul/soul'));
        return this.sprite;
    }

    public function update(elapsed:Float, soul:FlxSprite):Void {
        if (damageCooldown > 0) {
            damageCooldown -= elapsed;
            switch (damageCooldown%2)
            {
                case 0:
                    soul.color = FlxColor.fromString('#FF0000');
                case 1:
                    soul.color = FlxColor.fromString('#8f0000');
            }
        }
    }

    public function applyDamage(damageType:DamageType, damage:Float):Void {
        if (damageType.getType() != "NONE" && (damageType.getType() == "KARMA" || damageCooldown <= 0)) {
            if (health > 0) 
            {
                health -= damage;
                FlxG.sound.play(Paths.sound('ut/hurtsound'));
            }
            if (damageType.getType() != "KARMA") {
                damageCooldown = cooldownTime;
            }
        }
    }

    public function get_weapon():ITEM {
        return weapon;
    }

    private function set_weapon(value:ITEM):ITEM {
        switch (ITEMS.getItemType(value.action)) {
            case ITEMTYPE.WEAPON(_):
                weapon = value;
            default:
                throw "Invalid item type for weapon. Expected ITEMTYPE.WEAPON.";
        }
        return value;
    }

    public function get_armor():ITEM {
        return armor;
    }
    
    private function set_armor(value:ITEM):ITEM {
        switch (ITEMS.getItemType(value.action)) {
            case ITEMTYPE.ARMOR(_):
                armor = value;
            default:
                throw "Invalid item type for armor. Expected ITEMTYPE.ARMOR.";
        }
        return value;
    }
}

enum ITEMTYPE
{
    FOOD(?action:Void -> Void);
    WEAPON(?action:Void -> Void);
    ARMOR(?action:Void -> Void);
    KEY(?action:Void -> Void);
}

enum ACTION
{
    HEAL;
    ITEM(type:ITEMTYPE);
}
class ITEM {
    public var name:String;
    public var action:ACTION;
    public var value:Float;
    public var flavorText:String = 'This item doesn\'t have flavor text!\nOh, the horror!';
    public function new(name:String, action:ACTION, ?value:Float = 0, ?flavorText:String = 'This item doesn\'t have flavor text!\nOh, the horror!')
    {
        this.name = name;
        this.action = action;
        this.value = value;
        this.flavorText = flavorText;
    }
}
class ITEMS {
    public static var instance:ITEMS;
    public var items:Map<String, ITEM>;

    public function new() {
        instance = this;
        items = new Map<String, ITEM>();
        items.set('Stick', new ITEM('Stick', ACTION.ITEM(ITEMTYPE.WEAPON(() -> null)), 0, '[set:0.05]You equipped the Stick![pause:0.5]\nYou feel a little more powerful...'));
        items.set('Bandage', new ITEM('Bandage', ACTION.ITEM(ITEMTYPE.ARMOR(() -> null)), 0, '[set:0.05]You applied the Bandage![pause:0.5]\nYou feel a little better...'));
        items.set('Real Knife', new ITEM('Real Knife', ACTION.ITEM(ITEMTYPE.WEAPON(() -> null)), 99, '[set:0.05]You equipped the Real Knife.[pause:0.5]\nHere we are!'));
        items.set('The Locket', new ITEM('The Locket', ACTION.ITEM(ITEMTYPE.ARMOR(() -> null)), 99, '[set:0.05]You applied The Locket.[pause:0.5]\nYou can feel it beating.'));
        items.set('error', new ITEM('error', HEAL, 0, "[set:0.05]If you're reading this...[pause:0.5]\nyou messed up somewhere!"));
        items.set('Food 1', new ITEM('Food 1', HEAL, 10, '[set:0.05]You ate the Food 1![pause:0.5]\nYou healed 10HP and passed the test!'));
        items.set('Food 2', new ITEM('Food 2', HEAL, 20, '[set:0.05]You ate the Food 2![pause:0.5]\nSpicy![pause:0.5]\nYou healed 20HP'));
        items.set('Food 3', new ITEM('Food 3', HEAL, 1, '[set:0.05]You ate the Food 3![pause:0.5]\nEw. [pause:0.1]it\'s cold...[pause:0.5]\nYou healed 1HP anyway, though...'));
    }
    public static function getItemByName(name:String):ITEM {
        return instance.items.get(name);
    }

    
    public static function getItemType(action:ACTION):ITEMTYPE {
        switch (action) {
            case ITEM(itemType):
                return itemType;
            default:
                throw "Unknown action type.";
        }
    }

    public static function isWeapon(action:ACTION):Bool {
        switch (getItemType(action)) {
            case ITEMTYPE.WEAPON(_):
                return true;
            default:
                return false;
        }
    }

    public static function isArmor(action:ACTION):Bool {
        switch (getItemType(action)) {
            case ITEMTYPE.ARMOR(_):
                return true;
            default:
                return false;
        }
    }



    public function heal(value:Float):Void {
        SOUL.instance.health += Std.int(value);
        if (SOUL.instance.health > SOUL.instance.maxHealth) {
            SOUL.instance.health = SOUL.instance.maxHealth;
        }
    }

    public function useItem(itemName:String):ITEM {
        var item:ITEM = ITEMS.getItemByName(itemName);
        if (item != null) {
            SOUL.instance.storage.remove(itemName);
            // Perform the action associated with the item
            switch (item.action) {
                case HEAL:
                    heal(item.value);
                case ITEM(ITEMTYPE.WEAPON(action)):
                    if (action != null) {
                        action();
                    }
                    SOUL.instance.atk -= Std.int(SOUL.instance.addAtk);
                    SOUL.instance.addAtk += Std.int(item.value);
                    SOUL.instance.atk += Std.int(SOUL.instance.addAtk);

                case ITEM(ITEMTYPE.ARMOR(action)):
                    if (action != null) {
                        action();
                    }
                    SOUL.instance.def -= Std.int(SOUL.instance.addDef);
                    SOUL.instance.addDef += Std.int(item.value);
                    SOUL.instance.def += Std.int(SOUL.instance.addDef);

                case ITEM(ITEMTYPE.KEY(action)):
                    // Nothing to do here
                case ITEM(ITEMTYPE.FOOD(action)):
                    heal(item.value);
                    if (action != null) {
                        action();
                    }
            }
        }
        return item;
    }

    function checkItemType(itemType:ITEMTYPE):String {
        switch (itemType) {
            case FOOD(_):
                return "This is a FOOD item.";
            case WEAPON(_):
                return "This is a WEAPON item.";
            case ARMOR(_):
                return "This is an ARMOR item.";
            case KEY(_):
                return "This is a KEY item.";
        }
    }
}
