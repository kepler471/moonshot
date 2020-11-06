# Moonshot!
## Project structure

* Tilemap.tscn - For storing all map tiles
* Main.tscn - Main running scene, containing game menu, pause menu etc.
* Assets - All enviroment sprites, backgrounds, tilesets
* Audio - All audio files
* Enemies - All enemy scenes and sprites
* Items - All item scenes and sprites
* Player - Player scenes and sprites
* Procedural Map Generation - all code relating to procedural map generation
* Room templates - Room template scenes 

├── Moonshot
│   ├── assets
│   │   ├── tileset.png
│   │   └── tileset.png.import
│   ├── default_env.tres
│   ├── player
│   │   ├── player.gd
│   │   ├── PLAYER.md
│   │   ├── player.tscn
│   │   ├── sealedbit_icon.png
│   │   └── sealedbit_icon.png.import
│   ├── procedural_map_generation
│   │   ├── Camera2D.gd
│   │   ├── Floor_Generator.gd
│   │   └── LevelGen.gd
│   ├── project.godot
│   ├── README.md
│   ├── room_templates
│   │   ├── room_1.tscn
│   │   └── room_entrance.tscn
│   ├── TileMap.tscn
│   └── WorldMap.tscn
├── README.md
└── scripts
    └── saveMain.sh
