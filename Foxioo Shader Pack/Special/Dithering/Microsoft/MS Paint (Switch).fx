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

    float   _Mixing, _Add, _Mul, _DitheringSize,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 28

static const float3 _Palette[_Palette_Size] = 
{
    float3(0.0, 0.0, 0.0),
    float3(1.0, 1.0, 1.0),
    float3(0.5019608, 0.5019608, 0.5019608),
    float3(0.7529412, 0.7529412, 0.7529412),
    float3(0.4901961, 0.0, 0.0),
    float3(0.9803922, 0.0, 0.0),
    float3(0.5058824, 0.4980392, 0.0),
    float3(1.0, 0.9921569, 0.2352941),
    float3(0.1176471, 0.5019608, 0.09803922),
    float3(0.2745098, 1.0, 0.2352941),
    float3(0.09803922, 0.5058824, 0.5019608),
    float3(0.2352941, 1.0, 1.0),
    float3(0.0, 0.04313726, 0.4901961),
    float3(0.0, 0.1294118, 0.9803922),
    float3(0.4862745, 0.0, 0.4901961),
    float3(0.972549, 0.0, 0.9803922),
    float3(0.5058824, 0.4980392, 0.2705882),
    float3(1.0, 0.9960784, 0.5372549),
    float3(0.03137, 0.25098, 0.25098),
    float3(0.26666, 1.0, 0.53725),
    float3(0.0, 0.5176471, 0.9843137),
    float3(0.5372549, 1.0, 1.0),
    float3(0.0, 0.25882, 0.49411),
    float3(0.49019, 0.51372, 0.98431),
    float3(0.2, 0.12549, 0.98039),
    float3(0.98039, 0.51372, 0.49019),
    float3(0.4941176, 0.2431373, 0.03137255),
    float3(0.9843137, 0.4862745, 0.2705882),
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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

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

        int2 _Dith = int2(  fmod(In.x / fPixelWidth,   4.0), 
                            fmod(In.y / fPixelHeight,  4.0)
                        );

        int _Index = _Dith.x + _Dith.y * 4;
        float _DithValue = _Dithering[_Index];
                
        float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                
            float _MinDist = 1e9;
            int _IndexC = 0;
                
            for (int i = 0; i < _Palette_Size; i++)
            {
                float3 _PO = Fun_Convert(_Color);
                float3 _PL = Fun_Convert(_Palette[i]);
                    
                float _Dist = distance(_PO, _PL);
                    
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

technique tech_main { pass P0 { PixelShader = compile ps_3_0 Main(); } }
