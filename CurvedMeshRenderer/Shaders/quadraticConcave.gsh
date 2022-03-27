#version 440 core

layout(triangles_adjacency) in;
layout(triangle_strip, max_vertices = 170) out;

uniform mat3 view;

//in float _coeffs[];
layout(location = 0) in vec2[] v;
layout(location = 1) in float[] coeffs;

//out vec3 L;
//out vec3 coeffs1;
//out vec3 coeffs2;
layout(location = 0) out vec2 _v;
layout(location = 1) out vec2 _p1;
layout(location = 2) out vec2 _p2;
layout(location = 3) out vec2 _p3;
layout(location = 4) out vec2 _p4;
layout(location = 5) out vec2 _p5;
layout(location = 6) out vec2 _p6;
layout(location = 7) out vec3 _coeffs1;
layout(location = 8) out vec3 _coeffs2;

void generateCurve(vec2 A, vec2 B, vec2 C, int subdivision)
{
    float step = 1.0f / float(subdivision);
    vec2 prevPoint = A;
    float t;
    for (int i = 1; i <= subdivision; i++)
    {
        _v = v[0];
        gl_Position = vec4((view * vec3(_v, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();

        _v = prevPoint;
        gl_Position = vec4((view * vec3(_v, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();

        t = i * step;
        _v = (1.0f - 2.0f * t) * (1.0f - t) * A +
              4.0f * t * (1.0f - t) * B +
             (2.0f * t - 1.0f) * t * C;
        gl_Position = vec4((view * vec3(_v, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();
        EndPrimitive();

        prevPoint = _v;
    }
}

void main()
{
    int subdivision = 4;

    _p1 = v[0];
    _p2 = v[1];
    _p3 = v[2];
    _p4 = v[3];
    _p5 = v[4];
    _p6 = v[5];
    _coeffs1 = vec3(coeffs[0], coeffs[1], coeffs[2]);
    _coeffs2 = vec3(coeffs[3], coeffs[4], coeffs[5]);
    generateCurve(v[0], v[1], v[2], subdivision);
    generateCurve(v[2], v[3], v[4], subdivision);
    generateCurve(v[4], v[5], v[0], subdivision);
}