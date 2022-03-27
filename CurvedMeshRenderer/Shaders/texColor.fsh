#version 440 core

layout(location = 0) in vec2 uv;

uniform sampler2D tex;

out vec4 outColor;

void main()
{
    outColor = texture(tex, uv);
}