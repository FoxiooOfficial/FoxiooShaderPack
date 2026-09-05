/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float _Mixing;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

            _Result.rgb *= float3(0.02, 0.01, 0.5);
            _Result.r = lerp(0.0, 1.0, _Result.b / 2.0);

                float3 _ColorRed = float3(1.0, 0.2, 0.5);
                    _Result.r += lerp(0.0, _ColorRed.r, (_Render.r - 0.75) / (1.0 - 0.75));

                float3 _ColorGreen = float3(0.6, 1.0, 0.1);
                    _Result.g += lerp(0.0, _ColorGreen.g, (_Render.g - 0.75) / (1.0 - 0.75));

                float3 _ColorBlue = float3(0.2, 1.0, 0.8);
                    _Result.b += lerp(0.0, _ColorBlue.b, (_Render.b - 0.75) / (1.0 - 0.75));

                _Result.rgb = pow(abs(_Result.rgb), 1.0 / 2.2); 

            _Result = lerp(_Render, _Result, _Mixing);
            _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
