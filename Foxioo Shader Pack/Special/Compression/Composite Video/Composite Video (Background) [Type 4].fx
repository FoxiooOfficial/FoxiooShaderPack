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
    MinFilter = Linear;
    MagFilter = Linear;
    AddressU = border;
    AddressV = border;
};
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   fPixelWidth, fPixelHeight,
            _Mixing, _Size,
            _CrossLuma, _CrossColor,
            _Distortion,
            _Time;

    int     _Quality;

/************************************************************/
/* Main */
/************************************************************/

const float3 _L = float3(0.299, 0.587, 0.114);

#define M_PI        3.14159265358979323846

#define MHZ_CROMA   4.43361875
#define MHZ_LUM     13.5
#define MHZ_LIFT    283.75

#define FPS         25
#define SAMPLES     720
#define LINES       576

float3 Fun_RGB2YUV(float3 _Render)
{
    float Y = dot(_L, _Render);
    float U = 0.492 * (_Render.b - Y);
    float V = 0.877 * (_Render.r - Y);

    return float3(Y, U, V);
}

float3 Fun_Blur(sampler2D _Sampler, float2 In, float _Offset)
{
    float3 _Result = 0.0;
    int x, y;
    float _W = 0.0;

    for(y = 0; y < _Quality; y++)
    {
        for(x = 0; x < _Quality; x++)
        {
            float2 _Off = float2(x, y);
            _Off -= floor(_Quality / 2.0);
            _Result += tex2D(_Sampler, In + (float2(fPixelWidth, fPixelHeight) * _Off * _Offset * _Size) / _Quality);
            _W += 1.0;
        }
    }

    return _Result / _W;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

    float2 _Pos = float2(floor(In.texCoord.x * SAMPLES), floor(In.texCoord.y * LINES + (_Time * FPS * 2.0)));

        float _Vert = fmod(_Pos.y, 2.0) < 1.0 ? 1.0 : -1.0;
        float2 _Cycle = float2(MHZ_CROMA / MHZ_LUM, MHZ_LIFT);
        float _Noise = _Distortion * sin(_Pos.y * 6.0 * _Distortion - _Time + 1.0 / cos(_Time * 15.0));
        float _Phase = 2.0 * M_PI * ((_Pos.x * _Cycle.x) + (_Pos.y * _Cycle.y)) + _Noise;

        float2 _UV = 0.5 * lerp(float2(sin(_Phase + _Noise) * _Distortion * (1.0 / SAMPLES), 0.0), 5.0 * (In.texCoord.yy / (_Noise / _Phase) * _Vert * _Distortion), _Distortion);
        if(_Distortion == 0.0) _UV = 0.0;

            // Luma
            float4 _Result = tex2D(S2D_Background, In.bgCoord + _UV);
            float _Luma = Fun_RGB2YUV(_Result.rgb).x;

                _Result.rgb = Fun_Blur(S2D_Background, In.bgCoord + _UV, 0.85);
                float3 _Render = Fun_RGB2YUV(_Result.rgb);
                float Y = _Render.x;

            // Chroma
            _Result.rgb = Fun_Blur(S2D_Background, In.bgCoord + float2(0.0, 2.0 * (_Vert / LINES)) * Y + _UV, 4.0);

                _Render = Fun_RGB2YUV(_Result.rgb);
                float U = _Render.y;
                float V = _Render.z;

            // Rainbowing
            float _Sin, _Cos;
            sincos(_Phase, _Sin, _Cos);

                _Luma = (Y - _Luma) * _CrossColor;
                U += _Luma * _Cos;
                V += _Luma * _Sin * _Vert;

                float _Chroma = (U * _Cos) + (V * _Vert * _Sin);

                // Cross-luma
                Y += (_Chroma * _CrossLuma);

            // Out
            _Result.rgb = Y * Y;
            _Result.rgb = lerp(_Render_Background.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
