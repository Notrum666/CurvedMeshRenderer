#version 440 core
layout(location = 0) in vec2 v;
layout(location = 1) in float coeff;

//out float _coeff;
layout(location = 0) out vec2 pos;

void main()
{
    pos = v;
    gl_Position = vec4(pos, 0.0f, 1.0f);
    //_coeff = coeff;
}