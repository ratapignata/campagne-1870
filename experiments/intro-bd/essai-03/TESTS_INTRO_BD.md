# Tests réellement exécutés — essai BD 3

1 novembre 2026, Godot 4.5.1 officiel, Linux/OpenGL Compatibility llvmpipe. **3 085 assertions réussies : 179 parcours BD avec rendu et 2 906 non-régression.** Aucun test désactivé pour cette révision.

Parcours : six images chargées et empreintes vérifiées, navigation, toucher simulé, précédent/suivant/passage/retour, lecture automatique réelle de 30 secondes, pause et reprise, écran compact et défilement du récit. Chargement direct d’une sauvegarde sans introduction et conservation de son fichier. Captures réellement rendues par Godot, dont la vignette 6 entière à 1280 × 720.

| Suite | Résultat |
| --- | --- |
| `graphics/test_contract` | 2433/2433 |
| `graphics/test_previous_save` | 63/63 |
| `graphics/test_availability10` | 353/353 |
| `graphics/test_feedback12` | 20/20 |
| `v43/test_v4315` | 28/28 |
| `intro_bd/test_resume_direct` | 9/9 |

## Intégrité et APK

Comparaison avec BD 2 : images 1 à 5 et script de l’introduction identiques ; aucun fichier moteur, IA, carte, contrôleur principal, plateforme, sauvegarde ou graphisme du jeu modifié. Le contrôle source par rapport à la stable V43.15 passe également. La fixture BD 3 ne modifie que l’empreinte de l’image 6 ; les fixtures antérieures restent présentes.

APK compilé et signé, paquet identique à BD 2, code 3, même certificat. Signature et archive vérifiées ; les six textures incluses correspondent aux textures importées et testées. Tests et galeries exclus de l’APK. Minimum SDK 24, cible 35 ; ARMv7/ARM64/x86_64. Sonde ADB après export : avertissement de dossier personnel en lecture seule, sans échec de compilation ni de signature.

Archive sources extraite dans un dossier neuf : import éditeur Godot 4.5.1 réussi, reprise directe 9/9 et contrôle d’intégrité source réussis. Ces neuf assertions supplémentaires ne sont pas ajoutées au total principal de 3 085. La recompaction finale ne change que les rapports et preuves.

## Limites

Aucun test sur smartphone physique ni émulateur, aucune mesure de fluidité sur téléphone et aucune nouvelle simulation de bataille complète. Contrôle général des uniformes, sans certification régimentaire ; références de musées bloquées par HTTP 403, non revendiquées comme consultées. Voir `UNIFORMES_ET_PISTES_BD.md`. Preuves brutes dans `captures/introbd3/preuves/`.

## Reproduire

```sh
godot --headless --editor --path . --import
godot --path . --audio-driver Dummy --rendering-method gl_compatibility --script res://tests/intro_bd/test_intro_flow.gd -- /tmp/captures_intro
godot --headless --path . --script res://tests/intro_bd/test_resume_direct.gd
```

Créer le dossier de captures et utiliser un répertoire utilisateur isolé sans sauvegarde pour le test du parcours.
