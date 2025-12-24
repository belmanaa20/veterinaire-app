# Setup and Installation Guide

## Prerequisites

Before you begin, ensure you have the following installed:

1. **Git** - For cloning the repository
2. **Flutter SDK** (3.0.0 or higher)
3. **Dart SDK** (3.0.0 or higher) - Comes with Flutter
4. **Visual Studio 2022** (for Windows builds) with "Desktop development with C++" workload

## Step-by-Step Installation

### 1. Install Flutter

#### On Windows:

```powershell
# Download Flutter SDK
# Visit: https://docs.flutter.dev/get-started/install/windows

# Or use winget (Windows Package Manager)
winget install Flutter.Flutter

# Add Flutter to PATH
# Add the flutter\bin directory to your PATH environment variable
```

#### Verify Installation:

```bash
flutter doctor
```

This command checks your environment and displays a report of the status of your Flutter installation.

### 2. Install Windows Desktop Dependencies

Flutter requires Visual Studio 2022 for Windows desktop development:

```powershell
# Install Visual Studio 2022 Community Edition
# During installation, select:
# - Desktop development with C++
# - Windows 10 SDK (10.0.17763.0 or later)
```

### 3. Enable Windows Desktop Support

```bash
flutter config --enable-windows-desktop
```

### 4. Clone the Repository

```bash
git clone https://github.com/belmanaa20/veterinaire-app.git
cd veterinaire-app
```

### 5. Install Dependencies

```bash
flutter pub get
```

This will download all the required packages specified in `pubspec.yaml`.

### 6. Configure Supabase

The Supabase configuration is already set in `lib/config/supabase_config.dart`:

```dart
static const String supabaseUrl = 'https://teaawwipetvopcqmxpsj.supabase.co';
static const String supabaseAnonKey = 'YOUR_ANON_KEY';
```

**Note**: The anon key is already configured for demo purposes. For production, you should:
1. Create your own Supabase project
2. Update the URL and anon key
3. Set up Row Level Security (RLS) policies

### 7. Create Windows Platform Files

If the Windows platform files don't exist, create them:

```bash
flutter create --platforms=windows .
```

This will generate the necessary Windows-specific files without overwriting your existing code.

### 8. Run the Application

#### Development Mode:

```bash
# Run on Windows
flutter run -d windows

# Or in release mode for better performance
flutter run -d windows --release
```

#### List Available Devices:

```bash
flutter devices
```

### 9. Build for Production

#### Build Windows Executable:

```bash
flutter build windows --release
```

The built application will be in:
```
build/windows/runner/Release/
```

#### Create an Installer (Optional):

You can use tools like:
- **Inno Setup** - Free installer for Windows programs
- **Advanced Installer** - Professional installer
- **MSIX** - Windows Store package

Example with MSIX:
```bash
flutter pub add msix
flutter pub run msix:create
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Flutter Doctor Shows Errors

```bash
# Check what's missing
flutter doctor -v

# Common fixes:
# - Android toolchain: Not needed for Windows-only app
# - Chrome: Not needed for desktop app
# - Visual Studio: Must be installed with C++ tools
```

#### 2. Windows Build Fails

```bash
# Clean the build
flutter clean

# Get dependencies again
flutter pub get

# Rebuild
flutter build windows
```

#### 3. Supabase Connection Errors

- Check your internet connection
- Verify the Supabase URL and anon key
- Check Supabase dashboard for service status
- Ensure your database schema matches the expected structure

#### 4. Missing Dependencies

```bash
# Update Flutter
flutter upgrade

# Update packages
flutter pub upgrade
```

#### 5. Google Fonts Not Loading

Google Fonts requires internet connection on first load. After the first load, fonts are cached.

For offline use:
1. Download fonts manually
2. Add them to `assets/fonts/`
3. Update `pubspec.yaml` to use local fonts

## Database Setup

### Supabase Schema

The application expects the following database structure:

#### Tables:

```sql
-- Parameters
CREATE TABLE parametres (
  id SERIAL PRIMARY KEY,
  nom_entreprise TEXT NOT NULL,
  adresse TEXT,
  telephone TEXT,
  email TEXT,
  tva_defaut NUMERIC(5,2) DEFAULT 20,
  delai_notification_rappel INTEGER DEFAULT 30,
  seuil_stock_faible INTEGER DEFAULT 10,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Clients
CREATE TABLE clients (
  id SERIAL PRIMARY KEY,
  nom TEXT NOT NULL,
  prenom TEXT,
  telephone TEXT,
  email TEXT,
  adresse TEXT,
  notes TEXT,
  nom_animal TEXT,
  type_animal TEXT,
  race_animal TEXT,
  date_naissance_animal DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Products
CREATE TABLE produits (
  id SERIAL PRIMARY KEY,
  designation TEXT NOT NULL,
  code_barre TEXT UNIQUE,
  prix_unitaire NUMERIC(10,2) NOT NULL,
  stock_actuel INTEGER DEFAULT 0,
  stock_minimum INTEGER DEFAULT 5,
  unite TEXT DEFAULT 'Unité',
  categorie TEXT,
  description TEXT,
  actif BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoices
CREATE TABLE factures (
  id SERIAL PRIMARY KEY,
  numero_facture TEXT UNIQUE,
  client_id INTEGER REFERENCES clients(id),
  date_facture DATE DEFAULT CURRENT_DATE,
  statut TEXT DEFAULT 'brouillon',
  total_ht NUMERIC(10,2) DEFAULT 0,
  tva NUMERIC(10,2) DEFAULT 0,
  total_ttc NUMERIC(10,2) DEFAULT 0,
  montant_paye NUMERIC(10,2) DEFAULT 0,
  reste_a_payer NUMERIC(10,2) DEFAULT 0,
  mode_paiement TEXT,
  notes TEXT,
  date_echeance DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Invoice Lines
CREATE TABLE lignes_facture (
  id SERIAL PRIMARY KEY,
  facture_id INTEGER REFERENCES factures(id) ON DELETE CASCADE,
  produit_id INTEGER REFERENCES produits(id),
  designation TEXT NOT NULL,
  quantite NUMERIC(10,2) NOT NULL,
  prix_unitaire NUMERIC(10,2) NOT NULL,
  remise NUMERIC(10,2) DEFAULT 0,
  total_ligne NUMERIC(10,2) NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Views and Functions:

You'll need to create the views and RPC functions as specified in the problem statement. These handle:
- Complete invoice data joining
- Low stock alerts
- Invoice creation with auto-numbering
- Line item management with total recalculation
- Invoice validation and stock updates
- Payment recording

## Development Workflow

### Recommended IDE

**Visual Studio Code** with extensions:
- Flutter
- Dart
- Flutter Widget Snippets
- Error Lens

**Android Studio** also works well with Flutter plugin.

### Hot Reload

During development, use hot reload:
- Press `r` in the terminal to hot reload
- Press `R` to hot restart
- Press `q` to quit

### Debugging

```bash
# Run with debugging
flutter run -d windows --debug

# View logs
flutter logs
```

### Code Analysis

```bash
# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Environment Variables (Optional)

For production, consider using environment variables for sensitive data:

1. Create a `.env` file (add to `.gitignore`)
```
SUPABASE_URL=your_url_here
SUPABASE_ANON_KEY=your_key_here
```

2. Use `flutter_dotenv` package:
```yaml
dependencies:
  flutter_dotenv: ^5.1.0
```

3. Load in `main.dart`:
```dart
await dotenv.load();
```

## Performance Optimization

### Release Build

Always use release mode for production:
```bash
flutter run --release
flutter build windows --release
```

### Reduce App Size

```bash
# Split debug info
flutter build windows --split-debug-info=build/app/outputs/symbols

# Obfuscate code
flutter build windows --obfuscate
```

## Testing

### Run Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/models/client_test.dart

# With coverage
flutter test --coverage
```

## Deployment Checklist

- [ ] Update version in `pubspec.yaml`
- [ ] Test all features thoroughly
- [ ] Run `flutter analyze` with no errors
- [ ] Build in release mode
- [ ] Test the release build
- [ ] Create installer
- [ ] Update README with new version
- [ ] Tag the release in Git
- [ ] Create release notes

## Getting Help

- **Flutter Documentation**: https://docs.flutter.dev/
- **Supabase Documentation**: https://supabase.com/docs
- **GitHub Issues**: Report bugs or request features
- **Stack Overflow**: Tag questions with `flutter` and `supabase`

## Additional Resources

- [Flutter Desktop Documentation](https://docs.flutter.dev/desktop)
- [Supabase Flutter SDK](https://supabase.com/docs/reference/dart)
- [Provider State Management](https://pub.dev/packages/provider)
- [Material Design 3](https://m3.material.io/)

---

**Ready to Go!**

Once setup is complete, you should be able to run the application and start managing your veterinary clinic data!
