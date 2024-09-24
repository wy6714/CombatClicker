shader_type canvas_item;

uniform float speedX = 0.1;
uniform float speedY = -0.1;

void vertex() {
	UV.x += TIME * speedX;
	UV.y += TIME * speedY;
}

