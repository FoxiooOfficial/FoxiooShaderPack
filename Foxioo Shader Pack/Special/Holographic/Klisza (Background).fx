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

    float   _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result) {
    return 0.299 * _Result.r + 0.587 * _Result.g + 0.114 * _Result.b;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        const float3 _Min = float3(0.772549, 0.168627, 0.047058);
        const float3 _Max = float3(0.992156, 0.654901, 0.160784);
        float _Lum = Fun_Luminance(_Render_Background.rgb);
        _Lum *= _Lum;

        float3 _Klisza = lerp(_Min, _Max, _Lum);

            float4 _Result;
            _Result.a = _Render_Texture.a;

            _Result.rgb = (1.0 - _Render_Texture.rgb) * _Klisza * _Render_Background.rgb;
            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_4 ps_main(); } }
