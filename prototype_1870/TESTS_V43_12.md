# Tests V43.12 réellement exécutés

Godot 4.5.1 officiel, Linux ; rendu Compatibility sous Xorg/llvmpipe.

## Résultats techniques finaux

18 suites headless : **2 382 / 2 382 contrôles réussis**. Répartition : priorité d’assaut (11), Normal/Difficile/calendrier/brouillard (247), barrage et reprise Normal (16), assaut avant repos (8), compatibilité IA (18), informations cachées (18), isolement (45), liaisons encerclées (25), renforts adjacents (32), interface (31), export (28), EOF Android (9), cavalerie village 1,25 (20), fiche (18), présentation (102), journal (11), variante B et non-régression (1 701), QG Raoult (42).

Rendu canon : **53/53**. Rendu infanterie noire : **54/54**, dont 40 contrôles de contraste sur dix terrains et quatre zooms ; image inspectée. Relecture de la sauvegarde personnelle V43.11 T20, état final valide et original inchangé : **3/3**. Total de ces vérifications : **2 492/2 492**.

La première passe comportait un contrôle Normal comparant encore l’ancienne référence V43.10 ; il a été adapté à la décision utilisateur « Normal = ancien Difficile V43.11 ». Les tests ont été relancés avec la bonne référence et la reprise d’attelage est également vérifiée. Le problème de priorité entre tir et assaut de la première itération V43.12 a été reproduit puis corrigé avant livraison ; le test dédié conserve le checkpoint de simulation et la référence avant correction.

## Simulation tactique

Référence : V43.11 Difficile, test historique du 26 octobre. Nouvelle simulation V43.12 depuis T1, puis rejeu chronologique et continuation finale à partir de la phase prussienne T8, après une correction de décision active uniquement dès T8. Le rapport ANALYSE_IA_V43_12.md détaille cette méthode et les limites. La continuation finale atteint la fin T10 : **2117/2117 contrôles**, aucun ordre illégal, état invalide ou plafond d’actions atteint. Le préfixe rejoué représente 735 ordres et 1 472 contrôles, compris dans ce total ; ne pas les additionner une deuxième fois.

Wœrth est occupé au T4 contre T9 en référence. Frœschwiller est contrôlé en fin T8 contre T10. Cela inclut les nouvelles décisions et l’avance autorisée des renforts ; ce n’est pas une mesure isolée de l’intelligence de l’IA.

## APK et limites

Compilation Android réussie, version 0.8.43.12, code 69, application org.woerth1870.prototype.v02. Signature vérifiée avec le même certificat de développement que V43.11 : SHA256 57c00efad8c9b822d4a1d63238a4137b9afc97b6e9248076f4f54bb292ae846c. Le profil Normal archivé est bien présent dans l’APK et identique à V43.11.

Aucun essai physique Android, aucune nouvelle simulation autonome complète de 20 tours, aucune reproduction exacte de la partie humaine fournie au T20, aucun benchmark de performances sur appareil. Les contrôles automatisés ne remplacent pas ces essais.

## Reproduction

Le rejeu et la continuation effectivement utilisés :

```sh
godot --headless --path prototype_1870 --script res://tests/v43/replay_v4312_prefix_and_continue.gd -- res://tests/v43/fixtures/v4312_prefix_to_fr_t8.json /tmp/v4312.json
```

Pour lancer à nouveau toute la politique finale depuis T1, un pilote autonome est également fourni (cette nouvelle exécution complète n’a pas été lancée après le dernier ajustement) :

```sh
godot --headless --path prototype_1870 --script res://tests/v43/simulate_v4312_woerth.gd -- /tmp/v4312_autonome.json
```

Employer Godot 4.5.1 ; sous Linux, les répertoires XDG de configuration, données et cache doivent être accessibles en écriture.
