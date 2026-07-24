import { createClient } from '@/lib/supabase/server'
import { createDepartment } from './actions'

export default async function OrganizationPage(){
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 const {data:me}=await supabase.from('profiles').select('company_id,role,companies(name,code)').eq('auth_id',user!.id).single()
 const {data:departmentsData,error:departmentsError}=await supabase.from('departments').select('*').order('code')

if (departmentsError) {
  console.error(
    'Failed to load departments:',
    departmentsError.message
  )
}

const departments = departmentsData ?? []
 const {data:people=[]}=await supabase.from('profiles').select('id,employee_id,display_name,email,role,active,departments(name)').order('employee_id')
 const canAdmin=me?.role==='admin'
 return <main className="shell stack">
  <section className="card"><h1>Organization</h1><p className="muted">{(me as any)?.companies?.name} ({(me as any)?.companies?.code})</p></section>
  <div className="two-col">
   <section className="card"><div className="section-title"><h2>Departments</h2><span className="badge">{departments.length}</span></div>
    {departments.map((d:any)=><div className="task" key={d.id}><strong>{d.code}</strong> — {d.name}<div className="muted">{d.active?'Active':'Inactive'}</div></div>)}
   </section>
   <section className="card"><h2>เพิ่มแผนก</h2>{canAdmin?<form action={createDepartment}><label>รหัสแผนก</label><input className="input" name="code" placeholder="เช่น HR" required/><label>ชื่อแผนก</label><input className="input" name="name" placeholder="Human Resources" required/><button className="btn">เพิ่มแผนก</button></form>:<p className="notice">เฉพาะ Admin เท่านั้นที่เพิ่มแผนกได้</p>}</section>
  </div>
  <section className="card"><div className="section-title"><h2>Employees</h2><span className="badge">{people.length}</span></div><div className="table-wrap"><table className="table"><thead><tr><th>Employee ID</th><th>Name</th><th>Department</th><th>Role</th><th>Status</th></tr></thead><tbody>{people.map((p:any)=><tr key={p.id}><td>{p.employee_id}</td><td><strong>{p.display_name}</strong><div className="muted">{p.email||'-'}</div></td><td>{p.departments?.name||'-'}</td><td><span className={`badge role-${p.role}`}>{p.role}</span></td><td>{p.active?'Active':'Inactive'}</td></tr>)}</tbody></table></div></section>
 </main>
}
