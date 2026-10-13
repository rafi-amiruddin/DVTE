# scripts/fig_04_binscatter/python.py
# Binned scatterplots of female labor force participation against GDP per capita:
# (a) the number of bins; (b) what "controlling for region" does to a binscatter.
# Requires: pip install binsreg
from pathlib import Path
import warnings
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import binsreg

warnings.filterwarnings("ignore")           # binsreg prints solver notes
repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

x = pd.read_csv(repo_root / "data" / "wdi_flfp_xsec.csv")
x["lgdp"] = np.log10(x["gdppc_2022"])
x["reg"] = x["region"].replace({"North America": "Europe & Central Asia"})   # 2 countries merged


def binned_means(xv, yv, k):
    """Equal-count bins of xv; mean of xv and yv in each bin."""
    q = pd.qcut(xv, k, labels=False)
    return pd.DataFrame({"x": xv, "y": yv}).groupby(q).mean()


def ols_resid(v, W):
    """Residual of v on W (with constant), plus the mean of v added back."""
    X = np.column_stack([np.ones(len(W)), W])
    b, *_ = np.linalg.lstsq(X, v, rcond=None)
    return v - X @ b + v.mean()


# The data-driven number of bins (IMSE-optimal, Cattaneo et al. 2024)
sel = binsreg.binsregselect(y=x["flfp_2023"].values, x=x["lgdp"].values)
k_opt = int(sel.nbinsdpi)
print("binsregselect: IMSE-optimal number of bins =", k_opt)

# Panel (b): three binscatters, ten bins each
W = pd.get_dummies(x["reg"], drop_first=True).astype(float).values
raw = binned_means(x["lgdp"], x["flfp_2023"], 10)
res = binned_means(pd.Series(ols_resid(x["lgdp"].values, W)),
                   pd.Series(ols_resid(x["flfp_2023"].values, W)), 10)
bsr = binsreg.binsreg(y=x["flfp_2023"].values, x=x["lgdp"].values, w=W,
                      nbins=10, noplot=True).data_plot[0].dots

dollars = FuncFormatter(lambda v, _: f"${10 ** v:,.0f}")
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.4), sharey=True)

a.scatter(x["lgdp"], x["flfp_2023"], s=8, color="0.7", linewidth=0)
for k, style in [(5, dict(color="#b5532a", marker="s", ms=7)),
                 (k_opt, dict(color="#1f4e79", marker="o", ms=4))]:
    m = binned_means(x["lgdp"], x["flfp_2023"], k)
    a.plot(m["x"], m["y"], lw=1, label=f"{k} bins", **style)
a.legend(frameon=False, loc="lower right")
a.set_title("(a) Five bins or fourteen", loc="left")
a.set_ylabel("Female labor force participation, 2023 (%)")

b.plot(raw["x"], raw["y"], "o-", color="0.45", ms=4, lw=1, label="No controls")
b.plot(res["x"], res["y"], "s--", color="#b5532a", ms=4, lw=1, label="Residualized on region")
b.plot(bsr["x"], bsr["fit"], "o-", color="#1f4e79", ms=4, lw=1, label="binsreg, region controls")
b.legend(frameon=False, loc="lower right")
b.set_title("(b) Controlling for region", loc="left")

for ax in (a, b):
    ax.xaxis.set_major_formatter(dollars)
    ax.set_xticks([np.log10(v) for v in (1_000, 10_000, 100_000)])
    ax.set_xlabel("GDP per capita, 2022 (US$, log scale)")

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_binscatter_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
