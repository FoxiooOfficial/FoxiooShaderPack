/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

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
    float _Mul;
    float _Radius;
    float _Size;
    float _Liquid;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : SV_POSITION;
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

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

#define GOLDEN_ANGLE    2.39996323
#define PI              3.14159265359

static const int SAMPLES_INNER  = 16; 
static const int SAMPLES_BLUR   = 128;
static const float _Sigma       = 40.0;

float Fun_Hash12(float2 _UV)
{
    float3 _Pos = frac(float3(_UV.xyx) * 0.103116);
    _Pos += dot(_Pos, _Pos.yzx + 33.333);
    return frac((_Pos.x + _Pos.y) * _Pos.z);
}

float3 Fun_Blur(float2 UV, float2 _Pixel)
{
    float _SigmaULTRA = 1.0 / (2.0 * _Sigma * _Sigma);

    float _Angle = Fun_Hash12(UV.xy) * 2.0 * PI;
    float _Sin, _Cos;
    sincos(_Angle, _Sin, _Cos);

    float3 _Result = 0.0;
    float _Sum = 0.0;

    for(int i = 0; i < SAMPLES_BLUR; i++)
    {
        float _Rad = sqrt((i + 0.5) / SAMPLES_BLUR); 
        float _Thr = i * GOLDEN_ANGLE;

            float2 _Off;
            sincos(_Thr, _Off.x, _Off.y);
            _Off *= _Rad * _Radius; 
                    
            float2 _Rot = float2
            (
                _Cos * _Off.x - _Sin * _Off.y,
                _Sin * _Off.x + _Cos * _Off.y
            );

        float _Weight = exp(-pow(_Rad * _Radius, 2.0) * _SigmaULTRA);

        _Result += S2D_Background.Sample(S2D_BackgroundSampler, UV.xy + _Rot * _Pixel).rgb * _Weight;
        _Sum += _Weight;
    }

    _Result /= _Sum;
    return _Result;
}

float Fun_Inner(float2 In, float2 _Pixel, float _Tint)
{
    float _Alpha = 0.0, _Idx = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5) * _Size;
            
            _Offset *= _Pixel;
            
            _Alpha += S2D_Image.Sample(S2D_ImageSampler, In + _Offset).a * _Tint;
            _Idx += 1.0;
        }
    }
    
    _Alpha /= _Idx;

    return _Alpha;
}

float2 Fun_Mirror(float2 In)
{
    return 1.0 - abs(frac(In / 2.0) * 2.0 - 1.0);
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Texture_NT = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord), _Premultiplied);
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = 0.0;
        float2 _Pixel = float2(fPixelWidth, fPixelHeight);
            
            float2 _UV = In.texCoord;
            //_UV.z = max(abs(_UV.x - 0.5), abs(_UV.y - 0.5)) * 2.0;
            //_UV.z = 1.0 - pow(_UV.z, 10.0);

            _UV = Fun_Mirror(_UV);

            float _Lum = dot(_Render_Texture_NT.rgb, float3(0.212, 0.715, 0.072));
            float _Mirror = Fun_Inner(_UV, _Pixel, In.Tint.a);
            float _MirrorCopy = _Mirror;

                _Mirror *= pow(_Lum, 6.0);

            float2 _Off = Fun_Mirror(_UV + ((_UV - 0.5) / max(0.01, _Mirror)) * _Liquid);

                _Result.rgb = Fun_Blur(_Off, _Pixel);
                _Result.rgb = lerp(float3(0.3, 0.3, 0.3), _Result.rgb, 0.9);

            _Result.rgb += saturate(smoothstep(0.3, 0.6, _Mirror + abs(1.4 - _MirrorCopy))) * _Off.x * _Off.y * 0.5;
            _Result.rgb *= lerp(1.0, _Render_Texture.rgb * _Lum, _Mul);
            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
