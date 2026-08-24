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

    float   _Mixing,
            _Threshold;

    bool    _Blending_Mode, _Negative;

    float4  _ColorLight, _ColorShadow;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result;
        _Result.rgb = lerp(_Render_Texture.rgb, _Render_Background.rgb, _Blending_Mode);
        _Result.a = _Render_Texture.a;

            float4 _Render = _Result;
            float _Lum = dot(_Result.rgb + _Threshold, float3(0.299, 0.587, 0.114));

            _Render.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, step(0.5, abs(_Negative - _Lum)));
            _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_4 ps_main(); } }
