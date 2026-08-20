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

static const float3 _L = float3(0.299, 0.587, 0.114);

float3 Fun_LumInvert(float3 _Render)
{
    float Y = dot(_L, _Render);
    float U = 0.492 * (_Render.b - Y);
    float V = 0.877 * (_Render.r - Y);

    Y = 1.0 - Y;

    float R = Y + 1.13983 * V;
    float G = Y - 0.39465 * U - 0.58060 * V;
    float B = Y + 2.03211 * U;

    return float3(R, G, B);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result, _Render;
        
            if(!_Blending_Mode)
            {
                _Result.rgb = Fun_LumInvert(_Render_Texture.rgb);
                _Render = _Render_Texture;
            }
            else
            {
                _Result.rgb = Fun_LumInvert(_Render_Background.rgb);

                _Render.rgb = _Render_Background.rgb;
                _Result.a = _Render_Texture.a;
            }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
        
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
