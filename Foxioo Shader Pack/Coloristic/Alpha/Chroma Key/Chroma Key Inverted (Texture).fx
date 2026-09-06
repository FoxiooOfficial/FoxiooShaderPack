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

    float4 _ColorKey;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;

        float3 _Diff = _Render_Texture.rgb - _ColorKey.rgb;
        float _Alpha = dot(_Diff, _Diff);

            float _Key = _Mixing * 2.0;
    
        _Render_Texture.a *= saturate((1.0 - _Alpha) * _Key);

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_1 ps_main(); } }
