shader_type canvas_item;
uniform float hit_strength : hint_range(0.0, 1.0) = 0.0;
void fragment() {
 vec4 sprite = COLOR;
 sprite.rgb = mix(sprite.rgb, vec3(1.0, 0.90, 0.73), hit_strength);
 COLOR = sprite;
}
