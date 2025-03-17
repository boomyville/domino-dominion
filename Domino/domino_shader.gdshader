	shader_type canvas_item;

	uniform vec4 outline_color : hint_color = vec4(1.0, 0.0, 0.0, 1.0); 
	uniform bool outline_enabled = false; 

	void fragment() {
	    vec2 pixel_size = TEXTURE_PIXEL_SIZE;
	    vec4 current = texture(TEXTURE, UV);
	    
	    if (outline_enabled) {
	        vec4 up = texture(TEXTURE, UV + vec2(0, -2.0 * pixel_size.y));
	        vec4 down = texture(TEXTURE, UV + vec2(0, 2.0 * pixel_size.y));
	        vec4 left = texture(TEXTURE, UV + vec2(-2.0 * pixel_size.x, 0));
	        vec4 right = texture(TEXTURE, UV + vec2(2.0 * pixel_size.x, 0));
	        
	        float outline = 0.0;
	        if (current.a < 0.5) {
	            outline = float(up.a > 0.5 || down.a > 0.5 || left.a > 0.5 || right.a > 0.5);
	        }
	        
	        COLOR = mix(current, outline_color, outline);
	    } else {
	        COLOR = current;
	    }
	}