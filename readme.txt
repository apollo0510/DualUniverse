how to use stuff in this repo :
===============================

First I recommend you install the "link shell extensions". It is up to you to choose one from the
internet. Instead of copying then files from the repo into your game directories, you would create
a hardlink. 

1.) Files in the "custom_config" folder are used to configure dynamic cores. Copy / link them
    into the "Dual Universe\Game\data\lua\autoconf" folder.
    When running the game, update custom configurations from advanced menu, and apply to
    the pilot seat.

2.) Files in the "custom_lua" folders are supposed to be copied / linked into the
    "Dual Universe\Game\data\lua" folder. They will be "required" by PB code.

3.) Files ending on ".json" can be copied to clipboard and loaded directly into a PB. 
    They contain the full slot configuration, but are not really readable.

4.) Files ending on ".lua" represent major code parts of the equivalent ".json" files.
    They do NOT contain any slot configuration and can NOT be loaded into a PB directly.
    But they are nicely readable. Usually you would see the "start" event of "unit" 
    where I put all my code.
