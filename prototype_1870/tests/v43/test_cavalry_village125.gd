extends "res://tests/v43/test_cavalry.gd"
const Store=preload("res://war_engine/platform/save_store.gd")
func _initialize():
 for side in [0,1]:
  var e=fixture(side,"village")
  check(is_equal_approx(e.assault_power(4,true),500.0),"400 cavalry village defence 1.25 both camps")
  check(is_equal_approx(e.attack_power_against(0,4),352.0),"charge attack unchanged")
  check(e.assault_cost(0)==8,"charge still 2 AP")
  e.state.units[4].morale="shaken"
  check(is_equal_approx(e.assault_power(4,true),375.0),"existing disorder factor retained")
  e.state.units[4].morale="routed"
  check(is_equal_approx(e.assault_power(4,true),125.0),"existing rout factor retained")
  e.state.units[4].morale="stable";e.state.units[4].weapon="dreyse" if side==0 else "chassepot";e.state.units[4].formation="line"
  check(is_equal_approx(e.assault_power(4,true),600.0),"400 infantry village still 1.50")
  e=fixture(side,"plain")
  check(is_equal_approx(e.assault_power(4,true),400.0),"plain cavalry unchanged")
  e=fixture(side,"village");e.pack.unit_types.cavalry.erase("terrain_assault_defence")
  check(is_equal_approx(e.assault_power(4,true),600.0),"archived profile without override retains 1.50")
 var old_raw=FileAccess.get_file_as_string("res://tests/v43/fixtures/v43_before_cavalry_village125.json");var old=Rules.new(JSON.parse_string(old_raw));old.new_game(0,"hard")
 var legacy=Store.new("user://v436.json",old_raw.sha256_text());check(legacy.save_game(old),"physical previous-version save")
 var raw=FileAccess.get_file_as_string("res://packs/1870/regimental_trial_v43.json");var current=Rules.new(JSON.parse_string(raw));var slot=Store.new(legacy.path,raw.sha256_text(),current.pack.save_migrations);var before=FileAccess.get_file_as_bytes(legacy.path)
 check(slot.load_game(current) and current.validate(current.state),"previous fingerprint accepted by new scenario")
 check(same_persisted_state(current.state,old.state),"migration preserves complete game state")
 check(FileAccess.get_file_as_bytes(legacy.path)==before,"loading does not rewrite original")
 print("V43.7 CAVALRY VILLAGE ",checks-failures,"/",checks);quit(1 if failures else 0)

func same_persisted_state(actual: Dictionary,original: Dictionary) -> bool:
 var copy=actual.duplicate(true)
 if copy.get("objective_layout","")!="v4312":return false
 copy.erase("objective_layout")
 return JSON.parse_string(JSON.stringify(copy))==JSON.parse_string(JSON.stringify(original))
