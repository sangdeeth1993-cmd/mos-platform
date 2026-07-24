import { createClient } from '@/lib/supabase/server'
import { updateProfile } from './actions'
export default async function ProfilePage(){
 const supabase=await createClient();const {data:{user}}=await supabase.auth.getUser()
 const {data:p}=await supabase.from('profiles').select('employee_id,display_name,email,role,active,companies(name),departments(name)').eq('auth_id',user!.id).single()
 return <main className="shell" style={{maxWidth:760}}><section className="card"><h1>Profile</h1><form action={updateProfile}><label>ชื่อที่แสดง</label><input className="input" name="display_name" defaultValue={p?.display_name} required/><label>Employee ID</label><input className="input" value={p?.employee_id||''} disabled/><label>Email</label><input className="input" value={p?.email||user?.email||''} disabled/><label>Company / Department</label><input className="input" value={`${(p as any)?.companies?.name||'-'} / ${(p as any)?.departments?.name||'-'}`} disabled/><label>Role</label><input className="input" value={p?.role||''} disabled/><button className="btn">บันทึก</button></form></section></main>
}
