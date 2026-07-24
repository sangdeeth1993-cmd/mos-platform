import Link from 'next/link'
import { notFound } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import { addProjectMember, createMilestone, removeProjectMember, updateMilestoneStatus, updateProject } from '../actions'

const activityLabel:Record<string,string>={project_created:'สร้างโครงการ',status_changed:'เปลี่ยนสถานะ',progress_changed:'อัปเดตความคืบหน้า',health_changed:'เปลี่ยนระดับความเสี่ยง',member_added:'เพิ่มสมาชิก',member_removed:'นำสมาชิกออก'}

export default async function ProjectDetailPage({params}:{params:Promise<{id:string}>}) {
  const { id } = await params
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  const { data: me } = await supabase.from('profiles').select('id,role').eq('auth_id',user!.id).single()
  const { data: project } = await supabase.from('projects_view').select('*').eq('id',id).single()
  if (!project) notFound()
  const [{ data: members=[] },{ data: people=[] },{ data: milestones=[] },{ data: activity=[] }] = await Promise.all([
    supabase.from('project_members').select('profile_id,project_role,profiles(display_name,employee_id,role)').eq('project_id',id).order('joined_at'),
    supabase.from('profiles').select('id,display_name,employee_id,role').eq('active',true).order('display_name'),
    supabase.from('project_milestones').select('*').eq('project_id',id).order('sort_order').order('due_date'),
    supabase.from('project_activity').select('id,action,details,created_at,profiles:actor_id(display_name)').eq('project_id',id).order('created_at',{ascending:false}).limit(20),
  ])
  const canManage = ['executive','admin'].includes(me?.role||'') || members.some((m:any)=>m.profile_id===me?.id&&['lead','sponsor'].includes(m.project_role))
  const money = project.budget==null?'-':new Intl.NumberFormat('th-TH',{style:'currency',currency:'THB',maximumFractionDigits:0}).format(project.budget)

  return <main className="shell stack">
    <div><Link className="back-link" href="/projects">← Projects</Link></div>
    <section className="card project-hero">
      <div><div className="section-title start"><span className="project-code">{project.code}</span><span className={`health health-${project.health}`}>{project.health}</span><span className="badge">{project.status}</span></div><h1>{project.name}</h1><p className="muted">{project.description||'ยังไม่มีคำอธิบาย'}</p></div>
      <div className="progress-ring"><strong>{project.progress}%</strong><span>progress</span></div>
    </section>
    <div className="grid"><div className="card"><span className="muted small">Owner</span><h3>{project.owner_name||'-'}</h3></div><div className="card"><span className="muted small">Sponsor</span><h3>{project.sponsor_name||'-'}</h3></div><div className="card"><span className="muted small">Timeline</span><h3>{project.start_date||'-'} → {project.target_end_date||'-'}</h3></div><div className="card"><span className="muted small">Budget</span><h3>{money}</h3></div></div>
    {canManage && <details className="card"><summary><strong>แก้ไขข้อมูลโครงการ</strong></summary><form action={updateProject} className="form-grid details-form">
      <input type="hidden" name="project_id" value={id}/><label>Name<input className="input" name="name" defaultValue={project.name}/></label><label>Progress<input className="input" name="progress" type="number" min="0" max="100" defaultValue={project.progress}/></label>
      <label className="span-2">Description<textarea className="input textarea" name="description" rows={3} defaultValue={project.description||''}/></label>
      <label>Status<select className="select" name="status" defaultValue={project.status}><option value="draft">Draft</option><option value="planning">Planning</option><option value="active">Active</option><option value="on_hold">On hold</option><option value="completed">Completed</option><option value="cancelled">Cancelled</option><option value="archived">Archived</option></select></label>
      <label>Health<select className="select" name="health" defaultValue={project.health}><option value="green">Green</option><option value="yellow">Yellow</option><option value="red">Red</option></select></label>
      <label>Priority<select className="select" name="priority" defaultValue={project.priority}><option value="low">Low</option><option value="medium">Medium</option><option value="high">High</option><option value="critical">Critical</option></select></label>
      <label>Budget<input className="input" name="budget" type="number" min="0" step="0.01" defaultValue={project.budget||''}/></label>
      <label>Owner<select className="select" name="owner_id" defaultValue={project.owner_id||''}>{people.map((p:any)=><option key={p.id} value={p.id}>{p.display_name}</option>)}</select></label>
      <label>Sponsor<select className="select" name="sponsor_id" defaultValue={project.sponsor_id||''}><option value="">— ไม่ระบุ —</option>{people.map((p:any)=><option key={p.id} value={p.id}>{p.display_name}</option>)}</select></label>
      <label>Start<input className="input" name="start_date" type="date" defaultValue={project.start_date||''}/></label><label>Target End<input className="input" name="target_end_date" type="date" defaultValue={project.target_end_date||''}/></label>
      <div className="span-2"><button className="btn">บันทึกการเปลี่ยนแปลง</button></div>
    </form></details>}
    <div className="two-col">
      <section className="card stack"><div className="section-title"><div><h2>Members</h2><p className="muted small">{members.length} คน</p></div></div>
        {members.map((m:any)=><div className="member-row" key={m.profile_id}><div><strong>{m.profiles?.display_name}</strong><div className="muted small">{m.profiles?.employee_id} · {m.project_role}</div></div>{canManage&&<form action={removeProjectMember}><input type="hidden" name="project_id" value={id}/><input type="hidden" name="profile_id" value={m.profile_id}/><button className="link-danger">Remove</button></form>}</div>)}
        {canManage&&<form action={addProjectMember} className="inline-form"><input type="hidden" name="project_id" value={id}/><select className="select compact" name="profile_id">{people.filter((p:any)=>!members.some((m:any)=>m.profile_id===p.id)).map((p:any)=><option key={p.id} value={p.id}>{p.display_name}</option>)}</select><select className="select compact" name="project_role"><option value="member">Member</option><option value="lead">Lead</option><option value="sponsor">Sponsor</option></select><button className="btn secondary">เพิ่ม</button></form>}
      </section>
      <section className="card stack"><div><h2>Milestones</h2><p className="muted small">จุดส่งมอบสำคัญของโครงการ</p></div>
        {milestones.length===0&&<p className="muted">ยังไม่มี Milestone</p>}{milestones.map((m:any)=><div className="milestone" key={m.id}><div><strong>{m.title}</strong><div className="muted small">Due {m.due_date||'-'} · {m.status}</div></div>{canManage&&<form action={updateMilestoneStatus}><input type="hidden" name="project_id" value={id}/><input type="hidden" name="milestone_id" value={m.id}/><select className="select compact" name="status" defaultValue={m.status}><option value="not_started">Not started</option><option value="in_progress">In progress</option><option value="completed">Completed</option><option value="cancelled">Cancelled</option></select><button className="btn secondary">Save</button></form>}</div>)}
        {canManage&&<form action={createMilestone} className="milestone-form"><input type="hidden" name="project_id" value={id}/><input className="input" name="title" required placeholder="ชื่อ Milestone"/><input className="input" name="due_date" type="date"/><textarea className="input textarea" name="description" rows={2} placeholder="รายละเอียด (ถ้ามี)"/><button className="btn secondary">+ เพิ่ม Milestone</button></form>}
      </section>
    </div>
    <section className="card"><h2>Activity</h2>{activity.length===0?<p className="muted">ยังไม่มีกิจกรรม</p>:activity.map((a:any)=><div className="activity-row" key={a.id}><div className="activity-dot"/><div><strong>{activityLabel[a.action]||a.action}</strong><div className="muted small">{a.profiles?.display_name||'System'} · {new Date(a.created_at).toLocaleString('th-TH')}</div></div></div>)}</section>
  </main>
}
