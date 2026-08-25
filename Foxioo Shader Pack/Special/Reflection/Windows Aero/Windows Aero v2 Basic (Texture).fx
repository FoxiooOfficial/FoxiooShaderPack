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

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter   = LINEAR;
    MagFilter   = LINEAR;
    MipFilter   = LINEAR;
    AddressU    = BORDER;
    AddressV    = BORDER;
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,
            
            fPixelWidth, fPixelHeight;

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

float Fun_Inner(float2 In)
{
    float _Alpha = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5);
            float4 _Render = tex2D(S2D_Image, In + _Offset * JUMP_INNER * PIXELSIZE);

            _Alpha += dot(_Render.rgb, float3(0.299, 0.587, 0.114)) * _Render.a;
        }
    }
    return _Alpha / float(SAMPLES_INNER * SAMPLES_INNER);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;

            // color!!
            _Result.rgb = lerp(_Main, _Accent, _Lerp);

            // outline
            float _Outline = Fun_Inner(In);
            float3 _Border = lerp(_BorderHigh, _BorderLow, saturate(_Outline * 1.5));
            _Result.rgb = lerp(_Result.rgb, _Border, saturate(1.0 - _Outline));

        _Result.a = _Render_Texture.a + _Outline * 3.0;
        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
