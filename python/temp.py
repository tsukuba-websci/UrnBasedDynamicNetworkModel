from typing import List
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
from tqdm import tqdm

import pandas as pd

df = pd.read_csv("twitter.csv")  # type: ignore


klasses: List[str] = list(df["class"])  # type: ignore
counts: List[int] = list(df["cumsum"])  # type: ignore


def select_color(klass: str):
    if klass == "c1":
        return "purple"
    elif klass == "c2":
        return "blue"
    elif klass == "c3":
        return "orange"
    elif klass == "c4":
        return "green"
    elif klass == "c5":
        return "red"
    else:
        return "white"


plt.rcParams["font.size"] = 16
plt.rcParams["font.family"] = "serif"
ax: plt.Axes = plt.gca()  # type: ignore

prev_count = counts[0]
for i, (klass, count) in tqdm(enumerate(zip(klasses[1:], counts[1:]))):
    color = select_color(klass)
    # plt.plot([i - 1, i], [prev_count, count], color=color, lw=2)  # type: ignore
    ax.add_patch(mpatches.Circle((i, count), 0.1, color=color))

    prev_count = count

plt.xlabel("Iterations")  # type: ignore
plt.ylabel("Cumulative number of activities ")  # type: ignore

patches = [
    mpatches.Patch(color="purple", label="class 1"),
    mpatches.Patch(color="blue", label="class 2"),
    mpatches.Patch(color="orange", label="class 3"),
    mpatches.Patch(color="green", label="class 4"),
    mpatches.Patch(color="red", label="class 5"),
]
plt.legend(handles=patches)  # type: ignore
plt.tight_layout()  # type: ignore
plt.savefig("twitter.png", dpi=600)  # type: ignore
