import Link from 'next/link'
import { createClient } from '@/lib/supabase/server'
import { createProject } from '../actions'

export default async function NewProjectPage({searchParams}:{searchParams:Promise<{error?:string}>}) {
  const params = await searchParams
  const supabase = await createClient()
  const { data, error } = await supabase
  .from('profiles')
  .select('id,display_name')
  .eq('active', true)

if (error) {
  console.error('Failed to load profiles:', error.message)
}

const profiles = data ?? []
  return <main className="shell narrow stack">
    <div><Link className="back-link" href="/projects">← Projects</Link><h1>สร้างโครงการใหม่</h1><p className="muted">กำหนดข้อมูลหลักก่อน แล้วจึงเพิ่มสมาชิกและ Milestone ในหน้ารายละเอียด</p></div>
    {params.error && <div className="notice error">ไม่สามารถสร้างโครงการได้: {decodeURIComponent(params.error)}</div>}
    <form action={createProject} className="card form-grid">
      <label>Project Code<input className="input" name="code" required placeholder="เช่น KAP001" /></label>
      <label>Project Name<input className="input" name="name" required placeholder="เช่น Kaprow Sukhumvit Launch" /></label>
      <label className="span-2">Description<textarea className="input textarea" name="description" rows={4} placeholder="วัตถุประสงค์และขอบเขตโดยย่อ" /></label>
      <label>Owner<select className="select" name="owner_id">{profiles.map((p:any)=><option key={p.id} value={p.id}>{p.display_name} ({p.employee_id})</option>)}</select></label>
      <label>Sponsor<select className="select" name="sponsor_id"><option value="">— ไม่ระบุ —</option>{profiles.map((p:any)=><option key={p.id} value={p.id}>{p.display_name} ({p.role})</option>)}</select></label>
      <label>Start Date<input className="input" type="date" name="start_date" /></label>
      <label>Target End Date<input className="input" type="date" name="target_end_date" /></label>
      <label>Priority<select className="select" name="priority"><option value="medium">Medium</option><option value="low">Low</option><option value="high">High</option><option value="critical">Critical</option></select></label>
      <label>Budget (THB)<input className="input" type="number" min="0" step="0.01" name="budget" placeholder="0.00" /></label>
      <div className="span-2 form-actions"><Link className="btn secondary" href="/projects">ยกเลิก</Link><button className="btn" type="submit">สร้างโครงการ</button></div>
    </form>
  </main>
}
