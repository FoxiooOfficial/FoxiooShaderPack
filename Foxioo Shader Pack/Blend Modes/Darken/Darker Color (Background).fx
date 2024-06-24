/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (22.06.2024) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register (s0);
sampler2D S2D_Background : register (s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float4 Main( in float2 In : TEXCOORD0) : COLOR0
{       
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In) * _Mixing;

        float _Average = (_Render_Texture.r + _Render_Texture.g + _Render_Texture.b) / 3.0;
            if (_Render_Background.r < _Average) { _Render_Texture.r = _Render_Background.r; }
            if (_Render_Background.g < _Average) { _Render_Texture.g = _Render_Background.g; }
            if (_Render_Background.b < _Average) { _Render_Texture.b = _Render_Background.b; }

    return _Render_Texture;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }