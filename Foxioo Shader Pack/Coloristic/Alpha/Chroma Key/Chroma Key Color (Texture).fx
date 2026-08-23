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

    float _Mixing;

    float4 _ColorKey;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float3 _Diff = _Render_Texture.rgb - _ColorKey.rgb;
        float _Alpha = dot(_Diff, _Diff);

            float _Key = _Mixing * 2.0;
    
        _Render_Texture.a *= saturate(_Alpha * _Key + (1.0 - _Key));

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_1 ps_main(); } }
