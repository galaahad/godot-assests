# Player.gd (ฉบับแก้ไข)
# สคริปต์สำหรับควบคุมตัวละคร CharacterBody2D

extends CharacterBody2D

const SPEED = 300.0
# const JUMP_VELOCITY = -400.0 # ปิดการใช้งานการกระโดดไว้ชั่วคราว


# ใช้ @onready เพื่อให้แน่ใจว่า Node พร้อมใช้งานแล้วก่อนที่จะอ้างอิงถึง
# จะช่วยให้โค้ดทำงานได้เสถียรและสะอาดขึ้น
@onready var animated_sprite = $AnimatedSprite2D


# ฟังก์ชัน _ready จะถูกเรียกครั้งเดียวเมื่อ Node พร้อมใช้งาน
func _ready():
	# เราจะเชื่อมต่อ signal "animation_finished" จาก AnimatedSprite2D
	# มายังฟังก์ชันในสคริปต์นี้ วิธีนี้เป็นวิธีที่เสถียรที่สุดในการจัดการ
	# เมื่อแอนิเมชัน "attack" เล่นจบ
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	# 1. จัดการการเคลื่อนที่ (Movement)
	var direction = Input.get_axis("move_left", "move_right")
	
	# จะเคลื่อนที่ได้ ก็ต่อเมื่อตัวละครไม่ได้กำลังโจมตี
	if not animated_sprite.animation == "attack":
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else:
		# ถ้ากำลังโจมตี ให้ตัวละครหยุดนิ่ง
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 2. จัดการการโจมตี (Attack)
	if Input.is_action_just_pressed("attack"):
		# เล่นแอนิเมชัน "attack"
		# ไม่ต้องกังวลว่าจะถูกขัดจังหวะ เพราะเราจัดการในส่วนอื่นแล้ว
		animated_sprite.play("attack")
	
	# 3. อัปเดตแอนิเมชันการเคลื่อนไหว
	update_movement_animation()
	
	# 4. ใช้การเคลื่อนที่
	move_and_slide()


# ฟังก์ชันสำหรับอัปเดตแอนิเมชันที่เกี่ยวกับการเดิน/หยุดนิ่งเท่านั้น
func update_movement_animation() -> void:
	# ถ้ากำลังโจมตีอยู่ จะไม่เปลี่ยนไปเป็นท่าเดินหรือหยุด
	if animated_sprite.animation == "attack":
		return # ออกจากฟังก์ชันไปเลย

	# ตรรกะการเปลี่ยนท่าเดิน/หยุด/พลิกตัวแบบเดิม
	if velocity.x < 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.play("run")
		animated_sprite.flip_h = false
	else:
		animated_sprite.play("idle")


# ฟังก์ชันนี้จะถูกเรียกอัตโนมัติ "เมื่อแอนิเมชันใดๆ เล่นจบ"
func _on_animation_finished():
	# ตรวจสอบว่าแอนิเมชันที่เพิ่งเล่นจบคือ "attack" หรือไม่
	if animated_sprite.animation == "attack":
		# ถ้าใช่ ให้เปลี่ยนกลับไปเป็นท่า "idle" เพื่อให้ตัวละครกลับสู่สถานะปกติ
		animated_sprite.play("idle")
