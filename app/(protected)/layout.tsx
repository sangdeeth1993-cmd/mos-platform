import Link from 'next/link'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'
import LogoutButton from '@/components/logout-button'

export default async function ProtectedLayout({children}:{children:React.ReactNode}){
  const supabase=await createClient()
  const {data:{user}}=await supabase.auth.getUser()
  if(!user) redirect('/login')
  const {data:profile}=await supabase.from('profiles').select('display_name,employee_id,role').eq('auth_id',user.id).single()
  if(!profile) redirect('/setup-required')
  return <>
    <header className="top"><div className="shell">
      <div><div className="brand">MOS Platform</div><div style={{fontSize:13,opacity:.85}}>{profile.display_name} · {profile.employee_id} · {profile.role}</div></div>
      <nav className="nav"><Link href="/dashboard">Home</Link><Link href="/organization">Organization</Link><Link href="/profile">Profile</Link></nav>
      <div className="header-actions"><LogoutButton/></div>
    </div></header>
    {children}
  </>
}
