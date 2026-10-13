# 🔍 Reality Check – Plausibilität, Thermik, Strom & Kompatibilität

> Zurück zur [README](../README.md) · 📄 [Referenz-PDF SM-2026TT-SPEC-V1](reference/SM-2026TT-SPEC-V1_supermicro-2026tt-red-team-cluster-hardware-spec.pdf)

Die Spezifikation des Clusters wird in diesem Repository **unverändert übernommen**. Dieses Dokument ergänzt sie um **respektvolle, sachliche Hinweise** – dort, wo Physik, Herstellerangaben oder Plattform-Alter Grenzen setzen. Ziel: Hardware schützen, Brandrisiken vermeiden, Frust beim Debugging sparen.

| Legende | |
|---|---|
| 🟢 | Unkritisch, nur Hinweis |
| 🟡 | Funktioniert mit Einschränkungen / Prüfung nötig |
| 🔴 | Hohes Risiko oder wahrscheinlich inkompatibel – vor Betrieb klären |

---

<a id="rc-1"></a>
## RC-1 🟡 Netzteile: „2'800 W total“

- **Spec:** 2× 1400 W PWS-1K41P-1R (Platinum), N+1, „2'800 W total“, + 2 Spare-Module.
- **Realität:** In **N+1-Redundanz** muss die Last von **einem** Netzteil getragen werden können. Nutzbare Dauerleistung ≈ **1'400 W** (bei 100–120 V Eingang typischerweise weniger – Typenschild prüfen; in FL/CH mit 230 V ist das volle Rating üblich). 2'800 W ist die Summe der Nennleistungen.
- **Konsequenz:** Die vom PDF genannten **> 1'200 W Peak** liegen nahe an der Grenze eines einzelnen Moduls. Die extern betriebenen GPUs (Riser + eigene ATX-PSU) belasten zwar nicht die Chassis-PSUs, aber **denselben Stromkreis**.
- ✅ **Empfehlung:** Leistung über PMBus/IPMI (`ipmitool dcmi power reading`, sofern unterstützt) und Messsteckdose überwachen; Elektrofachkraft gemäss PDF-Sicherheitshinweis.

<a id="rc-2"></a>
## RC-2 🔴 250–285 W GPUs in einem 2U-Twin-Node

- **Spec:** GTX 1080 Ti (250 W, 6+8-Pin) an NODE 0, RTX 3070 Ti (285 W lt. Spec, 2× 8-Pin) an NODE 2, jeweils via Kolink-Riser.
- **Realität:**
  - Ein Node im 2026TT ist ein flacher Einschub mit **einem Low-Profile PCIe-2.0-x16-Slot** (via Riser RSC-R1U-E16R). Dual-Slot-Full-Height-Karten **passen physisch nicht** ins Gehäuse.
  - Die Node-Boards haben **keine** PCIe-6/8-Pin-GPU-Stromanschlüsse.
  - NVIDIA nennt für die RTX 3070 Ti **290 W** Total Graphics Power (Spec: 285 W) – Differenz unerheblich, aber erwähnenswert.
  - Der Chassis-Airflow ist auf **CPU + Low-Profile-Karte** ausgelegt. Ein Riser-Kabel, das den Deckel offenhält, **zerstört den Luftstrom aller 4 Nodes**.
- ✅ **Empfehlung:** GPUs **ausserhalb** des Chassis (offenes Rig/Regalfach) mit **separater ATX-Netzteil-Versorgung** und eigener Kühlung; Riser sauber aus dem Slotblech führen; Chassis vollständig geschlossen. Riser-Datenblatt bzgl. Masseverbindung beachten.

<a id="rc-3"></a>
## RC-3 🔴 Ein PCIe-Slot pro Node: X710 vs. GPU

- **Spec:** Pro Node Intel X710 Dual-SFP+ **und** (bei N0/N1/N2) GPU/eGPU.
- **Realität:** Laut SuperMicro-Manual hat jeder X8DTT-Node **genau einen** PCIe-2.0-x16-Slot. X710 (Add-in-Karte) und GPU-Riser bzw. TB5-Adapter **konkurrieren** um diesen Slot. Bifurcation (x8/x8) wird vom BIOS dieser Generation typischerweise nicht angeboten.
- ✅ **Optionen:**
  1. Pro Node **entweder** 10GbE **oder** GPU (z. B. NODE 3 und NODE 1 mit X710, NODE 0/2 mit GPU, 1GbE für deren Netz).
  2. Aktive **PCIe-Switch-Karte** (PLX/PEX) – teurer, IOMMU-Gruppen beachten, mechanisch im Low-Profile-Slot schwierig.
  3. Varianten wie *HIBXF/HIBQF* haben **onboard InfiniBand** (QSFP) – falls vorhanden, als zusätzliches Hochgeschwindigkeitsnetz nutzbar (IPoIB), statt X710.

<a id="rc-4"></a>
## RC-4 🔴 Thunderbolt 5 auf einem Westmere-Node (NODE 1)

- **Spec:** ASUS XG Mobile RTX 3080 eGPU via **TB5-Host-Adapter** (PCIe 4.0 x4 Tunneling, wie angegeben).
- **Realität:**
  - Westmere/5520-Boards haben **keinen** Thunderbolt-Controller, **keinen** TB-Header und keine Firmware-Unterstützung (TB-Add-in-Karten verlangen meist einen Mainboard-Header und BIOS-Optionen). Hot-Plug, Security-Level und PCIe-Ressourcenzuweisung sind ohne BIOS-Support unzuverlässig.
  - Der Host-Slot ist **PCIe 2.0**: selbst ein funktionierender TB5-Adapter wird auf **Gen2-Geschwindigkeit** des Slots begrenzt (Adapter sind meist x4 angebunden ⇒ ~2 GB/s).
  - Das **ROG XG Mobile GC31** (2021, RTX 3080 Laptop GPU) nutzt laut ASUS-Spezifikation die **proprietäre „ROG XG Mobile interface (PCIe Gen3 x8)“** plus USB-C – **nicht Thunderbolt**. Ein TB5-Host-Adapter kann das XG-Mobile-Interface nicht nativ ansprechen; nur neuere XG-Mobile-Generationen setzen auf Thunderbolt/USB4.
- ✅ **Einordnung:** **Experimentell**, Erfolg nicht garantiert. Für Cowrie/Credential-Trapping ist ohnehin **keine GPU nötig**; „Real-time Tensor Parsing“ kann alternativ auf NODE 2 oder dem Off-Cluster-Laptop (RTX 4070) laufen.

<a id="rc-5"></a>
## RC-5 🟡 „Passiv gekühlter“ NODE 3

- **Spec:** NODE 3 passiv gekühlt (GPU-Slot laut PDF „dediziert unbelegt – Kühlungsentlastung“).
- **Realität:** Im SYS-2026TT sind **alle** CPUs mit **passiven Kühlkörpern** ausgestattet; die Kühlung erfolgt durch die **gemeinsamen** Chassis-Lüfter (Front-to-Back). „Passiv“ stimmt also für den Kühlkörper, nicht im Sinne „lüfterlos“. Ein Node ist thermisch nicht unabhängig.
- ✅ **Empfehlung:** Air-Shrouds und Slot-Blenden montiert lassen; leere Drive-Bays mit Caddies/Blanks verschliessen; Temperaturen per IPMI überwachen. Die 1 TB HDD (Constellation ES) mag kühle, stabile Temperaturen.

<a id="rc-6"></a>
## RC-6 🟡 RAM-Bestückung vs. Slotanzahl

- **PDF:** NODE 0 „12× 8 GB, 6 Slots frei“, NODE 1/2 „16× 8 GB, 2 Slots frei“, NODE 3 „6× 8 GB, 12 Slots frei“ → impliziert 18 Slots/Node.
- **SuperMicro (X8DTT-H+ Serie):** **12 DIMM-Slots pro Node**, max. 192 GB RDIMM.
- **Konsequenz:** 16 Module passen nicht in 12 Slots; 128 GB entsteht z. B. aus **8× 16 GB**. Die Gesamtsumme **400 GB** ist korrekt und wird so übernommen. Bitte `dmidecode -t memory` prüfen.

<a id="rc-7"></a>
## RC-7 🟡 Core-Switch-Ports

- **Spec:** Huawei S220S-24LP4JX als 10Gb-Core; „Inter-Node Mesh via Huawei S220S Backbone“.
- **Datenblatt:** 24× GE PoE+, **2× 10GE SFP+**, 2× 2.5GE SFP; max. zwei unterschiedliche Raten gleichzeitig auf den vier optischen Ports.
- **Konsequenz:** 4 Nodes × 2 X710-Ports passen nicht an 2 SFP+-Ports → Ring/Routed Mesh per DAC (Phase 3 sieht DAC-Kabel vor ✅), siehe [Architektur](architecture.md#-10gbe-ohne-genug-switch-ports-ring).

<a id="rc-8"></a>
## RC-8 🟢 „iLO“ vs. IPMI

iLO ist HPEs BMC-Marke. Das 2026TT nutzt **SuperMicro IPMI 2.0** mit dediziertem LAN-Port. Funktion (OOB, KVM-over-IP, Sensoren) identisch. ⚠️ Alte BMC-Firmware hat bekannte Schwachstellen → **niemals** ins Internet oder in Lab-/DMZ-VLANs; nur VLAN 20, nur via Jumphost.

<a id="rc-9"></a>
## RC-9 🟡 eGPU-Kenndaten

PDF: XG Mobile RTX 3080 „8 GB GDDR6, 140 W“. ASUS-Spec GC31: RTX 3080 Laptop GPU **16 GB GDDR6, bis 150 W**; die RTX-3070-Variante hat **8 GB** und **125 W (140 W mit Dynamic Boost)**. Möglicherweise wurden Werte vermischt – am Gerät mit `nvidia-smi` verifizieren.

<a id="rc-10"></a>
## RC-10 🟡 Westmere-Plattformgrenzen

| Grenze | Detail |
|---|---|
| Kein AVX/AVX2/AVX-512 | Prebuilt TensorFlow (seit 1.6) & diverse Wheels erfordern AVX |
| PCIe 2.0 | ~8 GB/s auf x16; Riser-Rating „PCIe 5.0“ (NODE 0) ändert daran nichts |
| VT-d der 5520-Generation | Bekannte Interrupt-Remapping-Errata bei bestimmten 5500/5520-Revisionen – Linux deaktiviert IR dann und meldet das in `dmesg`; ggf. `allow_unsafe_interrupts=1` nötig (**Sicherheits-Tradeoff**: schwächt DMA/Interrupt-Isolation gegenüber der VM) |
| NVIDIA-Treiber | Pascal (1080 Ti) und Ampere (30er) werden aktuell unterstützt; NVIDIA hat für ältere Architekturen Support-Enden angekündigt bzw. vollzogen → Treiber-Branch planen |
| SATA | ICH10R, SATA 3 Gb/s |
| Microcode/BIOS | Keine aktuellen Updates mehr; nicht als Mandanten-Plattform für fremde, untrusted Workloads verwenden |
| Strom/Leistung | Gutes RAM/€-Verhältnis, aber schlechtes Rechenleistung/Watt-Verhältnis verglichen mit aktuellen CPUs |

<a id="rc-11"></a>
## RC-11 🟢 Firewalla Gold Pro

Das PDF nennt „Gigabit WAN/LAN (25 W)“. Der Hersteller bewirbt die Gold Pro mit **10GbE- und 2.5GbE-Ports** – bitte am Gerät verifizieren; für den Cluster-Entwurf ändert sich nichts Wesentliches (WAN-Uplink ist ohnehin der Engpass).

---

> 💬 *Keiner dieser Punkte macht das Projekt schlecht – im Gegenteil: Genau an diesen Grenzen lernt man, wie Hardware wirklich funktioniert.* 🛠️
