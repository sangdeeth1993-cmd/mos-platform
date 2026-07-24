import { createClient } from '@/lib/supabase/server'

export default async function Dashboard(){
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 const {data:profile}=await supabase.from('profiles').select('id,display_name,employee_id,role,companies(name),departments(name)').eq('auth_id',user!.id).single()
 const {data,error}=await supabase.from('tasks').select('id,title,status,priority,progress,due_date,projects(name)').eq('assignee_id',profile?.id).order('due_date',{ascending:true})
 const tasks=data??[]
 const today=new Date();today.setHours(0,0,0,0)
 const open=tasks.filter(...)
 const overdue=open.filter((t:any)=>t.due_date&&new Date(t.due_date+'T00:00:00')<today)
 const completed=tasks.filter((t:any)=>t.status==='completed')
 return <main className="shell stack">
   <section className="card"><h1>สวัสดี {profile?.display_name}</h1><p className="muted">{(profile as any)?.companies?.name||'-'} · {(profile as any)?.departments?.name||'ยังไม่ระบุแผนก'}</p></section>
   <div className="grid"><div className="card kpi">งานเปิด<strong>{open.length}</strong></div><div className="card kpi">งานเกินกำหนด<strong>{overdue.length}</strong></div><div className="card kpi">เสร็จแล้ว<strong>{completed.length}</strong></div><div className="card kpi">งานทั้งหมด<strong>{tasks.length}</strong></div></div>
   <section className="card"><h2>งานของฉัน</h2>{tasks.length===0?<p className="muted">ยังไม่มีงานที่มอบหมาย</p>:tasks.map((t:any)=><article className="task" key={t.id}><strong>{t.title}</strong><div className="muted">{t.projects?.name||'-'} · กำหนด {t.due_date||'-'} · ความคืบหน้า {t.progress}%</div><span className="badge">{t.status}</span><span className="badge">{t.priority}</span></article>)}</section>
 </main>
}
