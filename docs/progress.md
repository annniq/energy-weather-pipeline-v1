# Edenemisraport

> **Juhend:** See fail on projektitöö teise nädala väljund. Uuenda lühidalt iga esitamise eel. Kustuta see juhendrida.

## Mis on valmis

- [ ] Docker Compose käivitab kõik teenused
- [ ] Andmeid saadakse allikast kätte
- [ ] Andmed laetakse `staging` kihti
- [ ] Vähemalt üks transformatsioon toimib
- [ ] Vähemalt üks näidikulaud on nähtaval
- [ ] Vähemalt üks andmekvaliteedi test läbib

[Täpsusta lühidalt, mis täpselt valmis on]

## Järgmised sammud

- [Esimene tegevus, mis ees ootab]
- [Teine tegevus]
- [Kolmas tegevus]
- Esimesed dashboardi näited:
- [Dash 1](https://public.tableau.com/app/profile/anniq.k/viz/kodut_dash_v1/dash1?publish=yes).
- [Dash 2](https://public.tableau.com/app/profile/anniq.k/viz/kodut_dash_v1/dash2?publish=yes).


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
