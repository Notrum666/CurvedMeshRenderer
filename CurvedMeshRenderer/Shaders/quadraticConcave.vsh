#version 440 core
layout(location = 0) in vec2 v;
layout(location = 1) in float coeff;

//out float _coeff;
layout(location = 0) out vec2 _v;
layout(location = 1) out float _coeff;

void main()
{
    _v = v;
    gl_Position = vec4(_v, 0.0f, 1.0f);
    _coeff = coeff;
}