# Edenemisraport



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
- Korrigeerida dashboardi graafikuid ja parendada visualiseeringuid

## Mis takistab

- Praegu pole blokeerivaid probleeme

## Kontrollpunkt

Käsk, millega saab kontrollida, et töövoog töötab:

```bash
# [Lisa siia käsk, mis näitab, et andmed liiguvad allikast näidikulauani]
# Näiteks:
docker compose exec airflow-scheduler airflow dags trigger energy_weather_pipeline
```

Oodatav tulemus ja näidikulaua testimine
Andmetorustiku käivitamine:
Pärast käsu käivitamist peaks terminalis kuvatav tabel näitama, et käsk töötas ja DAG läks edukalt käivitusjärjekorda (olekusse queued või running).

Näidikulaua kontrollimine:
Selleks, et testida, kas andmed jõudsid lõpuks edukalt näidikulauani, saab kodutöö_dash_v1.twbx faili üles laadida ja testida Tableau Public keskkonnas.
