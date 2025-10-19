/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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

    float _Mixing, _Mul;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0)
        {
            _Result = 1.0 / cosh(_Render_Texture * _Mul);
            _Render = _Render_Texture;
        }
        else
        {
            _Result = 1.0 / cosh(_Render_Background * _Mul);
            _Render = _Render_Background;
        }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
