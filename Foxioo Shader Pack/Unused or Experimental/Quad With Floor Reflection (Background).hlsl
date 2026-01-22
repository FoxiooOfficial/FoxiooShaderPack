/***********************************************************/

/* Shader author: Foxioo and Adam Hawker (aka Sketchy / MuddyMole) */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float xA;
    float yA;
    float xB;
    float yB;
    float xC;
    float yC;
    float xD;
    float yD;
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
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

float3 Fun_Quad(float2 UV)
{
    float _xD = xD + 0.0001;

    float a = (xA - UV.x) * (yB - UV.y) - (xB - UV.x) * (yA - UV.y);
    float b = (xB - UV.x) * (yC - UV.y) - (xC - UV.x) * (yB - UV.y);
    float c = (xC - UV.x) * (yD - UV.y) - (_xD - UV.x) * (yC - UV.y);
    float d = (_xD - UV.x) * (yA - UV.y) - (xA - UV.x) * (yD - UV.y);

    //if (sign(a) == sign(b) && sign(b) == sign(c) && sign(c) == sign(d)) {

        float a1 = xA;
        float a2 = xB - xA;
        float a3 = _xD - xA;
        float a4 = xA - xB + xC - _xD;

        float b1 = yA;
        float b2 = yB - yA;
        float b3 = yD - yA;
        float b4 = yA - yB + yC - yD;

        float aa = a4 * b3 - a3 * b4;
        float bb = a4 * b1 - a1 * b4 + a2 * b3 - a3 * b2 + UV.x * b4 - UV.y * a4;
        float cc = a2 * b1 - a1 * b2 + UV.x*b2 - UV.y*a2;
        float det = sqrt(bb * bb - 4 * aa*cc);

        float m = (-bb + det)/(2 * aa);
        float l = (UV.x - a1 - a3 * m)/(a2 + a4 * m);

        return float3(l, m, 1);
    //}
    //else return 0;
}
PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

        float2 __In = frac(In.texCoord);
        float3 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, _In.xy) * In.Tint;
        if (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) _Render_Texture.a = 0;

    _In.y = 1 - (_In.y - 1.0);

    float4 _Render_Texture_Ref = S2D_Image.Sample(S2D_ImageSampler, _In.xy) * In.Tint;
        if (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) _Render_Texture_Ref.a = 0;

        _Render_Texture_Ref *= _In.y;

        float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, __In) * _Render_Texture_Ref;

    _Render_Texture = lerp(_Render_Texture, _Render_Texture_Ref + _Render_Background, _Render_Texture_Ref.a * _Mixing);

    Out.Color = _Render_Texture;
    
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

        float2 __In = frac(In.texCoord);
        float3 _In = Fun_Quad(In.texCoord);

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _In.xy)) * In.Tint;
        if (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) _Render_Texture.a = 0;

    _In.y = 1 - (_In.y - 1.0);

    float4 _Render_Texture_Ref = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _In.xy)) * In.Tint;
        if (_In.x <= 0.0 || _In.x >= 1.0 || _In.y <= 0.0 || _In.y >= 1.0) _Render_Texture_Ref.a = 0;

        _Render_Texture_Ref *= _In.y;

        float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, __In) * _Render_Texture_Ref;

    _Render_Texture = lerp(_Render_Texture, _Render_Texture_Ref + _Render_Background, _Render_Texture_Ref.a * _Mixing);

    _Render_Texture.rgb *= _Render_Texture.a;
    Out.Color = _Render_Texture;
    return Out;  
}
