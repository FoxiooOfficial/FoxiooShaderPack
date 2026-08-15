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

    float   _Mixing;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

static const float3x3 YIQ = float3x3(
    0.299,      0.587,      0.114,
    0.595716,   -0.274453,  -0.321263,
    0.211456,   -0.522591,  0.311135
);

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result, _Render;

        if(!_Blending_Mode) {
            _Result = _Render_Texture;
        }
        else {
            _Result = _Render_Background;
        }

        _Render = _Result;
        _Result.rgb = mul(_Result.rgb, YIQ);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_4 ps_main(); } }
