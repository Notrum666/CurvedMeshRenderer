#version 440 core

layout(location = 0) out vec2 uv;

void main()
{
    float x = float(((uint(gl_VertexID)+2u) / 3u) % 2u);
    float y = float(((uint(gl_VertexID)+1u) / 3u) % 2u);

    uv = vec2(x, y);
    gl_Position = vec4(uv * 2.0f - 1.0f, 0.0f, 1.0f);
}