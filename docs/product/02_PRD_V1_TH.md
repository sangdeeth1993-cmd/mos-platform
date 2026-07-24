# 02 — Product Requirements Document (PRD) v1.0

## 1. Scope

MOS Platform v1.0 เป็นระบบบริหารงานภายในองค์กรแบบ Multi-company / Multi-project โดยมี Task Management เป็นแกนกลาง

## 2. User Problems

- งานมาจากหลายช่องทางและไม่มีรายการกลาง
- Owner, Due Date และความคืบหน้าไม่ชัดเจน
- ผู้บริหารต้องถามสถานะซ้ำ
- ข้อมูล Project แยกใน Excel, LINE และ Email
- ไม่มีประวัติการเปลี่ยนแปลงที่ตรวจสอบได้
- Dashboard ใช้เวลารวบรวมข้อมูลด้วยมือ

## 3. Functional Requirements

### FR-01 Authentication
- Login ด้วย Employee ID หรือ Email
- Logout ทุกอุปกรณ์ได้
- Reset Password/PIN โดย Admin
- Account Active / Suspended / Archived
- Session timeout และ secure cookie

### FR-02 Organization
- รองรับหลายบริษัทภายใต้ Tenant เดียว
- กำหนด Department, Team และ Reporting Line
- ผู้ใช้หนึ่งคนอยู่ได้มากกว่าหนึ่ง Project
- ผู้ใช้มี Default Company และ Department

### FR-03 User & Role Management
- Admin สร้าง แก้ไข ระงับผู้ใช้
- กำหนด Role ระดับระบบและระดับ Project
- เก็บ Employee ID, Display Name, Email, Position
- Manager เห็นสมาชิกในทีมตาม Scope

### FR-04 Projects
- สร้าง Project พร้อม Owner, Sponsor, Dates, Status, Health
- เพิ่ม Project Members และ Role
- แสดงสรุป Open, Overdue, Completed, Progress
- Archive Project โดยไม่ลบประวัติ

### FR-05 Tasks
- Task ต้องมี Title, Project, Owner, Due Date, Priority, Status
- รองรับ Assignee หลักหนึ่งคนและผู้ติดตามหลายคน
- รองรับ Parent Task / Subtask
- รองรับ Description, Checklist, Tags และ Attachments
- สถานะพื้นฐาน: Draft, Assigned, Accepted, In Progress, Waiting, Completed, Reviewed, Closed, Cancelled
- บันทึก Completion Date และ Reviewed By

### FR-06 Task Updates & Comments
- ผู้รับผิดชอบอัปเดต Status, Progress, Comment
- แสดง Timeline ตามเวลา
- Mention ผู้ใช้ได้
- เก็บค่าเดิมและค่าใหม่สำหรับข้อมูลสำคัญ

### FR-07 Dashboard
- Employee: งานของฉัน, วันนี้, Overdue, 7 วัน
- Manager: Team workload, Overdue, No update, Critical
- Executive: Portfolio, Project health, Trend, Key blockers
- ตัวกรอง Company, Department, Project, Owner, Date

### FR-08 Notifications
- แจ้ง Assign งานใหม่
- แจ้งใกล้ Due Date
- แจ้ง Overdue
- แจ้ง Mention / Comment
- แจ้ง Completed รอ Review
- ผู้ใช้ตั้งค่า Notification Preference ได้

### FR-09 Search & Filters
- ค้นหา Task, Project, User
- Filter ตาม Status, Priority, Owner, Project, Due Date
- บันทึก Filter ที่ใช้บ่อยได้ในระยะถัดไป

### FR-10 Audit & Compliance
- บันทึก Login, Create, Update, Delete/Archive, Permission Change
- Audit Log แก้ไขย้อนหลังไม่ได้โดยผู้ใช้ทั่วไป
- Soft delete สำหรับข้อมูลสำคัญ

## 4. Business Rules

- Task ที่ Active ต้องมี Owner และ Due Date
- Employee ปิดงานเองได้เฉพาะเมื่อ Workflow ไม่ต้อง Review
- งาน Critical ต้องแจ้ง Manager ทันทีเมื่อ Overdue
- Progress ต้องอยู่ระหว่าง 0–100
- Status Completed ต้องมี Progress = 100
- Closed Task แก้ไขไม่ได้ ยกเว้น Admin หรือ Reopen ตามสิทธิ์
- การลบ Project ใช้วิธี Archive เท่านั้นใน Production

## 5. Non-functional Requirements

### Performance
- หน้า Home โหลดข้อมูลหลักภายใน 2 วินาทีในเครือข่ายปกติ
- API ทั่วไป P95 ไม่เกิน 800 ms เป้าหมายเริ่มต้น

### Availability
- เป้าหมาย 99.5% สำหรับช่วง Pilot
- มี Backup ฐานข้อมูลตามแพ็กเกจ Production

### Security
- HTTPS ทุกหน้า
- Row Level Security
- Secret Key ไม่อยู่ใน Client
- Least Privilege
- Audit Log สำหรับ Action สำคัญ

### Usability
- Responsive: Mobile, Tablet, Desktop
- งานหลักทำได้ไม่เกิน 3 คลิกจาก Home
- รองรับภาษาไทยเป็นภาษาหลัก

### Maintainability
- Database changes ผ่าน Migration
- Source code และเอกสารอยู่ GitHub
- แยก Dev / Preview / Production Environment

## 6. Assumptions

- Pilot 5–15 คน
- Production ระยะแรกไม่เกิน 100 คน
- ผู้ใช้มี Internet เป็นหลัก
- Browser เป้าหมาย: Safari, Chrome, Edge รุ่นปัจจุบัน

## 7. Acceptance Criteria for Core MVP

1. ผู้ใช้ 3 Role Login และเห็นข้อมูลตามสิทธิ์
2. Manager สร้าง Task และ Assign ให้ Employee ได้
3. Employee อัปเดต Progress และ Comment ได้
4. การอัปเดตจากมือถือปรากฏบน Desktop โดยใช้ข้อมูลกลาง
5. Executive Dashboard นับข้อมูลถูกต้อง
6. ผู้ใช้ข้าม Company/Scope ไม่สามารถอ่านข้อมูลที่ไม่มีสิทธิ์
7. Audit Log แสดงผู้แก้ไข เวลา และ Action
