#version 440 core

//in vec3 L;
//in vec3 coeffs1;
//in vec3 coeffs2;
layout(location = 0) in vec2 pos;

uniform float minValue;
uniform float maxValue;
uniform vec3 minColor;
uniform vec3 maxColor;

out vec4 outColor;

void main()
{
	//float value = coeffs1.x * L[0] * (2f * L[0] - 1f) + coeffs1.y * L[1] * (2f * L[1] - 1f) + coeffs1.z * L[2] * (2f * L[2] - 1f) +
	//			  4f * (coeffs2.x * L[0] * L[1] + coeffs2.y * L[1] * L[2] + coeffs2.z * L[0] * L[2]);
	//value = max(0f, min(1f, (value - minValue) / (maxValue - minValue)));
	//outColor = value * vec4(maxColor, 1f) + (1f - value) * vec4(minColor, 1f);
	outColor = vec4(0.5f, 0.5f, 0.5f, 1.0f);
}  