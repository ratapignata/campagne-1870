# Tests V43.10 réellement exécutés

Godot 4.5.1. 431 contrôles de régression/rendu réussis, aucun échec final d’assertion.

| Suite | Contrôles réussis |
|---|---:|
| Journal des redditions : ennemis vus/cachés, unités propres, doublons, fin de bataille, anciens événements, sauvegarde | 11 |
| Assaut avant ravitaillement : référence, décision corrigée, ordre réel légal, entrée inchangée, Normal/France/QG préservés, attaque défavorable refusée | 8 |
| Compatibilité IA et renseignements autorisés | 18 |
| Mondes cachés | 18 |
| Isolement, retraite et reddition | 45 |
| Encerclement et liaisons | 25 |
| Renforts voisins et Raoult | 32 |
| Interface générale V43 et durée/sons de tir/riposte | 30 |
| Export de sauvegarde | 28 |
| Retour EOF Android | 9 |
| Cavalerie en village 1,25 et migration | 20 |
| Fiches des quatre armes et deux camps | 18 |
| Noms RI et disposition des fiches, absence du suffixe QG | 102 |
| Rendu canon, dix terrains/quatre zooms/cinq phases et pixels du projectile | 53 |
| Rendu de l’infanterie et captures des phases distinctes | 14 |

Les captures réelles ont été produites sous X11/OpenGL logiciel llvmpipe, sans appareil Android. Inspection visuelle du journal, d’une fiche française sans QG et des volées d’infanterie. Les montages UI peuvent activer un renfort afin d’inspecter sa fiche : cela ne change pas son calendrier dans le jeu livré.

Deux continuations supplémentaires de la sauvegarde réelle T12 : référence 114/114 contrôles et correction livrée 100/100, décisions et états validés jusqu’à la fin de phase. Ce ne sont pas deux batailles complètes. Le fichier a été exporté pendant un calcul IA, donc l’ordre transitoire Android n’a pas été inventé ; les deux reprises utilisent une décision fraîche sur le même état. Voir DIAGNOSTIC_IA_T12_V43_10.md et tests/results/0843_10/real_phase_comparison.json.

Le test du pont sur la sauvegarde réelle confirme : assaut avant déplacement = river ; franchissement légal [343,344] exécuté ; commandement et ravitaillement perdus ; assaut après = isolated ; état valide.

Un premier réglage du bonus de tirs groupés a été rejeté après comparaison. Des montages initiaux du test synthétique ont été corrigés pour fournir explicitement les ennemis observables et isoler le choix assaut/ravitaillement ; les résultats du tableau correspondent aux tests finaux. Le scénario de choix est artificiel, sans prétention historique ; la sauvegarde réelle apporte une comparaison distincte.

Avertissements non corrigés dans ce lot : ObjectDB et deux ressources restant utilisées à la fermeture de la suite UI ; avertissement ADB concernant le dossier de préférences non inscriptible pendant l’import/export. Ils n’ont pas fait échouer les assertions ni la signature. Ces avertissements ne sont pas présentés comme résolus.

APK compilé et signature vérifiée avec le certificat existant. Aucune nouvelle bataille complète, aucun essai physique Android. La correction locale de choix d’assaut ne valide pas encore une IA globalement plus efficace : la mobilité et les PA inutilisés ne s’améliorent pas dans l’unique comparaison réelle.
