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
/* Variables */
/***********************************************************/

    float   _Mixing;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

static const float3x3 LMS = float3x3(
    0.412109,   0.523927,   0.063964,
    0.166742,   0.720446,   0.112812,
    0.024182,   0.075426,   0.900392
);

static const float3x3 ICTCP = float3x3(
    0.5,        0.5,        0.0,
    1.613769,   -3.323486,  1.709717,
    4.378174,   -4.245605, -0.132568
);

static const float M1 = 2610.0 / 16384.0;
static const float M2 = 2523.0 / 32.0;
static const float C1 = 3424.0 / 4096.0;
static const float C2 = 2413.0 / 128.0;
static const float C3 = 2392.0 / 128.0;

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result, _Render;

        if(!_Blending_Mode) {
            _Result = _Render_Texture;
        }
        else {
            _Result = _Render_Background;
        }

        _Render = _Result;
        _Result.rgb = mul(_Result.rgb, LMS);

            float3 _M1 = pow(abs(_Result.rgb), M1);
            float3 _NM = C1 + C2 * _M1;
            float3 _DN = 1.0 + C3 * _M1;
            _Result.rgb = pow(abs(_NM / _DN), M2);

            _Result.rgb = mul(_Result.rgb, ICTCP);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb / 10.0, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
