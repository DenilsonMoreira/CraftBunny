extends RefCounted
## Authored palm centers in each 362x362 source cell; never screen guesses.
const HANDS := {
 "idle":[Vector2(242,256),Vector2(242,253),Vector2(242,252),Vector2(242,250),Vector2(241,249),Vector2(243,251),Vector2(243,251),Vector2(243,251),Vector2(242,256),Vector2(243,256),Vector2(243,257),Vector2(242,255)],
 "run":[Vector2(256,251),Vector2(260,251),Vector2(257,252),Vector2(244,268),Vector2(252,254),Vector2(252,233),Vector2(261,223),Vector2(258,239),Vector2(251,256),Vector2(254,254),Vector2(248,264),Vector2(241,267)],
 "jump":[Vector2(243,258),Vector2(244,261),Vector2(243,262),Vector2(239,246),Vector2(242,237),Vector2(244,228),Vector2(245,217),Vector2(242,211),Vector2(245,214),Vector2(244,209),Vector2(245,204),Vector2(244,199)],
 "fall":[Vector2(240,251),Vector2(240,250),Vector2(241,251),Vector2(241,252),Vector2(240,252),Vector2(240,252),Vector2(241,252),Vector2(241,252),Vector2(241,252),Vector2(240,252),Vector2(241,253),Vector2(241,253)],
 "dash":[Vector2(243,257),Vector2(242,258),Vector2(244,266),Vector2(245,262),Vector2(254,244),Vector2(252,247),Vector2(244,247),Vector2(244,246),Vector2(245,256),Vector2(245,258),Vector2(243,258),Vector2(242,258)],
 "switch":[Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(241,255),Vector2(240,255)],
 # Both paws support the scarf: tool is tucked behind the satchel, not in air.
 "glide":[Vector2(174,280),Vector2(176,278),Vector2(179,279),Vector2(179,278),Vector2(172,283),Vector2(175,285),Vector2(175,285),Vector2(177,286),Vector2(173,283),Vector2(175,284),Vector2(176,282),Vector2(177,281)]
}
const RUN_ANGLES := [0.0,-.03,.02,.13,.08,-.05,-.12,-.06,.03,.07,.12,.08]
const DASH_ANGLES := [-.03,0.0,.04,.10,.17,.18,.17,.13,.09,.04,.0,-.03]
const TOOL_ANGLES := [.90,.75,.75,.90]
static func angle(state: String,index: int) -> float:
 if state=="run": return RUN_ANGLES[index]
 if state=="dash": return DASH_ANGLES[index]
 return 0.0
