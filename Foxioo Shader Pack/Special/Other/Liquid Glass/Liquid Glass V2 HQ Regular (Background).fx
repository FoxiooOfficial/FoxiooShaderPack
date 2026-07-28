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

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

#define GOLDEN_ANGLE    2.39996323
#define PI              3.14159265359

static const int SAMPLES_INNER  = 16;
static const int SAMPLES_BLUR   = 128;
static const float _Sigma       = 40.0;
static const float _Mul         = 0.7;
static const float _Radius      = 16.0;
static const float _Size        = 24.0;
static const float _Liquid      = 0.05;


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

        float _Weight = exp(-pow(_Rad * _Radius / 4.0, 2.0) * _SigmaULTRA);

        _Result += tex2D(S2D_Background, UV.xy + _Rot * _Pixel).rgb * _Weight;
        _Sum += _Weight;
    }

    _Result /= _Sum;
    return _Result;
}

float Fun_Inner(float2 In, float2 _Pixel)
{
    float _Alpha = 0.0, _Idx = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5) * _Size;
            
            _Offset *= _Pixel;
            
            _Alpha += tex2D(S2D_Image, In + _Offset).a;
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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = 0.0;
        float2 _Pixel = float2(fPixelWidth, fPixelHeight);
            
            float2 _UV = In;
            //_UV.z = max(abs(_UV.x - 0.5), abs(_UV.y - 0.5)) * 2.0;
            //_UV.z = 1.0 - pow(_UV.z, 10.0);

            _UV = Fun_Mirror(_UV);

            float _Lum = dot(_Render_Texture.rgb, float3(0.212, 0.715, 0.072));
            float _Mirror = Fun_Inner(_UV, _Pixel);
            float _MirrorCopy = _Mirror;

                _Mirror *= 0.5 + (pow(_Lum, 6.0) / 6.0) * 0.5;
                float2 _Off = Fun_Mirror(_UV + ((_UV - 0.5) / max(0.01, _Mirror)) * _Liquid);

                _Result.rgb = Fun_Blur(_Off, _Pixel);
                //_Result.rgb = lerp(float3(0.3, 0.3, 0.3), _Result.rgb, 0.9);

            _Result.rgb += pow(abs(_Result.rgb * (1.0 - _MirrorCopy)), 1.5) * 2.0;
            _Result.rgb = lerp(_Result.rgb + normalize(_Result.rgb), clamp(_Render_Texture.rgb * 0.55 + 0.12, 0.0, 1.0), _Mul);
            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 Main(); } }
