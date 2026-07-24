# 08 — Design System v1

## 1. Design Direction

- Professional
- Calm
- Clear hierarchy
- Mobile first
- ใช้สีเพื่อสื่อความหมาย ไม่ใช้เพื่อประดับมากเกินไป

## 2. Semantic Colors

- Primary: Navigation / Main action
- Success: Completed / Healthy
- Warning: Due soon / Attention
- Danger: Overdue / Critical
- Neutral: Background / Border / Secondary text

ค่ารหัสสีจริงกำหนดใน Design Token ของ Source Code ไม่กระจายตาม Component

## 3. Typography

- ภาษาไทยต้องอ่านง่ายบนมือถือ
- Heading ชัดเจน 3 ระดับ
- Body ขั้นต่ำ 16px ใน Form/Task Content
- Metadata ใช้ขนาดเล็กกว่าแต่ต้องไม่ต่ำจนอ่านยาก

## 4. Spacing

ใช้ระบบ 4px/8px base:
- 4, 8, 12, 16, 24, 32, 48

## 5. Core Components

- App Header
- Bottom Navigation
- Sidebar
- KPI Card
- Task Card
- Status Badge
- Priority Badge
- Progress Bar
- Form Field
- Empty State
- Confirmation Dialog
- Toast / Inline Error
- Data Table

## 6. Task Card Information Order

1. Task Title
2. Project
3. Due Date
4. Status + Progress
5. Priority / Exception
6. Primary action

## 7. Interaction Rules

- Primary action ต่อหน้าควรมีหนึ่งรายการเด่น
- Destructive action ต้อง Confirm
- Save ต้องแสดงผลสำเร็จหรือ Error ชัดเจน
- Loading ต้องไม่ทำให้ผู้ใช้กดซ้ำ
- Form validation แสดงใกล้ Field

## 8. Accessibility

- Contrast ต้องเพียงพอ
- Status ห้ามสื่อด้วยสีอย่างเดียว
- ปุ่มมี Label ชัดเจน
- Touch target อย่างน้อยประมาณ 44px
- รองรับ Keyboard บน Desktop สำหรับ Flow หลัก
