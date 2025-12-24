# Veterinaire App - Application de Gestion Vétérinaire

Application de gestion vétérinaire complète pour Windows Desktop (et mobile) construite avec Flutter et Supabase.

## Fonctionnalités

### ✅ Modules Implémentés
- **Dashboard**: Vue d'ensemble avec statistiques, alertes stock faible, factures récentes
- **Gestion des Clients**: CRUD complet avec informations propriétaire et animal
- **Gestion des Produits**: Catalogue avec gestion de stock et codes-barres
- **Gestion des Factures**: Création, validation, paiement avec calculs automatiques
- **Paramètres**: Configuration de l'entreprise et paramètres généraux

### 🎨 Design
- Material Design 3
- Thème professionnel aux couleurs vétérinaires
- Interface responsive optimisée pour desktop
- Navigation par sidebar

## Installation

### Prérequis
- Flutter SDK (3.0.0 ou supérieur)
- Dart SDK (3.0.0 ou supérieur)

### Configuration

1. Cloner le dépôt:
```bash
git clone https://github.com/belmanaa20/veterinaire-app.git
cd veterinaire-app
```

2. Installer les dépendances:
```bash
flutter pub get
```

3. Lancer l'application:
```bash
flutter run -d windows
```

## Base de Données

L'application utilise Supabase avec le schéma suivant:

### Tables
- `parametres` - Paramètres de l'application
- `clients` - Informations clients et animaux
- `produits` - Catalogue de produits/services
- `factures` - Factures et devis
- `lignes_facture` - Lignes de facture

### Vues
- `v_factures_complet` - Factures avec détails clients
- `v_factures_a_notifier` - Factures en retard
- `v_produits_stock_faible` - Produits avec stock faible

### Fonctions RPC
- `creer_facture` - Créer une nouvelle facture
- `ajouter_ligne_facture` - Ajouter une ligne à une facture
- `fermer_facture` - Valider une facture
- `enregistrer_paiement` - Enregistrer un paiement

## Configuration Supabase

Les identifiants Supabase sont configurés dans `lib/config/supabase_config.dart`:
- URL: https://teaawwipetvopcqmxpsj.supabase.co
- Anon Key: Configurée dans le fichier

## Structure du Projet

```
lib/
├── config/              # Configuration (Supabase, Theme)
├── models/              # Modèles de données
├── services/            # Services d'accès aux données
├── providers/           # State management (Provider)
├── screens/             # Écrans de l'application
│   ├── dashboard/
│   ├── clients/
│   ├── produits/
│   ├── factures/
│   └── parametres/
├── widgets/             # Widgets réutilisables
├── utils/               # Utilitaires (validators, formatters, constants)
└── main.dart            # Point d'entrée
```

## Technologies Utilisées

- **Flutter**: Framework UI cross-platform
- **Supabase**: Backend-as-a-Service (PostgreSQL, Auth, Storage)
- **Provider**: State management
- **Material Design 3**: Design system
- **Google Fonts**: Typographie (Roboto)
- **PDF & Printing**: Génération et impression de factures
- **Intl**: Formatage dates et devises

## Développement

### Linter
```bash
flutter analyze
```

### Tests
```bash
flutter test
```

### Build Windows
```bash
flutter build windows
```

## Fonctionnalités à Venir

- [ ] Édition complète des produits
- [ ] Création et édition de factures avec lignes
- [ ] Génération PDF des factures
- [ ] Impression des factures
- [ ] Export Excel/CSV
- [ ] Mode sombre
- [ ] Multi-langue (Français/Arabe)
- [ ] Scanner de codes-barres
- [ ] Statistiques avancées

## Licence

MIT License

## Auteur

Développé pour la gestion vétérinaire moderne.
