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

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

#if (__SHADER_TARGET_MAJOR >= 2)

    #define M_PI 3.14159265358979323846
    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
        float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

            float4 _Result;
                
                _Result.rgb = 0.5 + (atan((_Render_Background.rgb - _Render_Texture.rgb) * M_PI) / M_PI);
                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

            _Result.a = _Render_Texture.a;

        return _Result;
    }

#else

    float3 Fun_Penumbra(float3 _Color) {
        return 0.5 + _Color * (0.92752 + _Color * _Color * (-0.76 - 0.76 + _Color * _Color * (0.882305 + 0.882305 - 0.78 * _Color * _Color)));
    }

    float4 ps_main(in PS_INPUT In) : COLOR0
    {
        float4 _Render_Texture = tex2D(S2D_Image, In.texCoord); //* In.Tint;
        float3 _Render_Background = tex2D(S2D_Background, In.bgCoord);

            float3 _Result = _Render_Background.rgb - _Render_Texture.rgb;
                
                _Result = Fun_Penumbra(_Result);
                _Result = lerp(_Render_Texture, _Result, _Mixing);

        return float4(_Result, _Render_Texture.a);
    }

#endif

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