# 🤝 Beitragen

Danke für Interesse an **The Sovereign Datacenter**!

## Grundsätze

1. **Ehrlich bleiben.** Keine erfundenen Benchmarks. Schätzungen als solche kennzeichnen, Quellen zitieren.
2. **Westmere-Grenzen respektieren.** Keine Claims, die PCIe 2.0 / kein-AVX / 2U-Twin-Thermik widersprechen. Reality Checks aktualisieren statt verschweigen.
3. **Platzhalter klar markieren.** In Configs `<<PLACEHOLDER>>` oder offensichtlich gefälschte Netze (`10.10.x.x`, `203.0.113.0/24` TEST-NET-3).
4. **Keine Secrets.** Keine Tokens, Passwörter, private Keys, echte öffentliche IPs von Produktions-Honeypots.
5. **Sprache.** Dokumentation auf **Deutsch**; technische Begriffe (ZFS, Corosync, VFIO …) dürfen Englisch bleiben.
6. **Sicherheit & Recht.** Keine Anleitungen für Angriffe auf fremde Systeme. Labs/Honeypots immer isoliert und rechtlich abgesichert beschreiben.

## Workflow

```bash
# Fork / Branch
git checkout -b feat/kurze-beschreibung

# Änderungen, dann
git add -A
git commit -m "docs: …"   # oder feat:/fix:/chore:

# Pull Request mit kurzer Begründung + Reality-Check-Impact
```

## Was besonders willkommen ist

- Gemessene Werte (Strom, ARC-Hitrate, `fio`, Suricata-PPS) **mit Methodik**
- Getestete VFIO-/Riser-Erfahrungen auf X8DTT
- Verbesserungen an SDN-/nftables-Beispielen
- Übersetzungen (ohne die deutsche Fassung zu ersetzen)

## Lizenz

Mit deinem Beitrag akzeptierst du: Code/Configs unter **MIT**, Doku unter **CC BY-SA 4.0** (siehe [LICENSE](LICENSE)).
