# Friday Night Funkin' - Mixtape Engine

Modded Psych with a heavy focus on Modcharting Capabilities and New (Cool) Features

## Installation:
You must have [the most up-to-date version of Haxe](https://haxe.org/download/), seriously, stop using 4.1.5, it misses some stuff.

Follow a Friday Night Funkin' source code compilation tutorial, after this you will need to install LuaJIT.

To install LuaJIT do this: `haxelib git linc_luajit https://github.com/nebulazorua/linc_luajit` on a Command prompt/PowerShell

...Or if you don't want your mod to be able to run .lua scripts, delete the "LUA_ALLOWED" line on Project.xml


If you get an error about StatePointer when using Lua, run `haxelib remove linc_luajit` into Command Prompt/PowerShell, then re-install linc_luajit.

If you want video support on your mod, simply do `haxelib install hxCodec` on a Command prompt/PowerShell

otherwise, you can delete the "VIDEOS_ALLOWED" Line on Project.xml

## Credits:
* Z11Coding - Lead Programmer
* [NebulaTheZorua](https://bsky.app/profile/nebulazorua.bsky.social) - LuaJIT Fork, Input System, Modcharting System, Sustain Renderer
* [crowplexus](https://bsky.app/profile/crowplexus.bsky.social) - Custom Judgment Sprites

## Psych Credits:
* [ShadowMario](https://x.com/Shadow_Mario_) - Programmer
* [Riveren](https://x.com/riverennn) - Artist
* [bbpanzu](https://x.com/bbpnz213) - Ex-Programmer
* [KadeDev](https://x.com/kade0912) - Chart Editor Fixes
* [SqirraRNG](https://x.com/sqirradotdev) - Crash Handler, Chart Editor's Waveform
* [iFlicky](https://x.com/flicky_i) - Composer of Psync and Tea Time, also made the Dialogue Sounds
* [PolybiusProxy](https://x.com/polyproxy) - .MP4 Video Loader Library (hxCodec)
* [Keoiki](https://x.com/Keoiki_) - Note Splash Animations
* Smokey - Sprite Atlas Support

_____________________________________
