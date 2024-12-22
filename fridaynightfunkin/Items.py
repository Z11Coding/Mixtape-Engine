# Copyright (c) 2022 FelicitusNeko
#
# This software is released under the MIT License.
# https://opensource.org/licenses/MIT

import typing

from BaseClasses import Item, ItemClassification
from worlds.alttp import ALTTPWorld


class FunkinLttPText(typing.NamedTuple):
    pedestal: typing.Optional[str]
    sickkid: typing.Optional[str]
    magicshop: typing.Optional[str]
    zora: typing.Optional[str]
    fluteboy: typing.Optional[str]


LttPCreditsText = {
    "Nothing": FunkinLttPText("blank space",
                                "Forgot it at home again",
                                "Hallucinating again",
                                "Bucket o' Nothing for 9999.99",
                                "King Nothing"),
    "Score Bonus": FunkinLttPText("helpful hand",
                                    "Busy kid gets the point...s",
                                    "Variable conversion rate",
                                    "Stonks",
                                    "Catchy ad jingle"),
    "Task Advance": FunkinLttPText("hall pass",
                                     "Faker kid skips again",
                                     "I know a way around it",
                                     "Money can fix it",
                                     "Quick! A distraction"),
    "Starting Turner": FunkinLttPText("fidget spinner",
                                        "Spinning kid turns heads",
                                        "This turns things around",
                                        "Your turn to turn",
                                        "Turn turn turn"),
    "Reserved": FunkinLttPText("... wuh?",
                                 "Why's this here?",
                                 "Why's this here?",
                                 "Why's this here?",
                                 "Why's this here?"),
    "Starting Paint Can": FunkinLttPText("paint bucket",
                                           "Artsy kid paints again",
                                           "Your rainbow destiny",
                                           "Rainbow for sale",
                                           "Let me paint a picture"),
    "Booster Bumper": FunkinLttPText("multiplier",
                                       "Math kid multiplies again",
                                       "Growing shrooms",
                                       "Investment opportunity",
                                       "In harmony with themself"),
    "Hazard Bumper": FunkinLttPText("dull stone",
                                      "...I got better",
                                      "Mischief Maker",
                                      "Whoops for sale",
                                      "Stuck in a moment"),
    "Treasure Bumper": FunkinLttPText("odd treasure box",
                                        "Interdimensional treasure",
                                        "Shrooms for ???",
                                        "Who knows what this is",
                                        "You get what you give"),
    "Rainbow Trap": FunkinLttPText("chaos prism",
                                     "Roy G Biv in disguise",
                                     "The colors Duke! The colors",
                                     "Paint overstock",
                                     "Raise a little hell"),
    "Spinner Trap": FunkinLttPText("whirlwind",
                                     "Vertigo kid gets dizzy",
                                     "The room is spinning Dave",
                                     "International sabotage",
                                     "You spin me right round"),
    "Killer Trap": FunkinLttPText("broken board",
                                    "Thank you Mr Coffey",
                                    "Lethal dosage",
                                    "Assassin for hire",
                                    "Killer Queen"),
}


item_groups = {
    "Helpers": ["Task Advance", "Starting Turner", "Starting Paint Can"],
    "Targets": ["Treasure Bumper", "Booster Bumper", "Hazard Bumper"],
    "Traps": ["Rainbow Trap", "Spinner Trap", "Killer Trap"]
}


class FunkinItem(Item):
    game = "Friday Night Funkin"
    type: str

    def __init__(self, name, classification, code, player):
        super(FunkinItem, self).__init__(
            name, classification, code, player)

        if code is None:
            self.type = "Event"
        elif name in item_groups["Traps"]:
            self.type = "Trap"
            self.classification = ItemClassification.trap
        elif name in item_groups["Targets"]:
            self.type = "Target"
            self.classification = ItemClassification.progression
        elif name in item_groups["Helpers"]:
            self.type = "Helper"
            self.classification = ItemClassification.useful
        else:
            self.type = "Other"


offset = 595_000

item_table = {
    item: offset + x for x, item in enumerate(LttPCreditsText.keys())
}

ALTTPWorld.pedestal_credit_texts.update({item_table[name]: f"and the {texts.pedestal}"
                                         for name, texts in LttPCreditsText.items()})
ALTTPWorld.sickkid_credit_texts.update(
    {item_table[name]: texts.sickkid for name, texts in LttPCreditsText.items()})
ALTTPWorld.magicshop_credit_texts.update(
    {item_table[name]: texts.magicshop for name, texts in LttPCreditsText.items()})
ALTTPWorld.zora_credit_texts.update(
    {item_table[name]: texts.zora for name, texts in LttPCreditsText.items()})
ALTTPWorld.fluteboy_credit_texts.update(
    {item_table[name]: texts.fluteboy for name, texts in LttPCreditsText.items()})