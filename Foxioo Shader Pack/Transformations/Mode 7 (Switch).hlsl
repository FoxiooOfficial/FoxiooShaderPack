/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (30.06.2024) */
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
    float _PosZ;
    bool ___;
    float _RotX;
    float _RotY;
    float _RotZ;
    bool ____;
    float _PointX;
    float _PointY;
    bool _____;
    float _OffsetX;
    float _Distortion;
    bool ______;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool _______;
    int _Looping_Mode;
    bool _Render_Sky;
    bool _Result;
    bool ________;    
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_Target;
};

/***********************************************************/
/* Mode 7 */
/***********************************************************/

float2 Fun_Mode7(float2 In)
{
    float2 _UV = In;

        _UV.x -= -_OffsetX + 0.5;
        _UV /= (In.y * _Distortion) - 0.5;

    return _UV * _PosZ;
}

float2 Fun_RotationX(float2 In)
{
    float2 _UV = float2((In.x + _PointX) / 2.0, (In.y + _PointY) / 2.0);
    float _RotX_Temp = _RotX * (3.14159265 / 180);

        _UV = mul(float2x2(cos(_RotX_Temp), sin(_RotX_Temp), -sin(_RotX_Temp), cos(_RotX_Temp)), _UV);

    return _UV;
}

float2 Fun_RotationY(float2 In)
{
    float _RotY_Temp = (_RotY - 180) * (3.14159265 / 180);

        In = 0.5 + mul(float2x2(cos(_RotY_Temp), sin(_RotY_Temp), -sin(_RotY_Temp), cos(_RotY_Temp)), In - 0.5);

        In.x = 1 - In.x;
    return In;
}

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(PS_INPUT In)
{
    PS_OUTPUT Out;

        float2 _In = In.texCoord;
        _In = Fun_RotationY(_In);

    float _RotZ_Temp = _RotZ * (3.14159265 / 180);

        float2 _In_Old = _In;
        _In.y += _RotZ_Temp;

        float2 _UV = Fun_Mode7(_In);
        float2 _Pos = float2(-_PosX, _PosY);
        float2 _Scale_Temp = (float2(_ScaleX, _ScaleY)) * _Scale;

    _UV = Fun_RotationX(_UV);
    _UV -= _Pos;
    _UV *= _Scale_Temp;

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

    float4 _Render = 1;
    if(_Result == false) { _Render = S2D_Image.Sample(S2D_ImageSampler, _UV); }
    else { _Render = S2D_Background.Sample(S2D_BackgroundSampler, _UV); }

        if (_Looping_Mode == 3 && (_UV.x < 0 || _UV.x > 1 || _UV.y < 0 || _UV.y > 1 || _UV.y < 0))
        {
            _Render = 0;
        }

        if(_Render_Sky == false)
        {
            if(_In_Old.y > (0.5 / _Distortion) - _RotZ_Temp)
            {
                _Render = 0;
            }
        }

    _Render *= In.Tint;

    Out.Color = _Render;

    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

        float2 _In = In.texCoord;
        _In = Fun_RotationY(_In);

    float _RotZ_Temp = _RotZ * (3.14159265 / 180);

        float2 _In_Old = _In;
        _In.y += _RotZ_Temp;

        float2 _UV = Fun_Mode7(_In);
        float2 _Pos = float2(-_PosX, _PosY);
        float2 _Scale_Temp = (float2(_ScaleX, _ScaleY)) * _Scale;

    _UV = Fun_RotationX(_UV);
    _UV -= _Pos;
    _UV *= _Scale_Temp;

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

    float4 _Render = 1;
    if(_Result == false) { Demultiply(_Render = S2D_Image.Sample(S2D_ImageSampler, _UV)); }
    else { _Render = S2D_Background.Sample(S2D_BackgroundSampler, _UV); }

        if (_Looping_Mode == 3 && (_UV.x < 0 || _UV.x > 1 || _UV.y < 0 || _UV.y > 1 || _UV.y < 0))
        {
            _Render = 0;
        }

        if(_Render_Sky == false)
        {
            if(_In_Old.y > (0.5 / _Distortion) - _RotZ_Temp)
            {
                _Render = 0;
            }
        }

    _Render *= In.Tint;

    _Render.rgb *= _Render.a;
    Out.Color = _Render;

    return Out;
}