/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/************************************************************/

/*  Special thanks to Daniel Ilett.

    The video from which I took help on how to do this effect: https://www.youtube.com/watch?v=iRegHo8_GBk */

/************************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

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
    bool _Blending_Mode;
    float _Mixing;
    float _Intensity;
    float4 _Color;
    bool _______;

	bool _Is_Pre_296_Build;
	bool ________;
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

float2 Fun_RotationX(float2 In: TEXCOORD)
{
    float2  _UV = float2((In.x - (_PointX + 0.5)) / 2.0, (In.y - (_PointY + 0.5)) / 2.0);
    float _RotXTemp = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotXTemp), sin(_RotXTemp), -sin(_RotXTemp), cos(_RotXTemp)), _UV);

    return _UV;
}

float Fun_CalculateGlint(float2 In, float _OffsetX, float _OffsetY, float _Scale, float _Intensity)
{
    return pow(1 - frac((sin((In.x - _OffsetX) * _Scale) / 2.0 + 0.5) * (cos((In.y + _OffsetY) * _Scale) / 2.0 + 0.5)), _Intensity);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float2 _In = Fun_RotationX(In.texCoord);
    float2 _UV = float2((_In.x + _PosX) * _ScaleX, (_In.y + _PosY) * _ScaleY) * _Scale;

    //float2 _UV_Glint = (1 - frac((sin(_UV.x) / 2.0 + 0.5) * (cos(_UV.y) / 2.0 + 0.5)));

    float _UV_Glint_1 = Fun_CalculateGlint(_UV, 0.3, 0.6, 0.75, _Intensity);
    float _UV_Glint_2 = Fun_CalculateGlint(_UV, 0.5, 1.5, 0.5, _Intensity);
    float _UV_Glint_3 = Fun_CalculateGlint(_UV, 0.66, -1.3, 0.25, _Intensity);

    float _UV_Glint_Sum = (_UV_Glint_1 + _UV_Glint_2 + _UV_Glint_3) / 3.0;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

        _Result.a = _Render_Texture.a;

        _Result.rgb += _Color.rgb * _UV_Glint_Sum * _Mixing * _Result.a;

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float2 _In = Fun_RotationX(In.texCoord);
    float2 _UV = float2((_In.x + _PosX) * _ScaleX, (_In.y + _PosY) * _ScaleY) * _Scale;

    //float2 _UV_Glint = (1 - frac((sin(_UV.x) / 2.0 + 0.5) * (cos(_UV.y) / 2.0 + 0.5)));

    float _UV_Glint_1 = Fun_CalculateGlint(_UV, 0.3, 0.6, 0.75, _Intensity);
    float _UV_Glint_2 = Fun_CalculateGlint(_UV, 0.5, 1.5, 0.5, _Intensity);
    float _UV_Glint_3 = Fun_CalculateGlint(_UV, 0.66, -1.3, 0.25, _Intensity);

    float _UV_Glint_Sum = (_UV_Glint_1 + _UV_Glint_2 + _UV_Glint_3) / 3.0;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

        _Result.a = _Render_Texture.a;

        _Result.rgb += _Color.rgb * _UV_Glint_Sum * _Mixing * _Result.a;
        _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}