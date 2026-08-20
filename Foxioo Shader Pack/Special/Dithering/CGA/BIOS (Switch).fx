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

    float   _Mixing, _Add, _Mul, _DitheringSize,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 16

static const float3 _Palette[_Palette_Size] = 
{
    float3(0.0, 0.0, 0.0),
    float3(0.0, 0.0705882353, 0.6509803922),
    float3(0.1686274510, 0.6666666667, 0.1450980392),
    float3(0.1411764706, 0.6705882353, 0.6666666667),
    float3(0.6549019608, 0.0, 0.0039215686),
    float3(0.6470588235, 0.0039215686, 0.6509803922),
    float3(0.6588235294, 0.3215686275, 0.0549019608),
    float3(0.6666666667, 0.6666666667, 0.6666666667),
    float3(0.3333333333, 0.3333333333, 0.3333333333),
    float3(0.3058823529, 0.3568627451, 0.9803921569),
    float3(0.4196078431, 1.0, 0.4),
    float3(0.3960784314, 1.0, 1.0),
    float3(0.9803921569, 0.3098039216, 0.3333333333),
    float3(0.9764705882, 0.3333333333, 0.9803921569),
    float3(1.0, 0.9921568627, 0.4039215686),
    float3(1.0, 1.0, 1.0),
};

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

float3 Fun_Convert(float3 _Color)
{
    float3 _Low = _Color / 12.92;
    float3 _High = pow(abs((_Color + 0.055) / 1.055), 2.4);

        return lerp(_High, _Low, step(_Color, float3(0.04045, 0.04045, 0.04045)));
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

    _Render_Texture.rgb = _Render_Texture.rgb * _Mul + _Add;
    _Render_Background.rgb = _Render_Background.rgb * _Mul + _Add;

    _Render_Texture.rgb = _Render_Texture.rgb * _Mul + _Add;
    _Render_Background.rgb = _Render_Background.rgb * _Mul + _Add;

        float4 _Result, _Render;

        if(!_Blending_Mode) {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }

        int2 _Dith = int2(fmod(In / float2(fPixelWidth, fPixelHeight), 4.0));

        int _Index = _Dith.x + _Dith.y * 4;
        float _DithValue = _Dithering[_Index];
                
            float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                
            float _MinDist = 1e9;
            int _IndexC = 0;
            
                float3 _PO = Fun_Convert(_Color);
                for (int i = 0; i < _Palette_Size; i++)
                {
                    float3 _PL = Fun_Convert(_Palette[i]);
                    float3 _Diff = _PO - _PL;
                    float _Dist = dot(_Diff, _Diff);
                        
                    if (_Dist < _MinDist)
                    {
                        _MinDist = _Dist;
                        _IndexC = i;
                    }
                }

        _Result.rgb = _Palette[_IndexC];
        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 


    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
