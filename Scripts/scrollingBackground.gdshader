shader_type canvas_item;

uniform float speedX = 0.1;
uniform float speedY = -0.1;

uniform float rushSpeedX = 9.9;
uniform float rushSpeedY = -9.9;

uniform float rushFlag = 0.0;

void vertex() {
	
	//Rush is NOT on
	if(rushFlag <= 0.5){
		UV.x += TIME * speedX;
		UV.y += TIME * speedY;
	//Rush IS ON
	}else{
		UV.x += TIME * rushSpeedX;
		UV.y += TIME * rushSpeedY;
	}
}

