> Document de départ conservé pour traçabilité. Pour les résultats de cette livraison, consulter V41_Rapport_Tests.md et V41_Rapport_Performances_IA.md.

# V41 expérimentale — tir d'infanterie et artillerie prussienne

Base : archive V40 fournie. **Pas d'APK compilé, pas de test Godot ni de simulation de bataille complète.**

## Changements
- Scénario principal `packs/1870/regimental_trial.json` : facteurs de distance à 2 hexagones, Chassepot 0,65 → **0,60** (66 pertes théoriques), Dreyse 0,50 → **0,52** (57,2 pertes théoriques). L'écart passe de +30 % à +15,38 %. Les facteurs à 1 et 3 hexagones restent inchangés.
- `war_engine/ai/tactical_ai.gd` : les deux niveaux d'IA offensive accordent une priorité supplémentaire aux cibles retranchées et aux défenseurs proches d'infanterie alliée ; le mode difficile pondère davantage ces opportunités. Les batteries reçoivent aussi un bonus de décision pour atteindre une position de tir lorsqu'elles n'en ont pas. Aucun dégât supplémentaire n'est attribué à l'artillerie.
- Numéro de version du projet et du preset Android : 0.8.41, versionCode 54.

## Limites et précautions
- Le réglage de tir est appliqué **uniquement au scénario régimentaire principal** ; les anciens packs de compatibilité ne sont pas altérés.
- La priorité des tirs reste opportuniste : l'IA ne dispose pas d'un plan pluri-tours explicite liant batterie et régiment. Ce développement nécessiterait un test d'intégration Godot.
- Les heuristiques n'accèdent qu'aux unités du modèle d'observation filtré déjà utilisé par l'IA.
- Les données de sauvegarde, règles de cavalerie, riposte, ravitaillement, commandement, score et coûts en PA sont conservés.
- **À tester dans Godot avant utilisation Android** : parsing GDScript, replay IA Normal/Difficile, scénarios de combat, stabilité, sauvegardes et export APK.

## Valeurs calculées à deux hexagones
| | V40 | V41 expérimentale |
|---|---:|---:|
| Français | 110 × 0,65 = 71,5 | 110 × 0,60 = 66,0 |
| Prussiens | 110 × 0,50 = 55,0 | 110 × 0,52 = 57,2 |
| Rapport FR / PR | 1,300 | 1,154 |

Il s'agit d'un **prototype de test**, non d'une V41 finale validée.
