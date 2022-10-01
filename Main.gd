extends Control

export var questions: Resource

var current_question: int
onready var total_questions: int = questions.questions.size()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _next_question():
	current_question += 1
	if current_question >= total_questions - 1:
		print("end")
	else:
		$HBoxContainer/VBoxContainer/lblQuestion.text = questions.questions[current_question].question
		$HBoxContainer/VBoxContainer/btnChoice1.text = questions.questions[current_question].answers[0]
		$HBoxContainer/VBoxContainer/btnChoice2.text = questions.questions[current_question].answers[1]
		$HBoxContainer/VBoxContainer/btnChoice3.text = questions.questions[current_question].answers[2]
		$HBoxContainer/VBoxContainer/btnChoice4.text = questions.questions[current_question].answers[3]
	
	
func _check_answer(p_question: Question, p_answer: int) -> bool:
	if p_question.correct_answer_index == p_answer:
		return true
	return false


func _on_btnChoice1_button_up():
	_check_answer(questions.questions[current_question], 0)


func _on_btnChoice2_button_up():
	_check_answer(questions.questions[current_question], 1)


func _on_btnChoice3_button_up():
	_check_answer(questions.questions[current_question], 2)


func _on_btnChoice4_button_up():
	_check_answer(questions.questions[current_question], 3)
