# Copyright (c) 2022 FelicitusNeko
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

from dataclasses import dataclass

from typing import List
from Options import Toggle, OptionSet, Option, Range, PerGameCommonOptions

# Unless I organize it, this is gonna chill here for now
class FNFBaseList:
    baseSongs: List[str] = [
            "Bopeebo", "Fresh", "Dad Battle",
            "Spookeez", "South", "Monster",
            "Pico", "Philly Nice", "Blammed",
            "Satin Panties", "High", "Milf",
            "Cocoa", "Eggnog", "Winter Horrorland",
            "Senpai", "Roses", "Thorns",
            "Ugh", "Guns", "Stress",
            "Darnell", "Lit Up", "2Hot", "Blazin",
            "Darnell (BF Mix)", ""
        ]


class AllowMods(Toggle):
    """Enables the ability to use mods for your run. 
    (Should be kept off if you don't have any mods.)
    """
    display_name = "Enable Mods"
    default = False


class SongStarters(OptionSet):
    """The songs you wish to start with. 
    (Tutorial is recommended, but not required. 
    Any song will work. Or none at all if that's your thing.)"""
    display_name = "Starting Songs"
    valid_keys = [song for song in FNFBaseList.baseSongs]
    default = "Tutorial"


class ChartModifiers(OptionSet):
    """
        Modifiers that take place at the beginning of a song 
        to mess with the notes.
    """
    display_name = "Chart Modifiers"
    valid_keys = ["Always", "Sometimes", "Never"]
    default = "Never"


class ChartModChangeChance(Range):
    """
        The amount of times you'll get a Chart Modifier Trap.
    """
    display_name = "Chart Modifier Trap Count"
    range_start = 0
    range_end = 18
    default = 0

class UnlockType(OptionSet):
    """The way you wish to unlock songs."""
    display_name = "Unlock Type"
    valid_keys = ["Per Song", "Per Week"]
    default = "Per Song"


class UnlockMethod(OptionSet):
    """The way you wish to get checks."""
    display_name = "Check Method"
    valid_keys = ["Note Checks", "Song Completion"]
    default = "Note Checks"


@dataclass
class FunkinOptions(PerGameCommonOptions):
    allow_mods: AllowMods
    starting_songs: SongStarters
    randomize_chart_modifier: ChartModifiers
    chart_modifier_change_chance: ChartModChangeChance
    unlock_type: UnlockType
    unlock_method: UnlockMethod