# ขั้นตอนติดตั้ง MOS Platform v1.0

## A. GitHub
สร้าง repository ชื่อ `mos-platform` แล้วอัปโหลด **เนื้อหาภายในโฟลเดอร์นี้** ให้ `package.json` อยู่ระดับบนสุด

## B. Supabase Database
1. SQL Editor → New Query
2. เปิดไฟล์ `supabase/migrations/202607240001_initial_schema.sql` ด้วย TextEdit/VS Code
3. Copy ทั้งหมด → Paste → Run
4. รัน `supabase/seed.sql`

## C. Supabase Authentication
Authentication → Users → Add user:
- emp001@mos.local
- mgr001@mos.local
- adm001@mos.local

ตั้งรหัสผ่านชั่วคราวอย่างน้อย 6 ตัว และเปิด Auto Confirm User
จากนั้นคัดลอก User UUID ของแต่ละบัญชี แล้วแก้ไฟล์ `docs/03_link_auth_users.sql` ก่อน Run

## D. API Keys
Supabase → Project Settings → API Keys
ใช้ Project URL และ Publishable key เท่านั้นสำหรับตัวแปร `NEXT_PUBLIC_*` ห้ามนำ service_role key ลง GitHub หรือ Browser

## E. Vercel
Import repository `mos-platform` → Environment Variables:
- NEXT_PUBLIC_SUPABASE_URL
- NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY
กด Deploy

## F. ทดสอบ
เปิด `/api/health` ต้องเห็น `{ "ok": true }` จากนั้นเปิด `/login`
