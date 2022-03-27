#version 440 core

const float epsilon = 1e-6;

//in vec3 L;
//in vec3 coeffs1;
//in vec3 coeffs2;
layout(location = 0) in vec2 v;
layout(location = 1) in vec2 p1;
layout(location = 2) in vec2 p2;
layout(location = 3) in vec2 p3;
layout(location = 4) in vec2 p4;
layout(location = 5) in vec2 p5;
layout(location = 6) in vec2 p6;
layout(location = 7) in vec3 coeffs1;
layout(location = 8) in vec3 coeffs2;

uniform float minValue;
uniform float maxValue;
uniform vec4 minColor;
uniform vec4 maxColor;

out vec4 outColor;

float L1(vec2 vec)
{
	return 1.0f - vec.x - vec.y;
}
float L2(vec2 vec)
{
	return vec.x;
}
float L3(vec2 vec)
{
	return vec.y;
}

float phi1(vec2 vec)
{
	float l1 = L1(vec);
	return (2.0f * l1 - 1.0f) * l1;
}
float phi2(vec2 vec)
{
	float l2 = L2(vec);
	return (2.0f * l2 - 1.0f) * l2;
}
float phi3(vec2 vec)
{
	float l3 = L3(vec);
	return (2.0f * l3 - 1.0f) * l3;
}
float phi4(vec2 vec)
{
	float l1 = L1(vec);
	float l2 = L2(vec);
	return 4.0f * l1 * l2;
}
float phi5(vec2 vec)
{
	float l2 = L2(vec);
	float l3 = L3(vec);
	return 4.0f * l2 * l3;
}
float phi6(vec2 vec)
{
	float l1 = L1(vec);
	float l3 = L3(vec);
	return 4.0f * l1 * l3;
}

vec2 f(vec2 vec)
{
	return phi1(vec) * p1 + 
		   phi2(vec) * p3 + 
		   phi3(vec) * p5 + 
		   phi4(vec) * p2 + 
		   phi5(vec) * p4 + 
		   phi6(vec) * p6 - v;
}

void main()
{
	vec2 ksi_eta = vec2(0.3f, 0.3f);
	vec2 ksi_eps = vec2(epsilon, 0.0f);
	vec2 eta_eps = vec2(0.0f, epsilon);
	mat2 jacobi;
	vec2 base;
	for (int i = 0; i < 10; i++)
	{
		base = f(ksi_eta);
		jacobi[0][0] = (f(ksi_eta + ksi_eps).x - base.x) / epsilon;
		jacobi[1][0] = (f(ksi_eta + eta_eps).x - base.x) / epsilon;
		jacobi[0][1] = (f(ksi_eta + ksi_eps).y - base.y) / epsilon;
		jacobi[1][1] = (f(ksi_eta + eta_eps).y - base.y) / epsilon;
		jacobi = inverse(jacobi);

		ksi_eta -= jacobi * base;
	}

	float value = coeffs1.x * phi1(ksi_eta) + coeffs1.z * phi2(ksi_eta) + coeffs2.y * phi3(ksi_eta) +
				  coeffs1.y * phi4(ksi_eta) + coeffs2.x * phi5(ksi_eta) + coeffs2.z * phi6(ksi_eta);
	value = (value - minValue) / (maxValue - minValue);
	outColor = value * maxColor + (1.0f - value) * minColor;
}  