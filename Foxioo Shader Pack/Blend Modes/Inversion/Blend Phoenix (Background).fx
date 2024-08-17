
/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (15.08.2024) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In) * _Mixing;

        float4 _Result = _Render_Texture;

            _Result.rgb = lerp(_Render_Texture.rgb, min(_Render_Texture.rgb, _Render_Background.rgb) - max(_Render_Texture.rgb, _Render_Background.rgb) + 1.0, min(_Mixing, 1.0));

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
