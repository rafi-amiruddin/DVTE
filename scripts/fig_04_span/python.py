# scripts/fig_04_span/python.py
# Local regression smoothers of female labor force participation on GDP per capita:
# (a) the span; (b) the degree of the local polynomial, at a fixed span.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter
import statsmodels.api as sm

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

x = pd.read_csv(repo_root / "data" / "wdi_flfp_xsec.csv").dropna(subset=["gdppc_2022", "flfp_2023"])
x["lgdp"] = np.log10(x["gdppc_2022"])
X, Y = x["lgdp"].values, x["flfp_2023"].values


def loess(X, Y, grid, span, degree):
    """Local polynomial with tricube weights on the nearest span*n points,
    as R's loess(..., family = "gaussian", surface = "direct")."""
    q = int(np.floor(span * len(X)))
    fit = []
    for g in grid:
        d = np.abs(X - g)
        h = np.sort(d)[q - 1] * 1.0000001
        w = np.clip(1 - (d / h) ** 3, 0, None) ** 3
        A = np.vander(X - g, degree + 1, increasing=True) * np.sqrt(w)[:, None]
        fit.append(np.linalg.lstsq(A, Y * np.sqrt(w), rcond=None)[0][0])
    return np.array(fit)


grid = np.linspace(X.min(), X.max(), 200)
for span in (0.2, 0.75):
    f = loess(X, Y, grid, span, 1)
    print(f"span {span}: minimum {f.min():.1f}% at ${10 ** grid[f.argmin()]:,.0f};"
          f" ends {f[0]:.1f}, {f[-1]:.1f}")
for deg in (0, 1, 2):
    f = loess(X, Y, grid, 0.75, deg)
    print(f"span 0.75, degree {deg}: ends {f[0]:.1f}, {f[-1]:.1f}; minimum {f.min():.1f}")
# The defaults: statsmodels lowess (frac 2/3, 3 robustness iterations) with and without robustness
for it in (3, 0):
    f = sm.nonparametric.lowess(Y, X, frac=2 / 3, it=it, xvals=grid)
    print(f"statsmodels lowess, it={it}: left end {f[0]:.1f}, minimum {f.min():.1f}")

dollars = FuncFormatter(lambda v, _: f"${10 ** v:,.0f}")
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.4), sharey=True)
for ax in (a, b):
    ax.scatter(X, Y, s=8, color="0.7", linewidth=0)

a.plot(grid, loess(X, Y, grid, 0.2, 1), color="#b5532a", lw=1.2, label="Span 0.2")
a.plot(grid, loess(X, Y, grid, 0.75, 1), color="#1f4e79", lw=1.8, label="Span 0.75")
a.set_title("(a) The span", loc="left")
a.set_ylabel("Female labor force participation, 2023 (%)")

for deg, col, ls, lab in [(0, "#b5532a", "--", "Local mean (degree 0)"),
                          (1, "#1f4e79", "-", "Local linear (degree 1)"),
                          (2, "0.25", ":", "Local quadratic (degree 2)")]:
    b.plot(grid, loess(X, Y, grid, 0.75, deg), color=col, ls=ls, lw=1.6, label=lab)
b.set_title("(b) The degree, span 0.75", loc="left")

for ax in (a, b):
    ax.legend(frameon=False, loc="lower right")
    ax.xaxis.set_major_formatter(dollars)
    ax.set_xticks([np.log10(v) for v in (1_000, 10_000, 100_000)])
    ax.set_xlabel("GDP per capita, 2022 (US$, log scale)")

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_span_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
