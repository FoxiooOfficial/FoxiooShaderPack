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

    float _Mixing;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define M_PI 3.14159265358979323846

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result, _Render;

            if(!_Blending_Mode)
            { 
                _Result.rgb = atan((_Render_Background.rgb / _Render_Texture.rgb) / M_PI) * 2.0;
                _Render = _Render_Background;
            }
            else 
            { 
                _Result.rgb = atan((_Render_Texture.rgb / _Render_Background.rgb) / M_PI) * 2.0; 
                _Render = _Render_Texture;
            }
            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
