"""
Generate counts for all room exit orientations in the current directory.
Assumes all are labelled as "room_XXXX_name.tscn", with the correct room
label order: U > D > L > R
"""
from pathlib import Path
import pandas as pd

cwd = Path.cwd()

tags = [f.name.split('_')[1]for f in cwd.iterdir() if 'room' in f.name]
counts = {t: tags.count(t) for t in set(tags)}
order = {t: len(t) for t in counts.keys()}
combine = {t: [counts[t], order[t]] for t in counts}
df = pd.DataFrame.from_dict(combine, orient='index', columns=['Counts', '_order'])
df.index.name = 'Exits'
df = df.sort_values(by='_order', ascending=False).drop(columns=['_order'])
print(df)

## If you pip install tabulate you can also run the following line
# df.to_markdown()