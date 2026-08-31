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
    float _PixelSize;
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

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);
    _Render_Background.a = _Render_Texture.a;

        uint2 _Pixel = !_Blending_Mode ? float2((uint)(In.texCoord.x / fPixelWidth), (int)(In.texCoord.y / fPixelHeight)) :
                                        float2((uint)(In.bgCoord.x / fPixelWidth), (int)(In.bgCoord.y / fPixelHeight));

        float _PixelSizeFix = _PixelSize == 0.0 ? 0.0001 : _PixelSize;
        float2 _Size = float2(1.0 / fPixelWidth, 1.0 / fPixelHeight) / _PixelSizeFix;

        float2 _UV = !_Blending_Mode ?  float2(ceil(In.texCoord.x * _Size.x) / _Size.x, ceil(In.texCoord.y * _Size.y) / _Size.y) : 
                                        float2(ceil(In.bgCoord.x * _Size.x) / _Size.x, ceil(In.bgCoord.y * _Size.y) / _Size.y);

            float4 _Render_Texture_Ex = S2D_Image.Sample(S2D_ImageSampler, float2(_UV.x, _UV.y)) * In.Tint;
            float4 _Render_Background_Ex = S2D_Background.Sample(S2D_BackgroundSampler, float2(_UV.x, _UV.y));
            _Render_Background_Ex.a = _Render_Texture.a;

                float4 _Result = _Blending_Mode ? _Render_Background_Ex : _Render_Texture_Ex;
                float4 _Render = _Blending_Mode ? _Render_Background    : _Render_Texture;

                    if ((_Pixel.x % 3) == 0)    _Result.rgb += float3(_Result.r, 0.0, 0.0);
                    if ((_Pixel.x % 3) == 1)    _Result.rgb += float3(0.0, _Result.g, 0.0);
                    else                        _Result.rgb += float3(0.0, 0.0, _Result.b);

        _Result = lerp(_Render, _Result, _Mixing);

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
