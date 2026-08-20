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
/* Varibles */
/***********************************************************/

    float   _Mixing,
            fPixelWidth, fPixelHeight;

    float4  _ColorLight, _ColorShadow;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    const float _Steps = 32.0;
    const float _Res = 4.0;

    float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
    float _ResSize = _Res * _Mixing;

        float4 _Render_Texture = tex2D(S2D_Image, In);
        float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result, _Render;

        float2 UV = floor(In / _PixelSize / _ResSize) * _PixelSize * _ResSize;

            if(!_Blending_Mode)
            {
                _Result = tex2D(S2D_Image, UV);
                _Render = _Render_Texture;
            }
            else
            {
                _Result.rgb = tex2D(S2D_Background, UV);
                _Render = _Render_Background;

                _Result.a = _Render_Texture.a;
            }

            float _Lum = dot(_Result.rgb, float3(0.299, 0.587, 0.114));

                _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Lum) * 1.55;
                _Result.rgb = floor(_Result.rgb * _Steps) / _Steps;

            _Result = lerp(_Render, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
