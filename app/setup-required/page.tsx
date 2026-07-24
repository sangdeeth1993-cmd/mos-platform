import LogoutButton from '@/components/logout-button'
export default function SetupRequired(){return <main className="shell" style={{maxWidth:650,paddingTop:80}}><section className="card"><h1>บัญชียังไม่เชื่อมกับ Profile</h1><p className="muted">กรุณาให้ผู้ดูแลระบบรัน Migration และตรวจสอบข้อมูลในตาราง profiles ก่อนเข้าใช้งาน</p><LogoutButton/></section></main>}
