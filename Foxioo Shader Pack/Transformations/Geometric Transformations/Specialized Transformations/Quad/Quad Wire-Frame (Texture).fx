/***********************************************************/

/* Autor shader: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.0 (16.07.2025) */
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

    float   xA;
    float   yA;
    float   xB;
    float   yB;
    float   xC;
    float   yC;
    float   xD;
    float   yD;

    float   fPixelWidth, fPixelHeight;

    float   _Size,
            _Mixing,
            _ScaleDeformX, _ScaleDeformY;

    float4  _Color;

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

    float4 _Render_Texture = tex2D(S2D_Image, _In);
    float4 _Render;

    float2 _Pixel = (fPixelWidth / _ScaleDeformX, fPixelHeight / _ScaleDeformY) * _Size;
        bool _Edge =    abs(_In.x) < _Pixel.x || abs(_In.y) < _Pixel.y ||
                        abs(_In.x - 1.0) < _Pixel.x || abs(_In.y - 1.0) < _Pixel.y ||
                        abs(_In.x - _In.y) < _Pixel.x || abs((_In.x + _In.y) - 1.0) < _Pixel.y;

    if (_Edge && any(_In > 0.0 && _In < 1.0)) _Render = float4(_Color.r, _Color.g, _Color.b, 1);
    else _Render = 0.0;

    _Render = lerp(_Render_Texture, _Render, _Mixing);

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } };