extends PopupPanel

signal color_chosen(color: Color)

@onready var red_button: Button = $MarginContainer/GridContainer/RedButton
@onready var yellow_button: Button = $MarginContainer/GridContainer/YellowButton
@onready var orange_button: Button = $MarginContainer/GridContainer/OrangeButton
@onready var green_button: Button = $MarginContainer/GridContainer/GreenButton
@onready var blue_button: Button = $MarginContainer/GridContainer/BlueButton
@onready var purple_button: Button = $MarginContainer/GridContainer/PurpleButton
@onready var pink_button: Button = $MarginContainer/GridContainer/PinkButton
@onready var white_button: Button = $MarginContainer/GridContainer/WhiteButton  # Novo
@onready var black_button: Button = $MarginContainer/GridContainer/BlackButton  # Novo
@onready var dark_blue_button: Button = $MarginContainer/GridContainer/DarkBlueButton  # Novo
@onready var dark_red_button: Button = $MarginContainer/GridContainer/DarkRedButton  # Novo
@onready var gray_button: Button = $MarginContainer/GridContainer/GrayButton  # Novo
@onready var dark_green_button: Button = $MarginContainer/GridContainer/DarkGreenButton  # Novo
@onready var brown_button: Button = $MarginContainer/GridContainer/BrownButton  # Novo

func _ready():
	red_button.pressed.connect(_on_red_pressed)
	yellow_button.pressed.connect(_on_yellow_pressed)
	orange_button.pressed.connect(_on_orange_pressed)
	green_button.pressed.connect(_on_green_pressed)
	blue_button.pressed.connect(_on_blue_pressed)
	purple_button.pressed.connect(_on_purple_pressed)
	pink_button.pressed.connect(_on_pink_pressed)
	white_button.pressed.connect(_on_white_pressed)  # Novo
	black_button.pressed.connect(_on_black_pressed)  # Novo
	dark_blue_button.pressed.connect(_on_dark_blue_pressed)  # Novo
	dark_red_button.pressed.connect(_on_dark_red_pressed)  # Novo
	gray_button.pressed.connect(_on_gray_pressed)  # Novo
	dark_green_button.pressed.connect(_on_dark_green_pressed)  # Novo
	brown_button.pressed.connect(_on_brown_pressed)  # Novo

# Funções para cada cor (emita o sinal e feche o popup)
func _on_red_pressed():
	color_chosen.emit(Color(0.941, 0.0, 0.157))
	hide()

func _on_yellow_pressed():
	color_chosen.emit(Color(0.941, 0.820, 0.302))
	hide()

func _on_orange_pressed():
	color_chosen.emit(Color(0.839, 0.435, 0.129))
	hide()

func _on_green_pressed():
	color_chosen.emit(Color(0.475, 0.788, 0.353))
	hide()

func _on_blue_pressed():
	color_chosen.emit(Color(0.208, 0.663, 0.788))
	hide()

func _on_purple_pressed():
	color_chosen.emit(Color(0.557, 0.282, 0.902))
	hide()

func _on_pink_pressed():
	color_chosen.emit(Color(0.812, 0.196, 0.753))
	hide()

func _on_white_pressed():  # Novo
	color_chosen.emit(Color(1.0, 1.0, 1.0))
	hide()

func _on_black_pressed():  # Novo
	color_chosen.emit(Color(0.0, 0.0, 0.0))
	hide()

func _on_dark_blue_pressed():  # Novo
	color_chosen.emit(Color(0.231, 0.349, 0.918))
	hide()

func _on_dark_red_pressed():  # Novo
	color_chosen.emit(Color(0.431, 0.090, 0.090))
	hide()

func _on_gray_pressed():  # Novo
	color_chosen.emit(Color(0.643, 0.643, 0.643))
	hide()

func _on_dark_green_pressed():  # Novo
	color_chosen.emit(Color(0.149, 0.349, 0.0))
	hide()

func _on_brown_pressed():  # Novo
	color_chosen.emit(Color(0.251, 0.184, 0.0))
	hide()
