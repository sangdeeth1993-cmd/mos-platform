'use server'
import { revalidatePath } from 'next/cache'
import { createClient } from '@/lib/supabase/server'

export async function updateProfile(formData:FormData){
 const display_name=String(formData.get('display_name')||'').trim()
 if(!display_name) return
 const supabase=await createClient()
 const {data:{user}}=await supabase.auth.getUser()
 if(!user) return
 await supabase.from('profiles').update({display_name,last_seen_at:new Date().toISOString()}).eq('auth_id',user.id)
 revalidatePath('/profile');revalidatePath('/dashboard')
}
