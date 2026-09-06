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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            fPixelWidth, fPixelHeight;

    float4  _ColorLight, _ColorShadow;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in PS_INPUT In) : COLOR0
{
    const float _Steps = 32.0;
    const float _Res = 4.0;

    float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
    float _ResSize = _Res * _Mixing;

        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
        float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result, _Render;

            if(!_Blending_Mode)
            {
                float2 UV = floor(In.texCoord / _PixelSize / _ResSize) * _PixelSize * _ResSize;

                _Result = tex2D(S2D_Image, UV);
                _Render = _Render_Texture;
            }
            else
            {
                float2 UV = floor(In.bgCoord / _PixelSize / _ResSize) * _PixelSize * _ResSize;

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

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
