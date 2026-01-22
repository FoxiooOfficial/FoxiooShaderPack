/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (24.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
// sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Time, _InGray, _InMul, _OutGray, _OutMul;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float4 _Result = _Render_Texture;
        if(In.y <= _Time)   _Result.rgb = lerp(_Result.rgb, _Result.r * 0.2126 + _Result.g * 0.7152 + _Result.b * 0.0722, _OutGray) * _OutMul;
        else                _Result.rgb = lerp(_Result.rgb, _Result.r * 0.2126 + _Result.g * 0.7152 + _Result.b * 0.0722, _InGray) * _InMul;

                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
