/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.8 (18.10.2025) */
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

float   _Mixing, _Alpha, 
        _Brightness, _Mixing_Brightness,
        _Threshold;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(float2 In: TEXCOORD) : COLOR
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    _Render_Texture.rgb *= _Alpha * _Render_Texture.a;

    float4 _Result = _Render_Texture;
    _Result.rgb *= _Brightness + (_Render_Background.rgb * _Mixing_Brightness);
    _Result.rgb += 1;

    if (_Result.a > _Threshold)
    {
        float _Alpha_Temp = ((_Result.r + _Result.g + _Result.b) / 3.0 - _Threshold) / (1.0 - _Threshold);
        float4 _Lerp = lerp(_Render_Background, float4(1, 1, 1, _Result.a * 2), _Alpha_Temp);
        _Result.rgb *= _Lerp.rgb;
    }

    _Result.rgb *= (_Render_Texture.rgb * _Mixing) + _Render_Background.rgb;

    _Result.a = _Render_Texture.a * _Alpha * _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
