# Validation 0.8.16

- test_revision0816.gd : 43/43 contrôles. Cavalerie 4 PA, charge 2 PA pour les
  deux camps ; déplacement épuisant tous les PA annulable ; état exact restauré ;
  sauvegarde/reprise ; découverte propre bloquante ; observation par l’ennemi
  seul non bloquante ; motifs persistants et non transmis à l’IA ; blocage après
  les actions engagées ; six décisions IA légales (deux camps, trois difficultés).
- test_river0814.gd -- --quick : 108/108 contrôles de franchissement.
- test_ui0816.gd : 50/50 en 1280×720 et 50/50 en 1520×720. Tests SANS AFFICHAGE,
  contrôleurs appelés directement : pas une simulation de l’entrée Android réelle.
  Coûts, annulation à 0 PA, retour après traversée, absence de chevauchement,
  messages, sauvegarde 0.8.15, reprise et nouvelle partie ; marqueur sur rivière,
  aucun marqueur de gué sur pont ; animation non bloquante et aucune fuite de
  position ennemie ; courbes sur les changements de niveau.
- APK signé v2/v3, versionCode 29, versionName 0.8.16, même package et certificat.

Limites : rendu graphique non inspecté, serveur X virtuel indisponible (création
  des sockets refusée). Pas d’appareil ou d’émulateur Android utilisé. L’affichage
  des nouveaux effets et le confort doivent encore être essayés sur téléphone.
  Pas de nouvelle campagne de tests d’équilibrage.
