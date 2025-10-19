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

    float4 _Result, _Render;

    if (_Blending_Mode == 0)
    {   
        _Render = _Render_Texture; 
        _Result = _Render_Texture;
    }
    else
    {
        _Render = _Render_Background; 
        _Result = _Render_Background;
    }

        _Result.rgb *= float3(0.02, 0.01, 0.5);
        _Result.r = lerp(0, 1, _Result.b / 2.0);

            float3 _ColorRed = float3(1.0, 0.2, 0.5);
                _Result.r += lerp(0, _ColorRed.r, (_Render.r - 0.75) / (1.0 - 0.75));

            float3 _ColorGreen = float3(0.6, 1, 0.1);
                _Result.g += lerp(0, _ColorGreen.g, (_Render.g - 0.75) / (1.0 - 0.75));

            float3 _ColorBlue = float3(0.2, 1, 0.8);
                _Result.b += lerp(0, _ColorBlue.b, (_Render.b - 0.75) / (1.0 - 0.75));

        _Result.rgb = pow(_Result.rgb, 1.0 / 2.2); 


    _Result = lerp(_Render, _Result, _Mixing);
    _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
