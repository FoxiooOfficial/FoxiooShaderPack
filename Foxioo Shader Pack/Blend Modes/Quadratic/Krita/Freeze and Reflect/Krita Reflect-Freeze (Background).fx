/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (08.08.2025) */
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
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Reflect = 0;
        float4 _Freeze = 0;

                _Reflect.rgb = clamp(pow(_Render_Texture.rgb, 2) / (1 - _Render_Background.rgb), 0.0, 1.0);
                _Freeze.rgb  = clamp(1 - pow(1 - _Render_Background.rgb, 2) / _Render_Texture.rgb, 0.0, 1.0);

            float4 _Result = lerp(_Reflect, _Freeze, 0.5);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb * _Mixing, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
