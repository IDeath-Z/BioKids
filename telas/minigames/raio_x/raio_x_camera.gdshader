shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(1.0, 0.8, 0.2, 1.0);
uniform float edge_softness : hint_range(0.0, 0.5) = 0.4;
uniform float noise_amount : hint_range(0.0, 0.2) = 0.05;
uniform float noise_scale = 5.0;
uniform float noise_speed = 0.1;

float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 44758.5453123);
}

float fbm_noise(vec2 st) {
    float value = 0.0;
    float amplitude = 0.5;
    
    for (int i = 0; i < 4; i++) {
        value += amplitude * random(st);
        st *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}


void fragment() {
    vec2 noise_uv = UV * noise_scale + vec2(TIME * noise_speed);

    float noise = fbm_noise(noise_uv);

    vec2 dist_from_center = abs(UV - 0.5);
    float max_dist = max(dist_from_center.x, dist_from_center.y);
    float limit = edge_softness - (noise * noise_amount);
    float alpha = smoothstep(0.5, limit, max_dist);
    
    COLOR = vec4(glow_color.rgb, glow_color.a * alpha);
}