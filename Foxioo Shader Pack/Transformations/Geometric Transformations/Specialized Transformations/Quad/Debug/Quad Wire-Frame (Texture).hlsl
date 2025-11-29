/***********************************************************/

/* Autor shader: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Size;
    float _ScaleDeformX;
    float _ScaleDeformY;
    float4 _Color;
    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;
    bool __;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Quad(float2 UV)
{
    float a = (xA - UV.x) * (yB - UV.y) - (xB - UV.x) * (yA - UV.y);
    float b = (xB - UV.x) * (yC - UV.y) - (xC - UV.x) * (yB - UV.y);
    float c = (xC - UV.x) * (yD - UV.y) - (xD - UV.x) * (yC - UV.y);
    float d = (xD - UV.x) * (yA - UV.y) - (xA - UV.x) * (yD - UV.y);

    if (sign(a) == sign(b) && sign(b) == sign(c) && sign(c) == sign(d))
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

        if (abs(aa) < eps)
        {
            m = -cc / bb;
        }
        else
        {
            float det = sqrt(bb * bb - 4.0 * aa * cc);
            m = (-bb + det) / (2.0 * aa);
        }

        float denom = a2 + a4 * m;
        float l = (UV.x - a1 - a3 * m) / denom;

        return float2(l, m);
    }
    else return float2(-1.0, -1.0);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float2 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _In.xy) * In.Tint;
    float4 _Render;

    float2 _Pixel = float2(fPixelWidth / _ScaleDeformX, fPixelHeight / _ScaleDeformY) * _Size;
        bool _Edge =    abs(_In.x) < _Pixel.x || abs(_In.y) < _Pixel.y ||
                        abs(_In.x - 1.0) < _Pixel.x || abs(_In.y - 1.0) < _Pixel.y ||
                        abs(_In.x - _In.y) < _Pixel.x || abs((_In.x + _In.y) - 1.0) < _Pixel.y;

    if (_Edge && any(_In > 0.0 && _In < 1.0)) _Render = float4(_Color.r, _Color.g, _Color.b, 1);
    else _Render = 0.0;

    float _Border = (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) ? 0.0 : 1.0;

    _Render = lerp(_Render_Texture, _Render, _Mixing) * _Border;

    Out.Color = _Render;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float2 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _In.xy)) * In.Tint;
    float4 _Render;

    float2 _Pixel = float2(fPixelWidth / _ScaleDeformX, fPixelHeight / _ScaleDeformY) * _Size;
        bool _Edge =    abs(_In.x) < _Pixel.x || abs(_In.y) < _Pixel.y ||
                        abs(_In.x - 1.0) < _Pixel.x || abs(_In.y - 1.0) < _Pixel.y ||
                        abs(_In.x - _In.y) < _Pixel.x || abs((_In.x + _In.y) - 1.0) < _Pixel.y;

    if (_Edge && any(_In > 0.0 && _In < 1.0)) _Render = float4(_Color.r, _Color.g, _Color.b, 1);
    else _Render = 0.0;

    float _Border = (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) ? 0.0 : 1.0;

    _Render = lerp(_Render_Texture, _Render, _Mixing) * _Border;

    _Render.rgb *= _Render.a;
    Out.Color = _Render;
    return Out;
}
