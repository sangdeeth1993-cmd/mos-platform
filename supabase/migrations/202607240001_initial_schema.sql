-- MOS Platform v1.0 — Core Schema for Supabase
-- Run once in Supabase SQL Editor

begin;

create extension if not exists pgcrypto;

-- ENUMS
DO $$ BEGIN
  create type public.mos_role as enum ('employee','manager','executive','admin');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.project_role as enum ('member','lead','sponsor');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.task_status as enum ('not_started','in_progress','waiting','completed','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.task_priority as enum ('low','medium','high','critical');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.approval_status as enum ('not_required','pending','approved','rejected');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- MASTER TABLES
create table if not exists public.companies (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.departments (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  code text not null,
  name text not null,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, code)
);

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  auth_id uuid unique references auth.users(id) on delete cascade,
  company_id uuid not null references public.companies(id),
  department_id uuid references public.departments(id),
  employee_id text not null unique,
  display_name text not null,
  email text,
  role public.mos_role not null default 'employee',
  manager_id uuid references public.profiles(id),
  active boolean not null default true,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.projects (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  code text not null,
  name text not null,
  description text,
  owner_id uuid references public.profiles(id),
  start_date date,
  target_end_date date,
  active boolean not null default true,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(company_id, code)
);

create table if not exists public.project_members (
  project_id uuid not null references public.projects(id) on delete cascade,
  profile_id uuid not null references public.profiles(id) on delete cascade,
  project_role public.project_role not null default 'member',
  joined_at timestamptz not null default now(),
  primary key(project_id, profile_id)
);

-- TASK TABLES
create table if not exists public.tasks (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  project_id uuid not null references public.projects(id) on delete cascade,
  parent_task_id uuid references public.tasks(id) on delete set null,
  task_no bigint generated always as identity,
  title text not null,
  description text,
  owner_id uuid references public.profiles(id),
  assignee_id uuid not null references public.profiles(id),
  created_by uuid not null references public.profiles(id),
  due_date date,
  priority public.task_priority not null default 'medium',
  status public.task_status not null default 'not_started',
  progress smallint not null default 0 check(progress between 0 and 100),
  approval_status public.approval_status not null default 'not_required',
  approved_by uuid references public.profiles(id),
  approved_at timestamptz,
  latest_update text,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.task_comments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  author_id uuid not null references public.profiles(id),
  comment_text text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.task_updates (
  id bigint generated always as identity primary key,
  task_id uuid not null references public.tasks(id) on delete cascade,
  actor_id uuid not null references public.profiles(id),
  old_status public.task_status,
  new_status public.task_status,
  old_progress smallint,
  new_progress smallint,
  update_text text,
  created_at timestamptz not null default now()
);

create table if not exists public.task_attachments (
  id uuid primary key default gen_random_uuid(),
  task_id uuid not null references public.tasks(id) on delete cascade,
  uploaded_by uuid not null references public.profiles(id),
  bucket_name text not null default 'task-files',
  object_path text not null,
  original_name text not null,
  mime_type text,
  size_bytes bigint check(size_bytes is null or size_bytes >= 0),
  created_at timestamptz not null default now(),
  unique(bucket_name, object_path)
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles(id) on delete cascade,
  task_id uuid references public.tasks(id) on delete cascade,
  notification_type text not null,
  title text not null,
  body text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.activity_logs (
  id bigint generated always as identity primary key,
  company_id uuid references public.companies(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  entity_type text not null,
  entity_id uuid,
  action text not null,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create table if not exists public.app_settings (
  id uuid primary key default gen_random_uuid(),
  company_id uuid not null references public.companies(id) on delete cascade,
  setting_key text not null,
  setting_value jsonb not null default '{}'::jsonb,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now(),
  unique(company_id, setting_key)
);

-- INDEXES
create index if not exists idx_profiles_company on public.profiles(company_id);
create index if not exists idx_profiles_department on public.profiles(department_id);
create index if not exists idx_projects_company on public.projects(company_id);
create index if not exists idx_tasks_assignee_status on public.tasks(assignee_id, status);
create index if not exists idx_tasks_project_due on public.tasks(project_id, due_date);
create index if not exists idx_tasks_company_status on public.tasks(company_id, status);
create index if not exists idx_comments_task_created on public.task_comments(task_id, created_at);
create index if not exists idx_updates_task_created on public.task_updates(task_id, created_at);
create index if not exists idx_notifications_recipient_read on public.notifications(recipient_id, read_at);

-- GENERIC UPDATED_AT TRIGGER
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end; $$;

DO $$ BEGIN
  create trigger trg_companies_updated before update on public.companies for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create trigger trg_departments_updated before update on public.departments for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create trigger trg_profiles_updated before update on public.profiles for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create trigger trg_projects_updated before update on public.projects for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create trigger trg_tasks_updated before update on public.tasks for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create trigger trg_comments_updated before update on public.task_comments for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

-- SECURITY HELPER FUNCTIONS
create or replace function public.current_profile_id()
returns uuid language sql stable security definer set search_path=public as $$
  select id from public.profiles where auth_id=auth.uid() and active=true limit 1
$$;

create or replace function public.current_company_id()
returns uuid language sql stable security definer set search_path=public as $$
  select company_id from public.profiles where auth_id=auth.uid() and active=true limit 1
$$;

create or replace function public.current_role()
returns public.mos_role language sql stable security definer set search_path=public as $$
  select role from public.profiles where auth_id=auth.uid() and active=true limit 1
$$;

create or replace function public.is_project_member(p_project_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from public.project_members pm
    where pm.project_id=p_project_id and pm.profile_id=public.current_profile_id()
  )
$$;

create or replace function public.can_manage_project(p_project_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select public.current_role() in ('executive','admin')
     or exists(
       select 1 from public.project_members pm
       where pm.project_id=p_project_id
         and pm.profile_id=public.current_profile_id()
         and pm.project_role in ('lead','sponsor')
     )
$$;

-- RLS
alter table public.companies enable row level security;
alter table public.departments enable row level security;
alter table public.profiles enable row level security;
alter table public.projects enable row level security;
alter table public.project_members enable row level security;
alter table public.tasks enable row level security;
alter table public.task_comments enable row level security;
alter table public.task_updates enable row level security;
alter table public.task_attachments enable row level security;
alter table public.notifications enable row level security;
alter table public.activity_logs enable row level security;
alter table public.app_settings enable row level security;

-- Drop/recreate policies for repeatability
DO $$ DECLARE r record; BEGIN
  FOR r IN select schemaname, tablename, policyname from pg_policies where schemaname='public' and tablename in
  ('companies','departments','profiles','projects','project_members','tasks','task_comments','task_updates','task_attachments','notifications','activity_logs','app_settings')
  LOOP execute format('drop policy if exists %I on %I.%I', r.policyname, r.schemaname, r.tablename); END LOOP;
END $$;

create policy companies_select on public.companies for select to authenticated
using (id=public.current_company_id());

create policy departments_select on public.departments for select to authenticated
using (company_id=public.current_company_id());

create policy profiles_select on public.profiles for select to authenticated
using (company_id=public.current_company_id());
create policy profiles_update_self on public.profiles for update to authenticated
using (id=public.current_profile_id()) with check (id=public.current_profile_id());

create policy projects_select on public.projects for select to authenticated
using (company_id=public.current_company_id() and (public.current_role() in ('manager','executive','admin') or public.is_project_member(id)));
create policy projects_write on public.projects for all to authenticated
using (company_id=public.current_company_id() and public.current_role() in ('executive','admin'))
with check (company_id=public.current_company_id() and public.current_role() in ('executive','admin'));

create policy members_select on public.project_members for select to authenticated
using (exists(select 1 from public.projects p where p.id=project_id and p.company_id=public.current_company_id()));
create policy members_write on public.project_members for all to authenticated
using (public.can_manage_project(project_id)) with check (public.can_manage_project(project_id));

create policy tasks_select on public.tasks for select to authenticated
using (
  company_id=public.current_company_id() and
  (assignee_id=public.current_profile_id() or owner_id=public.current_profile_id() or public.can_manage_project(project_id))
);
create policy tasks_insert on public.tasks for insert to authenticated
with check (
  company_id=public.current_company_id() and created_by=public.current_profile_id() and
  (public.current_role() in ('manager','executive','admin') or public.can_manage_project(project_id))
);
create policy tasks_update on public.tasks for update to authenticated
using (
  company_id=public.current_company_id() and
  (assignee_id=public.current_profile_id() or owner_id=public.current_profile_id() or public.can_manage_project(project_id))
)
with check (company_id=public.current_company_id());

create policy comments_select on public.task_comments for select to authenticated
using (exists(select 1 from public.tasks t where t.id=task_id));
create policy comments_insert on public.task_comments for insert to authenticated
with check (author_id=public.current_profile_id() and exists(select 1 from public.tasks t where t.id=task_id));
create policy comments_update on public.task_comments for update to authenticated
using (author_id=public.current_profile_id()) with check (author_id=public.current_profile_id());

create policy updates_select on public.task_updates for select to authenticated
using (exists(select 1 from public.tasks t where t.id=task_id));
create policy updates_insert on public.task_updates for insert to authenticated
with check (actor_id=public.current_profile_id() and exists(select 1 from public.tasks t where t.id=task_id));

create policy attachments_select on public.task_attachments for select to authenticated
using (exists(select 1 from public.tasks t where t.id=task_id));
create policy attachments_insert on public.task_attachments for insert to authenticated
with check (uploaded_by=public.current_profile_id() and exists(select 1 from public.tasks t where t.id=task_id));

create policy notifications_select on public.notifications for select to authenticated
using (recipient_id=public.current_profile_id());
create policy notifications_update on public.notifications for update to authenticated
using (recipient_id=public.current_profile_id()) with check (recipient_id=public.current_profile_id());

create policy activity_select on public.activity_logs for select to authenticated
using (company_id=public.current_company_id() and public.current_role() in ('executive','admin'));

create policy settings_select on public.app_settings for select to authenticated
using (company_id=public.current_company_id());
create policy settings_write on public.app_settings for all to authenticated
using (company_id=public.current_company_id() and public.current_role()='admin')
with check (company_id=public.current_company_id() and public.current_role()='admin');

-- Useful view
create or replace view public.tasks_view as
select
  t.*,
  p.code as project_code,
  p.name as project_name,
  a.employee_id as assignee_employee_id,
  a.display_name as assignee_name,
  o.display_name as owner_name,
  c.name as company_name
from public.tasks t
join public.projects p on p.id=t.project_id
join public.companies c on c.id=t.company_id
join public.profiles a on a.id=t.assignee_id
left join public.profiles o on o.id=t.owner_id;

grant select on public.tasks_view to authenticated;

commit;
