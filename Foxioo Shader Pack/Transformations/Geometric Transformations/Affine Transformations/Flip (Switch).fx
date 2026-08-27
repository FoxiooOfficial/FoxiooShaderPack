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

    bool    _Blending_Mode,
            _X, _Y;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{   
    float4 _Render;

        if(_Blending_Mode)
        {
            float2 UV = abs(float2(_X, _Y) - In_Background);

            _Render.rgb = tex2D(S2D_Background, UV).rgb;
            _Render.a = tex2D(S2D_Image, In).a;
        }
        else
        {
            float2 UV = abs(float2(_X, _Y) - In);
            _Render = tex2D(S2D_Image, UV);
        }
        
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_1_4 ps_main(); } }