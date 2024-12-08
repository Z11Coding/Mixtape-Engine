package modchart;

import flixel.addons.ui.FlxUIDropDownMenu;
import backend.Section.SwagSection;
import states.PlayState;
import backend.CoolUtil;
import backend.Conductor;
import backend.ClientPrefs;
import backend.Paths;
import states.LoadingState;
import backend.Difficulty;
import backend.MusicBeatSubstate;
import objects.Note;
import objects.StrumNote;
import backend.Song;
import psychlua.FunkinLua;
import psychlua.HScript as FunkinHScript;
#if sys
import sys.FileSystem;
import sys.io.File;
#end