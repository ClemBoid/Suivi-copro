-- ============================================================
--  SUIVI DES CHARGES DE COPROPRIÉTÉ — Schéma Supabase
--  À coller dans Supabase > SQL Editor > New query > Run
--  (réexécutable sans danger : "create ... if not exists")
--
--  ⚠️ Toutes les tables sont préfixées "copro_" : ce script peut
--  être exécuté dans un projet Supabase EXISTANT sans aucun risque
--  pour vos autres tables (aucune collision de noms).
-- ============================================================

-- ---------- 1. Copropriétés (vos lots) ----------
create table if not exists public.copro_coproprietes (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null default auth.uid() references auth.users(id) on delete cascade,
  nom          text not null,
  type         text not null check (type in ('appartement','parking','autre')),
  adresse      text,
  syndic_nom   text,
  syndic_email text,
  quote_part   numeric,
  couleur      text default '#2563eb',
  created_at   timestamptz not null default now()
);

-- ---------- 2. Appels de charges ----------
create table if not exists public.copro_appels (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null default auth.uid() references auth.users(id) on delete cascade,
  copro_id        uuid not null references public.copro_coproprietes(id) on delete cascade,
  periode_libelle text,
  annee           int,
  trimestre       int check (trimestre between 1 and 4),
  date_emission   date,
  date_exigibilite date,
  montant_total   numeric not null default 0,
  statut          text not null default 'en_attente'
                    check (statut in ('en_attente','partiel','paye')),
  pdf_path        text,
  notes           text,
  created_at      timestamptz not null default now()
);

-- ---------- 3. Détail par poste ----------
create table if not exists public.copro_postes (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  appel_id   uuid not null references public.copro_appels(id) on delete cascade,
  categorie  text not null default 'Autres',
  libelle    text,
  montant    numeric not null default 0,
  created_at timestamptz not null default now()
);

-- ---------- 4. Paiements ----------
create table if not exists public.copro_paiements (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null default auth.uid() references auth.users(id) on delete cascade,
  appel_id       uuid not null references public.copro_appels(id) on delete cascade,
  date_paiement  date not null default current_date,
  montant        numeric not null default 0,
  moyen          text,
  created_at     timestamptz not null default now()
);

-- ---------- Index ----------
create index if not exists idx_copro_appels_copro   on public.copro_appels(copro_id);
create index if not exists idx_copro_postes_appel    on public.copro_postes(appel_id);
create index if not exists idx_copro_paiements_appel on public.copro_paiements(appel_id);

-- ============================================================
--  SÉCURITÉ (RLS) : chaque utilisateur ne voit que SES données
-- ============================================================
alter table public.copro_coproprietes enable row level security;
alter table public.copro_appels        enable row level security;
alter table public.copro_postes        enable row level security;
alter table public.copro_paiements     enable row level security;

do $$
declare t text;
begin
  foreach t in array array['copro_coproprietes','copro_appels','copro_postes','copro_paiements'] loop
    execute format('drop policy if exists "owner_all" on public.%I;', t);
    execute format($f$
      create policy "owner_all" on public.%I
        for all
        using (user_id = auth.uid())
        with check (user_id = auth.uid());
    $f$, t);
  end loop;
end $$;

-- ============================================================
--  STOCKAGE DES PDF (bucket privé dédié "copro-appels-pdf")
-- ============================================================
insert into storage.buckets (id, name, public)
values ('copro-appels-pdf', 'copro-appels-pdf', false)
on conflict (id) do nothing;

drop policy if exists "copro_pdf_select" on storage.objects;
drop policy if exists "copro_pdf_insert" on storage.objects;
drop policy if exists "copro_pdf_delete" on storage.objects;

create policy "copro_pdf_select" on storage.objects
  for select using (bucket_id = 'copro-appels-pdf' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "copro_pdf_insert" on storage.objects
  for insert with check (bucket_id = 'copro-appels-pdf' and (storage.foldername(name))[1] = auth.uid()::text);
create policy "copro_pdf_delete" on storage.objects
  for delete using (bucket_id = 'copro-appels-pdf' and (storage.foldername(name))[1] = auth.uid()::text);

-- Fin du script.
