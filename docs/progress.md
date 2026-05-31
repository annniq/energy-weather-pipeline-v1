# Edenemisraport

> **Juhend:** See fail on projektitöö teise nädala väljund. Uuenda lühidalt iga esitamise eel. Kustuta see juhendrida.

## Mis on valmis

- [x] Docker Compose käivitab kõik teenused
- [x] Andmeid saadakse allikast kätte
- [x] Andmed laetakse `staging` kihti
- [x] Vähemalt üks transformatsioon toimib
- [x] Vähemalt üks näidikulaud on nähtaval
- [x] Vähemalt üks andmekvaliteedi test läbib

Projektis on valminud terviklik andmevoog alates andmete sissevõtust kuni visualiseerimiseni. Andmed kogutakse kahest erinevast allikast, laaditakse automaatselt üks kord päevas ning teisendatakse analüüsiks sobivale kujule, sealhulgas viiakse läbi vajalikud tüübiteisendused ja luuakse dimensioonide ning mõõdikute jaoks sobivad väljad. Tableaus on loodud esmased visualiseeringud, mis sisaldavad KPI-sid ja graafikuid elektrihinna ning ilmastikutegurite vaheliste korrelatsioonide analüüsimiseks riikide ja kuude lõikes.

## Järgmised sammud

- Esimesed dashboardi näited:
- [Dash 1](https://public.tableau.com/app/profile/anniq.k/viz/kodut_dash_v1/dash1?publish=yes).
- [Dash 2](https://public.tableau.com/app/profile/anniq.k/viz/kodut_dash_v1/dash2?publish=yes).
- [Dash 3](https://public.tableau.com/app/profile/anniq.k/viz/kodut_dash_v1/dash3?publish=yes).

Vajab tegemist :
- Kuidas panna automaatselt uuenema Tabeleau Public extract
- Mida järeldada andmetest, kas saab täpsustada äriküsimust
- Eemadalda kõik "bugid" ja täiendada dashboarde
- Täiendada andmekvaliteediteste
- korrigeerida dashboardi graafikuid ja parendada visualiseeringuid

## Mis takistab

- [Probleem 1 — näiteks: API tagastab vigaseid väärtusi ühes linnas]
- [Probleem 2 — või: "Praegu pole blokeerivaid probleeme"]

## Kontrollpunkt

Käsk, millega saab kontrollida, et töövoog töötab:

```bash
# [Lisa siia käsk, mis näitab, et andmed liiguvad allikast näidikulauani]
# Näiteks:
docker compose exec pipeline python scripts/run_pipeline.py check
```

Oodatav tulemus: [Kirjelda, mida töötav süsteem väljastab]
