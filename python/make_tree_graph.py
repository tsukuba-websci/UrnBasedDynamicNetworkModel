import argparse
import os
import sys
from typing import Any, Dict
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib import patches


# COLUMNS = {
#     'id': 'key',
#     'parent': 'parent',
#     'birth': 'iteration'
# }

COLUMNS = {"id": "dst", "parent": "src", "birth": "birthstep"}


def make_graph_attr1(
    df: pd.DataFrame,
    radius_max: int,
    radius_min_ratio: float,
    radius_init: float = 0.0,
    root_key: int = -1,
):
    parent_children = {key: child for key, child in df.groupby(COLUMNS["parent"])}
    angle_num = len(df)

    attrs = {}
    nodes_tmp = []  # just use for angle indexer

    def recursive(row, radius1):
        key = row[COLUMNS["id"]]
        theta = len(nodes_tmp) / angle_num * 2 * np.pi
        radius2 = (
            row[COLUMNS["birth"]] / radius_max * (1 - radius_min_ratio)
            + radius_min_ratio
        )
        nodes_tmp.append(key)

        if key in parent_children:
            children = parent_children[key]
            thetas = [recursive(row, radius2) for _, row in children.iterrows()]
            arc = [theta / np.pi * 180, max(thetas) / np.pi * 180]
        else:
            arc = []

        attrs[key] = {
            "radius1": radius1,
            "radius2": radius2,
            "theta": theta,
            "arc": arc,
        }
        return theta

    for _, row in parent_children[root_key].iterrows():
        recursive(row, radius_init)

    grids = [(key, attr["theta"]) for key, attr in attrs.items()]

    return attrs, grids


def make_graph_attr2(df, radius_max, radius_min_ratio, radius_init=0.0, root_key=-1):
    parent_children = {key: child for key, child in df.groupby(COLUMNS["parent"])}
    angle_num = len(set(df[COLUMNS["id"]]) - set(parent_children.keys()))

    attrs = {}
    leafs = []

    def reccursive(row, radius1):
        key = row[COLUMNS["id"]]
        radius2 = (
            row[COLUMNS["birth"]] / radius_max * (1 - radius_min_ratio)
            + radius_min_ratio
        )
        if key in parent_children:
            children = parent_children[key]
            thetas = [reccursive(row, radius2) for _, row in children.iterrows()]
            mn, mx = np.min(thetas), np.max(thetas)
            theta = (mx + mn) / 2
            arc = [mn / np.pi * 180, mx / np.pi * 180]
        else:
            theta = len(leafs) / angle_num * 2 * np.pi
            arc = []
            leafs.append(key)

        attrs[key] = {
            "radius1": radius1,
            "radius2": radius2,
            "theta": theta,
            "arc": arc,
        }
        return theta

    for _, row in parent_children[root_key].iterrows():
        reccursive(row, radius_init)

    grids = [(key, attrs[key]["theta"]) for key in leafs]

    return attrs, grids


def plot_grid(ax, grid_attrs):
    grid_radius = 1.02
    grid_dashes = (40, 80)
    grid_color = [0.5] * 3
    grid_lw = 0.1

    text_radius = 1.03
    fontsize = 4

    for key, theta in grid_attrs:
        ax.plot(
            [0, np.cos(theta) * grid_radius],
            [0, np.sin(theta) * grid_radius],
            lw=grid_lw,
            ls="--",
            dashes=grid_dashes,
            c=grid_color,
        )

        if theta > np.pi / 2 and theta <= np.pi * 3 / 2:
            ax.text(
                np.cos(theta) * text_radius,
                np.sin(theta) * text_radius,
                str(key),
                ha="right",
                va="center",
                rotation=theta / np.pi * 180 + 180,
                rotation_mode="anchor",
                fontsize=fontsize,
            )
        else:
            ax.text(
                np.cos(theta) * text_radius,
                np.sin(theta) * text_radius,
                str(key),
                ha="left",
                va="center",
                rotation=theta / np.pi * 180,
                rotation_mode="anchor",
                fontsize=fontsize,
            )


def plot_tree(ax: plt.Axes, attrs: Dict[str, Any]):
    line_width = 1.0
    scatter_size = 4.0

    arc_patches = []
    scatter_attrs = {"x": [], "y": [], "s": [], "c": []}
    for key, attr in attrs.items():

        theta = attr["theta"]
        radius = np.array([attr["radius1"], attr["radius2"]])
        x = np.cos(theta) * radius
        y = np.sin(theta) * radius

        ax.plot(
            x,
            y,
            color="w",
            lw=line_width,
        )

        if attr["arc"]:
            diameter = attr["radius2"] * 2
            arc_patches.append(
                patches.Arc(
                    xy=(0, 0),
                    width=diameter,
                    height=diameter,
                    theta1=attr["arc"][0],
                    theta2=attr["arc"][1],
                    lw=line_width,
                    color="w",
                )
            )

        scatter_attrs["x"].append(x[1])
        scatter_attrs["y"].append(y[1])
        scatter_attrs["c"].append("w")
        scatter_attrs["s"].append(scatter_size)

    for arc in arc_patches:
        ax.add_patch(arc)

    ax.scatter(
        scatter_attrs["x"],
        scatter_attrs["y"],
        s=scatter_attrs["s"],
        c=scatter_attrs["c"],
    )


def main(label_tree_path: str, filename: str, first_n: int = None):

    label_tree = pd.read_csv(label_tree_path)
    if first_n != None:
        label_tree = label_tree[:first_n]

    label_tree = label_tree.fillna(-1)
    label_tree = label_tree.astype(int)

    # tmp
    root_df = pd.DataFrame(
        {
            COLUMNS["birth"]: [0] * 3,
            COLUMNS["parent"]: [-1] * 3,
            COLUMNS["id"]: [1, 2, 3],
        }
    )
    label_tree = pd.concat([root_df, label_tree], axis=0)

    radius_max: int = label_tree[COLUMNS["birth"]].max()
    radius_min_ratio = 0.05  # ルートノードのradius

    attrs, _ = make_graph_attr1(label_tree, radius_max, radius_min_ratio)

    fig, ax = plt.subplots(
        figsize=(10, 10),
        facecolor="k",
    )

    plot_tree(ax, attrs)

    ax.axis("off")
    os.makedirs("imgs/graphs", exist_ok=True)
    plt.savefig(f"imgs/graphs/{filename}.png")
    plt.savefig(f"imgs/graphs/{filename}.pdf")
    plt.close(fig)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--input",
        "-i",
        required=True,
        type=str,
        metavar="input_path",
    )
    parser.add_argument(
        "--output",
        "-o",
        required=True,
        type=str,
        metavar="output_path",
    )
    parser.add_argument(
        "--first_n",
        "-n",
        required=False,
        type=int,
        metavar="N",
    )

    args = parser.parse_args()

    main(
        label_tree_path=args.input,
        filename=args.output,
        first_n=args.first_n,
    )
