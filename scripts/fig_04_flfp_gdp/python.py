# scripts/fig_04_flfp_gdp/python.py
# Female labor force participation against GDP per capita: linear axis vs log axis with population bubbles.
from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
from matplotlib.ticker import FuncFormatter

repo_root = Path(".")                       # set to the repository root
plt.style.use(repo_root / "style" / "dvte.mplstyle")

x = pd.read_csv(repo_root / "data" / "wdi_flfp_xsec.csv")
pwt = pd.read_csv(repo_root / "data" / "pwt_full.csv", usecols=["countrycode", "year", "pop"])
pop = pwt[pwt["year"] == 2023][["countrycode", "pop"]]
x = x.merge(pop, left_on="iso3", right_on="countrycode", how="left")

labels = {"PAK": "Pakistan", "IND": "India", "CHN": "China"}
fig, (a, b) = plt.subplots(1, 2, figsize=(7, 3.4), sharey=True)

# (a) linear axis
a.scatter(x["gdppc_2022"] / 1000, x["flfp_2023"], s=12, color="#1f4e79", alpha=0.8)
a.set_xlabel("GDP per capita, 2022 (thousand US$)")
a.set_ylabel("Female labor force participation, 2023 (%)")
a.set_title("(a) Linear axis", loc="left")

# (b) log axis, area proportional to population (13 territories without PWT population dropped)
d = x.dropna(subset=["pop"])
b.scatter(d["gdppc_2022"], d["flfp_2023"], s=d["pop"] / 4, color="#1f4e79",
          alpha=0.35, edgecolor="white", linewidth=0.4)
b.set_xscale("log")
b.xaxis.set_major_formatter(FuncFormatter(lambda v, _: f"${v:,.0f}"))
b.set_xlabel("GDP per capita, 2022 (US$, log scale)")
b.set_title("(b) Log axis, sized by population", loc="left")
for iso, name in labels.items():
    r = x[x["iso3"] == iso].iloc[0]
    b.annotate(name, (r["gdppc_2022"], r["flfp_2023"]), xytext=(6, -10 if iso == "PAK" else 6),
               textcoords="offset points", fontsize=8)

fig.tight_layout()
out = repo_root / "Chapters" / "Figures" / "fig_04_flfp_gdp_python.svg"
out.parent.mkdir(parents=True, exist_ok=True)
fig.savefig(out)
