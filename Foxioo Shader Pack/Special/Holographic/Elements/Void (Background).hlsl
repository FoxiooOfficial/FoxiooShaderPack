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
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Border;
    bool __;

};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
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

static const int SAMPLES_INNER  = 12;
#define PIXELSIZE               float2(fPixelWidth, fPixelHeight)

float Fun_Inner(float2 In)
{
    float _Alpha = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5);
            float _Render = S2D_Image.Sample(S2D_ImageSampler, In + _Offset * _Border * PIXELSIZE).a;

            _Alpha += _Render;
        }
    }
    return _Alpha / float(SAMPLES_INNER * SAMPLES_INNER);
}

float Fun_Lum (float4 _Result) { 
    return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b) * _Result.a;
}

float Fun_Random(float2 In) {
    return frac(sin(dot(In, float2(12.9898, 78.233))) * 43758.5453);
}

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

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord * 1.0);

    float _Rand = Fun_Random(In.texCoord + _Render_Texture.rb + _Render_Texture.bg + _Render_Background.rg + _Render_Background.br);
    float _Lum = Fun_Lum(_Render_Texture);
    float _Lum_Background = Fun_Lum(_Render_Background);

        float3 _Space = lerp(float3(0.0, 0.0, 0.0), float3(0.15, 0.05, 0.25), _Lum);
        _Space += (_Space * (S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord + tan(_Lum) * _Lum * 0.25 - tan(_Lum_Background) * 0.25 - _Rand).rgb) * 1.5);
        _Space *= 0.5;

            float3 _Void = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord + (_Render_Background.rg * (1.0 - _Render_Texture.rg) + _Rand) * 0.1).rgb;
            _Space = lerp(_Space, _Space + _Void * float3(0.15, 0.05, 0.25), 1.0 - _Lum);

            float4 _Result = _Render_Texture;
            _Result.rgb = lerp( _Render_Texture.rgb, 
                                _Space + pow(Fun_Random(In.texCoord + _Space.rb + _Space.bg + _Render_Background.rg + _Render_Background.br + _Rand), 255.0), 
                                _Mixing);

            float _Inner = (1.0 - Fun_Inner(In.texCoord)) * _Render_Texture.a;
            _Result.rgb += ((_Inner / pow(cos(_Lum - _Inner), 6.0)) * saturate(_Mixing)) * 0.05;
            _Result.rgb += saturate(_Inner * _Inner + (1.0 - _Lum) * 0.15) * 4.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
