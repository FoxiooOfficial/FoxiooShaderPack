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

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#if (__SHADER_TARGET_MAJOR >= 2)

    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
        float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

            float4 _Result, _Render;
            
                if(!_Blending_Mode)
                { 
                    _Result.rgb = _Render_Texture.rgb - (_Render_Background.rgb * _Mul); 
                    _Render = _Render_Texture;
                }
                else 
                { 
                    _Result.rgb = (_Render_Background.rgb * _Mul) - _Render_Texture.rgb; 
                    _Render = _Render_Background;
                }

                _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

            _Result.a = _Render_Texture.a;
            
        return _Result;
    }

#else

    /*  fox note!
        ps_1_x does not have a function to return sqrt(x)
        Fun_FastSqrt -> return ~sqrt(x) when x is in [0, 1];
    */
    float3 Fun_FastSqrt(float3 _Render) {
        return 2.0 * (_Render * (0.9375 - 0.4375 * _Render));
    }

    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord); // * In.Tint;
        float3 _Render_Background = tex2D(S2D_Background, In.bgCoord).rgb * _Mul;

            float3 _Result = lerp(_Render_Background, _Render_Texture.rgb, _Blending_Mode);
            float3 _Render = lerp(_Render_Texture.rgb, _Render_Background, _Blending_Mode);
        
                _Result = _Render.rgb - _Result;
                _Result = Fun_FastSqrt(_Result);
                _Result = lerp(_Render.rgb, _Result.rgb, _Mixing);
            
        return float4(_Result, _Render_Texture.a);
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
