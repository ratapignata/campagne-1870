# V43.14 — liaisons expliquées, batteries, protection et rapport

Base : V43.13, branche `feature/v43.14-links-batteries-battle-report`. Le comportement validé constitue la référence documentée dans REFERENCE_IA_V43.md.

## 1. Liaisons

La fiche affiche « Double coupure » lorsque commandement et ravitaillement sont tous deux perdus. Toucher Cmd. ou Ravit. ouvre une explication de l’état, du motif, du QG de rattachement, du chemin de commandement mesuré lorsqu’il est disponible, du plafond du tour et de celui applicable au renouvellement avec ces liaisons. Une coupure n’équivaut pas à un encerclement ou une déroute.

Les nouveaux événements de coupure conservent les deux états, leurs motifs, la distance de commandement et l’identifiant du QG. Le journal présente ces informations uniquement pour son propre camp. Aucun hexagone d’ennemi caché n’est révélé. Les anciens événements restent lisibles avec la mention « motif détaillé non enregistré » : aucun passé n’est inventé.

Les champs ajoutés sont facultatifs, validés avant chargement et normalisés à la relecture. Le format enveloppe/checksum et le fichier de sauvegarde restent identiques. Le contenu du scénario n’a pas changé : les sauvegardes V43.13 ne nécessitent aucune nouvelle migration d’objectifs.

## 2. Batteries sans contribution

Cause reproduite dans un état synthétique : une batterie sans tir reste en garnison sur un objectif déjà contrôlé, parce que la mission reste cet objectif et déclenche la règle de maintien sur place. Une défense adverse observée est pourtant au contact de son infanterie, plus loin.

En Difficile prussien, une batterie sans ligne de tir reçoit une mission de soutien vers un combat observé à trois hexagones au plus d’une infanterie amie. Les contrôles existants de terrain, mouvement, PA, sécurité, portée, ligne de vue et distance à sa formation restent appliqués. Une batterie disposant déjà d’une ligne utile conserve sa stabilité et son tir.

Test avant/après : le témoin termine son activation ; la version courante dételle, suit un déplacement légal, puis se remet en batterie et tire au renouvellement suivant. Aucun délai uniforme de tir n’est garanti pour les autres positions.

Cela corrige une cause démontrée ; cela ne prétend pas reconstituer pourquoi chacune des trois batteries de la partie humaine s’est tue après T8. La sauvegarde T20 ne conserve pas toutes les positions intermédiaires.

## 3. Éléments avancés

En Difficile prussien, un mouvement individuel est refusé s’il abandonne les deux liaisons, n’a aucun soutien de combat ami à deux hexagones et pénètre à deux hexagones d’au moins deux ennemis observés. Une unité déjà seule et doublement coupée privilégie davantage un mouvement rétablissant au moins une liaison.

Les attaques groupées restent évaluées comme avant. Les charges et assauts n’ont pas de nouveau coefficient ; les mécanismes de retraite, reddition, ZOC, commandement et ravitaillement restent inchangés. La protection reste une décision limitée aux informations observées et ne rend pas les unités invulnérables à un encerclement ultérieur.

Normal et doctrine française inchangés. La comparaison de reprise T11–T12 et les contrôles de légalité sont détaillés dans TESTS_V43_14.md.

## 4. Rapport de bataille

Depuis l’écran de résultat, « Rapport détaillé de bataille » présente les objectifs et leurs valeurs, les forces initiales/restantes, les pertes hors prisonniers, les prisonniers, les unités capitulées, le calcul détaillé 60/20/20 pour les deux camps, les tirs/assauts/charges/ripostes, les captures et redditions ainsi que l’évolution des pertes par tour.

Le rapport complet est réservé aux parties terminées. Il utilise la disposition réelle des objectifs de la sauvegarde, y compris Elsasshausen dans les anciennes parties. Le journal courant utilise désormais lui aussi les objectifs réels au lieu de l’ancien en-tête fixe. Les historiques manquants d’anciennes parties ne sont pas reconstitués.

## Conservation des règles et installation

Charge 2 PA ; 20 tours ; variante B 0,90 ; score 60/20/20 ; Wœrth 2 dans les nouvelles parties ; 95 000 Allemands / 50 unités ; ripostes, isolement, renforts, coûts, portées et animations inchangés. Aucun bouton TIRER ni bonus militaire ajouté. Carte, effectifs, armes, règles de contenu et profils d’IA identiques à V43.13.

APK 0.8.43.14, code Android 71, même application et certificat de développement. Installer comme mise à jour sans désinstaller pour conserver les sauvegardes. Aucun test physique Android ; compilation et signature contrôlées dans l’environnement cloud.
