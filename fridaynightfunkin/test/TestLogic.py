import unittest
from ..FunkinUtils import FunkinUtils


class TestRuleLogic(unittest.TestCase):
    def test_all_names_are_ascii(self) -> None:
        bad_names = list()
        fnfutil = FunkinUtils()
        for name in fnfutil.song_items.keys():
            for c in name:
                # This is taken directly from Muse Dash taken directly from OoT. Represents the generally excepted characters.
                if 0x20 <= ord(c) < 0x7e:
                    continue

                bad_names.append(name)
                break

        self.assertEqual(len(bad_names), 0,
                         f"Friday Night Funkin has {len(bad_names)} songs with non-ASCII characters.\n{bad_names}")

    def test_ids_dont_change(self) -> None:
        collection = FunkinUtils()
        items_before = {name: code for name, code in collection.item_names_to_id.items()}
        locations_before = {name: code for name, code in collection.location_names_to_id.items()}

        collection.__init__()
        items_after = {name: code for name, code in collection.item_names_to_id.items()}
        locations_after = {name: code for name, code in collection.location_names_to_id.items()}

        self.assertDictEqual(items_before, items_after, "Item ID changed after secondary init.")
        self.assertDictEqual(locations_before, locations_after, "Location ID changed after secondary init.")