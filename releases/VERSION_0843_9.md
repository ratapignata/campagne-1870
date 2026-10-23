# V43.9 — Désignations, fiche compacte et projectile noir

23 octobre 2026. Android 0.8.43.9, code 66, Godot 4.5.1.

## Noms de l’infanterie prussienne

Les libellés reg_pru_36 à reg_pru_53 ne se limitent plus à un numéro et « Prusse ». Exemples : « 32e régiment d’infanterie · Prusse », forme de fiche « 32e rég. infanterie » ; « 7e régiment de grenadiers » ; « 37e régiment de fusiliers » ; « 5e bataillon de chasseurs » pour le Jäger correspondant. Les numéros et spécialisations existants sont conservés. Aucune unité n’est transformée en division. Les renforts génériques provisoires restent désignés comme provisoires.

Cette clarification de libellés ne constitue pas une validation historique nouvelle des effectifs et rattachements du scénario, qui conservent leurs réserves documentées. Les unités, identifiants, rattachements et calendriers d’arrivée ne changent pas.

## Fiche des unités

La ligne de description de l’arme et de sa portée est désormais retirée aussi de l’artillerie et de la cavalerie, pour les deux camps. Le nom de la batterie ou du régiment dans le titre reste affiché. Les informations tactiques de munitions, riposte, moral, PA, formation, commandement et ravitaillement restent présentes.

Pour les fiches sans cette ligne, les munitions remontent à y=100 au lieu de 123 et la réaction à y=134 au lieu de 147 ; leur police passe de 18 à 20. Les liaisons sont réalignées dans la colonne droite. Le dernier marqueur d’encerclement conserve un emplacement distinct. Les lignes de contact ennemi et de terrain restent utilisables : leur contenu n’est pas supprimé par la mise en page compacte. Aucune information cachée supplémentaire révélée.

## Tir d’artillerie

La bille, auparavant anthracite, devient noire (#101214), avec un fin liseré gris et une courte traînée sombre. Un rayon minimum la rend visible à faible zoom. Le fin halo crème du projectile est remplacé par le gris. L’éclair de bouche, la fumée, la trajectoire du centre de la bille, les impacts et les durées sont conservés. L’éclair et l’impact peuvent donc rester lumineux ; la bille en déplacement est noire. Le projectile d’infanterie reste inchangé. Une seule bille est dessinée par tir : aucune nouvelle volée ni tir supplémentaire ajouté.

## Règles et sauvegardes

Aucune modification du moteur, du scénario, des profils ou scripts IA : fichiers protégés comparés octet par octet au commit précédent. Cavalerie en défense de village à 1,25, infanterie à 1,50 ; charge 2 PA, variante B 0,90, ripostes, dégâts, portées, isolement/reddition, 20 tours et score 60/20/20 conservés. L’export de sauvegarde reste disponible. Le développement de l’axe de débordement IA n’est pas inclus dans cette version de présentation.

Empreinte de scénario inchangée : sauvegardes précédentes compatibles. Installer sans désinstaller l’application.

## Vérifications réellement exécutées

- Fiches des quatre types d’unités, deux camps : 18/18.
- Interface générale V43 : 30/30.
- Export complet : 28/28.
- Retour EOF Android lors de l’export : 9/9.
- Défense de cavalerie en village 1,25 et migration : 20/20.
- Noms et disposition, résolutions 1280×606 et 1520×720 : 88/88. Vérification de titres entiers sans découpe, suppression de ligne et absence de chevauchement des lignes de gauche. Cette suite a également été réexécutée avec rendu graphique.
- Animation réellement rendue sous X11/OpenGL logiciel llvmpipe : 53/53, dix terrains, quatre zooms (0,42 / 0,72 / 1 / 2,3), cinq phases et contrôle de pixels noirs.

Total : 246 contrôles, aucun échec final d’assertion. Captures inspectées : fiche prussienne 32e régiment, fiche artillerie française, grille des billes sur tous les terrains. Les tests de fiche activent temporairement des renforts dans leur état de test pour inspecter les différents types : cela ne signifie pas une arrivée anticipée dans une partie réelle.

Avertissements observés : ObjectDB et deux ressources encore utilisées à la fermeture de la suite UI ; périphérique audio serveur absent, repli sur pilote muet pour le premier rendu ; avertissement ADB de dossier de préférences en lecture seule pendant l’import. Ils n’ont pas fait échouer les assertions, le rendu, la compilation ou la vérification de signature. Ils ne sont pas présentés comme résolus dans cette version.

APK compilé et signature vérifiée, même certificat de développement. Aucun test physique Android ni nouvelle simulation complète de bataille.

## Fichiers modifiés

Application : war_engine/presentation/main.gd ; war_engine/presentation/map_view.gd ; packs/1870/fr.json ; project.godot ; export_presets.cfg.

Tests : tests/v43/test_rifle_label.gd ; tests/v43/test_animation_render.gd ; tests/v43/test_v439_presentation.gd. Rapport et preuves : VERSION_0843_9.md ; tests/results/0843_9.
