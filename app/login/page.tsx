'use client'
import { FormEvent, useState } from 'react'
import { createClient } from '@/lib/supabase/client'
export default function LoginPage(){
 const [error,setError]=useState('');const [loading,setLoading]=useState(false)
 async function login(e:FormEvent<HTMLFormElement>){e.preventDefault();setLoading(true);setError('');const f=new FormData(e.currentTarget);const employee=String(f.get('employee')).trim().toLowerCase();const password=String(f.get('password'));const email=employee.includes('@')?employee:`${employee}@mos.local`;const {error}=await createClient().auth.signInWithPassword({email,password});if(error){setError('เข้าสู่ระบบไม่สำเร็จ: '+error.message);setLoading(false);return}window.location.href='/dashboard'}
 return <main className="shell" style={{maxWidth:480,paddingTop:90}}><section className="card"><h1>MOS Platform</h1><p className="muted">Identity & Organization v1.1</p><form onSubmit={login}><label>รหัสพนักงาน</label><input className="input" name="employee" placeholder="เช่น EMP001" autoCapitalize="characters" required/><label>รหัสผ่าน</label><input className="input" name="password" type="password" required/><button className="btn" disabled={loading}>{loading?'กำลังเข้าสู่ระบบ...':'เข้าสู่ระบบ'}</button>{error&&<p className="error">{error}</p>}</form></section></main>
}
