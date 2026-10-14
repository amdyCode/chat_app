# 💬 Chat App — Messagerie Instantanée Temps Réel

Application mobile Flutter moderne de messagerie 1:1 en temps réel, propulsée par **Firebase** (`firebase_auth`, `cloud_firestore`) et architecturée avec **GetX**.

---

## 📱 Aperçu de l'Application

| 🔐 Authentification | 👥 Discussions & Contacts | 💬 Chat 1:1 en Direct |
| :---: | :---: | :---: |
| ![image alt]()| ![image alt]() | ![image alt]() |
| *Connexion, inscription et réinitialisation* | *Contacts, présence et statut de frappe* | *Bulles de chat, accusés et envoi instantané* |

---

## ✨ Fonctionnalités Principales

### ⚡ 1. Messagerie en Temps Réel (Real-Time Messaging)
* **Affichage optimiste (0 ms de latence)** : la bulle de message s'affiche immédiatement pour l'expéditeur dès l'appui sur Envoyer, tandis que la synchronisation Firestore opère en tâche de fond.

### 🟢 2. Présence en Ligne & Indicateur de Saisie (Online & Typing Indicators)
* **Présence dynamique** : passage automatique à *En ligne* ou *Hors ligne* selon le cycle de vie de l'application (`AppLifecycleState`).
* **Indicateur de frappe en direct** : notification *"En train d'écrire..."* visible en temps réel sur la carte de contact et dans la discussion.

### 👁️ 3. Accusés de Réception & de Lecture (Read Receipts)
* Suivi du cycle de vie du message : `sent` (✓ envoyé), `delivered` (distribué) et `read` (✓✓ lu).
* Marquage automatique des messages reçus à l'état `read` avec enregistrement de l'heure exacte de lecture (`readAt`) dès l'ouverture du chat.

### 🔴 4. Compteur de Messages Non Lus (Unread Count)
* Badge dynamique indiquant le nombre de nouveaux messages par conversation sur la page d'accueil.
* Remise à zéro automatique en base de données dès consultation de la discussion.

### 🚫 5. Blocage & Déblocage de Contacts (Block / Unblock)
* Contrôle total sur les échanges : possibilité de bloquer ou débloquer n'importe quel contact depuis le menu d'options.
* Désactivation du champ de saisie, affichage d'un bandeau d'alerte et filtre dédié *"Bloqués"*.

## 🗂️ Structure du Projet

```text
chat_app/
├── images/                         # Captures d'écran de l'application
│   ├── img1.png                    # Écran de connexion / inscription
│   ├── img2.png                    # Écran d'accueil et discussions
│   └── img3.png                    # Écran de chat 1:1
├── lib/
│   ├── controllers/                # Contrôleurs GetX (MVC)
│   │   ├── auth_controller.dart
│   │   ├── chat_controller.dart
│   │   └── home_controller.dart
│   ├── models/                     # Modèles métier
│   │   ├── message.dart
│   │   └── user.dart
│   ├── screens/                    # Vues / Écrans principaux
│   │   ├── auth_screen.dart
│   │   ├── chat_screen.dart
│   │   └── home_screen.dart
│   ├── services/                   # Services d'infrastructure Firebase
│   │   ├── auth_service.dart
│   │   └── chat_service.dart
│   ├── theme/                      # Palette de couleurs et thèmes visuels
│   │   ├── app_colors.dart
│   │   └── app_theme.dart
│   ├── widgets/                    # Composants réutilisables
│   │   ├── message_item.dart
│   │   └── user_avatar.dart
│   ├── firebase_options.dart       # Configuration générée FlutterFire
│   └── main.dart                   # Point d'entrée de l'application
└── pubspec.yaml                    # Dépendances Flutter & Firebase
```