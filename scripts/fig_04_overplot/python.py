# scripts/fig_04_overplot/python.py
# Monthly earnings by age, PSLM 2019-20: four answers to overplotting.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.colors import LogNorm
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

pp = pd.read_csv(repo_root / "data" / "pslm_person_subset.csv", low_memory=False)
hh = pd.read_csv(repo_root / "data" / "pslm_hh_subset.csv", usecols=["hhid", "hhweight"])
pp = pp.merge(hh, on="hhid", how="left")
e = pp[(pp["earn_month"] > 0) & pp["age"].between(15, 64)].copy()

# How many people hide behind each plotted point?
ties = e.groupby(["age", "earn_month"]).size().rename("n").reset_index()
print(f"earners: {len(e):,}; distinct points: {len(ties):,}; "
      f"share at points shared by 10+: {ties.loc[ties.n >= 10, 'n'].sum() / len(e):.2f}; "
      f"largest stack: {ties.n.max()}")

rng = np.random.default_rng(346)
rupees = FuncFormatter(lambda v, _: f"{v:,.0f}")
fig, axes = plt.subplots(2, 2, figsize=(7, 5.6), sharex=True, sharey=True)
(a, b), (c, d) = axes

a.scatter(e["age"], e["earn_month"], s=4, color="#1f4e79")
a.set_title("(a) One point per earner", loc="left")

jit_age = e["age"] + rng.uniform(-0.5, 0.5, len(e))
jit_earn = e["earn_month"] * 10 ** rng.uniform(-0.04, 0.04, len(e))
b.scatter(jit_age, jit_earn, s=3, color="#1f4e79", alpha=0.08, linewidth=0)
b.set_title("(b) Jittered and transparent", loc="left")

c.scatter(ties["age"], ties["earn_month"], s=ties["n"] * 1.2, color="#1f4e79", alpha=0.5, linewidth=0)
c.set_title("(c) Area proportional to count", loc="left")

hb = d.hexbin(e["age"], e["earn_month"], C=e["hhweight"], reduce_C_function=np.sum,
              yscale="log", gridsize=(25, 18), norm=LogNorm(), cmap="Blues", mincnt=1)
d.set_title("(d) Hexagonal bins, weighted", loc="left")
cb = fig.colorbar(hb, ax=d, pad=0.02)
cb.set_label("Earners represented", fontsize=8)

for ax in axes.flat:
    ax.set_yscale("log")
    ax.set_ylim(1_000, 1_000_000)
    ax.yaxis.set_major_formatter(rupees)
    ax.set_xlim(14, 65)
for ax in axes[1]:
    ax.set_xlabel("Age (years)")
for ax in axes[:, 0]:
    ax.set_ylabel("Monthly earnings (Rs, log scale)")

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_overplot_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
