shader_type canvas_item;
render_mode unshaded;

void fragment() {
    // Mostra a textura do próprio TextureRect.
    COLOR = texture(TEXTURE, UV);
}
