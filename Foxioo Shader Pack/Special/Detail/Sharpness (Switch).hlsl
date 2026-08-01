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
    bool _Blending_Mode;
    float _Mixing;
    float _Size;
    bool __;
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

float3 Fun_Sharp(Texture2D _Texture, SamplerState _Sampler, float2 In, float3 _Render, float2 _Off)
{
    _Render = 9.0 * _Render - (
        _Texture.Sample(_Sampler, In + float2(+_Off.x, +_Off.y)).rgb +
        _Texture.Sample(_Sampler, In + float2(-_Off.x, -_Off.y)).rgb +
        _Texture.Sample(_Sampler, In + float2(+_Off.x, -_Off.y)).rgb +
        _Texture.Sample(_Sampler, In + float2(-_Off.x, +_Off.y)).rgb +
        _Texture.Sample(_Sampler, In + float2(-_Off.x, 0.0)).rgb +
        _Texture.Sample(_Sampler, In + float2(+_Off.x, 0.0)).rgb +
        _Texture.Sample(_Sampler, In + float2(0.0, -_Off.y)).rgb +
        _Texture.Sample(_Sampler, In + float2(0.0, +_Off.y)).rgb
    );

    return _Render;
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result, _Render;
        float2 _Offset = _Size * float2(fPixelWidth, fPixelHeight);

            if(!_Blending_Mode)
            {
                _Result.rgb = _Render_Texture.rgb;
                _Render.rgb = Fun_Sharp(S2D_Image, S2D_ImageSampler, In.texCoord, _Result.rgb, _Offset) * In.Tint.rgb;
            }
            else
            {
                _Result.rgb = _Render_Background.rgb;
                _Render.rgb = Fun_Sharp(S2D_Background, S2D_BackgroundSampler, In.texCoord, _Result.rgb, _Offset);

            }

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
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
