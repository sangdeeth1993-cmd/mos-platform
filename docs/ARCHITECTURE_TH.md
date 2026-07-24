# Architecture
ผู้ใช้ → Vercel/Next.js → Supabase Auth + PostgreSQL

- Next.js App Router และ Server Components
- Supabase SSR ใช้ Cookie Session
- Row Level Security ควบคุมข้อมูลระดับฐานข้อมูล
- Database migrations เก็บใน Git
- Vercel deploy อัตโนมัติทุกครั้งที่ push เข้า main
