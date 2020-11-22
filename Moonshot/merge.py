"""
merge.py looks through generated scenes, and writes a new file as
a copy of room_CANVAS.tscn, replacing its tile_data with generated
tile data.
"""

from pathlib import Path

path = Path.cwd()
pgen = path / "MSTDungeon"
canvas = open(path / "room_CANVAS.tscn", "r")
canvas_data = canvas.readlines()
canvas.close()
write_at = 0
for n, i in enumerate(canvas_data):
    if i.startswith("tile_data"):
        print(i)
        write_at = n


for f in pgen.iterdir():
    if f.name.startswith("room"):
        with open(f, "r") as gen_data:
            for line in gen_data.readlines():
                if line.startswith("tile_data"):
                    tile_data = line

        canvas_data[write_at] = tile_data
        file_name = pgen / (f.name.split(".")[0] + "_CANVAS.tscn")
        print(file_name)
        with open(file_name.name, "w") as new_file:
            new_file.writelines(canvas_data)
