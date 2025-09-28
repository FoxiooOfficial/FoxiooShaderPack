/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (23.09.2025) */
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

    float _Mul, _Mixing;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result;

            if (_Blending_Mode == 0)
            {
                _Result.rgb = 1.0 / tanh(_Render_Texture.rgb / (_Render_Background.rgb * _Mul));
            }
            else
            {
                _Result.rgb = 1.0 / tanh((_Render_Background.rgb * _Mul) / _Render_Texture.rgb);
            }
        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
