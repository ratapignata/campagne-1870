# V43.10 — Journal, noms, animations et assaut opportuniste

23 octobre 2026. Android 0.8.43.10, code 67. Mise à jour sur V43.9, avec les corrections précédentes conservées.

## Journal des redditions

Une rubrique « Redditions confirmées » figure en tête du journal : tour, camp, nom de l’unité et nombre de prisonniers. Les doublons entre historique de bataille et historique de soutien sont supprimés. Les redditions des deux camps deviennent toutes consultables à la fin de bataille.

Pendant la partie, les redditions propres sont connues ; les redditions ennemies ne sont montrées que si elles ont été observées ou confirmées par un combat enregistré. Les événements futurs mémorisent le nom autorisé pour chaque observateur AVANT la disparition de l’unité. Une unité vue sans identification exacte reste générique. Les anciens événements sans ces métadonnées restent lisibles ; une reddition ancienne non confirmée reste cachée jusqu’à la fin de bataille. Ces métadonnées sont retirées des observations IA avec les historiques privés.

## Noms

Les régiments d’infanterie utilisent RI : par exemple « 32e RI ». Grenadiers/fusiliers conservent leur spécialisation. BCP, RTA, bataillons de chasseurs et noms de cavalerie restent distincts : ces unités ne sont pas transformées en régiments d’infanterie ordinaires. La mention du QG rattaché est retirée du titre des régiments, pour les deux camps. Les unités QG gardent naturellement leur propre nom « QG Raoult », etc. Les groupes et règles de commandement ne changent pas.

## Animations

Canon : retour à l’effet de la V43.8, avant la bille noire avec traînée de V43.9. Le corps de la fonction de dessin de l’effet canon a été comparé à cette référence : il est identique, hors branche réservée au nouveau tir d’infanterie. Projectile anthracite #252a30, éclair, fumée, trajectoire et impact précédents rétablis.

Infanterie : trois éclairs brefs décalés, fumées plus fines, traits de volée gris clair et petits impacts. Il s’agit d’une illustration d’un UNIQUE événement de tir : aucun tir réel, dégât, coût de PA, consommation de munitions ou budget de riposte supplémentaire. Les durées et sons de combat existants sont conservés.

## IA prussienne Difficile

Correction limitée d’une priorité confirmée : une unité d’infanterie qui dispose d’un assaut légal et déjà accepté par le filtre tactique ne choisit plus de refaire ses munitions à sa place. La mêlée ne consomme pas les munitions du tireur dans les règles existantes. Les seuils de rapport de forces et l’estimation après riposte restent inchangés. Normal et la doctrine française ne sont pas modifiés ; la cavalerie, l’artillerie et les QG sont exclus de cette correction.

Dans la reprise contrôlée de la sauvegarde T12 reçue : deux assauts au lieu d’un ; le 80e RI prussien prend la case d’un défenseur faible au lieu de se ravitailler. Le verrou de Wœrth n’est pas supprimé : le franchissement légal du pont met encore le fantassin de tête en double coupure, qui interdit ensuite l’assaut. Les résultats ne valident pas une meilleure progression globale : moins d’unités ont bougé et davantage de PA restent inutilisés dans cet essai. Voir DIAGNOSTIC_IA_T12_V43_10.md.

Un premier essai de plafonnement du bonus de tirs groupés a été écarté : il n’augmentait pas les assauts. Il ne figure pas dans le code livré.

## Objectifs et fusion : avis, sans modification de règle

Les trois objectifs restent Frœschwiller 3 / Elsasshausen 2 / Niederwald 1. Le remplacement éventuel de Niederwald par Wœrth à 1 point et la fusion sont étudiés dans PROPOSITIONS_OBJECTIFS_FUSION_V43_10.md ; aucun objectif n’est déplacé et aucune fusion n’est ajoutée.

## Compatibilité et limites

Même empreinte de scénario et même enveloppe JSON. Les métadonnées facultatives de reddition sont conservées dans les nouvelles sauvegardes ; les anciennes continuent de charger. L’export fourni a été validé et utilisé dans une copie de simulation, sans modifier l’original.

Charge 2 PA, cavalerie en défense de village 1,25, infanterie 1,50, variante B 0,90, ripostes, isolement/reddition, mouvements, portées, dégâts, 20 tours et score 60/20/20 conservés. Aucun bouton TIRER.

Godot 4.5.1 : 431 vérifications de régression et de rendu réussies. Comparaison supplémentaire de deux continuations de phase T12, avec 114 contrôles sur la référence et 100 sur la version corrigée. APK compilé et signature vérifiée avec le certificat existant. Pas de test Android physique, ni de nouvelle bataille complète.

Installer par-dessus l’application existante, sans la désinstaller. Voir TESTS_V43_10.md pour les résultats, avertissements et limites.
