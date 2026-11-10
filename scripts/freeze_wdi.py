"""
Freeze a multi-indicator World Development Indicators panel for the DVTE repository.

Run from the repository root (needs internet access to the World Bank API):
    pip install wbgapi
    python freeze_wdi.py

Writes:
    data/wdi/wdi_multi.csv     (country-year panel, 1990 onward, one column per indicator)
    data/wdi/countries.csv     (ISO3 code, name, region, income group at freeze time)
    data/wdi/MANIFEST.md       (indicator codebook, API vintage, checksums)

WDI is revised continuously, so this file, not the live API, is the book's reference copy.
"""

import hashlib
import pathlib
from datetime import date

import pandas as pd
import wbgapi as wb

START, END = 1990, 2025

# short name -> WDI code
INDICATORS = {
    # Income, population, structure
    "gdppc_ppp": "NY.GDP.PCAP.PP.KD",
    "gdppc_usd": "NY.GDP.PCAP.CD",
    "pop": "SP.POP.TOTL",
    "urban": "SP.URB.TOTL.IN.ZS",
    "agri_va": "NV.AGR.TOTL.ZS",
    "manuf_va": "NV.IND.MANF.ZS",
    "trade": "NE.TRD.GNFS.ZS",
    "inflation": "FP.CPI.TOTL.ZG",
    "tax_rev": "GC.TAX.TOTL.GD.ZS",
    "remit": "BX.TRF.PWKR.DT.GD.ZS",
    # Labor
    "lfp_female": "SL.TLF.CACT.FE.ZS",
    "lfp_male": "SL.TLF.CACT.MA.ZS",
    "unemp": "SL.UEM.TOTL.ZS",
    "emp_agri": "SL.AGR.EMPL.ZS",
    # Health and demography
    "life_exp": "SP.DYN.LE00.IN",
    "fertility": "SP.DYN.TFRT.IN",
    "adol_fert": "SP.ADO.TFRT",
    "u5mr": "SH.DYN.MORT",
    "imr": "SP.DYN.IMRT.IN",
    "mmr": "SH.STA.MMRT",
    "stunting": "SH.STA.STNT.ZS",
    "health_exp": "SH.XPD.CHEX.GD.ZS",
    # Education
    "prim_net": "SE.PRM.NENR",
    "sec_gross": "SE.SEC.ENRR",
    "ter_gross": "SE.TER.ENRR",
    "lit_adult": "SE.ADT.LITR.ZS",
    "lit_female": "SE.ADT.LITR.FE.ZS",
    # Poverty, inequality, services, gender, environment
    "gini": "SI.POV.GINI",
    "pov_intl": "SI.POV.DDAY",
    "electricity": "EG.ELC.ACCS.ZS",
    "water_basic": "SH.H2O.BASW.ZS",
    "internet": "IT.NET.USER.ZS",
    "women_parl": "SG.GEN.PARL.ZS",
    "co2_pc": "EN.GHG.CO2.PC.CE.AR5",
}


def sha256(path):
    h = hashlib.sha256()
    with open(path, "rb") as f:
        for chunk in iter(lambda: f.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def main(root=pathlib.Path(".")):
    folder = root / "data" / "wdi"
    folder.mkdir(parents=True, exist_ok=True)

    # Countries only (no regional or income aggregates)
    eco = wb.economy.DataFrame(skipAggs=True).reset_index()
    eco = eco.rename(columns={"id": "iso3", "name": "country", "region": "region",
                              "incomeLevel": "income_group"})
    # wbgapi returns region records as {"code", "name"} (older versions: {"id", "value"})
    regions = {r.get("code", r.get("id")): r.get("name", r.get("value"))
               for r in wb.region.list()}
    eco["region_name"] = eco["region"].map(regions)
    eco = eco[["iso3", "country", "region", "region_name", "income_group"]]
    eco.to_csv(folder / "countries.csv", index=False)
    codes = eco["iso3"].tolist()

    frames, labels, failed = [], {}, []
    for short, code in INDICATORS.items():
        try:
            d = wb.data.DataFrame(code, economy=codes, time=range(START, END + 1),
                                  numericTimeKeys=True, skipBlanks=False)
            d = d.reset_index().melt(id_vars="economy", var_name="year", value_name=short)
            frames.append(d.set_index(["economy", "year"]))
            meta = wb.series.get(code)
            labels[short] = (code, meta.get("value", meta.get("name", "")))
            print(f"ok    {short:12s} {code}")
        except Exception as e:  # a retired or renamed code should not stop the build
            failed.append(code)
            print(f"FAIL  {short:12s} {code}: {e}")

    panel = pd.concat(frames, axis=1).reset_index().rename(columns={"economy": "iso3"})
    panel = eco[["iso3", "country"]].merge(panel, on="iso3").sort_values(["iso3", "year"])
    out = folder / "wdi_multi.csv"
    panel.to_csv(out, index=False)

    try:
        vintage = wb.source.get(2)["lastupdated"]
    except Exception:
        vintage = "unknown"

    lines = [
        "# World Development Indicators: multi-indicator panel",
        "",
        "- Source: World Bank, World Development Indicators (API source 2)",
        f"- Database last updated (API): {vintage}",
        f"- Frozen on: {date.today().isoformat()}",
        "- License: CC BY 4.0",
        f"- Coverage: {panel['iso3'].nunique()} economies, {START}-{END}",
        f"- Output: `{out.name}` ({len(panel):,} rows, {panel.shape[1]} columns)",
        f"- Output SHA-256: `{sha256(out)}`",
        f"- countries.csv SHA-256: `{sha256(folder / 'countries.csv')}`",
        "- Region and income group are the classifications in force on the freeze date.",
        "",
        "## Indicators",
        "",
        "| Column | WDI code | Name |",
        "|---|---|---|",
    ]
    lines += [f"| `{s}` | {c} | {n} |" for s, (c, n) in labels.items()]
    if failed:
        lines += ["", f"Codes not retrieved: {', '.join(failed)}"]
    (folder / "MANIFEST.md").write_text("\n".join(lines) + "\n", encoding="utf-8")
    print(f"\nWDI: {len(panel):,} rows, {len(labels)} indicators -> {out}")


if __name__ == "__main__":
    main()
