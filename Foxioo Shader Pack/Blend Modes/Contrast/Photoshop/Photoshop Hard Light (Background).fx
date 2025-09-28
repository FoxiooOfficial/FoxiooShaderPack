/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (07.01.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

    float _Mixing;
    

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = 0;

        _Result.rgb = lerp(_Render_Texture, (_Render_Texture < 0.5) ? _Render_Texture * (_Render_Background * _Mixing) : 1 - 2 * (1 - _Render_Texture) * (1 - _Render_Background * _Mixing), _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
