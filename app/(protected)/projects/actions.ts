'use server'

import { revalidatePath } from 'next/cache'
import { redirect } from 'next/navigation'
import { createClient } from '@/lib/supabase/server'

const projectStatuses = ['draft','planning','active','on_hold','completed','cancelled','archived'] as const
const priorities = ['low','medium','high','critical'] as const
const healthValues = ['green','yellow','red'] as const
const projectRoles = ['member','lead','sponsor'] as const

async function context() {
  const supabase = await createClient()
  const { data: { user } } = await supabase.auth.getUser()
  if (!user) redirect('/login')
  const { data: profile } = await supabase
    .from('profiles')
    .select('id,company_id,role')
    .eq('auth_id', user.id)
    .single()
  if (!profile) redirect('/setup-required')
  return { supabase, profile }
}

function text(formData: FormData, key: string) {
  return String(formData.get(key) || '').trim()
}

export async function createProject(formData: FormData) {
  const { supabase, profile } = await context()
  if (!['manager','executive','admin'].includes(profile.role)) redirect('/projects?error=permission')

  const code = text(formData, 'code').toUpperCase()
  const name = text(formData, 'name')
  if (!code || !name) redirect('/projects/new?error=required')

  const ownerId = text(formData, 'owner_id') || profile.id
  const sponsorId = text(formData, 'sponsor_id') || null
  const budgetValue = text(formData, 'budget')

  const { data: project, error } = await supabase.from('projects').insert({
    company_id: profile.company_id,
    code,
    name,
    description: text(formData, 'description') || null,
    owner_id: ownerId,
    sponsor_id: sponsorId,
    start_date: text(formData, 'start_date') || null,
    target_end_date: text(formData, 'target_end_date') || null,
    priority: priorities.includes(text(formData, 'priority') as any) ? text(formData, 'priority') : 'medium',
    status: 'planning',
    health: 'green',
    budget: budgetValue ? Number(budgetValue) : null,
    created_by: profile.id,
  }).select('id').single()

  if (error || !project) redirect(`/projects/new?error=${encodeURIComponent(error?.message || 'create_failed')}`)

  await supabase.from('project_members').upsert({
    project_id: project.id,
    profile_id: profile.id,
    project_role: 'lead',
  })
  if (ownerId !== profile.id) {
    await supabase.from('project_members').upsert({
      project_id: project.id,
      profile_id: ownerId,
      project_role: 'lead',
    })
  }
  if (sponsorId) {
    await supabase.from('project_members').upsert({
      project_id: project.id,
      profile_id: sponsorId,
      project_role: 'sponsor',
    })
  }
  redirect(`/projects/${project.id}?created=1`)
}

export async function updateProject(formData: FormData) {
  const { supabase } = await context()
  const id = text(formData, 'project_id')
  if (!id) return
  const progress = Math.min(100, Math.max(0, Number(text(formData, 'progress') || 0)))
  const status = text(formData, 'status')
  const priority = text(formData, 'priority')
  const health = text(formData, 'health')
  const budgetValue = text(formData, 'budget')
  await supabase.from('projects').update({
    name: text(formData, 'name'),
    description: text(formData, 'description') || null,
    owner_id: text(formData, 'owner_id') || null,
    sponsor_id: text(formData, 'sponsor_id') || null,
    start_date: text(formData, 'start_date') || null,
    target_end_date: text(formData, 'target_end_date') || null,
    status: projectStatuses.includes(status as any) ? status : 'planning',
    priority: priorities.includes(priority as any) ? priority : 'medium',
    health: healthValues.includes(health as any) ? health : 'green',
    progress,
    budget: budgetValue ? Number(budgetValue) : null,
    archived_at: status === 'archived' ? new Date().toISOString() : null,
    active: !['cancelled','archived'].includes(status),
  }).eq('id', id)
  revalidatePath('/projects')
  revalidatePath(`/projects/${id}`)
}

export async function addProjectMember(formData: FormData) {
  const { supabase } = await context()
  const projectId = text(formData, 'project_id')
  const profileId = text(formData, 'profile_id')
  const role = text(formData, 'project_role')
  if (!projectId || !profileId) return
  await supabase.from('project_members').upsert({
    project_id: projectId,
    profile_id: profileId,
    project_role: projectRoles.includes(role as any) ? role : 'member',
  })
  revalidatePath(`/projects/${projectId}`)
}

export async function removeProjectMember(formData: FormData) {
  const { supabase } = await context()
  const projectId = text(formData, 'project_id')
  const profileId = text(formData, 'profile_id')
  if (!projectId || !profileId) return
  await supabase.from('project_members').delete().eq('project_id', projectId).eq('profile_id', profileId)
  revalidatePath(`/projects/${projectId}`)
}

export async function createMilestone(formData: FormData) {
  const { supabase, profile } = await context()
  const projectId = text(formData, 'project_id')
  const title = text(formData, 'title')
  if (!projectId || !title) return
  await supabase.from('project_milestones').insert({
    project_id: projectId,
    title,
    description: text(formData, 'description') || null,
    due_date: text(formData, 'due_date') || null,
    created_by: profile.id,
  })
  revalidatePath(`/projects/${projectId}`)
}

export async function updateMilestoneStatus(formData: FormData) {
  const { supabase } = await context()
  const projectId = text(formData, 'project_id')
  const milestoneId = text(formData, 'milestone_id')
  const status = text(formData, 'status')
  if (!projectId || !milestoneId) return
  await supabase.from('project_milestones').update({
    status,
    completed_at: status === 'completed' ? new Date().toISOString() : null,
  }).eq('id', milestoneId)
  revalidatePath(`/projects/${projectId}`)
}
