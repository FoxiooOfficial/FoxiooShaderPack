/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.3 (24.06.2024) */
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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;
        
        if(_Blending_Mode == 0)
        {
            _Result.r = (1 - (_Render_Texture.g + (_Render_Texture.b - _Render_Texture.r))) + (_Mixing * _Render_Texture.r);
            _Result.g = (1 - (_Render_Texture.b + (_Render_Texture.r - _Render_Texture.g))) + (_Mixing * _Render_Texture.g);
            _Result.b = (1 - (_Render_Texture.r + (_Render_Texture.g - _Render_Texture.b))) + (_Mixing * _Render_Texture.b);
        }
        else
        {
            _Result.r = (1 - (_Render_Background.g + (_Render_Background.b - _Render_Background.r))) + (_Mixing * _Render_Background.r);
            _Result.g = (1 - (_Render_Background.b + (_Render_Background.r - _Render_Background.g))) + (_Mixing * _Render_Background.g);
            _Result.b = (1 - (_Render_Background.r + (_Render_Background.g - _Render_Background.b))) + (_Mixing * _Render_Background.b);
        }

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
