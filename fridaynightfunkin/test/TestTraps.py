from . import FunkinTestBase


class TestNoTraps(FunkinTestBase):
    def test_no_traps(self) -> None:
        fnf = self.get_world()
        fnf.options.trapAmount.value = 0
        self.assertEqual(len(fnf.get_available_traps()), 0, "Got an available trap when we expected none.")