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

sampler2D S2D_Background : register(s1) = sampler_state
{
    MinFilter   = LINEAR;
    MagFilter   = LINEAR;
    MipFilter   = LINEAR;
    AddressU    = CLAMP;
    AddressV    = CLAMP;
};

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _PosX, _PosY,
            _Mixing,
            
            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

static const float3 _AColor     = float3(0.08333, 0.36842, 0.85714);
static const float3 _ALerp      = float3(0.24, 0.19, 0.14);
static const float3 _BorderHigh = float3(0.15, 0.16, 0.17);
static const float3 _BorderLow  = float3(0.96, 0.98, 0.99);
static const float3 _BorderCyan = float3(0.0, 1.0, 1.0);

static const int SAMPLES_INNER  = 6;
static const int SAMPLES_BLUR   = 8;
#define JUMP_INNER              2.0
#define JUMP_BLUR               1.0
#define PIXELSIZE               float2(fPixelWidth, fPixelHeight)

float3 Fun_Blur(float2 In)
{
    float3 _Render = 0.0;
    float _Sum = (float(SAMPLES_BLUR) - 1.0) / 2.0;

    int y, x;
    for(y = 0; y < SAMPLES_BLUR; ++y)
    {
        for(x = 0; x < SAMPLES_BLUR; ++x)
        {
            float2 _Off = float2(x, y) - _Sum;
            _Render += tex2D(S2D_Background, In + _Off * PIXELSIZE * JUMP_BLUR).rgb;
        }
    }

    return _Render / float(SAMPLES_BLUR * SAMPLES_BLUR);
}

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

float Fun_Aero_Light(float2 In)
{   
    float _D = In.x - In.y;

        float _P1 = sin(_D * 0.75);
        float _P2 = sin(_D * 0.4 + 0.1);
        float _P3 = sin(_D * 0.65 + 0.2);
        float _P4 = sin(_D * 1.1 + 0.3);

    float _Light = 0.5 + 0.5 * ((_P1 + _P2 * 0.5 + _P3 * 0.25 - _P4 * 0.6) / 1.75);
    return _Light;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;

            // blur!!
            _Result.rgb = Fun_Blur(In);
            _Result.rgb = lerp(_Result.rgb, _AColor, _ALerp);

            // outline
            float _Outline = Fun_Inner(In);
            float3 _Border = lerp(_BorderHigh, _BorderLow, saturate(_Outline * 1.5));
            _Border *= lerp(_Border, _BorderCyan, In.x + In.y);

            _Result.rgb = lerp(_Result.rgb, _Border, saturate(1.0 - _Outline));

            // lines
            _Result.rgb += _BorderHigh * Fun_Aero_Light(In / PIXELSIZE * 0.04 + float2(_PosX, _PosY) * PIXELSIZE);

            // light
            _Result.rgb += saturate(abs(0.5 - In.x) * (1.0 - In.y * 2.0)) * 0.5;
            
        _Result.a = _Render_Texture.a + _Outline * 3.0;
        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
