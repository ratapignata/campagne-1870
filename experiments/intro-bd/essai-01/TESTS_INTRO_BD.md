# Tests — introduction BD, essai 1

Godot 4.5.1 officiel `f62fdbde1`, Linux ; rendu OpenGL Compatibility llvmpipe pour les captures, répertoires utilisateur isolés. Résultats réellement exécutés, 31 octobre 2026.

## Prototype original indépendant

35/35 : six illustrations, dimensions, titres/textes, précédent/suivant, fin, activation/désactivation automatique, véritable intervalle de 9 s, six captures réelles. Limites de navigation et de taille des boutons relevées, corrigées dans l’intégration ; le ZIP d’origine n’a pas été modifié.

## Parcours intégré avec rendu et toucher

**168/168** : menu initial ; lancement d’une nouvelle partie ; six scènes et tous les textes originaux ; empreintes des six JPEG ; contrôles tactiles à trois tailles paysage ; boutons sans dépassement et texte complet ; précédent/suivant ; passage pendant un fondu ; retour menu ; retour Android simulé ; pause/reprise en arrière-plan ; véritable intervalle intégré de 9 s ; séquence complète automatique accélérée pour tester sa fin ; sélection du mode Difficile et de la France ; création du scénario V43 ; sauvegarde, reprise et relancement de l’application.

Contrôles supplémentaires : moteur/retour arrière/fichier de sauvegarde inchangés pendant la lecture et en l’abandonnant ; aucune partie créée avant le choix d’un camp ; fin idempotente sans timer tardif ; images libérées en quittant l’introduction. Les captures sont réellement produites par Godot, sans retouche ni maquette générée. Le retour Android et les notifications d’arrière-plan sont simulés, pas testés sur appareil.

## Reprise dans un processus séparé

**9/9** : sauvegarde V43 valide créée dans un dossier utilisateur de test, démarrage réel de l’application, Continuer disponible, reprise directe, état et fichier original identiques ; aucune des six images chargée avant ou après Continuer. Vérification mémoire complémentaire par référence faible : l’image n’existe plus après fermeture de l’introduction.

## Non-régression relancée

| Suite | Résultat |
| --- | --- |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_header09` | 795/795 |
| `graphics/test_hud06` | 84/84 |
| `graphics/test_guidance07` | 137/137 |
| `graphics/test_feedback12` | 20/20 |
| `v43/test_v4315` | 28/28 |
| `v43/test_raoult` | 42/42 |
| `v43/test_surrender_journal` | 11/11 |
| `v43/test_variant_b` | 1701/1701 |
| `v43/test_ui` | 30/30 |
| `v43_export/test_export` | 28/28 |

Total de ces treize suites : **5 725**. Soit 5 937 assertions sur l’ensemble prototype original + parcours intégré + reprise séparée + non-régression, sans ajouter les répétitions de mise au point ou de vérification d’archive. Tous les contrôles finaux passent ; aucun test désactivé.

La suite historique `v43/test_ui` passe ses 30 contrôles mais signale parfois ObjectDB/2 ressources audio Ogg encore utilisées à la fermeture. Le même avertissement a été reproduit sur la base graphique 12, sans introduction (`slow_world.ogg`) : anomalie de fermeture préexistante, non corrigée dans ce lot. Le nombre de contrôles UI varie selon la présence initiale du bouton de reprise ; ce relevé utilise un répertoire neuf. Le nouveau test d’introduction se ferme sans cet avertissement. Le pilote de rendu logiciel signale l’absence de réglage V-Sync.

## Intégrité et contenu

Base : source graphique 12 `a8652b5`. Seules cinq fonctions de menu/navigation de `main.gd` changent, avec un contrôleur d’introduction distinct chargé à la demande. Core, IA, plateforme, données, scènes de jeu, animations, graphismes 12 et logique des sauvegardes conservés. Vérification avec la stable V43.15 réussie également ; exceptions de présentation limitées explicitement aux fonctions de navigation. L’assertion d’isolation des données de test est adaptée au nouveau répertoire expérimental, sans changer les règles.

Scénario SHA-256 `5a69f33d1e4704966eb00ed1f643fa91463ecca1427419b5af9ce36d290f9b57`. JPEG et textes comparés aux ressources fournies, tous identiques. Sauvegardes antérieures relues via les suites existantes ; aucun format modifié.

## Mises au point et limites

Le premier banc de test utilisait une constante de retour Android hors de sa classe ; portée corrigée avant exécution. Un premier test à hauteur 606 a révélé le cadre modal resté à sa hauteur initiale : redimensionnement limité à l’introduction ajouté, puis les 168 contrôles relancés avec succès. Le chargement des images a été déplacé dans l’instance et leur libération vérifiée pour éviter de retenir six textures en cours de bataille. Aucun échec initial n’est présenté comme un succès final.

Pas de simulation complète nouvelle de bataille, d’essai physique Android, d’émulation Android ou de mesure comparative de FPS sur téléphone. Pas de voix ni d’animation de personnages testée, car absentes du prototype. Les textes historiques restent ceux de l’auteur, sans reconstitution ni nouveau contenu de bataille.

## APK et archive

APK compilé avec Godot 4.5.1, signé (v2/v3), identité `org.woerth1870.prototype.introbdexp`, version `0.8.43.15-bd1`, code 1. ZIP, métadonnées, six images importées et scène/contrôleur compilés vérifiés ; minimum SDK 24/cible 35, ARMv7/ARM64/x86_64. Tests, développement et captures exclus de l’APK. Avertissement connu de la sonde ADB sur son répertoire personnel en lecture seule après export ; compilation et signature réussies.

Archive complète extraite et importée dans un dossier indépendant : parcours headless 158/158 (captures et toucher réel déjà validés dans le test avec rendu), reprise 9/9, anciennes sauvegardes 63/63 et intégrité avec le dossier stable réussis. Ces répétitions ne sont pas ajoutées aux 5 937 assertions. Le code fonctionnel livré est celui de l’archive vérifiée ; les rapports et preuves sont complétés après cette vérification.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/intro_bd/test_intro_flow.gd -- /tmp/captures_intro
godot --headless --path . --script res://tests/intro_bd/test_resume_direct.gd
godot --headless --path . --script res://tests/graphics/test_previous_save.gd
python3 tests/graphics/check_source_integrity.py --baseline-directory /chemin/sources_V43.15
```

Créer le dossier de captures et utiliser un **nouveau répertoire utilisateur isolé** pour le test de parcours (son premier cas exige l’absence de sauvegarde). Les JSON et journaux bruts sont joints à la galerie/preuves.
