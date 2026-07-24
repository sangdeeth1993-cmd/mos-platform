-- MOS Platform v1.2 — Project Management Foundation
-- Run after 202607240001 and 202607240002
begin;

DO $$ BEGIN
  create type public.project_status as enum ('draft','planning','active','on_hold','completed','cancelled','archived');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.project_priority as enum ('low','medium','high','critical');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.project_health as enum ('green','yellow','red');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;
DO $$ BEGIN
  create type public.milestone_status as enum ('not_started','in_progress','completed','cancelled');
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

alter table public.projects
  add column if not exists status public.project_status not null default 'planning',
  add column if not exists priority public.project_priority not null default 'medium',
  add column if not exists health public.project_health not null default 'green',
  add column if not exists progress smallint not null default 0 check(progress between 0 and 100),
  add column if not exists sponsor_id uuid references public.profiles(id),
  add column if not exists budget numeric(15,2) check(budget is null or budget >= 0),
  add column if not exists archived_at timestamptz;

create table if not exists public.project_milestones (
  id uuid primary key default gen_random_uuid(),
  project_id uuid not null references public.projects(id) on delete cascade,
  title text not null,
  description text,
  due_date date,
  status public.milestone_status not null default 'not_started',
  sort_order integer not null default 0,
  created_by uuid not null references public.profiles(id),
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.project_activity (
  id bigint generated always as identity primary key,
  project_id uuid not null references public.projects(id) on delete cascade,
  actor_id uuid references public.profiles(id) on delete set null,
  action text not null,
  details jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_projects_company_status on public.projects(company_id,status);
create index if not exists idx_projects_owner on public.projects(owner_id);
create index if not exists idx_project_members_profile on public.project_members(profile_id);
create index if not exists idx_project_milestones_project_due on public.project_milestones(project_id,due_date);
create index if not exists idx_project_activity_project_created on public.project_activity(project_id,created_at desc);

DO $$ BEGIN
  create trigger trg_project_milestones_updated before update on public.project_milestones
  for each row execute function public.set_updated_at();
EXCEPTION WHEN duplicate_object THEN NULL; END $$;

create or replace function public.can_create_project()
returns boolean language sql stable security definer set search_path=public as $$
  select public.current_role() in ('manager','executive','admin')
$$;

create or replace function public.can_view_project(p_project_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from public.projects p
    where p.id=p_project_id and p.company_id=public.current_company_id()
      and (public.current_role() in ('manager','executive','admin')
        or exists(select 1 from public.project_members pm where pm.project_id=p.id and pm.profile_id=public.current_profile_id()))
  )
$$;

create or replace function public.can_initialize_project(p_project_id uuid)
returns boolean language sql stable security definer set search_path=public as $$
  select exists(
    select 1 from public.projects p
    where p.id=p_project_id and p.company_id=public.current_company_id()
      and p.created_by=public.current_profile_id()
      and public.can_create_project()
  )
$$;

create or replace function public.log_project_created()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  insert into public.project_activity(project_id,actor_id,action,details)
  values(new.id,new.created_by,'project_created',jsonb_build_object('code',new.code,'name',new.name));
  return new;
end; $$;

drop trigger if exists trg_log_project_created on public.projects;
create trigger trg_log_project_created after insert on public.projects
for each row execute function public.log_project_created();

create or replace function public.log_project_changes()
returns trigger language plpgsql security definer set search_path=public as $$
declare v_actor uuid;
begin
  v_actor := public.current_profile_id();
  if old.status is distinct from new.status then
    insert into public.project_activity(project_id,actor_id,action,details)
    values(new.id,v_actor,'status_changed',jsonb_build_object('from',old.status,'to',new.status));
  end if;
  if old.progress is distinct from new.progress then
    insert into public.project_activity(project_id,actor_id,action,details)
    values(new.id,v_actor,'progress_changed',jsonb_build_object('from',old.progress,'to',new.progress));
  end if;
  if old.health is distinct from new.health then
    insert into public.project_activity(project_id,actor_id,action,details)
    values(new.id,v_actor,'health_changed',jsonb_build_object('from',old.health,'to',new.health));
  end if;
  return new;
end; $$;

drop trigger if exists trg_log_project_changes on public.projects;
create trigger trg_log_project_changes after update on public.projects
for each row execute function public.log_project_changes();

create or replace function public.log_project_member_change()
returns trigger language plpgsql security definer set search_path=public as $$
begin
  if tg_op='INSERT' then
    insert into public.project_activity(project_id,actor_id,action,details)
    values(new.project_id,public.current_profile_id(),'member_added',jsonb_build_object('profile_id',new.profile_id,'project_role',new.project_role));
    return new;
  else
    insert into public.project_activity(project_id,actor_id,action,details)
    values(old.project_id,public.current_profile_id(),'member_removed',jsonb_build_object('profile_id',old.profile_id,'project_role',old.project_role));
    return old;
  end if;
end; $$;

drop trigger if exists trg_log_project_member_insert on public.project_members;
drop trigger if exists trg_log_project_member_delete on public.project_members;
create trigger trg_log_project_member_insert after insert on public.project_members
for each row execute function public.log_project_member_change();
create trigger trg_log_project_member_delete after delete on public.project_members
for each row execute function public.log_project_member_change();

alter table public.project_milestones enable row level security;
alter table public.project_activity enable row level security;

-- Replace project policies with manager-aware rules.
drop policy if exists projects_select on public.projects;
drop policy if exists projects_write on public.projects;
create policy projects_select on public.projects for select to authenticated
using (public.can_view_project(id));
create policy projects_insert on public.projects for insert to authenticated
with check (
  company_id=public.current_company_id() and
  created_by=public.current_profile_id() and public.can_create_project()
);
create policy projects_update on public.projects for update to authenticated
using (company_id=public.current_company_id() and public.can_manage_project(id))
with check (company_id=public.current_company_id());
create policy projects_delete on public.projects for delete to authenticated
using (company_id=public.current_company_id() and public.current_role()='admin');

-- Project members are visible only when the project itself is visible.
drop policy if exists members_select on public.project_members;
drop policy if exists members_write on public.project_members;
create policy members_select on public.project_members for select to authenticated
using (public.can_view_project(project_id));
create policy members_insert on public.project_members for insert to authenticated
with check (public.can_manage_project(project_id) or public.can_initialize_project(project_id));
create policy members_update on public.project_members for update to authenticated
using (public.can_manage_project(project_id)) with check (public.can_manage_project(project_id));
create policy members_delete on public.project_members for delete to authenticated
using (public.can_manage_project(project_id));

create policy milestones_select on public.project_milestones for select to authenticated
using (public.can_view_project(project_id));
create policy milestones_insert on public.project_milestones for insert to authenticated
with check (created_by=public.current_profile_id() and public.can_manage_project(project_id));
create policy milestones_update on public.project_milestones for update to authenticated
using (public.can_manage_project(project_id)) with check (public.can_manage_project(project_id));
create policy milestones_delete on public.project_milestones for delete to authenticated
using (public.can_manage_project(project_id));

create policy project_activity_select on public.project_activity for select to authenticated
using (public.can_view_project(project_id));

create or replace view public.projects_view with (security_invoker=true) as
select
  p.*,
  c.name as company_name,
  o.display_name as owner_name,
  s.display_name as sponsor_name,
  coalesce(m.member_count,0)::integer as member_count,
  coalesce(t.task_count,0)::integer as task_count,
  coalesce(t.completed_task_count,0)::integer as completed_task_count
from public.projects p
join public.companies c on c.id=p.company_id
left join public.profiles o on o.id=p.owner_id
left join public.profiles s on s.id=p.sponsor_id
left join (
  select project_id,count(*) as member_count from public.project_members group by project_id
) m on m.project_id=p.id
left join (
  select project_id,count(*) as task_count,count(*) filter(where status='completed') as completed_task_count
  from public.tasks group by project_id
) t on t.project_id=p.id;

grant select on public.projects_view to authenticated;

commit;
