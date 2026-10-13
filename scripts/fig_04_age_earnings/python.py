# scripts/fig_04_age_earnings/python.py
# Monthly earnings by age, PSLM 2019-20: (a) three conditional averages; (b) conditional spread.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

pp = pd.read_csv(repo_root / "data" / "pslm_person_subset.csv", low_memory=False)
hh = pd.read_csv(repo_root / "data" / "pslm_hh_subset.csv", usecols=["hhid", "hhweight"])
e = pp.merge(hh, on="hhid", how="left")
e = e[(e["earn_month"] > 0) & e["age"].between(15, 64)]


def wquantile(v, w, q):
    """Weighted quantile: smallest value whose cumulative weight share reaches q."""
    o = np.argsort(v)
    v, w = np.asarray(v)[o], np.asarray(w)[o]
    return v[np.searchsorted(np.cumsum(w) / w.sum(), q)]


def summarise(g):
    y, w = g["earn_month"].values, g["hhweight"].values
    out = {"mean": np.average(y, weights=w),
           "geomean": np.exp(np.average(np.log(y), weights=w))}
    for q in (10, 25, 50, 75, 90):
        out[f"p{q}"] = wquantile(y, w, q / 100)
    return pd.Series(out)


by_age = e.groupby("age").apply(summarise)
print(by_age.loc[[25, 40, 55]].round(0))

rupees = FuncFormatter(lambda v, _: f"{v:,.0f}")
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.4), sharey=True)

a.plot(by_age.index, by_age["mean"], "o-", ms=3, lw=1, color="#b5532a", label="Mean")
a.plot(by_age.index, by_age["geomean"], "o-", ms=3, lw=1, color="#1f4e79", label="Geometric mean")
a.plot(by_age.index, by_age["p50"], "o-", ms=3, lw=1, color="0.4", label="Median")
a.legend(frameon=False, loc="upper left")
a.set_title("(a) Which average?", loc="left")
a.set_ylabel("Monthly earnings (Rs, log scale)")

b.fill_between(by_age.index, by_age["p10"], by_age["p90"], color="#1f4e79", alpha=0.15,
               step="mid", label="10th to 90th percentile")
b.fill_between(by_age.index, by_age["p25"], by_age["p75"], color="#1f4e79", alpha=0.30,
               step="mid", label="25th to 75th percentile")
b.step(by_age.index, by_age["p50"], where="mid", color="0.2", lw=1.2, label="Median")
b.legend(frameon=False, loc="upper left")
b.set_title("(b) How spread out?", loc="left")

for ax in (a, b):
    ax.set_yscale("log")
    ax.set_ylim(2_000, 120_000)
    ax.yaxis.set_major_formatter(rupees)
    ax.set_xlabel("Age (years)")

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_age_earnings_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
