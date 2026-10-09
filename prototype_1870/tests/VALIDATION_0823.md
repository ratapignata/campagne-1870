# v0.8.23 — zones de tir de l’artillerie

Sélectionner un canon en batterie avec suffisamment de PA éclaire discrètement les cases accessibles au tir. Calcul partagé avec le combat : portée, relief, bois et unités connues. Les cases amies sont exclues. Les règles existantes de tir autorisé au-dessus de troupes amies en contrebas restent respectées. Le contour de portée seul est supprimé pour les canons. Pas de nouveaux marqueurs sur les ennemis.

Le premier appui sélectionne la cible et affiche un éventuel motif de blocage ; le deuxième confirme le tir. Les unités cachées ne changent pas l’éclairage : une interception par un ennemi caché reste possible, selon la règle antérieure. Aucun tir sur case vide n’est ajouté. L’affichage disparaît à la désélection, pendant l’animation ou quand le canon ne peut plus tirer.

Compatibilité : données de scénario strictement identiques à la v0.8.22, mêmes emplacements et empreintes de sauvegarde. Installer par-dessus la version précédente, sans désinstaller. Les deux camps et les deux scénarios restent disponibles.

Validation : 1188/1188 contrôles moteur (concordance cases/tirs pour les deux camps, relief, bois, amis, portée, PA, déroute, brouillard) ; 6/6 contrôles interface automatisés (sélection, deux appuis, mise à jour, désélection) ; 33/33 contrôles armes ; 7/7 contrôles interception cachée. Exécution Godot 4.5.1 sans écran. Aucun test sur appareil Android physique ni contrôle visuel final ; intensité de l’éclairage à confirmer sur téléphone.

APK Android 0.8.23, code 36. Le contenu historique complet n’est pas intégré à cette version.
