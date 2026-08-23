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
// sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,
            _Time, 
            _InGray, _InMul, 
            _OutGray, _OutMul;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

        float4 _Result = _Render_Texture;
        float _Lum = dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722));

        float3 _In = lerp(_Result.rgb, _Lum, _OutGray) * _OutMul;
        float3 _Out = lerp(_Result.rgb, _Lum, _InGray) * _InMul;

            _Result.rgb = lerp(_Out, _In, step(In.y, _Time));
            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
