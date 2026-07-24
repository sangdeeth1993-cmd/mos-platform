# Milestone 2 — Identity & Organization: ขั้นตอนติดตั้ง

## 1) อัปโหลดโค้ด
อัปโหลดไฟล์ทั้งหมดในแพ็กเกจนี้ทับ Repository `mos-platform` แล้ว Commit changes

## 2) Supabase SQL
รันตามลำดับ:
1. `supabase/migrations/202607240001_initial_schema.sql` (ถ้ายังไม่เคยรัน)
2. `supabase/seed.sql` (ถ้ายังไม่เคยรัน)
3. `supabase/migrations/202607240002_identity_organization.sql`

## 3) สร้างผู้ใช้ทดลอง
Supabase → Authentication → Users → Add user
- `adm001@mos.local` รหัสผ่านอย่างน้อย 6 ตัว
- `mgr001@mos.local`
- `emp001@mos.local`

Migration ใหม่จะสร้าง Profile อัตโนมัติจากชื่อก่อน @ เช่น ADM001
ค่าเริ่มต้นเป็น role = employee ดังนั้นหลังสร้างแล้วให้ไป SQL Editor และรัน:

```sql
update public.profiles set display_name='ผู้ดูแลระบบ', role='admin' where employee_id='ADM001';
update public.profiles set display_name='ผู้จัดการ', role='manager' where employee_id='MGR001';
update public.profiles set display_name='พนักงาน', role='employee' where employee_id='EMP001';
```

## 4) Vercel
ตรวจ Environment Variables:
- `NEXT_PUBLIC_SUPABASE_URL`
- `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`

เมื่อ GitHub Commit สำเร็จ Vercel จะ Deploy อัตโนมัติ

## 5) ทดสอบ
- `/login` Login ด้วย ADM001
- `/organization` ต้องเห็น Company, Departments และ Employees
- Admin ต้องเพิ่ม Department ได้
- `/profile` ต้องแก้ชื่อที่แสดงได้
- Employee/Manager เห็น Organization ได้ แต่เพิ่ม Department ไม่ได้
