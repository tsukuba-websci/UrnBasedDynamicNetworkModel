from typing import List
import matplotlib.pyplot as plt
import matplotlib.patches as mpatches
import pandas as pd
from typing import List, TypeVar, Optional

plt.rcParams["font.size"] = 16
plt.rcParams["font.family"] = "serif"


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
        return "gray"


all_df = pd.read_csv("twitter.csv")  # type: ignore
fig, ax = plt.subplots()  # type: ignore
gd = all_df.groupby(by="class")  # type: ignore


T = TypeVar("T")


def first(v: List[T]) -> Optional[T]:
    if len(v) > 0:
        return v[0]
    return None


gd = list(
    filter(
        lambda v: v is not None,
        list(
            map(
                lambda c: first(list(filter(lambda tup: tup[0] == c, gd))),
                [
                    "c1",
                    "c3",
                    "c4",
                    "c5",
                    "unknown",
                    "c2",
                ],
            )
        ),
    )
)


for d in gd:
    color: str = d[0]  # type: ignore
    df: pd.DataFrame = d[1]  # type: ignore

    counts: List[int] = list(df["cumsum"])  # type: ignore

    plt.scatter(df.index, counts, color=select_color(color), s=10, alpha=0.5)  # type: ignore


patches = [
    mpatches.Patch(color="purple", label="class 1", alpha=0.5),
    mpatches.Patch(color="blue", label="class 2", alpha=0.5),
    mpatches.Patch(color="orange", label="class 3", alpha=0.5),
    mpatches.Patch(color="green", label="class 4", alpha=0.5),
    mpatches.Patch(color="red", label="class 5", alpha=0.5),
]
plt.legend(handles=patches)  # type: ignore
plt.xlabel("iteration")  # type: ignore
plt.ylabel("Cumulative number of activities")  # type: ignore
plt.tight_layout()  # type: ignore
plt.savefig("twitter.dot.png", dpi=300)  # type: ignore
