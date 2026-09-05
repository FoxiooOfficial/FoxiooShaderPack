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
    bool _Blending_Mode;
    float _Mixing;
    float _Size;
    int _Quality;
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

float3 Fun_Filter(Texture2D _Texture, SamplerState _Sampler, float2 In, float3 _Render, float4 _Tint)
{
    float3 _Blur = 0.0;
    float _Sum = 0.0;

    float3 _Result = _Render;

    float _Center = (float(_Quality) - 1.0) / 2.0;
    float2 _SizePixel = _Size * float2(fPixelWidth,  fPixelHeight) / float(_Quality);
    float _Luma = saturate(dot(_Render, float3(0.2126, 0.7152, 0.0722)));

    int x; int y;
    for(y = 0; y < _Quality; y++)
    {  
        for(x = 0; x < _Quality; x++)
        {  
            float xx = float(x) - _Center;
            float yy = float(y) - _Center;

            float2 UV = In + float2(xx, yy) * _SizePixel;
            float3 _Render_Blur = _Texture.Sample(_Sampler, UV).rgb;

            float _Dist = length(float2(xx, yy));
            float _W = 1.0 - saturate(_Dist / _Center);

            _Blur += _Render_Blur * _W;
            _Sum += _W;
        }
    }

    _Blur /= _Sum;
    _Result = lerp(_Render * _Luma, _Blur / _Luma, _Luma);
    _Result = lerp(_Render, _Result, _Luma);

    return pow(abs(_Result), 1.61);
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, S2D_BackgroundSampler, In.bgCoord, _Render_Background.rgb, (float4)1.0)
                                        : Fun_Filter(S2D_Image, S2D_ImageSampler, In.texCoord, _Render_Texture.rgb, In.Tint);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;

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
