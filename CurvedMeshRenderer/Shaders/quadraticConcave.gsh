#version 440 core

layout(triangles_adjacency) in;
layout(triangle_strip, max_vertices = 170) out;

uniform mat3 view;

//in float _coeffs[];
layout(location = 0) in vec2[] pos;

//out vec3 L;
//out vec3 coeffs1;
//out vec3 coeffs2;
layout(location = 0) out vec2 vec;

void generateCurve(vec2 A, vec2 B, vec2 C, int subdivision)
{
    float step;

    vec2 AB = B - A;
    vec2 BC = C - B;
    vec2 CA = A - C;

    float a = length(BC);
    float b = length(CA);
    float c = length(AB);

    vec2 prevPoint = A;
    float t;
    if (a + c - b < 1e-3)
    {
        step = 1.0f / float(subdivision);

        for (int i = 1; i <= subdivision; i++)
        {
            vec = pos[0];
            gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
            EmitVertex();

            vec = prevPoint;
            gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
            EmitVertex();

            t = i * step;
            vec = t * C + (1.0f - t) * A;
            gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
            EmitVertex();
            EndPrimitive();

            prevPoint = vec;
        }
        return;
    }

    float p = (a + b + c) / 2.0f;
    float s = sqrt(p * (p - a) * (p - b) * (p - c));
    a = a * a * dot(-AB, CA);
    b = b * b * dot(AB, -BC);
    c = c * c * dot(-CA, BC);
    s = 1.0f / (8.0 * s * s);
    vec2 O = (a * A + b * B + c * C) * s;

    float radius = length(A - O);

    vec2 OA = normalize(A - O);
    float angleA = acos(OA.x) * sign(OA.y);
    vec2 OB = normalize(B - O);
    vec2 OC = normalize(C - O);

    step = acos(dot(OA, OC)) * sign(OA.x * OB.y - OA.y * OB.x) / float(subdivision);
    for (int i = 1; i <= subdivision; i++)
    {
        vec = pos[0];
        gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();

        vec = prevPoint;
        gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();

        t = angleA + i * step;
        vec = O + radius * vec2(cos(t), sin(t));
        gl_Position = vec4((view * vec3(vec, 1.0f)).xy, 0.0f, 1.0f);
        EmitVertex();
        EndPrimitive();

        prevPoint = vec;
    }
}

void main()
{
    int subdivision = 18;
    generateCurve(pos[0], pos[1], pos[2], subdivision);
    generateCurve(pos[2], pos[3], pos[4], subdivision);
    generateCurve(pos[4], pos[5], pos[0], subdivision);
    //vec = pos[0];
    //gl_Position = vec4(vec, 0.0f, 1.0f);
    //EmitVertex();
    //
    //vec = pos[2];
    //gl_Position = vec4(vec, 0.0f, 1.0f);
    //EmitVertex();
    //
    //vec = pos[4];
    //gl_Position = vec4(vec, 0.0f, 1.0f);
    //EmitVertex();
    //EndPrimitive();
}