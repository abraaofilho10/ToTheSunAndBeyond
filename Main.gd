extends Control

export var question_collection: Resource
export var texture_correct: Texture
export var texture_wrong: Texture
export var texture_normal: Texture
export var time_to_show_pop_up: float = 3.0
export var probe_min_y_position: float = 676.32
export var probe_max_y_position: float = 101
export var probe_y_size: float = 80.0
export var blinking_time: float = 0.3
export var waiting_time_to_show_answer: float = 1.2

export var scenes: Array

var current_question: int = 0
var answered_questions: int = 0
var not_used_questions := []
var can_click := true
var current_scene: int = 0
var next_step_at_question := [3, 8, 13]
onready var total_questions: int = question_collection.questions.size()
onready var _rnd := RandomNumberGenerator.new()

signal button_animation_completed


# Called when the node enters the scene tree for the first time.
func _ready():
	var cnt: int = 0
	for i in range(0, total_questions):
		not_used_questions.append(i)
	
	print("not_used_questions = " + str(not_used_questions))
	
	_rnd.randomize()
	
	print("ready")
	print("_update_probe_position")
	
	_update_probe_position()
	
	print("calling _start_current_scene()")
	_start_current_scene()


func _choose_random_question() -> int:
	var q := _rnd.randi_range(0, not_used_questions.size() - 1)
	return q


func _update_probe_position() -> void:
	var probe_y_position: float = (probe_min_y_position + probe_max_y_position - probe_y_size)
	probe_y_position = probe_y_position - (probe_y_position * answered_questions / (total_questions + 1))
	$ParkerProbe.position.y = probe_y_position


func _update_question_controls(p_question: Question) -> void:
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
	not_used_questions.erase(current_question)
	print("current_question" + str(current_question))
	print("not_used_questions old = " + str(not_used_questions))
	print("_next_question erase c=" + str(current_question))


func _update_question():
	print("entered next question func. Old question" + str(current_question))
	print("answered_questions" + str(answered_questions))
	print("not_used_questions new = " + str(not_used_questions))
	_update_probe_position()
	_update_question_controls(question_collection.questions[current_question])


func _check_answer(p_question: Question, p_answer: int) -> bool:
	if p_question.correct_answer_index == p_answer:
		return true
	return false


func _correct_answer(p_correct: int) -> void:
	yield(get_tree().create_timer(waiting_time_to_show_answer), "timeout")
	_show_correct_answer(p_correct)
	print("answer correct! Answer = " + str(p_correct))
	yield(self, "button_animation_completed")
	_show_popup_correct()


func _wrong_answer(p_wrong: int, p_correct: int) -> void:
	yield(get_tree().create_timer(waiting_time_to_show_answer), "timeout")
	_show_wrong_answer(p_wrong)
	print("answer wrong! Answer = " + str(p_wrong)+" the correct was " + str(p_correct))
	_show_correct_answer(p_correct)
	yield(self, "button_animation_completed")
	_show_popup_wrong()


func _show_correct_answer(p_correct: int) -> void:
	var show := true
	if p_correct == 0:
		$btnChoice1.texture_normal = texture_correct
		yield(get_tree().create_timer(0.5), "timeout")
		for i in range(0, 10):
			if show:
				$btnChoice1.texture_normal = texture_correct
			else:
				$btnChoice1.texture_normal = texture_normal
			yield(get_tree().create_timer(blinking_time), "timeout")
			show = not show
			
	elif p_correct == 1:
		$btnChoice2.texture_normal = texture_correct
		yield(get_tree().create_timer(0.5), "timeout")
		for i in range(0, 10):
			if show:
				$btnChoice2.texture_normal = texture_correct
			else:
				$btnChoice2.texture_normal = texture_normal
			yield(get_tree().create_timer(blinking_time), "timeout")
			show = not show
				
	elif p_correct == 2:
		$btnChoice3.texture_normal = texture_correct
		yield(get_tree().create_timer(0.5), "timeout")
		for i in range(0, 10):
			if show:
				$btnChoice3.texture_normal = texture_correct
			else:
				$btnChoice3.texture_normal = texture_normal
			yield(get_tree().create_timer(blinking_time), "timeout")
			show = not show
	
	emit_signal("button_animation_completed")


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
	if can_click:
		var question: Question = question_collection.questions[current_question]
		if _check_answer(question, 0):
			_correct_answer(0)
		else:
			_wrong_answer(0, question.correct_answer_index)


func _on_btnChoice2_button_up():
	if can_click:
		var question: Question = question_collection.questions[current_question]
		if _check_answer(question, 1):
			_correct_answer(1)
		else:
			_wrong_answer(1, question.correct_answer_index)


func _on_btnChoice3_button_up():
	if can_click:
		var question: Question = question_collection.questions[current_question]
		if _check_answer(question, 2):
			_correct_answer(2)
		else:
			_wrong_answer(2, question.correct_answer_index)


func _on_btnExitWrong_button_up():
	can_click = true
	$PopUpWrong.visible = false
	for n in next_step_at_question:
		if n == answered_questions:
			print("old game step" + str(current_scene))
			_next_game_step()
			print("new game step" + str(current_scene))
			_start_current_scene()
			return
	print("calling _next_question")
	_next_question()
	_update_question()


func _on_btnExitCorrect_button_up():
	can_click = true
	$PopUpCorrect.visible = false
	for n in next_step_at_question:
		if n == answered_questions:
			print("old game step" + str(current_scene))
			_next_game_step()
			print("new game step" + str(current_scene))
			_start_current_scene()
			return
	print("calling _next_question")
	_next_question()
	_update_question()


func _next_game_step() -> void:
	current_scene += 1
	

func _hide_previous_scene() -> void:
	print("_hide_previous_scene")
	if current_scene - 1 >= 0:
		var the_s: MySceneCollection = scenes[current_scene - 1]
		var c_to_hide = the_s.controls_to_show_or_hide
		for np in c_to_hide:
			var node = get_node(np)
			node.visible = false

	
func _start_current_scene() -> void:
	print("entered _start_scene func Current scene" + str(current_scene))
	if current_scene + 1 <= scenes.size():
		
		print("calling _hide_previous_scene")
		_hide_previous_scene()
		
		var next_s: MySceneCollection = scenes[current_scene]
		
		match next_s.my_type:
			MySceneCollection.ESceneType.START_SCENE:
				print("entered START_SCENE")
				$StartScreen.visible = true
				
				$TextureRect.visible = false
				$lblQuestion.visible = false
				$lblChoice1.visible = false
				$lblChoice2.visible = false
				$lblChoice3.visible = false
				$btnChoice1.visible = false
				$btnChoice2.visible = false
				$btnChoice3.visible = false
				
			MySceneCollection.ESceneType.HISTORY:
				print("entered HISTORY")
				$History.visible = true
				
				$History.history = next_s.history_content
				
				$TextureRect.visible = false
				$lblQuestion.visible = false
				$lblChoice1.visible = false
				$lblChoice2.visible = false
				$lblChoice3.visible = false
				$btnChoice1.visible = false
				$btnChoice2.visible = false
				$btnChoice3.visible = false
				
				$btnNext.visible = true
				$lblNext.visible = true
				
			MySceneCollection.ESceneType.QUESTION:
				
				print("entered QUESTION")
				
				$btnNext.visible = false
				$lblNext.visible = false
				
				$History.visible = false
				
				$TextureRect.visible = true
				$lblQuestion.visible = true
				$lblChoice1.visible = true
				$lblChoice2.visible = true
				$lblChoice3.visible = true
				$btnChoice1.visible = true
				$btnChoice2.visible = true
				$btnChoice3.visible = true
				
				_next_question()
				_update_question()
				
			MySceneCollection.ESceneType.END_GAME:
				print("entered END_GAME")
				#$History.visible = true
				
				#$History.history = next_s.history_content
				
				$TextureRect.visible = false
				$lblQuestion.visible = false
				$lblChoice1.visible = false
				$lblChoice2.visible = false
				$lblChoice3.visible = false
				$btnChoice1.visible = false
				$btnChoice2.visible = false
				$btnChoice3.visible = false
				
				$btnNext.visible = false
				$lblNext.visible = false
				
				
		var c_to_show = next_s.controls_to_show_or_hide
		for np in c_to_show:
			var node = get_node(np)
			node.visible = true
			
		yield(get_tree().create_timer(0.5), "timeout")
		can_click = true


func _on_btnNext_button_up():
	if can_click:
		can_click = false
		print("calling _next_game_step")
		_next_game_step()
		_start_current_scene()


func _on_btnPrevious_button_up():
	if can_click:
		can_click = false
		
		print("_on_btnPrevious_button_up")
		print("current_scene = " + str(current_scene))
		var the_s: MySceneCollection = scenes[current_scene]
		var c_to_hide = the_s.controls_to_show_or_hide
		for np in c_to_hide:
			var node = get_node(np)
			node.visible = false
		
		var previous_s: MySceneCollection = scenes[current_scene - 1]
		
		match previous_s.my_type:
			MySceneCollection.ESceneType.START_SCENE:
				pass
			MySceneCollection.ESceneType.HISTORY:
				$History.history = previous_s.history_content
			MySceneCollection.ESceneType.QUESTION:
				pass
			MySceneCollection.ESceneType.END_GAME:
				pass
				
		var c_to_show = previous_s.controls_to_show_or_hide
		for np in c_to_show:
			var node = get_node(np)
			node.visible = true
		
		current_scene -= 1
		yield(get_tree().create_timer(0.5), "timeout")
		can_click = true
