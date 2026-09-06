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
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0, 0, 1, 0);
};

//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _ColorAlpha,
            _Size,
            _PosX,
            _PosY,

            _AlphaMul,
            _AlphaBack,

            fPixelWidth, fPixelHeight;

    float4 _Color, _ColorAccent;

/************************************************************/
/* Main */
/************************************************************/

static const int _Samples = 16;

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    
    float _Alpha = 0.0;
    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            _Alpha += tex2D(S2D_Image, In.texCoord + _Offset).a;
        }
    }
    
    _Alpha /= float(_Samples * _Samples);

    //float _Outer = saturate(_Alpha * _AlphaMul) * (1.0 - _Render_Texture.a);
    float _Inner = saturate((1.0 - _Alpha) * _AlphaMul) * _Render_Texture.a;

        float _Strength = saturate(_Inner);
        float _Mask = saturate((1.0 - _Render_Texture.a) + _AlphaBack);

        float4 _Render_Color = lerp(_ColorAccent, _Color, _Strength);
        _Render_Color.a = _Strength * _Mask * _ColorAlpha * _Mixing;

            float4 _Render = _Render_Texture;
            _Render.a *= _AlphaBack;

            float4 _Result;

        _Result.a = _Render_Color.a + _Render.a * (1.0 - _Render_Color.a);
        _Result.rgb = lerp(_Render.rgb, _Render_Color.rgb, _Render_Color.a / _Result.a);
        
    return _Result;
}
/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
