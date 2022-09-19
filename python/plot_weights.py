import os
import matplotlib.pyplot as plt
import numpy as np


plt.rcParams["ps.useafm"] = True
plt.rcParams["pdf.use14corefonts"] = True
plt.rcParams["font.family"] = "Times New Roman"
plt.rcParams["text.usetex"] = True
plt.rcParams["font.size"] = 20

outdir = "results/imgs/weights"
os.makedirs(outdir, exist_ok=True)


def f(Nl: int, Nnl: int, zeta: float):
    return Nl / (Nl + zeta * Nnl)


def g(Nl: int, Nnl: int, zeta: float):
    return (Nl + zeta * f(Nl, Nnl, zeta) * Nnl) / (Nl + zeta * Nnl)


## Twitter

zeta = 0.7
eta = 0.5

fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class3_weights = [zeta * f(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class3_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class3--twitter.png", dpi=600)


fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class4_weights = [g(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class4_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class4--twitter.png", dpi=600)


fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class5_weights = [eta * g(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class5_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class5--twitter.png", dpi=600)


## APS
zeta = 0.1
eta = 0.5

fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class3_weights = [zeta * f(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class3_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class3--aps.png", dpi=600)


fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class4_weights = [g(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class4_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class4--aps.png", dpi=600)


fig = plt.figure(figsize=(10, 6))
for i, Nnl in enumerate([1, 10, 100, 1000, 10000]):
    class5_weights = [eta * g(Nl, Nnl, zeta) for Nl in range(1, 11)]
    plt.plot(
        range(1, 11),
        class5_weights,
        label="$" + str(Nnl) + "$",
    )

plt.ylim(-0.2, 1.2)
plt.yticks(np.linspace(0, 1, 6))
plt.xticks(np.linspace(1, 10, 10))
plt.xlabel("$N_{L_{t-1}}$")
plt.ylabel("weight")
plt.legend(title="$N_{\overline{L_{t-1}}}$", loc="upper left", bbox_to_anchor=(1, 1))
plt.tight_layout()
plt.savefig(f"{outdir}/class5--aps.png", dpi=600)
