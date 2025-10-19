/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

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
    float _Distortion;
    int _Looping_Mode;
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

float2 Fun_FishEye(float2 In)
{
    float2 _Center = float2(_PointX, _PointY);
    float2 _Rel = In - _Center;
    float _Ray = length(_Rel);
    float _Theta = atan2(_Rel.y, _Rel.x);

    float _Mode_Equidistant = _Ray + (_Ray * _Distortion * _Ray);
    float2 _UV = float2(cos(_Theta), sin(_Theta)) * _Mode_Equidistant;

    float2 _Result = lerp(_Rel, _UV, _Mixing) + _Center;
    return _Result;
}

float2 Fun_RotationX(float2 In: TEXCOORD)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Fix = _RotX * (3.14159265 / 180);

        _UV = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

        float2  _Pos = float2(_PosX, _PosY),
                _UV = Fun_RotationX((In.texCoord + _Pos));
                _UV = ((_UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        _UV = Fun_FishEye(_UV);


    if(_Looping_Mode == 0)
    {
        _UV = frac(_UV);
    }
    else if(_Looping_Mode == 1)
    {
        _UV /= 2;
        _UV = frac(_UV);
        _UV = abs(_UV * 2.0 - 1.0);
    }

    float4 _Render_Texture_UV = S2D_Image.Sample(S2D_ImageSampler, _UV);
    float4 _Render_Background_UV = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

    float4 _Result = _Blending_Mode ? _Render_Background_UV : _Render_Texture_UV;

            if (_Looping_Mode == 3 && any(_UV < 0 || _UV > 1))
            {
                _Result = 0;
            }

        _Result.a *= _Render_Texture_UV.a;

        _Result *= In.Tint;

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

        float2  _Pos = float2(_PosX, _PosY),
                _UV = Fun_RotationX((In.texCoord + _Pos));
                _UV = ((_UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        _UV = Fun_FishEye(_UV);

    if(_Looping_Mode == 0)
    {
        _UV = frac(_UV);
    }
    else if(_Looping_Mode == 1)
    {
        _UV /= 2;
        _UV = frac(_UV);
        _UV = abs(_UV * 2.0 - 1.0);
    }

    float4 _Render_Texture_UV = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _UV));
    float4 _Render_Background_UV = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

    float4 _Result = _Blending_Mode ? _Render_Background_UV : _Render_Texture_UV;

            if (_Looping_Mode == 3 && any(_UV < 0 || _UV > 1))
            {
                _Result = 0;
            }

        _Result.a *= _Render_Texture_UV.a;

        _Result *= In.Tint;

        _Result.rgb *= _Result.a;
        Out.Color = _Result;

    return Out;
}