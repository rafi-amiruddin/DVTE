# scripts/fig_04_paths/python.py
# Between and within countries: female labor force participation and GDP per capita,
# 15 Asian and African countries, 1990-2025. (a) country averages; (b) each country's path.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

d = (pd.read_csv(repo_root / "data" / "wdi_panel.csv")
       .dropna(subset=["gdppc_ppp", "lfp_female"])
       .sort_values(["country", "year"]))
d["lgdp"] = np.log10(d["gdppc_ppp"])

# Between: country means.  Within: slope after removing each country's mean.
m = d.groupby("country")[["lgdp", "lfp_female"]].mean()
b_between = np.polyfit(m["lgdp"], m["lfp_female"], 1)
dm = d[["lgdp", "lfp_female"]] - d.groupby("country")[["lgdp", "lfp_female"]].transform("mean")
b_within = np.polyfit(dm["lgdp"], dm["lfp_female"], 1)[0]
print(f"between slope {b_between[0]:.1f}; within slope {b_within:.1f} (points per tenfold GDP)")

ends = d.groupby("country").agg(y0=("year", "first"), y1=("year", "last"),
                                f0=("lfp_female", "first"), f1=("lfp_female", "last"),
                                g0=("gdppc_ppp", "first"), g1=("gdppc_ppp", "last"))
ends["rising"] = ends["f1"] > ends["f0"]
print(ends.round(1).sort_values("f1").to_string())

dollars = FuncFormatter(lambda v, _: f"${10 ** v:,.0f}")
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.6), sharex=True, sharey=True)

a.scatter(m["lgdp"], m["lfp_female"], s=14, color="#1f4e79", linewidth=0)
xs = np.array([m["lgdp"].min(), m["lgdp"].max()])
a.plot(xs, np.polyval(b_between, xs), color="#b5532a", lw=1.5)
for c, r in m.iterrows():
    a.annotate(c, (r["lgdp"], r["lfp_female"]), xytext=(3, 2), textcoords="offset points", fontsize=6.5)
a.set_title("(a) Between: country averages", loc="left")
a.set_ylabel("Female labor force participation (%)")

for c, g in d.groupby("country"):
    col = "#1f4e79" if ends.loc[c, "rising"] else "#b5532a"
    b.plot(g["lgdp"], g["lfp_female"], color=col, lw=1)
    b.scatter(g["lgdp"].iloc[-1], g["lfp_female"].iloc[-1], s=10, color=col, zorder=3)
    b.annotate(c, (g["lgdp"].iloc[-1], g["lfp_female"].iloc[-1]), xytext=(3, 2),
               textcoords="offset points", fontsize=6.5, color=col)
b.set_title("(b) Within: each country, 1990-2025", loc="left")

for ax in (a, b):
    ax.xaxis.set_major_formatter(dollars)
    ax.set_xticks([np.log10(v) for v in (1_000, 3_000, 10_000, 30_000)])
    ax.set_xlabel("GDP per capita (2021 PPP $, log scale)")
fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_paths_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
