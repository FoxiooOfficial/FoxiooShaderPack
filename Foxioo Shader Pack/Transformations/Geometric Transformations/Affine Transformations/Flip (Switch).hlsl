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
    int _Looping_Mode;
    bool _Blending_Mode;
    float _Mixing;
    bool _X;
    bool _Y;
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

float2 Fun_RotationX(float2 In)
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

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    float4 _Render = 0;

    float2  _Pos = float2(_PosX, _PosY),
        UV = Fun_RotationX((In.texCoord + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        float2 _UV_Temp = UV;
        if(_X) _UV_Temp.x = 1.0 - UV.x;
        if(_Y) _UV_Temp.y = 1.0 - UV.y;

        UV = lerp(UV, _UV_Temp, _Mixing);

            if(_Looping_Mode == 0)
            {
                UV = frac(UV);
            }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint; }
    else {                      _Render = float4(S2D_Background.Sample(S2D_BackgroundSampler, UV).rgb, _Render_Texture.a);    }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        {
            _Render = 0;
        }

    Out.Color = _Render;
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
    float4 _Render = 0;

    float2  _Pos = float2(_PosX, _PosY),
        UV = Fun_RotationX((In.texCoord + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        float2 _UV_Temp = UV;
        if(_X) _UV_Temp.x = 1.0 - UV.x;
        if(_Y) _UV_Temp.y = 1.0 - UV.y;

        UV = lerp(UV, _UV_Temp, _Mixing);

            if(_Looping_Mode == 0)
            {
                UV = frac(UV);
            }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint; }
    else {                      _Render = float4(S2D_Background.Sample(S2D_BackgroundSampler, UV).rgb, _Render_Texture.a);    }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        {
            _Render = 0;
        }

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}
