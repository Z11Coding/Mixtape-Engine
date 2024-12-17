package archipelago;

import flixel.FlxState;
import ap.Client;
import ap.PacketTypes.ClientStatus;
import ap.PacketTypes.NetworkItem;

import haxe.ds.Option;

// Enums
enum PrintJsonType {
    ItemSend, ItemCheat, Hint, Join, Part, Chat, ServerChat, Tutorial, TagsChanged, CommandResult, AdminCommandResult, Goal, Release, Collect, Countdown;
}

enum ClientStatus {
    CLIENT_UNKNOWN, CLIENT_CONNECTED, CLIENT_READY, CLIENT_PLAYING, CLIENT_GOAL;
}

enum PacketProblemType {
    cmd, arguments;
}

enum SetReplyPacketType {
    key, value, original_value;
}

enum ItemFlag {
    None, LogicalAdvancement, Important, Trap;
}

enum DataStorageOperationType {
    replace, default, add, mul, pow, mod, floor, ceil, max, min, and, or, xor, left_shift, right_shift, remove, pop, update;
}

enum ClientState {
    spectator, player, group;
}

enum Permission {
    disabled, enabled, goal, auto, auto_enabled;
}

// Types
typedef NetworkVersion = { major: Int, minor: Int, build: Int };
typedef NetworkPlayer = { team: Int, slot: Int, alias: String, name: String };
typedef NetworkItem = { item: Int, location: Int, player: Int, flags: Int };
typedef JSONMessagePart = { type: Option<String>, text: Option<String>, color: Option<String>, flags: Option<Int>, player: Option<Int> };
typedef Hint = { receiving_player: Int, finding_player: Int, location: Int, item: Int, found: Bool, entrance: String, item_flags: Int };
typedef GameData = { item_name_to_id: Map<String, Int>, location_name_to_id: Map<String, Int>, version: Int, checksum: String };
typedef NetworkSlot = { name: String, game: String, type: ClientState, group_members: Array<Int> };

// Packet Structures
typedef RoomInfoPacket = {
    version: NetworkVersion,
    generator_version: NetworkVersion,
    tags: Array<String>,
    password: Bool,
    permissions: Map<String, Permission>,
    hint_cost: Int,
    location_check_points: Int,
    games: Array<String>,
    datapackage_versions: Map<String, Int>,
    datapackage_checksums: Map<String, String>,
    seed_name: String,
    time: Float
};

typedef ConnectionRefusedPacket = { errors: Option<Array<String>> };
typedef ConnectedPacket = { team: Int, slot: Int, players: Array<NetworkPlayer>, missing_locations: Array<Int>, checked_locations: Array<Int>, slot_data: Map<String, Dynamic>, slot_info: Map<Int, NetworkSlot>, hint_points: Int };
typedef ReceivedItemsPacket = { index: Int, items: Array<NetworkItem> };
typedef LocationInfoPacket = { locations: Array<NetworkItem> };
typedef RoomUpdatePacket = { players: Array<NetworkPlayer>, checked_locations: Array<Int>, missing_locations: Array<Int> };
typedef PrintJSONPacket = { data: Array<JSONMessagePart>, type: Option<PrintJsonType>, receiving: Option<Int>, item: Option<NetworkItem>, found: Option<Bool>, team: Option<Int>, slot: Option<Int>, message: Option<String>, tags: Option<Array<String>>, countdown: Option<Int> };
typedef DataPackagePacket = { data: Dynamic };
typedef BouncedPacket = { games: Option<Array<String>>, slots: Option<Array<Int>>, tags: Option<Array<String>>, data: Option<Dynamic> };
typedef RetrievedPacket = { keys: Map<String, Dynamic> };
typedef SetReplyPacket = { key: String, value: Dynamic, original_value: Option<Dynamic> };
typedef ConnectPacket = { password: String, game: String, name: String, uuid: String, version: NetworkVersion, items_handling: Int, tags: Array<String>, slot_data: Option<Bool> };
typedef ConnectUpdatePacket = { items_handling: Int, tags: Array<String> };
typedef SyncPacket = {};
typedef LocationChecksPacket = { locations: Array<Int> };
typedef LocationScoutsPacket = { locations: Array<Int>, create_as_hint: Int };
typedef StatusUpdatePacket = { status: ClientStatus };
typedef SayPacket = { text: String };
typedef GetDataPackagePacket = { games: Option<Array<String>> };
typedef BouncePacket = { games: Option<Array<String>>, slots: Option<Array<Int>>, tags: Option<Array<String>>, data: Option<Dynamic> };
typedef GetPacket = { keys: Array<String> };
typedef SetPacket = { key: String, default: Dynamic, want_reply: Bool, operations: Array<DataStorageOperation> };
typedef SetNotifyPacket = { keys: Array<String> };


class GameState extends FlxState {

    public function new(ap:Client, slotData:Dynamic)
    {
        _ap = ap;
        _ap.clientStatus = ClientStatus.READY;
        _ap._hOnItemsReceived = onItemsReceived;
        _ap._hOnSocketDisconnected = onSocketDisconnect;

        super();
    }

}
