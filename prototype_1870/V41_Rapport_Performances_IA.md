# V41 — Rapport de performances IA

Mesures conservées de la séance du 14 octobre 2026, vérifiées le 15 octobre. Godot 4.5.1, hôte Linux, sans rendu et sans appareil Android.

## Conclusion

L'équivalence des décisions passe les cas testés. **Le gain de vitesse n'est pas confirmé.** Certaines moyennes sont plus lentes avec le cache. Les mesures sont variables ; elles ne permettent pas d'attribuer avec assurance ces écarts au cache seul. Le code expérimental fourni est conservé sans nouvelle optimisation ni affirmation d'accélération. Une mesure sur appareil cible et sur davantage d'états représentatifs reste nécessaire avant de qualifier le gain.

## Méthode

Le témoin `reference_v41_uncached.gd` est l'IA V41 avec uniquement la réutilisation du rapport de soutien au départ retirée. Les priorités tactiques d'artillerie restent identiques. Chaque variante reçoit le même état observé ; l'ordre d'exécution alterne. Le test vérifie les actions, le classement complet et les scores des candidats, l'absence de mutation de l'observation et la légalité de la commande.

40 décisions successives par difficulté, soit 80 paires, sur un banc réduit de 14 unités. Ces séquences couvrent le début de partie ; les six cas supplémentaires à 81 unités conservent le déploiement initial avec un numéro de tour changé, et ne sont pas des états issus d'une campagne complète. Résultat fonctionnel : 80 actions et 80 classements identiques ; 326/326 contrôles réussis.

## Temps écoulé par décision

| Difficulté | Paires | V41 avec cache, moyenne | Témoin sans cache, moyenne | Réduction du temps moyen |
| --- | --- | --- | --- | --- |
| Normal | 40 | 2190.96 ms | 2353.08 ms | +6.89 % |
| Difficile | 40 | 2729.60 ms | 2287.03 ms | -19.35 % |

Réduction = 100 × (1 − temps avec cache / temps témoin). Une valeur négative signifie un ralentissement mesuré. Ces moyennes ne constituent pas une promesse de vitesse sur téléphone. Les données brutes, actions, nombres de candidats et temps en microsecondes sont dans `optimization/optimization_optimization.json`.

## Mesure complémentaire du temps processeur

Lecture des compteurs utilisateur + système du processus dans `/proc/self/stat` ; 100 ticks par seconde. Échauffement des deux variantes, quatre répétitions appariées pour deux pressions de tour synthétiques (1 et 12) et deux difficultés : 16 paires. 17/17 contrôles réussis. Ce banc évite de compter directement l'attente du processus dans le temps CPU, mais n'élimine pas toutes les variations de l'environnement ni les effets d'ordre et d'exécution.

| Difficulté | Paires | CPU avec cache, moyenne | CPU témoin, moyenne | Réduction des moyennes | Médiane des réductions par paire |
| --- | --- | --- | --- | --- | --- |
| Normal | 8 | 3255.00 ms | 2092.50 ms | -55.56 % | -4.54 % |
| Difficile | 8 | 2918.75 ms | 2385.00 ms | -22.38 % | -1.37 % |

La résolution des compteurs est de 10 ms. Les données brutes sont dans `performance_cpu.json`. Les répétitions comprennent des écarts importants ; les chiffres défavorables sont conservés. Aucun résultat statistique de significativité n'est revendiqué.

## Portée

Les simulations complètes du banc à 14 unités apportent des contrôles de légalité et d'utilisation de l'artillerie. Leurs durées, mesurées lors d'exécutions distinctes et parfois concurrentes, ne servent pas à comparer la rapidité des difficultés ou des variantes. Pas de mesure de fluidité, mémoire, batterie ou temps de réponse sur Android. Pas de bataille complète à 81 unités menée sur 20 tours dans cette campagne de validation.
