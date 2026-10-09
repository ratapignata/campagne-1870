# Tests V37 — Godot 4.5.1

Environnement cloud Linux ; export Android natif sans Gradle. Les résultats automatisés ne constituent pas un essai tactile ou de performance sur téléphone.

## Régression exécutée

Commande :

```sh
python3 tests/v36/run_suite.py --godot /chemin/vers/Godot_4.5.1 --output-dir /tmp/regression-v37
```

Import du projet réussi. **26 suites, 2 186 assertions réussies**, aucun échec, erreur de script ou avertissement de fuite dans ces journaux. Résultats détaillés et journaux : `tests/results/0837/regression.json` et `regression_logs/`.

Couverture : sauvegardes valides et corrompues, compatibilité des champs facultatifs, LOS géométrique et reconnaissance, isolement et retraite légale, règles figées, interface tactile automatisée, brouillard de guerre, artillerie et portées, armes, réactions, assaut, déplacements, formations, objectifs, résultats, cavalerie, commandement/ravitaillement, renforts et carte historique 81 unités, rivière et IA.

Le test tactile couvre second toucher pour tirer, glisser/pincer, absence de bouton TIRER, flèche Reichshoffen et affichage final 17 h 00 sans tour supplémentaire.

## Bataille complète

Commande : `python3 tests/v37/run_full_battle.py --godot /chemin/vers/Godot_4.5.1 --output-dir /tmp/bataille-v37`.

Scénario historique original, 81 unités déclarées, déploiement et arrivées originales, 18 tours chronologiques, deux IA actives, difficulté moyenne, graine 187037 et style 0. Validation après chaque commande ; sauvegardes physiques périodiques et reprise finale. Le rapport BATAILLE_V37.md complète les chiffres finaux et les éventuels échecs.

## Non réalisés et limites conservées

- Aucun essai sur appareil Android physique ni émulateur ; performances mobiles et lecture visuelle non mesurées.
- Aucune campagne statistique sur plusieurs graines ou trois difficultés ; une simulation ne démontre pas l’équilibrage global.
- Anciens scripts de captures UI déjà obsolètes en V36 non remis en service ; les suites UI actuelles sont exécutées.
- Avertissement audio Ogg lors d’une fermeture forcée avec lecture musicale connu de V36 ; aucune refonte audio. Pas d’avertissement de fuite dans les suites exécutées ici.
- Opportunités de déplacement vers un objectif ennemi : indicateur d’inactivité possible, pas preuve qu’une réserve doit avancer. Les contrôles de brouillard examinent les informations autorisées.

## Compilation Android exécutée

Godot 4.5.1, export Android debug signé, SDK/Build Tools 35.0.1, Java 21. Application `org.woerth1870.prototype.v02`, version **0.8.37**, code **50**, min SDK 24 et cible SDK 35. APK de 87876685 octets.

`apksigner verify --verbose --print-certs` : signatures v2/v3 valides ; même certificat de test que V36. `zipalign -c -P 16 -v 4` : alignement 16 Ko réussi. Version lue avec `aapt dump badging`. SHA-256 : `17d3cde5764840dfd9164e8f80a8fa2aaf2553d6ca97cf84923faf91773459a8`.

La compilation et la signature ont réussi. Le scan ADB post-export signale son impossibilité de créer `/home/agent/.android` sur ce cloud en lecture seule ; aucun essai appareil n’a donc été effectué. Ce message n’est pas un échec de compilation de l’APK, vérifié indépendamment.

## Bilan exécuté de la bataille et du rejeu

- Bataille complète : **18 tours, 81 unités déclarées, 80 effectivement entrées**, 1 372 commandes acceptées et aucun état invalide.
- Test initial : **1 483 / 1 484** contrôles réussis. Un échec dû à l’attente incorrecte « tous les renforts sont entrés » ; QG Raoult légalement bloqué par occupation de sa case. Rapport, journal et script initial conservés.
- Le test publié vérifie maintenant « entrés ou légalement en attente ». **Ce prédicat corrigé a été exécuté et réussi pendant le rejeu**. La simulation avec choix IA n’a pas été recommencée après cette correction de test ; le moteur reste identique.
- Rejeu complet : **2 753 / 2 753** contrôles réussis. État final intégral identique à la sauvegarde initiale et checkpoint réel du début du tour 12 enregistré/rechargé exactement.
- Résultat : victoire prussienne mineure, 77,36151 / 14,95249, trois objectifs prussiens ; 418 tirs actifs et 30 assauts.
- Analyse : 331 observations d’occasion de progression, aucun tir/assaut légal laissé disponible en fin de demi-tour. Trois redditions prussiennes. Voir BATAILLE_V37.md et les JSON bruts.

Aucune régression majeure du moteur observée. L’entrée occupée du QG et les réserves parfois immobiles restent des limites à évaluer, sans nouvelle téléportation, changement de scénario ni refonte IA.

## Archive de sources vérifiée

ZIP extrait dans un nouveau répertoire, import Godot 4.5.1 sans cache préexistant, puis sauvegardes **43/43**, contrat de règles **110/110** et interface tactile automatisée **11/11** : tous réussis. La mise à jour finale de l’archive ajoute uniquement ce compte rendu et le résumé de vérification ; les fichiers de production testés sont identiques. Intégrité ZIP contrôlée ; aucun `.git`, `.godot`, APK, compilation Python ou cache dans les sources.
