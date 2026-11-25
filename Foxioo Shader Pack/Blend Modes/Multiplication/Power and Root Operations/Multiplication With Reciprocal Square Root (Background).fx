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

    float _Mul, _Mixing;

/************************************************************/
/* Main */
/************************************************************/

#if (__SHADER_TARGET_MAJOR >= 2)

    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
        float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

                float4 _Result;
                _Result.rgb = rsqrt(_Render_Texture * (_Render_Background * _Mul));
                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
                
            _Result.a = _Render_Texture.a;

        return _Result;
    }

#else
    
    /*  fox note!
        ps_1_x does not have a function to return rsqrt(x) and division;

        Fun_FastRSqrt -> return ~rsqrt(~1 / x) when x is in [0, 1];
        Fun_UltraFastInvDiv -> return ~1 / x when x is in [0, 1];

        if there are no slots, comment out the Newton correction but...
        lower precision :3
    */
    float3 Fun_UltraFastInvDiv(float3 _Div)
    {
        float3 _Color = 0.754 - 0.431 * _Div;
        _Color = _Color * _Color;

        // newton fix;
        float3 _Err = (_Div * _Color) * 8;
        _Color += _Color * (1.0 - _Err);

        return _Color;
    }

    float3 Fun_FastRSqrt(float3 _Render) {
        float3 _Color = (2 * (_Render * (0.9375 - 0.4375 * _Render)));
        return Fun_UltraFastInvDiv(_Color) * 8;
    }

    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord); // * In.Tint;
        float3 _Render_Background = tex2D(S2D_Background, In.bgCoord).rgb;

            float3 _Color = _Render_Texture.rgb * _Render_Background * _Mul;
            float3 _Result = Fun_FastRSqrt(_Color);
            
            _Result = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

        return float4(float3(_Result), _Render_Texture.a);
    }

#endif // (__SHADER_TARGET_MAJOR >= 2)

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{ 
    pass P0
    { 
        #if (__SHADER_TARGET_MAJOR >= 2)
            PixelShader = compile ps_2_0 ps_main();
        #else
            PixelShader = compile ps_1_4 ps_main();
        #endif
    } 
}
