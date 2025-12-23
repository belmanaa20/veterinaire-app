# ✅ Checklist de Test - Mode Offline

## Avant de commencer

- [ ] Flutter SDK installé (version 3.0.0+)
- [ ] Dépendances installées (`flutter pub get`)
- [ ] Configuration Supabase vérifiée
- [ ] Connexion internet disponible pour les tests

---

## 🧪 Tests Fonctionnels

### Test 1: Installation et Premier Lancement

**Objectif:** Vérifier que l'application démarre correctement avec Hive

- [ ] Lancer l'application
- [ ] Vérifier qu'aucune erreur d'initialisation Hive n'apparaît
- [ ] Vérifier que les 6 boxes Hive sont créées
- [ ] Vérifier que l'écran de splash s'affiche
- [ ] Vérifier la transition vers HomeScreen

**Logs attendus:**
```
✅ Hive initialized
✅ Boxes opened: clients, produits, factures, parametres, sync_queue, app_settings
✅ Supabase initialized
✅ Sync service started
```

---

### Test 2: Mode Online - Chargement Initial

**Objectif:** Vérifier le chargement des données depuis Supabase et leur mise en cache

**Étapes:**
1. [ ] Lancer l'app avec connexion internet
2. [ ] Naviguer vers **Clients**
3. [ ] Observer l'indicateur: devrait afficher **🟢 En ligne**
4. [ ] Attendre le chargement de la liste

**Résultat attendu:**
- [ ] Liste des clients chargée et affichée
- [ ] Log: `✅ Clients from Supabase + cached`
- [ ] Indicateur: 🟢 En ligne

**Répéter pour:**
- [ ] Produits
- [ ] Factures

---

### Test 3: Cache Hive - Lecture

**Objectif:** Vérifier que les données sont lues depuis le cache Hive

**Étapes:**
1. [ ] (Après Test 2) Fermer complètement l'application
2. [ ] Relancer l'application
3. [ ] Naviguer vers **Clients**

**Résultat attendu:**
- [ ] Liste des clients s'affiche **instantanément**
- [ ] Log: `💾 Clients from Hive cache (N items)`
- [ ] Puis (si online): `✅ Clients from Supabase + cached`

---

### Test 4: Mode Offline - Lecture Seule

**Objectif:** Vérifier que les données cachées sont accessibles hors ligne

**Étapes:**
1. [ ] Lancer l'app (Online)
2. [ ] Charger les données (Clients, Produits, Factures)
3. [ ] **Couper la connexion internet** (WiFi OFF / Mode avion)
4. [ ] Observer l'indicateur: devrait passer à **🟠 Hors ligne**
5. [ ] Naviguer entre Clients / Produits / Factures

**Résultat attendu:**
- [ ] Indicateur: 🟠 Hors ligne
- [ ] Log: `📴 Hors ligne`
- [ ] Toutes les données s'affichent correctement
- [ ] Log: `💾 [Entity] from Hive cache (N items)`

---

### Test 5: Mode Offline - Création

**Objectif:** Vérifier la création d'entités en mode offline

**Étapes:**
1. [ ] (Suite de Test 4 - Offline)
2. [ ] Naviguer vers **Clients**
3. [ ] Cliquer sur **+** (Ajouter)
4. [ ] Remplir le formulaire et sauvegarder
5. [ ] Observer l'indicateur

**Résultat attendu:**
- [ ] Client créé avec succès
- [ ] Log: `💾 Client sauvegardé offline (sera synchronisé)`
- [ ] Indicateur: 🟠 Hors ligne + **🔵 1 en attente**
- [ ] Le nouveau client apparaît dans la liste

**Répéter pour:**
- [ ] Créer un deuxième client (indicateur devrait montrer "2 en attente")
- [ ] Créer un produit

---

### Test 6: Mode Offline - Modification

**Objectif:** Vérifier la modification d'entités en mode offline

**Étapes:**
1. [ ] (Suite de Test 5 - Offline avec opérations en attente)
2. [ ] Sélectionner un client existant
3. [ ] Modifier le nom ou le téléphone
4. [ ] Sauvegarder

**Résultat attendu:**
- [ ] Modification sauvegardée
- [ ] Log: `💾 Client mis à jour offline (sera synchronisé)`
- [ ] Indicateur: compteur d'opérations en attente augmenté
- [ ] La modification apparaît dans la liste

---

### Test 7: Mode Offline - Suppression

**Objectif:** Vérifier la suppression d'entités en mode offline

**Étapes:**
1. [ ] (Suite de Test 6 - Offline)
2. [ ] Sélectionner un client
3. [ ] Supprimer le client
4. [ ] Confirmer la suppression

**Résultat attendu:**
- [ ] Client supprimé de la liste
- [ ] Log: `💾 Client marqué pour suppression (sera synchronisé)`
- [ ] Indicateur: compteur d'opérations en attente augmenté

---

### Test 8: Synchronisation Automatique

**Objectif:** Vérifier que la sync automatique fonctionne à la reconnexion

**Étapes:**
1. [ ] (Suite de Test 7 - Offline avec plusieurs opérations en attente)
2. [ ] Noter le nombre d'opérations en attente (ex: 4)
3. [ ] **Rétablir la connexion internet** (WiFi ON / Désactiver mode avion)
4. [ ] Attendre 5-10 secondes
5. [ ] Observer les logs et l'indicateur

**Résultat attendu:**
- [ ] Log: `🌐 Connexion restaurée - synchronisation...`
- [ ] Log: `🔄 Processing sync queue (N items)...`
- [ ] Log (pour chaque opération): `✅ Synced: insert/update/delete on [table]`
- [ ] Log: `✅ Sync queue vide!`
- [ ] Indicateur: 🟢 En ligne + **🔵 0 en attente**

**Vérifier dans Supabase:**
- [ ] Ouvrir Supabase Dashboard
- [ ] Vérifier que les nouveaux clients/produits sont présents
- [ ] Vérifier que les modifications sont appliquées
- [ ] Vérifier que les suppressions sont effectives

---

### Test 9: Synchronisation Manuelle

**Objectif:** Vérifier le bouton de synchronisation manuelle

**Étapes:**
1. [ ] Lancer l'app (Online)
2. [ ] Naviguer vers **Clients**
3. [ ] Cliquer sur le bouton **🔄 Refresh** dans l'AppBar
4. [ ] Observer le SnackBar et les logs

**Résultat attendu:**
- [ ] SnackBar: `✅ Synchronisé!`
- [ ] Log: `🔄 Synchronisation complète...`
- [ ] Log: `✅ Clients synchronized (N items)`
- [ ] Log: `✅ Produits synchronized (N items)`
- [ ] Log: `✅ Factures synchronized (N items)`
- [ ] Log: `✅ Synchronisation terminée!`

---

### Test 10: Persistance du Cache

**Objectif:** Vérifier que le cache persiste entre les sessions

**Étapes:**
1. [ ] Lancer l'app (Online)
2. [ ] Charger des données
3. [ ] **Fermer complètement l'application** (kill process)
4. [ ] Attendre 1 minute
5. [ ] **Couper internet**
6. [ ] Relancer l'app
7. [ ] Naviguer vers Clients/Produits

**Résultat attendu:**
- [ ] Données toujours disponibles
- [ ] Log: `💾 [Entity] from Hive cache (N items)`
- [ ] Aucune perte de données

---

### Test 11: Échec de Synchronisation

**Objectif:** Vérifier le comportement en cas d'échec de sync

**Étapes:**
1. [ ] Créer une opération offline (ex: client avec données invalides)
2. [ ] Reconnecter internet
3. [ ] Observer les logs

**Résultat attendu:**
- [ ] Log: `❌ Sync failed for item: [error]`
- [ ] L'opération reste dans la queue
- [ ] Après 5 tentatives: `⚠️ Item abandonné après 5 tentatives`

---

### Test 12: Multi-plateforme

**Objectif:** Vérifier que le mode offline fonctionne sur toutes les plateformes

**Tester sur:**
- [ ] **Windows** (`flutter run -d windows`)
- [ ] **Linux** (`flutter run -d linux`)
- [ ] **macOS** (`flutter run -d macos`)
- [ ] **Android** (`flutter run -d android`)
- [ ] **iOS** (`flutter run -d ios`)

**Pour chaque plateforme:**
- [ ] Vérifier que Hive s'initialise correctement
- [ ] Vérifier le chemin de stockage (logs)
- [ ] Tester le mode offline complet
- [ ] Vérifier la persistance du cache

---

## 🔍 Tests de Performance

### Test 13: Performance de Chargement

**Objectif:** Mesurer les temps de chargement

**Mesurer:**
- [ ] Temps de chargement depuis Hive (devrait être < 100ms)
- [ ] Temps de chargement depuis Supabase (varie selon connexion)
- [ ] Temps de synchronisation complète

**Outils:**
- Utiliser `Stopwatch` dans le code
- Observer les timestamps dans les logs

---

### Test 14: Taille du Cache

**Objectif:** Vérifier que la taille du cache reste raisonnable

**Étapes:**
1. [ ] Charger 100 clients
2. [ ] Charger 500 produits
3. [ ] Charger 50 factures
4. [ ] Vérifier la taille des fichiers Hive

**Résultat attendu:**
- [ ] Taille totale < 10 MB
- [ ] Pas de fuites mémoire

---

## 🐛 Tests de Robustesse

### Test 15: Connexion Instable

**Objectif:** Tester le comportement avec une connexion qui coupe fréquemment

**Étapes:**
1. [ ] Effectuer des opérations en alternant Online/Offline rapidement
2. [ ] Observer le comportement de l'indicateur
3. [ ] Vérifier qu'aucune opération n'est perdue

---

### Test 16: Corruption de Cache

**Objectif:** Vérifier le comportement si le cache Hive est corrompu

**Étapes:**
1. [ ] Fermer l'app
2. [ ] Supprimer manuellement un fichier `.hive`
3. [ ] Relancer l'app

**Résultat attendu:**
- [ ] L'app ne crash pas
- [ ] Le cache est recréé
- [ ] Les données sont rechargées depuis Supabase

---

## 📝 Rapport de Test

Après avoir complété tous les tests, remplir ce rapport:

**Date de test:** _______________

**Version de l'app:** _______________

**Flutter SDK:** _______________

**Plateformes testées:**
- [ ] Windows
- [ ] Linux
- [ ] macOS
- [ ] Android
- [ ] iOS

**Tests réussis:** _____ / 16

**Bugs trouvés:**
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

**Améliorations suggérées:**
1. _______________________________________________
2. _______________________________________________
3. _______________________________________________

**Commentaires:**
_______________________________________________
_______________________________________________
_______________________________________________

---

## 🎯 Critères de Validation

Pour que le mode offline soit considéré comme **validé**, tous les tests suivants doivent passer:

- [x] ✅ Tests 1-3: Installation et chargement basique
- [x] ✅ Tests 4-7: Mode offline complet (CRUD)
- [x] ✅ Tests 8-9: Synchronisation
- [x] ✅ Test 10: Persistance
- [x] ✅ Test 12: Multi-plateforme (au moins 2 plateformes)

**Signature du testeur:** _______________

**Date:** _______________
