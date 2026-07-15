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

    float   _Mixing, _Add, _Mul;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 16

static const float3 _Palette[_Palette_Size] = 
{
    float3(0.87, 0.87, 0.87),
    float3(0.74, 0.74, 0.74),
    float3(0.6, 0.6, 0.6),
    float3(0.47, 0.47, 0.47),
    float3(0.33, 0.33, 0.33),
    float3(0.19, 0.19, 0.19),
    float3(0.0, 0.27, 0.59),
    float3(0.95, 0.94, 0.22),
    float3(0.21, 0.8, 0.18),
    float3(0.85, 0.0, 0.0),
    float3(0.95, 0.94, 0.75),
    float3(0.35, 0.54, 0.11),
    float3(0.99, 0.73, 0.17),
    float3(0.13, 0.75, 0.99),
    float3(0.0, 0.0, 0.0),
    float3(1.0, 1.0, 1.0),
};

float3 Fun_Convert(float3 _Color)
{
    float3 _Low = _Color / 12.92;
    float3 _High = pow((_Color + 0.055) / 1.055, 2.4);

        return lerp(_High, _Low, step(_Color, float3(0.04045, 0.04045, 0.04045)));
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

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

        float3 _Lin = Fun_Convert(_Result.rgb);
        float _Min = 1e9;
        int _Final = 0;

            for (int i = 0; i < _Palette_Size; ++i)
            {
                float3 _LinP = Fun_Convert(_Palette[i]);
                float _Dist = dot(_Lin - _LinP, _Lin - _LinP);

                if (_Dist < _Min) { _Min = _Dist; _Final = i; }
            }

            _Result.rgb = _Palette[_Final];

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
