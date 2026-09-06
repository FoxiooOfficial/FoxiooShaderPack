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

    float   _Mixing, _DitheringSize, _Mul, _Add,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

/* https://belkadan.com/blog/2018/01/Color-Palette-8/ */

float3 Fun_Convert(float3 _Color)
{
    float3 _Quant = round(_Color * 5.0) / 5.0;

        float _Lum = (_Color.r + _Color.g + _Color.b) / 3.0;
        _Lum = round(_Lum * 15.0) / 15.0;

        float _Sat = max(max(_Color.r, _Color.g), _Color.b) - min(min(_Color.r, _Color.g), _Color.b);
    
    if (_Sat < 0.05)    return _Lum;
    else                return _Quant;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

    _Render_Texture.rgb = _Render_Texture.rgb * _Mul + _Add;
    _Render_Background.rgb = _Render_Background.rgb * _Mul + _Add;

        float4 _Result, _Render;

        if(!_Blending_Mode)
        {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }

        int2 _Dith = int2(  fmod(In.texCoord.x / fPixelWidth,   4.0), 
                            fmod(In.texCoord.y / fPixelHeight,  4.0)
                        );

        int _Index = _Dith.x + _Dith.y * 4;
        float _DithValue = _Dithering[_Index];
                
            float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
            _Color = saturate(_Color);

        _Result.rgb = Fun_Convert(_Color);
        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
