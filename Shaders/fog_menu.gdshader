shader_type canvas_item;

// This is your NoiseTexture2D.
uniform sampler2D fog_texture : hint_default_black;

// This will use the ColorRect's own color by default.
uniform vec4 fog_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);

// Controls how fast the fog moves.
uniform float scroll_speed = -0.05;

// Controls how far down the fade from the top goes.
uniform float fade_top_distance : hint_range(0.01, 1.0) = 0.4;


void fragment() {
    // 1. Create scrolling UVs
    vec2 scrolling_uv = UV;

    // --- THIS IS THE FIX ---
    // We use fract() to manually wrap the x-coordinate between 0.0 and 1.0.
    // This forces the texture to "repeat" or "tile" inside the shader code itself.
    // fract(-0.1) becomes 0.9, which is what we want.
    scrolling_uv.x = fract(scrolling_uv.x - TIME * scroll_speed);
    // ---------------------

    // 2. Sample the noise texture
    float noise_value = texture(fog_texture, scrolling_uv).r;

    // 3. Calculate the top fade
    float top_fade = smoothstep(0.0, fade_top_distance, UV.y);

    // 4. Set the final color
    COLOR = fog_color;
    COLOR.a *= noise_value * top_fade;
}