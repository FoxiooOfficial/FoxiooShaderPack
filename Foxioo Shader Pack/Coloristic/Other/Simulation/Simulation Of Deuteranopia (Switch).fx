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
            _Result = tex2D(S2D_Image, In);
        }
        else
        {
            _Result = tex2D(S2D_Background, In);
        }

        /* The _ColorMatrix variables are taken from: https://github.com/MaPePeR/jsColorblindSimulator */
        const float3x3 _ColorMatrix = float3x3(
            0.625, 0.375, 0.0,
            0.70,  0.30,  0.0,
            0.0,   0.30,  0.70
        );

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, mul(_ColorMatrix, _Result.rgb) * _Mixing, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
