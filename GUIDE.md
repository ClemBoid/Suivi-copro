# Suivi copro — Guide d'installation

Application web pour répertorier vos charges de copropriété (Appartement + Parking),
avec import des appels de charges en PDF. Données hébergées sur **Supabase** → accessibles
depuis n'importe quel appareil.

---

## 1. Préparer Supabase (à faire une seule fois)

1. Connectez-vous sur https://supabase.com et ouvrez votre projet.
2. Menu de gauche → **SQL Editor** → **New query**.
3. Ouvrez le fichier `supabase_schema.sql` (dans ce dossier), copiez **tout** son contenu,
   collez-le dans l'éditeur, puis cliquez **Run**.
   → Cela crée les tables (copropriétés, appels, postes, paiements), la sécurité, et
   l'espace de stockage des PDF.
4. (Recommandé pour démarrer vite) Désactiver la confirmation par email :
   **Authentication → Sign In / Providers → Email** → décochez *Confirm email* → **Save**.
   Vous pourrez ainsi créer votre compte et vous connecter immédiatement.

### Récupérer vos clés
Menu **Project Settings → API** :
- **Project URL** → c'est l'« URL du projet » (ex. `https://abcd.supabase.co`)
- **Project API keys → `anon` `public`** → c'est la « clé anon »

---

## 2. Lancer l'application

Ouvrez le fichier **`suivi-copro.html`** dans votre navigateur (double-clic).

1. **Premier écran** : collez l'URL du projet + la clé anon → *Enregistrer*.
2. **Connexion** : cliquez *Créer mon compte* (email + mot de passe de votre choix).
3. L'application crée automatiquement vos **2 copropriétés** : *Appartement* et *Parking*.
   (Vous pouvez les renommer, changer la couleur, ajouter l'adresse/le syndic dans l'onglet
   « Mes copropriétés ».)

---

## 2 bis. Votre historique est déjà prêt

Au premier lancement, après connexion, l'app crée vos 2 copropriétés puis affiche un bouton
**« Importer mon historique »** sur le tableau de bord. Un clic enregistre les **10 appels**
relevés depuis vos PDF :

- **Appartement (AURELIA 1)** — 9 appels, total **7 381,73 €**
  - Sergic : 1er trim. 2025 (953,73 €), travaux mars 2025 (104,16 €), 2e trim. 2025 (849,57 €),
    régularisation 2024 (1 003,14 €)
  - Vacherand : 3e trim. 2025 (1 117,35 €), 4e trim. 2025 (944,01 €), 1er trim. 2026 (944,01 €),
    2e trim. 2026 (944,01 €), régularisation 2025 (521,75 €)
- **Parking (PARKINGS P6 — Sergic)** — 1 appel : 2e trim. 2026 (46,57 €)

> Le montant retenu pour chaque appel est la **charge de la période** (hors « solde antérieur »),
> pour ne pas compter deux fois les reports d'un trimestre sur l'autre. Tous sont marqués **payés**
> (un justificatif de paiement existait pour chacun) ; la date de paiement est approximée à la date
> d'exigibilité — ajustez-la si besoin en ouvrant l'appel.

**Joindre les PDF d'origine** : l'import ne peut pas téléverser les fichiers à votre place
(ils sont sur votre OneDrive). Le chemin du PDF est indiqué dans les **notes** de chaque appel.
Pour attacher un PDF : ouvrez l'appel → (fonction d'ajout de PDF) — ou redéposez-le via un nouvel
appel. Dites-moi si vous voulez que j'ajoute un bouton « joindre un PDF » directement sur un appel existant.

---

## 3. Utilisation au quotidien

- **Onglet « Appels de charges » → + Nouvel appel** :
  - Glissez le **PDF du syndic** dans la zone d'import : l'app lit le document et **pré-remplit**
    le montant, la période et la date d'exigibilité. Vérifiez, complétez le détail par poste,
    puis *Enregistrer*. Le PDF d'origine reste **joint** à l'appel.
  - Ou saisissez tout à la main si vous n'avez pas de PDF.
- **Suivi des paiements** : ouvrez un appel → section *Paiements* → ajoutez un règlement.
  Le statut (En attente / Partiel / Payé) et le solde se mettent à jour automatiquement.
- **Tableau de bord** : totaux appelés / payés / restant dû, et progression par copropriété.

> ⚠️ **Import PDF** : la lecture automatique est générique pour l'instant. Dès que vous me
> fournissez un vrai PDF de votre syndic (déposez-le dans ce dossier), je calibre l'extraction
> précisément sur sa mise en page pour fiabiliser le pré-remplissage.

---

## 4. Y accéder « partout » (optionnel)

Le fichier HTML fonctionne déjà sur votre Mac. Pour y accéder depuis votre téléphone ou
ailleurs, on peut le **mettre en ligne gratuitement** (Netlify ou Vercel) : il suffit de
déposer ce fichier, vous obtenez une adresse privée. Dites-le-moi et je vous guide.

---

## Fichiers du projet
- `suivi-copro.html` — l'application
- `supabase_schema.sql` — à exécuter une fois dans Supabase
- `GUIDE.md` — ce guide
