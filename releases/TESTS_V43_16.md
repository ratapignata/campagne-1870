# Tests réellement exécutés — V43.16

24 novembre 2026. Godot **4.5.1 officiel**, vérifié avec les sommes SHA-512 de sa version. Baseline stable : 23 suites, 2 487/2 487 avant modification. Résultats du candidat final : **24 suites, 2 543/2 543**, plus relecture de la partie personnelle **7/7**, soit **2 550 contrôles techniques**. Les relances et les essais rejetés ne sont pas additionnés.

| Suite finale | Résultat |
| --- | --- |
| `v43/test_v4315` | 28/28 |
| `v43/test_v4314` | 25/25 |
| `v43/test_v4314_ui` | 14/14 |
| `v43/test_v4313` | 30/30 |
| `v43/test_assault_commitment` | 11/11 |
| `v43/test_v4312` | 247/247 |
| `v43/test_bridge_barrage` | 17/17 |
| `v43/test_assault_before_rest` | 8/8 |
| `test_ai_compat0833` | 18/18 |
| `v36/test_hidden_worlds` | 18/18 |
| `v36/test_isolation` | 45/45 |
| `v43/test_enclosed_links` | 25/25 |
| `v43/test_adjacent_reinforcements` | 32/32 |
| `v43/test_ui` | 30/30 |
| `v43_export/test_export` | 28/28 |
| `v43_export/test_android_eof` | 9/9 |
| `v43/test_cavalry_village125` | 20/20 |
| `v43/test_rifle_label` | 18/18 |
| `v43/test_v439_presentation` | 102/102 |
| `v43/test_surrender_journal` | 11/11 |
| `v43/test_variant_b` | 1701/1701 |
| `v43/test_raoult` | 42/42 |
| `v43/test_v4315_ui` | 8/8 |
| `v43/test_v4316` | 56/56 |

## Couverture nouvelle

Repli d’une garnison de plein effectif avant une fermeture ; maintien des deux liaisons après déplacement réel ; recours à un bois de seconde ligne ; maintien d’un point tenu et retranché contre une attaque frontale ; refus de fuir devant une petite cavalerie quand l’infanterie est bien soutenue ; tenue d’un objectif majeur encore défendable ; attelage puis déplacement réel de batterie ; éloignement d’un QG ; intervention d’une vraie réserve vers une intrusion arrière ; réaction à une double coupure propre connue sans localiser sa cause cachée ; action légale sans téléportation dans un anneau fermé ; comparaison entre mondes cachés ; politiques Normal et prussiennes identiques sur plusieurs décisions successives.

Les suites existantes gardent leurs assertions sur combat, charge, riposte, variante B, renforts/Raoult, réseaux/isolement, brouillard, export, UI et sauvegardes. Le worker de production et la reprise après son ordre ont été exécutés via le test UI V43.15. Un test supplémentaire vérifie explicitement la tenue d’une ligne de bois retranchée face à une pression supérieure en effectifs bruts. Anciens avertissements ObjectDB de certaines suites UI conservés dans les logs ; pas de correction UI hors périmètre.

## Simulations

Quatre cas complets T1–T20 sur un déploiement synthétique de 29 unités (deux graines × deux politiques) et deux démarrages chronologiques T1–T2 du scénario réel de 95 unités. Quatre fermetures ciblées de piège sur six tours. **7534 contrôles de légalité/état et de fin de phase réussis**, comptés séparément des contrôles techniques. Aucun plafond d’actions atteint dans ces cas finaux. Protocoles, résultats et limites détaillés dans `ANALYSE_PARTIE_V43_15.md` et `tests/results/0843_16`.

Les cinq réglages intermédiaires rejetés ne sont pas comptés comme des résultats finaux. Certains ont été interrompus devant des pertes prématurées d’objectifs ; d’autres ont terminé leurs simulations avant d’être écartés de la livraison. Un premier test sans brouillard ne fournissait pas les indices ennemis au contrat `observation`; cette fixture a été corrigée en passant explicitement les ennemis visibles. Le témoin des anciennes décisions est conservé dans des scripts de test, sans restauration d’API obsolète.

## Intégrité et sauvegardes

Moteur, réseaux, LOS, mouvement, sauvegarde, artillerie, profils, ancienne politique Normal, carte, unités, valeurs historiques et présentation identiques à la V43.15. Empreinte du scénario inchangée. Changements de production limités à deux modules IA, au badge et aux métadonnées de version. Le fichier personnel original est resté identique après chargement et aller-retour vers un autre slot. Aucun nouveau champ requis.

## APK

APK 0.8.43.16, code 73, paquet org.woerth1870.prototype.v02. Export, intégrité ZIP, signature et certificat identique à V43.15 vérifiés. Le module de défense est inclus ; tests et développement exclus. SDK minimum 24/cible 35, ARMv7/ARM64/x86_64. La sonde ADB peut signaler un refus de connexion en fin d’export ; la signature et la vérification de l’APK ont réussi. Aucun essai physique ou émulateur Android.

Archive du code extraite dans un dossier neuf : import Godot 4.5.1 et test de défense indépendants réussis. La recompression finale ajoute les rapports et les preuves ; égalité des fichiers de code/ressources et CRC du ZIP contrôlés avant livraison. Les assertions de cette répétition ne sont pas ajoutées au total technique.

## Reproduction

```sh
# Utiliser Godot 4.5.1 et des répertoires XDG inscriptibles/isolés.
godot --headless --editor --path prototype_1870 --import
godot --headless --path prototype_1870 --script res://tests/v43/test_v4316.gd
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4316_defence.gd -- reference pincer /tmp/reference.json 18704316 20
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4316_defence.gd -- current pincer /tmp/current.json 18704316 20
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4316_trap.gd -- current 18704316 /tmp/trap.json
```

Remplacer la graine pour le second cas. `full` au lieu de `pincer` reprend le scénario initial de 95 unités ; la campagne exécutée ici s’arrête à deux tours pour ces essais. Le test de fichier personnel demande explicitement le chemin d’un export et un chemin de rapport de sortie : il ne crée pas de nouvelle partie à partir d’un résultat déjà terminé.
