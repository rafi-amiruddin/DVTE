"""
Freeze Maddison Project 2023 and a V-Dem extract for the DVTE repository.

Run from the repository root:
    python freeze_maddison_vdem.py --maddison path/to/mpd2023_web.xlsx \
                                   --vdem path/to/V-Dem-CY-Full+Others-v16.csv

Writes:
    data/maddison/mpd2023.csv          (country-year GDP per capita and population)
    data/maddison/MANIFEST.md
    data/vdem/vdem_extract.csv         (selected indices, 1900 onward)
    data/vdem/MANIFEST.md
    data/vdem/LICENSE.md               (CC BY-SA 4.0 applies to the extract)

The raw downloads are NOT copied into the repo (V-Dem's full file exceeds
GitHub's 100 MB limit). Their SHA-256 checksums are recorded instead, so
anyone can verify they rebuilt from the same files.
"""

import argparse
import hashlib
import pathlib
from datetime import date

import pandas as pd

VDEM_VARS = {
    "v2x_polyarchy": "Electoral democracy index",
    "v2x_libdem": "Liberal democracy index",
    "v2x_gender": "Women's political empowerment index",
    "v2x_gencl": "Women's civil liberties index",
    "v2x_gencs": "Women's civil society participation index",
    "v2x_genpp": "Women's political participation index",
    "v2x_rule": "Rule of law index",
    "v2x_corr": "Political corruption index",
    "v2x_freexp_altinf": "Freedom of expression and alternative sources of information index",
    "v2x_regime": "Regimes of the World (0 closed autocracy to 3 liberal democracy)",
}
VDEM_IDS = ["country_name", "country_text_id", "year"]
VDEM_START = 1900


def sha256(path: pathlib.Path) -> str:
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def write_manifest(folder, title, source, version, doi, license_, raw, out, df, notes):
    folder.mkdir(parents=True, exist_ok=True)
    lines = [
        f"# {title}",
        "",
        f"- Source: {source}",
        f"- Version: {version}",
        f"- DOI: {doi}",
        f"- License: {license_}",
        f"- Frozen on: {date.today().isoformat()}",
        f"- Raw file: `{raw.name}`",
        f"- Raw SHA-256: `{sha256(raw)}`",
        f"- Output: `{out.name}` ({len(df):,} rows, {df.shape[1]} columns)",
        f"- Output SHA-256: `{sha256(out)}`",
        "",
        "## Columns",
        "",
    ]
    lines += [f"- `{c}`: {notes.get(c, '')}" for c in df.columns]
    (folder / "MANIFEST.md").write_text("\n".join(lines) + "\n", encoding="utf-8")


def freeze_maddison(raw: pathlib.Path, root: pathlib.Path):
    df = pd.read_excel(raw, sheet_name="Full data")
    keep = [c for c in ["countrycode", "country", "region", "year", "gdppc", "pop"] if c in df.columns]
    df = df[keep].sort_values(["countrycode", "year"])
    folder = root / "data" / "maddison"
    folder.mkdir(parents=True, exist_ok=True)
    out = folder / "mpd2023.csv"
    df.to_csv(out, index=False)
    write_manifest(
        folder, "Maddison Project Database 2023",
        "Groningen Growth and Development Centre (Bolt and van Zanden 2024)",
        "2023 release", "10.34894/INZBF2", "CC BY 4.0", raw, out, df,
        {"countrycode": "ISO 3166-1 alpha-3", "country": "Country name",
         "region": "Maddison region", "year": "Year",
         "gdppc": "Real GDP per capita, 2011 international dollars",
         "pop": "Population, thousands"},
    )
    print(f"Maddison: {len(df):,} rows -> {out}")


def freeze_vdem(raw: pathlib.Path, root: pathlib.Path):
    header = pd.read_csv(raw, nrows=0).columns
    missing = [v for v in VDEM_IDS + list(VDEM_VARS) if v not in header]
    if missing:
        raise SystemExit(f"V-Dem file lacks: {missing}. Use the Country-Year Full+Others or Core file.")
    df = pd.read_csv(raw, usecols=VDEM_IDS + list(VDEM_VARS), low_memory=False)
    df = df[df["year"] >= VDEM_START].sort_values(["country_text_id", "year"])
    folder = root / "data" / "vdem"
    folder.mkdir(parents=True, exist_ok=True)
    out = folder / "vdem_extract.csv"
    df.to_csv(out, index=False)
    version = raw.stem.split("-")[-1]  # e.g. "v16"
    write_manifest(
        folder, "V-Dem Country-Year extract",
        "Varieties of Democracy (V-Dem) Project, University of Gothenburg",
        version, "see the citation for this version on v-dem.net", "CC BY-SA 4.0",
        raw, out, df,
        {"country_name": "Country name", "country_text_id": "V-Dem three-letter code",
         "year": "Year", **VDEM_VARS},
    )
    (folder / "LICENSE.md").write_text(
        "This extract of the V-Dem dataset is licensed under CC BY-SA 4.0 "
        "(https://creativecommons.org/licenses/by-sa/4.0/). Any redistribution or "
        "derivative of this file must carry the same license and cite V-Dem.\n",
        encoding="utf-8",
    )
    print(f"V-Dem: {len(df):,} rows -> {out}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--maddison", type=pathlib.Path)
    p.add_argument("--vdem", type=pathlib.Path)
    p.add_argument("--root", type=pathlib.Path, default=pathlib.Path("."))
    a = p.parse_args()
    if a.maddison:
        freeze_maddison(a.maddison, a.root)
    if a.vdem:
        freeze_vdem(a.vdem, a.root)
