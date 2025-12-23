#!/bin/bash

# Script de test pour le mode offline
# Ce script aide à vérifier le fonctionnement du mode offline

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🧪 Tests du Mode Offline - Veterinaire App                 ║"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo ""

# Vérifier que Flutter est installé
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter n'est pas installé"
    echo "   Télécharger depuis: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter installé: $(flutter --version | head -n 1)"
echo ""

# Installer les dépendances
echo "📦 Installation des dépendances..."
flutter pub get
echo ""

# Analyser le code
echo "🔍 Analyse du code..."
flutter analyze
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  📝 Scénarios de test manuels                                ║"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo ""
echo "Scénario 1: Mode Online (normal)"
echo "  1. Lancer l'app avec connexion internet"
echo "  2. Naviguer vers Clients"
echo "  3. Vérifier l'indicateur: 🟢 En ligne"
echo "  4. Charger la liste des clients"
echo "  5. Vérifier dans les logs: '✅ Clients from Supabase + cached'"
echo ""

echo "Scénario 2: Mode Offline (création)"
echo "  1. Lancer l'app avec connexion internet"
echo "  2. Charger les données (Clients, Produits)"
echo "  3. ⚠️ COUPER LA CONNEXION INTERNET"
echo "  4. Vérifier l'indicateur: 🟠 Hors ligne"
echo "  5. Créer un nouveau client"
echo "  6. Vérifier l'indicateur: 🟠 Hors ligne + 🔵 1 en attente"
echo "  7. Vérifier dans les logs: '💾 Client sauvegardé offline (sera synchronisé)'"
echo ""

echo "Scénario 3: Synchronisation automatique"
echo "  1. (Suite du scénario 2)"
echo "  2. ⚠️ RÉTABLIR LA CONNEXION INTERNET"
echo "  3. Attendre quelques secondes"
echo "  4. Vérifier dans les logs: '🌐 Connexion restaurée - synchronisation...'"
echo "  5. Vérifier dans les logs: '🔄 Processing sync queue...'"
echo "  6. Vérifier dans les logs: '✅ Synced: insert on clients'"
echo "  7. Vérifier l'indicateur: 🟢 En ligne + 🔵 0 en attente"
echo ""

echo "Scénario 4: Synchronisation manuelle"
echo "  1. Lancer l'app (Online ou Offline)"
echo "  2. Appuyer sur le bouton 🔄 Refresh dans l'AppBar"
echo "  3. Vérifier le SnackBar: '✅ Synchronisé!'"
echo ""

echo "Scénario 5: Persistance du cache"
echo "  1. Lancer l'app (Online)"
echo "  2. Charger les données"
echo "  3. Fermer complètement l'app"
echo "  4. ⚠️ COUPER LA CONNEXION INTERNET"
echo "  5. Rouvrir l'app"
echo "  6. Naviguer vers Clients/Produits"
echo "  7. Vérifier que les données s'affichent instantanément"
echo "  8. Vérifier dans les logs: '💾 Clients from Hive cache (N items)'"
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🔍 Vérifications Hive                                       ║"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo ""
echo "Emplacements du cache Hive:"
echo ""
echo "Windows:"
echo "  C:\\Users\\[USER]\\AppData\\Roaming\\veterinaire_app\\hive\\"
echo ""
echo "Linux:"
echo "  ~/.local/share/veterinaire_app/hive/"
echo ""
echo "macOS:"
echo "  ~/Library/Application Support/veterinaire_app/hive/"
echo ""
echo "Android (nécessite adb):"
echo "  /data/data/com.example.veterinaire_app/app_flutter/hive/"
echo "  $ adb shell"
echo "  $ run-as com.example.veterinaire_app"
echo "  $ ls app_flutter/hive/"
echo ""

echo "Boxes Hive créées:"
echo "  ✓ clients.hive"
echo "  ✓ produits.hive"
echo "  ✓ factures.hive"
echo "  ✓ parametres.hive"
echo "  ✓ sync_queue.hive"
echo "  ✓ app_settings.hive"
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  🚀 Commandes de lancement                                   ║"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo ""
echo "Desktop Windows:"
echo "  $ flutter run -d windows"
echo ""
echo "Desktop Linux:"
echo "  $ flutter run -d linux"
echo ""
echo "Desktop macOS:"
echo "  $ flutter run -d macos"
echo ""
echo "Mobile Android:"
echo "  $ flutter run -d android"
echo ""
echo "Mobile iOS:"
echo "  $ flutter run -d ios"
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║  📖 Documentation                                            ║"
echo "╔═══════════════════════════════════════════════════════════════╗"
echo ""
echo "Voir OFFLINE_MODE.md pour la documentation complète"
echo "Voir README.md pour les informations générales"
echo ""

echo "✅ Script de test terminé!"
