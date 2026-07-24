-- MOS Platform v1.0 — Sample master data
begin;

insert into public.companies(code,name)
values ('AF','Aqua Flow Group')
on conflict(code) do update set name=excluded.name;

insert into public.departments(company_id,code,name)
select c.id, x.code, x.name
from public.companies c
cross join (values
  ('EXEC','Executive'),
  ('PMO','Project Management'),
  ('FIN','Finance'),
  ('OPS','Operations')
) as x(code,name)
where c.code='AF'
on conflict(company_id,code) do update set name=excluded.name;

insert into public.projects(company_id,code,name,description)
select c.id, x.code, x.name, x.description
from public.companies c
cross join (values
  ('KAPROW','Kaprow','Kaprow & Co. business project'),
  ('SOLAR','Solar','Solar power development project'),
  ('WATER','Water Management','Raw water management and drought planning'),
  ('CORP','Corporate','Internal corporate work')
) as x(code,name,description)
where c.code='AF'
on conflict(company_id,code) do update set name=excluded.name, description=excluded.description;

insert into public.app_settings(company_id,setting_key,setting_value)
select id,'task_defaults','{"default_priority":"medium","default_status":"not_started"}'::jsonb
from public.companies where code='AF'
on conflict(company_id,setting_key) do nothing;

commit;
