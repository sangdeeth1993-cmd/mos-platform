# MOS Platform v1.2 — Milestone 3: Project Management

## สิ่งที่เพิ่ม
- Project List พร้อม Search และ Status Filter
- Create Project
- Project Detail และการแก้ไขสถานะ/Health/Progress
- Project Members และบทบาท Member/Lead/Sponsor
- Milestones
- Project Activity Log
- Dashboard KPI ระดับ Project
- Row Level Security สำหรับ Manager, Executive, Admin และ Employee

## ขั้นตอนติดตั้ง
1. อัปโหลดไฟล์ทั้งหมดในแพ็กเกจนี้ทับ repository `mos-platform` แล้ว Commit
2. Supabase → SQL Editor → New Query
3. เปิดและรันไฟล์ `supabase/migrations/202607240003_project_management.sql`
4. ตรวจว่าแสดง `Success. No rows returned`
5. รอ Vercel Deploy แล้วเปิด `/projects`

## สิทธิ์หลัก
- Manager: สร้างโครงการ และจัดการโครงการที่ตนเป็น Lead/Sponsor
- Executive/Admin: เห็นทุกโครงการในบริษัท และจัดการได้
- Employee: เห็นเฉพาะโครงการที่เป็นสมาชิก
- Admin: ลบโครงการได้ตาม RLS (UI ยังใช้ Archive เป็นหลัก)

## Test Checklist
- [ ] Admin เปิด `/projects` ได้
- [ ] Admin สร้าง Project ได้
- [ ] Owner ถูกเพิ่มเป็น Lead อัตโนมัติ
- [ ] เพิ่ม/ลบสมาชิกได้
- [ ] เพิ่ม Milestone และเปลี่ยนสถานะได้
- [ ] เปลี่ยน Progress/Health/Status แล้ว Activity เพิ่ม
- [ ] Employee เห็นเฉพาะ Project ที่เป็นสมาชิก
- [ ] Mobile layout แสดงผลได้

## หมายเหตุ
Migration นี้ออกแบบให้รันหลัง Milestone 1 และ 2 เท่านั้น และใช้ `if not exists` สำหรับโครงสร้างส่วนใหญ่ อย่างไรก็ตามไม่ควรรันซ้ำโดยไม่จำเป็น
