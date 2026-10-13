# scripts/fig_04_form/python.py
# A smoother as the referee for a functional form:
# (a) linear and quadratic fits of female labor force participation on log GDP per capita;
# (b) a quadratic in age for log earnings, PSLM 2019-20, against the age means and a smoother.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")


def loess(X, Y, grid, span, degree, W=None):
    """Local polynomial with tricube weights on the nearest span*n points (times
    optional weights W), as R's loess(..., family = "gaussian", surface = "direct")."""
    W = np.ones(len(X)) if W is None else np.asarray(W, float)
    q = int(np.floor(span * len(X)))
    fit = []
    for g in grid:
        d = np.abs(X - g)
        h = np.sort(d)[q - 1] * 1.0000001
        w = np.clip(1 - (d / h) ** 3, 0, None) ** 3 * W
        A = np.vander(X - g, degree + 1, increasing=True) * np.sqrt(w)[:, None]
        fit.append(np.linalg.lstsq(A, Y * np.sqrt(w), rcond=None)[0][0])
    return np.array(fit)


# (a) Countries --------------------------------------------------------------------------
x = pd.read_csv(repo_root / "data" / "wdi_flfp_xsec.csv").dropna(subset=["gdppc_2022", "flfp_2023"])
X, Y = np.log10(x["gdppc_2022"].values), x["flfp_2023"].values
grid = np.linspace(X.min(), X.max(), 200)
b1, b2 = np.polyfit(X, Y, 1), np.polyfit(X, Y, 2)
print(f"linear: slope {b1[0]:.2f} points per tenfold GDP; correlation {np.corrcoef(X, Y)[0, 1]:.2f}")
print(f"quadratic: minimum {np.polyval(b2, -b2[1] / (2 * b2[0])):.1f}% at ${10 ** (-b2[1] / (2 * b2[0])):,.0f}")

# (b) Earners: weighted means of log earnings by age ---------------------------------------
pp = pd.read_csv(repo_root / "data" / "pslm_person_subset.csv")
hh = pd.read_csv(repo_root / "data" / "pslm_hh_subset.csv")[["hhid", "hhweight"]]
e = pp.merge(hh, on="hhid", how="left")
e = e[(e["earn_month"] > 0) & e["age"].between(15, 64)].copy()
e["ly"] = np.log(e["earn_month"])

# Weighted quadratic in age, fitted to the 18,494 earners
A = np.column_stack([np.ones(len(e)), e["age"], e["age"] ** 2]) * np.sqrt(e["hhweight"].values)[:, None]
c = np.linalg.lstsq(A, e["ly"].values * np.sqrt(e["hhweight"].values), rcond=None)[0]
peak_q = -c[1] / (2 * c[2])

m = (e.groupby("age")
       .apply(lambda g: pd.Series({"ly": np.average(g["ly"], weights=g["hhweight"]),
                                   "w": g["hhweight"].sum(), "n": len(g)}))
       .reset_index())
m["heaped"] = m["age"] % 5 == 0
ages = np.arange(15, 65, 0.25)
# Weighted local linear fit to the age means = weighted local linear fit to the earners
sm_ = loess(m["age"].values.astype(float), m["ly"].values, ages, 0.3, 1, W=m["w"].values)
quad = c[0] + c[1] * ages + c[2] * ages ** 2
print(f"quadratic peak at age {peak_q:.1f}; smoother peak at age {ages[sm_.argmax()]:.1f}")
for a_ in (15, 25, 45, 55, 64):
    i = np.searchsorted(ages, a_)
    print(f"age {a_}: quadratic Rs {np.exp(quad[i]):,.0f}, smoother Rs {np.exp(sm_[i]):,.0f}")
share = m.loc[m["heaped"] & m["age"].between(25, 60), "n"].sum() / m.loc[m["age"].between(25, 60), "n"].sum()
print(f"share of earners aged 25-60 reporting an age ending in 0 or 5: {share:.2f}")

# Plot ------------------------------------------------------------------------------------
dollars = FuncFormatter(lambda v, _: f"${10 ** v:,.0f}")
rupees = FuncFormatter(lambda v, _: f"{np.exp(v):,.0f}")
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.4))

a.scatter(X, Y, s=8, color="0.7", linewidth=0)
a.plot(grid, np.polyval(b1, grid), color="#b5532a", ls="--", lw=1.4, label="Linear")
a.plot(grid, np.polyval(b2, grid), color="0.25", ls=":", lw=1.6, label="Quadratic")
a.plot(grid, loess(X, Y, grid, 0.75, 1), color="#1f4e79", lw=1.8, label="Smoother, span 0.75")
a.xaxis.set_major_formatter(dollars)
a.set_xticks([np.log10(v) for v in (1_000, 10_000, 100_000)])
a.set_xlabel("GDP per capita, 2022 (US$, log scale)")
a.set_ylabel("Female labor force participation, 2023 (%)")
a.set_title("(a) A line through a U", loc="left")
a.legend(frameon=False, loc="lower right")

for heaped, col, lab in [(False, "0.55", "Age mean"), (True, "#b5532a", "Age ending in 0 or 5")]:
    s = m[m["heaped"] == heaped]
    b.scatter(s["age"], s["ly"], s=s["n"] / 25, color=col, alpha=0.8, linewidth=0, label=lab)
b.plot(ages, quad, color="0.25", ls=":", lw=1.6, label="Quadratic")
b.plot(ages, sm_, color="#1f4e79", lw=1.8, label="Smoother, span 0.3")
b.yaxis.set_major_formatter(rupees)
b.set_yticks(np.log([10_000, 15_000, 20_000, 25_000]))
b.set_ylim(np.log(7_000), np.log(30_000))
b.set_xlabel("Age (years)")
b.set_ylabel("Monthly earnings (Rs, geometric mean, log scale)")
b.set_title("(b) A quadratic in age", loc="left")
b.legend(frameon=False, loc="lower right", markerscale=0.6)

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_form_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
