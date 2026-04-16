-- SHRAPNEL NOTES — Schéma Supabase (corrigé)

create table if not exists ideas (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  done boolean default false,
  position integer default 0,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists fragments (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid references ideas(id) on delete cascade,
  text text default '',
  validated_at timestamptz,
  created_at timestamptz default now(),
  updated_at timestamptz default now()
);

create table if not exists fragment_links (
  id uuid primary key default gen_random_uuid(),
  from_idea_id uuid references ideas(id) on delete cascade,
  to_idea_id uuid references ideas(id) on delete cascade,
  created_at timestamptz default now(),
  unique(from_idea_id, to_idea_id)
);

create table if not exists biblio_refs (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid references ideas(id) on delete cascade,
  type text not null,
  emoji text default '📖',
  text text not null,
  created_at timestamptz default now()
);

create table if not exists activity (
  id uuid primary key default gen_random_uuid(),
  day date not null unique,
  count integer default 1,
  created_at timestamptz default now()
);

-- Migration : lier les idées à un projet
alter table ideas add column if not exists project_id uuid references projects(id) on delete set null;
create index if not exists idx_ideas_project_id on ideas(project_id);

create index if not exists idx_fragments_idea_id on fragments(idea_id);
create index if not exists idx_links_from on fragment_links(from_idea_id);
create index if not exists idx_links_to on fragment_links(to_idea_id);
create index if not exists idx_biblio_idea_id on biblio_refs(idea_id);
create index if not exists idx_activity_day on activity(day);

create or replace function update_updated_at()
returns trigger as $$
begin new.updated_at = now(); return new; end;
$$ language plpgsql;

create trigger ideas_updated_at before update on ideas
  for each row execute function update_updated_at();
create trigger fragments_updated_at before update on fragments
  for each row execute function update_updated_at();

alter table ideas enable row level security;
alter table fragments enable row level security;
alter table fragment_links enable row level security;
alter table biblio_refs enable row level security;
alter table activity enable row level security;

create policy "allow all ideas" on ideas for all using (true) with check (true);
create policy "allow all fragments" on fragments for all using (true) with check (true);
create policy "allow all links" on fragment_links for all using (true) with check (true);
create policy "allow all biblio_refs" on biblio_refs for all using (true) with check (true);
create policy "allow all activity" on activity for all using (true) with check (true);
