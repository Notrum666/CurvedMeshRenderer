#version 440 core

layout(triangles_adjacency) in;
layout(line_strip, max_vertices = 170) out;

uniform mat3 view;

layout(location = 0) in vec2[] v;
layout(location = 1) in float[] coeff;

//out vec3 L;
//out vec3 coeffs1;
//out vec3 coeffs2;
layout(location = 0) out vec2 _v;

void generateCurve(vec2 A, vec2 B, vec2 C, int subdivision)
{
    float step = 1.0f / float(subdivision);
    float t;
    for (int i = 0; i < subdivision; i++)
    {
        t = i * step;
        _v = (1.0f - 2.0f * t) * (1.0f - t) * A +
              4.0f * t * (1.0f - t) * B +
             (2.0f * t - 1.0f) * t * C;
        gl_Position = vec4((view * vec3(_v, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();
    }
}

void main()
{
    int subdivision = 4;

    generateCurve(v[0], v[1], v[2], subdivision);
    generateCurve(v[2], v[3], v[4], subdivision);
    generateCurve(v[4], v[5], v[0], subdivision);
    _v = v[0];
    gl_Position = vec4((view * vec3(_v, 1.0f)).xy, 0.0f, 1.0f);
    EmitVertex();
    EndPrimitive();
}