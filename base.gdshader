shader_type canvas_item;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    
    tex_color.rgb = vec3(1.0) - tex_color.rgb;

    COLOR = vec4(tex_color.rgb, tex_color.a);
}