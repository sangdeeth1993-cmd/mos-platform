'use server'
import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'

export async function createDepartment(formData:FormData){
 const code=String(formData.get('code')||'').trim().toUpperCase()
 const name=String(formData.get('name')||'').trim()
 if(!code||!name) return
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 if(!user) return
 const {data:profile}=await supabase.from('profiles').select('company_id,role').eq('auth_id',user.id).single()
 if(!profile||profile.role!=='admin') return
 await supabase.from('departments').insert({company_id:profile.company_id,code,name})
 revalidatePath('/organization')
}
