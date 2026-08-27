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

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _RotX; 
    float _PointX;
    float _PointY;
    bool ____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool _____;
    bool _Blending_Mode;
    float _Mixing;
    int _ChannelRed;
    int _ChannelGreen; 
    int _ChannelBlue;
};

float _Mul;

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

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

float3 Fun_Rainbow(float2 UV)
{
    static const float _Frag = 6.28318;
    float3 _Render;
    
    float _Red = Fun_Channel(UV, _ChannelRed);
    float _Green = Fun_Channel(UV, _ChannelGreen);
    float _Blue = Fun_Channel(UV, _ChannelBlue);
    
    _Render.r = sin(_Frag * _Red + 0.0) * 0.5 + 0.5;
    _Render.g = sin(_Frag * _Green + 2.0) * 0.5 + 0.5;
    _Render.b = sin(_Frag * _Blue + 4.0) * 0.5 + 0.5;

    return _Render;
}

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    _Result.a = _Render_Texture.a;

        float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

        float2  _UV = Fun_RotationX(In.texCoord * _Average),
                _ScaleTemp = (float2(_ScaleX, _ScaleY)) * _Scale,
                _Pos = float2(-_PosX, _PosY);

        float3 _Render_Rainbow = Fun_Rainbow((_UV - _Pos) * _ScaleTemp);

    _Result.rgb += _Render_Rainbow.rgb * _Average * _Mixing;

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
