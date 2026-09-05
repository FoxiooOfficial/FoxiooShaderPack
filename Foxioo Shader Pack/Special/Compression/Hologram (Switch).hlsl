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
	bool ___;
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
    float4 _Render_Texture;
    float4 _Render_Background;

    uint2 _Pixel = float2((uint)(In.texCoord.x / fPixelWidth), (uint)(In.texCoord.y / fPixelHeight));

        float4 _Result = 0.0;
    
            _Render_Texture =  Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(fPixelWidth, fPixelHeight)) * In.Tint, _Premultiplied);
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord + float2(fPixelWidth, fPixelHeight));
            float4 _RenderOff2 = _Blending_Mode ? _Render_Background : _Render_Texture;

            _Render_Texture =  Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);
            float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

            /* x-axis */
            if ((_Pixel.x % 2) == 0)    _Result.rgb = float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.x % 2) == 1)    _Result.rgb = float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb = float3(_RenderOff2.r, 0.0, _Render.b);

            /* y-axis */
            if ((_Pixel.y % 2) == 0)    _Result.rgb += float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.y % 2) == 1)    _Result.rgb += float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb += float3(_RenderOff2.r, 0.0, _Render.b);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb / 2.0, _Mixing);
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
