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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _Size,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Sharp(sampler2D _Sampler, float2 In, float3 _Render, float2 _Off)
{
    _Render = 9.0 * _Render - (
        tex2D(_Sampler, In + float2(+_Off.x, +_Off.y)).rgb +
        tex2D(_Sampler, In + float2(-_Off.x, -_Off.y)).rgb +
        tex2D(_Sampler, In + float2(+_Off.x, -_Off.y)).rgb +
        tex2D(_Sampler, In + float2(-_Off.x, +_Off.y)).rgb +
        tex2D(_Sampler, In + float2(-_Off.x, 0.0)).rgb +
        tex2D(_Sampler, In + float2(+_Off.x, 0.0)).rgb +
        tex2D(_Sampler, In + float2(0.0, -_Off.y)).rgb +
        tex2D(_Sampler, In + float2(0.0, +_Off.y)).rgb
    );

    return _Render;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result, _Render;
        float2 _Offset = _Size * float2(fPixelWidth, fPixelHeight);

            if(!_Blending_Mode)
            {
                _Result.rgb = _Render_Texture.rgb;
                _Render.rgb = Fun_Sharp(S2D_Image, In.texCoord, _Result.rgb, _Offset);
            }
            else
            {
                _Result.rgb = _Render_Background.rgb;
                _Render.rgb = Fun_Sharp(S2D_Background, In.bgCoord, _Result.rgb, _Offset);

            }

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
