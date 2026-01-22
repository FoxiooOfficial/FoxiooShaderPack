/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (04.01.2026) */
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

        float4 _Result = float4(0.0, 0.0, 0.0, 1.0);

        if(_Render_Texture.r >= _Render_Background.r)
            _Result.r = _Render_Texture.r;

        if(_Render_Texture.g >= _Render_Background.g)
            _Result.g = _Render_Texture.g;

        if(_Render_Texture.b >= _Render_Background.b)
            _Result.b = _Render_Texture.b;

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
