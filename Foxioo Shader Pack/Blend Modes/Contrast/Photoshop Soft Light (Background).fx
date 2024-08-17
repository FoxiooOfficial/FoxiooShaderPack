/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (30.06.2024) */
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

        float4 _Result = 0;

        _Result.rgb = (_Render_Background < 0.5) ? (2 * _Render_Texture - 1) * (_Render_Background - pow(_Render_Background, 2)) + _Render_Background : (2 * _Render_Texture - 1) * (sqrt(_Render_Background) - _Render_Background) + _Render_Background;

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
