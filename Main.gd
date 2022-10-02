extends Control

export var question_collection: Resource
export var texture_correct: Texture
export var texture_wrong: Texture
export var texture_normal: Texture
export var time_to_show_pop_up: float = 3.0

var current_question: int = 0
var answered_questions: int = 0
onready var total_questions: int = question_collection.questions.size()
onready var _rnd := RandomNumberGenerator.new()


# Called when the node enters the scene tree for the first time.
func _ready():
	print(str(total_questions))
	_rnd.randomize()
	current_question = _choose_random_question()
	_update_question_controls(question_collection.questions[current_question])
	

func _choose_random_question() -> int:
	return _rnd.randi_range(0, question_collection.questions.size() - 1)


func _update_question_controls(p_question: Question) -> void:
	#$ParkerProbe.position = 
	$lblQuestion.text = p_question.question
	$lblChoice1.text = p_question.answers[0]
	$lblChoice2.text = p_question.answers[1]
	$lblChoice3.text = p_question.answers[2]
	$btnChoice1.texture_normal = texture_normal
	$btnChoice2.texture_normal = texture_normal
	$btnChoice3.texture_normal = texture_normal

func _next_question():
	answered_questions += 1
	current_question = _choose_random_question()
	if answered_questions >= question_collection.questions.size() - 1:
		print("end")
	else:
		_update_question_controls(question_collection.questions[current_question])
		
	
func _check_answer(p_question: Question, p_answer: int) -> bool:
	if p_question.correct_answer_index == p_answer:
		return true
	return false


func _correct_answer(p_correct: int) -> void:
	_show_correct_answer(p_correct)
	yield(get_tree().create_timer(time_to_show_pop_up), "timeout")
	_show_popup_correct()


func _wrong_answer(p_wrong: int, p_correct: int) -> void:
	_show_correct_answer(p_correct)
	_show_wrong_answer(p_wrong)
	yield(get_tree().create_timer(time_to_show_pop_up), "timeout")
	_show_popup_wrong()


func _show_correct_answer(p_correct: int) -> void:
	if p_correct == 0:
		$btnChoice1.texture_normal = texture_correct
	elif p_correct == 1:
		$btnChoice2.texture_normal = texture_correct
	elif p_correct == 2:
		$btnChoice3.texture_normal = texture_correct
	

func _show_wrong_answer(p_wrong: int) -> void:
	if p_wrong == 0:
		$btnChoice1.texture_normal = texture_wrong
	elif p_wrong == 1:
		$btnChoice2.texture_normal = texture_wrong
	elif p_wrong == 2:
		$btnChoice3.texture_normal = texture_wrong


func _show_popup_correct() -> void:
	$PopUpCorrect.visible = true


func _show_popup_wrong() -> void:
	$PopUpWrong.visible = true


func _on_btnChoice1_button_up():
	var question: Question = question_collection.questions[current_question]
	if _check_answer(question, 0):
		_correct_answer(0)
	else:
		_wrong_answer(0, question.correct_answer_index)


func _on_btnChoice2_button_up():
	var question: Question = question_collection.questions[current_question]
	if _check_answer(question, 1):
		_correct_answer(1)
	else:
		_wrong_answer(1, question.correct_answer_index)


func _on_btnChoice3_button_up():
	var question: Question = question_collection.questions[current_question]
	if _check_answer(question, 2):
		_correct_answer(2)
	else:
		_wrong_answer(2, question.correct_answer_index)



func _on_btnExitWrong_button_up():
	$PopUpWrong.visible = false
	_next_question()


func _on_btnExitCorrect_button_up():
	$PopUpCorrect.visible = false
	_next_question()
