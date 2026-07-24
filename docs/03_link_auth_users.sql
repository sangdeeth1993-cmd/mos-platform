-- STEP 1: Create users in Supabase Authentication first.
-- STEP 2: Replace the three UUID placeholders below with Auth User UUIDs.

begin;

with c as (select id from public.companies where code='AF'),
     d as (select id from public.departments where code='PMO' and company_id=(select id from c))
insert into public.profiles(auth_id,company_id,department_id,employee_id,display_name,email,role)
select 'PUT_EMP001_AUTH_UUID_HERE'::uuid,c.id,d.id,'EMP001','สมชาย','emp001@mos.local','employee'::public.mos_role from c,d
on conflict(employee_id) do update set auth_id=excluded.auth_id,email=excluded.email;

with c as (select id from public.companies where code='AF'),
     d as (select id from public.departments where code='PMO' and company_id=(select id from c))
insert into public.profiles(auth_id,company_id,department_id,employee_id,display_name,email,role)
select 'PUT_MGR001_AUTH_UUID_HERE'::uuid,c.id,d.id,'MGR001','ผู้จัดการ','mgr001@mos.local','manager'::public.mos_role from c,d
on conflict(employee_id) do update set auth_id=excluded.auth_id,email=excluded.email;

with c as (select id from public.companies where code='AF'),
     d as (select id from public.departments where code='EXEC' and company_id=(select id from c))
insert into public.profiles(auth_id,company_id,department_id,employee_id,display_name,email,role)
select 'PUT_ADM001_AUTH_UUID_HERE'::uuid,c.id,d.id,'ADM001','ผู้ดูแลระบบ','adm001@mos.local','admin'::public.mos_role from c,d
on conflict(employee_id) do update set auth_id=excluded.auth_id,email=excluded.email;

-- Add all three users to sample projects.
insert into public.project_members(project_id,profile_id,project_role)
select p.id,u.id,
  case when u.role in ('manager','admin') then 'lead'::public.project_role else 'member'::public.project_role end
from public.projects p cross join public.profiles u
where p.code in ('KAPROW','SOLAR','WATER','CORP') and u.employee_id in ('EMP001','MGR001','ADM001')
on conflict(project_id,profile_id) do nothing;

commit;
