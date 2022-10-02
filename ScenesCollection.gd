extends Resource
class_name MySceneCollection

enum ESceneType { START_SCENE, QUESTION, HISTORY, VIDEO, END_GAME}

export(ESceneType) var my_type: int
export var history_content: String
export var controls_to_show_or_hide: Array
