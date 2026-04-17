-- =============================================
-- MIGRATION : Manuscrit — sections + positions
-- À exécuter dans Supabase → SQL Editor
-- =============================================

-- 1. Table sections
create table if not exists sections (
  id uuid primary key default gen_random_uuid(),
  project_id uuid references projects(id) on delete cascade,
  title text not null,
  position integer default 0,
  color text default '#4A7C59',
  user_id uuid,
  created_at timestamptz default now()
);

create index if not exists idx_sections_project_id on sections(project_id);
create index if not exists idx_sections_user_id on sections(user_id);
create index if not exists idx_sections_position on sections(project_id, position);

-- 2. Colonnes section_id et position dans fragments
alter table fragments
  add column if not exists section_id uuid references sections(id) on delete set null;

alter table fragments
  add column if not exists position integer default 0;

create index if not exists idx_fragments_section_id on fragments(section_id);
create index if not exists idx_fragments_section_position on fragments(section_id, position);

-- 3. RLS pour sections
alter table sections enable row level security;

create policy "allow all sections" on sections
  for all using (true) with check (true);
