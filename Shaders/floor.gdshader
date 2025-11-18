shader_type canvas_item;

uniform mat4 world_matrix;
uniform vec2 tile_size_in_world_units; // e.g., vec2(64.0, 64.0)

// These can be set from the script or left as constants in the shader
uniform bool enable_flip_h = true;
uniform bool enable_flip_v = true;
uniform bool enable_rotation = true; // For 0, 90, 180, 270 degree rotations

varying vec2 world_pos;

// --- Helper Functions for "Randomness" based on position ---
// Simple hash function to generate a pseudo-random float from a 2D integer vector
float hash21(vec2 p) {
    p = fract(p * vec2(123.45, 678.90));
    p += dot(p, p + 45.67);
    return fract(p.x * p.y);
}

// Another hash for 0-3 integer random number
float hash21_int(vec2 p) {
    return floor(mod(hash21(p) * 10.0, 4.0)); // Gives 0, 1, 2, or 3
}
// -----------------------------------------------------------


void vertex() {
	world_pos = (world_matrix * vec4(VERTEX, 0.0, 1.0)).xy;
}

void fragment() {
    // Determine the integer grid cell this pixel belongs to
    // This gives us the "seed" for our randomness for this tile
    vec2 tile_grid_id = floor(world_pos / tile_size_in_world_units);

    // Calculate base UV (before any randomization)
    vec2 base_uv = fract(world_pos / tile_size_in_world_units);

    vec2 final_uv = base_uv;

    // --- Apply Random Flips ---
    if (enable_flip_h) {
        float r_h = hash21(tile_grid_id); // Get a random value for this tile
        if (r_h > 0.5) { // 50% chance to flip horizontally
            final_uv.x = 1.0 - final_uv.x;
        }
    }

    if (enable_flip_v) {
        float r_v = hash21(tile_grid_id + vec2(1.0, 0.0)); // Use a slightly different seed for v-flip
        if (r_v > 0.5) { // 50% chance to flip vertically
            final_uv.y = 1.0 - final_uv.y;
        }
    }

    // --- Apply Random Rotation (0, 90, 180, 270 degrees) ---
    if (enable_rotation) {
        float r_rot = hash21_int(tile_grid_id + vec2(2.0, 0.0)); // Use another seed

        // Perform rotation around the center of the UV (0.5, 0.5)
        vec2 rotated_uv = final_uv - vec2(0.5); // Translate to origin

        if (r_rot == 1.0) { // Rotate 90 degrees
            rotated_uv = vec2(-rotated_uv.y, rotated_uv.x);
        } else if (r_rot == 2.0) { // Rotate 180 degrees
            rotated_uv = -rotated_uv;
        } else if (r_rot == 3.0) { // Rotate 270 degrees
            rotated_uv = vec2(rotated_uv.y, -rotated_uv.x);
        }

        final_uv = rotated_uv + vec2(0.5); // Translate back
    }

    COLOR = texture(TEXTURE, final_uv);
}