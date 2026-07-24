# 05 — Core Workflows

## 1. Task Lifecycle

Draft → Assigned → Accepted → In Progress → Waiting → Completed → Reviewed → Closed

ทางเลือก:
- Assigned → Rejected / Reassigned
- In Progress → Waiting
- Completed → Reopened
- ทุกสถานะ → Cancelled ตามสิทธิ์

## 2. Task Creation

1. Creator เลือก Project
2. ระบุ Title, Owner, Due Date, Priority
3. เพิ่ม Description / Checklist / Attachments
4. Save Draft หรือ Assign
5. ระบบแจ้ง Assignee
6. บันทึก Activity Log

## 3. Employee Update

1. เปิด My Tasks
2. เลือกงาน
3. เปลี่ยน Status หรือ Progress
4. ใส่ Update Comment
5. Save
6. Manager เห็นข้อมูลล่าสุดและได้รับแจ้งตาม Rule

## 4. Completion & Review

1. Employee กด Completed
2. ระบบบังคับ Progress = 100
3. งานเข้า Review Queue หากกำหนด Reviewer
4. Reviewer เลือก Approve หรือ Reopen
5. Approve → Reviewed / Closed
6. Reopen → In Progress พร้อมเหตุผล

## 5. Overdue Escalation

- T-3 วัน: แจ้ง Assignee
- T-1 วัน: แจ้ง Assignee และแสดง Due Soon
- Due Date: แจ้ง Assignee
- T+1 วัน: แจ้ง Assignee + Manager
- Critical Overdue: แจ้ง Manager ทันทีและแสดง Executive Exception List

ค่าระยะเวลาเป็น Configuration ได้ในอนาคต

## 6. Project Health

Project Health คำนวณจาก:
- % Overdue
- Critical Open
- Milestone delay
- No update duration
- Manager override พร้อมเหตุผล

ผลลัพธ์: Green / Amber / Red

## 7. User Offboarding

1. Admin Suspend Account
2. ระบบหา Open Tasks และ Owned Projects
3. Reassign งานก่อน Archive User
4. Session ถูกยกเลิก
5. Audit Log เก็บผู้ดำเนินการ
