# Copyright (c) 2022 FelicitusNeko
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT
from BaseClasses import Region, Item, MultiWorld, Tutorial, ItemClassification
from typing import List, ClassVar, Type
from worlds.AutoWorld import World, WebWorld
from math import floor
from Options import PerGameCommonOptions

from .Items import FunkinItem, FunkinFixedItem
from .Locations import FunkinLocation
from .Options import *
from .FunkinUtils import FunkinUtils


class FunkinWeb(WebWorld):
    tutorials = [Tutorial(
        "Friday Night Funkin Setup Guide",
        "A guide to setting up the Friday Night Funkin Archipelago software on your computer.",
        "English",
        "setup_en.md",
        "setup/en",
        ["Z11Gaming and Yutamon"]
    )]
    theme = "partyTime"
    bug_report_page = "https://github.com/Z11Coding/Mixtape-Engine/issues"
    option_groups = fnf_option_groups


class FunkinWorld(World):
    """
        Friday Night Funkin' is a rhythm game in which 
        the player controls a character called Boyfriend, 
        who must defeat a series of opponents to continue dating 
        his significant other, Girlfriend. Now infused with the chaotic world
        of Archipelago.
    """

    game = "Friday Night Funkin"
    web = FunkinWeb()

    fnfUtil = FunkinUtils()
    filler_item_names = list(fnfUtil.filler_item_weights.keys())
    filler_item_weights = list(fnfUtil.filler_item_weights.values())

    item_name_to_id = {name: code for name, code in fnfUtil.item_names_to_id.items()}
    location_name_to_id = {name: code for name, code in fnfUtil.location_names_to_id.items()}
    required_client_version = (0, 5, 0)
    topology_present = False
    options: FunkinOptions
    options_dataclass: ClassVar[Type[PerGameCommonOptions]] = FunkinOptions
    origin_region_name = "Freeplay"

    victory_song_name: str = ""
    location_count: int
    songList: List[str]

    def __init__(self, multiworld: MultiWorld, player: int):
        super(FunkinWorld, self).__init__(multiworld, player)
        self.allow_mods = AllowMods.default
        self.starting_song = SongStarter.default
        self.unlock_type = UnlockType.default
        self.unlock_method = UnlockMethod.default
        FNFBaseList.localSongList = songList.default
        self.trapAmount = trapAmount.default
        self.bbc_weight = bbcWeight.default
        self.ghost_chat_weight = ghostChatWeight.default
        self.svc_effect_weight = svcWeight.default
        self.tutorial_trap_weight = tutorialWeight.default
        self.fake_transition_weight = fakeTransWeight.default
        self.shield_weight = shieldWeight.default
        self.max_hp_weight = MHPWeight.default
        self.chart_modifier_change_chance = ChartModChangeChance.default
        self.ticket_percentage = TicketPercentage.default
        self.ticket_win_percentage = TicketWinPercentage.default

    def create_item(self, name: str) -> Item:
        if name == self.fnfUtil.SHOW_TICKET_NAME:
            return FunkinFixedItem(name, ItemClassification.progression_skip_balancing,
                                     self.fnfUtil.SHOW_TICKET_CODE, self.player)

        filler = self.fnfUtil.filler_items.get(name)
        if filler:
            return FunkinFixedItem(name, ItemClassification.filler, filler, self.player)

        trap = self.fnfUtil.trap_items.get(name)
        if trap:
            return FunkinFixedItem(name, ItemClassification.trap, trap, self.player)

        song = self.fnfUtil.song_items.get(name)
        return FunkinItem(name, self.player, song)

    def create_event(self, event: str) -> Item:
        return FunkinItem(event, ItemClassification.filler, None, self.player)

    def _create_item_in_quantities(self, name: str, qty: int) -> [Item]:
        return [self.create_item(name) for _ in range(0, qty)]

    def _create_traps(self):
        trap_return = [0, 0, 0, 0, 0]

        for i in range(self.trapAmount):
            draw = self.multiworld.random.randrange(0, self.trapAmount)
            if draw < self.bbc_weight:
                trap_return[0] += 1
            elif draw < self.ghost_chat_weight:
                trap_return[1] += 1
            elif draw < self.svc_effect_weight:
                trap_return[2] += 1
            elif draw < self.tutorial_trap_weight:
                trap_return[3] += 1
            elif draw < self.fake_transition_weight:
                trap_return[4] += 1
            '''elif draw < self.e_weight: soon
                trap_return[5] += 1'''

        return trap_return

    def _create_traps_string(self): # god this sucks
        trap_return = ["", "", "", "", "", ""]

        for i in range(self.trapAmount):
            draw = self.multiworld.random.randrange(0, self.trapAmount)
            if draw < self.bbc_weight:
                trap_return[0] += "Blue Balls Curse"
            elif draw < self.ghost_chat_weight:
                trap_return[1] += "Ghost Chat"
            elif draw < self.svc_effect_weight:
                trap_return[2] += "SvC Effect"
            elif draw < self.tutorial_trap_weight:
                trap_return[3] += "Tutorial Trap"
            elif draw < self.fake_transition_weight:
                trap_return[4] += "Fake Transition"
            '''elif draw < self.e_weight: # soon
                trap_return[5] += "E"'''

        return trap_return

    def get_filler_item_name(self) -> str:
        return self.random.choices(self.filler_item_names, self.filler_item_weights)[0]

    def get_available_traps(self) -> List[str]:
        full_trap_list = self.fnfUtil.trap_items_but_as_an_array_because_python_thats_why.copy()
        trapString = self._create_traps_string()
        traps: List[str] = []
        for num in range(0, len(full_trap_list)):
            if trapString != "":
                traps.append(trapString[num])
        return traps

    def generate_early(self):
        # Basic Settings
        self.allow_mods = self.options.allow_mods.value
        self.starting_song = self.options.starting_song.value
        self.unlock_type = self.options.unlock_type.value
        self.unlock_method = self.options.unlock_method.value
        FNFBaseList.localSongList = FNFBaseList.globalSongList.copy()
        # Trap Settings
        self.trapAmount = self.options.trapAmount.value
        self.bbc_weight = self.options.bbcWeight.value
        self.ghost_chat_weight = self.options.ghostChatWeight.value
        self.svc_effect_weight = self.options.svcWeight.value
        self.tutorial_trap_weight = self.options.tutorialWeight.value
        self.shield_weight = self.options.shieldWeight.value
        self.max_hp_weight = self.options.MHPWeight.value
        self.chart_modifier_change_chance = self.options.chart_modifier_change_chance.value
        self.ticket_percentage = self.options.ticket_percentage.value
        self.ticket_win_percentage = self.options.ticket_win_percentage.value
        #self.e_weight = self.options.trapAmount.value later
        # The minimum amount of songs to make an ok rando would be Starting Songs + 10 interim songs + Goal song.
        # - Interim songs being equal to max starting song count.
        # Note: The worst settings still allow 25 songs (Streamer Mode + No DLC).
        available_song_keys = FNFBaseList.localSongList
        self.create_song_pool(available_song_keys)
        for song in self.starting_song:
            self.multiworld.push_precollected(self.create_item(song))

    def create_regions(self):
        menu_region = Region("Freeplay", self.player, self.multiworld)
        self.multiworld.regions += [menu_region]

        all_selected_locations:List[str] = FNFBaseList.localSongList.copy()
        self.random.shuffle(all_selected_locations)

        # Adds 1 item locations per song to the menu region.
        while len(all_selected_locations) > 0:
            name = all_selected_locations[0]
            loc1 = FunkinLocation(self.player, name, self.fnfUtil.song_locations[name], menu_region)
            loc1.access_rule = lambda state, place=name: state.has(place, self.player)
            menu_region.locations.append(loc1)
            all_selected_locations.remove(name)

    def create_song_pool(self, available_song_keys: List[str]):
        if self.options.starting_song.value != "":
            starting_song_count = 1
        else:
            starting_song_count = 0
        self.random.shuffle(available_song_keys)
        song_count = len(FNFBaseList.localSongList)
        # choose a random victory song from the available songs
        chosen_song = self.random.randrange(0, len(available_song_keys))
        if chosen_song < song_count:
            self.victory_song_name = FNFBaseList.localSongList[chosen_song]
            del FNFBaseList.localSongList[chosen_song]
        else:
            self.victory_song_name = available_song_keys[chosen_song - song_count]
            del available_song_keys[chosen_song - song_count]

        # Then attempt to fulfill any remaining songs for interim songs
        if len(FNFBaseList.localSongList) < song_count:
            for _ in range(0, len(FNFBaseList.localSongList)):
                if len(available_song_keys) <= 0:
                    break
                FNFBaseList.localSongList.append(available_song_keys.pop())

        self.location_count = len(FNFBaseList.globalSongList)

    def create_items(self) -> None:
        song_keys_in_pool = FNFBaseList.localSongList.copy()
        item_count = self.get_ticket_count()

        # First add all goal song tokens


        # Then add 1 copy of every song
        item_count += len(FNFBaseList.localSongList)
        for song in FNFBaseList.localSongList:
            self.multiworld.itempool.append(self.create_item(song))

        # Then add all traps, making sure we don't over fill
        trap_count = min(self.location_count - item_count, self.get_trap_count())
        trap_list = self.get_available_traps()
        if len(trap_list) > 0 and trap_count > 0:
            for _ in range(0, trap_count):
                index = self.random.randrange(0, len(trap_list))
                self.multiworld.itempool.append(self.create_item(trap_list[index]))

            item_count += trap_count

        # At this point, if a player is using traps, it's possible that they have filled all locations
        items_left = self.location_count - item_count
        if items_left <= 0:
            return

        # When it comes to filling remaining spaces, we have 2 options. A useless filler or additional songs.
        # First fill 50% with the filler. The rest is to be duplicate songs.
        filler_count = floor(0.5 * items_left)
        items_left -= filler_count

        for _ in range(0, filler_count):
            self.multiworld.itempool.append(self.create_item(self.get_filler_item_name()))

        # All remaining spots are filled with duplicate songs. Duplicates are set to useful instead of progression
        # to cut down on the number of progression items that Muse Dash puts into the pool.

        # This is for the extraordinary case of needing to fill a lot of items.
        while items_left > len(song_keys_in_pool):
            for key in song_keys_in_pool:
                item = self.create_item(key)
                item.classification = ItemClassification.useful
                self.multiworld.itempool.append(item)
            items_left -= 1

        # Otherwise add a random assortment of songs
        self.random.shuffle(song_keys_in_pool)
        for i in range(0, len(song_keys_in_pool)):
            item = self.create_item(song_keys_in_pool[i])
            item.classification = ItemClassification.useful
            self.multiworld.itempool.append(item)

    def set_rules(self) -> None:
        self.multiworld.completion_condition[self.player] = lambda state: \
            state.has(self.fnfUtil.SHOW_TICKET_NAME, self.player, self.get_ticket_win_count())

    def get_trap_count(self) -> int:
        multiplier = self.options.trapAmount.value / 100.0
        trap_count = len(FNFBaseList.localSongList)
        return max(0, floor(trap_count * multiplier))

    def get_ticket_count(self) -> int:
        multiplier = self.options.ticket_percentage.value / 100.0
        song_count = len(FNFBaseList.localSongList)
        return max(1, floor(song_count * multiplier))

    def get_ticket_win_count(self) -> int:
        multiplier = self.options.ticket_win_percentage.value / 100.0
        ticket_count = self.get_ticket_count()
        return max(1, floor(ticket_count * multiplier))

    def fill_slot_data(self):
        return {
            "deathLink": self.options.death_link.value,
            "fullSongCount": len(FNFBaseList.localSongList),
            "victoryLocation": self.victory_song_name,
        }