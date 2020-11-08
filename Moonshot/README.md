# Moonshot!
## Project structure

* Main.tscn - Main running scene, containing game menu, pause menu etc.
* Assets - All enviroment sprites, backgrounds, tilesets
* Audio - All audio files
* Enemies - All enemy scenes and sprites
* Items - All item scenes and sprites
* Player - Player scenes and sprites
* Procedural Map Generation - all code relating to procedural map generation
* Room templates - Room template scenes 

Files:

    ├── Moonshot
    │   ├── assets
    │   │   └── tile_maps
    │   │       ├── SimpleTileMap.png
    │   │       └── SimpleTileset.tres
    │   ├── default_env.tres
    │   ├── player
    │   │   ├── 32x32_Medic
    │   │   │   ├── img1.png
    │   │   │   ├── img1.png.import
    │   │   │   ├── img3.png
    │   │   │   ├── img3.png.import
    │   │   │   ├── img5.png
    │   │   │   └── img5.png.import
    │   │   ├── player.gd
    │   │   ├── player.tscn
    │   │   ├── README.md
    │   │   └── test_idle.gif
    │   ├── procedural_map_generation
    │   │   ├── drag_camera.gd
    │   │   ├── Floor_Generator.gd
    │   │   ├── level_generation_test.tscn
    │   │   └── level_gen.gd
    │   ├── project.godot
    │   ├── README.md
    │   ├── room_templates
    │   │   ├── LevelConcepts.png
    │   │   ├── room_1.tscn
    │   │   └── room_entrance.tscn
    │   └── TileMap.tscn
    ├── README.md
    └── scripts
        └── saveMain.sh
