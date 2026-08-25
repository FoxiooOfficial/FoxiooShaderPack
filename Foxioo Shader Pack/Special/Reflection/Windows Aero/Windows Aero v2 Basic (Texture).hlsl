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

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	//float2 bgCoord : TEXCOORD1;
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

static const float3 _Main       = float3(0.73, 0.82, 0.92);
static const float3 _Accent     = float3(0.6, 0.71, 0.82);
static const float3 _Lerp      = float3(0.24, 0.19, 0.14);

static const float3 _BorderHigh = float3(0.15, 0.16, 0.17);
static const float3 _BorderLow  = float3(0.96, 0.98, 0.99);
static const float3 _BorderCyan = float3(0.0, 1.0, 1.0);

static const int SAMPLES_INNER  = 6;
#define JUMP_INNER              2.0
#define PIXELSIZE               float2(fPixelWidth, fPixelHeight)

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

float Fun_Inner(PS_INPUT In)
{
    float _Alpha = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5);
            float4 _Render = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Offset * JUMP_INNER * PIXELSIZE) * In.Tint;

            _Alpha += dot(_Render.rgb, float3(0.299, 0.587, 0.114)) * _Render.a;
        }
    }
    return _Alpha / float(SAMPLES_INNER * SAMPLES_INNER);
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Result;

            // color!!
            _Result.rgb = lerp(_Main, _Accent, _Lerp);

            // outline
            float _Outline = Fun_Inner(In);
            float3 _Border = lerp(_BorderHigh, _BorderLow, saturate(_Outline * 1.5));
            _Result.rgb = lerp(_Result.rgb, _Border, saturate(1.0 - _Outline));

        _Result.a = saturate(_Render_Texture.a + _Outline * 3.0);
        _Result = lerp(_Render_Texture, _Result, _Mixing);

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
