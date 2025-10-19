/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.3 (18.10.2025) */
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

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            float _Y = 0.257 * _Result.r + 0.504 * _Result.g + 0.098 * _Result.b + 0.0625;
            float _U = -0.148 * _Result.r - 0.291 * _Result.g + 0.439 * _Result.b + 0.5;
            float _V = 0.439 * _Result.r - 0.368 * _Result.g - 0.071 * _Result.b + 0.5;

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _U, _V), _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
