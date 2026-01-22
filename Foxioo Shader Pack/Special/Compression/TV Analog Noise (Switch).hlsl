/***********************************************************/

/* Shader author: Foxioo */
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
    bool __;
    float _PosX;
    float _PosY;    
    bool ___;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ____;
    bool _Blending_Mode;
    float _Mixing;
    float _Seed;
    bool _____;
	bool _Is_Pre_296_Build;
    bool ______;
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


float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453 + cos(_Pos.x * 34565.0)); }
float Fun_Noise(float2 _Pos)
{
    float2 _I = floor(_Pos + _Seed);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float3 Fun_NoiseGradient(float2 _UV)
{
    float2 _Offset = float2(12.9898, 78.233);
    float _Noise = Fun_Noise(_UV * 1.0 / float2(fPixelWidth, fPixelHeight) * 0.25);

    float _Noise1 = Fun_Noise((_UV * 1.5 / float2(fPixelWidth, fPixelHeight) * 0.25 + _Offset.yx) * 1.17);
    float _Noise2 = Fun_Noise((_UV * 1.5 / float2(fPixelWidth, fPixelHeight) * 0.25 - _Offset.xy) * 1.23);
    
    float3 _Render = lerp(_Noise1, _Noise2, _Noise) * 1.35;

    return _Render;
}

float3 Fun_NoiseSat(float3 _Color, float _Sat)
{
    float _Lum = dot(_Color, float3(0.299, 0.587, 0.114));

    return lerp(float3(_Lum, _Lum, _Lum), _Color, _Sat);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = (In.texCoord + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = 0.0;

            _Result.rgb = Fun_NoiseGradient(_UV);

                float4 _Render = _Blending_Mode ? lerp(_Render_Background, float4(_Result.rgb, 0), _Mixing) : lerp(_Render_Texture, float4(_Result.rgb, 0), _Mixing);
                _Render.a = _Render_Texture.a;
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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = (In.texCoord + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = 0.0;

            _Result.rgb = Fun_NoiseGradient(_UV);

                float4 _Render = _Blending_Mode ? lerp(_Render_Background, float4(_Result.rgb, 0), _Mixing) : lerp(_Render_Texture, float4(_Result.rgb, 0), _Mixing);
                _Render.a = _Render_Texture.a;
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}