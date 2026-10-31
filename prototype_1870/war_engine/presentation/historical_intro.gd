extends RefCounted
# Load the six pictures only when a new introduction is explicitly requested.
static func open(game):
    var box=game.modal_base(game.size.x,game.size.y)
    var view=load("res://intro_bd/intro.tscn").instantiate()
    view.host=game
    view.introduction_finished.connect(game.show_camp_choice,CONNECT_ONE_SHOT)
    view.menu_requested.connect(game.show_menu,CONNECT_ONE_SHOT)
    box.add_child(view)
    game.resized.connect(view._fit_host)
    view._fit_host()
