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

    float   _Mixing, _Seed, _Distortion,
            fPixelWidth, fPixelHeight;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Rand(float2 In)
{
    float2 _Rand = float2(  frac(sin(dot(In.xy + _Seed, float2(12.9898,78.233)))* 43758.5453123),
                            frac(cos(dot(In.xy + _Seed, float2(67.4684,18.467)))* 3463456.95546)
                        );
    return _Rand;
}

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float2 _Pixel = float2(fPixelWidth, fPixelHeight);
        float2 _Block = float2(4.0, 8.0);
        float4 _Result = (float4)0.0;
        float4 _Render = (float4)0.0;

            float2 _Art = floor(In / _Pixel / _Block) * _Pixel * _Block;
            if(any(abs(Fun_Rand(_Art).xy) > _Distortion))
                _Art = In;
            else
                _Art = In + Fun_Rand(_Art) * 0.5 - 0.25;

                if(_Blending_Mode)
                {
                    _Result = tex2D(S2D_Background, _Art);
                    _Render.rgb = _Render_Background.rgb;
                    _Result.a = _Render_Texture.a;
                }
                else
                {
                    _Result = tex2D(S2D_Image, _Art);
                    _Render = _Render_Texture;
                    
                }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
