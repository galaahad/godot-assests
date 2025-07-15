# Player.gd
# สคริปต์สำหรับควบคุมตัวละคร CharacterBody2D (เพิ่มการโจมตี, กระโดด, และแรงโน้มถ่วง)

extends CharacterBody2D

# --- ค่าคงที่ (Constants) ---
const SPEED = 300.0
const JUMP_VELOCITY = -400.0 # เปิดใช้งานค่าความแรงในการกระโดด

# --- ตัวแปร (Variables) ---
# ดึงค่าแรงโน้มถ่วงมาจาก Project Settings เพื่อให้ตรงกับค่าฟิสิกส์มาตรฐานของโปรเจกต์
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# --- การอ้างอิง Node (Node References) ---
@onready var animated_sprite = $AnimatedSprite2D


# ฟังก์ชัน _ready จะถูกเรียกครั้งเดียวเมื่อ Node พร้อมใช้งาน
func _ready():
	# เชื่อมต่อ signal "animation_finished" เพื่อจัดการเมื่อแอนิเมชันโจมตีเล่นจบ
	animated_sprite.animation_finished.connect(_on_animation_finished)


func _physics_process(delta: float) -> void:
	# 1. เพิ่มแรงโน้มถ่วง (Apply Gravity)
	# ถ้าตัวละครไม่ได้อยู่บนพื้น (ลอยอยู่) ให้เพิ่มความเร็วในแนวดิ่งลงมาเรื่อยๆ
	if not is_on_floor():
		velocity.y += gravity * delta

	# 2. จัดการการกระโดด (Handle Jump)
	# ตรวจสอบว่าผู้เล่นกดปุ่มกระโดดและกำลังอยู่บนพื้นหรือไม่
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 3. จัดการการเคลื่อนที่ซ้าย-ขวา (Handle Movement)
	var direction = Input.get_axis("move_left", "move_right")
	
	if not animated_sprite.animation == "attack": # จะเคลื่อนที่ได้ ก็ต่อเมื่อไม่ได้กำลังโจมตี
		if direction != 0:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
	else: # ถ้ากำลังโจมตี ให้หยุดนิ่ง
		velocity.x = move_toward(velocity.x, 0, SPEED)

	# 4. จัดการการโจมตี (Handle Attack)
	if Input.is_action_just_pressed("attack"):
		animated_sprite.play("attack")
	
	# 5. อัปเดตแอนิเมชัน
	update_movement_animation()
	
	# 6. ใช้การเคลื่อนที่
	move_and_slide()


# ฟังก์ชันสำหรับอัปเดตแอนิเมชันที่เกี่ยวกับการเดิน/หยุดนิ่ง
func update_movement_animation() -> void:
	if animated_sprite.animation == "attack":
		return

	if not is_on_floor(): # ถ้าลอยอยู่ ให้แสดงท่ากระโดด (ถ้ามี)
		animated_sprite.play("jump")
	elif velocity.x != 0: # ถ้าเคลื่อนที่บนพื้น
		animated_sprite.play("run")
	else: # ถ้าหยุดนิ่งบนพื้น
		animated_sprite.play("idle")
	
	# พลิกตัวละคร
	if velocity.x < 0:
		animated_sprite.flip_h = true
	elif velocity.x > 0:
		animated_sprite.flip_h = false


# ฟังก์ชันนี้จะถูกเรียกอัตโนมัติเมื่อแอนิเมชันใดๆ เล่นจบ
func _on_animation_finished():
	if animated_sprite.animation == "attack":
		animated_sprite.play("idle")
