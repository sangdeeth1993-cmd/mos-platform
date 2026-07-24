# 07 — Data Model Blueprint

## 1. Core Entity Groups

### Tenant & Organization
- tenants
- companies
- departments
- teams

### Identity & Access
- profiles
- roles
- permissions
- role_permissions
- user_roles

### Projects
- projects
- project_members
- project_milestones

### Tasks
- tasks
- task_assignees
- task_watchers
- task_checklist_items
- task_comments
- task_updates
- task_attachments
- task_tags

### Communication
- notifications
- notification_preferences

### Governance
- activity_logs
- audit_events
- settings

## 2. Mandatory Common Fields

ตารางธุรกิจหลักควรมี:
- id UUID
- tenant_id UUID
- created_at timestamptz
- created_by UUID
- updated_at timestamptz
- updated_by UUID
- archived_at timestamptz nullable

## 3. Data Rules

- UUID เป็น Primary Key
- ใช้ Foreign Key พร้อม Restrict/Cascade อย่างระมัดระวัง
- ไม่ Hard Delete ข้อมูล Transaction หลัก
- ทุก Tenant-scoped table ต้องมี tenant_id
- Index คอลัมน์ที่ใช้ Filter บ่อย เช่น assignee_id, project_id, status, due_date
- ใช้ Enum อย่างจำกัดเพื่อไม่ให้ Migration ยุ่งยากเกินไป; Master table เหมาะกับค่าที่ปรับได้

## 4. Task Minimum Schema

- id
- tenant_id
- company_id
- project_id
- parent_task_id
- title
- description
- status
- priority
- progress
- owner_id
- reviewer_id
- start_date
- due_date
- completed_at
- closed_at
- created_at / created_by
- updated_at / updated_by
- archived_at

## 5. Multi-tenant Isolation

ทุก Policy ต้องตรวจ:
1. User มี profile active
2. User เป็นสมาชิก Tenant
3. Scope ของ Role ครอบคลุม Entity

ห้ามพึ่ง company_id จาก Client โดยไม่ตรวจ Membership

## 6. Reporting Strategy

MVP ใช้ Query/View โดยตรง
ระยะถัดไปเพิ่ม:
- Materialized views
- Daily snapshots
- KPI fact tables
เมื่อข้อมูลและ Dashboard ซับซ้อนขึ้น
