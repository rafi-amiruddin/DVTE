# scripts/fig_04_region/python.py
# Female labor force participation against GDP per capita, one panel per region:
# each region's countries in color with a within-region linear fit, all others in grey.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

x = pd.read_csv(repo_root / "data" / "wdi_flfp_xsec.csv").dropna(subset=["gdppc_2022", "flfp_2023"])
x["lgdp"] = np.log10(x["gdppc_2022"])
x["reg"] = x["region"].replace({"North America": "Europe & Central Asia"})   # 2 countries merged
short = {"East Asia & Pacific": "East Asia & Pacific",
         "Europe & Central Asia": "Europe, Central Asia & North America",
         "Latin America & Caribbean": "Latin America & Caribbean",
         "Middle East, North Africa, Afghanistan & Pakistan": "Middle East, North Africa,\nAfghanistan & Pakistan",
         "South Asia": "South Asia",
         "Sub-Saharan Africa": "Sub-Saharan Africa"}

# Pooled and within-region linear slopes (points per tenfold increase in GDP per capita)
pooled = np.polyfit(x["lgdp"], x["flfp_2023"], 1)[0]
D = pd.get_dummies(x["reg"], drop_first=True).astype(float).values
X = np.column_stack([np.ones(len(x)), x["lgdp"], D])
within = np.linalg.lstsq(X, x["flfp_2023"], rcond=None)[0][1]
print(f"pooled slope {pooled:.1f}; slope within regions {within:.1f}")

dollars = FuncFormatter(lambda v, _: f"${10 ** v:,.0f}")
fig, axes = plt.subplots(2, 3, figsize=(7, 4.6), sharex=True, sharey=True)
for ax, (reg, g) in zip(axes.flat, x.groupby("reg")):
    ax.scatter(x["lgdp"], x["flfp_2023"], s=6, color="0.8", linewidth=0)
    ax.scatter(g["lgdp"], g["flfp_2023"], s=12, color="#1f4e79", linewidth=0)
    b = np.polyfit(g["lgdp"], g["flfp_2023"], 1)
    xs = np.array([g["lgdp"].min(), g["lgdp"].max()])
    ax.plot(xs, np.polyval(b, xs), color="#b5532a", lw=1.5)
    ax.set_title(f"{short[reg]}", loc="left", fontsize=8)
    ax.text(0.97, 0.04, f"n = {len(g)}, slope {b[0]:+.0f}", transform=ax.transAxes,
            ha="right", va="bottom", fontsize=7)
    print(f"{reg}: n {len(g)}, slope {b[0]:.1f}, mean participation {g['flfp_2023'].mean():.1f}")
    if reg.startswith("Middle East"):
        pk = g[g["country"] == "Pakistan"]
        ax.annotate("Pakistan", (pk["lgdp"].iloc[0], pk["flfp_2023"].iloc[0]), xytext=(4, 6),
                    textcoords="offset points", fontsize=7)
for ax in axes.flat:
    ax.xaxis.set_major_formatter(dollars)
    ax.set_xticks([np.log10(v) for v in (1_000, 10_000, 100_000)])
fig.supxlabel("GDP per capita, 2022 (US$, log scale)", fontsize=9)
fig.supylabel("Female labor force participation, 2023 (%)", fontsize=9)
fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_region_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
