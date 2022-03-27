#version 440 core

layout(location = 0) in vec2 v;

uniform vec4 color;

out vec4 outColor;

void main()
{
    outColor = color;
}