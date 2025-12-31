/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (29.12.2025) */
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

Texture2D<float4> S2D_NormalMap : register(t2);
SamplerState S2D_NormalMapSampler : register(s2);

Texture2D<float4> S2D_Overlay : register(t3);
SamplerState S2D_OverlaySampler : register(s3);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _ReflectionMixing;
    float _ReflectionCut;
    float4 _ColorMul;
    float4 _ColorAdd;
    float _SafeAlphaMixing;
    float _SafeAlphaTransition;
    float _SafeAlphaPower;
    bool __;
    Texture2D _Texture_NormalMap;
    float _NormalMapX;
    float _NormalMapY;
    float _NormalMapStrength;
    float _NormalMapScaleX;
    float _NormalMapScaleY;
    bool ___;
    Texture2D _Texture_Overlay;
    float _OverlayMixing;
    float _OverlayAddition;
    float _OverlayX;
    float _OverlayY;
    float _OverlayScaleX;
    float _OverlayScaleY;
    bool ____;
    float _Line;
    float4 _ColorLine;
    float _LineMixing;
    float _LineAmbient;
    float _LineAmbientMixing;
    bool _____;
    float _PointX;
    float _PointY;
    float _RotX;
    bool _X;
    bool _Y;
    bool ______;
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

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float2 _UV = In;
    float _RotX_Fix = _RotX * (3.14159265 / 180.0);

        _UV = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), _UV - _Points);

    return _UV;
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float2 In_Rot = Fun_RotationX(In.texCoord);

    float _Fix = lerp(1.0, 1.0 - (saturate((abs(In_Rot.y - _SafeAlphaTransition) * 2.0) * (abs(0.5 - _SafeAlphaTransition) * _SafeAlphaPower))), _SafeAlphaMixing);

    float4 _Render_Texture = (S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;

    float3 _Render_Normal = normalize(S2D_NormalMap.Sample(S2D_NormalMapSampler, frac(In.texCoord + float2(_NormalMapX , _NormalMapY)) * float2(_NormalMapScaleX, _NormalMapScaleY)).rgb * 2.0 - 1.0);
    float2 _Offset = _Render_Normal.xy * _NormalMapStrength;

    float4 _Render_Overlay = S2D_Overlay.Sample(S2D_OverlaySampler, frac(In.texCoord + float2(_OverlayX, _OverlayY) + _Offset) * float2(_OverlayScaleX, _OverlayScaleY));

        float4 _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

                float4 _Reflect = S2D_Background.Sample(S2D_BackgroundSampler, frac(float2(abs(_X - In.texCoord.x) + _Offset.x, abs(_Y - In.texCoord.y) + _Offset.y)));
                //_Reflect.rgb = _Reflect.rgb * _ColorMul.rgb + _ColorAdd.rgb;

                    if(In_Rot.y > _ReflectionCut - _Offset.y) 
                    {
                        _Result = lerp(_Result, _Reflect, _ReflectionMixing * _Fix);
                        _Result.rgb = _Result.rgb * _ColorMul.rgb + _ColorAdd.rgb;
                        _Result.rgb += saturate((1.0 - ((In_Rot.y - _ReflectionCut + _Offset.y) * _LineAmbient)) * _LineAmbientMixing * _ColorLine.rgb);

                        _Result.rgb = lerp(_Result.rgb, lerp(_Render_Overlay.rgb, _Render_Overlay.rgb + _Result.rgb, _OverlayAddition), _OverlayMixing * _Render_Overlay.a);

                        if(In_Rot.y < _ReflectionCut - _Offset.y + _Line) _Result.rgb += _ColorLine.rgb * _LineMixing;
                    }

                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
            _Result.a *= _Render_Texture.a;

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

    float2 In_Rot = Fun_RotationX(In.texCoord);

    float _Fix = lerp(1.0, 1.0 - (saturate((abs(In_Rot.y - _SafeAlphaTransition) * 2.0) * (abs(0.5 - _SafeAlphaTransition) * _SafeAlphaPower))), _SafeAlphaMixing);

    //float _SafeAlpha = (1.0 - saturate((In_Rot.y) - _Fix) / (1.0 - _Fix)) * (_Fix * 16.);

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;

    float3 _Render_Normal = normalize(S2D_NormalMap.Sample(S2D_NormalMapSampler, frac(In.texCoord + float2(_NormalMapX , _NormalMapY)) * float2(_NormalMapScaleX, _NormalMapScaleY)).rgb * 2.0 - 1.0);
    float2 _Offset = _Render_Normal.xy * _NormalMapStrength;

    float4 _Render_Overlay = S2D_Overlay.Sample(S2D_OverlaySampler, frac(In.texCoord + float2(_OverlayX, _OverlayY) + _Offset) * float2(_OverlayScaleX, _OverlayScaleY));

        float4 _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

                float4 _Reflect = S2D_Background.Sample(S2D_BackgroundSampler, frac(float2(abs(_X - In.texCoord.x) + _Offset.x, abs(_Y - In.texCoord.y) + _Offset.y)));
                //_Reflect.rgb = _Reflect.rgb * _ColorMul.rgb + _ColorAdd.rgb;

                    if(In_Rot.y > _ReflectionCut - _Offset.y) 
                    {
                        _Result = lerp(_Result, _Reflect, _ReflectionMixing * _Fix);
                        _Result.rgb = _Result.rgb * _ColorMul.rgb + _ColorAdd.rgb;
                        _Result.rgb += saturate((1.0 - ((In_Rot.y - _ReflectionCut + _Offset.y) * _LineAmbient)) * _LineAmbientMixing * _ColorLine.rgb);

                        _Result.rgb = lerp(_Result.rgb, lerp(_Render_Overlay.rgb, _Render_Overlay.rgb + _Result.rgb, _OverlayAddition), _OverlayMixing * _Render_Overlay.a);

                        if(In_Rot.y < _ReflectionCut - _Offset.y + _Line) _Result.rgb += _ColorLine.rgb * _LineMixing;
                    }

                _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
            _Result.a *= _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}