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
    bool _Blending_Mode;
    float _Mixing;    
    float _Seed;
    float _PointX;
    float _PointY;
    float _Speed;
    float4 _Color;
    float _LineLength;
    float _Softness;
    float _Weirdness;
    float _Radius;
    float _Freq;
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

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos, float2 _Ran)

{       float _A = Fun_Hash21(floor(_Pos * _Ran + float2(0.0, 0.0) + _Seed) / _Ran);
        float _B = Fun_Hash21(floor(_Pos * _Ran + float2(1.0, 0.0) + _Seed) / _Ran);
        float _C = Fun_Hash21(floor(_Pos * _Ran + float2(0.0, 1.0) + _Seed) / _Ran);
        float _D = Fun_Hash21(floor(_Pos * _Ran + float2(1.0, 1.0) + _Seed) / _Ran);

    float2 _Smooth = smoothstep((0.0), (1.0), (_Pos * _Ran) % 1.0);
    return lerp(lerp(_A, _B, _Smooth.y), lerp(_C, _D, _Smooth.y), _Smooth.x);
}

float Fun_Noise(float2 _Value)
{
    float _Sum = 0.0;

        for (int i = 1; i < 6; i++)
        {
            float _Pow = 2.0 * pow(2.0, i);
            _Sum += Fun_Noise(_Value + float2(i, i), float2(_Pow, _Pow)) / pow(2.0, i);
        }

    return _Sum;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _UV = (In.texCoord - float2(_PointX, _PointY)) * 2.0;
    float2 _UVZoom = float2(    _Weirdness * length(_UV) + _Speed,    _Freq * atan2(_UV.y, _UV.x) );

            float _Noise = Fun_Noise(_UVZoom);
            _Noise = length(_UV) - _Radius - _LineLength * (_Noise - 0.5);
            _Noise = smoothstep(-_Softness, _Softness, _Noise);

        float4 _Result;

        _Result.rgb = lerp(_Render.rgb, _Color.rgb, _Mixing * _Noise * _Render_Texture.a);
        _Result.a = _Render_Texture.a;

    Out.Color = _Result;
    
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

    float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _UV = (In.texCoord - float2(_PointX, _PointY)) * 2.0;
    float2 _UVZoom = float2(    _Weirdness * length(_UV) + _Speed,    _Freq * atan2(_UV.y, _UV.x) );

            float _Noise = Fun_Noise(_UVZoom);
            _Noise = length(_UV) - _Radius - _LineLength * (_Noise - 0.5);
            _Noise = smoothstep(-_Softness, _Softness, _Noise);

        float4 _Result;

        _Result.rgb = lerp(_Render.rgb, _Color.rgb, _Mixing * _Noise * _Render_Texture.a);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Render_Texture.a;

    Out.Color = _Result;
    return Out;
}