/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (21.02.2026) */
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

    float _Coeff, _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture      = tex2D(S2D_Image, In);
    float4 _Render_Background   = tex2D(S2D_Background, In);

        int4 _Render_Texture_int    = ceil(_Render_Texture * 255) * (128 - _Coeff);
        int4 _Render_Background_int = ceil(_Render_Background * 255) * (_Coeff);

        int4 _Result_int = ceil((_Render_Texture_int + _Render_Background_int) / 128);
   
    float4 _Result = (float4)_Result_int / 255.0;
    _Result.a *= _Render_Texture.a;

    _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
