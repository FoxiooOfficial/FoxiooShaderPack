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
    float _DistortionXCenter;
    float _DistortionXEdge;
    float _DistortionXRadius;
    float _DistortionXExponent;
    float _DistortionYOffset;
    float _DistortionYOffsetFactor;
    float _DistortionYPow;
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

float Fun_Jevil(float In)
{
    float _UV = In - _PosX * _ScaleX * _Scale;

    float _Distance = abs(_UV - 0.5);
        float _Size = saturate(_Distance / _DistortionXRadius);
        float _Smooth = pow(_Size, _DistortionXExponent);

    float _Scaler = lerp(_DistortionXCenter, _DistortionXEdge, _Smooth);
    float _In = (_UV - 0.5) / _Scaler + 0.5;

    float _Out = _In + _PosX  * _ScaleX * _Scale;

    return _Out;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{ 
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    float4 _Render = 0;

    float2  _Pos = float2(_PosX, _PosY),
        UV = ((In.texCoord + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        float2 UV_Extra = UV;

        float _In_Offset = distance(In.texCoord.x + _DistortionYOffsetFactor, 0.5);
        float _In_Dist = abs(In.texCoord.x - 0.5) - _PosX;

        float _UV_Distortion = pow(_In_Offset, _DistortionYPow);
            UV_Extra.y += _UV_Distortion * _DistortionYOffset;

        float _In_Scale = lerp(2.0, 1.0, (_In_Dist * 2.0));
            UV_Extra.x = Fun_Jevil(UV.x);

            UV = lerp(UV, UV_Extra, _Mixing);

        UV = frac(UV);

    if(_Blending_Mode == 0) {   _Render = S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint; }
    else {                      _Render = S2D_Background.Sample(S2D_BackgroundSampler, UV) * _Render_Texture.a;    }

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
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    float4 _Render = 0;

    float2  _Pos = float2(_PosX, _PosY),
        UV = ((In.texCoord + _Pos));
        UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

        float2 UV_Extra = UV;

        float _In_Offset = distance(In.texCoord.x + _DistortionYOffsetFactor, 0.5);
        float _In_Dist = abs(In.texCoord.x - 0.5) - _PosX;

        float _UV_Distortion = pow(_In_Offset, _DistortionYPow);
            UV_Extra.y += _UV_Distortion * _DistortionYOffset;

        float _In_Scale = lerp(2.0, 1.0, (_In_Dist * 2.0));
            UV_Extra.x = Fun_Jevil(UV.x);

            UV = lerp(UV, UV_Extra, _Mixing);

        UV = frac(UV);

    if(_Blending_Mode == 0) {   _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint; }
    else {                      _Render = S2D_Background.Sample(S2D_BackgroundSampler, UV) * _Render_Texture.a;    }

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}
