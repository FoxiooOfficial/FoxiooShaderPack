/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _RotX;
    bool ____;
    float _PointX;
    float _PointY;
    bool _____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ______;
    float _Mixing;
	bool _Is_Pre_296_Build;
	bool _______;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
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

float2 Fun_RotationX(float2 In, float _RotExtra, float _Scaler)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Fix = (_RotX + _RotExtra) * (3.14159265 / 180) / _Scaler;

        _UV = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}

float2 Fun_UV(float _UVRot, float2 _UVPos, float _UVScaler, float2 UV)
{
    UV = Fun_RotationX(UV, _UVRot, _UVScaler) + _UVPos / _UVScaler;
    UV = (UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale + float2(_PointX, _PointY);
    return frac(UV * _UVScaler);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

        float2 _Pos = float2(_PosX, _PosY);
        float4 _Result = 0;

        float4 _Render = (S2D_Image.Sample(S2D_ImageSampler, Fun_UV(236, _Pos, 3, In.texCoord))) * In.Tint;
        float _Lum = _Render.r * _Render.g * _Render.b * _Render.a;
        _Result += lerp(_Render, _Render_Texture, _Lum);

        _Result += (S2D_Image.Sample(S2D_ImageSampler, Fun_UV(206, _Pos, 2, In.texCoord))) * In.Tint;
        _Result += (S2D_Image.Sample(S2D_ImageSampler, Fun_UV(127, _Pos, 1, In.texCoord))) * In.Tint;
        _Result += (S2D_Image.Sample(S2D_ImageSampler, Fun_UV(2, _Pos, 0.5, In.texCoord))) * In.Tint;

        _Result /= 3.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    Out.Color = _Result;
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _Pos = float2(_PosX, _PosY);
        float4 _Result = 0;

        float4 _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, Fun_UV(236, _Pos, 3, In.texCoord))) * In.Tint;
        float _Lum = _Render.r * _Render.g * _Render.b * _Render.a;
        _Result += lerp(_Render, _Render_Texture, _Lum);

        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, Fun_UV(206, _Pos, 2, In.texCoord))) * In.Tint;
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, Fun_UV(127, _Pos, 1, In.texCoord))) * In.Tint;
        _Result += Demultiply(S2D_Image.Sample(S2D_ImageSampler, Fun_UV(2, _Pos, 0.5, In.texCoord))) * In.Tint;

        _Result /= 3.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}