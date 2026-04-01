# Windows Native Optimizer & Cleaner 🚀

Un script PowerShell léger utilisant exclusivement des outils natifs Windows pour améliorer la vie privée et les performances.

## ✨ Fonctionnalités
- **Confidentialité :** Désactivation de la télémétrie et de la localisation.
- **Performance :** Optimisation des effets visuels et de la précision souris.
- **Maintenance :** Nettoyage des fichiers temporaires, cache DNS et réparation système (SFC/DISM).
- **Mises à jour :** Mise à jour automatique de tous les logiciels via `Winget`.

## ⚠️ Précautions
Certaines actions (comme la désactivation de BitLocker) touchent à la sécurité du système. 
Lisez attentivement les descriptions dans l'interface avant de cliquer.

## 🛠️ Installation
1. Téléchargez le fichier `Optimizer.ps1`.
2. Faites un clic droit -> **Exécuter avec PowerShell**.
   *(Le script demandera automatiquement les droits administrateur)*

## 🤝 Contribuer
Les suggestions sont les bienvenues ! N'hésitez pas à ouvrir une "Issue" ou à proposer une modification (Pull Request).

## 🛠 Windows Native Optimizer - Carnet de bord technique
Ce document résume les défis rencontrés lors du développement du script sous PowerShell 5.1 et les solutions implémentées pour garantir stabilité et visibilité.

1. Le problème d'encodage (Les caractères "Ã©")
Problématique : PowerShell 5.1 ne gère pas l'UTF-8 standard par défaut. Les accents dans l'interface graphique s'affichaient avec des symboles étranges (ex: PrivÃ©e).

Résolution : Forcer l'enregistrement du fichier .ps1 en encodage UTF-8 avec BOM (Byte Order Mark). C'est le seul format qui permet à la fois de garder les accents et d'être lu correctement par le moteur Windows de base.

2. Les erreurs de "Pipeline" et "Surcharge introuvable"
Problématique : L'utilisation de fonctions trop complexes (boucles foreach pour créer les boutons) générait des erreurs rouges massives. PS 5.1 perdait la trace des objets en mémoire lors de la création de l'interface.

Résolution : Abandon de l'automatisation dynamique. Chaque élément de l'interface (bouton, label, couleur) est maintenant écrit "en dur" (codage à plat). C'est plus verbeux dans le code, mais c'est la seule méthode 100% stable sur les anciennes versions de Windows.

3. Le "gel" de l'interface pendant DISM / SFC
Problématique : Les outils de réparation système (dism.exe et sfc.exe) sont des processus lourds et synchrones. Lancés directement, ils bloquaient la fenêtre du script qui affichait "Ne répond pas". De plus, aucun suivi n'était visible.

Résolution :

Utilisation de Start-Process -Wait. Cela ouvre une console temporaire qui montre la progression réelle (les %).

L'interface principale attend la fermeture de cette console avant de reprendre la main.

4. L'absence de rapports (Le côté "C'est con")
Problématique : Une fois la fenêtre de scan fermée, l'utilisateur ne savait pas si Windows était réparé ou non.

Résolution : Implémentation de la capture de l'ExitCode. Le script vérifie maintenant le code de retour envoyé par Windows à la fin de la tâche :

Code 0 = Succès / Rien à signaler.

Code différent de 0 = Erreur ou fichiers corrompus détectés.
Le résultat est immédiatement transcrit en texte clair dans la zone de logs verte.

5. Droits Administrateurs
Problématique : La plupart des commandes (BitLocker, DISM) échouaient silencieusement si le script n'était pas lancé "En tant qu'administrateur".

Résolution : Ajout d'un auto-élévateur au début du script. S'il détecte qu'il n'est pas admin, il relance automatiquement une instance avec le bouclier Windows (UAC) pour l'utilisateur.

Version actuelle du moteur : v4.1 (Stable - PS 5.1 Ready)
