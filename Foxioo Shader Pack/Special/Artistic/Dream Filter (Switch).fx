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
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Size, _Mixing,
            
            fPixelWidth, fPixelHeight;
    int    _Quality;

    bool    _Blending_Mode;

/************************************************************/
/* Pixel Shader */
/************************************************************/

float3 Fun_Filter(sampler2D _Sampler, float2 In, float3 _Render)
{
    float3 _Blur = 0.0;
    float _Sum = 0.0;

    float3 _Result = _Render;

    float _Center = (float(_Quality) - 1.0) / 2.0;
    float2 _SizePixel = _Size * float2(fPixelWidth,  fPixelHeight) / float(_Quality);
    float _Luma = saturate(dot(_Render, float3(0.2126, 0.7152, 0.0722)));

    int x; int y;
    for(y = 0; y < _Quality; y++)
    {  
        for(x = 0; x < _Quality; x++)
        {  
            float xx = float(x) - _Center;
            float yy = float(y) - _Center;

            float2 UV = In + float2(xx, yy) * _SizePixel;
            float3 _Render_Blur = tex2D(_Sampler, UV).rgb;

            float _Dist = length(float2(xx, yy));
            float _W = 1.0 - saturate(_Dist / _Center);

            _Blur += _Render_Blur * _W;
            _Sum += _W;
        }
    }

    _Blur /= _Sum;
    _Result = lerp(_Render * _Luma, _Blur / _Luma, _Luma);
    _Result = lerp(_Render, _Result, _Luma);

    return pow(abs(_Result), 1.61);
}

//float4 ps_main(PS_INPUT In.texCoord) : COLOR0
float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, In.bgCoord, _Render_Background.rgb)
                                        : Fun_Filter(S2D_Image, In.texCoord, _Render_Texture.rgb);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;
    
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
    pass P0
    {
        PixelShader = compile ps_3_0 ps_main();
        VertexShader = NULL;
    }
}