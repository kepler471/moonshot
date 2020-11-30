"""
Place in a directory to rename any rooms with the name 'Room Root' to their filename.
Any rooms built from 'room_CANVAS.tscn' will be called 'Room Root'
"""

from pathlib import Path

path = Path.cwd()

SEARCH = "Room Root"

for f in path.iterdir():
    if not f.name.endswith('py') and f.name.endswith('tscn'):
        with open(f, "r") as room:
            scene = room.readlines()
            for n, line in enumerate(scene):
                if SEARCH in line:
                    scene[n] = line.replace(SEARCH, f.name.split('.')[0])
                    break

        with open(f, "w") as new_scene:
            new_scene.writelines(scene)
