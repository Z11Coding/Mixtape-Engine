# Copyright (c) 2022 FelicitusNeko
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

from BaseClasses import Item, MultiWorld, Tutorial, ItemClassification
from .Items import FunkinItem, item_table, item_groups
from .Locations import location_table
from .Options import *
from .Regions import create_regions
from worlds.AutoWorld import World, WebWorld
from worlds.generic.Rules import forbid_item


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

    item_name_to_id = item_table
    location_name_to_id = location_table
    item_name_groups = item_groups

    required_client_version = (0, 5, 0)

    options: FunkinOptions
    options_dataclass = FunkinOptions

    def __init__(self, multiworld: MultiWorld, player: int):
        super(FunkinWorld, self).__init__(multiworld, player)
        self.allow_mods = AllowMods.default
        self.starting_songs = SongStarters.default
        self.randomize_chart_modifier = ChartModifiers.default
        self.chart_modifier_change_chance = ChartModChangeChance.default
        # self.trap_percentage = Traps.default ill figure out this later
        self.unlock_type = UnlockType.default
        self.unlock_method = UnlockMethod.default

    def create_item(self, name: str) -> Item:
        return FunkinItem(name, ItemClassification.filler, item_table[name], self.player)

    def create_event(self, event: str) -> Item:
        return FunkinItem(event, ItemClassification.filler, None, self.player)

    def _create_item_in_quantities(self, name: str, qty: int) -> [Item]:
        return [self.create_item(name) for _ in range(0, qty)]

    def _create_traps(self):
        max_weight = self.rainbow_trap_weight + \
            self.spinner_trap_weight + self.killer_trap_weight
        rainbow_threshold = self.rainbow_trap_weight
        spinner_threshold = self.rainbow_trap_weight + self.spinner_trap_weight
        trap_return = [0, 0, 0]

        for i in range(self.traps):
            draw = self.multiworld.random.randrange(0, max_weight)
            if draw < rainbow_threshold:
                trap_return[0] += 1
            elif draw < spinner_threshold:
                trap_return[1] += 1
            else:
                trap_return[2] += 1

        return trap_return

    def get_filler_item_name(self) -> str:
        return "Nothing"

    def generate_early(self):
        self.allow_mods = self.options.allow_mods.value
        self.starting_songs = self.options.starting_songs.value
        self.randomize_chart_modifier = self.options.randomize_chart_modifier.value
        self.chart_modifier_change_chance = self.options.chart_modifier_change_chance.value
        # self.trap_percentage = Traps.default ill figure out this later
        self.unlock_type = self.options.unlock_type.value
        self.unlock_method = self.options.unlock_method.value

    def create_regions(self):
        create_regions(self.multiworld, self.player)

    def create_items(self):
        frequencies = [
            0, 0, self.task_advances, self.turners, 0, self.paint_cans, 5, 25, 33
        ] + self._create_traps()
        item_pool = []

        for i, name in enumerate(item_table):
            if i < len(frequencies):
                item_pool += self._create_item_in_quantities(
                    name, frequencies[i])

        item_delta = len(location_table) - len(item_pool)
        if item_delta > 0:
            item_pool += self._create_item_in_quantities(
                "Score Bonus", item_delta)

        self.multiworld.itempool += item_pool

    def set_rules(self):
        for treasure_count in range(1, 33):
            self.multiworld.get_location(f"Treasure Bumper {treasure_count}", self.player).access_rule = \
                lambda state, treasure_held = treasure_count: state.has("Treasure Bumper", self.player, treasure_held)
        for booster_count in range(1, 6):
            self.multiworld.get_location(f"Bonus Booster {booster_count}", self.player).access_rule = \
                lambda state, booster_held = booster_count: state.has("Booster Bumper", self.player, booster_held)
        self.multiworld.get_location("Level 5 - Cleared all Hazards", self.player).access_rule = \
            lambda state: state.has("Hazard Bumper", self.player, 25)
            
        self.multiworld.completion_condition[self.player] = \
            lambda state: state.has_all_counts({"Booster Bumper": 5, "Treasure Bumper": 32, "Hazard Bumper": 25}, \
                self.player)
