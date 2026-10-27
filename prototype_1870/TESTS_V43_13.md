# Tests V43.13 réellement exécutés

Godot 4.5.1 officiel, Linux, rendu Compatibility sous Xorg/llvmpipe.

## Contrôles techniques finaux

19 suites automatisées : **2 412 / 2 412 contrôles réussis**. Elles comprennent les nouveaux tests d’objectif à Wœrth, de conservation des objectifs et scores des anciennes parties, de batterie prête à tirer, de déploiement suivi de tir, d’approche conservant les PA d’assaut, de reprise du plan avec une nouvelle instance et d’invalidation d’un plan sans PA (30 contrôles, dont le refus sûr d’un ancien fichier mal formé). Les suites existantes couvrent notamment variante B et combats (1 701), isolement, liaisons, brouillard de guerre, renforts, Raoult, interface, export, cavalerie en village et présentation.

Rendu canon : **53/53** ; rendu infanterie : **54/54**. Contrôle visuel de la scène réelle avec l’objectif Wœrth vide puis occupé : étoile 2 à Wœrth, lisible avec le pion présent. La carte, ses villages, routes et rivière restent identiques.

Relecture de la sauvegarde personnelle V43.11 T20 terminée : **3/3**. Son résultat est exactement conservé, ses objectifs restent à leurs anciennes positions et le fichier original est intact. Les tests synthétiques couvrent également une partie ancienne non terminée, son réenregistrement et une nouvelle partie revenant à Wœrth.

Total de ces contrôles techniques : **2 522/2 522**.

Des anciens tests de migration comparaient tout l’état sans accepter la nouvelle métadonnée objective_layout. Ils ont été adaptés pour exiger explicitement cette métadonnée et comparer tous les autres champs à l’identique. Les erreurs d’indentation introduites dans ces helpers de test ont été corrigées ; les suites concernées, y compris leur dépendance d’export, ont été relancées avec succès. Aucun contrôle de combat n’a été supprimé ou assoupli.

Avertissement restant : la fermeture du test UI affiche encore ObjectDB instances leaked et deux ressources utilisées à la sortie, bien que ses assertions réussissent. La cause n’a pas été corrigée dans ce lot. Les rendus serveur affichent aussi l’avertissement VSync non pris en charge par llvmpipe ; les captures et tests de pixels ont bien terminé.

## Comparaison de difficulté

Deux simulations autonomes complètes depuis T1 jusqu’à fin T10, sur le nouveau placement commun des objectifs, même graine/style et même défense française active. Normal : **2 199/2 199 contrôles de légalité et d’état** ; Difficile : **2 365/2 365**. Total séparé : **4 564 contrôles**, aucun ordre illégal, état invalide ou plafond d’actions atteint. Pas de saut à un tour avancé ni de modification d’effectif ou de PA.

Normal : 117 tirs de canon et 15 assauts. Difficile : 144 et 29. Les trois objectifs sont prussiens en fin T8 en Difficile ; Frœschwiller reste français fin T10 en Normal. Voir COMPARAISON_NORMAL_DIFFICILE_V43_13.md pour les tirs d’infanterie, pertes, prisonniers, objectifs et limites.

## APK et limites

Compilation Android réussie, version 0.8.43.13, code 70, application org.woerth1870.prototype.v02. Signature vérifiée, même certificat de développement : SHA256 57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c. La définition Wœrth 2 et l’ancienne disposition de compatibilité sont présentes dans l’APK.

Aucun essai physique Android. Aucune nouvelle campagne complète de vingt tours, aucune reproduction exacte de la partie humaine et aucune généralisation à tous les styles/graines. Les scores de mi-bataille ont le niveau pending et ne sont pas des résultats finaux.

## Reproduction

Le pilote fourni conserve la même logique de défense et de simulation que les deux exécutions, avec le mode passé en argument :

```sh
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4313_modes.gd -- medium /tmp/normal.json
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4313_modes.gd -- hard /tmp/hard.json
```

Employer Godot 4.5.1 et des répertoires XDG de configuration, données et cache accessibles en écriture. Le pilote écrit les décisions et un état séparé après chaque phase ; il peut prendre plusieurs dizaines de minutes. Les rapports publiés ne contiennent aucune sauvegarde personnelle complète.
