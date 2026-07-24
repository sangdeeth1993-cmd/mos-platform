# 06 — System Architecture

## 1. Target Architecture

```text
User Browser / Installed PWA
        |
        | HTTPS
        v
Vercel — Next.js Application
        |
        | Supabase SSR / Server Actions / API
        v
Supabase
  - Authentication
  - PostgreSQL
  - Row Level Security
  - Storage
  - Realtime (selective)
        |
        v
Monitoring / Audit / Backup
```

## 2. Environments

- Development: Local developer environment
- Preview: Vercel Preview per branch/PR
- Production: Main branch + Production Supabase

Production data ห้ามใช้ใน Development โดยตรง

## 3. Frontend

- Next.js App Router
- TypeScript
- Server Components เป็นค่าเริ่มต้น
- Client Components เฉพาะส่วน Interactive
- Responsive / Mobile First
- PWA เพิ่มหลัง Core Flow เสถียร

## 4. Backend

- ใช้ Supabase Auth และ PostgreSQL
- Server Actions/API Route สำหรับ Action ที่ต้องตรวจสิทธิ์เพิ่ม
- RLS เป็นแนวป้องกันหลักของ Data Access
- Business validation สำคัญทำทั้ง Server และ Database Constraint

## 5. Security Boundaries

- Browser ใช้ Publishable/Anon Key เท่านั้น
- Service Role Key อยู่ Server Environment เท่านั้น
- ทุก Query ต้องอยู่ภายใต้ User Session หรือ Trusted Server Context
- File access ใช้ Signed URL หรือ Storage Policy

## 6. Deployment Flow

Feature Branch → Pull Request → Vercel Preview → Review/Test → Merge Main → Production Deployment

Database Migration ต้อง Review ก่อนใช้ Production

## 7. Observability

ขั้นต่ำสำหรับ Pilot:
- Vercel deployment logs
- Supabase auth/database logs
- Application error logging
- Audit Log ในระบบ

Production ระยะถัดไป:
- Error monitoring
- Uptime monitoring
- Performance tracing
