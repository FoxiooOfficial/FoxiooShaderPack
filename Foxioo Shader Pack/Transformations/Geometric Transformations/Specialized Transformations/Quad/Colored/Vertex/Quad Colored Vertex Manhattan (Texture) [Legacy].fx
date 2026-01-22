/***********************************************************/

/* Shader author: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.1 (18.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;

    AddressU = Border;
    AddressV = Border;

    BorderColor = float4(0, 0, 1, 0);
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;

    float4 _ColorA;
    float4 _ColorB;
    float4 _ColorC;
    float4 _ColorD;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Quad(float2 UV)
{
    float a = (xA - UV.x) * (yB - UV.y) - (xB - UV.x) * (yA - UV.y);
    float b = (xB - UV.x) * (yC - UV.y) - (xC - UV.x) * (yB - UV.y);
    float c = (xC - UV.x) * (yD - UV.y) - (xD - UV.x) * (yC - UV.y);
    float d = (xD - UV.x) * (yA - UV.y) - (xA - UV.x) * (yD - UV.y);

    if (sign(a)==sign(b) && sign(b)==sign(c) && sign(c)==sign(d))
    {
        float a1 = xA;
        float a2 = xB - xA;
        float a3 = xD - xA;
        float a4 = xA - xB + xC - xD;

        float b1 = yA;
        float b2 = yB - yA;
        float b3 = yD - yA;
        float b4 = yA - yB + yC - yD;

        float aa = a4 * b3 - a3 * b4;
        float bb = a4 * b1 - a1 * b4 + a2 * b3 - a3 * b2 + UV.x * b4 - UV.y * a4;
        float cc = a2 * b1 - a1 * b2 + UV.x * b2 - UV.y * a2;

            float eps = 1e-6;
            float m;

                if (abs(aa) < eps) { m = -cc / bb; }
                else
                {
                    float det = sqrt(bb*bb - 4.0*aa*cc);
                    m = (-bb + det) / (2.0 * aa);
                }

        float denom = a2 + a4 * m;
        float l = (UV.x - a1 - a3 * m) / denom;

        return float2(l, m);
    }
    else return -1;

}


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{  
    float2 _In = Fun_Quad(In);

        float _T0 = max(abs(_In.x), abs(_In.y));
        float _T1 = max(abs(1.0 - _In.x), abs(_In.y));
        float _T2 = max(abs(1.0 - _In.x), abs(1.0 - _In.y));
        float _T3 = max(abs(_In.x), abs(1.0 - _In.y));

        float _wA = 1.0 - _T0;
        float _wB = 1.0 - _T1;
        float _wC = 1.0 - _T2;
        float _wD = 1.0 - _T3;

            _wA = max(0, _wA);
            _wB = max(0, _wB);
            _wC = max(0, _wC);
            _wD = max(0, _wD);

        float _Sum = _wA + _wB + _wC + _wD;

        float4 _Render = float4((_wA * _ColorA.xyz + _wB * _ColorB.xyz + _wC * _ColorC.xyz + _wD * _ColorD.xyz) / _Sum, tex2D(S2D_Image, _In).a);

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } };