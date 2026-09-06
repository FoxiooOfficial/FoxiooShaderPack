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

    float _Mixing;
    float _Add;
    float _Mul;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Hue(float _Lum) {
    return abs(fmod(frac(_Lum) * 6.0 + float3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result;
        _Result.rgb = lerp(_Render_Texture.rgb, _Render_Background.rgb, float(_Blending_Mode));
        _Result.a = _Render_Texture.a;

            float _Lum = dot(_Result.rgb, float3(0.299, 0.587, 0.114));
            float3 _MLG = Fun_Hue(_Lum * _Mul + _Add);
            
        _Result.rgb = lerp(_Result.rgb, _MLG, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
