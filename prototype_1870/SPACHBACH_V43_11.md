# Vérification de Spachbach

Le village du scénario est en (17,11), index 347. Le classement des rives, en coupant toutes les arêtes de rivière y compris les ponts, le place à l’ouest. L’archive development/historical_trial0825/map_candidate.json classe également la tuile 347 « west » et y rattache Spachbach. Le point source extrait reste du même côté du tracé local de la Sauer. Le nord de la carte est dirigé vers la gauche : le haut de l’écran ne correspond pas au nord.

L’ancien texte se trouvait 38 pixels au-dessus du centre et pouvait sembler situé sur l’autre rive. Il est maintenant 43 pixels sous le centre, avec mise à l’échelle au zoom. Le village et toutes les données de terrain restent identiques. Rendu inspecté à deux zooms ; test de rive, offset et absence de mutation des données réussi.

Limite historique : il s’agit d’une cohérence avec une extraction historique préexistante, pas d’un nouveau contrôle géodésique indépendant. Les références originales https://www.dilibri.de/ubtr/content/titleinfo/1925170 et https://doi.org/10.3931/e-rara-101646 n’ont pas pu être rouvertes (proxy 403). L’archive de géoréférencement annonce une erreur RMS d’environ 267 mètres. Les limites communales d’Oberdorf-Spachbach ne permettent pas, seules, de localiser le hameau par rapport à la rivière. Aucun déplacement arbitraire du village n’a donc été effectué.
