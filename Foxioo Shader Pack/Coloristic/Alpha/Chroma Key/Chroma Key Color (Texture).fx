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
/* Varibles */
/***********************************************************/

    float _Mixing;

    float4 _ColorKey;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float4 _Result = _Render_Texture;

        float3 _Difference = abs(_Result.rgb - _ColorKey.rgb);
        float _KeyAlpha = max(_Difference.r, max(_Difference.g, _Difference.b));

        _Result.a = _Render_Texture.a * (1 + (_KeyAlpha - 1.0) * _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_4 ps_main(); } }
