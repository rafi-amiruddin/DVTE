# scripts/fig_04_cs_redesign/python.py
# Redesign of the case-study figure: one panel, each decile drawn twice. A filled point marks
# consumption from all sources, an open point purchases only, and an arrow joins them.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

h = pd.read_csv(repo_root / "data" / "hies_hh_subset.csv")
h["pc_purch"] = h["total_purch"] / h["hhsize"] / 12
cols = {"rural": "#b5532a", "urban": "#1f4e79"}


def wdeciles(d, x, y, w="hhweight", k=10):
    """Means of x and y in k bins holding equal shares of the weighted households."""
    d = d.sort_values(x)
    b = np.minimum((d[w].cumsum() / d[w].sum() * k).astype(int), k - 1)
    return d.groupby(b.values).apply(lambda g: pd.Series(
        {"x": np.average(g[x], weights=g[w]), "y": np.average(g[y], weights=g[w])}))


rupees = FuncFormatter(lambda v, _: f"{np.exp(v):,.0f}")
fig, ax = plt.subplots(figsize=(6, 4))
for area, d in h[h["pc_purch"] > 0].groupby("area"):
    d = d.assign(la=np.log(d["pc_exp_month"]), lp=np.log(d["pc_purch"]),
                 sa=100 * d["food_share"], sp=100 * d["food_share_purch"])
    a = wdeciles(d, "la", "sa")             # deciles of consumption from all sources
    p = wdeciles(d, "lp", "sp")             # deciles of purchases
    for (xa, ya), (xp, yp) in zip(a.values, p.values):
        ax.annotate("", xy=(xp, yp), xytext=(xa, ya),
                    arrowprops=dict(arrowstyle="->", color=cols[area], lw=0.8, shrinkA=3, shrinkB=3))
    ax.scatter(a["x"], a["y"], s=22, color=cols[area], zorder=3)
    ax.scatter(p["x"], p["y"], s=22, facecolor="white", edgecolor=cols[area], zorder=3)
    ax.annotate(area.capitalize(), (a["x"].iloc[-1], a["y"].iloc[-1]), xytext=(6, 0),
                textcoords="offset points", va="center", color=cols[area], fontweight="bold")
    shift = 100 * (np.exp(p["x"].values - a["x"].values) - 1)
    print(f"{area}: per-person consumption falls by {-shift.max():.0f} to {-shift.min():.0f} percent;"
          f" food share changes by {np.min(p['y'] - a['y']):+.1f} to {np.max(p['y'] - a['y']):+.1f} points")

ax.scatter([], [], s=22, color="0.3", label="All sources")
ax.scatter([], [], s=22, facecolor="white", edgecolor="0.3", label="Purchases only")
ax.legend(frameon=False, loc="upper right")
ax.set_xticks(np.log([2_000, 5_000, 10_000, 20_000]))
ax.xaxis.set_major_formatter(rupees)
ax.set_xlabel("Consumption per person (Rs a month, log scale)")
ax.set_ylabel("Food share of consumption (%)")
ax.set_title("Counting purchases only moves every decile", loc="left")
fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_cs_redesign_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
