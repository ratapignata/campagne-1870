# V43.1 — renfort voisin sur entrée ennemie

Correction demandée le 20 octobre 2026. Version Android 0.8.43.1, code 58, même application et certificat de développement. V43.1 remplace V43 comme prototype courant.

Au début du tour du camp, si la case d’arrivée d’un renfort est occupée par un ennemi, le moteur recherche un hexagone immédiatement voisin, libre et accessible. Choix déterministe par index de carte croissant. Aucun occupant n’est déplacé ou détruit, aucun empilement.

Pas d’arrivée sur un terrain infranchissable ou à travers une rivière non pontée. Pas d’exclusion supplémentaire des zones de contrôle : être adjacent à l’ennemi n’accorde aucune immunité ; les règles de commandement, ravitaillement et combat restent normales.

Si toutes les cases voisines sont occupées ou impraticables, le renfort attend sur son entrée d’origine. Une entrée occupée par un ami conserve également son comportement d’attente. Une entrée libre reste prioritaire. Aucun renfort n’arrive avant son calendrier ni pendant la phase adverse.

Cas réel reproduit, graine 187037 : pru_55 reste en (15,4), Raoult entre au tour 3 en (15,3), puis sa position est conservée dans la sauvegarde. Les effectifs, PA, calendrier et position de la cavalerie ne sont pas modifiés pour faciliter l’arrivée.

Règle activée pour le scénario courant V43, pour les renforts des deux camps et tous les types d’unités. Les scénarios V42 archivés gardent leur règle historique, afin de conserver les diagnostics et comparaisons. Le fichier de sauvegarde reste save_v43.json ; les anciennes empreintes V43 sont compatibles. Une partie ancienne déjà en attente n’est pas réécrite au chargement : la nouvelle tentative se fait au prochain début de tour du camp.

Variante B 0,90, projectile anthracite, charge 2 PA, ripostes, isolement/reddition, 20 tours, score 60/20/20, 95 000 Allemands et 50 unités conservés. Aucun bouton TIRER ni bonus IA.
