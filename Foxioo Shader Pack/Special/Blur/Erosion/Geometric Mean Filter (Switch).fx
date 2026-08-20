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

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Linear;
    MagFilter = Linear;
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    MinFilter = Linear;
    MagFilter = Linear;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Size, _Mixing,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;
    
    int     _Quality;

/************************************************************/
/* Main */
/************************************************************/

/*  Special thanks to Envy24!
    https://www.shadertoy.com/view/ssySDh */

float3 Fun_Filter(sampler2D _Sampler, float2 In)
{
    float3 _Result = (float3)0.0;

    float _Center = (float(_Quality) - 1.0) / 2.0;
    float2 _SizePixel = _Size * float2(fPixelWidth,  fPixelHeight) / float(_Quality);
    
    float _Sum = float(_Quality * _Quality);

    int x; int y;
    for(y = 0; y < _Quality; y++)
    {  
        for(x = 0; x < _Quality; x++)
        {  
            float xx = float(x) - _Center;
            float yy = float(y) - _Center;

            float2 UV = In + float2(xx, yy) * _SizePixel;

            float3 _Effect = tex2D(_Sampler, UV).rgb;
            
            _Result += log(abs(_Effect));
            //_Sum++;
        }
    }

    return exp(_Result / _Sum);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, In)
                                        : Fun_Filter(S2D_Image, In);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
