-- MOS Platform v1.1 — Identity & Organization
begin;

create or replace function public.handle_new_auth_user()
returns trigger
language plpgsql
security definer
set search_path=public
as $$
declare
  v_company uuid;
  v_department uuid;
  v_employee_id text;
  v_name text;
  v_role public.mos_role;
begin
  select id into v_company from public.companies where code=coalesce(new.raw_user_meta_data->>'company_code','AF') limit 1;
  if v_company is null then select id into v_company from public.companies order by created_at limit 1; end if;
  select id into v_department from public.departments where company_id=v_company and code=coalesce(new.raw_user_meta_data->>'department_code','PMO') limit 1;
  if v_department is null then select id into v_department from public.departments where company_id=v_company order by created_at limit 1; end if;
  v_employee_id := upper(coalesce(nullif(new.raw_user_meta_data->>'employee_id',''), split_part(new.email,'@',1)));
  v_name := coalesce(nullif(new.raw_user_meta_data->>'display_name',''), v_employee_id);
  begin v_role := coalesce(nullif(new.raw_user_meta_data->>'role',''),'employee')::public.mos_role;
  exception when others then v_role := 'employee'; end;
  insert into public.profiles(auth_id,company_id,department_id,employee_id,display_name,email,role)
  values(new.id,v_company,v_department,v_employee_id,v_name,new.email,v_role)
  on conflict(employee_id) do update set auth_id=excluded.auth_id,email=excluded.email,updated_at=now();
  return new;
end;$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users for each row execute function public.handle_new_auth_user();

drop policy if exists companies_admin_update on public.companies;
create policy companies_admin_update on public.companies for update to authenticated
using(id=public.current_company_id() and public.current_role()='admin')
with check(id=public.current_company_id() and public.current_role()='admin');

drop policy if exists departments_admin_write on public.departments;
create policy departments_admin_write on public.departments for all to authenticated
using(company_id=public.current_company_id() and public.current_role()='admin')
with check(company_id=public.current_company_id() and public.current_role()='admin');

drop policy if exists profiles_admin_update on public.profiles;
create policy profiles_admin_update on public.profiles for update to authenticated
using(company_id=public.current_company_id() and public.current_role()='admin')
with check(company_id=public.current_company_id() and public.current_role()='admin');

create or replace function public.protect_profile_security_fields()
returns trigger language plpgsql as $$
begin
  if public.current_role()<>'admin' and old.auth_id=auth.uid() then
    new.auth_id:=old.auth_id;new.company_id:=old.company_id;new.department_id:=old.department_id;
    new.employee_id:=old.employee_id;new.role:=old.role;new.manager_id:=old.manager_id;new.active:=old.active;
  end if;
  return new;
end;$$;

drop trigger if exists trg_protect_profile_security_fields on public.profiles;
create trigger trg_protect_profile_security_fields before update on public.profiles for each row execute function public.protect_profile_security_fields();

commit;
