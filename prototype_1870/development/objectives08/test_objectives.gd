extends SceneTree
const Rules=preload("res://development/objectives08/objective_rules.gd")
func _initialize():
 var cfg={"final_control":40,"duration":20,"military":40,"draw_margin":5,"major_margin":25,"major_loss_advantage":0.1,"major_requires_objective":true}
 var objectives=[{"id":"a","weight":1,"owner":0,"held":[18,0]}]
 var r=Rules.evaluate(objectives,[0.1,0.4],18,cfg)
 if r.get("level")!="major_win" or r.get("parts")!=[[40.0,20.0,16.0],[0.0,0.0,4.0]]:quit(1);return
 if Rules.evaluate(objectives,[0.1,0.4],18,cfg,1).get("level")!="major_loss":quit(1);return
 objectives[0].held=[18,1]
 if not Rules.evaluate(objectives,[0.1,0.4],18,cfg).has("error"):quit(1);return
 print("Objective candidate tests passed")
 quit(0)
