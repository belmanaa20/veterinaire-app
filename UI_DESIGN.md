# UI Design Reference

## Application Layout

```
┌────────────────────────────────────────────────────────────────────────────┐
│  Gestion Vétérinaire                                               [User]  │
├──────────────┬─────────────────────────────────────────────────────────────┤
│              │  Dashboard                               [Refresh] [Actions]│
│              ├─────────────────────────────────────────────────────────────┤
│  🐾         │                                                              │
│  Gestion    │  ┌────────────┐ ┌────────────┐ ┌────────────┐ ┌──────────┐│
│  Vétérinaire│  │ 👥 Clients │ │ 📦 Produit │ │ 🧾 Facture │ │ 💰 Revenu││
│              │  │    125     │ │    450     │ │    89      │ │  45,890  ││
│ 📊 Dashboard│  └────────────┘ └────────────┘ └────────────┘ └──────────┘│
│  (Active)   │                                                              │
│              │  ┌──────────────────────────────────────────────────────┐  │
│ 👥 Clients  │  │ ⚠️  Alertes Stock Faible (5)                        │  │
│              │  │ ─────────────────────────────────────────────────────│  │
│ 📦 Produits │  │ 📦 Vaccin Rabies - Stock: 2 unités (Min: 10)        │  │
│              │  │ 📦 Antiparasitaire - Stock: 5 unités (Min: 15)      │  │
│ 🧾 Factures │  └──────────────────────────────────────────────────────┘  │
│              │                                                              │
│ ⚙️  Paramèt.│  ┌──────────────────────────────────────────────────────┐  │
│              │  │ Factures Récentes                                    │  │
│              │  │ ─────────────────────────────────────────────────────│  │
│              │  │ 🧾 2024-0123 | Ahmed Ben Ali | 24/12/2024 | 1,250 DH│  │
│  v1.0.0     │  │ 🧾 2024-0122 | Sara Mansouri | 23/12/2024 | 850 DH  │  │
└──────────────┴─────────────────────────────────────────────────────────────┘
```

## Color Palette

### Primary Colors
- **Primary Green**: `#2E7D32` - Sidebar, buttons, active states
- **Secondary Blue**: `#1976D2` - Accent elements
- **Accent Orange**: `#F57C00` - Highlights, active border

### Status Colors
- **Success**: `#388E3C` - Completed, paid, success messages
- **Warning**: `#F9A825` - Low stock, pending items
- **Error**: `#D32F2F` - Errors, cancelled, critical alerts
- **Info**: `#0288D1` - Information, validated status

### Neutral Colors
- **Background**: `#FAFAFA` - Main background
- **Surface**: `#FFFFFF` - Cards, forms
- **Text Primary**: `#212121` - Main text
- **Text Secondary**: `#757575` - Subtitles, helpers
- **Divider**: `#E0E0E0` - Separators

## Screen Previews

### 1. Dashboard
```
┌─────────────────────────────────────────────────────────┐
│ Dashboard                                     [Refresh] │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ STATISTICS                                       │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ [👥 125 Clients] [📦 450 Products]              │  │
│  │ [🧾 89 Invoices] [💰 45,890 DH Revenue]         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ ⚠️ LOW STOCK ALERTS                              │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ • Vaccin Rabies - Stock: 2/10                   │  │
│  │ • Antiparasitaire - Stock: 5/15                 │  │
│  │ • Antibiotique X - Stock: 3/20                  │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ RECENT INVOICES                                  │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ 2024-0123 | Ahmed Ali | 24/12/2024 | 1,250 DH  │  │
│  │ 2024-0122 | Sara M.   | 23/12/2024 | 850 DH    │  │
│  │ 2024-0121 | Mohamed K.| 22/12/2024 | 2,100 DH  │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 2. Clients List
```
┌─────────────────────────────────────────────────────────┐
│ Gestion des Clients              [🔍 Search] [+ Client]│
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 👤 Ahmed Ben Ali                        [✏️] [🗑️]│  │
│  │    🐾 Rex (Chien - Berger Allemand)             │  │
│  │    📞 +212 6XX XXX XXX                          │  │
│  │    📧 ahmed@email.com                           │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ 👤 Sara Mansouri                        [✏️] [🗑️]│  │
│  │    🐾 Mimi (Chat - Persan)                      │  │
│  │    📞 +212 6YY YYY YYY                          │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ 👤 Mohamed Khalil                       [✏️] [🗑️]│  │
│  │    🐾 Coco (Oiseau)                             │  │
│  │    📞 +212 6ZZ ZZZ ZZZ                          │  │
│  └──────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────┘
```

### 3. Client Form Dialog
```
┌─────────────────────────────────────────────────┐
│ 👤 Nouveau Client                        [✕]   │
├─────────────────────────────────────────────────┤
│                                                  │
│  INFORMATIONS DU PROPRIÉTAIRE                   │
│  ┌──────────────────┐ ┌──────────────────┐     │
│  │ Nom *            │ │ Prénom           │     │
│  └──────────────────┘ └──────────────────┘     │
│  ┌──────────────────┐ ┌──────────────────┐     │
│  │ Téléphone        │ │ Email            │     │
│  └──────────────────┘ └──────────────────┘     │
│  ┌────────────────────────────────────────┐    │
│  │ Adresse                                │    │
│  └────────────────────────────────────────┘    │
│                                                  │
│  INFORMATIONS DE L'ANIMAL                       │
│  ┌──────────────────┐ ┌──────────────────┐     │
│  │ Nom Animal       │ │ Type [Dropdown]  │     │
│  └──────────────────┘ └──────────────────┘     │
│  ┌──────────────────┐ ┌──────────────────┐     │
│  │ Race             │ │ Date Naissance   │     │
│  └──────────────────┘ └──────────────────┘     │
│  ┌────────────────────────────────────────┐    │
│  │ Notes                                  │    │
│  └────────────────────────────────────────┘    │
│                                                  │
├─────────────────────────────────────────────────┤
│                         [Annuler] [Enregistrer] │
└─────────────────────────────────────────────────┘
```

### 4. Products List
```
┌─────────────────────────────────────────────────────────┐
│ Gestion des Produits             [🔍 Search] [+ Produit]│
├─────────────────────────────────────────────────────────┤
│                                                          │
│  ┌──────────────────────────────────────────────────┐  │
│  │ 🔴 Vaccin Rabies                        [✏️] [🗑️]│  │
│  │    Code: VAC001                                  │  │
│  │    Stock: 2 unités                               │  │
│  │    Prix: 150.00 DH              [Actif]         │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ 🟢 Consultation Générale                [✏️] [🗑️]│  │
│  │    Stock: 999 unités                             │  │
│  │    Prix: 200.00 DH              [Actif]         │  │
│  ├──────────────────────────────────────────────────┤  │
│  │ 🟠 Antiparasitaire                      [✏️] [🗑️]│  │
│  │    Code: MED042                                  │  │
│  │    Stock: 5 boîtes                               │  │
│  │    Prix: 85.00 DH               [Actif]         │  │
│  └──────────────────────────────────────────────────┘  │
│                                                          │
│  🔴 = Stock critique  🟠 = Stock faible  🟢 = Stock OK  │
└─────────────────────────────────────────────────────────┘
```

### 5. Invoice Form
```
┌──────────────────────────────────────────────────────┐
│ 🧾 Nouvelle Facture                           [✕]   │
├──────────────────────────────────────────────────────┤
│                                                       │
│  ┌─────────────────────────┐ ┌──────────────┐       │
│  │ Client: [Ahmed Ali ▼]   │ │ 24/12/2024   │       │
│  └─────────────────────────┘ └──────────────┘       │
│                                        [Créer]       │
│  ─────────────────────────────────────────────       │
│  AJOUTER UN PRODUIT                                  │
│  ┌─────────────┐ ┌──┐ ┌────┐ ┌────┐ [+]            │
│  │ Produit ▼  │ │1 │ │Prix│ │0.00│                 │
│  └─────────────┘ └──┘ └────┘ └────┘                 │
│                                                       │
│  LIGNES DE FACTURE                                   │
│  ┌────────────────────────────────────────────────┐ │
│  │ Consultation Générale                          │ │
│  │ Qté: 1 x 200.00 DH              200.00 DH [🗑️]│ │
│  │ Vaccin Rabies                                  │ │
│  │ Qté: 2 x 150.00 DH              300.00 DH [🗑️]│ │
│  ├────────────────────────────────────────────────┤ │
│  │ Total HT:                          500.00 DH   │ │
│  │ TVA (20%):                         100.00 DH   │ │
│  │ Total TTC:                         600.00 DH   │ │
│  └────────────────────────────────────────────────┘ │
│                                                       │
├──────────────────────────────────────────────────────┤
│                      [Fermer] [Valider la facture]  │
└──────────────────────────────────────────────────────┘
```

### 6. Status Badges

```
┌─────────────────────────┐
│ Invoice Status Badges   │
├─────────────────────────┤
│ ⚪ Brouillon  (Grey)    │
│ 🔵 Validée   (Blue)    │
│ 🟢 Payée     (Green)   │
│ 🔴 Annulée   (Red)     │
└─────────────────────────┘
```

## Typography Scale

- **H1** (Headers): 24px, Bold, Primary Text
- **H2** (Sub-headers): 20px, Bold, Primary Text
- **H3** (Section titles): 16px, Bold, Primary Text
- **Body**: 14px, Regular, Primary Text
- **Caption**: 12px, Light, Secondary Text
- **Button**: 14px, Medium, White on Primary

## Spacing System (8px Grid)

- **XS**: 8px - Tight spacing
- **SM**: 16px - Normal spacing
- **MD**: 24px - Comfortable spacing
- **LG**: 32px - Generous spacing
- **XL**: 40px - Extra spacing

## Component Specifications

### Cards
- Border Radius: 12px
- Elevation: 2 (default), 4 (hover)
- Padding: 24px
- Background: Surface White

### Buttons
- **Primary**: 48px height, Green bg, White text
- **Secondary**: 40px height, Green border, Green text
- **Text**: 40px height, Green text
- Border Radius: 8px

### Input Fields
- Height: 48px
- Border Radius: 8px
- Padding: 16px horizontal, 14px vertical
- Border: 1px solid Divider
- Focus Border: 2px solid Primary Green

### Sidebar
- Width: 240px
- Background: Green gradient
- Active Border: 4px left Orange
- Item Padding: 12px vertical, 16px horizontal

## Responsive Breakpoints

- Desktop: ≥ 1280px (primary target)
- Tablet: 768px - 1279px
- Mobile: < 768px

## Animations

- Hover transitions: 200ms ease-in-out
- Page transitions: 300ms ease
- Dialog open/close: 250ms ease-out
- Loading spinner: Infinite rotation

---

This design system ensures **consistency, professionalism, and usability** throughout the application.
