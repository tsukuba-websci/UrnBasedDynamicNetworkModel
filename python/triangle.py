import pandas as pd
import matplotlib.pyplot as plt
import os
import shutil
from typing import List, Tuple, Any, List, TypeVar, Optional
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
from tqdm import tqdm


##### パラメータ設定 #####
target_dataset = "twitter"
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


plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["font.size"] = 16

df = pd.read_csv(f"results/triangle/{target_dataset}/data.csv")

output_dir = f"results/imgs/triangle/{target_dataset}"
shutil.rmtree(output_dir, ignore_errors=True)
os.makedirs(output_dir)


for index, target in tqdm(df.iterrows()):
    plt.scatter(x=df["interval"], y=df["birthstep"], alpha=0.5)

    target_df = df[df["aid"] == target.aid]
    plt.scatter(x=target_df["interval"], y=target_df["birthstep"], c="red", alpha=1)
    plt.xlabel("interval")
    plt.ylabel("birth-iteration")
    plt.tight_layout()
    plt.savefig(f"{output_dir}/{target.aid}_triangle.png", dpi=300)
    plt.close()

    history_df = pd.read_csv(
        f"results/triangle/{target_dataset}/history_{target.aid}.csv"
    )

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

    patches = [
        mpatches.Patch(color="purple", label="class 1", alpha=0.5),
        mpatches.Patch(color="blue", label="class 2", alpha=0.5),
        mpatches.Patch(color="orange", label="class 3", alpha=0.5),
        mpatches.Patch(color="green", label="class 4", alpha=0.5),
        mpatches.Patch(color="red", label="class 5", alpha=0.5),
    ]
    plt.legend(handles=patches)
    plt.xlabel("iteration")
    plt.ylabel("Cumulative number of activities")
    plt.tight_layout()
    plt.savefig(f"{output_dir}/{target.aid}_history.png", dpi=300)
    plt.close()
