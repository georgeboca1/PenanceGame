shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float blur_size = 4.0;          // blur radius multiplier
uniform vec2 radius = vec2(0.5, 0.25);  // oval radius relative to rect (x,y)
uniform float softness = 0.1;           // edge feather (0..1)

void fragment() {
    // blur sample from background
    vec2 size = SCREEN_PIXEL_SIZE * blur_size;
    vec4 b = texture(SCREEN_TEXTURE, SCREEN_UV) * 0.36;
    b += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(size.x, 0.0)) * 0.16;
    b += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(size.x, 0.0)) * 0.16;
    b += texture(SCREEN_TEXTURE, SCREEN_UV + vec2(0.0, size.y)) * 0.16;
    b += texture(SCREEN_TEXTURE, SCREEN_UV - vec2(0.0, size.y)) * 0.16;

    // oval mask (1.0 inside, 0.0 outside)
    vec2 uvc = UV * 2.0 - 1.0;        // center UV at (0,0), range -1..1
    vec2 scaled = uvc / radius;
    float d = length(scaled);

    // smoothstep with increasing edges: edge0 < edge1
    float edge0 = 1.0 - softness;
    float edge1 = 1.0;
    float mask = 1.0 - smoothstep(edge0, edge1, d);

    // output blurred color inside oval, transparent outside
    COLOR = vec4(b.rgb, mask * b.a);
}
