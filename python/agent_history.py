import pandas as pd
import os
import shutil
from typing import List, Tuple, Any, List, TypeVar, Optional
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
from tqdm import tqdm
import re
import matplotlib.pyplot as plt

plt.rcParams["font.family"] = "serif"
plt.rcParams["font.size"] = 16


##### パラメータ設定 #####
target_dataset = "twitter"
input_dir = f"results/agent_history/{target_dataset}"
output_dir = f"results/imgs/agent_history2/{target_dataset}"
########################


def select_color(klass):
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
        return "gray"


T = TypeVar("T")


def first(v: List[T]) -> Optional[T]:
    if len(v) > 0:
        return v[0]
    return None


def convert_marker(s: pd.Series):
    if s.call:
        return "^"
    elif s.called:
        return "v"
    else:
        return "o"


def marker_sort(t: Tuple[Any, pd.DataFrame]):
    if t[0] == "^":
        return 1
    elif t[0] == "v":
        return 2
    else:
        return 0


def extract_aid(filename: str) -> int:
    regex_result = re.search(r"(?<=history_)\d+(?=\.csv)", filename)
    assert regex_result is not None
    return int(regex_result.group())


input_files = os.listdir(input_dir)
input_files = sorted(input_files, key=extract_aid)

shutil.rmtree(output_dir, ignore_errors=True)
os.makedirs(output_dir)


def plot(input_file: str):

    regex_result = re.search(r"(?<=history_)\d+(?=\.csv)", input_file)
    assert regex_result is not None
    aid = regex_result.group()

    history_df = pd.read_csv(f"{input_dir}/{input_file}")

    history_df["marker"] = history_df[["call", "called"]].apply(convert_marker, axis=1)
    history_df["color"] = history_df["class"].apply(select_color)

    gd = history_df.groupby("marker")
    gd = sorted(list(gd), key=marker_sort)

    for marker, gdf in gd:
        plt.scatter(
            x=gdf.index,
            y=gdf["cumsum"],
            c=list(gdf["color"]),
            marker=marker,  # type: ignore
            edgecolors="none",
            s=25 if marker == "o" else 50,
            alpha=1,
        )

    plt.savefig(f"{output_dir}/{aid}_history", transparent=True)
    plt.close()


for input_file in tqdm(input_files):
    plot(input_file)
