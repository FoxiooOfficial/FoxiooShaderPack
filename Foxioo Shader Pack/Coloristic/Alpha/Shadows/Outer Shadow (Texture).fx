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

static const int _Samples = 4;

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    
    float _Alpha = 0.0, _Idx = 0.0;

    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            
            _Alpha += tex2D(S2D_Image, In + _Offset).a;
            _Idx += 1.0;
        }
    }
    
    _Alpha /= _Idx;

        float _OuterMask = (1.0 - _Render_Texture.a) * _Alpha;
    
        _OuterMask = saturate(_OuterMask * _AlphaMul);

            float4 _OutlineColor = lerp(_ColorAccent, _Color, _OuterMask);
            _OutlineColor.a = (1.0 - _Render_Texture.a) * _ColorAlpha;

        float4 _Render = _Render_Texture;
        _Render.a *= _AlphaBack;

        _Render = lerp(_Render, _OutlineColor, _OuterMask * _Mixing);

    return _Render;
}
/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
