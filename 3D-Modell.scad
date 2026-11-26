// ============================================================
// Empfangsgebäude Berlin-Lichterfelde West  –  Spur H0 (1:87)
// Stufe 1: Gebäudehülle (Wände + Dächer), ohne Fenster/Türen
// ------------------------------------------------------------
// Alle Gebäudemaße unten sind ECHTE Meter (aus Foto/Zeichnung
// geschätzt). Am Ende wird alles ddddauf Modell-mm skaliert.
// Koordinaten:  x = entlang der Fassade (links -> rechts)
//               y = Tiefe (y=0 Straßenseite, +y Richtung Gleise)
//               z = Höhe (z=0 Gelände / Oberkante Sockel)
// ============================================================

// ------------------------------------------------------------
// GEBÄUDETEILE – Bezeichnungen in Code und Kommentaren
//   Hauptgebäude     = linker Flügel (mit Türmchen und Turm) + Mittelrisalit + rechter Flügel
//                      (x_hg0 .. x_hg1, Front der Flügel bei y_main[0])
//     linker Flügel    x_lw0 .. x_tow1    liegt hinter Turm und Türmchen, Giebelwand links bei x_lw0
//     Türmchen         x_tt0 .. x_tt1     vor dem linken Flügel, links neben dem Turm
//     Turm             x_tow0 .. x_tow1
//     Mittelrisalit    x_ris0 .. x_ris1   = Eingangsrisalit (drei Türen, vier Fenster, Schriftzug); x_ris0 liegt RIS_HINTER_TURM
//                      hinter dem Turm, sichtbar ist es ab x_tow1; Giebelachse = Mitte von x_ris0 .. x_ris1
//     rechter Flügel   x_tow1 .. x_end    Tür, Fenster, Blindfenster in der rechten Giebelwand
//   Zwischengebäude  = zweifenstriger Bau links neben dem Hauptgebäude (x_zw0 .. x_zw1, früher "Mittelbau")
//   Pavillon         = Bau links vom Zwischengebäude (Walmdach)
//   Anbau            = niedriger Bau ganz links vom Pavillon (vorderer Teil + links zurückspringender hinterer Teil,
//                      sehr flaches Walmdach mit Plateau, Traufkante umlaufend waagerecht; 3 Fenster in der Front, Tür mit Ziegeltreppe, seitliche Fenster)
// ------------------------------------------------------------

M        = 87;      // Maßstab 1:M
WAND_MM  = 4;       // Wandstärke im Modell [mm]
DACH_MM  = 1.5;     // Dachhaut-Stärke (senkrecht gemessen) im Modell [mm]

t   = WAND_MM * M / 1000;   // Wandstärke in Meter (real)
td  = DACH_MM * M / 1000;   // Dachhaut in Meter (real)
eps = 0.001;

// ---------- Farben (nur für die F5-Vorschau) ----------
C_KLINKER  = [0.91, 0.74, 0.40];   // gelber Klinker
C_SCHIEFER = [0.36, 0.39, 0.42];   // schiefergrau
C_DUNKEL   = [0.22, 0.20, 0.16];   // Fensterrahmen, Zeiger
C_GLAS     = [0.36, 0.41, 0.48];   // Verglasung
C_RING     = [0.45, 0.16, 0.12];   // Uhrring (roter Klinker)
C_BETON    = [0.62, 0.62, 0.60];   // grauer Betonsockel
C_FUGE     = [0.52, 0.52, 0.52];   // Fugen: grau
C_BAND     = [0.52, 0.22, 0.16];   // braunrote Ziegel (Sockelband, rote Schichten, Zahnfries)
C_TUER     = [0.55, 0.64, 0.55];   // Tür: graugrün
C_GELAENDER= [0.15, 0.28, 0.20];   // Geländer: dunkelgrün
C_BOGEN    = C_KLINKER;            // Bogenfries über der Tür: gelb
C_SCHILD   = [0.62, 0.60, 0.55];   // Klinkenschild (Metall)
C_STURZ    = [0.80, 0.52, 0.30];   // Fenstersturz (hochkant gestellte Ziegel, etwas rötlicher)
C_ROLL     = [0.72, 0.27, 0.18];   // Rollschicht: ziegelrot
C_HOLZ     = [0.20, 0.40, 0.28];   // grünes Holz (Balken über der Laterne)
C_ZTREPPE  = C_ROLL;               // Ziegeltreppe des Anbaus: ziegelrot

// ---------- Ziegelstruktur ----------
ZIEGEL        = true;     // Fugen darstellen? false = glatte Flächen (schnellste Vorschau).
                          // Die Ziegelmaße unten gelten auch bei false: Bandhöhe und
                          // Beginn des gelben Mauerwerks hängen von Schichthöhe ab.
FUGEN_GRAU    = $preview; // Fugen grau einfärben (Füllkörper in den Fugen, nur Vorschau-Farbe).
                          // Nur in der Vorschau (F5): beim Rendern/Export (F6) entfällt der zweite
                          // Fugenkörper, und die Nuten bleiben für den Druck offen.
STOSSFUGEN    = false;    // false = nur Lagerfugen (waagerecht, schnell)
                          // true  = zusätzlich Stoßfugen (senkrecht, viel Geometrie)
STOSS_FLAECHEN = "front"; // wo Stoßfugen geschnitten werden (nur wirksam bei STOSSFUGEN = true):
                          // "front" = nur Straßenseiten (ca. 17.000 Rechtecke)
                          // "alle"  = auch Rück- und Seitenwände (ca. 60.000 Rechtecke, sehr langsam)
                          // Lagerfugen sind immer überall: je Fläche ein Polygon, ein Schnitt.
VERBAND       = "laeufer";  // "kreuz" = Kreuzverband, "block" = Blockverband, "laeufer" = Läuferverband
                          // (senkrechte Fugen sind nur sichtbar, wenn STOSSFUGEN = true)
FUGENTIEFE_MM = 0.10;     // Fugentiefe im Modell [mm]
// Reichsformat 250 x 120 x 65 mm, Lager- und Stoßfugen 10 mm (echte Meter)
Z_L = 0.250;  Z_B = 0.120;  Z_H = 0.065;  Z_FUGE = 0.010;
Z_PX = Z_L + Z_FUGE;      // Läufer-Rastermaß 0,26 m
Z_PZ = Z_H + Z_FUGE;      // Schichthöhe 0,075 m (4 Schichten = 30 cm)
fd   = FUGENTIEFE_MM * M / 1000;
STOSS_V    = STOSSFUGEN && STOSS_FLAECHEN != "aus";     // Straßenseiten (Außenfläche -y)
STOSS_REST = STOSSFUGEN && STOSS_FLAECHEN == "alle";    // alle übrigen Flächen

// ---------- Betonsockel und braunrotes Ziegelband ----------
// Von unten nach oben: Betonsockel, Band aus braunroten Ziegeln, gelbes Mauerwerk.
// Sockel und Band stehen vor der gelben Wandfläche vor (Maße im Modell in mm).
SOCKEL              = true;   // grauer Betonsockel
SOCKEL_HOEHE_MM     = 3.5;    // Sockelhöhe (ca. 0,30 m real)
SOCKEL_VORSPRUNG_MM = 0.8;    // Vorsprung des Sockels vor dem gelben Mauerwerk
BAND                = true;   // braunrotes Ziegelband über dem Sockel
BAND_SCHICHTEN      = 19;     // Ziegelschichten in der Höhe (Straßenseite)
BAND_REIHEN_GLEIS   = 13;     // Gleisseite: so viele Ziegelreihen des Bandes sind über dem Sockel sichtbar; der Bahnsteig liegt entsprechend höher
BAHNSTEIG_SOCKEL    = true;   // Gleisseite: grauer Betonsockel sitzt auf der Bahnsteigoberkante (darüber BAND_REIHEN_GLEIS Reihen)
BAND_VORSPRUNG_MM   = 0.4;    // Vorsprung des Bandes vor dem gelben Mauerwerk

zs   = SOCKEL ? SOCKEL_HOEHE_MM * M / 1000 : 0;   // Oberkante Sockel (echte m)
nb   = BAND ? BAND_SCHICHTEN : 0;
z_bt = zs + nb * Z_PZ - Z_FUGE;   // Oberkante letzter Bandziegel
z_y0 = zs + nb * Z_PZ;            // erste Schicht des gelben Mauerwerks
// Bahnsteigoberkante (Gleisseite): von oben nach unten 13 Bandreihen, grauer Betonsockel, Oberkante Bahnsteig
bs_h = max(0, (nb - BAND_REIHEN_GLEIS) * Z_PZ);
ps   = SOCKEL_VORSPRUNG_MM * M / 1000;
pb   = BAND_VORSPRUNG_MM * M / 1000;
$teil = "mauer";                  // intern: welche Fugen gerade geschnitten werden
$pav  = "mit";                    // intern: Zahnfries des Pavillons: "nur" = nur Wandflächen des Pavillons, "mit" = alle Flächen
$tt   = "mit";                    // intern: Fugen der Flächen von Türmchen und Pavillon: "mit" oder "ohne"
$zw   = "mit";                    // intern: Fugen der Wandflächen des Zwischengebäudes: "mit" = alle Flächen,
                                  // "nur" = nur Zwischengebäude, "ohne" = alle außer Zwischengebäude
$bz0 = 0; $bz1 = 0; $bp = 0; $bj0 = 0;   // intern: aktuelles Band

// ---------- Traufschema: Schichtenfolge über dem Sockelband ----------
// Von unten nach oben, umlaufend um alle Baukörper. Eintrag: [Typ, Anzahl Reihen]
//   "g" gelbe Schichten
//   "r" rote Schichten, praktisch bündig mit dem gelben Mauerwerk
//   "v" rote Schicht, springt vor
//   "z" roter Zahnfries: Ziegel aufrecht, 45° gewinkelt. Eine Zahnfries-Reihe ist
//       ZAHN_SCHICHTEN Mauerwerksschichten hoch (aufrechte Ziegel sind höher als Läufer).
// Die Summe bestimmt die Traufhöhe (Oberkante der letzten Reihe).
TRAUFE_SCHEMA = [
    ["g", 21], ["r", 1], ["g", 2], ["r", 1],
    ["g", 22],
    ["r", 1], ["g", 2], ["r", 1],     // dicker roter Streifen: rot, 2 gelb, rot ...
    ["v", 1],                         // ... und ein vorspringender roter Stein
    ["g", 27], ["r", 1], ["z", 1], ["r", 1]      // Zahnfries: Läufer, senkrechter Zahn, abschließender Läufer; darauf sitzt der grüne Dachkasten
];
TRAUFE_OBEN_AB     = 10;     // Index im TRAUFE_SCHEMA, ab dem das obere rote Band (r, Zahnfries, r) beginnt
TRAUFE_BAND_OBEN   = false;  // false = KEINE glatten roten Läuferreihen (r) waagerecht um den Zahnfries (das war das Doppelband an Giebelwänden und Risalit); der Zahnfries selbst bleibt immer
                             // true  = diese Läuferreihen werden wieder gebaut
GIEBEL_LINKS_ROT   = false;  // false = an der linken Giebelwand (x_lw0) laufen die roten Zierreihen (r, v) NICHT; die Wand bleibt dort gelb
ZAHN_SCHICHTEN     = 3;      // Höhe einer Zahnfries-Reihe in Schichten (1 = nur eine Schicht hoch)
TURM_BALKEN_VORSPRUNG = 0.10;   // grüner Balken über der Laterne: Vorsprung vor der Wand (größer als der der Kappenreihe) [m]
TURM_KAPPE_VORSPRUNG = 0.05;    // Laterne: die volle rote Kappenreihe über den Pfeilern springt um dieses Maß vor [m]
FLACH_VORSPRUNG_MM = 0.05;   // "r": nur minimal vor der Wand (verhindert Flackern der Farben)
VOR_VORSPRUNG_MM   = 0.40;   // "v": vorspringende rote Schicht
ZAHN_WINKEL        = 45;     // Zahnfries: Winkel der Ziegel zur Wand [°]
ZAHN_TIEFE         = 0.065;  // Zahnfries: Vorsprung der Ziegelkanten vor der Wand [m real]
ZAHN_TEILUNG       = (Z_H + Z_FUGE) / sin(ZAHN_WINKEL);   // Abstand der Ziegel entlang der Wand

ZAHN_GIEBEL_HAUPT  = true;   // Zahnfries an den Giebelwänden des rechten Flügels (rechte Außenwand und Rückwand
                             // zum Turm hin) folgt der Dachkante statt waagerecht zu laufen

pf = FLACH_VORSPRUNG_MM * M / 1000;
pv = VOR_VORSPRUNG_MM   * M / 1000;
pmax = max(ps, pb, pv, pf, ZAHN_TIEFE, TURM_KAPPE_VORSPRUNG);

// ---------- GEMEINSAME Parameter für alle Türen und Fenster (Rundbogenöffnungen) ----------
GEWAENDE_STUFE           = Z_PX / 2; // Stufengewände: innere Öffnung je Seite um einen Halbziegel
                                    // (halber Läufer + Fuge = 0,13 m, im Modell ca. 1,5 mm)
                                    // schmaler UND um dasselbe Maß nach hinten versetzt
BOGEN_BREITE             = Z_L;     // Bogenfries: radiale Breite (ein Läufer)
BOGEN_VORSPRUNG_MM       = 0;       // Bogenfries: Hervorspringen vor der Wand (Modell-mm); 0 = bündig
                                    // (intern +2 mm real, damit die Fugen des Bogens sichtbar bleiben)
SPROSSENFUSS             = 0.09;    // Radius des Halbkreises am Fuß der senkrechten Oberlicht-Sprosse

// ---------- Tür rechts im rechten Flügel (Maße in echten Metern, aus dem Foto geschätzt) ----------
TUER                     = true;
// TUER_X (Türmitte) steht unten bei WAND_MITTE, weil es x_end braucht (Variablen gelten erst ab ihrer Zeile)
TUER_BREITE              = 1.40;    // lichte Breite der inneren Öffnung (zwei Flügel)
TUER_BOGEN_SCHMAL        = false;   // Bogen über der Tür: false = Längsseiten radial, true = Schmalseiten
TUER_FLUEGELHOEHE        = 2.60;    // Türflügel von Podestoberkante bis Kämpfer
TUER_KAEMPFER            = 0.12;    // Kämpfer zwischen Flügeln und Oberlicht
TUER_OBERLICHT_GERADE    = 0.15;    // gerader Teil des Oberlichts unter dem Halbkreis
TUERSCHILD               = true;    // Klinkenschild mit Schlüsselloch (linker Flügel)
TUERSCHILD_B             = 0.07;    // Breite des Schildes (sitzt auf dem Mittelstil)
TUERSCHILD_H             = 0.28;    // Höhe des Schildes
KLINKE_HOEHE             = 0.95;    // Höhe der Klinke über der Podestoberkante
PODEST_SCHICHTEN         = 5;       // Podestoberkante nach so vielen Ziegelreihen über dem Sockel
PODEST_TIEFE             = 1.00;    // Tiefe des Podests vor der Wand
PODEST_UEBERSTAND        = 0.45;    // Podest/Treppe seitlich über die Öffnung hinaus
TREPPE_STEIGUNGEN        = 4;       // Stufen vom Boden bis zum Podest (= Anzahl Steigungen)
TREPPE_AUFTRITT          = 0.30;

// ---------- Fenster über der Tür (gleiche Grundsätze wie die Tür) ----------
FENSTER                  = true;
FENSTER_HALBZIEGEL       = 9;       // Breite ÜBER ALLES (Mauerwerksöffnung inkl. Stufengewände) in Halbziegeln
                                    // (Halbziegel = halber Läufer + Fuge); die lichte Weite ist je Seite um ein Gewände schmaler
// FENSTER_X (Fenstermitte, standardmäßig mittig auf der Wand) steht unten bei x_end, weil es x_end braucht
FENSTER_BOGEN_OBEN       = 0;       // Scheitel des Bogenfrieses; 0 = Unterkante der letzten gelben Reihe
                                    // unter dem Zahnfries (aus TRAUFE_SCHEMA), sonst z in m
FENSTER_BANK_ABSTAND     = 0;       // gelbe Reihen zwischen dem obersten roten Band (der vorspringenden "v"-Reihe)
                                    // und der Fensteröffnung; 0 = Fenster sitzt direkt auf der roten Reihe
FENSTER_BOGEN_BREITE     = Z_B;     // Fensterbogen: EINE Rollschicht aus Köpfen (ein Halbziegel, 12 cm radial)
FENSTER_KAEMPFER         = 0.07;    // Kämpferhöhe am Bogenansatz
FENSTER_BOGEN_SCHMAL     = true;    // Bogen aus Schmalseiten (Köpfe 12 x 6,5 cm, eine Rollschicht);
                                    // false = Längsseiten radial
FENSTERBANK              = false;   // zusätzliche rote Schicht als Fensterbank (nur sinnvoll bei FENSTER_BANK_ABSTAND >= 1;
                                    // bei 0 ist die rote "v"-Reihe selbst die Fensterbank)
FENSTER_VERGLASUNG       = false;   // false = Fenster durchbrochen (nur Rahmen und Sprossen, kein Glaskörper)
FENSTERBANK_VORSPRUNG_MM = 0.5;
GELAENDER                = true;

// ---------- Eingangsrisalit (Front): 3 Türen mit gemeinsamer Treppe, 4 Fenster im 1. OG ----------
// Konstruktion, Maße und Höhen identisch zur Tür bzw. zum Fenster über der Tür im rechten Flügel.
RISALIT_OEFFNUNGEN       = true;
RIS_TUEREN               = true;
RIS_FENSTER              = true;
RIS_PFEILER              = Z_PX;    // Mauerpfeiler zwischen den äußeren Gewändekanten zweier benachbarter
                                    // Öffnungen: ein Läufer + Fuge = 0,26 m. Die Bogenfriese der Türen
                                    // überschneiden sich dadurch und treffen sich in der Pfeilermitte.
TUER_GLAS_UNTEN          = 0.90;    // Risalittüren: Höhe der geschlossenen Füllung (Kassette) über dem Podest,
                                    // darüber ist der Flügel verglast
TUER_GLAS_SPROSSEN       = 1;       // waagerechte Sprossen in der Glasfläche je Flügel
TUER_VERGLASUNG          = false;   // false = Glasfläche durchbrochen (nur Rahmen und Sprossen)

// ---------- Schriftzug über den Türen (erhaben, schwarz, Fraktur/altdeutsch) ----------
SCHRIFT                  = true;
SCHRIFT_TEXT             = "Berlin-Lichterfelde West";
SCHRIFT_FONT             = "UnifrakturMaguntia";   // altdeutsche Schrift, muss installiert sein (z. B. Google Fonts
                                                   // "UnifrakturMaguntia" / "UnifrakturCook"; Windows: "Old English Text MT")
SCHRIFT_BREITE           = 5.6;     // Breite des Schriftzugs [m real]
SCHRIFT_HOEHE            = 0.46;    // Höhe (Ober- bis Unterkante der Zeichen) [m real]
SCHRIFT_Z                = 4.93;    // Mitte des Schriftzugs [m real, über Gelände]: zwischen Türbogen und rotem Streifen
SCHRIFT_ERHABEN_MM       = 0.5;     // Erhabenheit im Modell [mm]

// ---------- Zwei schmale Fenster links und rechts der Tür ----------
FENSTER_SCHMAL              = true;
FENSTER_SCHMAL_HALBZIEGEL   = 4;      // lichte Weite in Halbziegeln (4 = zwei Läufer = 0,51 m), ohne Stufengewände
// Lage: Mitte zwischen Türrand (äußere Gewändekante) und Wandende, je Seite (siehe s_xs unten)
FENSTER_SCHMAL_BOGEN_BREITE = Z_B;    // Bogen: eine Rollschicht aus Köpfen (ein Halbziegel, 12 cm radial)
FENSTER_SCHMAL_RAHMEN       = 0.04;   // Rahmenbreite (m)
FENSTER_SCHMAL_SPROSSE      = 0.03;   // Sprossenbreite (m)
FENSTER_SCHMAL_VERGLASUNG   = false;  // false = durchbrochen (nur Rahmen und Sprossen)

function sch_n(e) = e[0] == "z" ? e[1] * ZAHN_SCHICHTEN : e[1];        // Schichten eines Eintrags
function lauf_n(l, i) = i <= 0 ? 0 : sch_n(l[i-1]) + lauf_n(l, i - 1);   // Schichten vor Eintrag i
n_schema  = lauf_n(TRAUFE_SCHEMA, len(TRAUFE_SCHEMA));
z_traufe  = z_y0 + n_schema * Z_PZ;      // Oberkante Mauerwerk incl. letzter Fuge

// ---------- Turmfenster (nach Foto): Rechteckfenster mit Sturz aus hochkant gestellten Ziegeln ----------
// Gemeinsame Maße aller Turmfenster
TURM_FENSTER_ZEILEN      = 15;                     // Fensterhöhe in Ziegelreihen (lichte Höhe 15 Schichten - Fuge)
TURM_FENSTER_PAAR_WI     = 2 * Z_L + Z_FUGE;       // lichte Weite der Paarfenster: 2 Läufer (0,51 m)
TURM_FENSTER_EINZEL_WI   = 1.5 * Z_L + Z_FUGE;     // lichte Weite des schmalen Einzelfensters: anderthalb Läufer (0,385 m)
TURM_EINZEL_ZEILEN       = 18;                     // Höhe des Einzelfensters in Ziegelreihen (nach Foto schlanker als die Paarfenster)
TURM_EINZEL_ABSTAND      = 17;                     // Ziegelreihen zwischen Oberkante des unteren Fensterpaares und Unterkante des Einzelfensters
TURM_EINZEL_GEWAENDE     = Z_PX / 2;               // Gewände rund um das Einzelfenster: halbe Ziegelbreite (Halbziegel + Fuge = 0,13 m)
TURM_STURZ_TIEFER        = 1;                      // Sturz des Einzelfensters um so viele Reihen tiefer (verkürzt das Gewände oben)
TURM_GEWAENDE_TIEFE      = 0.04;                   // das Gewände ist um dieses Maß [m real] gegenüber der Wandfläche zurückgesetzt
TURM_FENSTER_ABSTAND     = Z_PX;                   // Mauerwerk zwischen den beiden Fenstern eines Paares: 1 Läufer (+ Fuge)
TURM_STURZ_ZEILEN        = 3;                      // Höhe des Sturzes in Ziegelreihen (hochkant gestellte Läufer)
TURM_FENSTER_QUERSPROSSEN = 1;                     // Quersprossen je Fensterrahmen
TURM_VERGLASUNG          = FENSTER_VERGLASUNG;     // wie bei den übrigen Fenstern: false = durchbrochen
// Lage: erste Ziegelreihe (k, gezählt ab Beginn des gelben Mauerwerks) der Fensteröffnung
TURM_K_UNTEN             = lauf_n(TRAUFE_SCHEMA, erster_rot(TRAUFE_SCHEMA));   // unteres Paar: Unterkante auf Höhe des unteren roten Streifens (Reihe 21)
TURM_K_EINZEL            = TURM_K_UNTEN + TURM_FENSTER_ZEILEN + TURM_EINZEL_ABSTAND;   // Einzelfenster: mittig über dem unteren Paar
TURM_OBEN_ABSTAND        = 16;                     // Ziegelreihen zwischen Oberkante der Einzelfensteröffnung und der roten Reihe (Sohlbank) des oberen Paares
TURM_K_BANK              = TURM_K_EINZEL + TURM_EINZEL_ZEILEN + TURM_OBEN_ABSTAND;   // Reihe der roten Sohlbank des oberen Paares
TURM_K_OBEN              = TURM_K_BANK + 1;        // oberes Paar sitzt direkt auf der roten Reihe (15 Reihen lichte Höhe)
TURM_OBEN_GEWAENDE       = Z_PX / 2;               // zurückgesetztes Gewände rund um das obere Paar: halbe Ziegelbreite
TURM_BANK                = true;                   // rote Ziegelreihe (Sohlbank) unter dem oberen Paar, springt leicht vor
TURM_K_SEITE             = 133;                    // Paar auf den Seitenflächen (links/hinten, über den Dächern; unverändert)
// Musterverschiebung der beiden roten Streifen ("rot, 2 gelb, rot", Schemaeinträge TURM_STREIFEN_IDX) auf der
// Turmvorderseite: sie weichen dem unteren Fensterpaar aus, knicken um TURM_MUSTER_VERSCHIEBUNG Reihen nach unten,
// laufen unter dem Fensterpaar durch und knicken auf der anderen Seite wieder hoch (Fenster nach Foto).
TURM_MUSTER              = true;
TURM_MUSTER_VERSCHIEBUNG = 6;                      // Ziegelreihen nach unten
TURM_STREIFEN_IDX        = [1, 3];                 // Einträge im TRAUFE_SCHEMA (unterer, oberer roter Streifen)

// ---------- Turmvorderseite oben: Uhr, Rollschicht, rotes Band (alle Maße in Ziegelreihen, Zählung ab Oberkante der lichten Fensteröffnung des oberen Paares) ----------
TURM_K_LICHT_OBEN  = TURM_K_OBEN + TURM_FENSTER_ZEILEN;   // erste Reihe über der lichten Oberkante des oberen Fensterpaares
TURM_UHR_ABSTAND   = 8;     // Reihen zwischen lichter Fensteroberkante und Unterkante der Uhr
TURM_UHR_ZEILEN    = 14;    // Durchmesser der Uhr in Reihen (inkl. rotem Ziegelring)
TURM_ROLL_ABSTAND  = 34;    // Reihen zwischen lichter Fensteroberkante und Unterkante der Rollschicht
TURM_ROLL_ZEILEN   = 3;     // Höhe der Rollschicht in Reihen (hochkant gestellte Läufer, wie der Sturz)
TURM_BAND2_ABSTAND = 5;     // Reihen zwischen rotem Band und Unterkante der Rollschicht
TURM_BAND_OBEN     = true;  // rotes Ziegelband unter der Rollschicht
ROLL_VORSPRUNG_MM  = 0.6;   // Vorsprung der Rollschicht vor der Wand [Modell-mm]
UHR_ERHABEN_MM     = 1.0;   // Uhr steht so weit vor der Wand [Modell-mm] (Zarge); roter Ring etwas weniger
UHR_RING_B         = Z_H;   // roter Ring: Schmalseiten (Köpfe) liegen mit 6,5 cm radial, 12 cm in Umfangsrichtung
TURM_K_UHR   = TURM_K_LICHT_OBEN + TURM_UHR_ABSTAND;
TURM_K_ROLL  = TURM_K_LICHT_OBEN + TURM_ROLL_ABSTAND;
TURM_K_BAND2 = TURM_K_ROLL - TURM_BAND2_ABSTAND - 1;     // Band liegt in der Reihe, nach der noch 5 Reihen bis zur Rollschicht folgen
UHR_R   = (TURM_UHR_ZEILEN * Z_PZ - Z_FUGE) / 2;          // Außenradius inkl. Ring (14 Reihen = 1,04 m)
z_uhr   = z_y0 + TURM_K_UHR * Z_PZ + UHR_R;               // Uhr Mittelpunkt

// ---------- Turmbreite ----------
TURM_LAEUFER = 14;                                        // Turm: 14 Läufer im Quadrat
TURM_BREITE  = 3.72;                                      // Aufmaß t (vorher 14 Läufer = 3,63 m)

// ---------- Laterne über der Rollschicht (Reihen wie oben gezählt) ----------
// rote Reihe auf der Rollschicht, dann 24 Reihen (die 22. rot), dann rote Kappenreihe, dann eine Reihe grünes Holz
TURM_L_ROT0      = TURM_K_ROLL + TURM_ROLL_ZEILEN;        // rote Reihe direkt auf der Rollschicht (zugleich Sohle der Öffnungen)
TURM_L_ZEILEN    = 24;
TURM_L_ROT_NR    = 22;                                    // die wievielte dieser 24 Reihen rot ist
TURM_K_L0        = TURM_L_ROT0 + 1;                       // erste der 24 Reihen
TURM_K_LROT      = TURM_K_L0 + TURM_L_ROT_NR - 1;         // rote Zwischenreihe
TURM_K_KAPPE     = TURM_K_L0 + TURM_L_ZEILEN;             // rote Reihe auf den 24 Reihen (Kappe der Pfeiler und des Pfostens)
TURM_K_HOLZ      = TURM_K_KAPPE + 1;                      // Holzbalken
TURM_HOLZ_ZEILEN = 1;                                     // Balkenhöhe in Reihen
L_PFEILER        = 5 * Z_PX / 2;                          // Eckpfeiler je Seite: 5 Halbziegel = 0,65 m
L_GEW            = Z_PX / 2;                              // Gewände neben den Öffnungen: ein Halbziegel
L_POST           = Z_L;                                   // Mittelpfosten: 1 Läufer im Quadrat (0,25 x 0,25 m)
L_OEFF           = (TURM_BREITE - 2*L_PFEILER - 2*L_GEW - L_POST) / 2;   // lichte Weite je Öffnung (0,91 m)
L_GTIEFE         = TURM_GEWAENDE_TIEFE;                   // Gewände UND Pfosten um dieses Maß zurückgesetzt
L_WD             = 2 * L_OEFF + L_POST;                   // Durchbruch über beide Öffnungen und den Pfosten
L_WG             = L_WD + 2 * L_GEW;                      // mit Gewände
z_lat_lo = tw_z(TURM_K_L0);                               // Unterkante der Öffnungen (Oberkante roter Sohlreihe)
z_lat_hi = tw_z(TURM_K_HOLZ);                             // Oberkante der Öffnungen = Unterkante Holzbalken

function tw_z(k)   = z_y0 + k * Z_PZ;
function stz_n(w)  = ceil((w + 2 * (Z_H + Z_FUGE) + Z_FUGE) / (Z_H + Z_FUGE));   // Anzahl hochkant stehender Ziegel im Sturz (je Seite mind. ein Ziegel Überstand)
function stz_w(w)  = stz_n(w) * (Z_H + Z_FUGE) - Z_FUGE;                          // Breite des Sturzes
tw_Hh   = TURM_FENSTER_ZEILEN * Z_PZ - Z_FUGE;                                    // lichte Höhe der Fenster
tw_c    = (TURM_FENSTER_PAAR_WI + TURM_FENSTER_ABSTAND) / 2;                      // Paarfenster: Mitte seitlich von Turmmitte
tw_edge = tw_c + stz_w(TURM_FENSTER_PAAR_WI) / 2;                                 // äußere Sturzkante des Paares (seitlich von Turmmitte)
// Streifenknick m (0 = unterer Streifen): äußere Kante der senkrechten Stufe; der untere Streifen knickt weiter außen
function tw_ub(m)  = tw_edge + Z_FUGE + (len(TURM_STREIFEN_IDX) - 1 - m) * Z_PX + Z_H;
function tw_ua(m)  = tw_ub(m) - Z_H;
function tw_zk(m)  = tw_z(lauf_n(TRAUFE_SCHEMA, TURM_STREIFEN_IDX[m]));          // Unterkante des Streifens m

// g = Gewändebreite (0 = keins), bank = 1: das Gewände reicht unten nur bis zur Fensterunterkante (rote Sohlbank darunter)
function fenster_paar(k, g = 0, bank = 0) = [[-tw_c, tw_z(k), TURM_FENSTER_PAAR_WI, tw_Hh, g, bank],
                                             [ tw_c, tw_z(k), TURM_FENSTER_PAAR_WI, tw_Hh, g, bank]];
// Eintrag: [u (seitlich von Turmmitte), z Unterkante, lichte Weite, lichte Höhe, Gewändebreite (0 = kein Gewände)]
fenster_oben = fenster_paar(TURM_K_SEITE);                      // Seitenflächen
fenster_voll = concat(fenster_paar(TURM_K_OBEN, TURM_OBEN_GEWAENDE, 1),   // oberes Paar mit Gewände und Sohlbank
    [[0, tw_z(TURM_K_EINZEL), TURM_FENSTER_EINZEL_WI, TURM_EINZEL_ZEILEN * Z_PZ - Z_FUGE, TURM_EINZEL_GEWAENDE, 0]],   // einzelnes schmales Fenster mit Gewände
    fenster_paar(TURM_K_UNTEN));                                  // Fensterpaar unten

// ---------- Längsaufteilung (x) ----------
// ---------- Anbau links vom Pavillon (nach Foto) ----------
// Grundriss: vorderer Teil an der Straße (3 Gitterfenster in der Front, seitliches Fenster in seiner linken Wand) und
// daneben links der kleinere Teil, dessen Front um ANN_TIEFE_VORN zurückspringt (Fenster, Tür mit Ziegeltreppe und
// Geländer). Beide reichen bis zur gleisseitigen Wand des Pavillons. Pultdach, fällt nach links (-x), stößt rechts an
// den Pavillon.
ANBAU               = true;    // Anbau links vom Pavillon: false = entfernt
ANBAU_FENSTER       = true;    // drei Fenster in der Front
ANBAU_SEITENFENSTER = true;    // seitliche Fenster (linke Wand des vorderen Teils, zurückspringende Wand)
ANBAU_TUER          = true;    // Tür mit Ziegeltreppe und Geländer in der zurückspringenden Wand
ANN_STREIFEN        = false;   // rote Streifen des Hauptgebäudes auch am Anbau? (nach Foto: nein)
ANN_BAND            = false;   // braunrotes Sockelband auch am Anbau? (nach Foto: nein; false = gelbes Mauerwerk ab Oberkante Betonsockel)
ANN_BREITE          = 8.97;    // Aufmaß b: Breite (x) des vorderen Teils (3 Fenster) bis zum Pavillon
ANN_LINKS           = 1.82;    // Aufmaß a: Breite (x) des kleineren Teils links daneben (nur die Tür, mittig)
ANN_TIEFE_VORN      = 4.16;    // Aufmaß m: Rücksprung (y) der Front des linken Teils gegenüber der Front des vorderen Teils
x_pav0 = 0;        // linker Pavillon (Walmdach)
x_ann1 = x_pav0 - ANN_BREITE;        // linke Kante des vorderen Teils (= rechte Kante des linken Teils)
x_ann0 = x_ann1 - ANN_LINKS;         // linke Kante des Anbaus (linker Teil)
x_pav1 = 7.80;     // Aufmaß c: Breite Pavillon
// Aufmaß (Stand 20.11.2026), x-Richtung von links: Zwischengebäude d, Türmchen steht TT_UEBER_LW vor der Gleisseiten-Ecke
// von Zwischengebäude und linkem Flügel, dann Türmchen v, Turm t, sichtbares Risalit w, rechter Flügel e2.
x_mb1 = x_pav1 + 7.80;             // Aufmaß d: Breite Zwischengebäude; Ende am linken Flügel
x_lw0 = x_mb1;                     // linkes Ende des linken Flügels (Giebelwand)
TT_UEBER_LW = 1.19;                // Türmchen beginnt so weit links von x_lw0 (Länge x der Maßskizze)
TT_BREITE   = 2.60;                // Aufmaß v: Breite Türmchen
x_tt0  = x_lw0 - TT_UEBER_LW;      // linke Kante des Türmchens
x_tow0 = x_tt0 + TT_BREITE;        // Turm: linke Kante
x_tow1 = x_tow0 + TURM_BREITE;     // Turm: rechte Kante bleibt am Risalit

x_ris1 = x_tow1 + 7.80;   // Aufmaß w: Mittelrisalit (Eingangsrisalit), rechte Kante; sichtbarer Teil rechts vom Turm 7,80 m
RIS_HINTER_TURM = 0.97;   // Aufmaß: das straßenseitige Risalit reicht so weit hinter den Turm (Turm überdeckt links 0,97 m)
x_ris0 = x_tow1 - RIS_HINTER_TURM;   // linke Kante des straßenseitigen Risalits (verdeckt, hinter dem Turm)
x_ris_m = (x_ris0 + x_ris1) / 2;     // Giebelachse des straßenseitigen Risalits (nicht die Mitte des sichtbaren Teils x_tow1 .. x_ris1)
WAND_RECHTS = 5.59;   // Aufmaß e2: Breite des rechten Gebäudeteils (rechts neben dem Mittelrisalit)
x_end  = x_ris1 + WAND_RECHTS;   // rechtes Ende (Giebelwand)
// Linker Flügel: spiegelbildlich zum rechten Flügel (gleiche Breite, Tiefe, Höhen, Dachneigung), Mitte = Eingangsrisalit.
// Er liegt hinter dem Turm; seine Front ist teilweise verdeckt. Keine Fenster (davor steht das Türmchen).
// (x_lw0 und x_mb1 stehen oben in der Aufmaß-Kette)
// (der niedrigere
WAND_MITTE = (x_ris1 + x_end) / 2;  // Mitte der Wand des rechten Gebäudeteils
// Hauptgebäude (linker Flügel + Mittelrisalit + rechter Flügel): Gesamtausdehnung in x
x_hg0 = x_lw0;                       // linkes Ende (Giebelwand des linken Flügels)
x_hg1 = x_end;                       // rechtes Ende (Giebelwand des rechten Flügels)
// Zwischengebäude (links neben dem Hauptgebäude; Variablen x_pav1, x_mb1, y_wing, h_wing, a_wing, o_wing)
x_zw0 = x_pav1;                      // linkes Ende (am Pavillon)
x_zw1 = x_mb1;                       // rechtes Ende (am linken Flügel des Hauptgebäudes)
FENSTER_X = WAND_MITTE;             // Fenster über der Tür: mittig auf der Wand, in einer Achse mit der Tür
TUER_X    = WAND_MITTE;             // Türmitte entlang der Fassade: ebenfalls Wandmitte (Tür und Fenster in einer Achse)

// ---------- Tiefen (y): Vorderkante / Rückseite ----------
y_pav  = [0.0, 11.47];     // Pavillon steht vor
// y_wing (Zwischengebäude) steht weiter unten, nach y_main: Seine Front fluchtet mit der Front des Hauptgebäudes (p = 9,89)
// Aufmaß: y-Richtung. Pavillon-Tiefe n; Zwischengebäude: Front z1, Rückseite y vor der Pavillon-Rückwand;
                          // der Front des Mittelrisalit (Eingangsrisalit)s, in Läufern: 4 Läufer + 3 Stoßfugen = 1,03 m
// Hauptgebäude: Rückseite z hinter der Rückseite des Zwischengebäudes, Tiefe p; Risalit z4 vor dem Flügel
y_wing = [1.88, y_pav[1] - 0.47];   // Aufmaß z1 (Front) und y (Rückseite)
y_main = [y_wing[1] + 0.77 - 9.89, y_wing[1] + 0.77];   // Aufmaß z = 0,77 (Rückseite), p = 9,89 (Tiefe ohne Risalite, vom Maßnehmer bestätigt; Front fluchtet damit mit y_wing[0])
y_ris0 = y_main[0] - 1.24;   // Aufmaß z4: Front des Mittelrisalits
y_hg   = y_main[0];

// Turm: springt vor die Front des Mittelrisalit (Eingangsrisalit)s vor, und zwar TURM_VORSPRUNG_FAKTOR mal so weit, wie das
// Risalit vor dem rechten Flügel vorsteht (y_main[0] - y_ris0 = 1,03 m; Faktor 4/3 = 1,37 m). Grundfläche 5 x 5 m.
TURM_VORSPRUNG        = 1.62;   // Aufmaß u: Vorsprung des Turms vor dem Mittelrisalit (Straßenseite)
TURM_TIEFE            = TURM_BREITE;
y_tow0 = y_ris0 - TURM_VORSPRUNG;
y_tow  = [y_tow0, y_tow0 + TURM_TIEFE];
y_ris  = [y_ris0, (y_main[0] + y_main[1]) / 2];   // Mittelrisalit (Eingangsrisalit) springt vor und reicht bis zum Hauptfirst

// ---------- Gleisseitiger Mittelrisalit (Rückwand des Hauptgebäudes, außen +y) ----------
// Mittig hinter dem straßenseitigen Mittelrisalit, Breite = RIS_HINTEN_FAKTOR dieses Risalits, gleiche Tiefe des Vorsprungs,
// gleiche Traufhöhe, gleiche Dachneigung, Giebel zur Gleisseite. Noch ohne Fenster und Türen.
RIS_HINTEN        = true;
RIS_HINTEN_BREITE = 5.91;   // Aufmaß g: Breite des gleisseitigen Risalits
RIS_HINTEN_TIEFE  = 0.55;   // Aufmaß q: Vorsprung vor der Rückwand
ris_h_w   = RIS_HINTEN_BREITE;
ris_h_x0  = x_ris_m - ris_h_w / 2;                   // gleiche Mitte wie das straßenseitige Risalit: Firste fluchten
ris_h_x1  = ris_h_x0 + ris_h_w;
y_rh      = [(y_main[0] + y_main[1]) / 2, y_main[1] + RIS_HINTEN_TIEFE];   // von der Mitte des Hauptdachs bis zur Giebelfront
y_ann  = [1.21, y_pav[1]]; // Aufmaß z2 = 1,21 (Front, Straßenseite) bis Rückseite, bündig mit der gleisseitigen Wand des Pavillons; Tiefe k = 10,26
y_anns = y_ann[0] + ANN_TIEFE_VORN;   // Front des zurückspringenden linken Teils

// ---------- Höhen (z) ----------
ANN_TRAUFE_REIHEN = 34;   // Traufkante des Anbaus: Oberkante der letzten Ziegelreihe, gezählt ab Beginn des gelben Mauerwerks.
                          // Nach Foto: Die Unterkante des braunen Dachkastens (tiefste Kante, ca. 0,27 m unter dem Wandkopf) liegt 5 Reihen über dem
                          // zweiten roten Streifen des Pavillons (Reihe 24, Oberkante bei 25 Reihen) = 30 Reihen -> Wandkopf bei 30 + 3,6 = 34 Reihen
h_ann   = z_y0 + ANN_TRAUFE_REIHEN * Z_PZ - Z_FUGE;   // Anbau: Wandkopf = Traufkante, umlaufend waagerecht (auf dem Ziegelraster)
a_ann   = 0;       // Anbau: Dachneigung (0 = flach, Traufkante überall gleich hoch; > 0 neigt das Dach nach links und die Traufe schräg)
o_ann   = 0.5;     // Anbau: Dachüberstand
// Dach des Anbaus (nach Skizze): einseitiges Walmdach über dem hinteren Bereich (Gleisseite). Der First läuft parallel zur Gleisachse (x)
// von der Walmspitze links bis zum Pavillon, nur das linke Ende ist abgewalmt. Die Längsfläche zur Straße fällt bis zur Traufhöhe des
// Türanbaus (linker, zurückspringender Teil); davor, über dem vorderen Teil, schließt sich ein leicht zur Vorderkante abfallendes
// Flachdach an.
ANN_DACH_NEIGUNG   = 10;     // Neigung der geneigten Flächen (rückwärtige Längsfläche und Walm links) [Grad]
ANN_FIRST_ANTEIL   = 0.5;    // Lage des Firsts in der Tiefe des hinteren Teils, von der Rückwand aus gesehen (0,5 = Mitte)
ANN_FLACH_ABFALL   = 0.10;   // Flachdach: Höhenunterschied der Oberseite zwischen Anschluss an die Längsfläche und Vorderkante [m real]
ANN_FLACH_RAND     = 0.08;   // Flachdach: Dicke an der Vorderkante. Die Unterseite des Flachdachs ist waagerecht und liegt auf dem Wandkopf, nur die Oberseite ist geneigt
ANN_TRAUFE_ABSENK  = 0.0;    // Traufkante (Dachüberstand) der Rückseite liegt so weit unter dem Wandkopf
function ann_z(x) = h_ann + (x - x_ann0) * tan(a_ann);   // Dachebene des Anbaus
h_ann_h = ann_z(x_ann1);   // Wandkopf des vorderen Teils (Dachebene an dessen linker Kante)
h_traufe = z_traufe - Z_FUGE;   // Traufhöhe laut TRAUFE_SCHEMA (Oberkante letzter Ziegel)

// ---------- Zwischengebäude: zwei Fenster, eigenes Traufschema (links neben dem Hauptgebäude) ----------
// Sockelbereich (Betonsockel + braunrotes Band) wie beim Hauptgebäude. Seine Oberkante ist die Unterkante
// jedes Fensters. Die Fenster enden auf der Höhe der Türen des Mittelrisalits (Scheitel des Bogenfrieses).
// Das Gewände springt zurück (Stufengewände wie sonst) und setzt sich im roten Sockelband um
// ZW_SOCKEL_REIHEN Reihen nach unten fort. Über den Fenstern folgen ZW_GELB_UEBER_FENSTER gelbe Reihen,
// danach der Zahnfries wie im Hauptgebäude (rot, Zahnfries, rot, gelbe Schlussreihe).
ZW_FENSTER             = true;
ZW_FENSTER_WI          = TUER_BREITE;     // lichte Weite der Fenster (wie die Türen: 1,40 m)
ZW_BOGEN_BREITE        = BOGEN_BREITE;    // Bogenfries wie bei den Türen (ein Läufer radial)
ZW_BOGEN_SCHMAL        = TUER_BOGEN_SCHMAL;
ZW_SOCKEL_REIHEN       = 11;              // Rücksprung des Gewändes im roten Sockelband, in Ziegelreihen
ZW_GELB_UEBER_FENSTER  = 10;              // gelbe Reihen zwischen Fensterscheitel und Zahnfries
ZW_GELB_OBEN           = 1;               // gelbe Schlussreihe über dem Zahnfries (wie im Hauptgebäude)
ZW_STREIFEN_UNTEN      = true;            // die ersten roten Streifen des Hauptgebäudes laufen auch hier durch
ZW_QUERSPROSSEN        = 1;               // waagerechte Sprossen im geraden Teil des Fensters (nur Giebel-/OG-Fenster)
// ---------- Fenster im Erdgeschoss (Pavillon, Zwischengebäude, Gleisseite der Flügel): Aufbau nach Foto ----------
// Zwei Flügel mit Mittelpfosten, 3 x 2 = 6 Teilscheiben unter dem Kämpfer, darüber der Bogen mit einer dünnen
// senkrechten Sprosse, die unten in einen offenen Halbkreis (Ring) ausläuft. Unter dem Fenster eine Fensterbank aus
// Ziegelrollschicht (schmale Seite nach vorn).
EG_QUERSPROSSEN        = 2;               // waagerechte Sprossen unter dem Kämpfer: 2 -> 3 Reihen x 2 Flügel = 6 Scheiben
EG_KAEMPFER            = 0.12;            // Höhe des Kämpfers (waagerechte Sprosse unter dem Bogen) [m real]
EG_KAEMPFER_AUFL       = 0.015;           // Höhe der dünnen Aufleisten oben und unten am Kämpfer (U-Profil)
EG_AUFL_V              = 0.015;           // Aufleisten stehen so weit vor dem Rahmen [m real]
EG_PFOSTEN_B           = 0.12;            // Breite des Mittelpfostens (beide Flügelrahmen zusammen)
EG_PFOSTEN_AUFL_B      = 0.04;            // Breite der Aufleiste auf dem Mittelpfosten
EG_SPROSSE_B           = 0.03;            // dünne senkrechte Sprosse im Bogen
EG_BOGEN_R             = 0.13;            // Außenradius des Halbkreises am Fuß der Bogensprosse [m real]
EG_BOGEN_RING          = 0.03;            // Stegbreite des Halbkreises (innen offen)
EG_BOGEN_HEBUNG        = 0.02;            // Halbkreis sitzt so weit über dem Kämpfer (Stege reichen bis zum Kämpfer)
OG_QUERSPROSSEN        = 1;               // Bogenfenster im Obergeschoss/Giebel: 1 waagerechte Sprosse -> 2 Reihen x 2 Flügel = 4 Scheiben
OG_BANK                = true;            // Fensterbank (flache Köpfe nebeneinander) auch bei den Bogenfenstern im Obergeschoss
EG_BANK                = true;            // Fensterbank als Rollschicht
EG_BANK_HOEHE          = Z_H;             // eine Schicht flach liegender Ziegel, 6,5 cm hoch
EG_BANK_STEIN_B        = Z_B;             // sichtbare Breite eines Steins (schmale Seite = Kopf nach vorn): 12 cm
EG_BANK_VORSPRUNG      = 0.05;            // Vorderkante der Bank vor der Wandfläche [m real]
ZW_IDX                 = 2;               // Index des Zwischengebäudes in bloecke_liste
zw_top = zs + PODEST_SCHICHTEN * Z_PZ - Z_FUGE + TUER_FLUEGELHOEHE + TUER_KAEMPFER + TUER_OBERLICHT_GERADE
         + TUER_BREITE / 2 + GEWAENDE_STUFE + BOGEN_BREITE;      // Scheitel des Bogenfrieses der Risalittüren
zw_zsp = zw_top - ZW_BOGEN_BREITE - GEWAENDE_STUFE - ZW_FENSTER_WI / 2;   // Bogenansatz der Fenster
zw_zb  = z_y0;                                // Unterkante der Fenster = Oberkante des Sockelbereichs
zw_zbn = z_y0 - ZW_SOCKEL_REIHEN * Z_PZ;      // Unterkante der zurückspringenden Nische im roten Sockelband
zw_k_oben = ceil((zw_top - z_y0) / Z_PZ - 0.001);   // erste Reihe über dem Fensterscheitel
zw_k_ende = zw_k_oben + ZW_GELB_UEBER_FENSTER;      // hier beginnt der Zahnfries (rote Reihe)
zw_unten  = ZW_STREIFEN_UNTEN ? [for (i = [0 : 3]) TRAUFE_SCHEMA[i]] : [["g", lauf_n(TRAUFE_SCHEMA, 4)]];
ZW_SCHEMA = concat(zw_unten,
                   [["g", zw_k_ende - lauf_n(zw_unten, len(zw_unten))]],
                   [["r", 1], ["z", 1], ["r", 1], ["g", ZW_GELB_OBEN]]);
h_zw      = z_y0 + lauf_n(ZW_SCHEMA, len(ZW_SCHEMA)) * Z_PZ - Z_FUGE;   // Traufhöhe des Zwischengebäudes
// Traufhöhe der Baukörper: true = aus dem Schema, false = geschätzter Wert
SCHEMA_PAV  = true;   h_pav_alt  = 8.5;
SCHEMA_RIS  = true;   h_ris_alt  = 10.6;
SCHEMA_MAIN = true;   h_main_alt = 10.5;
// ---------- Pavillon: drei Fenster wie im Zwischengebäude, darüber 10 gelbe Reihen, dann der Bogenfries ----------
// Fenster: gleiche Maße wie im Zwischengebäude (Sohle = Oberkante Sockelbereich, Nische im roten Sockelband,
// Scheitel des Bogenfrieses = Oberkante der Risalittüren). Darüber PAV_GELB_UEBER_FENSTER gelbe Reihen, dann der
// bogenförmige Zierfries (Rundbogenfries auf gestuften Konsolen) über ZF_ZEILEN Reihen Höhe, darüber das Dach.
PAV_FENSTER            = true;
PAV_RUECK_FENSTER      = true;             // Gleisseite (Rückwand, außen +y): Fensterachsen wie an der Straßenseite
PAV_RUECK_TUER         = true;             // ... aber die mittlere Öffnung ist eine Tür statt eines Fensters
PAV_RUECK_STUFE        = true;             // Betonstufe vor der Tür (Schwelle liegt knapp über dem Bahnsteig)
PAV_ZIERFRIES          = true;             // Bogenfries: umlaufend, also auch auf der Gleisseite
PAV_IDX                = 1;                // Index des Pavillons in bloecke_liste
PAV_GELB_UEBER_FENSTER = 10;               // gelbe Reihen zwischen Fensterscheitel und Zierfries
ZF_ZEILEN              = 10;               // Höhe des Zierfrieses in Ziegelreihen
ZF_KONSOLEN_ZEILEN     = 3;                // Konsole: gestufte Reihen unter dem Bogenansatz
ZF_KONSOLE_B           = 0.30;             // Breite der obersten Konsolenreihe [m real]
ZF_RING                = Z_B;              // Bogenring: eine Rollschicht (12 cm radial)
ZF_VORSPRUNG           = 0.06;             // Konsolen und Bogenring stehen so weit vor der Wand [m real]
PAV_FENSTER_ABSTAND = TUER_BREITE + 2 * GEWAENDE_STUFE + RIS_PFEILER;   // Fenstermitte zu Fenstermitte wie die Türen im Eingangsrisalit (1,92 m)
pav_xm   = (x_pav0 + x_pav1) / 2;
pav_fx   = [pav_xm - PAV_FENSTER_ABSTAND, pav_xm, pav_xm + PAV_FENSTER_ABSTAND];   // drei Fenster, symmetrisch zur Mitte der Front
ZF_BOEGEN = 7;                             // Anzahl der Bögen des Zierfrieses auf Front und Rückseite
ZF_RASTER = (x_pav1 - x_pav0) / ZF_BOEGEN; // Breite eines Bogenfeldes (Konsole zu Konsole); die Seitenwände bekommen gleich große Bögen (ganzzahlig gerundet)
zf_k0    = zw_k_oben + PAV_GELB_UEBER_FENSTER;     // erste Reihe des Zierfrieses (Bogenfries)
zf_z0    = z_y0 + zf_k0 * Z_PZ;                    // Unterkante des Zierfrieses
zf_H     = ZF_ZEILEN * Z_PZ - Z_FUGE;              // Höhe des Zierfrieses

// Aufschaltung der 9 Schichten über dem Bogenfries (1 gelb, 1 rot, 3 rot-Zahnfries, 1 rot, 3 gelb)
k_pav_g1   = zf_k0 + ZF_ZEILEN;                    // 1. gelbe Reihe über Bogenfries
k_pav_r1   = k_pav_g1 + 1;                         // 1. rote Reihe über Bogenfries
k_pav_z    = k_pav_r1 + 1;                         // Start roter Zahnfries (3 Schichten)
k_pav_r2   = k_pav_z + ZAHN_SCHICHTEN;             // 2. rote Reihe über Zahnfries
k_pav_g2   = k_pav_r2 + 1;                         // Start der 3 gelben Reihen
k_pav_top  = k_pav_g2 + 3;                         // Oberkante des Mauerwerks (Traufe)

h_pav_zf   = z_y0 + k_pav_top * Z_PZ - Z_FUGE;     // Traufe = Oberkante der 3 gelben Ziegelreihen
// Walmdach des Pavillons (nach Maßskizze, gestrichelte Dachlinien): der First läuft 90° zur Gleisachse, also in y-Richtung
// (von der Straße zur Gleisseite), und ist nur PAV_FIRST_LAENGE lang. Nur das Dach ist gedreht, der Pavillon-Baukörper bleibt.
// Die beiden langen Dachflächen links und rechts (zum Anbau bzw. Zwischengebäude hin) haben die Neigung a_pav, die Walmflächen
// an Front und Rückseite ergeben sich aus der Firstlänge (a_pav_e). Das Dach sitzt so hoch, dass der Zierfries (steht ZF_VORSPRUNG vor der Wand) unter der Dachhaut endet.
a_pav  = 25;  o_pav  = 1.05;
PAV_FIRST_LAENGE = 4.5;                             // Länge des Firstes [m real], nach dem roten Strich im Luftbild geschätzt
pav_hh   = (x_pav1 - x_pav0) / 2 * tan(a_pav);  // Firsthöhe über der Traufe (Spannweite in x, First läuft in y)
a_pav_e  = atan(pav_hh / ((y_pav[1] - y_pav[0] - PAV_FIRST_LAENGE) / 2));   // Neigung der Walmflächen an Front und Rückseite
pav_dach_hoch = td + ZF_VORSPRUNG * tan(max(a_pav, a_pav_e)) + 0.005;  // Dachfuß über Oberkante Zierfries
// h_pav und h_wing (Dachfuß von Pavillon und Zwischengebäude) stehen weiter unten, nach DACHKASTEN, DK_G und a_wing
h_ris   = SCHEMA_RIS  ? h_traufe : h_ris_alt;     // Risalit Traufe (Giebelfuß)
h_main  = SCHEMA_MAIN ? h_traufe : h_main_alt;    // rechter Bau Traufe
// Grüner Dachkasten des Hauptgebäudes (Flügel und Risalite): eine Platte, die sich flach unter die Dachhaut legt, parallel zur
// Dachneigung, von der Wand bis kurz vor die Dachkante (an den Traufen wie an den Giebelschrägen, ähnlich wie beim Turmdach).
// Die Platte sitzt direkt auf dem Zahnfries; die Dachhaut beginnt deshalb nur DK_H über der Mauerwerk-Oberkante (ze_*).
// Es gibt kein senkrechtes Band mehr an der Wand und keinen waagerechten Kasten quer vor den Giebeln.
DACHKASTEN    = true;
DK_G          = 0.15;     // Dicke der Platte unter der Dachhaut (senkrecht zur Dachfläche gemessen)
DK_G_UE       = 0.04;     // Platte endet so weit vor der Dachkante (Traufe und Giebel)
DK_EIN        = 0.04;     // Traufplatte bindet so weit in die Wand ein (verdeckt)
a_ris  = 28.6;   // Dachneigung Giebel Risalit (steht hier, weil DK_H sie braucht: Zuweisungen werden der Reihe nach ausgewertet)
a_main = 26;     // Dachneigung Hauptdach
DK_H          = td + DK_G / cos(max(a_main, a_ris));   // Anhebung der Dächer = Dachhaut + Plattendicke, gemessen senkrecht über der Traufe [m]
ze_main = h_main + (DACHKASTEN ? DK_H : 0);   // Dachfuß (Oberkante Dachhaut an der Wand) der Flügel
ze_ris  = h_ris  + (DACHKASTEN ? DK_H : 0);   // Dachfuß der Risalite
h_shaft = z_lat_hi + TURM_HOLZ_ZEILEN * Z_PZ;    // Oberkante Holzbalken
TURM_DACH_HUB = 0.30;             // Turmdach um dieses Maß nach oben gerückt: der grüne Holzbalken (Dachkasten) wird entsprechend höher [m]
z_lant1 = h_shaft + td + 0.03 + TURM_DACH_HUB;    // Dachfuß Turm: Unterkante der Dachhaut liegt knapp über dem Holzbalken, damit der Balken sichtbar bleibt

// ---------- Dachneigungen / Überstände ----------
// a_pav, o_pav (Walmdach Pavillon): siehe Pavillon-Block oben
a_wing = 22;  o_wing = 0.6;    // Satteldach Zwischengebäude (Traufe parallel x)
// Dachfuß (Oberkante Dachhaut an der Wand) von Pavillon und Zwischengebäude. Mit Dachkasten liegt er wie am Hauptgebäude um die
// Plattendicke höher: Die grüne Platte hängt unter der Dachhaut direkt auf dem Zierfries bzw. Zahnfries (Unterkante der Platte an der
// Wand = Oberkante Fries), so dass sie ihn nicht verdeckt.
DKP_PAV = DACHKASTEN ? DK_G / cos(max(a_pav, a_pav_e)) : 0;      // senkrechte Plattenhöhe an der Pavillonwand
DKP_ZW  = DACHKASTEN ? DK_G / cos(a_wing) : 0;                   // dito Zwischengebäude
h_pav   = h_pav_zf + pav_dach_hoch + DKP_PAV;       // Pavillon Traufe (Dachfuß)
h_wing  = h_zw + (DACHKASTEN ? td : 0) + DKP_ZW;    // Zwischengebäude Traufe (Dachfuß; Fries h_zw, eigenes Traufschema ZW_SCHEMA)
o_ris = 0.9;          // Giebel Risalit (Ortgang-Überstand)
a_ris_h = a_ris;               // gleisseitiger Risalit: Dachneigung des Giebels (muss nach a_ris stehen: OpenSCAD wertet Zuweisungen der Reihe nach aus)
o_main = 0.8;
o_ris_t = o_main * tan(a_main) / tan(a_ris);   // Traufüberstand der Risalit-Seiten: ihre Traufkante liegt genau so hoch wie die der Flügel (saubere Ecke, die Kehle läuft von der Wandecke zum Rinnenwinkel)
    // Hauptdach rechts
o_main_end = 0.85;             // Überstand an rechter Giebelseite
o_wing_end = o_main_end;       // Ortgang-Überstand am linken Giebel des Zwischengebäudes (zum Pavillon hin), wie am Hauptgebäude
a_tow  = 27.5; o_tow = 0.5;    // Turm-Zeltdach

// ---------- Zwischengebäude: First weiter nach links auf das Walmdach des Pavillons gezogen ----------
// Der First des Zwischengebäudes liegt höher als die Traufe des Pavillons und endete bisher frei in der Luft
// (Lücke zum Pavillondach). Jetzt läuft er nach links, bis er das Walmdach des Pavillons trifft, und dringt noch
// ZW_FIRST_EINDRINGEN [m] weit in dessen Dachfläche ein (keine Lücke). Der verlängerte Teil wird in y auf die Grundfläche
// des Pavillons beschnitten, damit der Dachüberstand nicht an der Pavillon-Rückwand herausragt.
ZW_FIRST_VERLAENGERN = true;
ZW_FIRST_EINDRINGEN  = 0.30;   // so weit [m] reicht der First über den Treffpunkt hinaus ins Pavillondach
ZW_CLIP_HINTEN       = 0.05;   // Abstand der Beschneidung zur Rückwand des Pavillons [m]
zw_zr  = h_wing + (y_wing[1] - y_wing[0]) / 2 * tan(a_wing);   // Firsthöhe des Zwischengebäudes
// Entfernung (nach links ab der Pavillon-Ostwand x_pav1), in der die Pavillon-Dachfläche (Neigung a_pav ab Traufe h_pav) die Firsthöhe erreicht
zw_ext = ZW_FIRST_VERLAENGERN
       ? min((x_pav1 - x_pav0) / 2, max(o_wing_end, (zw_zr - h_pav) / tan(a_pav) + ZW_FIRST_EINDRINGEN))
       : o_wing_end;

// ---------- Schornsteine auf dem rechten Flügel (nach Foto) ----------
// Beide stehen auf der VORDEREN (straßenseitigen) Dachfläche des rechten Flügels, nicht auf der Firstlinie
// (First parallel zur x-Achse).
//   rechter Schornstein: eher rechteckig, lange Seite PARALLEL zum First, nahe der rechten Giebelwand
//   linker Schornstein:  schmaler, lange Seite SENKRECHT zum First (in y), nahe dem Mittelrisalit
// Maße in echten Metern, Lage = Schornsteinmitte. Lage und Querschnitt sind nach dem Foto geschätzt.
SCHORNSTEIN        = true;
SCH_R_X            = x_end - 1.10;   // rechter Schornstein: Mitte, gemessen von der rechten Giebelwand
SCH_R_BX           = 1.40;           //   Ausdehnung in x (parallel zum First)
SCH_R_BY           = 0.85;           //   Ausdehnung in y (quer zum First)
SCH_R_H            = 2.00;           //   Höhe über der Dachfläche (an der Schornsteinmitte)
SCH_L_X            = x_ris1 + 1.40;  // linker Schornstein: Mitte, gemessen vom rechten Rand des Mittelrisalits
SCH_L_BX           = 0.60;           //   Ausdehnung in x (schmal)
SCH_L_BY           = 1.05;           //   Ausdehnung in y (senkrecht zum First)
SCH_L_H            = 1.60;           //   Höhe über der Dachfläche (an der Schornsteinmitte)
SCH_R_ABSTAND_FIRST = 1.70;          // rechter Schornstein: Abstand der Mitte vom First, waagerecht in Richtung Straße (-y) [m]
SCH_L_ABSTAND_FIRST = 3.30;          // linker Schornstein: weiter unten auf der Dachfläche, näher an der Traufe [m]
// dritter Schornstein auf dem linken Flügel, links neben dem Turm: gleicher schmaler Querschnitt wie der linke Schornstein
// (SCH_L_BX x SCH_L_BY, senkrecht zum First), ebenfalls unterhalb der Firstlinie auf der Straßenseite
SCHORNSTEIN_LW      = true;
SCH_LW_X            = x_tow0 - 0.90;   // Mitte: 0,90 m links der linken Turmkante (das Dach links vom Turm ist nur 1,41 m breit)
SCH_LW_ABSTAND_FIRST = 1.70;           // Abstand der Mitte vom First, waagerecht in Richtung Straße [m]
// zwei Schornsteine auf dem Pavillon (Dachfläche zur Anbau-Seite), siehe schornsteine_pavillon()
SCHORNSTEIN_PAV     = true;
SCH_P_BOGEN_WAND    = 2;      // linker Schornstein (an der Wand): über dem so vielten Bogen des Zierfrieses, von links gezählt
SCH_P_WAND_VOR      = 0.45;   //   Tiefe senkrecht zur Wand: der Schornstein steht komplett VOR der Wand (außerhalb des Gebäudes) [m]
SCH_P_WAND_EIN      = 0.02;   //   Einbindung in die Wand, nur damit kein Spalt bleibt [m]
SCH_P_WAND_BY       = 0.80;   //   Länge der Längsseite, die an der Wand anliegt [m]
SCH_P_UEBERGANG     = 0.10;   //   gelbes Mauerwerk endet so weit [m] über der Dachfläche an der Wand, darüber ziegelrot
SCH_P_HOEHE         = 1.70;   //   Oberkante des Wand-Schornsteins über der Traufe des Pavillons [m]
SCH_P_BOGEN_FREI    = 6.5;    // rechter Schornstein (freistehend): y-Lage zwischen dem 6. und 7. Bogen von links (6.5 = auf der Grenze)
SCH_P_FREI_X        = 1.20;   //   Mitte, Abstand von der Wand x_pav0 nach innen [m]
SCH_P_FREI_BX       = 0.60;   //   Ausdehnung in x
SCH_P_FREI_BY       = 0.70;   //   Ausdehnung in y
SCH_P_FREI_H        = 2.20;   //   Höhe über der Dachfläche an der Schornsteinmitte (höher als der Wand-Schornstein) [m]
SCH_FUSS           = 0.50;           // so weit [m] reicht der Schornstein unter die tiefste Stelle der Dachfläche (verdeckt im Dach)
SCH_KOPF_ZEILEN    = 2;              // Kopf: rote Schichten unter der Abdeckplatte
SCH_KOPF_VOR       = 0.04;           // Kopf springt so weit [m] vor dem Schaft vor
SCH_PLATTE_H       = 0.10;           // Abdeckplatte: Stärke
SCH_PLATTE_VOR     = 0.09;           // Abdeckplatte: Überstand über den Kopf
SCH_MUENDUNG_RAND  = 0.17;           // Rauchrohr-Mündung: Abstand zum Plattenrand
SCH_MUENDUNG_TIEFE = 0.07;           // Mündung: Tiefe der Vertiefung in der Platte
function sch_y(ab) = (y_main[0] + y_main[1]) / 2 - ab;          // Mitte in y bei Abstand ab vom First (Straßenseite)
function sch_dach(y) = ze_main + (y - y_main[0]) * tan(a_main);  // Höhe der vorderen Dachfläche (Oberkante Dachhaut) bei y

// ---------- Türmchen vor dem linken Flügel ----------
// Steht zwischen der linken Giebelwand des linken Flügels (x_lw0) und der linken Turmkante (x_tow0),
// vor der Front des linken Flügels. Die Front ist gegenüber der Turmfront um TT_RUECKSPRUNG_LAEUFER
// Läufer zurückgesetzt. An der linken Seite (-x): Fenster oben, Tür darunter, Podest, Treppe, Geländer
// (gleiche Maße und Module wie Tür und Fenster im rechten Flügel).
TUERMCHEN              = true;
TT_TUER                = true;    // Tür mit Podest, Treppe und Geländer an der linken Seite
TT_FENSTER             = true;    // Fenster über der Tür
TT_RUECKSPRUNG = 0.13;            // Aufmaß z3: Front gegenüber der Turmfront zurückgesetzt [m]
TT_UEBERLAPP   = 0.21;            // Türmchen reicht so weit hinter die Front des linken Flügels (steckt in der 0,35 m dicken Wand, unsichtbar)
// Aufmaß s = Vorsprung des Türmchens vor dem linken Flügel = z4 + u - z3 = 1,24 + 1,62 - 0,13 = 2,73 m. Er ergibt sich aus der Kette
// Flügelfront -> Risalit -> Turm -> Türmchen und ändert sich deshalb NICHT, wenn p (und damit y_main[0]) geändert wird.
// Die Modelltiefe (2,73 + Überlappung = 2,94) wird deshalb aus der Kette berechnet:
TT_TIEFE       = (y_main[0] - (y_tow0 + TT_RUECKSPRUNG)) + TT_UEBERLAPP;   // Tiefe des Türmchens [m]
TT_IDX      = 7;                  // Index des Türmchens in bloecke_liste
ANN_IDX     = [0, TUERMCHEN ? 8 : 7];   // Indizes der beiden Anbau-Teile in bloecke_liste (vorn, hinten)
TT_TUER_WI  = 0.90;               // lichte Weite der Tür (gerade Tür mit Sturz, nach Foto)
tt_dach_hub = 0.20;               // flaches Pultdach: steigt zum Turm hin um dieses Maß [m]
o_tt   = 0.20;                    // Dachüberstand links und vorn (klein, damit er nicht vor die Turmfront ragt)
tt_k_streifen = lauf_n(TRAUFE_SCHEMA, 4);   // Reihe 25: am Türmchen gibt es nur die unteren zwei roten Streifen
// (x_tt0 steht oben in der Aufmaß-Kette)
x_tt1  = x_tow0;                                           // rechts am Turm
y_tt0  = y_tow0 + TT_RUECKSPRUNG;                          // Front: z3 hinter der Turmfront
y_tt1  = y_tt0 + TT_TIEFE;                                  // Rückseite: s hinter der Front (reicht minimal in den linken Flügel)
h_tt   = sturz_z0(fenster_voll[2]) + TURM_STURZ_ZEILEN * Z_PZ - Z_FUGE;   // Traufe = Oberkante des Sturzes des einzelnen Turmfensters
tt_yc  = (y_tt0 + y_tt1) / 2;                              // Mitte der linken Seitenwand
tt_B   = y_tt1 - y_tt0;                                    // Breite der linken Seitenwand
tt_podest_hw = min(tt_B / 2, TT_TUER_WI / 2 + PODEST_UEBERSTAND);   // Podest und Treppe seitlich über die Tür hinaus


// ============================================================
// Hilfsmodule
// ============================================================
module box(x0, x1, y0, y1, h) {
    translate([x0, y0, 0]) cube([x1 - x0, y1 - y0, h]);
}

// Innenraum eines Blocks (nach unten offen, 4-mm-Decke)
module hohl(x0, x1, y0, y1, h) {
    translate([x0 + t, y0 + t, -1])
        cube([x1 - x0 - 2*t, y1 - y0 - 2*t, h - t + 1]);
}

// Durchgang zwischen zwei aneinanderstoßenden Blöcken (Wand bei x)
module bruecke(x, y0, y1, h) {
    translate([x - t - eps, y0 + t, -1])
        cube([2*t + 2*eps, y1 - y0 - 2*t, h - t + 1]);
}

// Durchgang zwischen zwei hintereinanderliegenden Blöcken (Wand bei y)
module bruecke_y(y, x0, x1, h) {
    translate([x0 + t, y - t - eps, -1])
        cube([x1 - x0 - 2*t, 2*t + 2*eps, h - t + 1]);
}

// Querschnitt einer Dachfläche mit Überstand: oben die Dachlinie von der Traufkante (y0, zb) über den First
// (yc, zr) zur anderen Traufkante (y1, zb). An den Traufkanten endet die Haut RECHTWINKLIG zur Dachfläche
// (Stirnfläche senkrecht, so lang wie die Hautstärke), nicht in einer Spitze. Die Haut ist die obere Schicht
// dieses Körpers, td dick (senkrecht gemessen td * cos(a)); sie entsteht als Körper minus um td abgesenkter Körper.
function roof_prof(y0, y1, yc, zb, zr, a) =
    let(dpp = td * cos(a), sx = dpp * sin(a), sz = dpp * cos(a))
    [[y0, zb], [yc, zr], [y1, zb], [y1 - sx, zb - sz], [y0 + sx, zb - sz]];

// Walm-/Zeltdach: Kern über dem Mauerwerk + dünne Dachhaut mit Überstand
module hip(x0, x1, y0, y1, ze, a, o, teil = "beide") {
    W  = min(x1 - x0, y1 - y0);
    zr = ze + W/2 * tan(a);
    dz = o * tan(a);
    rx0 = x0 + W/2;  rx1 = x1 - W/2;
    ry0 = y0 + W/2;  ry1 = y1 - W/2;

    module first() {   // Dachfirst (Strecke oder Punkt)
        translate([rx0, ry0, zr - eps])
            cube([max(rx1 - rx0, eps), max(ry1 - ry0, eps), eps]);
    }
    sx = td * cos(a) * sin(a);  sz = td * cos(a) * cos(a);       // Versatz der Unterkante der Stirnfläche (senkrecht zur Dachfläche)
    module aussen() {
        hull() {
            translate([x0 - o, y0 - o, ze - dz])
                cube([x1 - x0 + 2*o, y1 - y0 + 2*o, eps]);
            translate([x0 - o + sx, y0 - o + sx, ze - dz - sz])
                cube([x1 - x0 + 2*o - 2*sx, y1 - y0 + 2*o - 2*sx, eps]);
            first();
        }
    }
    // Kern (füllt das Dach über den Wänden); liegt eine halbe Dachhaut unter der
    // Dachfläche, damit er unter der Dachhaut verschwindet. Gehört zum Mauerwerk.
    if (teil != "haut")
        translate([0, 0, -td/2]) hull() {
            translate([x0, y0, ze - eps]) cube([x1 - x0, y1 - y0, eps]);
            first();
        }
    // Dachhaut mit Überstand
    if (teil != "kern")
        difference() {
            aussen();
            translate([0, 0, -td]) aussen();
        }
}

// Walmdach mit First parallel zur x-Achse (Fassade). Front/Rückseite: Neigung a. Die Walmflächen an den Stirnseiten sind
// steiler (Neigung ae), sodass der First genau die Länge fl hat. Gebaut als Schnitt zweier Dreiecksprismen (wie die Satteldächer).
module walm_x(x0, x1, y0, y1, ze, a, o, fl, teil = "beide", o1 = -1) {   // o1: Überstand rechts (x1), -1 = wie o
    xc = (x0 + x1) / 2;  yc = (y0 + y1) / 2;
    orr = o1 < 0 ? o : o1;                                   // Überstand an der rechten Stirnseite
    zr  = ze + (y1 - y0) / 2 * tan(a);                       // Firsthöhe
    ae  = atan((zr - ze) / ((x1 - x0 - fl) / 2));            // Neigung der Walmflächen
    zre = ze + (x1 - x0) / 2 * tan(ae);                      // Spitze des Stirn-Prismas (wird vom Front-Prisma gekappt)
    // Die Stirnflächen sind steiler als Front/Rückseite: bei gleichem Überstand läge ihre Traufe tiefer und die
    // Traufkante knickte an den Ecken. Linker Überstand daher so, dass die Traufe überall auf derselben Höhe liegt.
    oL  = o * tan(a) / tan(ae);
    module voll() {
        intersection() {
            translate([x0 - oL, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0 + oL + orr)
                polygon(roof_prof(y0 - o, y1 + o, yc, ze - o * tan(a), zr, a));
            translate([0, y1 + o, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0 + 2*o)
                polygon(let(sx = td * cos(ae) * sin(ae), sz = td * cos(ae) * cos(ae),
                            zl = ze - oL * tan(ae), zrr = ze - orr * tan(ae))
                        // Unterkante WAAGERECHT (auf Höhe der linken Traufe): eine schräge Unterkante (links tief, rechts hoch)
                        // schnitt den vorderen Dachüberstand diagonal ab, sodass die vordere Dachkante nach rechts anstieg.
                        [[x0 - oL, zl], [xc, zre], [x1 + orr, zrr],
                         [x1 + orr, zl - sz], [x0 - oL + sx, zl - sz]]);
        }
    }
    if (teil != "haut")      // Kern (Mauerwerk unter der Dachhaut), eine halbe Dachhaut unter der Dachfläche
        translate([0, 0, -td/2]) intersection() {
            translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0)
                polygon([[y0, ze], [y1, ze], [yc, zr]]);
            translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0)
                polygon([[x0, ze], [x1, ze], [xc, zre]]);
        }
    if (teil != "kern")      // Dachhaut mit Überstand
        difference() { voll(); translate([0, 0, -td]) voll(); }
}

// Walmdach mit First parallel zur y-Achse (90° zur Fassade bzw. zur Gleisachse). Front und Rückseite (y0, y1) sind die Walmflächen.
// Gebaut als walm_x im vertauschten Koordinatensystem (x <-> y): a = Neigung der langen Dachflächen links/rechts (Spannweite x1 - x0),
// fl = Firstlänge in y. o = Überstand an den langen Seiten; o_e = Überstand an Front und Rückseite
// (Standard: so, dass die Traufkante dort auf derselben Höhe liegt wie an den langen Seiten, keine Knicke an den Ecken).
module walm_y(x0, x1, y0, y1, ze, a, o, fl, teil = "beide", o_e = -1) {
    zr = ze + (x1 - x0) / 2 * tan(a);                        // Firsthöhe
    ae = atan((zr - ze) / ((y1 - y0 - fl) / 2));             // Neigung der Walmflächen an Front und Rückseite
    oe = o_e < 0 ? o * tan(a) / tan(ae) : o_e;
    multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]])   // Spiegelung x <-> y
        walm_x(y0, y1, x0, x1, ze, a, o, fl, teil, oe);
}

// Satteldach, First parallel zur x-Achse (Giebelwände links/rechts)
module roof_x(x0, x1, yf, yb, ze, a, o, ol = 0, or = 0, teil = "beide") {
    hs = (yb - yf) / 2;  yc = (yf + yb) / 2;
    zr = ze + hs * tan(a);  dz = o * tan(a);
    module prof() { polygon(roof_prof(yf - o, yb + o, yc, ze - dz, zr, a)); }
    // Kern inkl. Giebeldreieck (Mauerwerk, eine halbe Dachhaut unter der Dachfläche)
    if (teil != "haut")
        translate([x0, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0)
            polygon([[yf, ze - td/2], [yb, ze - td/2], [yc, zr - td/2]]);
    // Dachhaut mit Überständen
    if (teil != "kern")
        translate([x0 - ol, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0 + ol + or)
            difference() { prof(); translate([0, -td]) prof(); }
}

// Satteldach, First parallel zur y-Achse (Giebel zur Straße)
module roof_y(x0, x1, yf, yb, ze, a, o, of = 0, ob = 0, teil = "beide") {
    hs = (x1 - x0) / 2;  xc = (x0 + x1) / 2;
    zr = ze + hs * tan(a);  dz = o * tan(a);
    module prof() { polygon(roof_prof(x0 - o, x1 + o, xc, ze - dz, zr, a)); }
    if (teil != "haut")
        translate([0, yb, 0]) rotate([90, 0, 0]) linear_extrude(yb - yf)
            polygon([[x0, ze - td/2], [x1, ze - td/2], [xc, zr - td/2]]);
    if (teil != "kern")
        translate([0, yb + ob, 0]) rotate([90, 0, 0]) linear_extrude(yb - yf + of + ob)
            difference() { prof(); translate([0, -td]) prof(); }
}


// ============================================================
// Baukörper (außen, massiv – Innenräume werden später abgezogen)
// ============================================================
module baukoerper() {
    if (ANBAU) {                                                            // Anbau links
        box(x_ann0, x_ann1, y_anns,   y_ann[1], h_ann);                      //   linker, zurückspringender Teil
        box(x_ann1, x_pav0, y_ann[0], y_ann[1], h_ann_h);                    //   vorderer Teil (3 Fenster)
    }
    box(x_pav0, x_pav1, y_pav[0],  y_pav[1],  h_pav);          // Pavillon
    box(x_pav1, x_mb1,  y_wing[0], y_wing[1], h_wing);         // Zwischengebäude (endet am linken Flügel)
    box(x_lw0,  x_tow1, y_main[0], y_main[1], h_main);         // linker Flügel (hinter dem Turm)
    box(x_tow1, x_end,  y_main[0], y_main[1], h_main);         // rechter Flügel
    box(x_ris0, x_ris1, y_ris[0],  y_ris[1],  h_ris);          // Mittelrisalit (Eingangsrisalit), links 0,97 m hinter dem Turm
    if (RIS_HINTEN) box(ris_h_x0, ris_h_x1, y_rh[0], y_rh[1], h_ris);   // gleisseitiger Mittelrisalit
    if (TUERMCHEN) box(x_tt0, x_tt1, y_tt0, y_tt1, h_tt);      // Türmchen vor dem linken Flügel
}

// ============================================================
// Dächer
// ============================================================
// Vollkörper (Dreiecksprisma mit Überstand) eines Satteldachs, Firstrichtung x bzw. y
module roof_x_voll(x0, x1, yf, yb, ze, a, o, ol = 0, or = 0) {
    hs = (yb - yf) / 2;  yc = (yf + yb) / 2;
    zr = ze + hs * tan(a);  dz = o * tan(a);
    translate([x0 - ol, 0, 0]) rotate([90, 0, 90]) linear_extrude(x1 - x0 + ol + or)
        polygon(roof_prof(yf - o, yb + o, yc, ze - dz, zr, a));
}
module roof_y_voll(x0, x1, yf, yb, ze, a, o, of = 0, ob = 0) {
    hs = (x1 - x0) / 2;  xc = (x0 + x1) / 2;
    zr = ze + hs * tan(a);  dz = o * tan(a);
    translate([0, yb + ob, 0]) rotate([90, 0, 0]) linear_extrude(yb - yf + of + ob)
        polygon(roof_prof(x0 - o, x1 + o, xc, ze - dz, zr, a));
}
// Gemeinsame Dachhaut von Zwischengebäude, Flügel und Mittelrisalit: Außenhaut der Vereinigung aller
// Dachkörper (obere Fläche der Vereinigung, eine Dachhautstärke dick). An den Kehlen gilt immer
// die höhere Fläche; nichts ragt mehr durch die andere Dachhaut.
// Beschneidung des nach links über den Pavillon verlängerten Zwischengebäudedachs: rechts von x_pav1 unbeschnitten,
// links davon nur innerhalb der Grundfläche des Pavillons (y), damit nichts an der Pavillon-Rückwand herausragt.
module zw_ext_clip() {
    union() {
        translate([x_pav1, -50, -10]) cube([200, 100, 100]);
        translate([x_pav1 - zw_ext - 1, y_pav[0], -10])
            cube([zw_ext + 1.5, y_pav[1] - ZW_CLIP_HINTEN - y_pav[0], 100]);
    }
}
module zw_dach_voll() {
    intersection() {
        roof_x_voll(x_pav1, x_mb1, y_wing[0], y_wing[1], h_wing, a_wing, o_wing, zw_ext, 0);
        zw_ext_clip();
    }
}
module dachkoerper_alle() {
    zw_dach_voll();   // Zwischengebäude, First bis ins Walmdach des Pavillons verlängert
    roof_x_voll(x_lw0, x_tow1, y_main[0], y_main[1], ze_main, a_main, o_main, o_main_end, 0);   // linker Flügel
    roof_x_voll(x_tow1, x_end, y_main[0], y_main[1], ze_main, a_main, o_main, 0, o_main_end);
    roof_y_voll(x_ris0, x_ris1, y_ris[0], y_ris[1], ze_ris, a_ris, o_ris_t, o_ris, 0);
    if (RIS_HINTEN) roof_y_voll(ris_h_x0, ris_h_x1, y_rh[0], y_rh[1], ze_ris, a_ris_h, o_ris_t, 0, o_ris);   // Giebelüberstand nach hinten
}
module dachhaut_gruppe() {
    difference() {
        dachkoerper_alle();
        translate([0, 0, -td]) dachkoerper_alle();
    }
}

// Dach eines Anbau-Teils: Kern = Giebelkeil (Mauerwerk) über dem waagerechten Wandkopf ze, haut = Dachhaut mit Überstand.
// xa = linke Wandkante, y0..y1 = Tiefe; vorn / hinten: Dachüberstand an der Front / Rückseite
module ann_dach_teil(xa, y0, y1, ze, vorn, hinten, teil) {
    if (teil != "haut" && a_ann > 0)    // Giebelkeil nur bei geneigtem Dach
        translate([0, y1, 0]) rotate([90, 0, 0]) linear_extrude(y1 - y0)
            polygon([[xa, ze - td/2], [x_pav0, ann_z(x_pav0) - td/2], [x_pav0, ze - td/2]]);
    if (teil != "kern") {
        dv  = td / cos(a_ann);                                  // senkrechte Hautstärke
        yy0 = y0 - (vorn ? o_ann : 0);
        yy1 = y1 + (hinten ? o_ann : 0);
        translate([0, yy1, 0]) rotate([90, 0, 0]) linear_extrude(yy1 - yy0)
            polygon([[xa - o_ann, ann_z(xa - o_ann)], [x_pav0, ann_z(x_pav0)],
                     [x_pav0, ann_z(x_pav0) - dv], [xa - o_ann, ann_z(xa - o_ann) - dv]]);
    }
}

// Anbau-Dach: Walmdach über dem hinteren Bereich (Dachhaut aus Traufrechteck und First, nur links abgewalmt) plus Flachdach über dem
// vorderen Teil. Die Längsfläche zur Straße endet an der Vorderkante des Türanbaus (yf) auf der Höhe zJ, ab dort beginnt das
// Flachdach: ein Keil mit waagerechter Unterseite auf dem Wandkopf und geneigter Oberseite, die bis zur Vorderkante um
// ANN_FLACH_ABFALL abfällt. Die Mauer kann so nirgends durch die Dachfläche stoßen.
module ann_dach(teil = "beide") {
    xl = x_ann0 - o_ann;  xm = x_ann1 - o_ann;  xr = x_pav0;      // linke Traufe, Traufe des vorderen Teils, Pavillon
    yb = y_ann[1] + o_ann;                                         // Traufe Rückseite (Gleisseite)
    yf = y_anns - o_ann;                                           // Traufe Vorderkante des Türanbaus (linker Teil)
    yv = y_ann[0] - o_ann;                                         // Traufe Vorderkante des vorderen Teils
    yr = y_ann[1] - ANN_FIRST_ANTEIL * (y_ann[1] - y_anns);        // Firstlage
    zE  = h_ann - ANN_TRAUFE_ABSENK;                               // Traufe Rückseite
    zFE = h_ann + ANN_FLACH_RAND;                                  // Oberseite des Flachdachs an der Vorderkante
    zJ  = zFE + ANN_FLACH_ABFALL;                                  // Anschluss Längsfläche / Flachdach (= Traufe des Türanbaus)
    ta = tan(ANN_DACH_NEIGUNG);
    zR = zE + ta * (yb - yr);                                      // Firsthöhe
    xh = xl + (yb - yr);                                           // Ende des Firsts links (Walm gleiche Neigung)
    zB = h_ann - 0.6;
    module pc(pts) {       // Dachfläche als Vollkörper: Oberseite aus den Punkten, unten bei zB
        hull() for (q = pts) {
            translate([q[0], q[1], q[2]]) cube(eps);
            translate([q[0], q[1], zB]) cube(eps);
        }
    }
    module voll() {        // Walmdach (nur links abgewalmt): Traufrechteck + First
        pc([[xl, yb, zE], [xr, yb, zE], [xr, yf, zJ], [xl, yf, zJ], [xh, yr, zR], [xr, yr, zR]]);
    }
    module keil() {        // Flachdach: waagerechte Unterseite auf dem Wandkopf, Oberseite fällt zur Vorderkante
        zu = h_ann - 0.003;
        hull() for (q = [[xm, yf, zJ], [xr, yf, zJ], [xr, yv, zFE], [xm, yv, zFE]]) {
            translate([q[0], q[1], q[2]]) cube(eps);
            translate([q[0], q[1], zu]) cube(eps);
        }
    }
    if (teil != "haut")        // Kern: füllt den Raum zwischen Wandkopf und Dachhaut des Walmdachs (nur über dem Mauerwerk)
        intersection() {
            translate([0, 0, -td/2]) voll();
            union() {
                translate([x_ann0, y_anns, h_ann - 0.02])   cube([x_ann1 - x_ann0, y_ann[1] - y_anns, 3]);
                translate([x_ann1, y_ann[0], h_ann_h - 0.02]) cube([x_pav0 - x_ann1, y_ann[1] - y_ann[0], 3]);
            }
        }
    if (teil != "kern") {      // Dachhaut mit Überstand
        difference() { voll(); translate([0, 0, -td]) voll(); }
        keil();
    }
}

module daecher(teil = "beide") {
    // Anbau: einseitiges Walmdach hinten, Flachdach vorn (siehe ann_dach)
    if (ANBAU) ann_dach(teil);

    // Pavillon: Walmdach
    walm_y(x_pav0, x_pav1, y_pav[0], y_pav[1], h_pav, a_pav, o_pav, PAV_FIRST_LAENGE, teil);   // First 90° zur Gleisachse (in y)

    // Zwischengebäude, rechter Flügel und Mittelrisalit (Eingangsrisalit): Der Kern (Mauerwerk unter dem Dach) wird einzeln
    // gebaut, die Dachhaut aber als EINE gemeinsame Hülle (siehe dachhaut_gruppe), damit sich die
    // Dachflächen an den Kehlen nicht gegenseitig durchstoßen.
    if (teil != "haut") {
        roof_x(x_pav1 - zw_ext, x_mb1, y_wing[0], y_wing[1], h_wing, a_wing, o_wing, teil = "kern");   // Kern reicht mit dem verlängerten First bis ins Pavillondach
        roof_x(x_lw0, x_tow1, y_main[0], y_main[1], ze_main, a_main, o_main, o_main_end, 0, "kern");
        roof_x(x_tow1, x_end, y_main[0], y_main[1], ze_main, a_main, o_main, 0, o_main_end, "kern");
        roof_y(x_ris0, x_ris1, y_ris[0], y_ris[1], ze_ris, a_ris, o_ris_t, o_ris, 0, "kern");
        if (RIS_HINTEN) roof_y(ris_h_x0, ris_h_x1, y_rh[0], y_rh[1], ze_ris, a_ris_h, o_ris_t, 0, o_ris, "kern");
    }
    if (teil != "kern") {
        dachhaut_gruppe();
        // Eigene Haut des Zwischengebäudes: In der Gruppe verschwindet sie dort, wo der Vollkörper des Ortgang-
        // überstands vom linken Flügel (o_main_end) über First und oberem Dachteil liegt; das ließ eine Lücke,
        // in der der Kern sichtbar war. Die Flächen sind deckungsgleich mit denen der Gruppe, sonst gibt es keine Überschneidung.
        // Der First läuft nach links (zw_ext) bis ins Walmdach des Pavillons; dort in y auf den Pavillon beschnitten.
        intersection() {
            roof_x(x_pav1, x_mb1, y_wing[0], y_wing[1], h_wing, a_wing, o_wing, zw_ext, 0, teil = "haut");
            zw_ext_clip();
        }
    }

    // Turm: Zeltdach mit großem Überstand
    hip(x_tow0, x_tow1, y_tow[0], y_tow[1], z_lant1, a_tow, o_tow, teil);

    // Türmchen vor dem linken Flügel: flaches Pultdach, steigt zum Turm hin, liegt unter dem Traufüberstand des linken Flügels
    if (TUERMCHEN && teil != "kern")
        translate([0, y_tt1, 0]) rotate([90, 0, 0])
            linear_extrude(y_tt1 - (y_tt0 - o_tt))
                polygon([[x_tt0 - o_tt, h_tt], [x_tt1, h_tt + tt_dach_hub], [x_tt1, h_tt]]);
}

// ============================================================
// Turm: Schaft, Gesims, offene Laterne
// ============================================================
module turm() {
    box(x_tow0, x_tow1, y_tow[0], y_tow[1], z_lat_hi);   // Schaft bis Unterkante Holzbalken (Laterne-Öffnungen siehe laterne_oeffnung)
}

// Holzbalken (eine Reihe hoch) rund um den Turm, begrenzt die Öffnungen nach oben
module turm_holz() {
    hp = TURM_BALKEN_VORSPRUNG;   // Balken steht über Wand und Kappenreihe vor und läuft durchgehend über Pfeiler, Pfosten und Öffnungen; er reicht verdeckt bis unter den Dachkern, damit keine Fuge klafft
    color(C_HOLZ) translate([x_tow0 - hp, y_tow[0] - hp, z_lat_hi])
        cube([x_tow1 - x_tow0 + 2*hp, y_tow[1] - y_tow[0] + 2*hp, z_lant1 - td/2 - z_lat_hi]);
}

// ============================================================
// Dachzubehör Turm: Sparrenköpfe, Dachrinne mit Halbring-Haltern, Fahnenmast
// Der Turm ist quadratisch: eine Seite (vorn) wird modelliert und viermal um die Turmmitte gedreht.
// ============================================================
SPARREN    = true;
RINNE      = true;
MAST       = true;
C_SPARREN  = [0.30, 0.20, 0.13];
C_RINNE    = [0.62, 0.70, 0.66];
C_MAST     = [0.78, 0.80, 0.82];
C_KNAUF    = [0.30, 0.36, 0.60];
SPARREN_B  = 0.14;      // Breite eines Sparrenkopfes
SPARREN_H  = 0.16;      // Höhe
SPARREN_L0 = 0.00;      // Sparrenköpfe beginnen so weit (waagerecht) von der Wand
SPARREN_ZURUECK = 0.10; // Sparrenköpfe enden so weit hinter der Dachkante (ragen nicht über die Dachfläche hinaus)
RINNE_R    = 0.07;      // Radius der halbrunden Rinne
RINNE_W    = 0.012;     // Blechstärke
HALTER_ABSTAND = 0.55;  // Abstand der Rinnenhalter
HALTER_B   = 0.016;     // Breite des Halbrings
MAST_R     = 0.05;      // Mastradius unten
KNAUF_R    = 0.13;      // Knubbel am Mastende

module rund() { for (r = [0, 90, 180, 270]) translate([tcx, tcy, 0]) rotate(r) translate([-tcx, -tcy, 0]) children(); }

// Unterseite der Dachhaut am Sparren: Höhe in Abhängigkeit vom Abstand w von der Wand (Seite) bzw. s (Gratlinie)
function dach_unten(w) = z_lant1 - td - w * tan(a_tow);

// 6 Sparrenköpfe je Seite; der 1. und 6. sind die Ecksparren (Grat) und gehören zu beiden Seiten: 4 Sparren je Seite + 4 Ecksparren
module sparren_vorne() {
    Ls = (x_tow1 - x_tow0) + 2 * o_tow;
    for (i = [1 : 4])
        multmatrix(m_v(x_tow0 - o_tow + i * Ls / 5, y_tow[0]))
            translate([0, dach_unten(SPARREN_L0), SPARREN_L0]) rotate([a_tow, 0, 0])
                translate([-SPARREN_B/2, -SPARREN_H, 0])
                    cube([SPARREN_B, SPARREN_H, (o_tow - SPARREN_ZURUECK - SPARREN_L0) / cos(a_tow)]);
}
module sparren_ecke() {   // Ecksparren in der Gratlinie (Ecke vorn links), Neigung des Grates
    ah = atan(tan(a_tow) / sqrt(2));
    s0 = SPARREN_L0 * sqrt(2);  s1 = (o_tow - SPARREN_ZURUECK) * sqrt(2);
    translate([x_tow0, y_tow[0], 0]) rotate([0, 0, 225 - 90])
        translate([0, s0, z_lant1 - td - s0 * tan(ah)]) rotate([-ah, 0, 0])
            translate([-SPARREN_B/2, 0, -SPARREN_H]) cube([SPARREN_B, (s1 - s0) / cos(ah), SPARREN_H]);
}
module sparren_alle() { rund() { sparren_vorne(); sparren_ecke(); } }

// ------------------------------------------------------------
// Sparren (Balkenköpfe) unter den Ortgang-Überständen der Giebel: beide Stirnseiten des Hauptgebäudes (x_lw0, x_end)
// sowie die Giebel des straßen- und gleisseitigen Mittelrisalits (y_ris[0], y_rh[1]). Die Balken stehen waagerecht
// aus der Giebelwand heraus (Firstrichtung), liegen mit der Oberseite an der Dachhaut an und enden SPARREN_ZURUECK
// vor der Dachkante. Je Dachseite gleichmäßig verteilt (Abstand ca. SG_ABSTAND).
// ------------------------------------------------------------
SPARREN_GIEBEL = true;
SG_B       = 0.12;      // Balkenbreite
SG_H       = 0.14;      // Balkenhöhe
SG_ABSTAND = 1.1;       // ungefährer Abstand der Balken entlang der Dachneigung (waagerecht gemessen) [m]
// [Richtung der Balken ("x": Wand x = const, "y": Wand y = const), Wandlage, Richtung nach außen (+1/-1), Überstand,
//  Wandanfang und -ende quer dazu, Traufhöhe, Dachneigung, kleinste Querposition (Balken davor entfallen)]
giebel_sparren_liste = concat(
    [["x", x_lw0, -1, o_main_end, y_main[0], y_main[1], ze_main, a_main, -1e9],        // Hauptgebäude, linker Giebel
     ["x", x_end,   1, o_main_end, y_main[0], y_main[1], ze_main, a_main, -1e9],        // Hauptgebäude, rechter Giebel
     ["y", y_ris[0], -1, o_ris, x_ris0, x_ris1, ze_ris, a_ris, x_tow1 + SG_B]],        // Eingangsrisalit (Straßenseite); links vom Turm verdeckt
    RIS_HINTEN ? [["y", y_rh[1], 1, o_ris, ris_h_x0, ris_h_x1, ze_ris, a_ris_h, -1e9]] : []);   // gleisseitiger Mittelrisalit

module giebel_sparren(g) {
    mode = g[0];  wall = g[1];  dir = g[2];  o = g[3];  c0 = g[4];  c1 = g[5];  ze = g[6];  a = g[7];  cmin = g[8];
    L  = o - SPARREN_ZURUECK;
    hs = (c1 - c0) / 2;
    n  = max(2, round(hs / SG_ABSTAND));
    dp = hs / n;
    t  = tan(a);
    for (side = [-1, 1]) for (i = [0 : n - 1]) {
        c = side < 0 ? c0 + (i + 0.5) * dp : c1 - (i + 0.5) * dp;
        if (c > cmin) {
            // Unterseite der Dachhaut an dieser Querposition; der grüne Dachkasten hängt darunter (Dicke DK_G senkrecht zur Dachfläche).
            // Die Balken hängen unter dem Kasten und sind so sichtbar (Oberseite 1 cm im Kasten, damit sie anliegen).
            zt = ze + min(c - c0, c1 - c) * t - td + 0.005 - (DACHKASTEN ? DK_G / cos(a) - 0.01 : 0);
            sg = side < 0 ? 1 : -1;                              // Dach steigt zur Mitte hin: Oberseite des Balkens folgt der Neigung
            pr = [[-SG_B/2, -SG_H], [SG_B/2, -SG_H], [SG_B/2, sg * SG_B/2 * t], [-SG_B/2, -sg * SG_B/2 * t]];
            if (mode == "x")
                translate([dir > 0 ? wall - 0.02 : wall - L, c, zt]) rotate([90, 0, 90]) linear_extrude(L + 0.02) polygon(pr);
            else
                translate([c, dir < 0 ? wall + 0.02 : wall + L, zt]) rotate([90, 0, 0]) linear_extrude(L + 0.02) polygon(pr);
        }
    }
}
module giebel_sparren_alle() { for (g = giebel_sparren_liste) giebel_sparren(g); }

// Sparrenköpfe unter den vier Dachkanten des Pavillons (wie im Foto): je ein Balken über jeder Konsole des Bogenfrieses (Konsolen im
// Abstand der Bogenfelder, ohne die Eckkonsolen) und je ein diagonaler Balken an jeder Ecke (unter dem Walmgrat). Die Balken hängen
// parallel zur Dachneigung unter der grünen Platte (Oberkante 1 cm in der Platte), beginnen an der Vorderkante des Zierfrieses und enden
// SPARREN_ZURUECK vor der Dachkante.
// mode "y": Traufe verläuft in y bei x = wall (Balken in x); mode "x": Traufe in x bei y = wall (Balken in y).
// s = Richtung nach außen, o = Überstand, c0..c1 = Wandlänge, t = tan(Dachneigung), zb = Oberkante der Balken an der Wand,
// ex0..ex1 = Bereich quer dazu, in dem keine Balken stehen (dort steht ein anderes Gebäude).
PAV_SPARREN = true;
module pav_sparren(mode, wall, s, o, c0, c1, t, zb, ex0 = 1e9, ex1 = -1e9) {
    d0 = ZF_VORSPRUNG;  d1 = o - SPARREN_ZURUECK;
    Lw = c1 - c0;  N = max(1, round(Lw / ZF_RASTER));  P = Lw / N;      // gleiche Teilung wie zf_wand2d
    pr = [[s * d0, zb - d0 * t], [s * d1, zb - d1 * t], [s * d1, zb - d1 * t - SG_H], [s * d0, zb - d0 * t - SG_H]];
    for (m = [1 : N - 1]) {
        c = c0 + m * P;
        if (c < ex0 || c > ex1) {
            if (mode == "y") translate([wall, c + SG_B / 2, 0]) rotate([90, 0, 0]) linear_extrude(SG_B) polygon(pr);
            else             translate([c - SG_B / 2, wall, 0]) rotate([90, 0, 90]) linear_extrude(SG_B) polygon(pr);
        }
    }
}
// Diagonalbalken an einer Ecke (cx, cy): sx, sy = Richtung nach außen; läuft entlang des Walmgrats (Grundriss: von der Wandecke zur Dachecke)
module pav_sparren_ecke(cx, cy, sx, sy, oe, zb) {
    lg = sqrt(o_pav * o_pav + oe * oe);                 // waagerechte Länge des Grats bis zur Dachecke
    tg = o_pav * tan(a_pav) / lg;                       // Gefälle des Grats
    l0 = ZF_VORSPRUNG * sqrt(2);  l1 = lg - SPARREN_ZURUECK;
    pr = [[l0, zb - l0 * tg], [l1, zb - l1 * tg], [l1, zb - l1 * tg - SG_H], [l0, zb - l0 * tg - SG_H]];
    translate([cx, cy, 0]) rotate([0, 0, atan2(sy * oe, sx * o_pav)]) translate([0, SG_B / 2, 0])
        rotate([90, 0, 0]) linear_extrude(SG_B) polygon(pr);
}
module pavillon_sparren() {
    oe = o_pav * tan(a_pav) / tan(a_pav_e);
    zb = h_pav - td - DKP_PAV + 0.01;
    pav_sparren("y", x_pav0, -1, o_pav, y_pav[0], y_pav[1], tan(a_pav), zb);
    pav_sparren("y", x_pav1,  1, o_pav, y_pav[0], y_pav[1], tan(a_pav), zb, y_wing[0] - SG_B, y_wing[1] + SG_B);   // vor dem Zwischengebäude verdeckt
    pav_sparren("x", y_pav[0], -1, oe, x_pav0, x_pav1, tan(a_pav_e), zb);
    pav_sparren("x", y_pav[1],  1, oe, x_pav0, x_pav1, tan(a_pav_e), zb);
    for (cx = [[x_pav0, -1], [x_pav1, 1]]) for (cy = [[y_pav[0], -1], [y_pav[1], 1]])
        pav_sparren_ecke(cx[0], cy[0], cx[1], cy[1], oe, zb);
}

// Dachrinne (Halbrund, Gehrung in den Ecken) mit Rinnenhaltern: reine Halbringe unter der Rinne
module rinne_vorne() {
    e   = o_tow + 0.01;
    rg  = RINNE_R;
    zax = z_lant1 - o_tow * tan(a_tow) + 0.03;
    yax = y_tow[0] - e;
    xl  = x_tow0 - e;  xr = x_tow1 + e;
    intersection() {
        translate([0, 0, zax - 1]) linear_extrude(2)       // Gehrung 45° in den Ecken
            polygon([[xl - rg, yax - rg], [xr + rg, yax - rg], [xr - rg, yax + rg], [xl + rg, yax + rg]]);
        intersection() {
            translate([xl - rg, yax, zax]) rotate([0, 90, 0]) difference() {
                cylinder(r = rg, h = xr - xl + 2*rg, $fn = 32);
                translate([0, 0, -eps]) cylinder(r = rg - RINNE_W, h = xr - xl + 2*rg + 2*eps, $fn = 32);
            }
            translate([xl - rg - 0.1, yax - rg - 0.1, zax - rg - 0.1]) cube([xr - xl + 2*rg + 0.2, 2*rg + 0.2, rg + 0.1]);   // nur untere Hälfte
        }
    }
    n = round((xr - xl) / HALTER_ABSTAND);
    for (k = [0 : n - 1])
        translate([xl + (k + 0.5) * (xr - xl) / n - HALTER_B/2, yax, zax]) rotate([90, 0, 90])
            linear_extrude(HALTER_B) {
                difference() {                                   // Halbring um die Rinne
                    intersection() { circle(r = rg + 0.014, $fn = 32); translate([-1, -1]) square([2, 1]); }
                    circle(r = rg, $fn = 32);
                }
            }
}
module rinne_alle() { rund() rinne_vorne(); }

// ------------------------------------------------------------
// Straßenseite des Hauptgebäudes: Dachrinne am rechten Flügel und zwei Fallrohre
//   1. Fallrohr in der Innenecke Turm / Eingangsrisalit (Turm links, Risalitfront dahinter): endet in einem
//      kleinen Wasserfangkasten unter dem Dachüberstand des Risalits
//   2. Halbrunde Dachrinne an der Traufkante des rechten Flügels (von der Risalitkante bis zum Giebelüberstand) und
//      daran ein Fallrohr in der Innenecke Eingangsrisalit / rechter Flügel (Rohr hängt am Rinnenende, springt unter
//      dem Dachüberstand mit einer 45°-Schräge zur Wand zurück und läuft dann senkrecht zum Boden)
// ------------------------------------------------------------
RINNE_STRASSE = true;
FALLROHR_AUSSENECKEN = false;  // Fallrohre an den Außenecken der Seitengiebel des Hauptgebäudes (falsch -> aus); die Fallrohre der Innenecken bleiben
FR_R       = 0.045;           // Fallrohr: Radius (real 90 mm Durchmesser)
FR_WAND    = pmax + 0.02;     // Abstand Rohrmantel - Wand (vor Sockel und Bändern)
FR_SCHELLE = 1.3;             // Abstand der Rohrschellen
FR_Z0      = 0.12;            // Rohrende über Gelände

// rechter Flügel, Traufe Straßenseite
rw_zax = ze_main - o_main * tan(a_main) + 0.03;           // Rinnenachse (wie am Turm: knapp über der Dachkante)
rw_yax = y_main[0] - o_main - 0.01;
rc_x   = x_ris1 + o_ris_t + 0.01;                         // Rinnenwinkel Innenecke Risalit / rechter Flügel: Traufrinne und Risalitrinne stoßen im rechten Winkel aufeinander
ry_f   = y_ris[0] - o_ris;                                // Risalitrinne reicht bis zum Giebelüberstand vorn
rw_xr  = x_end + o_main_end + 0.01;                       // Achse der Ortgangrinne rechts (Giebelüberstand)
rw_xe  = rw_xr;                                           // Traufrinne endet im Winkel mit der Ortgangrinne
// Fallrohr am Rinnenanfang (Innenecke Risalit / rechter Flügel)
fr_x   = x_ris1 + FR_R + FR_WAND;
fr_y   = y_main[0] - FR_R - FR_WAND;
fr_gx  = rc_x;                                            // Rinnenauslauf im Winkel
fr_gz  = rw_zax - RINNE_R - FR_R + 0.01;
fr_dz  = sqrt(pow(fr_gx - fr_x, 2) + pow(fr_y - rw_yax, 2));   // 45° gegen die Waagerechte
fr_zk  = fr_gz - fr_dz;                                   // Knick am Wandrohr
// Fallrohr in der Innenecke Turm / Eingangsrisalit
tp_x   = x_tow1 + FR_R + FR_WAND;
tp_y   = y_ris0 - FR_R - FR_WAND;
tp_zt  = ze_ris + (tp_x - x_ris0) * tan(a_ris) - td - 0.03;   // Oberkante des Wasserfangkastens unter der Dachhaut des Risalits

module rinne_gerade(xs, xe, yax, zax) {
    rg = RINNE_R;  L = xe - xs;
    intersection() {
        translate([xs, yax, zax]) rotate([0, 90, 0]) difference() {
            cylinder(r = rg, h = L, $fn = 32);
            translate([0, 0, RINNE_W]) cylinder(r = rg - RINNE_W, h = L - 2 * RINNE_W, $fn = 32);   // Endkappen bleiben stehen
        }
        translate([xs - 0.1, yax - rg - 0.1, zax - rg - 0.1]) cube([L + 0.2, 2 * rg + 0.2, rg + 0.1]);   // nur untere Hälfte
    }
    n = max(1, round(L / HALTER_ABSTAND));
    for (k = [0 : n - 1])
        translate([xs + (k + 0.5) * L / n - HALTER_B / 2, yax, zax]) rotate([90, 0, 90])
            linear_extrude(HALTER_B)
                difference() {
                    intersection() { circle(r = rg + 0.014, $fn = 32); translate([-1, -1]) square([2, 1]); }
                    circle(r = rg, $fn = 32);
                }
}
module rohr_stueck(p0, p1, r = FR_R) {
    hull() { translate(p0) sphere(r = r, $fn = 16); translate(p1) sphere(r = r, $fn = 16); }
}
// Rohrschellen mit Wandhalter (Wand liegt bei yw, hinter dem Rohr in +y)
module fr_schellen(x, y, z0, z1, yw) {
    for (z = [z0 + 0.4 : FR_SCHELLE : z1 - 0.1]) {
        translate([x, y, z]) cylinder(r = FR_R + 0.012, h = 0.03, $fn = 20);
        translate([x - 0.012, y, z]) cube([0.024, yw + 0.01 - y, 0.03]);
    }
}
// ------------------------------------------------------------
// Ortgangrinnen und Gleisseite
// An den Giebelüberständen von rechtem und linkem Flügel läuft eine kleine Rinne an der Dachschräge nach unten und trifft im
// Winkel auf die Traufrinne; genau dort geht das Fallrohr ab (45°-Schräge zurück zur Wandecke, dann senkrecht). Gleisseite:
// Traufrinne an der Rückseite beider Flügel (von den Risalitseiten bis zum Giebelüberstand), gleiche Ecken.
// ------------------------------------------------------------
RINNE_GLEIS   = true;
RINNE_G_R     = 0.05;                                      // Radius der kleinen Ortgangrinne
rl_xr  = x_lw0 - o_main_end - 0.01;                        // Achse der Ortgangrinne links
rb_yax = y_main[1] + o_main + 0.01;                        // Traufrinne Gleisseite
y_first = (y_main[0] + y_main[1]) / 2;                     // Firstlinie der Flügel
rb_xs  = ris_h_x1 + o_ris_t + 0.01;                        // Rinnenwinkel rechts vom gleisseitigen Risalit
rb_xe  = ris_h_x0 - o_ris_t - 0.01;                        // Rinnenwinkel links vom gleisseitigen Risalit
ry_b   = y_rh[1] + o_ris;                                  // Rinnen der Risalitseiten reichen bis zum Giebelüberstand hinten

// halbrunde Rinne entlang einer beliebigen (auch geneigten) Strecke p0 -> p1, Öffnung nach oben
module rinne_dir(p0, p1, rg) {
    d = p1 - p0;  L = norm(d);  az = atan2(d[1], d[0]);  el = asin(d[2] / L);
    translate(p0) rotate([0, 0, az]) rotate([0, -el, 0])
        intersection() {
            rotate([0, 90, 0]) difference() {
                cylinder(r = rg, h = L, $fn = 24);
                translate([0, 0, RINNE_W]) cylinder(r = rg - RINNE_W, h = L - 2*RINNE_W, $fn = 24);
            }
            translate([-0.01, -rg - 0.01, -rg - 0.01]) cube([L + 0.02, 2*rg + 0.02, rg + 0.01]);
        }
}
module rinne_kappe(p, rg) {   // Halbkugel im Winkel, schließt die Ecke
    translate(p) intersection() { sphere(r = rg, $fn = 20); translate([-rg, -rg, -rg]) cube([2*rg, 2*rg, rg]); }
}
// Ortgangrinne + Fallrohr an einer Ecke. xr: Achse der Ortgangrinne, yk: Achse der Traufrinne (Ecke), sy: +1 = Traufe vorn
// (Rinne steigt zum First nach +y), -1 = Traufe hinten; sx: +1 Giebel rechts, -1 Giebel links
module ecke_rinne(xr, yk, sy, sx, ywand) {
    zk  = rw_zax;                                             // Achse im Winkel
    ca  = cos(a_main);  sa = sin(a_main);
    s   = abs(y_first - yk) / ca;                             // Länge der Schräge bis zum First
    P   = [xr, yk + sy * s * ca, zk + s * sa];
    rinne_dir([xr, yk, zk], P, RINNE_G_R);
    rinne_kappe([xr, yk, zk], RINNE_R);
    // Fallrohr: unter dem Winkel ab, 45° zurück zur Wandecke, dann senkrecht (an den Außenecken der Seitengiebel nicht vorhanden)
    if (FALLROHR_AUSSENECKEN) {
    xw = sx > 0 ? x_end + FR_R + FR_WAND : x_lw0 - FR_R - FR_WAND;
    yw = ywand;
    d  = sqrt(pow(xr - xw, 2) + pow(yk - yw, 2));
    zn = zk - RINNE_R - FR_R + 0.01;
    zq = zn - d;
    translate([xw, yw, FR_Z0]) cylinder(r = FR_R, h = zq - FR_Z0, $fn = 24);
    rohr_stueck([xw, yw, zq], [xr, yk, zn]);
    translate([xr, yk, zn - 0.03]) cylinder(r = FR_R, h = 0.03, $fn = 24);
    }
}
// Fallrohr unter dem Rinnenwinkel p: 45° zurück zur Wand (xw, yw), dann senkrecht
module fallrohr_winkel(xp, yp, xw, yw) {
    zn = rw_zax - RINNE_R - FR_R + 0.01;
    d  = sqrt(pow(xp - xw, 2) + pow(yp - yw, 2));
    zq = zn - d;
    translate([xw, yw, FR_Z0]) cylinder(r = FR_R, h = zq - FR_Z0, $fn = 24);
    rohr_stueck([xw, yw, zq], [xp, yp, zn]);
    translate([xp, yp, zn - 0.03]) cylinder(r = FR_R, h = 0.03, $fn = 24);
}
// Rinne entlang y (Achse bei x = xax), von ys bis ye
module rinne_y(ys, ye, xax, zax) {
    multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) rinne_gerade(ys, ye, xax, zax);
}
module gleis_rinnen() {
    // Ortgangrinne und Fallrohr: rechter Flügel vorn und hinten, linker Flügel hinten (vorn steht das Türmchen)
    ecke_rinne(rw_xr, rw_yax,  1, 1, y_main[0] - FR_R - FR_WAND);
    ecke_rinne(rw_xr, rb_yax, -1, 1, y_main[1] + FR_R + FR_WAND);
    ecke_rinne(rl_xr, rb_yax, -1, -1, y_main[1] + FR_R + FR_WAND);
    // Traufrinnen Gleisseite
    rinne_gerade(rb_xs, rw_xr, rb_yax, rw_zax);               // rechter Flügel
    rinne_gerade(rl_xr, rb_xe, rb_yax, rw_zax);               // linker Flügel
    if (RIS_HINTEN) {   // Rinnen an den Seiten des gleisseitigen Risalits: im rechten Winkel zur Traufrinne, im Winkel das Fallrohr
        rinne_y(rb_yax, ry_b, rb_xs, rw_zax);   rinne_kappe([rb_xs, rb_yax, rw_zax], RINNE_R);
        rinne_y(rb_yax, ry_b, rb_xe, rw_zax);   rinne_kappe([rb_xe, rb_yax, rw_zax], RINNE_R);
        fallrohr_winkel(rb_xs, rb_yax, ris_h_x1 + FR_R + FR_WAND, y_main[1] + FR_R + FR_WAND);
        fallrohr_winkel(rb_xe, rb_yax, ris_h_x0 - FR_R - FR_WAND, y_main[1] + FR_R + FR_WAND);
    }
}

module strassen_rinnen() {
    // Dachrinne rechter Flügel
    rinne_gerade(rc_x, rw_xe, rw_yax, rw_zax);
    rinne_y(ry_f, rw_yax, rc_x, rw_zax);                      // Rinne an der Risalitseite, trifft im rechten Winkel auf die Traufrinne
    rinne_kappe([rc_x, rw_yax, rw_zax], RINNE_R);
    {
    // Fallrohr Innenecke Risalit / rechter Flügel
    translate([fr_x, fr_y, FR_Z0]) cylinder(r = FR_R, h = fr_zk - FR_Z0, $fn = 24);
    rohr_stueck([fr_x, fr_y, fr_zk], [fr_gx, rw_yax, fr_gz]);
    fr_schellen(fr_x, fr_y, FR_Z0, fr_zk, y_main[0]);
    // Fallrohr Innenecke Turm / Eingangsrisalit mit Wasserfangkasten
    translate([tp_x, tp_y, FR_Z0]) cylinder(r = FR_R, h = tp_zt - 0.14 - FR_Z0, $fn = 24);
    translate([tp_x - 0.07, tp_y - 0.06, tp_zt - 0.16]) cube([0.14, 0.12, 0.16]);
    fr_schellen(tp_x, tp_y, FR_Z0, tp_zt - 0.16, y_ris0);
    }
    if (RINNE_GLEIS) gleis_rinnen();
}

// ------------------------------------------------------------
// Dachrinnen und Fallrohre an Zwischengebäude, Pavillon und Anbau (gleiche Bauart wie am Hauptgebäude: halbrunde Rinne mit
// Halbring-Haltern knapp vor der Dachkante, Endkappen, Fallrohre mit Rohrschellen: unter dem Rinnenauslauf 45° zurück zur
// Wand, dann senkrecht zum Boden)
//   Zwischengebäude: Rinne vorn und hinten; vier Fallrohre in den Innenecken (Pavillon / Türmchen vorn, Pavillon / linker Flügel hinten)
//   Pavillon: Rinne vorn und hinten (Walmdach, gleiche Traufhöhe rundum); die Längsseiten entwässern auf das Anbau- bzw.
//             Zwischengebäudedach. Je zwei Fallrohre an den Wandecken vorn und hinten
//   Anbau: Rinne an der Rückseite, an der linken Walmkante, an der Vorderkante des Türanbaus und an Seite und Front des
//          Flachdachs; Fallrohre im Winkel Türanbau / vorderer Teil, hinten am Pavillon und vorn in der Innenecke zum Pavillon
// Dazu ein brauner Dachkasten unter der Dachhaut des Anbaus (Rückseite, linke Kante, Vorderkante des Türanbaus). Sparren sind am Anbau
// nicht zu sehen.
// ------------------------------------------------------------
RINNE_NEBEN   = true;
C_DK_ANN      = [0.36, 0.24, 0.15];   // brauner Dachkasten am Anbau

// Fallrohr unter dem Rinnenauslauf (xo, yo, zo = Rinnenachse): senkrecht an der Wand bei (xw, yw), darüber 45° zurück zum Auslauf
// (wx, wy: Richtung zur Wand für die Rohrschellen)
module fr_neben(xo, yo, zo, xw, yw, wx, wy) {
    zn = zo - RINNE_R - FR_R + 0.01;
    d  = sqrt(pow(xo - xw, 2) + pow(yo - yw, 2));
    zq = zn - d;
    translate([xw, yw, FR_Z0]) cylinder(r = FR_R, h = zq - FR_Z0, $fn = 24);
    rohr_stueck([xw, yw, zq], [xo, yo, zn]);
    translate([xo, yo, zn - 0.03]) cylinder(r = FR_R, h = 0.03, $fn = 24);
    for (z = [FR_Z0 + 0.4 : FR_SCHELLE : zq - 0.1])
        hull() {
            translate([xw, yw, z]) cylinder(r = FR_R + 0.012, h = 0.03, $fn = 20);
            translate([xw + wx * (FR_R + FR_WAND + 0.01), yw + wy * (FR_R + FR_WAND + 0.01), z]) cylinder(r = 0.012, h = 0.03, $fn = 8);
        }
}

// ---- Zwischengebäude
zr_zax = h_wing - o_wing * tan(a_wing) + 0.03;                // Rinnenachse (knapp über der Dachkante)
zr_yf  = y_wing[0] - o_wing - 0.01;                           // Rinne vorn
zr_yb  = y_wing[1] + o_wing + 0.01;                           // Rinne hinten
zr_xs  = x_pav1 + 0.02;                                       // Anfang am Pavillon
zr_xv  = x_tt0 - 0.05;                                        // vorn endet die Rinne am Türmchen
zr_xh  = x_mb1 - 0.02;                                        // hinten am linken Flügel
module rinnen_zwischen() {
    rinne_gerade(zr_xs, zr_xv, zr_yf, zr_zax);
    rinne_gerade(zr_xs, zr_xh, zr_yb, zr_zax);
    if (FALLROHR_PAV_RECHTS_VORN)
        fr_neben(x_pav1 + FR_R + FR_WAND, zr_yf, zr_zax, x_pav1 + FR_R + FR_WAND, y_wing[0] - FR_R - FR_WAND, -1, 0);   // vorn links: Innenecke Pavillon (entfällt)
    fr_neben(x_tt0 - FR_R - FR_WAND,  zr_yf, zr_zax, x_tt0 - FR_R - FR_WAND,  y_wing[0] - FR_R - FR_WAND,  1, 0);   // vorn rechts: Innenecke Türmchen
    if (!FALLROHR_GLEIS_NUR_LISTE)   // Gleisseite: Innenecke Pavillon hinten nicht in der Liste
        fr_neben(x_pav1 + FR_R + FR_WAND, zr_yb, zr_zax, x_pav1 + FR_R + FR_WAND, y_wing[1] + FR_R + FR_WAND, -1, 0);   // hinten links: Innenecke Pavillon
    fr_neben(x_mb1 - FR_R - FR_WAND,  zr_yb, zr_zax, x_mb1 - FR_R - FR_WAND,  y_wing[1] + FR_R + FR_WAND,  1, 0);   // hinten rechts: Innenecke linker Flügel
}

// ---- Pavillon (Walmdach)
pr_oe  = o_pav * tan(a_pav) / tan(a_pav_e);                   // Überstand der Walmseiten vorn / hinten (gleiche Traufhöhe rundum)
pr_zax = h_pav - o_pav * tan(a_pav) + 0.03;
pr_yf  = y_pav[0] - pr_oe - 0.01;
pr_yb  = y_pav[1] + pr_oe + 0.01;
pr_xl  = x_pav0 - o_pav - 0.01;
pr_xr  = x_pav1 + o_pav + 0.01;
module rinnen_pavillon() {
    rinne_gerade(pr_xl, pr_xr, pr_yf, pr_zax);
    rinne_gerade(pr_xl, pr_xr, pr_yb, pr_zax);
    for (xw = [x_pav0 + FR_R + FR_WAND, x_pav1 - FR_R - FR_WAND]) {
        if (xw < x_pav0 + 1 || FALLROHR_PAV_RECHTS_VORN)                      // vorn rechts (Außenecke) entfällt
            fr_neben(xw, pr_yf, pr_zax, xw, y_pav[0] - FR_R - FR_WAND, 0,  1);    // vorn, an der Frontwand
        if (!FALLROHR_GLEIS_NUR_LISTE || xw > x_pav0 + 1)                     // hinten: nur die Außenecke links (von der Gleisseite gesehen = x_pav1)
            fr_neben(xw, pr_yb, pr_zax, xw, y_pav[1] + FR_R + FR_WAND, 0, -1);    // hinten, an der Rückwand
    }
    fr_ausguss_strasse(x_pav0 + FR_R + FR_WAND, y_pav[0] - FR_R - FR_WAND);   // vorn links: unten Öffnung zur Straße
}

// ---- Anbau: Maße des Daches wie in ann_dach()
an_xl = x_ann0 - o_ann;  an_xm = x_ann1 - o_ann;  an_xr = x_pav0;
an_yb = y_ann[1] + o_ann;  an_yf = y_anns - o_ann;  an_yv = y_ann[0] - o_ann;
an_yr = y_ann[1] - ANN_FIRST_ANTEIL * (y_ann[1] - y_anns);
an_zE = h_ann - ANN_TRAUFE_ABSENK;
an_zFE = h_ann + ANN_FLACH_RAND;
an_zJ  = an_zFE + ANN_FLACH_ABFALL;
an_zR  = an_zE + tan(ANN_DACH_NEIGUNG) * (an_yb - an_yr);
an_gz  = 0.03;                                                // Rinnenachse über der Dachkante
module rinnen_anbau() {
    gx = an_xl - 0.01;  gxm = an_xm - 0.01;  gyb = an_yb + 0.01;  gyf = an_yf - 0.01;  gyv = an_yv - 0.01;
    rinne_gerade(gx, an_xr, gyb, an_zE + an_gz);                                                   // Rückseite
    rinne_dir([gx, gyb, an_zE + an_gz], [gx, gyf, an_zJ + an_gz], RINNE_R);                        // linke Walmkante (steigt zur Front)
    rinne_kappe([gx, gyb, an_zE + an_gz], RINNE_R);  rinne_kappe([gx, gyf, an_zJ + an_gz], RINNE_R);
    rinne_gerade(gx, gxm, gyf, an_zJ + an_gz);                                                     // Vorderkante des Türanbaus
    rinne_dir([gxm, gyf, an_zJ + an_gz], [gxm, gyv, an_zFE + an_gz], RINNE_R);                     // linke Kante des Flachdachs (fällt zur Front)
    rinne_kappe([gxm, gyf, an_zJ + an_gz], RINNE_R);  rinne_kappe([gxm, gyv, an_zFE + an_gz], RINNE_R);
    rinne_gerade(gxm, an_xr, gyv, an_zFE + an_gz);                                                 // Vorderkante des Flachdachs
    // Fallrohre
    if (FALLROHR_ANN_TUERWINKEL)                                                                    // Winkel Türanbau / vorderer Teil: kein Fallrohr
        fr_neben(gxm, gyf, an_zJ + an_gz, x_ann1 - 0.085, y_anns - FR_R - FR_WAND, 0, 1);
    if (!FALLROHR_GLEIS_NUR_LISTE)                                                                  // Gleisseite: hinten am Pavillon nicht in der Liste
        fr_neben(x_pav0 - FR_R - FR_WAND, gyb, an_zE + an_gz, x_pav0 - FR_R - FR_WAND, y_ann[1] + FR_R + FR_WAND, 0, -1);   // hinten am Pavillon
    if (FALLROHR_ANN_GIEBEL_HINTEN)                                                                 // Gleisseite: Giebelecke des Anbaus (im Foto rechts)
        fr_neben(gx, gyb, an_zE + an_gz, x_ann0 + FR_R + FR_WAND, y_ann[1] + FR_R + FR_WAND, 0, -1);
    fr_neben(x_pav0 - FR_R - FR_WAND, gyv, an_zFE + an_gz, x_pav0 - FR_R - FR_WAND, y_ann[0] - FR_R - FR_WAND, 0, 1);       // vorn, Innenecke zum Pavillon
    fr_boden_zum_pavillon();                                                                        // von dort am Boden nach vorn zum Pavillon-Fallrohr
}

// Brauner Dachkasten am Anbau: Platte unter der Dachhaut entlang der Dachkante (parallel zur Dachfläche), Oberkante = Unterseite der Dachhaut
// p0, p1: Traufkante (Oberkante Dachhaut), n: Richtung zur Wand in der Draufsicht, sl: Anstieg der Dachfläche zur Wand hin
module dk_ann_platte(p0, p1, n, sl) {
    dka = DK_G / cos(atan(sl));
    s0 = DK_G_UE;  s1 = o_ann + DK_EIN;
    hull() for (q = [p0, p1]) for (s = [s0, s1]) {
        zt = q[2] + sl * s - td + 0.004;
        translate([q[0] + n[0] * s, q[1] + n[1] * s, zt]) cube(eps);
        translate([q[0] + n[0] * s, q[1] + n[1] * s, zt - dka]) cube(eps);
    }
}
module dachkasten_anbau() {
    sl_h = tan(ANN_DACH_NEIGUNG);
    sl_v = (an_zR - an_zJ) / (an_yr - an_yf);
    dk_ann_platte([an_xl, an_yb, an_zE], [an_xr, an_yb, an_zE], [0, -1], sl_h);        // Rückseite
    dk_ann_platte([an_xl, an_yb, an_zE], [an_xl, an_yf, an_zJ], [1, 0], sl_h);         // linke Walmkante
    dk_ann_platte([an_xl, an_yf, an_zJ], [an_xm, an_yf, an_zJ], [0, 1], sl_v);         // Vorderkante des Türanbaus
    // Flachdach vor dem Türanbau: linke Kante (quer flach, fällt zur Front) und Vorderkante (fällt nach vorn, steigt zur Wand)
    sl_f = ANN_FLACH_ABFALL / (an_yf - an_yv);
    dk_ann_platte([an_xm, an_yf, an_zJ], [an_xm, an_yv, an_zFE], [1, 0], 0);           // linke Kante des Flachdachs
    dk_ann_platte([an_xm, an_yv, an_zFE], [an_xr, an_yv, an_zFE], [0, 1], sl_f);       // Vorderkante des Flachdachs
}
// Fallrohre vorn am Pavillon: Rinnenwinkel Anbau/Pavillon läuft am Boden nach vorn und endet im Fallrohr an der Pavillon-Frontwand,
// dessen Rohrende unten eine Öffnung zur Straße hat (Vorbild: Foto)
// Gleisseite: Fallrohre nur in den Innenecken des gleisseitigen Mittelrisalits (beidseitig), an der Außenecke links des Pavillons
// (von der Gleisseite aus gesehen) und in der Innenecke Zwischengebäude / Hauptgebäude. Alle anderen Fallrohre der Gleisseite sind
// abgeschaltet; die Straßenseite ist davon nicht betroffen.
FALLROHR_GLEIS_NUR_LISTE = true;
FALLROHR_ANN_GIEBEL_HINTEN = true;   // Gleisseite: Fallrohr an der Giebelecke des Anbaus (links im Modell, rechts im Foto)
FALLROHR_ANN_TUERWINKEL = false;     // true: Fallrohr in der Innenecke zwischen Türanbau und vorderem Wandteil des Anbaus
FALLROHR_PAV_RECHTS_VORN = false;   // true: auch das Fallrohr an der rechten Außenecke des Pavillons und in der Innenecke zum Zwischenbau (vorn)
FR_AUSGUSS = 0.20;                  // Länge des Ausgussstutzens zur Straße
FR_ZB      = FR_Z0 + FR_R;          // Rohrachse am Boden
module fr_boden_zum_pavillon() {
    xa = x_pav0 - FR_R - FR_WAND;   ya = y_ann[0] - FR_R - FR_WAND;       // unten am Anbau-Fallrohr (Innenecke)
    yv = y_pav[0] - FR_R - FR_WAND; xp = x_pav0 + FR_R + FR_WAND;          // unten am Pavillon-Fallrohr
    pts = [[xa, ya, FR_ZB], [xa, yv, FR_ZB], [xp, yv, FR_ZB]];
    for (p = pts) translate(p) sphere(r = FR_R, $fn = 20);
    for (i = [0 : len(pts) - 2]) rohr_stueck(pts[i], pts[i + 1]);
}
module fr_ausguss_strasse(x, y) {   // Krümmer unten am Fallrohr + offener Stutzen zur Straße (-y)
    translate([x, y, FR_ZB]) {
        sphere(r = FR_R, $fn = 20);
        rotate([90, 0, 0]) difference() {
            cylinder(r = FR_R, h = FR_AUSGUSS, $fn = 24);
            translate([0, 0, FR_AUSGUSS - 0.08]) cylinder(r = FR_R - 0.012, h = 0.09, $fn = 24);
        }
    }
}

// ---- Türmchen: Rinne an der tiefen Dachkante des Pultdachs (Dach fällt nach links, weg vom Turm)
tz_x = x_tt0 - o_tt - 0.01;
tz_z = h_tt + 0.03;
module rinnen_tuermchen() {
    rinne_y(y_tt0 - o_tt, y_tt1, tz_x, tz_z);
    rinne_kappe([tz_x, y_tt0 - o_tt, tz_z], RINNE_R);  rinne_kappe([tz_x, y_tt1, tz_z], RINNE_R);
}

// ---- Hauptturm: Rinne rundum an der Traufe des Zeltdachs, ein Fallrohr an der hinteren linken Ecke (von der Gleisseite gesehen,
// also x_tow1 / y_tow[1]). Es läuft an der Turmecke hinunter und endet offen knapp über der Dachfläche des Eingangsrisalits.
RINNE_TURM = true;
tr_zax = z_lant1 - o_tow * tan(a_tow) + 0.03;
tr_x0 = x_tow0 - o_tow - 0.01;  tr_x1 = x_tow1 + o_tow + 0.01;
tr_y0 = y_tow[0] - o_tow - 0.01; tr_y1 = y_tow[1] + o_tow + 0.01;
FR_DACH_ABSTAND = 0.30;       // Rohrende über der Dachfläche
// Fallrohr vom Rinnenwinkel (xo, yo, zo) 45° zurück zur Turmecke (xw, yw), dann senkrecht bis z_end; offenes Ende
module fr_dach_ende(xo, yo, zo, xw, yw, z_end) {
    zn = zo - RINNE_R - FR_R + 0.01;
    d  = sqrt(pow(xo - xw, 2) + pow(yo - yw, 2));
    zq = zn - d;
    translate([xw, yw, z_end]) difference() {
        cylinder(r = FR_R, h = zq - z_end, $fn = 24);
        translate([0, 0, -0.01]) cylinder(r = FR_R - 0.012, h = 0.1, $fn = 24);   // offenes Ende
    }
    rohr_stueck([xw, yw, zq], [xo, yo, zn]);
    translate([xo, yo, zn - 0.03]) cylinder(r = FR_R, h = 0.03, $fn = 24);
    for (z = [z_end + 0.4 : FR_SCHELLE : zq - 0.1])
        hull() {
            translate([xw, yw, z]) cylinder(r = FR_R + 0.012, h = 0.03, $fn = 20);
            translate([x_tow1, y_tow[1], z]) cylinder(r = 0.012, h = 0.03, $fn = 8);
        }
}
module rinnen_turm() {
    rinne_gerade(tr_x0, tr_x1, tr_y0, tr_zax);  rinne_gerade(tr_x0, tr_x1, tr_y1, tr_zax);
    rinne_y(tr_y0, tr_y1, tr_x0, tr_zax);       rinne_y(tr_y0, tr_y1, tr_x1, tr_zax);
    for (x = [tr_x0, tr_x1]) for (y = [tr_y0, tr_y1]) rinne_kappe([x, y, tr_zax], RINNE_R);
    xw = x_tow1 + FR_R;  yw = y_tow[1] + FR_R;      // Rohrmantel direkt an der Turmwand (kein Abstand, besser druckbar)
    z_dach = ze_ris + (xw - x_ris0) * tan(a_ris);             // Dachfläche des Eingangsrisalits (linke Seite, am Turm)
    fr_dach_ende(tr_x1, tr_y1, tr_zax, xw, yw, z_dach + FR_DACH_ABSTAND);
}

module rinnen_neben() {
    rinnen_zwischen();
    rinnen_pavillon();
    if (ANBAU) rinnen_anbau();
    if (TUERMCHEN) rinnen_tuermchen();
    if (RINNE_TURM) rinnen_turm();
}

// Fahnenmast auf dem Dachfirst mit Knubbel am Ende. Höhe über dem Firstpunkt = Höhe der Türoberkante über Gelände.
module fahnenmast() {
    hm = z_tsp + tuer_Wi / 2;                                       // Oberkante der Türöffnung (Bogenscheitel) über Gelände
    zr = z_lant1 + (x_tow1 - x_tow0) / 2 * tan(a_tow);              // Firstpunkt des Zeltdaches
    translate([tcx, tcy, zr]) {
        color(C_MAST) {
            translate([0, 0, -0.05]) cylinder(r1 = MAST_R, r2 = 0.03, h = hm - KNAUF_R + 0.05, $fn = 24);
            for (q = [0.3, 0.62]) translate([0, 0, q * hm]) cylinder(r = 0.06, h = 0.05, $fn = 24);   // Muffen
        }
        color(C_KNAUF) translate([0, 0, hm - KNAUF_R]) sphere(r = KNAUF_R, $fn = 32);
    }
}

// ============================================================
// Turmfenster und Uhren
// Lokales Wandsystem je Turmseite: u = nach rechts (Blick von außen),
// v = nach oben, w = nach außen (w=0 ist die Außenfläche der Wand).
// Seiten: "v" vorn (Straße), "h" hinten (Gleise), "l" links, "r" rechts
// ============================================================
tcx = (x_tow0 + x_tow1) / 2;
tcy = (y_tow[0] + y_tow[1]) / 2;

function seitenmatrix(s) =
    s == "v" ? [[ 1,0, 0,tcx],[0,0,-1,y_tow[0]],[0,1,0,0],[0,0,0,1]] :
    s == "h" ? [[-1,0, 0,tcx],[0,0, 1,y_tow[1]],[0,1,0,0],[0,0,0,1]] :
    s == "l" ? [[ 0,0,-1,x_tow0],[-1,0,0,tcy],[0,1,0,0],[0,0,0,1]] :
               [[ 0,0, 1,x_tow1],[ 1,0,0,tcy],[0,1,0,0],[0,0,0,1]];

// Fensterauswahl je Seite. Rechts keine Fenster: dort stoßen Risalit-
// und Hauptdach unmittelbar an den Turm.
function fenster_liste(s) =
    s == "v" ? fenster_voll : [];     // Seiten: keine Fenster (die Laterne ersetzt das obere Paar)

module an_wand(s) { multmatrix(seitenmatrix(s)) children(); }

module arch2d(w, h) {
    translate([-w/2, 0]) square([w, h - w/2]);
    translate([0, h - w/2]) circle(d = w, $fn = 24);
}

// Öffnung durch die Wand (Rechteck, auch durch Sockel/Band nach außen)
module fenster_oeffnung(f) {
    translate([f[0] - f[2]/2, f[1], -t - eps])
        cube([f[2], f[3], t + 2*eps + pmax]);
}

// Rahmen mit Quersprosse(n) und optional Glas, etwas zurückgesetzt in der Öffnung
module fenster_fuellung(f) {
    w = f[2];  h = f[3];  fr = 0.06;  sb = 0.04;  dz = 0.06;
    translate([f[0], f[1], -0.12]) {
        color(C_TUER) {
            difference() {
                translate([-w/2, 0, 0]) cube([w, h, dz]);
                translate([-w/2 + fr, fr, -eps]) cube([w - 2*fr, h - 2*fr, dz + 2*eps]);
            }
            for (q = [1 : TURM_FENSTER_QUERSPROSSEN])
                translate([-w/2, (h - 2*fr) * q / (TURM_FENSTER_QUERSPROSSEN + 1) + fr - sb/2, 0])
                    cube([w, sb, dz * 0.8]);
        }
        if (TURM_VERGLASUNG)
            color(C_GLAS) translate([-w/2 + fr/2, fr/2, dz/2 - 0.005]) cube([w - fr, h - fr, 0.01]);
    }
}

function sturz_z0(f) = f[1] + (ceil((f[3] + f[4] + Z_FUGE) / Z_PZ - 0.001) - (f[4] > 0 ? TURM_STURZ_TIEFER : 0)) * Z_PZ;   // Unterkante Sturz: erste Reihe über Öffnung + Gewände, bei Fenstern mit Gewände um TURM_STURZ_TIEFER Reihen tiefer
// erste Reihe nach dem letzten roten Streifen (r/v) unterhalb der Reihe kmax
function rot_ende(l, kmax, i = 0, r = 0) =
    i >= len(l) ? r :
    lauf_n(l, i) >= kmax ? r :
    rot_ende(l, kmax, i + 1, (l[i][0] == "r" || l[i][0] == "v") ? lauf_n(l, i) + sch_n(l[i]) : r);

// Gewände als zurückgesetzte Nische rund um die Öffnung (links, rechts, unten und oben bis zum Sturz), mit Lagerfugen
// auf dem Nischengrund. Unten nicht in einen roten Streifen hinein. fugen = true liefert nur die Fugennuten.
module gewaende_form(f, fugen = false) {
    g  = f[4];
    k0 = round((f[1] - z_y0) / Z_PZ);                          // erste Reihe der Öffnung
    ks = round((sturz_z0(f) - z_y0) / Z_PZ);                   // erste Reihe des Sturzes
    kb = f[5] == 1 ? k0 : max(k0 - ceil(g / Z_PZ - 0.001), rot_ende(TRAUFE_SCHEMA, k0));
    z0 = tw_z(kb);  z1 = tw_z(ks) - Z_FUGE;
    u0 = f[0] - f[2]/2 - g;  bw = f[2] + 2 * g;
    if (!fugen)
        translate([u0, z0, -TURM_GEWAENDE_TIEFE]) cube([bw, z1 - z0, TURM_GEWAENDE_TIEFE + pmax + 0.02]);
    else if (ks - 2 >= kb)
        for (j = [kb : ks - 2])
            translate([u0, tw_z(j) + Z_H, -TURM_GEWAENDE_TIEFE - fd]) cube([bw, Z_FUGE, fd + eps]);
}
module turm_gewaende(fugen = false) {
    for (sd = ["v", "h", "l", "r"]) an_wand(sd)
        for (f = fenster_liste(sd)) if (f[4] > 0) gewaende_form(f, fugen);
}

// Sturz über der Öffnung: eine Schicht hochkant gestellter Läufer (Pitch Ziegeldicke + Fuge), je Seite
// mindestens ein Ziegel breiter als die Öffnung, TURM_STURZ_ZEILEN Reihen hoch, mit senkrechten Fugen
module sturz(f) {
    n  = stz_n(f[2]);  Ws = stz_w(f[2]);  bp = Z_H + Z_FUGE;
    hs = TURM_STURZ_ZEILEN * Z_PZ - Z_FUGE;
    zs0 = sturz_z0(f);                          // über der Öffnung bzw. über dem Gewände, auf einer Reihengrenze
    module fugen() {
        for (i = [1 : n - 1])
            translate([f[0] - Ws/2 + i * bp - Z_FUGE, zs0, pbog - fd]) cube([Z_FUGE, hs, fd + eps]);
    }
    color(C_STURZ) difference() {
        translate([f[0] - Ws/2, zs0, -0.02]) cube([Ws, hs, pbog + 0.02]);
        if (ZIEGEL) fugen();
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) fugen();
}

// rotes Wandstück (Ziegelreihen za..zb, u von ua bis ub) auf der Turmvorderseite, Lagerfugen je Reihe
module rot_stueck(ua, ub, za, zb) {
    rows = round((zb - za + Z_FUGE) / Z_PZ);
    module fugen() {
        for (j = rows >= 2 ? [0 : rows - 2] : [])
            translate([ua - eps, za + j * Z_PZ + Z_H, pf - fd]) cube([ub - ua + 2*eps, Z_FUGE, fd + eps]);
    }
    difference() {
        translate([ua, za, -0.1]) cube([ub - ua, zb - za, 0.1 + pf]);
        if (ZIEGEL) fugen();
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) fugen();
}

// rote Sohlbank unter dem oberen Fensterpaar: eine rote Ziegelreihe, so breit wie das Gewände, springt leicht vor
module turm_bank() {
    ov = FENSTERBANK_VORSPRUNG_MM * M / 1000;
    hw = tw_c + TURM_FENSTER_PAAR_WI / 2 + TURM_OBEN_GEWAENDE;
    an_wand("v") translate([-hw, tw_z(TURM_K_BANK), -0.1]) cube([2 * hw, Z_H, 0.1 + ov]);
}

// Rollschicht um den Turm: hochkant gestellte Läufer (Pitch Ziegeldicke + Fuge), TURM_ROLL_ZEILEN Reihen hoch, springt vor.
// Die Öffnungen der Turmfenster werden ausgespart (relevant für die Seitenfenster).
module turm_roll() {
    z0 = tw_z(TURM_K_ROLL);  h = TURM_ROLL_ZEILEN * Z_PZ - Z_FUGE;
    p  = ROLL_VORSPRUNG_MM * M / 1000;  bp = Z_H + Z_FUGE;
    wx = x_tow1 - x_tow0;  wy = y_tow[1] - y_tow[0];
    module fugen() {
        for (fl = [[m_v(x_tow0, y_tow[0]), wx], [m_h(x_tow1, y_tow[1]), wx],
                   [m_l(y_tow[1], x_tow0), wy], [m_r(y_tow[0], x_tow1), wy]])
            multmatrix(fl[0]) for (i = [1 : ceil(fl[1] / bp) - 1])
                translate([i * bp - Z_FUGE, z0, p - 2*fd]) cube([Z_FUGE, h, 2*fd + eps]);
    }
    difference() {
        translate([x_tow0 - p, y_tow[0] - p, z0]) cube([wx + 2*p, wy + 2*p, h]);
        hohlraeume();
        turm_oeffnungen();
        if (ZIEGEL) fugen();
    }
    if (ZIEGEL && FUGEN_GRAU)
        color(C_FUGE) difference() { fugen(); turm_oeffnungen(); }
}

// verschobene Streifen auf der Turmvorderseite: senkrechte Stufen und der tiefer liegende Streifen
module turm_muster() {
    an_wand("v")
        for (m = [0 : len(TURM_STREIFEN_IDX) - 1]) {
            z0 = tw_zk(m);
            z1 = z0 + sch_n(TRAUFE_SCHEMA[TURM_STREIFEN_IDX[m]]) * Z_PZ - Z_FUGE;
            zd = z0 - TURM_MUSTER_VERSCHIEBUNG * Z_PZ;
            rot_stueck(-tw_ub(m), tw_ub(m), zd, zd + (z1 - z0));   // tiefer liegender Streifen unter dem Fensterpaar
            rot_stueck( tw_ua(m),  tw_ub(m), zd, z1);               // senkrechte Stufe rechts
            rot_stueck(-tw_ub(m), -tw_ua(m), zd, z1);               // senkrechte Stufe links
        }
}

// Aussparung im normalen roten Streifen (Reihe z0..z1) auf der Turmvorderseite zwischen den Stufen
module muster_sperre(z0, z1) {
    if (TURM_MUSTER)
        for (m = [0 : len(TURM_STREIFEN_IDX) - 1])
            if (abs(z0 - tw_zk(m)) < 0.0001)
                an_wand("v") translate([-tw_ub(m), z0 - 0.01, -(t + 0.1)])
                    cube([2 * tw_ub(m), z1 - z0 + 0.02, t + 0.1 + pmax + 0.05]);
}

// Turmuhr, 10:10 Uhr: erhaben. Von außen nach innen: roter Ziegelring (Schmalseiten), schwarze Zarge, weißes Zifferblatt
module uhr() {
    r_ri  = UHR_R - UHR_RING_B;               // Innenradius des roten Rings
    r_zif = r_ri - 0.07;                      // Zifferblatt (Zarge 7 cm)
    w_ring = 0.05;                            // Ring steht 5 cm vor
    w_zar  = UHR_ERHABEN_MM * M / 1000;       // Zarge steht am weitesten vor
    w_zif  = 0.04;                            // Zifferblatt etwas hinter der Zarge
    n_ring = round(PI * (UHR_R + r_ri) / (Z_B + Z_FUGE));   // Ziegel im Ring
    module ring_fugen() {
        translate([0, 0, w_ring - fd]) linear_extrude(fd + eps)
            for (i = [0 : n_ring - 1])
                rotate(i * 360 / n_ring) translate([r_ri - 0.005, -Z_FUGE / 2]) square([UHR_RING_B + 0.01, Z_FUGE]);
    }
    translate([0, z_uhr, 0]) {
        color(C_RING) difference() {
            translate([0, 0, -0.05]) linear_extrude(w_ring + 0.05)
                difference() { circle(r = UHR_R, $fn = 96); circle(r = r_ri, $fn = 96); }
            if (ZIEGEL) ring_fugen();
        }
        if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) ring_fugen();
        color(C_DUNKEL) translate([0, 0, -0.05]) linear_extrude(w_zar + 0.05)      // Zarge
            difference() { circle(r = r_ri + 0.003, $fn = 96); circle(r = r_zif, $fn = 96); }
        color("white") translate([0, 0, -0.05]) cylinder(r = r_zif + 0.003, h = w_zif + 0.05, $fn = 96);
        color(C_DUNKEL) translate([0, 0, w_zif]) {
            for (i = [0 : 11])                                                      // Strichmarken
                rotate(i * 30) translate([-0.01, r_zif - 0.075, 0]) cube([0.02, 0.06, 0.01]);
            translate([0, 0, 0.005]) {
                rotate([0, 0, -305]) translate([-0.022, 0, 0]) cube([0.044, 0.24, 0.03]);   // Stundenzeiger
                rotate([0, 0,  -60]) translate([-0.018, 0, 0]) cube([0.036, 0.32, 0.03]);   // Minutenzeiger
            }
        }
    }
}

// Laterne: Durchbruch über beide Öffnungen und den Mittelpfosten, davor das um L_GTIEFE zurückgesetzte Gewände
module laterne_oeffnung() {
    translate([-L_WD/2, z_lat_lo, -t - eps]) cube([L_WD, z_lat_hi - z_lat_lo, t + 2*eps + pmax]);
    translate([-L_WG/2, z_lat_lo, -L_GTIEFE]) cube([L_WG, z_lat_hi - z_lat_lo, L_GTIEFE + pmax + 0.02]);
}

module turm_oeffnungen() {
    for (s = ["v", "h", "l", "r"]) an_wand(s) {
        for (f = fenster_liste(s)) fenster_oeffnung(f);
        laterne_oeffnung();
    }
}

// Lagerfugen auf dem Gewändegrund der Laterne
module laterne_fugen() {
    for (s = ["v", "h", "l", "r"]) an_wand(s)
        for (k = [TURM_K_L0 : TURM_K_KAPPE - 1], ua = [-L_WG/2, L_WD/2])
            translate([ua, tw_z(k) + Z_H, -L_GTIEFE - fd]) cube([L_GEW, Z_FUGE, fd + eps]);
}

// Mittelpfosten je Seite: 1 Läufer im Quadrat, um L_GTIEFE zurückgesetzt, rote Zwischenreihe und rote Kappe wie die Pfeiler
module turm_pfosten() {
    module pfugen() {
        for (k = [TURM_K_L0 : TURM_K_KAPPE - 1])
            translate([-L_POST/2 - eps, tw_z(k) + Z_H, -L_GTIEFE - fd]) cube([L_POST + 2*eps, Z_FUGE, fd + eps]);
    }
    for (s = ["v", "h", "l", "r"]) an_wand(s) {
        color(C_KLINKER) difference() {
            translate([-L_POST/2, z_lat_lo, -L_GTIEFE - L_POST]) cube([L_POST, z_lat_hi - z_lat_lo, L_POST]);
            if (ZIEGEL) pfugen();
        }
        if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) pfugen();
        for (k = [TURM_K_LROT, TURM_K_KAPPE])
            color(C_BAND) translate([-L_POST/2, tw_z(k), -L_GTIEFE - L_POST]) cube([L_POST, Z_H, L_POST + (k == TURM_K_KAPPE ? TURM_KAPPE_VORSPRUNG : pf)]);
        color(C_BAND) translate([-L_POST/2, tw_z(TURM_K_KAPPE - 1) + Z_H / 2, -L_GTIEFE - L_POST]) cube([L_POST, Z_H / 2, L_POST + pf]);   // halbhohe rote Schicht
    }
}

// Grüner Querbalken als oberer Abschluss jeder einzelnen Fensterhöhle der Laterne (zwei je Seite): sitzt im zurückgesetzten
// Gewände, schließt links und rechts an die Steine (Gewände bzw. Mittelpfosten) an und reicht oben in den Dachkasten (turm_holz)
TURM_QUERBALKEN  = true;
TURM_QUERBALKEN_H = 0.20;     // Höhe des Querbalkens unter der Oberkante der Öffnung [m]
TURM_QUERBALKEN_T = 0.20;     // Tiefe in die Wand [m]
module turm_querbalken() {
    for (s = ["v", "h", "l", "r"]) an_wand(s)
        for (m = [-1, 1])
            color(C_HOLZ) translate([m < 0 ? -L_WD/2 - eps : L_POST/2 - eps, z_lat_hi - TURM_QUERBALKEN_H, -L_GTIEFE - TURM_QUERBALKEN_T])
                cube([L_OEFF + 2*eps, TURM_QUERBALKEN_H + 0.02, TURM_QUERBALKEN_T + 0.01]);
}

module turm_fuellung() {
    for (s = ["v", "h", "l", "r"]) an_wand(s) {
        if (s == "v") uhr();                       // Turmuhr nur an der Straßenseite
        for (f = fenster_liste(s)) { fenster_fuellung(f); sturz(f); }
    }
}

// ============================================================
// Ziegelstruktur: Fugen werden als flache Nuten (Tiefe FUGENTIEFE_MM)
// aus den Außenflächen geschnitten. Reichsformat 250 x 120 x 65 mm,
// Fugen 10 mm => im Modell 2,87 x 0,75 mm Läufer, Fugenbreite 0,115 mm.
// Alle Flächen beginnen bei z = 0, die Schichten laufen also überall
// auf gleicher Höhe.
// ============================================================

// Fugen einer Fläche als EIN 2D-Objekt: ein einziges polygon() aus vielen
// disjunkten Rechtecken, das als Liste berechnet wird (keine Modul-Instanzen
// je Ziegel). Lagerfugen = eine Leiste je Schicht über dem Ziegel,
// Stoßfugen = senkrechte Leisten innerhalb der Schichthöhe (beides disjunkt).
function stossfugen_x(j, W) =   // j = globale Schichtnummer (bestimmt Läufer-/Binderschicht und Versatz)
    let(pb        = Z_B + Z_FUGE,
        laeufer   = [for (x = [Z_L : Z_PX : W]) x],                  // Läuferschicht
        laeufer_v = [for (x = [Z_L - Z_PX/2 : Z_PX : W]) x],         // Läuferschicht, um einen halben Stein versetzt
        kopf      = [for (x = [Z_B - pb/2 : pb : W]) x])             // Binderschicht
    VERBAND == "laeufer" ? (j % 2 == 0 ? laeufer : laeufer_v)
  : VERBAND == "kreuz"   ? (j % 2 == 1 ? kopf : (j % 4 == 0 ? laeufer : laeufer_v))   // Läufer, Binder, Läufer (versetzt), Binder
  :                        (j % 2 == 0 ? laeufer : kopf);                              // Blockverband

function fugen_rects(W, Hh, stoss, j0 = 0) = [
    for (j = [0 : ceil(Hh / Z_PZ) - 1]) each concat(
        [[0, j*Z_PZ + Z_H, W, (j + 1)*Z_PZ]],                         // Lagerfuge
        stoss ? [for (x = stossfugen_x(j + j0, W))
                    [x, j*Z_PZ, x + Z_FUGE, j*Z_PZ + Z_H]] : []        // Stoßfugen
    )
];

module fugen2d(W, Hh, stoss, j0 = 0) {
    R   = fugen_rects(W, Hh, stoss, j0);
    pts = [for (r = R) each [[r[0], r[1]], [r[2], r[1]], [r[2], r[3]], [r[0], r[3]]]];
    pth = [for (k = [0 : len(R) - 1]) [4*k, 4*k + 1, 4*k + 2, 4*k + 3]];
    polygon(pts, pth);
}

// Flächensysteme (u nach rechts bei Blick von außen, v nach oben, w nach außen)
function m_v(x0, y) = [[ 1,0, 0,x0],[0,0,-1, y],[0,1,0,0],[0,0,0,1]];   // Vorderseite (außen -y)
function m_h(x1, y) = [[-1,0, 0,x1],[0,0, 1, y],[0,1,0,0],[0,0,0,1]];   // Rückseite   (außen +y)
function m_l(y1, x) = [[ 0,0,-1, x],[-1,0,0,y1],[0,1,0,0],[0,0,0,1]];   // links       (außen -x)
function m_r(y0, x) = [[ 0,0, 1, x],[ 1,0,0,y0],[0,1,0,0],[0,0,0,1]];   // rechts      (außen +x)

function rechteck(W, H)      = [[0,0],[W,0],[W,H],[0,H]];
function giebel(W, ze, zr)   = [[0,0],[W,0],[W,ze],[W/2,zr],[0,ze]];
// Giebel, dessen linke a0 Meter (hinter dem Turm) fehlen: sichtbarer Teil der Breite W, volle Breite Wf, Spitze bei Wf/2 - a0
function giebel_ab(W, ze, zr, a0, Wf) = [[0,0],[W,0],[W,ze],[Wf/2 - a0, zr],[0, ze + a0 / (Wf/2) * (zr - ze)]];

// Wandflächen: Fugen (Nuten) bzw. Zahnfries, je Fläche ein Körper.
// $teil: "mauer" = gelbes Mauerwerk, "band" = Fugen eines roten Bandes
// ($bz0..$bz1 Höhe, $bp Vorsprung, $bj0 Schichtnummer), "zahn" = Zahnfries
// ann = true: Fläche gehört zum Anbau; zu/ju = Beginn des gelben Mauerwerks (Höhe, Schichtnummer). Ohne rotes Sockelband
// (ANN_BAND = false) beginnt das gelbe Mauerwerk des Anbaus direkt über dem Betonsockel.
module fuge(mat, W, pts, zahn = true, stoss = false, zwb = false, ttb = false, pvb = false, ann = false, zu = z_y0, ju = nb, bandfrei = false) {   // zahn=false: kein horizontaler Zahnfries auf dieser Fläche
    Hm = max([for (p = pts) p[1]]);       // zwb = true: Fläche gehört zum Zwischengebäude (siehe $zw)
    hw = pts[2][1];                       // Traufhöhe der Wand (ohne Giebelspitze)
    if (($zw == "mit" || ($zw == "nur" && zwb) || ($zw == "ohne" && !zwb)) && ($tt == "mit" || !ttb))
    multmatrix(mat) {
        if ($teil == "mauer") {
            // gelbes Mauerwerk oberhalb des Sockelbandes
            translate([0, 0, -fd]) linear_extrude(fd + eps)
                intersection() {
                    polygon(pts);
                    translate([0, zu]) square([W, Hm - zu + 1]);
                    translate([0, zu]) fugen2d(W, Hm - zu, stoss, ju);
                }
        } else if ($teil == "band" && !($gl && bandfrei) && $bz0 < hw && (!ann || ($bz0 < z_y0 ? ANN_BAND : ANN_STREIFEN))) {
            translate([0, 0, $bp - fd]) linear_extrude(fd + eps)
                intersection() {
                    translate([0, $bz0]) square([W, min($bz1, hw) - $bz0]);
                    translate([0, $bz0]) fugen2d(W, $bz1 - $bz0, stoss, $bj0);
                }
        } else if ($teil == "zahn" && zahn && $bz1 <= hw && ($pav != "nur" || pvb)) {
            zahnreihe(W, $bz0, $bz1);
        }
    }
}

// Zahnfries: aufrecht stehende Ziegel (Höhe z0..z1), 45° zur Wand gewinkelt,
// wie Lamellen mit Fuge dazwischen. Grundriss je Ziegel: Z_B x Z_H, gedreht um ZAHN_WINKEL.
module zahnreihe(W, z0, z1, grund = false) {
    a   = ZAHN_WINKEL;
    e1  = [cos(a), sin(a)];            // Längsrichtung des Ziegels (Grundriss u,w)
    e2  = [-sin(a), cos(a)];           // Querrichtung
    hl  = Z_B / 2;  hb = Z_H / 2;
    ext = hl * sin(a) + hb * cos(a);   // halbe Ausdehnung senkrecht zur Wand
    hu  = hl * cos(a) + hb * sin(a);   // halbe Ausdehnung entlang der Wand
    T   = ZAHN_TEILUNG;
    n   = floor((W - 2*hu) / T) + 1;
    u0  = (W - (n - 1) * T) / 2;
    wc  = ZAHN_TIEFE - ext;            // Mittelpunkt: Kanten stehen ZAHN_TIEFE vor, Rest in der Wand
    pts = [for (i = [0 : n - 1])
              let(c = [u0 + i*T, wc]) each [
                  c - hl*e1 - hb*e2, c + hl*e1 - hb*e2,
                  c + hl*e1 + hb*e2, c - hl*e1 + hb*e2 ]];
    pth = [for (k = [0 : n - 1]) [4*k, 4*k + 1, 4*k + 2, 4*k + 3]];
    // Polygon in (u,w) -> lokales System (u,v,w)
    multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
        translate([0, 0, z0]) linear_extrude(z1 - z0) {
            polygon(pts, pth);
            if (grund) translate([0, -0.003]) square([W, pf + 0.003]);   // roter Grund hinter den Ziegeln
        }
}

// Sockel / Bänder: alle Baukörper um p nach außen vergrößert, bis zur jeweiligen Traufe
bloecke_liste = [
    [x_ann0, x_ann1, y_anns,    y_ann[1],  h_ann],      // 0 Anbau, linker Teil
    [x_pav0, x_pav1, y_pav[0],  y_pav[1],  h_pav],
    [x_pav1, x_mb1,  y_wing[0], y_wing[1], h_wing],
    [x_tow1, x_end,  y_main[0], y_main[1], h_main],
    [x_ris0, x_ris1, y_ris[0],  y_ris[1],  h_ris],
    [x_tow0, x_tow1, y_tow[0],  y_tow[1],  h_shaft],
    [x_lw0,  x_tow1, y_main[0], y_main[1], h_main],     // 6 linker Flügel
    each (TUERMCHEN ? [[x_tt0, x_tt1, y_tt0, y_tt1, h_tt]] : []),   // 7 Türmchen
    each (ANBAU ? [[x_ann1, x_pav0, y_ann[0], y_ann[1], h_ann_h]] : []),   // 8 Anbau, vorderer Teil
    each (RIS_HINTEN ? [[ris_h_x0, ris_h_x1, y_rh[0], y_rh[1], h_ris]] : [])   // zuletzt: gleisseitiger Mittelrisalit
];
RIS_H_IDX = RIS_HINTEN ? len(bloecke_liste) - 1 : -1;   // Index des gleisseitigen Risalits (gehört zum Hauptgebäude)
// Blockindizes: 0 Anbau, 1 Pavillon, 2 Zwischengebäude, 3 rechter Flügel, 4 Mittelrisalit, 5 Turm, 6 linker Flügel, 7 Türmchen
// (Hauptgebäude = 3, 4, 5, 6, 7)
ZW_AUSSER = [for (i = [0 : len(bloecke_liste) - 1]) if (i != ZW_IDX) i];   // alle Blöcke außer dem Zwischengebäude
function enthalten(l, x) = len([for (e = l) if (e == x) 1]) > 0;
// kuerz = true: der rechte Flügel (Index 3) endet in x knapp innerhalb der Giebelwände, damit dort kein
// waagerechtes rotes Band an der Außenfläche erscheint (Vorderseite und Rückseite bleiben unverändert)
$gl = false;   // true: rote Reihen am linken Giebelende des linken Flügels weglassen (wird beim Aufruf der Bänder gesetzt)
module vorsprung(p, z0, z1, ausser = [], kuerz = false) {
    for (i = [0 : len(bloecke_liste) - 1])
        let(b = bloecke_liste[i],
            kl = ((kuerz || $gl) && i == 6) ? 2*p + 0.001 : 0,      // linker Flügel: nur das linke (freie) Giebelende kürzen
            kr = (kuerz && i == 3) ? 2*p + 0.001 : 0)      // rechter Flügel: nur das rechte (freie) Giebelende kürzen
            if (!enthalten(ausser, i) && min(z1, b[4]) > z0 && (i != 0 || ANBAU))
                translate([b[0] - p + kl, b[2] - p, z0])
                    cube([b[1] - b[0] + 2*p - kl - kr, b[3] - b[2] + 2*p, min(z1, b[4]) - z0]);
}

// Ein rotes Band (Ziegelschichten z0..z1), springt um p vor, Fugen optional
module band(z0, z1, p, j0 = 0, fugen = true, ausser = [], kuerz = false) {
    difference() {
        vorsprung(p, z0, z1, ausser, kuerz);
        hohlraeume();
        oeffnungen_alle();
        muster_sperre(z0, z1);
        if (ZIEGEL && fugen)
            fugen_alle($teil = "band", $bz0 = z0, $bz1 = z1, $bp = p, $bj0 = j0);
    }
    if (ZIEGEL && FUGEN_GRAU && fugen)                          // Fugenfüllung grau
        color(C_FUGE) difference() {
            fugen_alle($teil = "band", $bz0 = z0, $bz1 = z1, $bp = p, $bj0 = j0);
            oeffnungen_alle();
        }
}

// Grüner Dachkasten des Hauptgebäudes: Platten flach unter der Dachhaut der Traufen (parallel zur Dachneigung), dazu die Füllung
// unter dem Dach. Die Giebelschrägen übernimmt giebel_kasten_alle().
// Eine Traufplatte im lokalen System: x = entlang der Traufe, y = Abstand von der Wand (nach außen), z = Höhe.
// Oberkante = Unterseite der Dachhaut, Unterkante liegt an der Wand genau auf dem Mauerwerk (Zahnfries), Ende senkrecht zur Dachfläche.
module dk_platte(L, o, a, h, ze) {
    ue = o - DK_G_UE;  c = cos(a);  s = sin(a);
    zt = ze - td + 0.004;                    // Oberkante an der Wand (knapp in die Dachhaut hinein)
    V  = zt - (h - 0.002);                   // senkrechte Höhe der Platte an der Wand
    d0 = -DK_EIN;
    rotate([90, 0, 90]) linear_extrude(L)
        polygon([[d0, zt - d0 * tan(a)], [ue, zt - ue * tan(a)],
                 [ue - V * c * s, zt - ue * tan(a) - V * c * c], [d0, h - 0.002 - d0 * tan(a)]]);
}
// Traufe parallel x bei y; nach = -1: Dach fällt nach -y (Vorderseite), +1: nach +y (Rückseite)
module dk_traufe_x(xa, xb, y, nach, a, o, h, ze) {
    translate([xa, y, 0]) {
        if (nach < 0) mirror([0, 1, 0]) dk_platte(xb - xa, o, a, h, ze);
        else dk_platte(xb - xa, o, a, h, ze);
    }
}
module dk_y(L, o, a, h, ze) {   // Platte entlang y: lokales System der Platte mit vertauschten Achsen x <-> y
    multmatrix([[0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 1, 0], [0, 0, 0, 1]]) dk_platte(L, o, a, h, ze);
}
// Traufe parallel y bei x; nach = +1: Dach fällt nach +x (rechte Seite), -1: nach -x (linke Seite)
module dk_traufe_y(ya, yb, x, nach, a, o, h, ze) {
    translate([x, ya, 0]) {
        if (nach < 0) mirror([1, 0, 0]) dk_y(yb - ya, o, a, h, ze);
        else dk_y(yb - ya, o, a, h, ze);
    }
}
// Ecke Flügeltraufe / Risalitseite: die Dachkehle liegt über der Linie von der Wandecke c zum Rinnenwinkel p; die beiden Platten
// stoßen dort auf Gehrung aufeinander (wie im Foto). Koordinaten dx/dy = Abstand von der Wandecke nach außen (dx: von der
// Risalitwand weg, dy: von der Flügelwand weg), sx/sy = Richtung in x bzw. y.
module dk_ecke_clip(cx, cy, sx, sy, teil) {
    m  = o_main / o_ris_t;
    pk = teil == "fluegel"
         ? [[0, -1], [0, 0], [o_ris_t, o_main], [o_ris_t, 5], [60, 5], [60, -1]]
         : [[-1, -0.3], [0, -0.3], [0, 0], [o_ris_t + 1, m * (o_ris_t + 1)], [o_ris_t + 1, 8], [-1, 8]];
    intersection() {
        children();
        translate([0, 0, -10]) linear_extrude(100) polygon([for (p = pk) [cx + sx * p[0], cy + sy * p[1]]]);
    }
}
module dk_clip_plan(pts) {   // beschneidet die Kinder auf einen Grundriss-Polygonzug (Gehrung an den Walmgraten des Pavillons)
    intersection() {
        children();
        translate([0, 0, -10]) linear_extrude(100) polygon(pts);
    }
}
DK_ECKE = o_main_end - DK_G_UE;   // Traufplatten reichen an den Giebelwänden so weit über die Wandflucht hinaus (bis unter die Dachecke), sonst bleibt dort eine Lücke
module dachkasten() {
    color(C_HOLZ) {
        // Flügel vorn: links vom Turm; rechts vom Risalit (mit Gehrung an der Risalitseite). Vor dem Risalit selbst keine Platte.
        dk_traufe_x(x_lw0 - DK_ECKE, x_tow0, y_main[0], -1, a_main, o_main, h_main, ze_main);
        dk_ecke_clip(x_ris1, y_main[0], 1, -1, "fluegel")
            dk_traufe_x(x_ris1, x_end + DK_ECKE, y_main[0], -1, a_main, o_main, h_main, ze_main);
        dk_ecke_clip(x_ris1, y_main[0], 1, -1, "risalit")
            dk_traufe_y(y_ris[0] - (o_ris - DK_G_UE), y_main[0] + 0.05, x_ris1, 1, a_ris, o_ris_t, h_ris, ze_ris);   // reicht vorn bis unter die Dachecke (Giebelüberstand), damit dort keine Lücke zwischen Giebelkasten und Seitenplatte bleibt; linke Seite liegt hinter dem Turm
        // Flügel hinten und gleisseitiger Risalit
        if (RIS_HINTEN) {
            dk_ecke_clip(ris_h_x0, y_main[1], -1, 1, "fluegel")
                dk_traufe_x(x_lw0 - DK_ECKE, ris_h_x0, y_main[1], 1, a_main, o_main, h_main, ze_main);
            dk_ecke_clip(ris_h_x1, y_main[1], 1, 1, "fluegel")
                dk_traufe_x(ris_h_x1, x_end + DK_ECKE, y_main[1], 1, a_main, o_main, h_main, ze_main);
            dk_ecke_clip(ris_h_x0, y_main[1], -1, 1, "risalit")
                dk_traufe_y(y_main[1] - 0.05, y_rh[1] + (o_ris - DK_G_UE), ris_h_x0, -1, a_ris_h, o_ris_t, h_ris, ze_ris);   // bis unter die Dachecke (Giebelüberstand)
            dk_ecke_clip(ris_h_x1, y_main[1], 1, 1, "risalit")
                dk_traufe_y(y_main[1] - 0.05, y_rh[1] + (o_ris - DK_G_UE), ris_h_x1,  1, a_ris_h, o_ris_t, h_ris, ze_ris);   // bis unter die Dachecke (Giebelüberstand)
        } else
            dk_traufe_x(x_lw0 - DK_ECKE, x_end + DK_ECKE, y_main[1], 1, a_main, o_main, h_main, ze_main);

    }
    // Zwischengebäude und Pavillon: brauner Dachkasten (nur Hauptgebäude und Turm sind grün)
    color(C_DK_ANN) {
        // Zwischengebäude: die beiden Traufen (vorn und hinten), Platte sitzt auf dem Zahnfries (Oberkante h_zw)
        dk_traufe_x(x_pav1, x_mb1, y_wing[0], -1, a_wing, o_wing, h_wing - td - DKP_ZW, h_wing);
        dk_traufe_x(x_pav1, x_mb1, y_wing[1],  1, a_wing, o_wing, h_wing - td - DKP_ZW, h_wing);

        // Pavillon (Walmdach): lange Traufen links/rechts (a_pav) und die beiden Walmseiten vorn/hinten (a_pav_e). An den Ecken stoßen
        // die Platten auf Gehrung entlang der Walmgrate (Grat verläuft von der Wandecke zur Dachecke).
        pav_h0 = h_pav - td - DKP_PAV;                 // Unterkante der Platten an der Wand
        pav_oe = o_pav * tan(a_pav) / tan(a_pav_e);    // Überstand der Walmseiten (wie in walm_y)
        pav_dm = o_pav + 1;
        pav_tk = tan(a_pav) / tan(a_pav_e);
        // links (x_pav0) und rechts (x_pav1): Grat-Gehrung in y
        for (sd = [-1, 1]) {
            xw = sd < 0 ? x_pav0 : x_pav1;
            dk_clip_plan([[xw - sd, y_pav[0]], [xw, y_pav[0]], [xw + sd * pav_dm, y_pav[0] - pav_dm * pav_tk],
                          [xw + sd * pav_dm, y_pav[1] + pav_dm * pav_tk], [xw, y_pav[1]], [xw - sd, y_pav[1]]])
                dk_traufe_y(y_pav[0] - pav_oe, y_pav[1] + pav_oe, xw, sd, a_pav, o_pav, pav_h0, h_pav);
        }
        // vorn (y_pav[0]) und hinten (y_pav[1]): Grat-Gehrung in x
        for (sd = [-1, 1]) {
            yw = sd < 0 ? y_pav[0] : y_pav[1];
            dk_clip_plan([[x_pav0, yw - sd], [x_pav0, yw], [x_pav0 - pav_dm / pav_tk, yw + sd * pav_dm],
                          [x_pav1 + pav_dm / pav_tk, yw + sd * pav_dm], [x_pav1, yw], [x_pav1, yw - sd]])
                dk_traufe_x(x_pav0 - o_pav, x_pav1 + o_pav, yw, sd, a_pav_e, pav_oe, pav_h0, h_pav);
        }
    }
    // Füllung unter dem Dach (schließt das Mauerwerk bis zur Dachhaut), wandbündig und ausdrücklich in Ziegelfarbe
    for (it = [3, 6, 4, RIS_H_IDX]) if (it >= 0) {
        b = bloecke_liste[it];  z0 = b[4] - 0.002;  hk = DK_H - td/2 + 0.002;
        color(C_KLINKER) translate([b[0], b[2], z0]) cube([b[1] - b[0], b[3] - b[2], hk]);
    }
}

// Kasten entlang der Giebelschrägen (Ortgang): sitzt direkt unter der Dachhaut, darunter der Zahnfries
module giebel_kasten_alle() {
    $gk = true;
    zahn_giebel();
    if (RIS_HINTEN) zahn_giebel_ris_h();
    if (ZAHN_GIEBEL_HAUPT) zahn_giebel_haupt();
}

// Schräger Läufer (rote Reihe parallel zur Dachkante) im lokalen Friesystem der Giebel (u entlang, v senkrecht dazu)
module laeufer_schraeg(L, v0, v1) {
    multmatrix([[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1]])
        translate([0, 0, v0]) linear_extrude(v1 - v0) translate([0, -0.003]) square([L, pf + 0.003]);
}
// Giebel-Zahnfries wie am Traufgesims: abschließender Läufer (oben), senkrechter Zahn, Läufer (unten); v = 0 ist die Oberkante
$gk = false;   // intern: true = nur der grüne Kasten entlang der Giebelschräge, false = Zahnfries
// ex: Verlängerung des Frieses über das untere Ende hinaus. Die Stirnfläche steht senkrecht zur Dachschräge und lässt an der Traufecke
// einen Keil offen; der Fries wird deshalb um ex verlängert und von der aufrufenden Stelle an der Wandecke abgeschnitten (gbegrenzt).
GIEBEL_FRIES_EX = 0.5;   // Verlängerung des Giebel-Zahnfrieses nach unten [m] (reicht für beide Dachneigungen)
module fries_schraeg(L, h, vs = DACHKASTEN ? DK_G : 0, ue = 0, ex = 0) {   // vs: Versatz nach unten (Platz für den Kasten), ue: Überstand
    if ($gk)                                   // grüner Kasten: Platte direkt unter der Dachhaut, parallel zur Dachfläche, von der Wand bis kurz vor die Dachkante
        translate([0, -DK_G, -0.02]) cube([L, DK_G + 0.004, ue + 0.02]);
    else translate([-ex, -vs, 0]) {           // Fries darunter
        laeufer_schraeg(L + ex, -Z_H, 0);
        zahnreihe(L + ex, -Z_H - Z_FUGE - h, -Z_H - Z_FUGE, true);
        laeufer_schraeg(L + ex, -2*Z_H - 2*Z_FUGE - h, -Z_H - 2*Z_FUGE - h);
    }
}
// Begrenzt den Zahnfries (nicht den Kasten) auf die Wandbreite: x0..x1 bzw. y0..y1 (achse "x" oder "y")
module gbegrenzt(achse, a0, a1) {
    if ($gk) children();
    else intersection() {
        children();
        if (achse == "x") translate([a0, -100, -10]) cube([a1 - a0, 300, 200]);
        else translate([-100, a0, -10]) cube([300, a1 - a0, 200]);
    }
}

// Zahnfries unter dem Dach des Risalitgiebels: folgt beiden Ortgängen
module zahn_giebel() {
    W  = x_ris1 - x_ris0;                       // volle Giebelbreite (Giebelachse = Mitte, auch hinter dem Turm)
    ca = cos(a_ris);  sa = sin(a_ris);
    L  = (W / 2) / ca;                          // Länge einer Giebelseite
    h  = ZAHN_SCHICHTEN * Z_PZ - Z_FUGE;        // Höhe des Frieses
    v0 = ze_ris - td - 0.01;                     // Oberkante knapp unter der Dachunterseite
    intersection() {
        multmatrix(m_v(x_ris0, y_ris[0])) {
            multmatrix([[ ca, -sa, 0, 0], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
                fries_schraeg(L, h, ue = o_ris - DK_G_UE, ex = GIEBEL_FRIES_EX);          // linke Giebelseite
            multmatrix([[-ca,  sa, 0, W], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
                fries_schraeg(L, h, ue = o_ris - DK_G_UE, ex = GIEBEL_FRIES_EX);          // rechte Giebelseite
        }
        translate([x_tow1, -50, -10]) cube([x_ris1 - x_tow1, 100, 200]);   // links: der Teil hinter dem Turm (x < x_tow1) entfällt; rechts endet der Fries an der Risalitecke
    }
}

// Zahnfries unter dem Dach des gleisseitigen Risalitgiebels (wie zahn_giebel an der Straßenseite)
module zahn_giebel_ris_h() {
    W  = ris_h_w;
    ca = cos(a_ris_h);  sa = sin(a_ris_h);
    L  = (W / 2) / ca;
    h  = ZAHN_SCHICHTEN * Z_PZ - Z_FUGE;
    v0 = ze_ris - td - 0.01;
    gbegrenzt("x", ris_h_x0, ris_h_x1)
    multmatrix(m_h(ris_h_x1, y_rh[1])) {
        multmatrix([[ ca, -sa, 0, 0], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]]) fries_schraeg(L, h, ue = o_ris - DK_G_UE, ex = GIEBEL_FRIES_EX);
        multmatrix([[-ca,  sa, 0, W], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]]) fries_schraeg(L, h, ue = o_ris - DK_G_UE, ex = GIEBEL_FRIES_EX);
    }
}

// Zahnfries unter dem Dach der freien Giebelwände von rechtem und linkem Flügel (x_end und x_lw0): folgt beiden Dachkanten
module zahn_giebel_haupt() {
    W  = y_main[1] - y_main[0];
    ca = cos(a_main);  sa = sin(a_main);
    L  = (W / 2) / ca;                          // Länge einer Giebelseite
    h  = ZAHN_SCHICHTEN * Z_PZ - Z_FUGE;        // Höhe des Frieses
    v0 = ze_main - td - 0.01;                    // Oberkante knapp unter der Dachunterseite
    // jede Giebelwand einzeln, ohne Schleifenvariable (wie zahn_giebel am Risalit), Begrenzung auf die Wandbreite in y
    gbegrenzt("y", y_main[0], y_main[1])
    multmatrix(m_r(y_main[0], x_end)) {         // rechte Giebelwand (außen +x)
        multmatrix([[ ca, -sa, 0, 0], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
            fries_schraeg(L, h, ue = o_main_end - DK_G_UE, ex = GIEBEL_FRIES_EX);
        multmatrix([[-ca,  sa, 0, W], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
            fries_schraeg(L, h, ue = o_main_end - DK_G_UE, ex = GIEBEL_FRIES_EX);
    }
    gbegrenzt("y", y_main[0], y_main[1])
    multmatrix(m_l(y_main[1], x_lw0)) {         // linke Giebelwand des linken Flügels (außen -x)
        multmatrix([[ ca, -sa, 0, 0], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
            fries_schraeg(L, h, ue = o_main_end - DK_G_UE, ex = GIEBEL_FRIES_EX);
        multmatrix([[-ca,  sa, 0, W], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]])
            fries_schraeg(L, h, ue = o_main_end - DK_G_UE, ex = GIEBEL_FRIES_EX);
    }
}

// Zahnfries-Reihe: waagerecht an den Wänden (außer Turm und Risalit),
// am Risalit stattdessen unter dem Dach entlang der Giebelschrägen
module zahnfries(z0, z1, j0) {
    band(z0, z1, pf, j0, false, [4, 5, ZW_IDX, RIS_H_IDX], ZAHN_GIEBEL_HAUPT);   // bündiger roter Grund, ohne Mittelrisalite/Turm/Zwischengebäude
    fugen_alle($teil = "zahn", $bz0 = z0, $bz1 = z1, $zw = "ohne");
    // Giebelfriese folgen dem Dachkasten der Giebel bis in die Wandecke und schließen dort an den waagerechten Zahnfries an
    // (früher wurden sie unterhalb von ze_main - td/2 abgeschnitten, das ließ an der Traufecke eine Lücke)
    zahn_giebel();
    if (RIS_HINTEN) zahn_giebel_ris_h();
    if (ZAHN_GIEBEL_HAUPT) zahn_giebel_haupt();
    if (RIS_HINTEN) {            // gleisseitiger Risalit: an den Seitenwänden waagerecht

        multmatrix(m_r(y_main[1], ris_h_x1)) zahnreihe(RIS_HINTEN_TIEFE, z0, z1, true);
        multmatrix(m_l(y_rh[1], ris_h_x0))   zahnreihe(RIS_HINTEN_TIEFE, z0, z1, true);
    }
    // kurzes Wandstück rechts am Risalit (zwischen Risalitfront und Flügelfront): waagerechter
    // Zahnfries mit rotem Grund, schließt an den Zahnfries des rechten Flügels an
    multmatrix(m_r(y_ris[0], x_ris1)) zahnreihe(y_main[0] - y_ris[0], z0, z1, true);
}

module fugen_alle() {
    Wm      = y_main[1] - y_main[0];
    Wr      = x_ris1 - x_tow1;                          // sichtbare Breite des Risalits (rechts vom Turm)
    Wf      = x_ris1 - x_ris0;                          // volle Breite (inkl. 0,97 m hinter dem Turm)
    zr_ris  = ze_ris  + Wf / 2 * tan(a_ris)  - td/2;   // Giebelspitze (Mauerwerk), Giebelachse = Mitte der vollen Breite
    zr_main = ze_main + Wm / 2 * tan(a_main) - td/2;

    // Anbau links: linker (zurückspringender) Teil und vorderer Teil (die Wandköpfe folgen der Dachebene)
    if (ANBAU) {
        Wa_l = x_ann1 - x_ann0;               // Breite des linken Teils
        Wa_v = x_pav0 - x_ann1;               // Breite des vorderen Teils
        Da_l = y_ann[1] - y_anns;             // Tiefe des linken Teils
        Da_s = y_anns - y_ann[0];             // Sprungwand des vorderen Teils (außen -x)
        Da_v = y_ann[1] - y_ann[0];           // Tiefe des vorderen Teils
        fuge(m_v(x_ann0, y_anns), Wa_l, [[0, 0], [Wa_l, 0], [Wa_l, h_ann_h], [0, h_ann]], stoss = STOSS_V, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
        fuge(m_l(y_ann[1], x_ann0), Da_l, rechteck(Da_l, h_ann), stoss = STOSS_REST, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
        fuge(m_h(x_ann1, y_ann[1]), Wa_l, [[0, 0], [Wa_l, 0], [Wa_l, h_ann], [0, h_ann_h]], stoss = STOSS_REST, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
        fuge(m_v(x_ann1, y_ann[0]), Wa_v, [[0, 0], [Wa_v, 0], [Wa_v, ann_z(x_pav0)], [0, h_ann_h]], stoss = STOSS_V, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
        fuge(m_l(y_anns, x_ann1), Da_s, rechteck(Da_s, h_ann_h), stoss = STOSS_REST, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
        fuge(m_h(x_pav0, y_ann[1]), Wa_v, [[0, 0], [Wa_v, 0], [Wa_v, h_ann_h], [0, ann_z(x_pav0)]], stoss = STOSS_REST, ann = true, zu = ANN_BAND ? z_y0 : zs, ju = ANN_BAND ? nb : 0);
    }

    // Pavillon
    fuge(m_v(x_pav0, y_pav[0]), x_pav1 - x_pav0, rechteck(x_pav1 - x_pav0, h_pav), stoss = STOSS_V, ttb = true, pvb = true);
    fuge(m_h(x_pav1, y_pav[1]), x_pav1 - x_pav0, rechteck(x_pav1 - x_pav0, h_pav), stoss = STOSS_REST, ttb = true, pvb = true);
    fuge(m_l(y_pav[1], x_pav0), y_pav[1] - y_pav[0], rechteck(y_pav[1] - y_pav[0], h_pav), stoss = STOSS_REST, ttb = true, pvb = true);
    fuge(m_r(y_pav[0], x_pav1), y_pav[1] - y_pav[0], rechteck(y_pav[1] - y_pav[0], h_pav), stoss = STOSS_REST, ttb = true, pvb = true);

    // Zwischengebäude
    fuge(m_v(x_pav1, y_wing[0]), x_mb1 - x_pav1, rechteck(x_mb1 - x_pav1, h_wing), stoss = STOSS_V, zwb = true);
    fuge(m_h(x_mb1, y_wing[1]), x_mb1 - x_pav1, rechteck(x_mb1 - x_pav1, h_wing), stoss = STOSS_REST, zwb = true);
    // linker Giebel des Zwischengebäudes (zum Pavillon): Ziegel wie am Hauptgebäude, Zahnfries folgt der Dachkante (zahn_giebel_zw)
    fuge(m_l(y_wing[1], x_pav1), y_wing[1] - y_wing[0],
         giebel(y_wing[1] - y_wing[0], h_wing, h_wing + (y_wing[1] - y_wing[0]) / 2 * tan(a_wing) - td/2),
         false, stoss = STOSS_REST, zwb = true);

    // Turm (4 Seiten bis zum Gesims)
    fuge(m_v(x_tow0, y_tow[0]), x_tow1 - x_tow0, rechteck(x_tow1 - x_tow0, h_shaft), false, stoss = STOSS_V);
    fuge(m_h(x_tow1, y_tow[1]), x_tow1 - x_tow0, rechteck(x_tow1 - x_tow0, h_shaft), false, stoss = STOSS_REST);
    fuge(m_l(y_tow[1], x_tow0), y_tow[1] - y_tow[0], rechteck(y_tow[1] - y_tow[0], h_shaft), false, stoss = STOSS_REST);
    fuge(m_r(y_tow[0], x_tow1), y_tow[1] - y_tow[0], rechteck(y_tow[1] - y_tow[0], h_shaft), false, stoss = STOSS_REST);

    // Mittelrisalit (Eingangsrisalit) (Giebeldreieck gehört zur Wand)
    fuge(m_v(x_tow1, y_ris[0]), Wr, giebel_ab(Wr, ze_ris, zr_ris, RIS_HINTER_TURM, Wf), false, stoss = STOSS_V);   // sichtbarer Teil des Giebels, Spitze nicht mittig
    fuge(m_r(y_ris[0], x_ris1), y_main[0] - y_ris[0], rechteck(y_main[0] - y_ris[0], h_ris), false, stoss = STOSS_REST);

    // Rechter Flügel
    fuge(m_v(x_ris1, y_main[0]), x_end - x_ris1, rechteck(x_end - x_ris1, h_main), stoss = STOSS_V);
    if (RIS_HINTEN) {   // Rückwand des rechten Flügels beidseits des gleisseitigen Risalits, dazu dessen Wände
        fuge(m_h(x_end, y_main[1]), x_end - ris_h_x1, rechteck(x_end - ris_h_x1, h_main), stoss = STOSS_REST);
        fuge(m_h(ris_h_x0, y_main[1]), ris_h_x0 - x_tow1, rechteck(ris_h_x0 - x_tow1, h_main), stoss = STOSS_REST);
        fuge(m_h(ris_h_x1, y_rh[1]), ris_h_w,
             giebel(ris_h_w, ze_ris, ze_ris + ris_h_w / 2 * tan(a_ris_h) - td/2), false, stoss = STOSS_REST);   // Giebelfront
        fuge(m_l(y_rh[1], ris_h_x0), RIS_HINTEN_TIEFE, rechteck(RIS_HINTEN_TIEFE, h_ris), false, stoss = STOSS_REST);
        fuge(m_r(y_main[1], ris_h_x1), RIS_HINTEN_TIEFE, rechteck(RIS_HINTEN_TIEFE, h_ris), false, stoss = STOSS_REST);
    } else
        fuge(m_h(x_end, y_main[1]), x_end - x_tow1, rechteck(x_end - x_tow1, h_main), stoss = STOSS_REST);
    fuge(m_r(y_main[0], x_end), Wm, giebel(Wm, ze_main, zr_main), !ZAHN_GIEBEL_HAUPT, stoss = STOSS_REST);

    // Linker Flügel (die Wand zum rechten Flügel bei x_tow1 liegt innen, dort keine Fugen).
    // Front nur bis zur linken Turmkante (der Rest liegt hinter dem Turm), Rückwand ganz.
    // (Der Abschnitt x_lw0 bis x_tow0 liegt mit Türmchen hinter diesem und bekommt keine Fugen.)
    if (!TUERMCHEN) fuge(m_v(x_lw0, y_main[0]), x_tow0 - x_lw0, rechteck(x_tow0 - x_lw0, h_main), stoss = STOSS_V);
    fuge(m_h(x_tow1, y_main[1]), x_tow1 - x_lw0, rechteck(x_tow1 - x_lw0, h_main), stoss = STOSS_REST);
    fuge(m_l(y_main[1], x_lw0), Wm, giebel(Wm, ze_main, zr_main), !ZAHN_GIEBEL_HAUPT, stoss = STOSS_REST, bandfrei = true);

    // Türmchen vor dem linken Flügel: Front und linke Seite (rechts Turm, hinten linker Flügel)
    if (TUERMCHEN) {
        fuge(m_v(x_tt0, y_tt0), x_tt1 - x_tt0, rechteck(x_tt1 - x_tt0, h_tt), stoss = STOSS_V, ttb = true);
        fuge(m_l(y_tt1, x_tt0), y_tt1 - y_tt0, rechteck(y_tt1 - y_tt0, h_tt), stoss = STOSS_REST, ttb = true);
    }
}

// ============================================================
// Innenräume (abgezogen => 4-mm-Wände, unten offen)
// ============================================================
module hohlraeume() {
    if (ANBAU) {
        hohl(x_ann0, x_ann1, y_anns,   y_ann[1], h_ann);
        hohl(x_ann1, x_pav0, y_ann[0], y_ann[1], h_ann_h);
    }
    hohl(x_pav0, x_pav1, y_pav[0],  y_pav[1],  h_pav);
    hohl(x_pav1, x_mb1,  y_wing[0], y_wing[1], h_wing);
    hohl(x_lw0,  x_tow1, y_main[0], y_main[1], h_main);
    hohl(x_tow1, x_end,  y_main[0], y_main[1], h_main);
    hohl(x_ris0, x_ris1, y_ris[0],  y_ris[1],  h_ris);
    if (RIS_HINTEN) hohl(ris_h_x0, ris_h_x1, y_rh[0], y_rh[1], h_ris);   // gleisseitiger Mittelrisalit (öffnet die Rückwand)
    hohl(x_tow0, x_tow1, y_tow[0],  y_tow[1],  z_lat_hi + t);   // Hohlraum bis zur Unterkante des Balkens
    if (TUERMCHEN) hohl(x_tt0, x_tt1, y_tt0, y_tt1, h_tt);      // Türmchen

    // Durchgänge zwischen den Raumteilen
    if (ANBAU) {
        bruecke(x_pav0, y_ann[0], y_ann[1], h_ann_h);     // zum Pavillon
        bruecke(x_ann1, y_anns,   y_ann[1], h_ann);       // zwischen linkem und vorderem Teil
    }
    bruecke(x_pav1, y_wing[0], y_wing[1], h_wing);
    bruecke(x_mb1,  y_wing[0], y_wing[1], h_wing);
    bruecke(x_tow1, y_wing[0], y_wing[1], h_wing);
}

// ============================================================
// Tür rechts im rechten Flügel: Öffnung mit gestufter Laibung, Bogenfries,
// Türblatt (zwei Flügel, Kassetten, Klinke, Oberlicht), Podest, Treppe, Geländer
// Lokales Türsystem wie bei den Fenstern: u seitlich, v = z absolut, w nach außen.
// ============================================================
tuer_Wi = TUER_BREITE;                        // innere Öffnung
tuer_Wo = TUER_BREITE + 2 * GEWAENDE_STUFE;       // äußere Öffnung (mit Bogenfries)
z_pod   = zs + PODEST_SCHICHTEN * Z_PZ - Z_FUGE;
z_tr0   = z_pod + TUER_FLUEGELHOEHE;          // Unterkante Kämpfer
z_tr1   = z_tr0 + TUER_KAEMPFER;              // Oberkante Kämpfer
z_tsp   = z_tr1 + TUER_OBERLICHT_GERADE;      // Bogenansatz
pbog    = BOGEN_VORSPRUNG_MM * M / 1000 + 0.002;
tuer_d  = 0.06;                               // Türblattstärke
tuer_w0 = -GEWAENDE_STUFE - 0.10;                 // Rückseite Türblatt (lokal w)
tuer_y  = y_main[0];                          // Fassadenebene der Tür
podest_hw = tuer_Wo / 2 + PODEST_UEBERSTAND;  // halbe Podestbreite
st_rise = z_pod / TREPPE_STEIGUNGEN;

module tuer_arch2d(W, z0, zsp) {
    translate([-W/2, z0]) square([W, zsp - z0]);
    translate([0, zsp]) circle(r = W/2, $fn = 64);
}

// Öffnung (wird aus Wand und Bändern abgezogen)
module rb_oeffnung(x, yf, Wi, zb, zsp) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    multmatrix(m_v(x, yf)) {
        // äußere Öffnung bis zur Stufe
        translate([0, 0, -GEWAENDE_STUFE])
            linear_extrude(GEWAENDE_STUFE + pmax + 0.05) tuer_arch2d(Wo, zb, zsp);
        // innere Öffnung: schmaler und nach hinten versetzt, durch die ganze Wand
        translate([0, 0, -t - eps])
            linear_extrude(t - GEWAENDE_STUFE + 2*eps + 0.01) tuer_arch2d(Wi, zb, zsp);
    }
}
module tuer_oeffnung() { rb_oeffnung(TUER_X, tuer_y, tuer_Wi, z_pod, z_tsp); }

// OEFF_RENDER = true: alle Öffnungen werden EINMAL zu einem festen Körper vereinigt (render() = CGAL) und dann nur noch
// als ein einziges Teil von Wänden, Bändern und Fugen abgezogen. Das hält den CSG-Baum in der Vorschau klein
// (sonst bricht OpenSCAD die Normalisierung bei 200000 Elementen ab). Die erste Vorschau nach einer Änderung an
// Öffnungen dauert dadurch länger; unveränderte Öffnungen kommen danach aus dem Cache. false = altes Verhalten.
OEFF_RENDER = true;
module oeffnungen_alle() {
    if (OEFF_RENDER) render(convexity = 10) oeffnungen_roh();
    else oeffnungen_roh();
}
module oeffnungen_roh() {
    turm_oeffnungen();
    if (TUER) tuer_oeffnung();
    if (FENSTER) fenster_ueber_tuer_oeffnung();
    if (FENSTER_SCHMAL) schmal_oeffnungen();
    if (BLIND) blind_oeffnungen();
    if (RISALIT_OEFFNUNGEN) ris_oeffnungen();
    if (TUERMCHEN) tt_oeffnungen();
    if (ZW_FENSTER) zw_oeffnungen();
    if (PAV_FENSTER) pav_oeffnungen();
    if (PAV_RUECK_FENSTER) pav_rueck_oeffnungen();
    if (RW_RUECK_FENSTER) rw_rueck_oeffnungen();
    if (LW_RUECK_FENSTER) lw_rueck_oeffnungen();
    if (OG_RUECK_FENSTER) og_rueck_oeffnungen();
    if (ZW_RUECK_FENSTER) zw_rueck_oeffnungen();
    if (RIS_HINTEN) ris_h_oeffnungen();
    if (GIEBELFENSTER) gw_oeffnung();
    if (ANBAU) ann_oeffnungen();
}

// Bogenfries: Halbring aus radial gestellten Ziegeln über dem äußeren Türbogen
module rb_bogenfries(x, yf, Wi, zsp, schmal = false, nurfugen = false, Rb = BOGEN_BREITE, stufe = GEWAENDE_STUFE) {
    Ro = Wi / 2 + stufe;
    n  = max(3, round(PI * (Ro + Rb / 2) / (Z_B + Z_FUGE)));   // Ziegel im Bogen (Längsseiten-Variante)
    pt = Z_H + Z_FUGE;                                         // Bogenteilung bei Schmalseiten
    rows = max(1, round((Rb + Z_FUGE) / (Z_B + Z_FUGE)));      // Rollschichten radial (je 12 cm + Fuge)
    module fugenkoerper() {
        translate([0, 0, pbog - fd]) linear_extrude(fd + eps) {
            if (!schmal) {
                // Längsseiten: ein Ring aus radial gestellten Ziegeln, radiale Stoßfugen
                for (i = [1 : n - 1])
                    translate([0, zsp]) rotate(i * 180 / n)
                        translate([Ro - 0.01, -Z_FUGE/2]) square([Rb + 0.02, Z_FUGE]);
            } else {
                // Schmalseiten: Rollschichten aus Köpfen (12 cm radial, 6,5 cm im Bogen),
                // je Schicht um eine halbe Teilung versetzt, konzentrische Lagerfugen dazwischen
                for (r = [0 : rows - 1])
                    let(rs = Ro + r * (Z_B + Z_FUGE),
                        nr = round(PI * (rs + Z_B / 2) / pt),
                        v  = r % 2) {
                        if (r > 0)
                            translate([0, zsp]) intersection() {
                                difference() { circle(r = rs, $fn = 96); circle(r = rs - Z_FUGE, $fn = 96); }
                                translate([-10, 0]) square([20, 10]);
                            }
                        for (i = [(v == 0 ? 1 : 0) : nr - 1])
                            translate([0, zsp]) rotate((i + 0.5 * v) * 180 / nr)
                                translate([rs - 0.005, -Z_FUGE/2]) square([Z_B + 0.01, Z_FUGE]);
                    }
            }
        }
    }
    multmatrix(m_v(x, yf)) {
        if (nurfugen) {
            if (ZIEGEL) fugenkoerper();                         // nur die Fugen (zum grauen Einfärben)
        } else
            difference() {
                translate([0, 0, -0.02]) linear_extrude(pbog + 0.02)
                    intersection() {
                        difference() {
                            translate([0, zsp]) circle(r = Ro + Rb, $fn = 96);
                            translate([0, zsp]) circle(r = Ro, $fn = 96);
                        }
                        translate([-10, zsp]) square([20, 10]);
                    }
                if (ZIEGEL) fugenkoerper();
            }
    }
}
module bogenfries(x = TUER_X, yf = tuer_y) { rb_bogenfries(x, yf, tuer_Wi, z_tsp, TUER_BOGEN_SCHMAL); }

// Oberlicht-Umriss (Rechteck + Halbkreis), inset > 0 verkleinert nach innen
module oberlicht_form(inset) {
    Wi = tuer_Wi;
    intersection() {
        union() {
            translate([-Wi/2 + inset, z_tr1 + inset])
                square([Wi - 2*inset, z_tsp - z_tr1 - inset]);
            translate([0, z_tsp]) circle(r = Wi/2 - inset, $fn = 64);
        }
        translate([-10, z_tr1 + inset]) square([20, 10]);
    }
}

// ============================================================
// Kassettentür (aus Tuer_Modul.scad übernommen): zwei Flügel mit je drei gerahmten Kassetten (quadratisch, rechteckig,
// quadratisch), Türfalz, Kämpfer mit Aufleisten (U-Profil), Oberlicht mit dünner Sprosse und offenem Halbring,
// Türschild und Drücker. Gilt für alle Türen mit glas = false. TM_NEU = false schaltet auf die alte Tür zurück.
// ============================================================
TM_NEU = true;
C_BESCHLAG = [0.22, 0.21, 0.20];

// ---------- Maße der Tür ----------
TM_WI           = tuer_Wi;            // lichte Breite der Öffnung (zwei Flügel)
TM_HOEHE_FLUEGEL= TUER_FLUEGELHOEHE;  // Flügelhöhe von Podestoberkante bis Unterkante Kämpfer
TM_D            = tuer_d;             // Blattstärke
TM_FUGE         = 0.01;    // Fuge zwischen den beiden Flügeln (wird vom Falz überdeckt)

// Kämpfer (waagerecht zwischen Flügeln und Oberlicht), als U-Profil mit dünner Aufleiste oben und unten
TM_KAEMPFER        = TUER_KAEMPFER;
TM_KAEMPFER_AUFL_H = 0.022;   // Höhe (in der Ebene) der Aufleisten
TM_AUFL_V          = 0.025;   // Aufleisten stehen so weit vor dem Blatt
TM_KAEMPFER_AUFL_UNTEN = true;  // false = nur oben

// Oberlicht
TM_OBERLICHT_GERADE = TUER_OBERLICHT_GERADE;   // gerader Teil unter dem Halbkreis
TM_RAHMEN       = 0.07;       // Rahmenbreite des Oberlichts
TM_SPROSSE_B    = 0.03;       // dünne senkrechte Sprosse
TM_BOGEN_R      = 0.13;       // Außenradius des Halbkreises am Sprossenfuß
TM_BOGEN_RING   = 0.03;       // Stegbreite des Halbkreises (innen offen)
TM_BOGEN_HEBUNG = 0.02;       // Halbkreismittelpunkt über der Kämpferoberkante

// Flügel: Stile, Kassetten
TM_STIL         = 0.10;       // Stilbreite (seitlich) und Rand
TM_RIEGEL_UNTEN = 0.15;       // Abstand Unterkante Flügel -> unterste Kassette
TM_RIEGEL_OBEN  = 0.12;       // Abstand oberste Kassette -> Oberkante Flügel
TM_RIEGEL_MITTE = 0.12;       // Querholz zwischen den Kassetten
// Kassetten je Flügel von unten nach oben: quadratisch, rechteckig (Rest), quadratisch

// Bilderrahmen um jede Kassette
TM_RAHMEN_B     = 0.05;       // Breite der Rahmenleiste
TM_RAHMEN_H     = 0.02;       // Höhe der Leiste über der Blattfläche
TM_RAHMEN_FASE  = 0.015;      // Abschrägung außen und innen (Profil: Trapez)
TM_FELD_TIEFE   = 0.010;      // Füllung liegt so tief unter der Blattfläche

// Türfalz: senkrechte Aufleiste mittig über der Flügelfuge
TM_FALZ_B       = 0.08;
TM_FALZ_H       = 0.03;

// Türschild und Drücker (am linken Flügel, auf dem Stil neben dem Falz; Hebel zeigt zur Scharnierseite)
TM_KLINKE       = true;
TM_KLINKE_V     = 1.05;       // Höhe der Drückerachse über Podest
TM_KLINKE_U     = -0.075;     // Lage der Drückerachse (Mitte des linken Stils)
TM_SCHILD_B     = 0.06;       // Türschild: Breite (passt in den Stil, neben dem Falz)
TM_SCHILD_H     = 0.28;       // Türschild: Höhe
TM_SCHILD_D     = 0.008;      // Türschild: Stärke
TM_DRUECKER_L   = 0.15;       // Hebellänge ab Achse
TM_DRUECKER_B   = 0.030;      // Hebelbreite (in der Ebene)
TM_DRUECKER_T   = 0.026;      // Hebelstärke (nach vorn)
TM_DRUECKER_ABSTAND = 0.040;  // Hebel steht so weit vor dem Blatt

// ---------- abgeleitet ----------
TM_Z_K0   = TM_HOEHE_FLUEGEL;                 // Unterkante Kämpfer
TM_Z_K1   = TM_Z_K0 + TM_KAEMPFER;            // Oberkante Kämpfer
TM_Z_SP   = TM_Z_K1 + TM_OBERLICHT_GERADE;    // Bogenansatz (Mittelpunkt des Oberlicht-Halbkreises)

// ---------- Hilfsmodule ----------
// Rechteck-Stumpf: Fußfläche (Einzug i0) bis Kopffläche (Einzug i1) in Höhe H, Grundrechteck x,y,w,h
module tm_stumpf(x, y, w, h, i0, i1, H) {
    hull() {
        translate([x + i0, y + i0, 0])     cube([w - 2*i0, h - 2*i0, eps]);
        translate([x + i1, y + i1, H - eps]) cube([w - 2*i1, h - 2*i1, eps]);
    }
}

// Bilderrahmen (Gehrung automatisch): Trapezprofil, außen und innen abgeschrägt; z = 0 ist die Blattfläche
module tm_bilderrahmen(x, y, w, h) {
    fb = TM_RAHMEN_B;  fh = TM_RAHMEN_H;  fs = TM_RAHMEN_FASE;
    difference() {
        tm_stumpf(x, y, w, h, 0, fs, fh);
        translate([0, 0, -0.01]) tm_stumpf(x, y, w, h, fb, fb - fs, fh + 0.02);
    }
}

// Umriss der Öffnung des Oberlichts (Rechteck + Halbkreis), inset > 0 verkleinert
module tm_oberlicht_form(inset) {
    intersection() {
        union() {
            translate([-TM_WI/2 + inset, TM_Z_K1 + inset]) square([TM_WI - 2*inset, TM_Z_SP - TM_Z_K1 - inset]);
            translate([0, TM_Z_SP]) circle(r = TM_WI/2 - inset, $fn = 96);
        }
        translate([-10, TM_Z_K1 + inset]) square([20, 10]);
    }
}

// Halbkreis am Fuß der Sprosse: Ring, innen offen, mit Stegen bis zum Kämpfer
module tm_bogenring2d() {
    zc = TM_Z_K1 + TM_BOGEN_HEBUNG;  R = TM_BOGEN_R;  rr = TM_BOGEN_RING;
    intersection() {
        difference() {
            translate([0, zc]) circle(r = R, $fn = 64);
            translate([0, zc]) circle(r = R - rr, $fn = 64);
        }
        translate([-R - 1, zc]) square([2 * R + 2, R + 1]);
    }
    for (sx = [-1, 1])
        translate([sx * (R - rr/2) - rr/2, TM_Z_K1 - 0.005]) square([rr, zc - TM_Z_K1 + 0.01]);
}

// ---------- ein Flügel ----------
// u0 = linke Kante des Flügels, lw = Flügelbreite
module tm_fluegel(u0, lw) {
    hl = TM_HOEHE_FLUEGEL;  d = TM_D;
    pw = lw - 2 * TM_STIL;                                   // Kassettenbreite
    hq = pw;                                                 // quadratische Kassette
    hr = hl - TM_RIEGEL_UNTEN - TM_RIEGEL_OBEN - 2 * TM_RIEGEL_MITTE - 2 * hq;   // rechteckige Kassette
    ys = [TM_RIEGEL_UNTEN,
          TM_RIEGEL_UNTEN + hq + TM_RIEGEL_MITTE,
          TM_RIEGEL_UNTEN + hq + TM_RIEGEL_MITTE + hr + TM_RIEGEL_MITTE];
    hs = [hq, hr, hq];
    difference() {
        translate([u0, 0, 0]) cube([lw, hl, d]);
        for (i = [0 : 2])                                     // Füllungen liegen etwas tiefer als die Blattfläche
            translate([u0 + TM_STIL + TM_RAHMEN_B, ys[i] + TM_RAHMEN_B, d - TM_FELD_TIEFE])
                cube([pw - 2*TM_RAHMEN_B, hs[i] - 2*TM_RAHMEN_B, TM_FELD_TIEFE + 0.01]);
    }
    for (i = [0 : 2])
        translate([0, 0, d]) tm_bilderrahmen(u0 + TM_STIL, ys[i], pw, hs[i]);
}

// ---------- ganze Tür ----------

// ---------- Bahnsteigtür (Glastür): unten eine Kassette, darüber das Glasfeld mit drei Scheiben je Flügel ----------
// Gilt für alle Türen mit glas = true (Mittelrisalit Straßenseite, gleisseitiger Risalit, Gleisseite Pavillon/Zwischenbau).
// BS_NEU = false schaltet auf das alte Glastürblatt zurück (dann gibt es keine offenen Flügel).
BS_NEU           = true;
BS_STIL          = 0.09;       // Stilbreite seitlich
BS_RIEGEL_UNTEN  = 0.12;       // Abstand Unterkante Flügel -> Kassette
BS_KASSETTE_H    = 0.52;       // Höhe der Kassette
BS_RIEGEL_MITTE  = 0.12;       // Querholz zwischen Kassette und Glasfeld
BS_RIEGEL_OBEN   = 0.10;       // Querholz über dem Glasfeld
BS_SCHEIBEN      = 3;          // Scheiben je Flügel übereinander
BS_SPROSSE       = 0.045;      // Sprossenbreite zwischen den Scheiben
BS_LEISTE_B      = 0.018;      // Glasleiste (Rahmen) um jede Scheibe: Breite
BS_LEISTE_H      = 0.014;      // und Höhe über der Blattfläche
BS_KLINKE_U      = 0.075;      // Drücker am rechten Flügel (Mitte des rechten Stils)
// Offene Flügel (Winkel in Grad, 0 = geschlossen; nach innen = ins Gebäude). Flügel drehen am äußeren Gewände.
TM_OFFEN_WINKEL  = 85;
// Straßenseite, Mittelrisalit (drei Türen, von links nach rechts): [linker Flügel, rechter Flügel] je Tür
STRASSE_TUER_OFFEN = [[TM_OFFEN_WINKEL, TM_OFFEN_WINKEL], [0, 0], [0, TM_OFFEN_WINKEL]];   // links: beide Flügel auf; rechts: nur der rechte Flügel
// Gleisseite, Mittelrisalit (zwei Türen, von links nach rechts)
GLEIS_TUER_OFFEN   = [[0, 0], [0, TM_OFFEN_WINKEL]];                                         // rechte Tür: nur der rechte Flügel auf
GLEIS_FENSTER_OFFEN = [0, 80, 0];   // die drei Fenster darüber: nur das mittlere offen (Grad, nach außen, beide Flügel)

// Flügel um das äußere Gewände (Scharnier am Rand, in Blattmitte) drehen: ang > 0 dreht den linken, < 0 den rechten Flügel nach innen
module tm_pivot(hu, ang) {
    translate([hu, 0, TM_D/2]) rotate([0, ang, 0]) translate([-hu, 0, -TM_D/2]) children();
}

// Kassettentür: lokal Podestoberkante = 0, Blattrückseite w = 0. ol/orr = Öffnungswinkel linker/rechter Flügel (nach innen)
module tuer_modul(ol = 0, orr = 0) {
    Wi = TM_WI;  d = TM_D;  lw = (Wi - TM_FUGE) / 2;  ph = d / 2;
    color(C_TUER) {
        tm_pivot(-Wi/2 + ph, ol) tm_fluegel(-Wi/2, lw);
        tm_pivot(Wi/2 - ph, -orr) {
            tm_fluegel(TM_FUGE/2, lw);
            translate([-TM_FALZ_B/2, 0, d]) cube([TM_FALZ_B, TM_HOEHE_FLUEGEL, TM_FALZ_H]);   // Türfalz am rechten Flügel
        }
        tm_fest();
    }
    if (TUER_VERGLASUNG)
        color(C_GLAS) translate([0, 0, d/2 - 0.005]) linear_extrude(0.01) tm_oberlicht_form(TM_RAHMEN - 0.005);
    if (TM_KLINKE) tm_pivot(-Wi/2 + ph, ol) tm_beschlag(TM_KLINKE_U, -1);
}

// feste Teile: Kämpfer mit Aufleisten (U-Profil), Oberlicht mit dünner Sprosse und offenem Halbring
module tm_fest() {
    Wi = TM_WI;  d = TM_D;
    translate([-Wi/2, TM_Z_K0, 0]) cube([Wi, TM_KAEMPFER, d]);
    translate([-Wi/2, TM_Z_K1 - TM_KAEMPFER_AUFL_H, d]) cube([Wi, TM_KAEMPFER_AUFL_H, TM_AUFL_V]);        // oben
    if (TM_KAEMPFER_AUFL_UNTEN)
        translate([-Wi/2, TM_Z_K0, d]) cube([Wi, TM_KAEMPFER_AUFL_H, TM_AUFL_V]);                         // unten
    linear_extrude(d) {
        difference() { tm_oberlicht_form(-0.01); tm_oberlicht_form(TM_RAHMEN); }
        intersection() {
            tm_oberlicht_form(-0.01);
            translate([-TM_SPROSSE_B/2, TM_Z_K1 + TM_BOGEN_HEBUNG + TM_BOGEN_R - TM_BOGEN_RING/2]) square([TM_SPROSSE_B, 10]);
        }
        tm_bogenring2d();
    }
}

// Türschild mit abgerundeten Ecken, Rosette und Drückerhebel mit gerundetem Ende; u = Lage der Achse, rich = Hebelrichtung (+1 rechts, -1 links)
module tm_beschlag(u, rich, zextra = 0) {
    d = TM_D;  r = 0.012;
    color(C_BESCHLAG) translate([u, TM_KLINKE_V, d + zextra]) {
        linear_extrude(TM_SCHILD_D)
            offset(r = r) square([TM_SCHILD_B - 2*r, TM_SCHILD_H - 2*r], center = true);
        for (sy = [-1, 1]) translate([0, sy * (TM_SCHILD_H/2 - 0.03), TM_SCHILD_D]) cylinder(r = 0.007, h = 0.003);
        translate([0, 0, TM_SCHILD_D]) cylinder(r = 0.034, h = 0.012);                                   // Rosette
        translate([0, 0, TM_SCHILD_D]) cylinder(r = 0.016, h = TM_DRUECKER_ABSTAND - TM_SCHILD_D);       // Hals
        hull() {                                                                                          // Hebel
            translate([0, 0, TM_DRUECKER_ABSTAND - TM_DRUECKER_T/2]) cylinder(r = TM_DRUECKER_B/2 + 0.004, h = TM_DRUECKER_T/2);
            translate([rich * TM_DRUECKER_L, 0, TM_DRUECKER_ABSTAND - TM_DRUECKER_T/2]) cylinder(r = TM_DRUECKER_B/2, h = TM_DRUECKER_T/2);
        }
    }
}

// Bahnsteigtür-Flügel: unten eine Kassette, darüber drei Scheiben mit Glasleiste (Rahmen)
module bs_fluegel(u0, lw) {
    hl = TM_HOEHE_FLUEGEL;  d = TM_D;
    pw  = lw - 2 * BS_STIL;
    zk0 = BS_RIEGEL_UNTEN;  kh = BS_KASSETTE_H;
    zg0 = zk0 + kh + BS_RIEGEL_MITTE;
    zg1 = hl - BS_RIEGEL_OBEN;
    ph  = ((zg1 - zg0) - (BS_SCHEIBEN - 1) * BS_SPROSSE) / BS_SCHEIBEN;
    difference() {
        translate([u0, 0, 0]) cube([lw, hl, d]);
        translate([u0 + BS_STIL + TM_RAHMEN_B, zk0 + TM_RAHMEN_B, d - TM_FELD_TIEFE])
            cube([pw - 2*TM_RAHMEN_B, kh - 2*TM_RAHMEN_B, TM_FELD_TIEFE + 0.01]);
        for (i = [0 : BS_SCHEIBEN - 1])
            translate([u0 + BS_STIL, zg0 + i * (ph + BS_SPROSSE), -0.01]) cube([pw, ph, d + 0.02]);
    }
    translate([0, 0, d]) tm_bilderrahmen(u0 + BS_STIL, zk0, pw, kh);
    for (i = [0 : BS_SCHEIBEN - 1])
        translate([0, 0, d]) difference() {
            translate([u0 + BS_STIL - BS_LEISTE_B, zg0 + i * (ph + BS_SPROSSE) - BS_LEISTE_B, 0])
                cube([pw + 2*BS_LEISTE_B, ph + 2*BS_LEISTE_B, BS_LEISTE_H]);
            translate([u0 + BS_STIL, zg0 + i * (ph + BS_SPROSSE), -0.01]) cube([pw, ph, BS_LEISTE_H + 0.02]);
        }
    if (TUER_VERGLASUNG)
        color(C_GLAS) for (i = [0 : BS_SCHEIBEN - 1])
            translate([u0 + BS_STIL, zg0 + i * (ph + BS_SPROSSE), d/2 - 0.004]) cube([pw, ph, 0.008]);
}

// Bahnsteigtür (Glastür); Falz am linken, Drücker mit Schild am rechten Flügel
module tuer_bahnsteig(ol = 0, orr = 0) {
    Wi = TM_WI;  d = TM_D;  lw = (Wi - TM_FUGE) / 2;  ph = d / 2;
    color(C_TUER) {
        tm_pivot(-Wi/2 + ph, ol) {
            bs_fluegel(-Wi/2, lw);
            translate([-TM_FALZ_B/2, 0, d]) cube([TM_FALZ_B, TM_HOEHE_FLUEGEL, TM_FALZ_H]);   // Türfalz am linken Flügel
        }
        tm_pivot(Wi/2 - ph, -orr) bs_fluegel(TM_FUGE/2, lw);
        tm_fest();
    }
    if (TUER_VERGLASUNG)
        color(C_GLAS) translate([0, 0, d/2 - 0.005]) linear_extrude(0.01) tm_oberlicht_form(TM_RAHMEN - 0.005);
    if (TM_KLINKE) tm_pivot(Wi/2 - ph, -orr) tm_beschlag(BS_KLINKE_U, 1, BS_LEISTE_H - 0.004);
}

// Mehrfach gerahmte Kassette (Füllung) im Türflügel, von außen nach innen:
// Rahmenstufe, tiefe Nut, Feld, erhabene Mittelfüllung. x,y = linke untere Ecke, d = Blattstärke
module kassette(x, y, w, h, d) {
    module rr(i, z0, z1) { translate([x + i, y + i, z0]) cube([w - 2*i, h - 2*i, z1 - z0]); }
    rr(0.000, d - 0.008, d + eps);                                                   // äußerer Rahmen
    difference() { rr(0.035, d - 0.018, d + eps); rr(0.055, d - 0.1, d + 0.1); }     // tiefe Nut
    difference() { rr(0.055, d - 0.010, d + eps); rr(0.100, d - 0.1, d + 0.1); }     // Feld
    rr(0.100, d - 0.006, d + eps);                                                   // Mittelfüllung
}

// Türblatt: zwei Flügel mit je drei Kassetten, Kämpfer, Oberlicht (offen, mittig geteilt)
module tuer_blatt(x = TUER_X, yf = tuer_y, glas = false, ol = 0, orr = 0) {
    if (TM_NEU && !glas)                                       // neue Kassettentür
        multmatrix(m_v(x, yf)) translate([0, z_pod, tuer_w0]) tuer_modul(ol, orr);
    else if (BS_NEU && glas)                                   // neue Bahnsteigtür (Glastür)
        multmatrix(m_v(x, yf)) translate([0, z_pod, tuer_w0]) tuer_bahnsteig(ol, orr);
    else {
    Wi = tuer_Wi;  hl = TUER_FLUEGELHOEHE;  d = tuer_d;
    lw = Wi / 2 + 0.005;  stile = 0.10;  pw = lw - 2 * stile;
    kassetten = [[0.18, 0.45], [0.75, 1.05], [1.92, 0.55]];   // [Unterkante, Höhe] über Podest
    multmatrix(m_v(x, yf)) translate([0, 0, tuer_w0]) {
        for (u0 = [-Wi/2 - 0.01, 0.005]) {                     // mittig geteilt: Fuge 1 cm
            gh = hl - 0.10 - TUER_GLAS_UNTEN;                  // Höhe der Glasfläche (glas = true)
            difference() {
                translate([u0, z_pod, 0]) cube([lw, hl, d]);
                if (glas) {
                    // große Glasöffnung oben, unten eine Kassette
                    translate([u0 + stile, z_pod + TUER_GLAS_UNTEN, -0.01]) cube([pw, gh, d + 0.02]);
                    kassette(u0 + stile, z_pod + 0.12, pw, TUER_GLAS_UNTEN - 0.12 - 0.10, d);
                } else
                    for (k = kassetten)
                        kassette(u0 + stile, z_pod + k[0], pw, k[1], d);
            }
            if (glas) {
                if (TUER_GLAS_SPROSSEN > 0)
                    for (sp = [1 : TUER_GLAS_SPROSSEN])
                        translate([u0 + stile - 0.005, z_pod + TUER_GLAS_UNTEN + sp * gh / (TUER_GLAS_SPROSSEN + 1) - 0.015, 0])
                            cube([pw + 0.01, 0.03, d * 0.7]);
                if (TUER_VERGLASUNG)
                    color(C_GLAS) translate([u0 + stile, z_pod + TUER_GLAS_UNTEN, d/2 - 0.005]) cube([pw, gh, 0.01]);
            }
        }
        // Kämpfer
        translate([-Wi/2 - 0.01, z_tr0, 0]) cube([Wi + 0.02, TUER_KAEMPFER, d]);
        // Oberlicht: nur Rahmen und Mittelsprosse, Verglasung durchbrochen
        linear_extrude(d) {
            difference() { oberlicht_form(-0.01); oberlicht_form(0.06); }
            intersection() { oberlicht_form(-0.01); translate([-0.02, z_tr1]) square([0.04, 3]); }
            // die senkrechte Sprosse endet unten in einem kleinen Halbkreis
            intersection() {
                translate([0, z_tr1]) circle(r = SPROSSENFUSS, $fn = 32);
                translate([-1, z_tr1 - 0.005]) square([2, 1]);
            }
        }
        // Halbkreis steht zusätzlich nach vorn heraus, damit er sichtbar wird
        translate([0, 0, d]) linear_extrude(0.02)
            intersection() {
                translate([0, z_tr1]) circle(r = SPROSSENFUSS, $fn = 32);
                translate([-1, z_tr1 - 0.005]) square([2, 1]);
            }
    }
    }
}

// Türklinke (linker Flügel): Rosette auf dem Schild, Hebel zeigt zur Scharnierseite
module tuer_klinke(x = TUER_X, yf = tuer_y) {
    multmatrix(m_v(x, yf)) translate([0, 0, tuer_w0 + tuer_d]) {
        translate([klinke_u, klinke_v, 0]) cylinder(r = 0.028, h = 0.016, $fn = 24);      // Rosette
        translate([klinke_u - 0.11, klinke_v - 0.010, 0.008]) cube([0.11, 0.02, 0.022]); // Hebel
    }
}

// Podest und Treppe (Beton)
module podest_treppe(xc = TUER_X, yf = tuer_y, hw = podest_hw) {
    translate([xc - hw, yf - PODEST_TIEFE, 0])
        cube([2 * hw, PODEST_TIEFE + 0.02, z_pod]);
    for (k = [1 : TREPPE_STEIGUNGEN - 1])
        translate([xc - hw, yf - PODEST_TIEFE - k * TREPPE_AUFTRITT, 0])
            cube([2 * hw, TREPPE_AUFTRITT + 0.01, z_pod - k * st_rise]);
}

// ------------------------------------------------------------
// Treppengeländer (nach Foto, druckgerecht): Handlauf, Fußholm und Pfosten; dazwischen senkrechte Stäbe, zwischen
// denen je eine stehende Doppelvolute (S-Schnecke) sitzt. Alles hängt zusammen: die Voluten berühren Handlauf und Fußholm
// mit ihren Scheiteln, ihre Ausbuchtungen und Enden überlappen die Stäbe, die beiden Schnecken einer Volute sind durch
// einen Punkt verschweißt; die Pfosten reichen (pe) bis in Podest bzw. Stufe. Die Geländer sind als ebene Kontur
// (Länge s, Höhe z) gebaut und mit GEL_DICKE extrudiert.
// Alle Stärken sind in Modell-mm angegeben (Maßstab 1:M) und damit direkt druckbar (>= 0,6 mm).
// ------------------------------------------------------------
GEL_DICKE  = 1.0 * M / 1000;   // Stärke des Geländers quer zur Ebene (1,0 mm im Modell)
GEL_HANDL  = 1.0 * M / 1000;   // Handlauf (Höhe in der Ebene)
GEL_FUSSH  = 0.8 * M / 1000;   // Fußholm (Höhe in der Ebene)
GEL_POST   = 0.9 * M / 1000;   // Pfostenbreite
GEL_STAB   = 0.6 * M / 1000;   // Stärke der Voluten und der senkrechten Stäbe
GEL_MITTELSTAB = true;       // senkrechte Zwischenstrebe in der Feldmitte (Verbindung/Stabilität für die Voluten)
GEL_FUSS   = 0.15;             // Fußholm liegt so weit [m real] über der Stufenkante (Abstand Handlauf - Fußholm = hh - GEL_FUSS)

// Kreisbogenband (Außenradius r, Stärke w) von Winkel a0 bis a1
function gel_bogen(r, w, a0, a1, n = 24) =
    concat([for (i = [0 : n]) let(a = a0 + (a1 - a0) * i / n) [r * cos(a), r * sin(a)]],
           [for (i = [n : -1 : 0]) let(a = a0 + (a1 - a0) * i / n) [(r - w) * cos(a), (r - w) * sin(a)]]);
// Doppelvolute (S-Schnecke), Breite 4R, Höhe 2R, Berührpunkt im Ursprung (durch eine Verschweißung fest verbunden)
module gel_volute(R, w) {
    translate([-R, 0]) polygon(gel_bogen(R, w, 0, 270));
    translate([ R, 0]) polygon(gel_bogen(R, w, -90, 180));
    circle(d = 2.2 * w, $fn = 16);
}
// pts = Knickpunkte des Handlaufs [s, z]; hh = Höhe Handlauf über Stufe/Podest; pe = Pfosten reichen so weit tiefer
// (in Podest bzw. Stufe hinein)
module gel_flaeche(pts, hh, pe = 0) {
    hb = hh - GEL_FUSS;                                     // senkrechter Abstand Handlauf - Fußholm
    R0 = hb / 4;                                            // stehende Volute: Höhe 4R = hb, Scheitel berühren beide Holme
    for (i = [0 : len(pts) - 2]) {
        p0 = pts[i];  p1 = pts[i + 1];
        ds = p1[0] - p0[0];  dz = p1[1] - p0[1];
        hull() for (q = [p0, p1]) translate(q) circle(d = GEL_HANDL, $fn = 10);                                  // Handlauf
        hull() for (q = [p0, p1]) translate([q[0], q[1] - hb]) circle(d = GEL_FUSSH, $fn = 8);                   // Fußholm
        n = max(1, ceil(abs(ds) / (2 * R0 * 1.3)));         // Zahl der Felder zwischen den Stäben
        for (k = [0 : n])                                   // senkrechte Stäbe zwischen Handlauf und Fußholm
            translate([p0[0] + ds * k / n - GEL_STAB / 2, p0[1] + dz * k / n - hb]) square([GEL_STAB, hb]);
        if (GEL_MITTELSTAB)                                 // Zwischenstrebe in der Mitte jedes Feldes: geht durch den
            for (j = [0 : n - 1])                           // Berührpunkt und beide Schneckenmitten, verbindet Voluten
                translate([p0[0] + ds * (j + 0.5) / n - GEL_STAB / 2,   // mit Handlauf und Fußholm
                           p0[1] + dz * (j + 0.5) / n - hb]) square([GEL_STAB, hb]);
        for (j = [0 : n - 1])                               // je Feld eine stehende Volute, in x auf die Feldbreite gestaucht
            translate([p0[0] + ds * (j + 0.5) / n, p0[1] + dz * (j + 0.5) / n - hb / 2])
                scale([abs(ds) / n / (2 * R0), 1]) rotate(90) gel_volute(R0, GEL_STAB);
    }
    for (q = pts) translate([q[0] - GEL_POST / 2, q[1] - hh - pe]) square([GEL_POST, hh + pe]);   // Pfosten
}

// Geländer beidseitig: waagerecht über dem Podest, dann parallel zur Treppe nach unten
module gelaender(xc = TUER_X, yf = tuer_y, hw = podest_hw) {
    n  = TREPPE_STEIGUNGEN - 1;
    hh = 0.90;
    pts = [[yf - 0.05, z_pod + hh],
           [yf - PODEST_TIEFE, z_pod + hh],
           [yf - PODEST_TIEFE - n * TREPPE_AUFTRITT + 0.05, z_pod - n * st_rise + hh]];
    for (sx = [-1, 1])
        translate([xc + sx * (hw - 0.04) - GEL_DICKE / 2, 0, 0]) rotate([90, 0, 90])     // 2D (y, z), Extrusion entlang x
            linear_extrude(GEL_DICKE) gel_flaeche(pts, hh, st_rise + 0.05);
}

// Laibung der gestuften Öffnung als dünne gelbe Haut (äußere Laibung, Stufenfläche,
// innere Laibung), damit sie nie ziegelrot erscheint. e = Hautstärke.
tuer_e = 0.006;
module rb_laibung_formen(Wi, zb, zsp, e) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(GEWAENDE_STUFE)         // äußere Laibung
        difference() { tuer_arch2d(Wo, zb, zsp); tuer_arch2d(Wo - 2*e, zb - 0.1, zsp); }
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(e)                      // Stufenfläche
        difference() { tuer_arch2d(Wo - 2*e, zb, zsp); tuer_arch2d(Wi, zb - 0.1, zsp); }
    translate([0, 0, -t]) linear_extrude(t - GEWAENDE_STUFE + e)              // innere Laibung
        difference() { tuer_arch2d(Wi, zb, zsp); tuer_arch2d(Wi - 2*e, zb - 0.1, zsp); }
}

module rb_laibung(x, yf, Wi, zb, zsp) {
    multmatrix(m_v(x, yf)) rb_laibung_formen(Wi, zb, zsp, tuer_e);
}
module laibung(x = TUER_X, yf = tuer_y) { rb_laibung(x, yf, tuer_Wi, z_pod, z_tsp); }

// Die roten Ziegelschichten der Wand (laut TRAUFE_SCHEMA) laufen in die Laibung hinein
module rb_streifen(x, yf, Wi, zb, zsp) {
    for (i = [0 : len(TRAUFE_SCHEMA) - 1])
        let(typ = TRAUFE_SCHEMA[i][0], k = lauf_n(TRAUFE_SCHEMA, i),
            z0 = z_y0 + k * Z_PZ, z1 = z0 + sch_n(TRAUFE_SCHEMA[i]) * Z_PZ - Z_FUGE)
            if ((typ == "r" || typ == "v") && k * Z_PZ > 0 && z1 > zb && z0 < zsp + Wi / 2)
                multmatrix(m_v(x, yf))
                    intersection() {
                        rb_laibung_formen(Wi, zb, zsp, tuer_e + 0.004);
                        translate([-5, z0, -1]) cube([10, z1 - z0, 2]);
                    }
}
module laibung_streifen(x = TUER_X, yf = tuer_y) { rb_streifen(x, yf, tuer_Wi, z_pod, z_tsp); }

// Klinkenschild (Langschild) mit Schlüsselloch unter der Klinke, auf dem Mittelstil des linken Flügels
klinke_u = -0.055;                          // Mitte des Stils neben der Teilungsfuge
klinke_v = z_pod + KLINKE_HOEHE;
module schluesselloch2d() {
    vk = klinke_v - 0.10;                   // Schlüsselloch unter der Klinke
    translate([klinke_u, vk]) circle(r = 0.011, $fn = 20);
    polygon([[klinke_u - 0.006, vk - 0.002], [klinke_u + 0.006, vk - 0.002],
             [klinke_u + 0.003, vk - 0.035], [klinke_u - 0.003, vk - 0.035]]);
}
module tuerschild(x = TUER_X, yf = tuer_y) {
    sw = TUERSCHILD_B;  sh = TUERSCHILD_H;  r = 0.012;
    multmatrix(m_v(x, yf)) translate([0, 0, tuer_w0 + tuer_d]) {
        color(C_SCHILD) linear_extrude(0.010)               // Schild mit Schlüsselloch-Öffnung
            difference() {
                translate([klinke_u, klinke_v - 0.17 + sh/2 - 0.03])
                    offset(r = r) offset(delta = -r) square([sw, sh], center = true);
                schluesselloch2d();
            }
        color(C_DUNKEL) translate([0, 0, -0.002]) linear_extrude(0.004)   // dunkler Grund im Schlüsselloch
            schluesselloch2d();
    }
}

// ============================================================
// Fenster über der Tür: gleiche Grundsätze wie die Tür (Stufengewände, Bogenfries,
// gelbe Laibung mit durchlaufenden roten Streifen), Bogenfries bis unter die letzte
// gelbe Reihe unter dem Zahnfries.
// ============================================================
f_Wo = FENSTER_HALBZIEGEL * (Z_L + Z_FUGE) / 2 - Z_FUGE;   // Breite über alles = 9 Halbziegel (1,16 m)
f_Wi = f_Wo - 2 * GEWAENDE_STUFE;                           // lichte Weite: je Seite ein Halbziegel Gewände abgezogen (7 Halbziegel, 0,90 m)

function erster_index(l, typ, i = 0) = i >= len(l) ? -1 : (l[i][0] == typ ? i : erster_index(l, typ, i + 1));
function letzter_g_vor(l, i) = i < 0 ? -1 : (l[i][0] == "g" ? i : letzter_g_vor(l, i - 1));
f_iz = erster_index(TRAUFE_SCHEMA, "z");
f_ig = letzter_g_vor(TRAUFE_SCHEMA, f_iz < 0 ? len(TRAUFE_SCHEMA) - 1 : f_iz - 1);
f_gende = z_y0 + (lauf_n(TRAUFE_SCHEMA, f_ig) + sch_n(TRAUFE_SCHEMA[f_ig])) * Z_PZ;   // Ende dieser gelben Schichten

// Scheitel des Bogenfrieses = Unterkante der letzten gelben Reihe: darüber folgt noch
// eine gelbe Reihe, erst dann die rote Schicht unter dem Zahnfries.
z_ftop = FENSTER_BOGEN_OBEN > 0 ? FENSTER_BOGEN_OBEN : f_gende - Z_PZ;
z_fsp  = z_ftop - FENSTER_BOGEN_BREITE - f_Wo / 2;                       // Bogenansatz
// Unterkante der Öffnung: die gelbe Schichtgruppe beginnt direkt über dem obersten roten Band
// (hier dem vorspringenden "v"); darüber FENSTER_BANK_ABSTAND gelbe Reihen, dann die Öffnung.
// Bei 0 sitzt das Fenster direkt auf der roten Reihe, die als Fensterbank dient.
f_gstart = z_y0 + lauf_n(TRAUFE_SCHEMA, f_ig) * Z_PZ;                    // erste gelbe Schicht über dem roten Band
z_fsil = f_gstart + FENSTER_BANK_ABSTAND * Z_PZ;                         // Unterkante Öffnung (Ziegelraster)
f_d    = 0.05;                                                           // Rahmenstärke
f_w0   = -GEWAENDE_STUFE - 0.08;                                         // Rückseite des Rahmens (lokal w)

// ============================================================
// Bogenfenster in der linken Giebelwand des linken Flügels (Außenfläche -x, x_lw0): ZWEI Fenster, symmetrisch zur
// Wandmitte und eher außen, über dem Dach des Zwischengebäudes. Blick auf die Giebelwand von außen: links (größeres y,
// gleisseitig) ein Blindfenster (nur Nische), rechts (kleineres y, straßenseitig) ein echtes Fenster mit Rahmen und
// Sprossen; der First des Zwischengebäudes liegt dazwischen. Form wie die übrigen Fenster: gerader Schaft mit
// Halbkreisbogen oben (Breite wie das Fenster über der Tür). Die Schäfte reichen nach unten BIS INS DACH des
// Zwischengebäudes und werden von dessen schrägen Dachflächen abgeschnitten (kein freistehender Kreis mehr).
// ============================================================
GIEBELFENSTER = true;
GW_ANSATZ     = 0.15;                        // Bogenansatz über der Dachfläche an der zum First hin gelegenen Fensterkante [m real]
GW_TIEFE      = 0.20;                        // Öffnung reicht so weit unter die Dachfläche an der vom First abgewandten Kante [m real]
GW_DACH_TOL   = 0.03;                        // Schnittfläche liegt so weit unter der Dachfläche (verschwindet in der Dachhaut)
GW_AUSSEN     = 2.4;                         // Abstand jedes Fensters von der Wandmitte (y)
GW_DURCHBRUCH = true;                        // true = straßenseitiges Fenster durchbrochen; false = beide blind (Fehlersuche)
GW_STREIFEN   = false;                       // true = rote Streifen laufen in die Laibungen (Fehlersuche: aus)
gw_yc  = (y_wing[0] + y_wing[1]) / 2;        // Achse des Zwischengebäudes (dort liegt dessen First)
gw_ym  = (y_main[0] + y_main[1]) / 2;        // Mitte der Giebelwand
gw_ys  = [gw_ym - GW_AUSSEN, gw_ym + GW_AUSSEN];   // [straßenseitig, gleisseitig]
gw_zr  = h_wing + (y_wing[1] - y_wing[0]) / 2 * tan(a_wing);           // Firsthöhe des Zwischengebäudes
gw_halb = f_Wi / 2 + GEWAENDE_STUFE + FENSTER_BOGEN_BREITE;            // halbe Breite inkl. Bogenfries
function gw_dach(y)      = gw_zr - max(0, abs(y - gw_yc) - gw_halb) * tan(a_wing);   // Dachhöhe an der zum First hin gelegenen Fensterkante
function gw_dach_fern(y) = gw_zr - (abs(y - gw_yc) + gw_halb) * tan(a_wing);         // Dachhöhe an der vom First abgewandten Fensterkante
function gw_flaeche(y)   = gw_zr - abs(y - gw_yc) * tan(a_wing);                     // Dachfläche des Zwischengebäudes
gw_zsp = z_y0 + ceil((max(gw_dach(gw_ys[0]), gw_dach(gw_ys[1])) + GW_ANSATZ - z_y0) / Z_PZ) * Z_PZ;          // Bogenansatz (Ziegelraster)
gw_zb  = z_y0 + floor((min(gw_dach_fern(gw_ys[0]), gw_dach_fern(gw_ys[1])) - GW_TIEFE - z_y0) / Z_PZ) * Z_PZ; // Sohle unter dem Dach
gw_pitch = (zw_zsp - EG_KAEMPFER - zw_zb) / (OG_QUERSPROSSEN + 1);                   // Sprossenabstand wie bei den übrigen Fenstern

module gw_wand(y) { translate([x_lw0, y, 0]) rotate([0, 0, -90]) children(); }   // lokal wie m_v: u seitlich, v = z, w nach außen (-x)

// Raum oberhalb der Dachflächen des Zwischengebäudes (Prisma entlang x): alles, was darunter liegt, wird abgeschnitten
module gw_ueber_dach() {
    y0 = gw_ym - 8;  y1 = gw_ym + 8;
    translate([x_lw0 - 3, 0, 0]) rotate([90, 0, 90]) linear_extrude(6)       // 2D-Koordinaten (y, z), Extrusion entlang x
        polygon([[y0, gw_flaeche(y0) - GW_DACH_TOL], [gw_yc, gw_zr - GW_DACH_TOL], [y1, gw_flaeche(y1) - GW_DACH_TOL],
                 [y1, gw_zr + 20], [y0, gw_zr + 20]]);
}
module gw_clip() { intersection() { union() children(); gw_ueber_dach(); } }

module gw_oeffnung() {
    gw_clip() gw_wand(gw_ys[0]) {                                                          // straßenseitig: durchbrochen (oder blind)
        if (GW_DURCHBRUCH) rb_oeffnung(0, 0, f_Wi, gw_zb, gw_zsp);
        else multmatrix(m_v(0, 0)) blind_oeffnung(f_Wi, gw_zb, gw_zsp);
    }
    gw_clip() gw_wand(gw_ys[1]) multmatrix(m_v(0, 0)) blind_oeffnung(f_Wi, gw_zb, gw_zsp);  // gleisseitig: blind
}
module gw_objekte() {
    // straßenseitig (von außen rechts vom First): echtes Fenster mit Rahmen und Sprossen
    gw_wand(gw_ys[0]) {
        color(C_BOGEN) rb_bogenfries(0, 0, f_Wi, gw_zsp, FENSTER_BOGEN_SCHMAL, false, FENSTER_BOGEN_BREITE);
        if (FUGEN_GRAU) color(C_FUGE) rb_bogenfries(0, 0, f_Wi, gw_zsp, FENSTER_BOGEN_SCHMAL, true, FENSTER_BOGEN_BREITE);
    }
    if (GW_DURCHBRUCH) {
        color(C_KLINKER) gw_clip() gw_wand(gw_ys[0]) rb_laibung(0, 0, f_Wi, gw_zb, gw_zsp);
        if (GW_STREIFEN) color(C_BAND) gw_clip() gw_wand(gw_ys[0]) rb_streifen(0, 0, f_Wi, gw_zb, gw_zsp);
    } else
        color(C_KLINKER) gw_clip() gw_wand(gw_ys[0]) multmatrix(m_v(0, 0)) blind_laibung_formen(f_Wi, gw_zb, gw_zsp, tuer_e);
    gw_clip() gw_wand(gw_ys[0]) {
        zw_blatt(0, 0, f_Wi, gw_zb, gw_zsp, gw_pitch, true, OG_QUERSPROSSEN);
        if (OG_BANK) zw_fensterbank(0, 0, f_Wi, gw_zb);
    }
    // gleisseitig (von außen links vom First): Blindfenster ohne Rahmen
    gw_wand(gw_ys[1]) {
        color(C_BOGEN) rb_bogenfries(0, 0, f_Wi, gw_zsp, FENSTER_BOGEN_SCHMAL, false, FENSTER_BOGEN_BREITE);
        if (FUGEN_GRAU) color(C_FUGE) rb_bogenfries(0, 0, f_Wi, gw_zsp, FENSTER_BOGEN_SCHMAL, true, FENSTER_BOGEN_BREITE);
    }
    color(C_KLINKER) gw_clip() gw_wand(gw_ys[1]) multmatrix(m_v(0, 0)) blind_laibung_formen(f_Wi, gw_zb, gw_zsp, tuer_e);
    if (GW_STREIFEN) color(C_BAND) gw_clip() gw_wand(gw_ys[1]) multmatrix(m_v(0, 0)) blind_streifen(f_Wi, gw_zb, gw_zsp);
}

module fenster_ueber_tuer_oeffnung() { rb_oeffnung(FENSTER_X, tuer_y, f_Wi, z_fsil, z_fsp); }

// Umriss der Öffnung (Rechteck + Halbkreis), inset > 0 verkleinert nach innen
module fenster_form(inset) {
    intersection() {
        union() {
            translate([-f_Wi/2 + inset, z_fsil + inset]) square([f_Wi - 2*inset, z_fsp - z_fsil - inset]);
            translate([0, z_fsp]) circle(r = f_Wi/2 - inset, $fn = 64);
        }
        translate([-10, z_fsil + inset]) square([20, 20]);
    }
}

// Fensterflügel graugrün: Rahmen, Kämpfer, Mittelpfosten, Sprosse, Halbkreis am Sprossenfuß, Glas
module fenster_blatt(x = FENSTER_X, yf = tuer_y) {
    kb = FENSTER_KAEMPFER;  fr = 0.07;  sb = 0.04;
    z_fb = (z_fsil + z_fsp) / 2 - sb / 2;      // waagerechte Sprosse teilt den rechteckigen Teil mittig
    multmatrix(m_v(x, yf)) translate([0, 0, f_w0]) {
        color(C_TUER) {
            linear_extrude(f_d) {
                difference() { fenster_form(-0.01); fenster_form(fr); }                                       // Rahmen
                intersection() { fenster_form(-0.01); translate([-f_Wi/2, z_fsp - kb]) square([f_Wi, kb]); }  // Kämpfer
                intersection() { fenster_form(-0.01); translate([-0.03, z_fsil]) square([0.06, 10]); }       // Mittelpfosten
                intersection() { fenster_form(-0.01); translate([-f_Wi/2, z_fb]) square([f_Wi, sb]); }       // Sprosse
                intersection() {                                                                              // Sprossenfuß
                    translate([0, z_fsp]) circle(r = SPROSSENFUSS, $fn = 32);
                    translate([-1, z_fsp - 0.005]) square([2, 1]);
                }
            }
            translate([0, 0, f_d]) linear_extrude(0.02)                                                       // Fuß steht vor
                intersection() {
                    translate([0, z_fsp]) circle(r = SPROSSENFUSS, $fn = 32);
                    translate([-1, z_fsp - 0.005]) square([2, 1]);
                }
        }
        if (FENSTER_VERGLASUNG)
            color(C_GLAS) translate([0, 0, f_d/2 - 0.005]) linear_extrude(0.01) fenster_form(fr - 0.005);
    }
}

// Fensterbank: eine rote Ziegelschicht unter der Öffnung, springt leicht vor
module fensterbank(x = FENSTER_X, yf = tuer_y) {
    ov = FENSTERBANK_VORSPRUNG_MM * M / 1000;
    multmatrix(m_v(x, yf))
        translate([-f_Wo/2 - 0.06, z_fsil - Z_PZ, -0.02]) cube([f_Wo + 0.12, Z_H, ov + 0.02]);
}

module fenster_objekte(x = FENSTER_X, yf = tuer_y, offen = 0) {
    color(C_BOGEN) rb_bogenfries(x, yf, f_Wi, z_fsp, FENSTER_BOGEN_SCHMAL, false, FENSTER_BOGEN_BREITE);
    if (FUGEN_GRAU) color(C_FUGE) rb_bogenfries(x, yf, f_Wi, z_fsp, FENSTER_BOGEN_SCHMAL, true, FENSTER_BOGEN_BREITE);
    color(C_KLINKER) rb_laibung(x, yf, f_Wi, z_fsil, z_fsp);
    color(C_BAND) rb_streifen(x, yf, f_Wi, z_fsil, z_fsp);
    if (FENSTERBANK) color(C_BAND) fensterbank(x, yf);
    zw_blatt(x, yf, f_Wi, z_fsil, z_fsp, 0, true, OG_QUERSPROSSEN, offen);
    if (OG_BANK) zw_fensterbank(x, yf, f_Wi, z_fsil);
}

// eine Tür (Bogenfries, Laibung, Türblatt, Schild, Klinke) ohne Podest/Treppe
// glas = true: Türflügel mit großer Glasfläche; kl/kr: der Bogenfries wird links/rechts der Türmitte
// auf diese Entfernung [m] beschnitten (für dicht stehende Türen, deren Friese sich überschneiden)
module clipx(x, yf, kl, kr) {
    if (kl >= 50 && kr >= 50) children();
    else intersection() {
        children();
        translate([x - kl, yf - 2, -1]) cube([kl + kr, 4, 100]);
    }
}

module tuer_einzel(x = TUER_X, yf = tuer_y, glas = false, kl = 100, kr = 100, ol = 0, orr = 0) {
    color(C_BOGEN)      clipx(x, yf, kl, kr) bogenfries(x, yf);
    if (FUGEN_GRAU) color(C_FUGE) clipx(x, yf, kl, kr) rb_bogenfries(x, yf, tuer_Wi, z_tsp, TUER_BOGEN_SCHMAL, true);
    color(C_KLINKER)    laibung(x, yf);
    color(C_BAND)       laibung_streifen(x, yf);
    alt = glas ? !BS_NEU : !TM_NEU;                    // alte Tür: Schild und Klinke separat; neue Türen haben beides im Modul
    if (TUERSCHILD && alt) tuerschild(x, yf);
    color(C_TUER)       tuer_blatt(x, yf, glas, ol, orr);
    if (alt) color(C_DUNKEL) tuer_klinke(x, yf);
}

module tuer_objekte() {
    color(C_BETON)      podest_treppe();
    if (GELAENDER) color(C_GELAENDER) gelaender();
    tuer_einzel();
}

// ============================================================
// Schmale Fenster links und rechts der Tür: Rundbogenöffnung ohne Stufengewände, beginnen in der
// ersten gelben Schicht über dem Sockelband. Der Bogen aus Halbziegeln (eine Rollschicht Köpfe)
// liegt genau unter der nächsten roten Reihe. Rahmen mit zwei senkrechten und zwei waagerechten
// Sprossen, durchbrochen (ohne Glas).
// ============================================================
function erster_rot(l, i = 0) = i >= len(l) ? -1 : (l[i][0] == "r" || l[i][0] == "v" ? i : erster_rot(l, i + 1));
s_Wi   = FENSTER_SCHMAL_HALBZIEGEL * (Z_L + Z_FUGE) / 2 - Z_FUGE;      // lichte Weite (4 Halbziegel = 2 Läufer = 0,51 m)
s_top  = z_y0 + lauf_n(TRAUFE_SCHEMA, erster_rot(TRAUFE_SCHEMA)) * Z_PZ; // Unterkante der nächsten roten Reihe
s_z0   = z_y0;                                                           // Unterkante: erste gelbe Schicht
s_zsp  = s_top - FENSTER_SCHMAL_BOGEN_BREITE - s_Wi / 2;                 // Bogenansatz
s_xs   = [(x_ris1 + (TUER_X - tuer_Wo/2)) / 2,        // links: mittig zwischen Wandanfang (Risalit) und Türrand
          ((TUER_X + tuer_Wo/2) + x_end) / 2];        // rechts: mittig zwischen Türrand und Wandende
s_d    = 0.05;                                                           // Rahmenstärke
s_w0   = -0.12;                                                          // Rückseite des Rahmens (lokal w)

module schmal_oeffnungen() {
    for (x = s_xs)
        multmatrix(m_v(x, tuer_y))
            translate([0, 0, -t - eps])
                linear_extrude(t + 2*eps + pmax + 0.05) tuer_arch2d(s_Wi, s_z0, s_zsp);
}

// Umriss (Rechteck + Halbkreis), inset > 0 verkleinert nach innen
module schmal_form(inset) {
    intersection() {
        union() {
            translate([-s_Wi/2 + inset, s_z0 + inset]) square([s_Wi - 2*inset, s_zsp - s_z0 - inset]);
            translate([0, s_zsp]) circle(r = s_Wi/2 - inset, $fn = 48);
        }
        translate([-10, s_z0 + inset]) square([20, 20]);
    }
}

module schmal_blatt(x) {
    fr = FENSTER_SCHMAL_RAHMEN;  sb = FENSTER_SCHMAL_SPROSSE;
    h  = s_zsp - s_z0;                                    // Höhe des geraden Teils
    multmatrix(m_v(x, tuer_y)) translate([0, 0, s_w0]) {
        color(C_TUER) linear_extrude(s_d) {
            difference() { schmal_form(-0.01); schmal_form(fr); }                               // Rahmen
            for (u = [-s_Wi/6, s_Wi/6])                                                         // zwei senkrechte Sprossen
                intersection() { schmal_form(-0.01); translate([u - sb/2, s_z0]) square([sb, 10]); }
            for (k = [1, 2])                                                                    // zwei waagerechte Sprossen
                intersection() { schmal_form(-0.01); translate([-s_Wi/2, s_z0 + k*h/3 - sb/2]) square([s_Wi, sb]); }
        }
        if (FENSTER_SCHMAL_VERGLASUNG)
            color(C_GLAS) translate([0, 0, s_d/2 - 0.005]) linear_extrude(0.01) schmal_form(fr - 0.005);
    }
}

module schmal_objekte() {
    for (x = s_xs) {
        color(C_BOGEN) rb_bogenfries(x, tuer_y, s_Wi, s_zsp, true, false, FENSTER_SCHMAL_BOGEN_BREITE, 0);
        if (FUGEN_GRAU) color(C_FUGE) rb_bogenfries(x, tuer_y, s_Wi, s_zsp, true, true, FENSTER_SCHMAL_BOGEN_BREITE, 0);
        schmal_blatt(x);
    }
}

// ============================================================
// Rechte Außenwand (Giebelwand, Außenfläche +x): zwei Blindfenster oben, eine Blindtür unten.
// Blind = nur Nische, kein Durchbruch, kein Rahmen/Türblatt, keine Treppe.
// Maße und Höhen identisch zu Fenster über der Tür (f_Wi, z_fsil, z_fsp) und zur Tür
// (tuer_Wi, z_pod, z_tsp), also auch gleiche Stufengewände, Bogenfriese und durchlaufende
// rote Streifen. Die Blindtür sitzt auf Höhe der Podestoberkante (ohne Podest/Treppe).
// ============================================================
BLIND                 = true;
BLIND_FENSTER         = true;
BLIND_TUER            = true;
BLIND_TIEFE           = 0.22;   // Gesamttiefe der Nischen ab Wandfläche [m real] (0,22 m = 2,5 mm im Modell;
                                // Wand ist 4 mm stark, bleiben ca. 1,5 mm Restwand). Mindestens GEWAENDE_STUFE.
// Abstand der beiden Blindfenster (Mitte zu Mitte): zwischen den äußeren Öffnungskanten liegt je Fenster
// ein Halbziegelrand (die Breite des Bogens läuft virtuell senkrecht nach unten weiter) und dazwischen
// ein Läufer mit Fugen: 0,12 + 0,01 + 0,25 + 0,01 + 0,12 = 0,51 m  ->  1,16 + 0,51 = 1,67 m
BLIND_FENSTER_ABSTAND = f_Wo + 2 * FENSTER_BOGEN_BREITE + 2 * Z_FUGE + Z_L;
bw_breite = y_main[1] - y_main[0];          // Breite der rechten Giebelwand
BLIND_MITTE = bw_breite / 2;                // Achse: Blindtür mittig, Blindfenster symmetrisch darüber
blind_f_u = [BLIND_MITTE - BLIND_FENSTER_ABSTAND / 2, BLIND_MITTE + BLIND_FENSTER_ABSTAND / 2];
blind_t_u = [BLIND_MITTE];

// Nische mit lokalem Wandsystem von m_r (u = entlang der Wand, v = z, w = nach außen)
module blind_wand(u) { multmatrix(m_r(y_main[0], x_end)) translate([u, 0, 0]) children(); }
// dasselbe Koordinatensystem für Module, die intern m_v(x, yf) benutzen (Aufruf dort mit x = 0, yf = 0)
module blind_wand_v(u) { translate([x_end, y_main[0] + u, 0]) rotate([0, 0, 90]) children(); }

module blind_oeffnung(Wi, zb, zsp) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    translate([0, 0, -GEWAENDE_STUFE])                      // äußere Stufe (Bogenfries-Seite)
        linear_extrude(GEWAENDE_STUFE + pmax + 0.05) tuer_arch2d(Wo, zb, zsp);
    translate([0, 0, -BLIND_TIEFE])                         // innere Nische, schmaler, blind
        linear_extrude(BLIND_TIEFE - GEWAENDE_STUFE + eps) tuer_arch2d(Wi, zb, zsp);
}

module blind_oeffnungen() {
    if (BLIND_FENSTER) for (u = blind_f_u) blind_wand(u) blind_oeffnung(f_Wi, z_fsil, z_fsp);
    if (BLIND_TUER)    for (u = blind_t_u) blind_wand(u) blind_oeffnung(tuer_Wi, z_pod, z_tsp);
}

// gelbe Haut in der Nische (äußere Laibung, Stufenfläche, innere Laibung, Rückwand)
module blind_laibung_formen(Wi, zb, zsp, e) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(GEWAENDE_STUFE)
        difference() { tuer_arch2d(Wo, zb, zsp); tuer_arch2d(Wo - 2*e, zb - 0.1, zsp); }
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(e)
        difference() { tuer_arch2d(Wo - 2*e, zb, zsp); tuer_arch2d(Wi, zb - 0.1, zsp); }
    translate([0, 0, -BLIND_TIEFE]) linear_extrude(BLIND_TIEFE - GEWAENDE_STUFE + e)
        difference() { tuer_arch2d(Wi, zb, zsp); tuer_arch2d(Wi - 2*e, zb - 0.1, zsp); }
    translate([0, 0, -BLIND_TIEFE]) linear_extrude(e) tuer_arch2d(Wi, zb, zsp);   // Rückwand
}

// rote Schichten des Traufschemas laufen in die Nische hinein
module blind_streifen(Wi, zb, zsp) {
    for (i = [0 : len(TRAUFE_SCHEMA) - 1])
        let(typ = TRAUFE_SCHEMA[i][0], k = lauf_n(TRAUFE_SCHEMA, i),
            z0 = z_y0 + k * Z_PZ, z1 = z0 + sch_n(TRAUFE_SCHEMA[i]) * Z_PZ - Z_FUGE)
            if ((typ == "r" || typ == "v") && k * Z_PZ > 0 && z1 > zb && z0 < zsp + Wi / 2)
                intersection() {
                    blind_laibung_formen(Wi, zb, zsp, tuer_e + 0.004);
                    translate([-5, z0, -1]) cube([10, z1 - z0, 2]);
                }
}

module blind_element(u, Wi, zb, zsp, schmal, Rb) {
    color(C_BOGEN) blind_wand_v(u) rb_bogenfries(0, 0, Wi, zsp, schmal, false, Rb);
    if (FUGEN_GRAU) color(C_FUGE) blind_wand_v(u) rb_bogenfries(0, 0, Wi, zsp, schmal, true, Rb);
    blind_wand(u) {
        color(C_KLINKER) blind_laibung_formen(Wi, zb, zsp, tuer_e);
        color(C_BAND)    blind_streifen(Wi, zb, zsp);
    }
}

module blind_objekte() {
    if (BLIND_FENSTER) for (u = blind_f_u)
        blind_element(u, f_Wi, z_fsil, z_fsp, FENSTER_BOGEN_SCHMAL, FENSTER_BOGEN_BREITE);
    if (BLIND_TUER) for (u = blind_t_u)
        blind_element(u, tuer_Wi, z_pod, z_tsp, TUER_BOGEN_SCHMAL, BOGEN_BREITE);
}

// ============================================================
// Eingangsrisalit (Front, -y): drei Türen mit gemeinsamer Treppe, vier Fenster im 1. OG.
// Alles wird mit den Modulen und Maßen der Tür bzw. des Fensters im rechten Flügel gebaut
// (Stufengewände, Bogenfries, durchlaufende rote Streifen, Türblatt, Schild, Klinke, Geländer).
// Anordnung symmetrisch zur Risalitmitte, Abstand der Öffnungen = RIS_PFEILER zwischen den
// äußeren Öffnungskanten.
// ============================================================
ris_xc     = x_ris_m;                                     // Giebelachse des Risalits (Mitte der vollen Breite, nicht des sichtbaren Teils)
ris_yf     = y_ris[0];                                    // Front des Risalits
ris_tuer_ab = tuer_Wo + RIS_PFEILER;                      // Abstand Mitte-Mitte der Türen
ris_fen_ab  = f_Wo + RIS_PFEILER;                         // Abstand Mitte-Mitte der Fenster
ris_tuer_x  = [for (i = [-1 : 1]) ris_xc + i * ris_tuer_ab];
ris_fen_x   = [for (k = [-1.5, -0.5, 0.5, 1.5]) ris_xc + k * ris_fen_ab];
ris_podest_hw = ris_tuer_ab + tuer_Wo / 2 + PODEST_UEBERSTAND;   // halbe Breite von Podest und Treppe

module ris_oeffnungen() {
    if (RIS_TUEREN)  for (x = ris_tuer_x) rb_oeffnung(x, ris_yf, tuer_Wi, z_pod, z_tsp);
    if (RIS_FENSTER) for (x = ris_fen_x)  rb_oeffnung(x, ris_yf, f_Wi, z_fsil, z_fsp);
}

// Schriftzug: erhabene schwarze Fraktur auf der gelben Wand zwischen Türbögen und rotem Streifen
module ris_schriftzug() {
    color("black")
    multmatrix(m_v(ris_xc, ris_yf)) translate([0, SCHRIFT_Z, -0.02])
        linear_extrude(SCHRIFT_ERHABEN_MM * M / 1000 + 0.02)
            resize([SCHRIFT_BREITE, SCHRIFT_HOEHE])
                text(SCHRIFT_TEXT, size = 1, font = SCHRIFT_FONT, halign = "center", valign = "center");
}

// ------------------------------------------------------------
// Gleisseitiger Mittelrisalit (Giebelfront y_rh[1], außen +y): zwei Türen im Erdgeschoss, drei Fenster im 1. OG.
// Türen und Fenster sind die der Straßenseite (gleiche Maße, Höhen, Türabstand und Fensterabstand), jeweils
// mittig auf dem Risalit. Lokales Wandsystem wie an der Front (außen = -y), um 180° um die Risalitmitte gedreht;
// die Anordnung ist symmetrisch. Die Straßenseite hat vier Fenster, hier sind es wie gewünscht drei.
// Der Bahnsteig liegt nur knapp unter der Türschwelle, daher statt Podest und Treppe eine Betonstufe.
// ------------------------------------------------------------
RIS_H_TUEREN  = true;
RIS_H_FENSTER = true;
RIS_H_STUFE   = true;
ris_h_xm    = (ris_h_x0 + ris_h_x1) / 2;
ris_h_tuer  = [-ris_tuer_ab / 2, ris_tuer_ab / 2];             // zwei Türen, Abstand wie straßenseitig (Mitte zu Mitte)
ris_h_fen   = [-ris_fen_ab, 0, ris_fen_ab];                    // drei Fenster, Abstand wie straßenseitig

module ris_h_oeffnungen() {
    pav_rueck(ris_h_xm, y_rh[1]) {
        if (RIS_H_TUEREN)  for (u = ris_h_tuer) rb_oeffnung(u, 0, tuer_Wi, z_pod, z_tsp);
        if (RIS_H_FENSTER) for (u = ris_h_fen)  rb_oeffnung(u, 0, f_Wi, z_fsil, z_fsp);
    }
}
module ris_h_objekte() {
    pav_rueck(ris_h_xm, y_rh[1]) {
        if (RIS_H_TUEREN) {
            for (i = [0 : len(ris_h_tuer) - 1])
                tuer_einzel(ris_h_tuer[i], 0, true, i == 0 ? 100 : ris_tuer_ab / 2, i == len(ris_h_tuer) - 1 ? 100 : ris_tuer_ab / 2,
                            GLEIS_TUER_OFFEN[i][0], GLEIS_TUER_OFFEN[i][1]);
            if (RIS_H_STUFE)
                color(C_BETON) translate([ris_h_tuer[0] - tuer_Wo / 2 - 0.25, -0.40, 0])
                    cube([ris_h_tuer[1] - ris_h_tuer[0] + tuer_Wo + 0.50, 0.42, z_pod]);
        }
        if (RIS_H_FENSTER) for (i = [0 : len(ris_h_fen) - 1]) fenster_objekte(ris_h_fen[i], 0, GLEIS_FENSTER_OFFEN[i]);
    }
}

module ris_objekte() {
    if (RIS_TUEREN) {
        color(C_BETON) podest_treppe(ris_xc, ris_yf, ris_podest_hw);
        if (GELAENDER) color(C_GELAENDER) gelaender(ris_xc, ris_yf, ris_podest_hw);
        for (i = [0 : len(ris_tuer_x) - 1])               // äußere Türen: Bogenfries außen nicht beschneiden
            tuer_einzel(ris_tuer_x[i], ris_yf, true,
                        i == 0 ? 100 : ris_tuer_ab / 2,
                        i == len(ris_tuer_x) - 1 ? 100 : ris_tuer_ab / 2,
                        STRASSE_TUER_OFFEN[i][0], STRASSE_TUER_OFFEN[i][1]);
    }
    if (SCHRIFT) ris_schriftzug();
    if (RIS_FENSTER) for (x = ris_fen_x) fenster_objekte(x, ris_yf);
}

// ============================================================
// Türmchen vor dem linken Flügel: Fenster und Tür an der linken Seite (Außenfläche -x)
// Es werden dieselben Module und Maße wie bei Tür und Fenster im rechten Flügel benutzt
// (Stufengewände, Bogenfries, durchlaufende rote Streifen, Türblatt, Schild, Klinke, Podest,
// Treppe, Geländer). Das lokale Wandsystem wird dazu um 90° auf die linke Seite gedreht:
// Seitenmitte = Ursprung (x = 0, yf = 0), Breite entlang der Seite, "vorn" = nach -x.
// ============================================================
module tt_wand() { translate([x_tt0, tt_yc, 0]) rotate([0, 0, -90]) children(); }

// Fenster: Sohle auf dem zweiten roten Streifen, Scheitel des Bogenfrieses unter der Reihe TT_FENSTER_K_OBEN
// (im Foto sitzt es deutlich tiefer als die Fenster im Mittelrisalit).
TT_FENSTER_K_SOHLE = tt_k_streifen;     // erste gelbe Reihe über dem zweiten roten Streifen (Reihe 25)
TT_FENSTER_K_OBEN  = 51;
tt_fsil = z_y0 + TT_FENSTER_K_SOHLE * Z_PZ;
tt_ftop = z_y0 + TT_FENSTER_K_OBEN * Z_PZ - Z_FUGE;
tt_fsp  = tt_ftop - FENSTER_BOGEN_BREITE - f_Wo / 2;
// Tür (nach Foto): gerade Tür mit Sturz aus hochkant gestellten Ziegeln, unten Füllung, oben Glasfläche mit Sprosse
TT_TUER_K_OBEN   = 15;                  // Oberkante der Öffnung unter Ziegelreihe 15 (ab Beginn des gelben Mauerwerks)
TT_TUER_FUELLUNG = 0.90;                // Höhe der geschlossenen Füllung über der Schwelle
TT_TUER_SPROSSEN = 1;                   // waagerechte Sprossen in der Glasfläche
tt_tur_top = z_y0 + TT_TUER_K_OBEN * Z_PZ - Z_FUGE;
tt_tur_h   = tt_tur_top - z_pod;        // lichte Höhe (rund 2,10 m)

module tt_oeffnungen() {
    tt_wand() {
        if (TT_TUER)
            multmatrix(m_v(0, 0)) translate([-TT_TUER_WI / 2, z_pod, -t - eps])
                cube([TT_TUER_WI, tt_tur_h, t + 2*eps + pmax + 0.05]);
        if (TT_FENSTER) rb_oeffnung(0, 0, f_Wi, tt_fsil, tt_fsp);
    }
}

module tt_tuer() {
    Wi = TT_TUER_WI;  h = tt_tur_h;  fr = 0.07;  sb = 0.04;  d = 0.06;  hu = TT_TUER_FUELLUNG;
    n  = stz_n(Wi);  Ws = stz_w(Wi);  bp = Z_H + Z_FUGE;
    hs = TURM_STURZ_ZEILEN * Z_PZ - Z_FUGE;  zs0 = z_y0 + TT_TUER_K_OBEN * Z_PZ;
    module sturz_fugen() {
        for (i = [1 : n - 1])
            translate([-Ws/2 + i * bp - Z_FUGE, zs0, pbog - fd]) cube([Z_FUGE, hs, fd + eps]);
    }
    multmatrix(m_v(0, 0)) {
        // Sturz über der Tür
        color(C_STURZ) difference() {
            translate([-Ws/2, zs0, -0.02]) cube([Ws, hs, pbog + 0.02]);
            if (ZIEGEL) sturz_fugen();
        }
        if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) sturz_fugen();
        // Türblatt, zurückgesetzt in der Öffnung
        translate([0, 0, -0.12]) color(C_TUER) {
            difference() {                                                                   // Rahmen
                translate([-Wi/2, z_pod, 0]) cube([Wi, h, d]);
                translate([-Wi/2 + fr, z_pod + fr, -eps]) cube([Wi - 2*fr, h - 2*fr, d + 2*eps]);
            }
            translate([-Wi/2, z_pod, 0]) cube([Wi, hu, d * 0.8]);                           // geschlossene Füllung unten
            translate([-Wi/2, z_pod + hu - 0.03, 0]) cube([Wi, 0.06, d]);                   // Querholz über der Füllung
            for (q = [1 : TT_TUER_SPROSSEN])                                                // Sprossen in der Glasfläche
                translate([-Wi/2, z_pod + hu + q * (h - hu) / (TT_TUER_SPROSSEN + 1) - sb/2, 0])
                    cube([Wi, sb, d * 0.8]);
            translate([Wi/2 - fr - 0.07, z_pod + 1.00, d]) cube([0.04, 0.12, 0.04]);        // Klinke
        }
    }
}

module tt_objekte() {
    tt_wand() {
        if (TT_TUER) {
            color(C_BETON) podest_treppe(0, 0, tt_podest_hw);
            if (GELAENDER) color(C_GELAENDER) gelaender(0, 0, tt_podest_hw);
            tt_tuer();
        }
        if (TT_FENSTER) {
            color(C_BOGEN) rb_bogenfries(0, 0, f_Wi, tt_fsp, FENSTER_BOGEN_SCHMAL, false, FENSTER_BOGEN_BREITE);
            if (FUGEN_GRAU)
                color(C_FUGE) rb_bogenfries(0, 0, f_Wi, tt_fsp, FENSTER_BOGEN_SCHMAL, true, FENSTER_BOGEN_BREITE);
            color(C_KLINKER) rb_laibung(0, 0, f_Wi, tt_fsil, tt_fsp);
            zw_blatt(0, 0, f_Wi, tt_fsil, tt_fsp, 0, true, OG_QUERSPROSSEN);
            if (OG_BANK) zw_fensterbank(0, 0, f_Wi, tt_fsil);
        }
    }
}

// ============================================================
// Zwischengebäude: zwei Fenster in der Front (Außenfläche -y, in einer Flucht mit dem Hauptgebäude)
// Wie die Türen des Mittelrisalits: Stufengewände, Bogenfries, gelbe Laibung, durchlaufende rote Streifen.
// Unterkante des Fensters = Oberkante des Sockelbereichs (zw_zb). Das äußere (zurückspringende) Gewände
// reicht darunter noch ZW_SOCKEL_REIHEN Reihen weit ins rote Sockelband (zw_zbn) als Nische.
// ============================================================
zw_fx = [for (q = [0.25, 0.75]) x_zw0 + q * ((TUERMCHEN ? x_tt0 : x_zw1) - x_zw0)];   // symmetrisch im sichtbaren Teil der Front (das Türmchen steht ein Stück davor)   // Fenstermitten, symmetrisch auf der Front

// Öffnung: äußere Stufe (Nische) von zbn bis zum Bogen, innere Öffnung (Fenster) von zb bis zum Bogen
module zw_oeffnung(x, yf, Wi, zb, zbn, zsp) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    multmatrix(m_v(x, yf)) {
        translate([0, 0, -GEWAENDE_STUFE])
            linear_extrude(GEWAENDE_STUFE + pmax + 0.05) tuer_arch2d(Wo, zbn, zsp);
        translate([0, 0, -t - eps])
            linear_extrude(t - GEWAENDE_STUFE + 2*eps + 0.01) tuer_arch2d(Wi, zb, zsp);
    }
}
module zw_oeffnungen() { fenster_reihe_oeffnungen(zw_fx, y_wing[0]); }
module pav_oeffnungen() { fenster_reihe_oeffnungen(pav_fx, y_pav[0]); }
module fenster_reihe_oeffnungen(xs, yf) {     // Fenster wie im Zwischengebäude, auf der Front bei yf
    for (x = xs) zw_oeffnung(x, yf, ZW_FENSTER_WI, zw_zb, zw_zbn, zw_zsp);
}

// Haut der Laibung (äußere Laibung, Stufenfläche auch unter dem Fenster, innere Laibung)
module zw_laibung_formen(Wi, zb, zbn, zsp, e) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(GEWAENDE_STUFE)
        difference() { tuer_arch2d(Wo, zbn, zsp); tuer_arch2d(Wo - 2*e, zbn - 0.1, zsp); }
    translate([0, 0, -GEWAENDE_STUFE]) linear_extrude(e)
        difference() { tuer_arch2d(Wo - 2*e, zbn, zsp); tuer_arch2d(Wi, zb, zsp); }
    translate([0, 0, -t]) linear_extrude(t - GEWAENDE_STUFE + e)
        difference() { tuer_arch2d(Wi, zb, zsp); tuer_arch2d(Wi - 2*e, zb - 0.1, zsp); }
}
// gelb ab der Fensterunterkante, rot (wie das Sockelband) in der Nische darunter
module zw_laibung(x, yf, Wi, zb, zbn, zsp) {
    multmatrix(m_v(x, yf)) {
        color(C_KLINKER) intersection() {
            zw_laibung_formen(Wi, zb, zbn, zsp, tuer_e);
            translate([-5, zb, -1]) cube([10, zsp + Wi + 1, 2]);
        }
        color(C_BAND) intersection() {
            zw_laibung_formen(Wi, zb, zbn, zsp, tuer_e + 0.004);
            translate([-5, zbn - 0.2, -1]) cube([10, zb - zbn + 0.2, 2]);
        }
    }
}
// die roten Streifen des Zwischengebäudes laufen in die Laibung hinein
module zw_streifen(x, yf, Wi, zb, zbn, zsp) {
    for (i = [0 : len(ZW_SCHEMA) - 1])
        let(typ = ZW_SCHEMA[i][0], k = lauf_n(ZW_SCHEMA, i),
            z0 = z_y0 + k * Z_PZ, z1 = z0 + sch_n(ZW_SCHEMA[i]) * Z_PZ - Z_FUGE)
            if ((typ == "r" || typ == "v") && k > 0 && z1 > zb && z0 < zsp + Wi / 2)
                multmatrix(m_v(x, yf))
                    intersection() {
                        zw_laibung_formen(Wi, zb, zbn, zsp, tuer_e + 0.004);
                        translate([-5, z0, -1]) cube([10, z1 - z0, 2]);
                    }
}

// Umriss des Fensters (Rechteck + Halbkreis), inset > 0 verkleinert nach innen
module zw_form(inset, Wi, zb, zsp) {
    intersection() {
        union() {
            translate([-Wi/2 + inset, zb + inset]) square([Wi - 2*inset, zsp - zb - inset]);
            translate([0, zsp]) circle(r = Wi/2 - inset, $fn = 64);
        }
        translate([-10, zb + inset]) square([20, 20]);
    }
}
// Fensterflügel graugrün wie die übrigen Fenster: Rahmen, Kämpfer, Mittelpfosten, Quersprossen, Sprossenfuß
// pitch > 0: Quersprossen im festen Abstand pitch unterhalb des Bogenansatzes (für Fenster, die nach unten abgeschnitten werden)
// eg = true: Erdgeschossfenster (dicker Mittelpfosten mit Aufleiste, Kämpfer als U-Profil, 6 Scheiben, Halbkreis als Ring)
module zw_blatt(x, yf, Wi, zb, zsp, pitch = 0, eg = false, nq = EG_QUERSPROSSEN, offen = 0) {
    kb = eg ? EG_KAEMPFER : FENSTER_KAEMPFER;  fr = 0.07;  sb = 0.04;
    qs = eg && pitch > 0 ? [for (i = [1 : max(1, floor((zsp - kb - zb - 0.10) / pitch))]) zsp - kb - i * pitch]
        : eg ? [for (q = [1 : nq]) zb + q * (zsp - kb - zb) / (nq + 1)]
        : pitch > 0 ? [for (i = [1 : max(1, floor((zsp - zb - 0.10) / pitch))]) zsp - i * pitch]
                    : [for (q = [1 : ZW_QUERSPROSSEN]) zb + q * (zsp - zb) / (ZW_QUERSPROSSEN + 1)];
    zc = zsp + EG_BOGEN_HEBUNG;      // Mittelpunkt des Halbkreises (nur eg)
    module fuss() {
        intersection() {
            translate([0, zsp]) circle(r = SPROSSENFUSS, $fn = 32);
            translate([-1, zsp - 0.005]) square([2, 1]);
        }
    }
    // Halbkreis als Ring (innen offen), Stege bis zum Kämpfer
    module bogenring() {
        R = EG_BOGEN_R;  rr = EG_BOGEN_RING;
        intersection() {
            difference() {
                translate([0, zc]) circle(r = R, $fn = 64);
                translate([0, zc]) circle(r = R - rr, $fn = 64);
            }
            translate([-R - 1, zc]) square([2 * R + 2, R + 1]);
        }
        for (sx = [-1, 1])
            translate([sx * (R - rr / 2) - rr / 2, zsp - 0.005]) square([rr, zc - zsp + 0.01]);
    }
    multmatrix(m_v(x, yf)) translate([0, 0, f_w0]) {
        color(C_TUER) {
            linear_extrude(f_d) {
                difference() { zw_form(-0.01, Wi, zb, zsp); zw_form(fr, Wi, zb, zsp); }                                   // Rahmen
                intersection() { zw_form(-0.01, Wi, zb, zsp); translate([-Wi/2, zsp - kb]) square([Wi, kb]); }          // Kämpfer
                if (eg) {
                    if (offen <= 0) intersection() {                                                                    // dicker Mittelpfosten
                        zw_form(-0.01, Wi, zb, zsp);
                        translate([-EG_PFOSTEN_B/2, zb]) square([EG_PFOSTEN_B, zsp - kb - zb]);
                    }
                    intersection() {                                                                                    // dünne Sprosse im Bogen
                        zw_form(-0.01, Wi, zb, zsp);
                        translate([-EG_SPROSSE_B/2, zc + EG_BOGEN_R - EG_BOGEN_RING / 2]) square([EG_SPROSSE_B, 10]);
                    }
                    bogenring();
                } else
                    intersection() { zw_form(-0.01, Wi, zb, zsp); translate([-0.03, zb]) square([0.06, 10]); }          // Mittelpfosten
                if (!(eg && offen > 0)) for (zq = qs)                                                                   // Quersprossen (bei offenen Flügeln gehören sie zu den Flügeln)
                    intersection() {
                        zw_form(-0.01, Wi, zb, zsp);
                        translate([-Wi/2, zq - sb/2]) square([Wi, sb]);
                    }
                if (!eg) fuss();                                                                                         // Sprossenfuß
            }
            if (eg) {
                // Aufleisten stehen vor dem Rahmen: auf dem Mittelpfosten, oben und unten am Kämpfer (U-Profil)
                translate([0, 0, f_d]) linear_extrude(EG_AUFL_V) {
                    if (offen <= 0) translate([-EG_PFOSTEN_AUFL_B/2, zb + fr]) square([EG_PFOSTEN_AUFL_B, zsp - kb - zb - fr]);
                    translate([-Wi/2 + fr, zsp - EG_KAEMPFER_AUFL]) square([Wi - 2*fr, EG_KAEMPFER_AUFL]);
                    translate([-Wi/2 + fr, zsp - kb]) square([Wi - 2*fr, EG_KAEMPFER_AUFL]);
                }
            } else
                translate([0, 0, f_d]) linear_extrude(0.02) fuss();                                                      // Fuß steht vor
        }
        if (eg && offen > 0) zw_offene_fluegel(Wi, zb, zsp, kb, fr, nq, offen);
        if (FENSTER_VERGLASUNG)
            color(C_GLAS) translate([0, 0, f_d/2 - 0.005]) linear_extrude(0.01) zw_form(fr - 0.005, Wi, zb, zsp);
    }
}

// Zwei Fensterflügel (unterer, rechteckiger Teil unter dem Kämpfer) nach außen aufgeklappt, Scharnier am Gewände (innerer Rahmenrand).
// Innen (Rückseite, zeigt im offenen Zustand zur Fenstermitte) sitzt an jedem Flügel am freien Stil ein Fenstergriff (Olive).
// Lokales System wie zw_blatt: Rückseite des Rahmens bei w = 0, Vorderseite bei f_d.
module zw_offene_fluegel(Wi, zb, zsp, kb, fr, nq, ang) {
    zl = zb + fr;  zu = zsp - kb;  hh = zu - zl;
    st = 0.04;  mid = EG_PFOSTEN_B / 2;            // Stilbreite, halber Mittelstil (freier Stil)
    wl = Wi / 2 - fr;                              // Flügelbreite
    zmitte = zl + hh / 2;
    module fluegel2d(sx) {                         // sx = -1 linker, +1 rechter Flügel; Mitte bei u = 0
        difference() {
            translate([sx < 0 ? -wl : 0, zl]) square([wl, hh]);
            translate([sx < 0 ? -wl + st : mid, zl + st]) square([wl - st - mid, hh - 2*st]);
        }
        for (q = [1 : nq])
            translate([sx < 0 ? -wl : 0, zl + q * hh / (nq + 1) - 0.02]) square([wl, 0.04]);
    }
    for (sx = [-1, 1]) {
        hu = sx * (Wi / 2 - fr);                   // Scharnierachse (Rand des Flügels am Rahmen)
        translate([hu, 0, f_d / 2]) rotate([0, sx * ang, 0]) translate([-hu, 0, -f_d / 2]) {
            color(C_TUER) linear_extrude(f_d) fluegel2d(sx);
            // Aufleiste am freien Stil des linken Flügels (Außenseite)
            if (sx < 0) color(C_TUER) translate([-EG_PFOSTEN_AUFL_B, zl + 0.03, f_d]) cube([EG_PFOSTEN_AUFL_B, hh - 0.06, EG_AUFL_V]);
            // Fenstergriff innen (Rückseite, z < 0): Rosette und Hebel nach unten
            color(C_BESCHLAG) translate([sx * mid / 2, zmitte, 0]) {   // Mitte des freien Stils
                translate([0, 0, -0.012]) cylinder(r = 0.018, h = 0.012, $fn = 24);
                hull() {
                    translate([0, 0, -0.026]) cylinder(r = 0.008, h = 0.014, $fn = 16);
                    translate([0, -0.075, -0.026]) cylinder(r = 0.006, h = 0.014, $fn = 16);
                }
            }
        }
    }
}

// Fensterbank: flach liegende Ziegel, nebeneinander gereiht, die schmale Seite (Kopf, 12 x 6,5 cm) zeigt nach vorn.
// Sie liegt in der Nische unter dem Fenster (Oberkante = Fensterunterkante zb), über die ganze Nischenbreite, und steht
// EG_BANK_VORSPRUNG vor die Wandfläche. Grauer Fugengrund dahinter.
module zw_fensterbank(x, yf, Wi, zb) {
    Wo = Wi + 2 * GEWAENDE_STUFE;
    bw = EG_BANK_STEIN_B;  bp = bw + Z_FUGE;
    n  = ceil((Wo + Z_FUGE) / bp);
    L  = n * bp - Z_FUGE;
    w0 = -GEWAENDE_STUFE;  wl = EG_BANK_VORSPRUNG - w0;
    multmatrix(m_v(x, yf)) {
        if (FUGEN_GRAU)
            color(C_FUGE) translate([-L/2, zb - EG_BANK_HOEHE + 0.003, w0]) cube([L, EG_BANK_HOEHE - 0.006, wl - 0.004]);
        color(C_BAND)
            for (i = [0 : n - 1])
                translate([-L/2 + i * bp, zb - EG_BANK_HOEHE, w0]) cube([bw, EG_BANK_HOEHE, wl]);
    }
}

module zw_objekte()  { fenster_reihe_objekte(zw_fx, y_wing[0]); }
module pav_objekte() { fenster_reihe_objekte(pav_fx, y_pav[0], PAV_FENSTER_ABSTAND); }
// ab > 0: Mitte-Mitte-Abstand dicht stehender Fenster; die Bogenfriese treffen sich dann in der Pfeilermitte (wie bei den Türen)
module zw_fenster_einzel(x, yf, kl = 100, kr = 100) {   // ein Fenster mit Bogenfries, Laibung, Streifen, Flügel
    color(C_BOGEN) clipx(x, yf, kl, kr)
        rb_bogenfries(x, yf, ZW_FENSTER_WI, zw_zsp, ZW_BOGEN_SCHMAL, false, ZW_BOGEN_BREITE);
    if (FUGEN_GRAU)
        color(C_FUGE) clipx(x, yf, kl, kr)
            rb_bogenfries(x, yf, ZW_FENSTER_WI, zw_zsp, ZW_BOGEN_SCHMAL, true, ZW_BOGEN_BREITE);
    zw_laibung(x, yf, ZW_FENSTER_WI, zw_zb, zw_zbn, zw_zsp);
    color(C_BAND) zw_streifen(x, yf, ZW_FENSTER_WI, zw_zb, zw_zbn, zw_zsp);
    zw_blatt(x, yf, ZW_FENSTER_WI, zw_zb, zw_zsp, 0, true);
    if (EG_BANK) zw_fensterbank(x, yf, ZW_FENSTER_WI, zw_zb);
}
module fenster_reihe_objekte(xs, yf, ab = 0) {
    for (i = [0 : len(xs) - 1])
        zw_fenster_einzel(xs[i], yf,
                          (ab > 0 && i > 0) ? ab / 2 : 100,
                          (ab > 0 && i < len(xs) - 1) ? ab / 2 : 100);
}

// ------------------------------------------------------------
// Pavillon, Gleisseite (Rückwand y_pav[1], außen +y): dieselben drei Fensterachsen wie an der Straßenseite,
// das mittlere Fenster ist eine Tür (Maße und Aufbau wie die Türen des Eingangsrisalits; die Fenster sind
// genauso breit, Bogenansatz und Bogenfries liegen auf gleicher Höhe).
// Lokales Wandsystem wie an der Front (außen = -y), um 180° um die Mitte der Rückwand gedreht. Die Anordnung
// ist symmetrisch zur Mitte, die Spiegelung entspricht also genau der Straßenseite.
// ------------------------------------------------------------
pav_ru = [-PAV_FENSTER_ABSTAND, 0, PAV_FENSTER_ABSTAND];   // lokale Mitten der drei Öffnungen
// Dieselbe Anordnung (Fenster, Tür, Fenster) trägt auch die Gleisseite des Zwischengebäudes (Rückwand y_wing[1]).
// xm = Mitte der Wand, y = Rückwandebene, tuer = mittlere Öffnung als Tür, stufe = Betonstufe vor der Tür.
ZW_RUECK_FENSTER       = true;             // Zwischengebäude, Gleisseite: Fenster, Tür, Fenster
ZW_RUECK_TUER          = true;
ZW_RUECK_STUFE         = true;
zw_xm = (x_zw0 + x_zw1) / 2;
module pav_rueck(xm = pav_xm, y = y_pav[1]) { translate([xm, y, 0]) rotate([0, 0, 180]) children(); }

module rueck_oeffnungen(xm, y, tuer, ab = PAV_FENSTER_ABSTAND) {   // ab = Abstand Mitte zu Mitte der drei Öffnungen
    pav_rueck(xm, y) for (i = [0 : 2]) {
        if (tuer && i == 1) rb_oeffnung(ab * (i - 1), 0, tuer_Wi, z_pod, z_tsp);
        else zw_oeffnung(ab * (i - 1), 0, ZW_FENSTER_WI, zw_zb, zw_zbn, zw_zsp);
    }
}
module rueck_objekte(xm, y, tuer, stufe, ab = PAV_FENSTER_ABSTAND) {
    pav_rueck(xm, y) for (i = [0 : 2]) {
        u  = ab * (i - 1);
        kl = i > 0 ? ab / 2 : 100;        // Bogenfriese benachbarter Öffnungen treffen sich in der Pfeilermitte
        kr = i < 2 ? ab / 2 : 100;
        if (tuer && i == 1) {
            tuer_einzel(u, 0, true, kl, kr);
            if (stufe)
                color(C_BETON) translate([u - tuer_Wo / 2 - 0.25, -0.40, 0])
                    cube([tuer_Wo + 0.50, 0.42, z_pod]);
        } else
            zw_fenster_einzel(u, 0, kl, kr);
    }
}
module pav_rueck_oeffnungen() { rueck_oeffnungen(pav_xm, y_pav[1], PAV_RUECK_TUER); }
module pav_rueck_objekte()    { rueck_objekte(pav_xm, y_pav[1], PAV_RUECK_TUER, PAV_RUECK_STUFE); }
module zw_rueck_oeffnungen()  { rueck_oeffnungen(zw_xm, y_wing[1], ZW_RUECK_TUER); }
module zw_rueck_objekte()     { rueck_objekte(zw_xm, y_wing[1], ZW_RUECK_TUER, ZW_RUECK_STUFE); }

// Rechter Flügel des Hauptgebäudes, Gleisseite (Rückwand y_main[1]): Fenster, Tür, Fenster auf dem Wandstück zwischen
// dem gleisseitigen Mittelrisalit und der Giebelwand bei x_end (von der Gleisseite gesehen liegt es links vom Risalit).
// Fensterform wie an der Straßenseite des Pavillons (Nische mit Ausfachung im roten Sockelband).
// Die Kombination steht bewusst NICHT mittig: Neben dem Risalit bleibt nur ein schmaler Rand (RW_RUECK_RAND_INNEN, ein
// Pfeiler wie zwischen den Öffnungen), der breitere Rest liegt außen zur Giebelwand hin.
RW_RUECK_FENSTER    = true;
RW_RUECK_TUER       = true;
RW_RUECK_STUFE      = true;
RW_RUECK_ABSTAND    = PAV_FENSTER_ABSTAND;   // Mitte zu Mitte
RW_RUECK_RAND_INNEN = RIS_PFEILER;           // Mauerwerk zwischen Risalit und der ersten Öffnung (bis Nischenkante)
rw_xm = ris_h_x1 + RW_RUECK_RAND_INNEN + tuer_Wo / 2 + RW_RUECK_ABSTAND;   // Mitte der Tür
module rw_rueck_oeffnungen() { rueck_oeffnungen(rw_xm, y_main[1], RW_RUECK_TUER, RW_RUECK_ABSTAND); }
module rw_rueck_objekte()    { rueck_objekte(rw_xm, y_main[1], RW_RUECK_TUER, RW_RUECK_STUFE, RW_RUECK_ABSTAND); }

// Linker Flügel des Hauptgebäudes, Gleisseite (Rückwand y_main[1]): dieselbe Kombination, spiegelbildlich zum rechten Flügel.
// Das Wandstück reicht von der Giebelwand x_lw0 bis zum gleisseitigen Risalit (ris_h_x0) und ist wie beim rechten Flügel 6,70 m
// breit (nicht nur bis x_tow1: zwischen x_tow1 und ris_h_x0 liegen noch 0,99 m Rückwand). Gleiche Maße wie rechts:
// schmaler Rand am Risalit (RW_RUECK_RAND_INNEN), breiter Rest außen zur Giebelwand hin.
LW_RUECK_FENSTER    = true;
LW_RUECK_TUER       = true;
LW_RUECK_STUFE      = true;
LW_RUECK_RAND       = Z_PX / 2;                         // Rand innen und außen: ein Halbziegel (Wandstück nur noch e1 = 5,59 m breit)
LW_RUECK_ABSTAND    = (ris_h_x0 - x_lw0 - 2 * LW_RUECK_RAND - tuer_Wo) / 2;   // Mitte zu Mitte, so dass Fenster-Tür-Fenster auf das Wandstück passen
lw_xm = ris_h_x0 - LW_RUECK_RAND - tuer_Wo / 2 - LW_RUECK_ABSTAND;   // Mitte der Tür
module lw_rueck_oeffnungen() { rueck_oeffnungen(lw_xm, y_main[1], LW_RUECK_TUER, LW_RUECK_ABSTAND); }
module lw_rueck_objekte()    { rueck_objekte(lw_xm, y_main[1], LW_RUECK_TUER, LW_RUECK_STUFE, LW_RUECK_ABSTAND); }

// ------------------------------------------------------------
// Gleisseite, 1. OG von linkem und rechtem Flügel (Rückwand y_main[1]): je zwei Fenster wie im gleisseitigen
// Mittelrisalit (f_Wi, z_fsil, z_fsp, Bogenfries, Laibung, Rahmen). Sie stehen mittig über den beiden Fenstern des
// Erdgeschosses (Achsen i = 0 und 2 der Kombination Fenster, Tür, Fenster), also kein Fenster über der Tür.
// ------------------------------------------------------------
OG_RUECK_FENSTER = true;
og_fluegel = [[rw_xm, RW_RUECK_ABSTAND],     // rechter Flügel
              [lw_xm, LW_RUECK_ABSTAND]];    // linker Flügel (gleiche Maße, gespiegelt)
module og_rueck_oeffnungen() {
    for (g = og_fluegel) pav_rueck(g[0], y_main[1])
        for (u = [-g[1], g[1]]) rb_oeffnung(u, 0, f_Wi, z_fsil, z_fsp);
}
module og_rueck_objekte() {
    for (g = og_fluegel) pav_rueck(g[0], y_main[1])
        for (u = [-g[1], g[1]]) fenster_objekte(u, 0);
}

// ------------------------------------------------------------
// Bogenförmiger Zierfries des Pavillons (Rundbogenfries auf gestuften Konsolen), ZF_ZEILEN Reihen hoch.
// Konsolen im Abstand ZF_RASTER, symmetrisch zur Wandmitte (auf der Front zwischen den Fenstern, an den
// Enden angeschnittene Felder). Zwischen je zwei Konsolen spannt ein flacher Bogenring (eine Rollschicht).
// 2D-Koordinaten: u entlang der Wand ab linker Kante, v ab Unterkante des Zierfrieses.
// ------------------------------------------------------------
module zf_konsole2d() {                     // gestuft: unten schmal, oben breit
    n = ZF_KONSOLEN_ZEILEN;
    for (r = [0 : n - 1])
        translate([-ZF_KONSOLE_B * (r + 1) / n / 2, r * Z_PZ]) square([ZF_KONSOLE_B * (r + 1) / n, Z_H]);
}
module zf_feld2d(P) {                       // Bogenring zwischen den Konsolen bei u = 0 und u = P
    ks = ZF_KONSOLEN_ZEILEN * Z_PZ;         // Bogenansatz
    hw = ZF_KONSOLE_B / 2;
    cw = P - 2 * hw;                        // Sehne
    h  = zf_H - ks;                         // Stichhöhe der Außenkante
    R  = (cw * cw / 4 + h * h) / (2 * h);
    intersection() {
        translate([P / 2, ks + h - R]) difference() {
            circle(r = R, $fn = 128);
            circle(r = R - ZF_RING, $fn = 128);
        }
        translate([hw, ks]) square([cw, h + 1]);
    }
}
module zf_wand2d(Lw) {
    N = max(1, round(Lw / ZF_RASTER));                   // Anzahl Bögen (Front/Rückseite: ZF_BOEGEN)
    P = Lw / N;                                          // Feldbreite, die Bögen füllen die Wand von Ecke zu Ecke
    intersection() {
        square([Lw, zf_H + 1]);
        union() {                                        // je eine halbe Konsole an den Ecken, dort treffen sich zwei Wände
            for (m = [0 : N])     translate([m * P, 0]) zf_konsole2d();
            for (m = [0 : N - 1]) translate([m * P, 0]) zf_feld2d(P);
        }
    }
}
module zf_wand3d(mat, Lw) {
    multmatrix(mat) translate([0, zf_z0, -0.02]) linear_extrude(ZF_VORSPRUNG + 0.02) zf_wand2d(Lw);
}
module pav_zierfries() {
    zf_wand3d(m_v(x_pav0, y_pav[0]), x_pav1 - x_pav0);        // Front
    zf_wand3d(m_h(x_pav1, y_pav[1]), x_pav1 - x_pav0);        // Rückseite
    zf_wand3d(m_l(y_pav[1], x_pav0), y_pav[1] - y_pav[0]);    // links
    zf_wand3d(m_r(y_pav[0], x_pav1), y_pav[1] - y_pav[0]);    // rechts
}

PAV_AUSSER = [for (i = [0 : len(bloecke_liste) - 1]) if (i != PAV_IDX) i];

// Rote Schichten und Zahnfries über dem Bogenfries des Pavillons
module pav_zahnfries() {
    let(z0_r1 = z_y0 + k_pav_r1 * Z_PZ, z1_r1 = z0_r1 + Z_PZ - Z_FUGE,
        z0_z  = z_y0 + k_pav_z  * Z_PZ, z1_z  = z0_z  + ZAHN_SCHICHTEN * Z_PZ - Z_FUGE,
        z0_r2 = z_y0 + k_pav_r2 * Z_PZ, z1_r2 = z0_r2 + Z_PZ - Z_FUGE) {
        // 1. Rote Ziegelreihe über der 1. gelben Reihe
        band(z0_r1, z1_r1, pf, nb + k_pav_r1, false, PAV_AUSSER, false);
        // Roter Zahnfries (3 Schichten)
        band(z0_z, z1_z, pf, nb + k_pav_z, false, PAV_AUSSER, false);
        fugen_alle($teil = "zahn", $bz0 = z0_z, $bz1 = z1_z, $zw = "ohne", $tt = "mit", $pav = "nur");
        // 2. Rote Ziegelreihe über dem Zahnfries
        band(z0_r2, z1_r2, pf, nb + k_pav_r2, false, PAV_AUSSER, false);
    }
}

// Zahnfries des Zwischengebäudes (waagerecht, nur dessen Wandflächen)
// Zahnfries unter dem Dach am linken Giebel des Zwischengebäudes (wie zahn_giebel_haupt): folgt beiden Dachkanten
module zahn_giebel_zw() {
    W  = y_wing[1] - y_wing[0];
    ca = cos(a_wing);  sa = sin(a_wing);
    L  = (W / 2) / ca;
    h  = ZAHN_SCHICHTEN * Z_PZ - Z_FUGE;
    v0 = h_wing - td - 0.01;
    multmatrix(m_l(y_wing[1], x_pav1)) {
        multmatrix([[ ca, -sa, 0, 0], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]]) fries_schraeg(L, h, 0);
        multmatrix([[-ca,  sa, 0, W], [sa, ca, 0, v0], [0, 0, 1, 0], [0, 0, 0, 1]]) fries_schraeg(L, h, 0);
    }
}
module zw_zahnfries(z0, z1, j0) {
    band(z0, z1, pf, j0, false, ZW_AUSSER, false);              // bündiger roter Grund nur am Zwischengebäude
    fugen_alle($teil = "zahn", $bz0 = z0, $bz1 = z1, $zw = "nur");
    zahn_giebel_zw();
}

// ============================================================
// Anbau links vom Pavillon: Fenster, Tür, Ziegeltreppe, Geländer
// Lokale Wandsysteme (wie m_v / m_l): u entlang der Wand, v = z, w nach außen
//   ann_fl_v: Front des vorderen Teils (außen -y),                  u = x - x_ann1 (nach rechts)
//   ann_fl_s: linke Wand (Sprungwand) des vorderen Teils (außen -x), u = y_anns - y
//   ann_fl_r: Front des zurückspringenden linken Teils (außen -y), nur die Tür (kein Fenster)  u = x - x_ann0
//   ann_fl_g: linke Giebelwand des linken Teils (außen -x),            u = y_ann[1] - y
// ============================================================
ANN_F_B       = 1.30;    // Gitterfenster in der Front: lichte Breite (am Foto gemessen: 1,29 / 1,35 / 1,32 m)
ANN_F_ABSTAND = 2.78;    // Mitte zu Mitte (Foto: 2,75 und 2,81 m)
ANN_F_VERSATZ = 0.45;    // mittleres Fenster liegt um so viel rechts (zum Pavillon) von der Mitte des vorderen Teils (Foto: Mitten bei 2,16 / 4,91 / 7,73 m von der linken Kante)
ANN_F_SOHLE   = 1.55;    // Sohle über Gelände (Foto: ca. 1,5 bis 1,6 m; wird ins Ziegelraster gerundet)
ANN_F_ZEILEN  = 23;      // Höhe in Ziegelreihen (Foto: ca. 1,7 m = 22,5 Reihen)
ANN_S_B       = 0.9;     // seitliches Fenster in der Sprungwand des vorderen Teils: Breite
ANN_S_SOHLE   = 3.0;     // Sohle (hoch gelegen)
ANN_S_ZEILEN  = 12;      // Höhe in Ziegelreihen
ANN_W_B       = 0.9;     // Gitterfenster in der linken Giebelwand: Breite
ANN_W_SOHLE   = 2.0;     // Sohle
ANN_W_ZEILEN  = 20;      // Höhe in Ziegelreihen
ANN_W_Y       = 2.0;     // Fenstermitte in der linken Giebelwand, gemessen ab der Front des linken Teils nach hinten
ANN_T_B       = 0.90;    // Tür: lichte Breite
ANN_T_X       = ANN_LINKS / 2;   // Türmitte, gemessen ab der linken Kante des linken Teils (mittig)
ANN_T_K_OBEN  = 12;      // Oberkante der Tür unter Ziegelreihe 12 (ab Beginn des gelben Mauerwerks)
ANN_T_FUELLUNG = 0.95;   // geschlossene Füllung unten im Türblatt
ANN_PODEST_ZEILEN     = 6;      // Podest: Höhe in Ziegelreihen
ANN_PODEST_TIEFE      = 1.0;    // Tiefe des Podests vor der Wand
ANN_PODEST_HW         = 0.75;   // halbe Breite von Podest und Treppe
ANN_TREPPE_STEIGUNGEN = 3;      // Steigungen vom Boden bis zum Podest (je 2 Ziegelreihen)
ANN_TREPPE_AUFTRITT   = 0.30;
ANN_GEL_HOEHE         = 0.90;   // Geländerhöhe über Podest / Stufen

// ---------- Gleisseite des Anbaus (Rückwand y_ann[1], außen +y): 5 Fenster ----------
ANBAU_RUECKFENSTER = true;
ANN_H_N         = 5;      // Anzahl Fenster
ANN_H_B         = 0.70;   // lichte Breite (Foto: ca. 0,69 m, aus der Ziegellänge)
ANN_H_RAND_PAV  = 1.60;   // Abstand des ersten Fensters zur Pavillonwand (bis Fensterkante); Foto: ca. 0,8 Fensterabstände
ANN_H_RAND_GIE  = 0.90;   // Abstand des letzten Fensters zur Giebelecke (x_ann0); Foto: ca. 0,45 Fensterabstände
ANN_H_ZEILEN_BS = 21;     // Fensterunterkante: Ziegelreihen über dem Bahnsteig (Foto: ca. 20 Reihen bis zur Unterkante der Rollschicht-Bank, plus Bank)
ANN_H_ZEILEN    = 16;     // Höhe der Fensteröffnung in Ziegelreihen (Foto: ca. 16 Reihen = 1,2 m)
ANN_H_ZEILEN_TR = 8;      // Ziegelreihen zwischen Traufkante (Wandkopf) und Oberkante der Fensteröffnung (der 3-reihige Sturz sitzt darin)
ANN_H_BANK_VOR  = 0.06;   // Vorsprung der Rollschicht-Fensterbank vor der Wand [m real]
// u wird von der Pavillonseite (x_pav0) nach links (Giebel x_ann0) gemessen
ann_fl_h = m_h(x_pav0, y_ann[1]);
ann_hw   = x_pav0 - x_ann0;                                              // Länge der Gleisseite des Anbaus
ann_hp   = (ann_hw - ANN_H_B - ANN_H_RAND_PAV - ANN_H_RAND_GIE) / (ANN_H_N - 1);   // Fensterabstand Mitte zu Mitte (ca. 1,9 m)
ann_hu   = [for (i = [0 : ANN_H_N - 1]) ANN_H_RAND_PAV + ANN_H_B / 2 + i * ann_hp];
ann_hz0  = ann_raster(bs_h + ANN_H_ZEILEN_BS * Z_PZ);                    // Fensterunterkante: ANN_H_ZEILEN_BS Reihen über der Bahnsteigoberkante bs_h
function ann_hh(u) = ANN_H_ZEILEN * Z_PZ - Z_FUGE;                 // Oberkante: ANN_H_ZEILEN_TR Reihen unter dem Wandkopf
ann_fl_v = m_v(x_ann1, y_ann[0]);
ann_fl_s = m_l(y_anns, x_ann1);
ann_fl_r = m_v(x_ann0, y_anns);
ann_fl_g = m_l(y_ann[1], x_ann0);      // linke Giebelwand des linken Teils (außen -x), u = y_ann[1] - y
function ann_raster(z) = z_y0 + round((z - z_y0) / Z_PZ) * Z_PZ;   // auf eine Ziegelreihe runden
ann_f_u  = [for (i = [-1 : 1]) ANN_BREITE / 2 + ANN_F_VERSATZ + i * ANN_F_ABSTAND];   // Fenstermitten der Front (u), gemessen ab der linken Kante des vorderen Teils
ann_fz0  = ann_raster(ANN_F_SOHLE);   ann_fh = ANN_F_ZEILEN * Z_PZ - Z_FUGE;
ann_sz0  = ann_raster(ANN_S_SOHLE);   ann_sh = ANN_S_ZEILEN * Z_PZ - Z_FUGE;
ann_wz0  = ann_raster(ANN_W_SOHLE);   ann_wh = ANN_W_ZEILEN * Z_PZ - Z_FUGE;
ann_wu   = y_ann[1] - (y_anns + ANN_W_Y);    // Fenstermitte in u der linken Giebelwand
ann_tu   = ANN_T_X;    // Türmitte in u
z_apod   = ANN_PODEST_ZEILEN * Z_PZ - Z_FUGE;                 // Podestoberkante = Türschwelle
ann_t_top = z_y0 + ANN_T_K_OBEN * Z_PZ - Z_FUGE;              // Türoberkante
ann_th   = ann_t_top - z_apod;                                // lichte Türhöhe

// Fenster als Liste: [Wandmatrix, u, lichte Breite, Sohle z, Höhe, Typ]  (Typ "gitter" oder "sprosse")
function ann_liste() = concat(
    ANBAU_FENSTER ? [for (u = ann_f_u) [ann_fl_v, u, ANN_F_B, ann_fz0, ann_fh, "gitter"]] : [],
    ANBAU_SEITENFENSTER ? [[ann_fl_s, (y_anns - y_ann[0]) / 2, ANN_S_B, ann_sz0, ann_sh, "sprosse"],
                           [ann_fl_g, ann_wu, ANN_W_B, ann_wz0, ann_wh, "gitter"]] : [],
    ANBAU_RUECKFENSTER ? [for (u = ann_hu) [ann_fl_h, u, ANN_H_B, ann_hz0, ann_hh(u), "gitter", "roll"]] : []);

// Rechteckige Öffnung durch die Wand (auch durch Sockel-/Bandvorsprünge nach außen)
module ann_oeff(u, wi, z0, h) {
    translate([u - wi/2, z0, -t - eps]) cube([wi, h, t + 2*eps + pmax + 0.05]);
}
module ann_oeffnungen() {
    for (f = ann_liste()) multmatrix(f[0]) ann_oeff(f[1], f[2], f[3], f[4]);
    if (ANBAU_TUER) multmatrix(ann_fl_r) ann_oeff(ann_tu, ANN_T_B, z_apod, ann_th);
}

// Sturz aus hochkant gestellten Ziegeln über der Öffnung (je Seite mindestens ein Ziegel Überstand), Unterkante zs0
module ann_sturz(u, wi, zs0) {
    n  = stz_n(wi);  Ws = stz_w(wi);  bp = Z_H + Z_FUGE;
    hs = TURM_STURZ_ZEILEN * Z_PZ - Z_FUGE;
    module fg() {
        for (i = [1 : n - 1])
            translate([u - Ws/2 + i * bp - Z_FUGE, zs0, pbog - fd]) cube([Z_FUGE, hs, fd + eps]);
    }
    color(C_STURZ) difference() {
        translate([u - Ws/2, zs0, -0.02]) cube([Ws, hs, pbog + 0.02]);
        if (ZIEGEL) fg();
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) fg();
}

// Fensterbank als Rollschicht: Ziegel auf der hohen Kante (Höhe Z_B), Kopfseite Z_H breit zeigt nach vorn, Oberkante = Fensterunterkante
module ann_rollschicht(u, wi, z0) {
    bp = Z_H + Z_FUGE;  n = round((wi + 2 * Z_H) / bp);  Ws = n * bp - Z_FUGE;  hs = Z_B;  v = ANN_H_BANK_VOR;
    module fg() {
        for (i = [1 : n - 1])
            translate([u - Ws/2 + i * bp - Z_FUGE, z0 - hs, v - fd]) cube([Z_FUGE, hs, fd + eps]);
    }
    color(C_STURZ) difference() {
        translate([u - Ws/2, z0 - hs, -0.02]) cube([Ws, hs, v + 0.02]);
        if (ZIEGEL) fg();
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) fg();
}

// Fensterbank (grauer Stein), springt vor
module ann_bank(u, wi, z0) {
    color(C_BETON) translate([u - wi/2 - 0.06, z0 - 0.08, -0.02]) cube([wi + 0.12, 0.08, 0.10]);
}

// Fensterfüllung, zurückgesetzt: "gitter" = dunkler Rahmen mit senkrechten Stäben und Querband,
// "sprosse" = graugrüner Rahmen mit Mittelpfosten und Quersprosse
module ann_blatt(u, wi, z0, h, typ) {
    fr = 0.06;  sb = 0.04;  d = 0.05;
    color(typ == "gitter" ? C_DUNKEL : C_TUER) translate([0, 0, -0.12]) {
        difference() {
            translate([u - wi/2, z0, 0]) cube([wi, h, d]);
            translate([u - wi/2 + fr, z0 + fr, -eps]) cube([wi - 2*fr, h - 2*fr, d + 2*eps]);
        }
        if (typ == "gitter") {
            nb = max(2, round(wi / 0.18));
            for (i = [1 : nb - 1])
                translate([u - wi/2 + i * wi / nb - sb/2, z0, 0]) cube([sb, h, d * 0.8]);
            translate([u - wi/2, z0 + h * 0.72 - sb/2, 0]) cube([wi, sb * 1.6, d]);
        } else {
            translate([u - sb, z0, 0]) cube([2*sb, h, d]);
            translate([u - wi/2, z0 + h/2 - sb, 0]) cube([wi, 2*sb, d]);
        }
    }
}

// Tür in der Front des linken Teils: gerade Öffnung mit Sturz, unten Füllung, oben Glasfläche mit Sprosse
module ann_tuer_blatt() {
    wi = ANN_T_B;  h = ann_th;  u = ann_tu;  z0 = z_apod;  fr = 0.07;  d = 0.06;  hu = ANN_T_FUELLUNG;
    ann_sturz(u, wi, ann_t_top + Z_FUGE);
    color(C_TUER) translate([0, 0, -0.12]) {
        difference() {
            translate([u - wi/2, z0, 0]) cube([wi, h, d]);
            translate([u - wi/2 + fr, z0 + fr, -eps]) cube([wi - 2*fr, h - 2*fr, d + 2*eps]);
        }
        translate([u - wi/2, z0, 0]) cube([wi, hu, d * 0.8]);                              // geschlossene Füllung
        translate([u - wi/2, z0 + hu - 0.03, 0]) cube([wi, 0.06, d]);                      // Querholz
        translate([u - wi/2, z0 + hu + (h - hu) / 2 - 0.02, 0]) cube([wi, 0.04, d * 0.8]); // Sprosse
        translate([u + wi/2 - fr - 0.07, z0 + 1.0, d]) cube([0.04, 0.12, 0.04]);           // Klinke
    }
}

// Gemauerter Block aus n Ziegelreihen (u0..u1, w0..w1) mit Lagerfugen an Front und Seiten (Rückseite bleibt glatt)
module ann_ziegelblock(u0, u1, w0, w1, n) {
    h = n * Z_PZ - Z_FUGE;
    module nuten() {
        for (j = [0 : n - 2])
            translate([0, j * Z_PZ + Z_H, 0]) difference() {
                translate([u0 - eps, 0, w0 - eps]) cube([u1 - u0 + 2*eps, Z_FUGE, w1 - w0 + 2*eps]);
                translate([u0 + fd, -1, w0 - 1]) cube([u1 - u0 - 2*fd, Z_FUGE + 2, w1 - w0 - fd + 1]);
            }
    }
    color(C_ZTREPPE) difference() {
        translate([u0, 0, w0]) cube([u1 - u0, h, w1 - w0]);
        if (ZIEGEL) nuten();
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) nuten();
}

// Podest und Treppe aus Ziegeln: Podest an der Wand, davor Stufen (je 2 Reihen niedriger), alles nach außen (-y)
module ann_podest_treppe() {
    hw = ANN_PODEST_HW;  PT = ANN_PODEST_TIEFE;  A = ANN_TREPPE_AUFTRITT;
    ann_ziegelblock(ann_tu - hw, ann_tu + hw, -0.02, PT, ANN_PODEST_ZEILEN);
    for (k = [1 : ANN_TREPPE_STEIGUNGEN - 1])
        ann_ziegelblock(ann_tu - hw, ann_tu + hw, PT + (k - 1) * A, PT + k * A, ANN_PODEST_ZEILEN - 2 * k);
}

// Geländer beidseitig: waagerecht über dem Podest, dann parallel zur Treppe nach unten (gleiche Form wie gelaender())
module ann_gelaender() {
    hw = ANN_PODEST_HW;  PT = ANN_PODEST_TIEFE;  A = ANN_TREPPE_AUFTRITT;
    n  = ANN_TREPPE_STEIGUNGEN - 1;  rz = 2 * Z_PZ;  hh = ANN_GEL_HOEHE;
    zp = ANN_PODEST_ZEILEN * Z_PZ - Z_FUGE;
    pts = [[0.05, zp + hh], [PT, zp + hh], [PT + n * A - 0.05, zp - n * rz + hh]];   // (w, z)
    for (sx = [-1, 1])
        translate([ann_tu + sx * (hw - 0.04) - GEL_DICKE / 2, 0, 0])
            multmatrix([[0, 0, 1, 0], [0, 1, 0, 0], [1, 0, 0, 0], [0, 0, 0, 1]])     // 2D (w, z) -> lokal (u, v = z, w)
                linear_extrude(GEL_DICKE) gel_flaeche(pts, hh, rz + 0.05);
}

// ---------- Bahnsteig auf der Gleisseite (durchsichtig, nur Vorschau) ----------
BAHNSTEIG         = true;
BAHNSTEIG_TIEFE   = 5.0;    // Tiefe (y) ab der Rückwand [m real]
BAHNSTEIG_UEBER   = 1.0;    // Überstand über Anbau (links) und rechten Flügel (rechts) hinaus [m real]
BAHNSTEIG_ALPHA   = 0.35;   // Deckkraft
module bahnsteig() {
    color([0.55, 0.62, 0.70, BAHNSTEIG_ALPHA]) {
        // Rückwand von Anbau, Pavillon und Hauptgebäude bei y_ann[1]; das Zwischengebäude steht 1 m zurück (y_wing[1])
        translate([x_ann0 - BAHNSTEIG_UEBER, y_ann[1] + ps, 0])
            cube([x_end - x_ann0 + 2 * BAHNSTEIG_UEBER, BAHNSTEIG_TIEFE, bs_h]);
        translate([x_pav1, y_wing[1] + ps, 0])
            cube([x_mb1 - x_pav1, y_ann[1] - y_wing[1], bs_h]);
    }
}

// ---------- Rampe am rechten Giebel (Stirnseite des rechten Flügels, x_end) ----------
// Das Gelände steigt von der straßenseitigen Ecke der Giebelwand (z = 0) bis zur Rückwand/Bahnsteigkante (z = bs_h) an. Die Rampe ist
// durchsichtig wie der Bahnsteig. Der graue Betonsockel an der Giebelwand folgt ihr als schräger Keil und trifft an der Gleisseite
// auf den Sockel, der dort auf der Bahnsteigoberkante sitzt.
RAMPE          = true;
RAMPE_BREITE   = BAHNSTEIG_UEBER;      // Ausdehnung der Rampe quer zur Giebelwand (in +x) [m real]
ramp_y0 = y_main[0];                   // Rampenanfang: straßenseitige Ecke der Giebelwand
ramp_y1 = y_ann[1];                    // Rampenende: hier beginnt der Bahnsteig (Sockelkeil trifft den Bahnsteigsockel)
// Dreiecksprisma (Gelände): (y, z) -> Extrusion entlang x
module rampe() {
    if (RAMPE && bs_h > 0)
        color([0.55, 0.62, 0.70, BAHNSTEIG_ALPHA])
            translate([x_end, 0, 0]) rotate([90, 0, 90]) linear_extrude(RAMPE_BREITE)
                polygon([[ramp_y0, 0], [ramp_y1, 0], [ramp_y1, bs_h]]);
}
// Sockel an der Giebelwand: Parallelogramm (y, z), steigt mit der Rampe; Vorsprung ps vor der Wand
module rampen_sockel() {
    if (SOCKEL && RAMPE && bs_h > 0)
        color(C_BETON)
            translate([x_end - 0.001, 0, 0]) rotate([90, 0, 90]) linear_extrude(ps + 0.001)
                polygon([[ramp_y0, 0], [ramp_y1, bs_h], [ramp_y1, bs_h + zs], [ramp_y0, zs]]);
}

module anbau_objekte() {
    for (f = ann_liste()) multmatrix(f[0]) {
        ann_sturz(f[1], f[2], f[3] + f[4] + Z_FUGE);
        if (len(f) > 6 && f[6] == "roll") ann_rollschicht(f[1], f[2], f[3]);
        else ann_bank(f[1], f[2], f[3]);
        ann_blatt(f[1], f[2], f[3], f[4], f[5]);
    }
    if (ANBAU_TUER) multmatrix(ann_fl_r) {
        ann_tuer_blatt();
        ann_podest_treppe();
        if (GELAENDER) color(C_GELAENDER) ann_gelaender();
    }
}

// ============================================================
// Schornsteine auf dem rechten Flügel
// Schaft aus gelbem Klinker mit Lagerfugen, Kopf aus SCH_KOPF_ZEILEN roten Schichten (springt leicht vor),
// darauf eine Abdeckplatte aus Beton mit Rauchrohr-Mündung. Der Fuß steckt unter dem First im Dach (verdeckt).
// ============================================================
// Lagerfugen eines Quaders (Ziegelraster ab zb, rows Schichten) als Nuten rundum
module sch_fugen(x0, y0, bx, by, zb, rows) {
    for (j = [0 : rows - 1])
        difference() {
            translate([x0 - eps, y0 - eps, zb + j * Z_PZ + Z_H]) cube([bx + 2*eps, by + 2*eps, Z_FUGE]);
            translate([x0 + fd, y0 + fd, zb + j * Z_PZ + Z_H - 1]) cube([bx - 2*fd, by - 2*fd, Z_FUGE + 2]);
        }
}
// Allgemeiner Schornstein: Ecke (x0, y0), Ausdehnung bx (x) und by (y), Fuß sch_zb (auf dem Ziegelraster), Oberkante des Kopfes
// bei ztop (auf Schichten aufgerundet). cs = Farbe des Schafts, ck = Farbe des Kopfes (rote Schichten).
module sch_bau(x0, y0, bx, by, sch_zb, ztop, cs = C_KLINKER, ck = C_BAND) {
    n   = ceil((ztop - sch_zb) / Z_PZ);            // Schichten insgesamt
    nk  = SCH_KOPF_ZEILEN;
    ns  = n - nk;                                  // Schichten des Schafts
    zk  = sch_zb + ns * Z_PZ;                      // Unterkante Kopf
    zt  = sch_zb + n * Z_PZ - Z_FUGE;              // Oberkante Kopf
    v   = SCH_KOPF_VOR;
    pv_ = SCH_PLATTE_VOR;
    // Schaft
    color(cs) difference() {
        translate([x0, y0, sch_zb]) cube([bx, by, ns * Z_PZ]);
        if (ZIEGEL) sch_fugen(x0, y0, bx, by, sch_zb, ns);
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) sch_fugen(x0, y0, bx, by, sch_zb, ns);
    // Kopf: rote Schichten, leicht vorspringend
    color(ck) difference() {
        translate([x0 - v, y0 - v, zk]) cube([bx + 2*v, by + 2*v, nk * Z_PZ - Z_FUGE]);
        if (ZIEGEL && nk > 1) sch_fugen(x0 - v, y0 - v, bx + 2*v, by + 2*v, zk, nk - 1);
    }
    if (ZIEGEL && FUGEN_GRAU && nk > 1) color(C_FUGE) sch_fugen(x0 - v, y0 - v, bx + 2*v, by + 2*v, zk, nk - 1);
    // Abdeckplatte mit Mündung
    color(C_BETON) difference() {
        translate([x0 - v - pv_, y0 - v - pv_, zt]) cube([bx + 2*(v + pv_), by + 2*(v + pv_), SCH_PLATTE_H]);
        translate([x0 - v - pv_ + SCH_MUENDUNG_RAND, y0 - v - pv_ + SCH_MUENDUNG_RAND, zt + SCH_PLATTE_H - SCH_MUENDUNG_TIEFE])
            cube([bx + 2*(v + pv_) - 2*SCH_MUENDUNG_RAND, by + 2*(v + pv_) - 2*SCH_MUENDUNG_RAND, SCH_MUENDUNG_TIEFE + 1]);
    }
    color(C_DUNKEL)    // dunkler Grund der Mündung
        translate([x0 - v - pv_ + SCH_MUENDUNG_RAND, y0 - v - pv_ + SCH_MUENDUNG_RAND, zt + SCH_PLATTE_H - SCH_MUENDUNG_TIEFE - 0.002])
            cube([bx + 2*(v + pv_) - 2*SCH_MUENDUNG_RAND, by + 2*(v + pv_) - 2*SCH_MUENDUNG_RAND, 0.004]);
}
// Schornstein auf der vorderen Dachfläche des Hauptdachs (rechter und linker Flügel)
// xc = Mitte in x, bx/by = Ausdehnung in x bzw. y, hh = Höhe über der Dachfläche an der Mitte, ab = Abstand der Mitte vom First
module schornstein(xc, bx, by, hh, ab) {
    yc = sch_y(ab);
    zs = sch_dach(yc);                                   // Dachhöhe an der Schornsteinmitte
    // Fuß: unter der tiefsten Stelle der Dachfläche (Vorderkante des Schornsteins), auf dem Ziegelraster
    zb = z_y0 + floor((sch_dach(yc - by / 2) - SCH_FUSS - z_y0) / Z_PZ) * Z_PZ;
    sch_bau(xc - bx / 2, yc - by / 2, bx, by, zb, zs + hh);
}

// Pavillon (Walmdach, First in y): zwei Schornsteine auf der Dachfläche zur Anbau-Seite (-x).
//   links:  Mauerwerksvorlage (gelb) außen an der Wand x_pav0, über dem SCH_P_BOGEN_WAND-ten Bogen des Zierfrieses
//           (von links gezählt, von außen gesehen = von der Gleisseite aus), geht über den Zierfries und durch das Dach
//           und setzt sich darüber als ziegelroter Schornstein fort
//   rechts: ziegelroter Schornstein auf der Dachfläche, über dem SCH_P_BOGEN_FREI-ten Bogen (y), nahe der Traufe
// Bogenmitte in y: die Bögen der Seitenwand (links) laufen vom linken Rand = Gleisseite (y_pav[1]) nach vorn (wie zf_wand2d).
function sch_bogen_y(k) = let(Lw = y_pav[1] - y_pav[0], N = max(1, round(Lw / ZF_RASTER)))
                          y_pav[1] - (k - 0.5) * Lw / N;
function sch_p_dach(x) = h_pav + (x - x_pav0) * tan(a_pav);   // Höhe der Pavillon-Dachfläche zur Anbau-Seite bei der Koordinate x (Traufe h_pav an der Wand x_pav0, auch im Überstand x < x_pav0)
module schornsteine_pavillon() {
    // links: schmale Vorlage, Längsseite AN der Wand (komplett außerhalb des Gebäudes), durch den Dachüberstand;
    // darüber der ziegelrote Schornstein
    zt   = h_pav + SCH_P_HOEHE;                                            // Oberkante des Wand-Schornsteins
    wt   = SCH_P_WAND_VOR + SCH_P_WAND_EIN;                                // Tiefe senkrecht zur Wand
    wx0  = x_pav0 - SCH_P_WAND_VOR;   wy0 = sch_bogen_y(SCH_P_BOGEN_WAND) - SCH_P_WAND_BY / 2;
    zf0  = z_y0 + floor(((ANBAU ? h_ann - 0.20 : zs) - z_y0) / Z_PZ) * Z_PZ;   // Fuß der Vorlage: im Anbaudach (verdeckt)
    zuebergang = z_y0 + ceil((sch_p_dach(x_pav0) + SCH_P_UEBERGANG - z_y0) / Z_PZ) * Z_PZ;   // hier endet das gelbe Mauerwerk
    rows = round((zuebergang - zf0) / Z_PZ);
    color(C_KLINKER) difference() {                                         // gelbe Vorlage
        translate([wx0, wy0, zf0]) cube([wt, SCH_P_WAND_BY, rows * Z_PZ]);
        if (ZIEGEL) sch_fugen(wx0, wy0, wt, SCH_P_WAND_BY, zf0, rows);
    }
    if (ZIEGEL && FUGEN_GRAU) color(C_FUGE) sch_fugen(wx0, wy0, wt, SCH_P_WAND_BY, zf0, rows);
    sch_bau(wx0, wy0, wt, SCH_P_WAND_BY, zuebergang, zt, C_ROLL, C_BAND);   // roter Schornstein darüber
    // rechts: schmaler, höherer Schornstein freistehend auf der Dachfläche
    fxc  = x_pav0 + SCH_P_FREI_X;
    fx0  = fxc - SCH_P_FREI_BX / 2;   fy0 = sch_bogen_y(SCH_P_BOGEN_FREI) - SCH_P_FREI_BY / 2;
    fzb  = z_y0 + floor((sch_p_dach(fx0) - SCH_FUSS - z_y0) / Z_PZ) * Z_PZ;
    sch_bau(fx0, fy0, SCH_P_FREI_BX, SCH_P_FREI_BY, fzb, sch_p_dach(fxc) + SCH_P_FREI_H, C_ROLL, C_BAND);
}
module schornsteine() {
    if (SCHORNSTEIN_PAV) schornsteine_pavillon();
    schornstein(SCH_R_X, SCH_R_BX, SCH_R_BY, SCH_R_H, SCH_R_ABSTAND_FIRST);   // rechts: rechteckig, parallel zum First
    schornstein(SCH_L_X, SCH_L_BX, SCH_L_BY, SCH_L_H, SCH_L_ABSTAND_FIRST);   // links: schmaler, senkrecht zum First, weiter unten
    if (SCHORNSTEIN_LW)   // linker Flügel, links neben dem Turm: schmal wie der linke Schornstein, unter der Firstlinie
        schornstein(SCH_LW_X, SCH_L_BX, SCH_L_BY, SCH_L_H, SCH_LW_ABSTAND_FIRST);
}

// ============================================================
// Ausgabe (auf Modell-mm skaliert)
// ============================================================
scale(1000 / M) {
    // Mauerwerk (Wände, Giebel, Turm): gelber Klinker mit Fugen
    color(C_KLINKER)
    difference() {
        union() { baukoerper(); turm(); daecher("kern"); }
        union() {
            hohlraeume();
            oeffnungen_alle();
            if (ZIEGEL) fugen_alle($teil = "mauer");
            turm_gewaende();                       // zurückgesetztes Gewände der Turmfenster
            if (ZIEGEL) turm_gewaende(true);       // Lagerfugen im Gewände
            if (ZIEGEL) laterne_fugen();           // Lagerfugen im Gewände der Laterne
        }
    }
    // Fugen der Wände grau (füllen die Nuten, ohne die Öffnungen)
    if (ZIEGEL && FUGEN_GRAU)
        color(C_FUGE) difference() {
            union() { fugen_alle($teil = "mauer"); turm_gewaende(true); laterne_fugen(); }
            oeffnungen_alle();
        }
    // Betonsockel (springt vor)
    if (SOCKEL)
        color(C_BETON)
        difference() {
            vorsprung(ps, 0, zs);
            hohlraeume();
            turm_oeffnungen();
            if (RAMPE && bs_h > 0)      // an der rechten Giebelwand ersetzt der schräge Sockelkeil (rampen_sockel) den flachen Sockel
                translate([x_end - 0.001, ramp_y0, -1]) cube([ps + 1, ramp_y1 - ramp_y0, zs + 2]);
        }
        rampen_sockel();
    // Gleisseite: der graue Sockel sitzt auf der Bahnsteigoberkante und verdeckt davor die roten Reihen bis Oberkante Sockel;
    // darüber folgen BAND_REIHEN_GLEIS Reihen des roten Bandes (Straßenseite: Sockel am Boden, darüber das ganze Band)
    if (SOCKEL && BAHNSTEIG_SOCKEL && BAHNSTEIG && bs_h > 0)
        color(C_BETON)
        difference() {
            intersection() {
                vorsprung(ps, bs_h, bs_h + zs);
                union() {   // Rückwände von Anbau, Pavillon, Hauptgebäude (bei y_ann[1]) und gleisseitiger Risalit; Zwischengebäude 1 m zurück
                    translate([x_ann0 - 1, y_ann[1] - 0.001, -1]) cube([x_end - x_ann0 + 2, BAHNSTEIG_TIEFE + 1, 100]);
                    translate([x_pav1 - 0.01, y_wing[1] - 0.001, -1]) cube([x_mb1 - x_pav1 + 0.02, y_ann[1] - y_wing[1], 100]);
                }
            }
            hohlraeume();
            turm_oeffnungen();
            oeffnungen_alle();
        }
    // Braunrotes Sockelband (springt vor)
    if (BAND && z_bt > zs)
        color(C_BAND) band(zs, z_bt, pb, 0, ausser = ANN_BAND ? [] : ANN_IDX);
    // Rote Schichten und Zahnfries laut TRAUFE_SCHEMA, umlaufend
    for (i = [0 : len(TRAUFE_SCHEMA) - 1])
        let(typ = TRAUFE_SCHEMA[i][0], n = sch_n(TRAUFE_SCHEMA[i]),
            k = lauf_n(TRAUFE_SCHEMA, i),
            z0 = z_y0 + k * Z_PZ, z1 = z0 + n * Z_PZ - Z_FUGE, j0 = nb + k,
            ohne_tt = k >= tt_k_streifen,     // Türmchen und Pavillon haben nur die unteren roten Streifen
            aus = concat(ohne_tt ? [ZW_IDX, TT_IDX, PAV_IDX] : [ZW_IDX], ANN_STREIFEN ? [] : ANN_IDX)) {
            if (typ == "r" && !(i >= TRAUFE_OBEN_AB && !TRAUFE_BAND_OBEN)) color(C_BAND) band(z0, z1, pf, j0, ausser = aus, $zw = "ohne", $tt = ohne_tt ? "ohne" : "mit", $gl = !GIEBEL_LINKS_ROT);
            if (typ == "v") color(C_BAND) band(z0, z1, pv, j0, ausser = aus, $zw = "ohne", $tt = ohne_tt ? "ohne" : "mit", $gl = !GIEBEL_LINKS_ROT);
            if (typ == "z") color(C_BAND) zahnfries(z0, z1, j0);        // Zahnfries bleibt umlaufend (unter Giebeln und Traufe)
        }
    // Zwischengebäude: eigenes Traufschema ZW_SCHEMA (rote Streifen unten, Zahnfries oben)
    for (i = [0 : len(ZW_SCHEMA) - 1])
        let(typ = ZW_SCHEMA[i][0], k = lauf_n(ZW_SCHEMA, i),
            z0 = z_y0 + k * Z_PZ, z1 = z0 + sch_n(ZW_SCHEMA[i]) * Z_PZ - Z_FUGE, j0 = nb + k) {
            if (typ == "r") color(C_BAND) band(z0, z1, pf, j0, ausser = ZW_AUSSER, $zw = "nur");
            if (typ == "z") color(C_BAND) zw_zahnfries(z0, z1, j0);
        }
    // Turmvorderseite: verschobene rote Streifen (Musterverschiebung beim unteren Fensterpaar)
    if (TURM_MUSTER) color(C_BAND) turm_muster();
    if (TURM_BANK) color(C_BAND) turm_bank();
    // Rollschicht und rotes Band oben am Turm
    color(C_ROLL) turm_roll();
    // Laterne: rote Reihen (Sohle, Zwischenreihe, Kappe), Pfosten, Holzbalken
    for (k = [TURM_L_ROT0, TURM_K_LROT])
        color(C_BAND) band(tw_z(k), tw_z(k) + Z_H, pf, nb + k);
    // Pfeilerkopf: halbhohe rote Schicht, darüber die volle, vorspringende rote Kappenreihe; erst darüber beginnt der grüne Balken
    color(C_BAND) band(tw_z(TURM_K_KAPPE - 1) + Z_H / 2, tw_z(TURM_K_KAPPE - 1) + Z_H, pf, nb + TURM_K_KAPPE - 1);   // obere Hälfte der Reihe: grenzt direkt an die Kappe, keine gelbe Halbschicht dazwischen
    color(C_BAND) band(tw_z(TURM_K_KAPPE), tw_z(TURM_K_KAPPE) + Z_H, TURM_KAPPE_VORSPRUNG, nb + TURM_K_KAPPE);
    turm_pfosten();
    turm_holz();
    if (DACHKASTEN) { dachkasten(); color(C_HOLZ) giebel_kasten_alle(); }
    if (DACHKASTEN && ANBAU) color(C_DK_ANN) dachkasten_anbau();
    if (TURM_QUERBALKEN) turm_querbalken();
    if (SPARREN) color(C_SPARREN) sparren_alle();
    if (SPARREN_GIEBEL) color(C_SPARREN) giebel_sparren_alle();
    if (SPARREN && PAV_SPARREN) color(C_SPARREN) pavillon_sparren();
    if (RINNE)   color(C_RINNE)   rinne_alle();
    if (RINNE_STRASSE) color(C_RINNE) strassen_rinnen();
    if (RINNE_NEBEN) color(C_RINNE) rinnen_neben();
    if (MAST)    fahnenmast();
    if (TURM_BAND_OBEN)
        let(k = TURM_K_BAND2, z0 = tw_z(k)) color(C_BAND) band(z0, z0 + Z_H, pf, nb + k);
    // Dachhaut: Schiefer
    color(C_SCHIEFER)
    difference() {
        daecher("haut");
        hohlraeume();
    }
    // Fensterrahmen, Glas, Uhren (eigene Farben)
    turm_fuellung();
    // Tür rechts mit Treppe
    if (TUER) tuer_objekte();
    // Fenster über der Tür
    if (FENSTER) fenster_objekte();
    // Schmale Fenster neben der Tür
    if (FENSTER_SCHMAL) schmal_objekte();
    // Rechte Außenwand: Blindfenster und Blindtür
    if (BLIND) blind_objekte();
    // Eingangsrisalit: drei Türen mit Treppe, vier Fenster
    if (RISALIT_OEFFNUNGEN) ris_objekte();
    // Gleisseitiger Mittelrisalit: zwei Türen, drei Fenster
    if (RIS_HINTEN) ris_h_objekte();
    // Türmchen vor dem linken Flügel: Fenster, Tür, Treppe, Geländer an der linken Seite
    if (TUERMCHEN) tt_objekte();
    // Zwischengebäude: zwei Fenster mit zurückspringendem Gewände
    if (ZW_FENSTER) zw_objekte();
    // Bogenfenster im Giebel des linken Flügels (unten vom Dach des Zwischengebäudes geschnitten)
    if (GIEBELFENSTER) gw_objekte();
    // Pavillon: drei Fenster und der bogenförmige Zierfries unter dem Dach
    if (PAV_FENSTER) pav_objekte();
    if (PAV_RUECK_FENSTER) pav_rueck_objekte();
    if (RW_RUECK_FENSTER) rw_rueck_objekte();
    if (LW_RUECK_FENSTER) lw_rueck_objekte();
    if (OG_RUECK_FENSTER) og_rueck_objekte();
    if (ZW_RUECK_FENSTER) zw_rueck_objekte();
    if (PAV_ZIERFRIES) color(C_BOGEN) pav_zierfries();
    if (PAV_ZIERFRIES) color(C_BAND) pav_zahnfries();
    // Schornsteine auf dem rechten Flügel
    if (SCHORNSTEIN) schornsteine();
    // Anbau links: Fenster, Tür, Ziegeltreppe, Geländer
    if (ANBAU) anbau_objekte();
    // Bahnsteig auf der Gleisseite (durchsichtig)
    if (BAHNSTEIG) bahnsteig();
    rampe();
}