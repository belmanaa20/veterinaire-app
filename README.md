# 🏥 Application de Gestion Vétérinaire - Flutter & Supabase

Application complète de gestion pour pharmacie vétérinaire avec système de facturation sur 45 jours. Compatible Desktop (Windows, Linux, macOS) et Mobile (Android, iOS).

## ✨ Nouveauté: Mode Offline avec Hive

L'application fonctionne maintenant **complètement hors ligne** grâce au cache local Hive! 🚀

- 🔌 **Fonctionne sans connexion internet**
- 💾 **Cache automatique** de toutes les données
- 🔄 **Synchronisation intelligente** (manuelle + automatique)
- 📊 **Indicateur de statut** en temps réel (En ligne/Hors ligne)
- 📱 **Queue de synchronisation** pour opérations offline

👉 Voir [OFFLINE_MODE.md](./OFFLINE_MODE.md) pour la documentation complète

## 📋 Description

Cette application permet de gérer efficacement une pharmacie vétérinaire avec les fonctionnalités suivantes:

- **Gestion des clients**: CRUD complet avec types d'élevage
- **Gestion des produits**: Stock, alertes de stock faible, impression d'étiquettes
- **Facturation sur 45 jours**: Système unique permettant d'ajouter des produits pendant 45 jours
- **Impression PDF**: Factures A4 professionnelles
- **Scanner de codes-barres**: Ajout rapide de produits via scan
- **Alertes automatiques**: Notifications pour échéances et stock faible
- **Interface moderne**: Support mode sombre et design responsive
- **Mode Offline**: Fonctionne sans connexion internet avec synchronisation automatique

## 🗄️ Base de données Supabase

### Configuration (déjà intégrée)

```dart
Project URL: https://teaawvipetvopccqmxpsj.supabase.co
Anon Key: sb_publishable_vFTEmjjf_jWSK-zaPquzsw_8PtVCYXQ
```

### Tables

1. **parametres** - Informations du magasin (logo, signature, cachet)
2. **clients** - Liste des clients avec culture (type d'élevage)
3. **produits** - Produits avec barcode, stock, prix
4. **factures** - Factures (45 jours, statut: OUVERTE/FERMEE/PAYEE)
5. **lignes_facture** - Détails des factures avec date_ajout par produit

### Functions PostgreSQL

- `creer_facture(client_id, numero, delai_jours)` - Créer une facture
- `ajouter_ligne_facture(facture_id, produit_id, quantite, prix)` - Ajouter un produit
- `ajouter_ligne_by_barcode(facture_id, barcode, quantite)` - Ajouter par scan
- `recalculer_facture(facture_id)` - Calculer le total
- `fermer_facture(facture_id)` - Fermer une facture
- `enregistrer_paiement(facture_id)` - Enregistrer un paiement cash

## 🚀 Installation

### Prérequis

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.0.0 ou supérieure)
- Un éditeur de code (VS Code, Android Studio, ou IntelliJ)
- Pour Android: Android SDK
- Pour iOS: Xcode (macOS uniquement)
- Pour Desktop: Dépendances selon la plateforme

### Installation des dépendances

```bash
# Cloner le dépôt
git clone https://github.com/belmanaa20/veterinaire-app.git
cd veterinaire-app

# Installer les dépendances
flutter pub get
```

### Lancement de l'application

#### Desktop (Windows)
```bash
flutter run -d windows
```

#### Desktop (Linux)
```bash
flutter run -d linux
```

#### Desktop (macOS)
```bash
flutter run -d macos
```

#### Web
```bash
flutter run -d chrome
```

#### Mobile (Android)
```bash
flutter run -d android
```

#### Mobile (iOS)
```bash
flutter run -d ios
```

## 📁 Structure du projet

```
lib/
├── main.dart                          # Point d'entrée de l'application
├── config/
│   ├── supabase_config.dart          # Configuration Supabase
│   ├── theme_config.dart             # Thèmes (Light + Dark)
│   └── app_constants.dart            # Constantes de l'application
├── models/
│   ├── parametres.dart               # Modèle des paramètres
│   ├── client.dart                   # Modèle client
│   ├── produit.dart                  # Modèle produit
│   ├── facture.dart                  # Modèle facture
│   ├── ligne_facture.dart            # Modèle ligne de facture
│   └── sync_queue_item.dart          # ✨ Modèle queue de sync offline
├── services/
│   ├── supabase_service.dart         # Initialisation Supabase
│   ├── client_service.dart           # CRUD clients + cache offline
│   ├── produit_service.dart          # CRUD produits + cache offline
│   ├── facture_service.dart          # CRUD factures + RPC + cache
│   ├── pdf_service.dart              # Génération PDF A4
│   ├── label_service.dart            # Impression étiquettes
│   ├── cache_service.dart            # ✨ Service Hive (cache local)
│   ├── connectivity_service.dart     # ✨ Détection Online/Offline
│   └── sync_service.dart             # ✨ Synchronisation Hive ↔ Supabase
├── screens/
│   ├── home_screen.dart              # Dashboard principal
│   ├── clients/
│   │   ├── clients_list_screen.dart
│   │   ├── client_form_screen.dart
│   │   └── client_details_screen.dart
│   ├── produits/
│   │   ├── produits_list_screen.dart
│   │   ├── produit_form_screen.dart
│   │   └── print_labels_screen.dart
│   └── factures/
│       ├── factures_list_screen.dart
│       ├── nouvelle_facture_screen.dart  # Écran principal!
│       ├── facture_details_screen.dart
│       └── barcode_scanner_screen.dart
└── widgets/
    ├── custom_app_bar.dart
    ├── custom_button.dart
    ├── facture_card.dart
    ├── produit_card.dart
    └── connection_status_widget.dart # ✨ Indicateur Online/Offline
```

## 🎯 Fonctionnalités principales

### 1. Gestion des Clients

- Liste complète avec recherche
- Ajout/Modification/Suppression
- Types d'élevage: Bovin, Ovin, Caprin, Avicole, Équin, Autre
- Historique des factures par client

### 2. Gestion des Produits

- Catalogue complet avec stock
- Catégories: Antibiotiques, Vaccins, Vitamines, etc.
- Alertes de stock faible (stock ≤ stock_min)
- **Impression d'étiquettes (80×50mm)** avec barcode, nom et prix

### 3. Système de Facturation (45 jours)

**Workflow complet:**

1. Créer une facture → sélectionner un client
2. Ajouter des produits pendant 45 jours:
   - Manuellement (liste déroulante)
   - Scanner barcode (mobile_scanner)
3. Chaque produit enregistre sa date_ajout
4. Calcul automatique du total
5. Alerte à 7 jours de l'échéance
6. Fermeture de la facture après 45 jours
7. Enregistrement du paiement cash
8. Impression PDF A4

**Statuts de facture:**
- **OUVERTE**: Peut encore ajouter des produits
- **FERMEE**: Ne peut plus modifier, en attente de paiement
- **PAYEE**: Paiement enregistré
- **EN_RETARD**: Dépassé la date d'échéance

### 4. Impression PDF A4

Template professionnel incluant:
- En-tête avec logo et informations du magasin
- Numéro de facture
- Informations client complètes
- Tableau des produits avec **DATE AJOUT** pour chaque ligne
- Total en chiffres et en lettres
- Signature et cachet

### 5. Étiquettes produits (80×50mm)

Étiquettes imprimables comprenant:
- Nom du produit
- Code-barres (EAN-13, EAN-8, UPC-A ou Code128)
- Prix en DA
- Code produit

### 6. Scanner de codes-barres

- Interface moderne avec overlay personnalisé
- Détection automatique
- Support flash et changement de caméra
- Ajout direct à la facture

## 🎨 Design System

### Couleurs
- **Primary**: Blue 900 (#0D47A1)
- **Accent**: Green 600 (#43A047)
- **Background Light**: Grey 50
- **Background Dark**: Grey 900

### Thèmes
- Support mode clair et sombre
- Adaptation automatique selon les préférences système
- Police Cairo pour l'arabe, Roboto pour le français

## 📦 Dépendances principales

```yaml
dependencies:
  # Backend & Cache
  supabase_flutter: ^2.3.0      # Backend Supabase
  hive: ^2.2.3                  # ✨ Cache local offline
  hive_flutter: ^1.1.0          # ✨ Hive pour Flutter
  connectivity_plus: ^6.0.5     # ✨ Détection réseau
  
  # State & UI
  provider: ^6.1.1              # State management
  google_fonts: ^6.1.0          # Fonts
  
  # Barcode & Scanning
  mobile_scanner: ^5.0.0        # Barcode scanner
  barcode_widget: ^2.0.4        # Barcode generation
  
  # PDF & Printing
  pdf: ^3.10.7                  # PDF generation
  printing: ^5.11.1             # Printing
  
  # Utils
  intl: ^0.18.1                 # Internationalization
  uuid: ^4.2.2                  # UUID generation
  path_provider: ^2.1.1         # File paths
  shared_preferences: ^2.2.2    # Preferences
```

## 🔧 Configuration

### Supabase

Les identifiants Supabase sont déjà configurés dans `lib/config/supabase_config.dart`. Aucune configuration supplémentaire n'est nécessaire.

### Permissions

#### Android
Les permissions pour la caméra et Internet sont déjà configurées dans `android/app/src/main/AndroidManifest.xml`.

#### iOS
Ajoutez les permissions dans `ios/Runner/Info.plist` si nécessaire:
```xml
<key>NSCameraUsageDescription</key>
<string>Nécessaire pour scanner les codes-barres</string>
```

## 🐛 Résolution de problèmes

### Erreur de connexion Supabase
Vérifiez que vous avez une connexion Internet active et que les identifiants Supabase sont corrects.

### Problème de scanner barcode
- Vérifiez les permissions de caméra
- Testez sur un appareil physique (émulateur limité)

### Erreur d'impression
Assurez-vous qu'une imprimante est configurée sur votre système.

## 📝 Licence

Copyright © 2025 Pharmacie Vétérinaire. Tous droits réservés.

## 👥 Support

Pour toute question ou problème, veuillez créer une issue sur GitHub.

---

**Note**: Cette application nécessite une base de données Supabase correctement configurée avec les tables et fonctions PostgreSQL mentionnées ci-dessus.
