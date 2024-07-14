shader_type canvas_item;

#define iTime TIME

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_nearest,repeat_disable;

uniform sampler2D iChannel1;
uniform vec2 param1 = vec2(0.3, 0.2);
uniform vec2 param2 = vec2(0.4, 0.7);
uniform vec2 param3 = vec2(0.3, 0.1);

void fragment()
{
    vec2 uv = UV;
    vec2 dist = vec2(0.0);
    dist += texture(iChannel1,fract(uv + vec2(iTime*0.2))).rr * param1;
    dist += texture(iChannel1,fract(uv + vec2(iTime*-0.1,iTime*-0.1))).rr * param2;
    dist += texture(iChannel1,fract(uv + vec2(iTime*-0.03,iTime*0.2))).rr * param3;	
	
	//Se pilla el fondo del la textura
	vec3 col = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	
	//Se transforma la parte oscure en blanca
    col += pow(dot(normalize(vec3(dist.x,1.0,dist.y)),vec3(0.0,1.0,0.0)),16.0);
	
	COLOR = vec4(col,1.0);
}