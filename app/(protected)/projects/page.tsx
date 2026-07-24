import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'

const labels: Record<string,string> = {
  draft:'Draft', planning:'Planning', active:'Active', on_hold:'On hold', completed:'Completed', cancelled:'Cancelled', archived:'Archived'
}

export default async function ProjectsPage({searchParams}:{searchParams:Promise<{q?:string,status?:string}>}) {
  const params = await searchParams
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  const { data: profile } = await supabase.from('profiles').select('role').eq('auth_id',user!.id).single()
  let query = supabase.from('projects_view').select('*').order('updated_at',{ascending:false})
  if (params.status && params.status !== 'all') query = query.eq('status', params.status)
  if (params.q) query = query.or(`name.ilike.%${params.q}%,code.ilike.%${params.q}%`)
  const { data: projects = [], error } = await query
  const canCreate = ['manager','executive','admin'].includes(profile?.role || '')
  const active = projects.filter((p:any)=>p.status==='active').length
  const atRisk = projects.filter((p:any)=>p.health==='red').length
  const completed = projects.filter((p:any)=>p.status==='completed').length

  return <main className="shell stack">
    <section className="page-heading">
      <div><p className="eyebrow">WORK MANAGEMENT</p><h1>Projects</h1><p className="muted">ติดตามโครงการ เจ้าของโครงการ สมาชิก ความคืบหน้า และความเสี่ยง</p></div>
      {canCreate && <Link className="btn" href="/projects/new">+ New Project</Link>}
    </section>
    <div className="grid">
      <div className="card kpi">โครงการที่เห็นได้<strong>{projects.length}</strong></div>
      <div className="card kpi">กำลังดำเนินการ<strong>{active}</strong></div>
      <div className="card kpi">ความเสี่ยงสูง<strong>{atRisk}</strong></div>
      <div className="card kpi">เสร็จแล้ว<strong>{completed}</strong></div>
    </div>
    <section className="card">
      <form className="filter-bar">
        <input className="input compact" name="q" defaultValue={params.q||''} placeholder="ค้นหาชื่อหรือรหัสโครงการ" />
        <select className="select compact" name="status" defaultValue={params.status||'all'}>
          <option value="all">ทุกสถานะ</option><option value="planning">Planning</option><option value="active">Active</option><option value="on_hold">On hold</option><option value="completed">Completed</option><option value="archived">Archived</option>
        </select>
        <button className="btn secondary">ค้นหา</button>
      </form>
    </section>
    {error && <section className="card error">{error.message}</section>}
    <section className="project-grid">
      {projects.length===0 ? <div className="card empty"><h3>ยังไม่มีโครงการ</h3><p className="muted">สร้างโครงการแรก หรือเปลี่ยนเงื่อนไขการค้นหา</p></div> : projects.map((p:any)=><Link className="card project-card" href={`/projects/${p.id}`} key={p.id}>
        <div className="section-title"><span className="project-code">{p.code}</span><span className={`health health-${p.health}`}>{p.health}</span></div>
        <h2>{p.name}</h2><p className="muted clamp">{p.description||'ยังไม่มีคำอธิบายโครงการ'}</p>
        <div className="progress"><span style={{width:`${p.progress}%`}} /></div>
        <div className="project-meta"><strong>{p.progress}%</strong><span>{labels[p.status]||p.status}</span><span>{p.member_count} members</span></div>
        <div className="muted small">Owner: {p.owner_name||'-'} · Due: {p.target_end_date||'-'}</div>
      </Link>)}
    </section>
  </main>
}
