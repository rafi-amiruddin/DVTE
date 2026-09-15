from pathlib import Path
import pandas as pd
import seaborn as sns

repo_root = Path(r"C:\Users\Rafi\OneDrive - Higher Education Commission\02 COMSATS Assignments\Fall 2026\ECO346 Data Visualization Techniques for Economists\Typst_DVTE_V1")

wdi = pd.read_csv(repo_root / "data" / "wdi_panel.csv")

sns.set_theme(style="darkgrid")

g = sns.relplot(
    data=wdi, x="year", y="lfp_female",
    col="country", col_wrap=5, kind="line",
)
g.set_titles("{col_name}")

# Strip every per-axes label, then set one shared pair for the whole figure
for ax in g.axes.flat:
    ax.set_xlabel("")
    ax.set_ylabel("")

g.figure.set_size_inches(9, 6)
g.figure.supxlabel("Year")
g.figure.supylabel("Female labour force participation (%)")
g.figure.tight_layout(rect=[0.03, 0.03, 1, 1])   # reserve margin so the shared labels don't overlap

out_path = repo_root / "Chapters" / "Figures" / "fig_02_flfp_python.svg"
out_path.parent.mkdir(parents=True, exist_ok=True)
g.savefig(out_path)