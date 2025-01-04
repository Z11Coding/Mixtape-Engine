from test.bases import WorldTestBase
from .. import FunkinWorld
from typing import cast

class FunkinTestBase(WorldTestBase):
    game = "Friday Night Funkin"

    def get_world(self) -> FunkinWorld:
        return cast(FunkinWorld, self.multiworld.worlds[1])

