# 🔌 Mode Offline - Guide d'utilisation

## 📦 Vue d'ensemble

L'application **Pharmacie Vétérinaire** dispose maintenant d'un **mode offline complet** grâce à **Hive** (cache local) et **connectivity_plus** (détection réseau).

### ✨ Fonctionnalités

- ✅ **Cache local automatique** avec Hive
- ✅ **Détection Online/Offline** en temps réel
- ✅ **Synchronisation intelligente** (manuelle + automatique)
- ✅ **Queue de synchronisation** pour opérations offline
- ✅ **Indicateur visuel** dans l'AppBar
- ✅ **Fonctionnement complet hors ligne** (lecture + écriture)

---

## 🏗️ Architecture

```
lib/
├── services/
│   ├── cache_service.dart           # Service Hive général
│   ├── connectivity_service.dart    # Détection Online/Offline
│   └── sync_service.dart           # Synchronisation Hive ↔ Supabase
│
├── widgets/
│   └── connection_status_widget.dart  # Indicateur 🟢/🟠 Online/Offline
│
└── models/
    └── sync_queue_item.dart         # Modèle pour queue de synchronisation
```

---

## 🔧 Services

### 1️⃣ CacheService

Service générique pour gérer le cache Hive.

**Boxes disponibles:**
- `clients` - Cache des clients
- `produits` - Cache des produits
- `factures` - Cache des factures
- `parametres` - Cache des paramètres
- `sync_queue` - Queue de synchronisation
- `app_settings` - Paramètres de l'application

**Méthodes principales:**
```dart
// Sauvegarder une liste
await CacheService.saveList('clients', 'all', data);

// Récupérer une liste
final list = CacheService.getList('clients', 'all');

// Ajouter un élément
await CacheService.addToList('clients', 'all', clientData);

// Mettre à jour un élément
await CacheService.updateInList('clients', 'all', id, updatedData);

// Supprimer un élément
await CacheService.deleteFromList('clients', 'all', id);

// Obtenir la dernière sync
final lastSync = CacheService.getLastSyncTime('clients', 'all');

// Nettoyer le cache
await CacheService.clearAll();
```

---

### 2️⃣ ConnectivityService

Détecte si l'appareil est en ligne (avec vérification réseau réelle).

**Méthodes:**
```dart
// Vérifier si en ligne (avec ping réel)
final isOnline = await ConnectivityService.isOnline();

// Écouter les changements de connexion
ConnectivityService.connectionStatusStream.listen((isOnline) {
  print(isOnline ? 'En ligne' : 'Hors ligne');
});

// Démarrer l'écoute
ConnectivityService.startListening();
```

---

### 3️⃣ SyncService

Gère la synchronisation entre Hive et Supabase.

**Queue de synchronisation:**
```dart
// Ajouter une opération à la queue
await SyncService.addToQueue('clients', 'insert', clientData);
await SyncService.addToQueue('produits', 'update', produitData);
await SyncService.addToQueue('clients', 'delete', {'id': 123});

// Obtenir le nombre d'opérations en attente
final pendingCount = SyncService.getPendingCount();
```

**Synchronisation:**
```dart
final syncService = SyncService();

// Synchroniser tout
await syncService.syncAll();

// Synchroniser uniquement les clients
await syncService.syncClients();

// Synchroniser uniquement les produits
await syncService.syncProduits();

// Synchroniser uniquement les factures (90 derniers jours)
await syncService.syncFactures();

// Traiter la queue (envoyer les opérations offline)
await syncService.processSyncQueue();
```

**Synchronisation automatique:**
```dart
// Écouter les changements de connexion
syncService.startListeningToConnectivity();

// Synchronisation périodique (toutes les 5 minutes)
syncService.startPeriodicSync(interval: Duration(minutes: 5));

// Arrêter la sync périodique
syncService.stopPeriodicSync();
```

---

## 🎨 Widget ConnectionStatusWidget

Affiche l'état de la connexion dans l'AppBar.

**Utilisation:**
```dart
AppBar(
  title: Text('Clients'),
  actions: [
    // Bouton refresh manuel
    IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () async {
        final syncService = SyncService();
        await syncService.syncAll();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('✅ Synchronisé!')),
        );
      },
    ),
    
    // Indicateur de connexion
    Padding(
      padding: EdgeInsets.only(right: 16, left: 8),
      child: ConnectionStatusWidget(),
    ),
  ],
)
```

**Affichage:**
- 🟢 **En ligne** (vert) → Connexion active
- 🟠 **Hors ligne** (orange) → Pas de connexion
- 🔵 **N en attente** (bleu) → Opérations en attente de sync

---

## 📱 Utilisation dans les Services

### ClientService

```dart
// Récupérer tous les clients (Hive d'abord, puis Supabase)
final clients = await clientService.getAllClients();

// Forcer le refresh depuis Supabase
final clients = await clientService.getAllClients(forceRefresh: true);

// Créer un client (Online/Offline)
final newClient = await clientService.createClient(client);
// → Online: enregistré dans Supabase + Hive
// → Offline: enregistré dans Hive + ajouté à la queue

// Mettre à jour un client
final updatedClient = await clientService.updateClient(id, client);
// → Online: mis à jour dans Supabase + Hive
// → Offline: mis à jour dans Hive + ajouté à la queue

// Supprimer un client
await clientService.deleteClient(id);
// → Online: supprimé de Supabase + Hive
// → Offline: supprimé de Hive + ajouté à la queue
```

### ProduitService

Même logique que `ClientService`:
```dart
final produits = await produitService.getAllProduits();
final newProduit = await produitService.createProduit(produit);
final updated = await produitService.updateProduit(id, produit);
await produitService.deleteProduit(id);
```

### FactureService

```dart
// Récupérer toutes les factures (Hive d'abord, puis Supabase)
final factures = await factureService.getFacturesComplet();

// Forcer le refresh
final factures = await factureService.getFacturesComplet(forceRefresh: true);
```

---

## 🚀 Initialisation

L'initialisation de Hive est gérée automatiquement dans `main.dart`:

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ✅ Initialiser Hive AVANT Supabase
  await Hive.initFlutter();
  
  // Ouvrir les boxes
  await Hive.openBox('clients');
  await Hive.openBox('produits');
  await Hive.openBox('factures');
  await Hive.openBox('parametres');
  await Hive.openBox('sync_queue');
  await Hive.openBox('app_settings');
  
  // Initialize Supabase
  await SupabaseService.initialize();
  
  // Démarrer le service de synchronisation
  final syncService = SyncService();
  syncService.startListeningToConnectivity();
  
  runApp(const VeterinaireApp());
}
```

---

## 📊 Comportement de la Synchronisation

### Priorité de chargement

1. **Hive** (instantané, toujours disponible)
2. **Supabase** (si Online, mise à jour du cache)
3. **Fallback Hive** (si erreur Supabase)

### Queue de synchronisation

- Les opérations offline sont ajoutées à la queue
- Tentatives automatiques lors de la reconnexion
- Maximum **5 tentatives** par opération
- Au-delà, l'opération est abandonnée (loggée)

### Synchronisation automatique

- ✅ À l'ouverture de l'application (si Online)
- ✅ Lors de la reconnexion (détection automatique)
- ✅ Manuellement via le bouton Refresh
- ❌ PAS de sync périodique en arrière-plan (économie batterie)

---

## 💾 Stockage Local

### Emplacements des fichiers Hive

- **Windows:** `C:\Users\[USER]\AppData\Roaming\[APP]\hive\`
- **Linux:** `~/.local/share/[APP]/hive/`
- **macOS:** `~/Library/Application Support/[APP]/hive/`
- **Android:** `/data/data/com.example.veterinaire_app/app_flutter/hive/`
- **iOS:** `/var/mobile/Containers/Data/Application/[ID]/Documents/hive/`

### Taille estimée du cache

- **Clients:** ~500 KB pour 1000 clients
- **Produits:** ~2 MB pour 5000 produits
- **Factures:** ~5 MB pour 10000 factures (90 derniers jours)
- **Total:** < 10 MB (négligeable)

---

## 🧪 Tests

### Scénario 1: Usage normal (Online)
1. Lancer l'app (Online)
2. Charger des données → Supabase + Hive
3. Fermer l'app
4. Rouvrir → données chargées depuis Hive instantanément
5. Synchronisation en arrière-plan si nouvelle data

### Scénario 2: Mode Offline
1. Lancer l'app (Online)
2. Charger des données
3. **Couper le WiFi/Données**
4. Ajouter un client → sauvegardé dans Hive + Queue
5. Indicateur "🟠 Hors ligne" + "1 en attente"
6. **Reconnecter WiFi**
7. Synchronisation automatique ✅
8. Indicateur "🟢 En ligne" + "0 en attente"

### Scénario 3: Démarrage Offline
1. **Couper le WiFi**
2. Lancer l'app
3. Données précédemment cachées sont disponibles
4. Possibilité d'ajouter/modifier/supprimer
5. Toutes les opérations en queue
6. Reconnecter → synchronisation

---

## 📝 Notes importantes

1. **Les factures sont limitées aux 90 derniers jours** pour limiter la taille du cache
2. **Les opérations RPC (créer facture, ajouter ligne, etc.) ne fonctionnent QUE en Online**
3. **La queue de synchronisation n'est jamais vidée** lors du nettoyage du cache
4. **Les champs `_pending` et `_temp_id`** sont ajoutés aux données offline et supprimés lors de la sync
5. **Le ping Google DNS** est utilisé pour vérifier la connexion réelle (pas juste WiFi connecté)

---

## 🔒 Sécurité

- ❌ **Aucune encryption** n'est activée par défaut
- ⚠️ Les données sensibles sont stockées en clair dans Hive
- ✅ Pour activer l'encryption: utiliser `hive_flutter` avec `HiveAesCipher`

---

## 🐛 Dépannage

### Le cache ne se met pas à jour
→ Utiliser `forceRefresh: true` ou le bouton Refresh

### Les opérations offline ne se synchronisent pas
→ Vérifier la queue: `SyncService.getPendingCount()`
→ Vérifier les logs: "🔄 Processing sync queue..."

### L'indicateur reste "Hors ligne" alors que je suis connecté
→ Vérifier que Google DNS (google.com) est accessible
→ Certains réseaux bloquent le ping

### L'app est lente au démarrage
→ Normal si beaucoup de données en cache
→ Hive charge les boxes au démarrage

---

## 📚 Ressources

- [Hive Documentation](https://docs.hivedb.dev/)
- [connectivity_plus Documentation](https://pub.dev/packages/connectivity_plus)
- [Flutter Offline-First Guide](https://flutter.dev/docs/cookbook/persistence)

---

**Mode Offline activé! 🚀**
