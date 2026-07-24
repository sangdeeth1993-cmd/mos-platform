# MOS Platform v1.0 Starter

โครงสร้างเริ่มต้นสำหรับระบบ Company Operating System แบบ Next.js + Supabase + Vercel

## เริ่มใช้งาน
1. อัปโหลดไฟล์ทั้งหมดเข้า GitHub repository ใหม่หรือแทน repository เดิม
2. Supabase SQL Editor: รัน `supabase/migrations/202607240001_initial_schema.sql`
3. รัน `supabase/seed.sql`
4. สร้าง Auth users และรัน `docs/03_link_auth_users.sql` หลังแก้ UUID ตามจริง
5. Vercel Environment Variables:
   - `NEXT_PUBLIC_SUPABASE_URL`
   - `NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY`
6. Deploy

อ่านขั้นตอนภาษาไทยใน `docs/NEXT_STEPS_TH.md`
