# scripts/fig_04_cs_engel/python.py
# Engel curves for food, Pakistan, HIES 2018-19: food share against monthly consumption
# per person, rural and urban. (a) consumption from all sources; (b) purchases only.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

h = pd.read_csv(repo_root / "data" / "hies_hh_subset.csv")
h["pc_purch"] = h["total_purch"] / h["hhsize"] / 12
defs = {"a": ("pc_exp_month", "food_share", "(a) All sources"),
        "b": ("pc_purch", "food_share_purch", "(b) Purchases only")}
cols = {"rural": "#b5532a", "urban": "#1f4e79"}


def wdeciles(d, x, y, w="hhweight", k=10):
    """Means of x and y in k bins holding equal shares of the weighted households."""
    d = d.sort_values(x)
    b = np.minimum((d[w].cumsum() / d[w].sum() * k).astype(int), k - 1)
    return d.groupby(b.values).apply(lambda g: pd.Series(
        {"x": np.average(g[x], weights=g[w]), "y": np.average(g[y], weights=g[w])}))


def loess(X, Y, W, grid, span=0.3):
    """Weighted local linear fit, tricube weights on the nearest span*n points."""
    q = int(np.floor(span * len(X)))
    fit = []
    for g in grid:
        d = np.abs(X - g)
        h_ = np.partition(d, q - 1)[q - 1] * 1.0000001
        k = np.clip(1 - (d / h_) ** 3, 0, None) ** 3 * W
        A = np.column_stack([np.ones_like(X), X - g]) * np.sqrt(k)[:, None]
        fit.append(np.linalg.lstsq(A, Y * np.sqrt(k), rcond=None)[0][0])
    return np.array(fit)


rupees = FuncFormatter(lambda v, _: f"{np.exp(v):,.0f}")
fig, axes = plt.subplots(1, 2, figsize=(7, 3.8), sharex=True, sharey=True)
for ax, (key, (xv, yv, title)) in zip(axes, defs.items()):
    d0 = h[h[xv] > 0].assign(lx=lambda d: np.log(d[xv]), pct=lambda d: 100 * d[yv])
    ax.scatter(d0["lx"], d0["pct"], s=1, color="0.5", alpha=0.05, linewidth=0, rasterized=True)
    for area, d in d0.groupby("area"):
        bins = wdeciles(d, "lx", "pct")
        lo, hi = bins["x"].iloc[0], bins["x"].iloc[-1]
        grid = np.linspace(lo, hi, 100)
        fit = loess(d["lx"].values, d["pct"].values, d["hhweight"].values, grid)
        ax.plot(grid, fit, color=cols[area], lw=1.6)
        ax.scatter(bins["x"], bins["y"], s=16, color=cols[area], zorder=3)
        end = -1 if area == "urban" else 0              # urban labeled right, rural left
        ax.annotate(area.capitalize(), (grid[end], fit[end]), xytext=(4 if end else -4, 0),
                    textcoords="offset points", va="center", ha="left" if end else "right",
                    color=cols[area], fontsize=8)
        print(f"{title}, {area}: poorest decile {bins['y'].iloc[0]:.1f}% at Rs {np.exp(lo):,.0f};"
              f" richest {bins['y'].iloc[-1]:.1f}% at Rs {np.exp(hi):,.0f}")
    ax.set_title(title, loc="left")
    ax.set_xticks(np.log([2_000, 5_000, 10_000, 20_000, 50_000]))
    ax.xaxis.set_major_formatter(rupees)
    ax.set_xlim(np.log(1_000), np.log(60_000))
    ax.set_ylim(0, 80)
    ax.set_xlabel("Consumption per person (Rs a month, log scale)")
axes[0].set_ylabel("Food share of consumption (%)")
fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_cs_engel_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out, dpi=300)
