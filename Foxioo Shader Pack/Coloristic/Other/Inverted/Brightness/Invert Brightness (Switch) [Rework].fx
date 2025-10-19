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

    float _Mixing;
    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Lum(float3 _Render)
{
    float Y = 0.299     * _Render.r + 0.587      *_Render.g + 0.114     * _Render.b;
    float U = -0.14713  * _Render.r - 0.28886   * _Render.g + 0.436     * _Render.b;
    float V =  0.615    * _Render.r - 0.51499   * _Render.g - 0.10001   * _Render.b;
    Y = 1.0 - Y;

    float3 _Result;
        _Result.r = Y + 1.13983 * V;
        _Result.g = Y - 0.39465 * U - 0.58060 * V;
        _Result.b = Y + 2.03211 * U;

    return saturate(_Result);
}


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result = 0;
    float4 _Render = 0;
        
        if(_Blending_Mode == 0)
        {
            _Result.rgb = Fun_Lum(_Render_Texture.rgb);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = Fun_Lum(_Render_Background.rgb);
            _Render = _Render_Background;
        }

    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
