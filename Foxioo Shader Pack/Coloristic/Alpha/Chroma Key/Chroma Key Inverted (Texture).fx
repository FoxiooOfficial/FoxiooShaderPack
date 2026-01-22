/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (26.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float4 _Result = _Render_Texture;

        float3 _Difference = abs(_Result.rgb - _ColorKey.rgb);
        float _KeyAlpha = 1.0 - max(_Difference.r, max(_Difference.g, _Difference.b));

        _Result.a = _Render_Texture.a * (1 + (_KeyAlpha - 1.0) * _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
