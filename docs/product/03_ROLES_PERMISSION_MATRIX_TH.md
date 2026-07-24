# 03 — User Roles & Permission Matrix

## 1. Roles

### Founder / Executive
เห็นข้อมูลภาพรวมทุกบริษัทตาม Scope ที่ได้รับ และใช้ Dashboard เพื่อการตัดสินใจ

### Company Admin
ดูแลโครงสร้างบริษัท ผู้ใช้ Role Master Data และการตั้งค่า

### Department Manager
ดูงานของ Department มอบหมายงาน ติดตาม และ Review

### Project Manager
บริหาร Project Members, Tasks, Timeline และ Project Dashboard

### Team Leader / Supervisor
ดูงานทีมย่อย มอบหมายและติดตามงานภายในทีม

### Employee
ดูและอัปเดตงานของตน รวมถึงงานที่ถูกเชิญให้ร่วม

### Auditor / Viewer
อ่านข้อมูลและ Report ตาม Scope แต่แก้ไขไม่ได้

## 2. Permission Matrix

| Capability | Employee | Team Lead | Project Manager | Dept Manager | Executive | Admin |
|---|---:|---:|---:|---:|---:|---:|
| View own tasks | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Update own task | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Create personal task | ✓ | ✓ | ✓ | ✓ | ✓ | ✓ |
| Assign task to others | — | Team | Project | Department | Scope | All |
| View team tasks | — | ✓ | Project members | Department | Scope | All |
| Review completed task | — | ✓ | ✓ | ✓ | ✓ | ✓ |
| Create project | — | — | Optional | ✓ | ✓ | ✓ |
| Edit project settings | — | — | Own project | Department | Scope | All |
| Manage project members | — | — | ✓ | ✓ | ✓ | ✓ |
| View executive dashboard | — | Limited | Project | Department | ✓ | ✓ |
| Manage users | — | — | — | Limited | — | ✓ |
| Manage roles/permissions | — | — | — | — | — | ✓ |
| View audit logs | Own actions | Team | Project | Department | Scope | All |
| Archive task/project | — | Limited | Own project | Department | Scope | All |

## 3. Scope Model

Permission = Role + Scope

Scope สามารถเป็น:
- Own
- Team
- Project
- Department
- Company
- Tenant / All Companies

## 4. Security Rules

- UI ซ่อนเมนูไม่เพียงพอ ต้องบังคับสิทธิ์ที่ Database/RLS ด้วย
- Admin ไม่ควรใช้บัญชีเดียวกับการทำงานทั่วไปในระยะ Production
- Service Role Key ใช้เฉพาะ Server-side
- Permission changes ต้องถูกบันทึกใน Audit Log
