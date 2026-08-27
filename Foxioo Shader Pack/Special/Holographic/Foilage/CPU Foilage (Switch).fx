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

    float   _Mixing,
            _PosX, _PosY,
            _PointX, _PointY,
            _RotX,
            _ScaleX, _ScaleY, _Scale;

    bool    _Blending_Mode;

    int     _ChannelRed, _ChannelGreen, _ChannelBlue;

/***********************************************************/
/* Main */
/***********************************************************/

#define POINTS float2(_PointX, _PointY)
#define RAD 0.01745329251

float2 Fun_RotationX(float2 In)
{
    float2 UV;
    float _Sin, _Cos;
    sincos(RAD * _RotX, _Sin, _Cos);

        UV = POINTS + mul(float2x2(_Cos, _Sin, -_Sin, _Cos), In - POINTS);

    return UV;
}

float Fun_Channel(float2 UV, int _Mode)
{
    if(_Mode == 0)
        return UV.x;
    
    else if(_Mode == 1)
        return UV.y;

    else
        return UV.x + UV.y;
}

float3 Fun_Rainbow(float2 In)
{
    static const float _Frag = 6.28318;
    float3 _Render;
    
    float _Red = Fun_Channel(In, _ChannelRed);
    float _Green = Fun_Channel(In, _ChannelGreen);
    float _Blue = Fun_Channel(In, _ChannelBlue);
    
    _Render.r = sin(_Frag * _Red + 0.0) * 0.5 + 0.5;
    _Render.g = sin(_Frag * _Green + 2.0) * 0.5 + 0.5;
    _Render.b = sin(_Frag * _Blue + 4.0) * 0.5 + 0.5;

    return _Render;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    _Result.a = _Render_Texture.a;

        float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

        float2  _UV = Fun_RotationX(In * _Average),
                _ScaleTemp = (float2(_ScaleX, _ScaleY)) * _Scale,
                _Pos = float2(-_PosX, _PosY);

        float3 _Render_Rainbow = Fun_Rainbow((_UV - _Pos) * _ScaleTemp);

    _Result.rgb += _Render_Rainbow.rgb * _Average * _Mixing;

    return _Result;
}

/***********************************************************/
/* Tech Main */
/***********************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
