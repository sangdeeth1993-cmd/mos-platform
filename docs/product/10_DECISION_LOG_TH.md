# 10 — Product Decision Log

| ID | Decision | Rationale | Status |
|---|---|---|---|
| D-001 | ใช้ Web/PWA ไม่ทำ Native App ในระยะแรก | ลดต้นทุนและใช้ได้ทุกอุปกรณ์ | Approved |
| D-002 | ใช้ Next.js + Vercel | Deployment และ Preview ง่าย | Approved |
| D-003 | ใช้ Supabase/PostgreSQL | Auth, DB, Storage และ RLS ใน Platform เดียว | Approved |
| D-004 | ใช้ GitHub เป็น Single Source of Truth | ควบคุม Version ของ Code/Docs/Migration | Approved |
| D-005 | แยก Prototype `mos-lite-pwa` จาก Production repo `mos-platform` | ป้องกัน Demo code ปะปน Production | Approved |
| D-006 | Multi-company ready ตั้งแต่ Data Model | รองรับ Kaprow, Water, Solar และธุรกิจใหม่ | Approved |
| D-007 | MVP เน้น Project + Task ก่อน Module อื่น | ให้คุณค่ารวดเร็วและลด Scope Risk | Approved |
| D-008 | Employee ID ใช้เป็น Login identifier ที่เป็นมิตร แต่ Auth ภายในใช้ Email/Identity ที่ปลอดภัย | UX ง่ายและยังใช้ Supabase Auth ได้ | Proposed |
| D-009 | ใช้ RLS ควบคู่ Server validation | ป้องกันข้อมูลข้าม Scope | Approved |

## Open Decisions

- จะใช้ชื่อบริษัทหลัก/ชื่อ Tenant อย่างเป็นทางการว่าอะไร
- Role จริงในองค์กรช่วง Pilot มีตำแหน่งใดบ้าง
- Task ต้อง Review ทุกงานหรือกำหนดเป็นรายงาน
- ช่องทาง Notification แรก: In-app เท่านั้น หรือเพิ่ม Email/LINE
- ระยะเวลา Overdue escalation ที่เหมาะกับองค์กร
