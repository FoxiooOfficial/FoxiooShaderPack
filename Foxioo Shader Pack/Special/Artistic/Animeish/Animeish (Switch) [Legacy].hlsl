/***********************************************************/

/* Shader author: Foxioo */
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
    bool _Blending_Mode;
    float _Mixing;
    float _ColorSteps;
    float _Saturation;
    bool ___;
    float _ShadowThreshold;
    float _ShadowAlpha;
    bool ____;
    float4 _OutlineColor;
    float _OutlineThreshold;
    float _OutlineAntialiasing;
    float _OutlineScale;
    float _OutlineAlpha;
    bool _____;

	bool _Is_Pre_296_Build;
	bool ______;
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

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_ColorRamp(float4 _Color, float _Steps)
{
    _Color.rgb = floor(_Color.rgb * _Steps) / _Steps;
    return _Color;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result, _GradientX, _GradientY = 0;

    if(_Blending_Mode == 0)
    {
        _Result = _Render_Texture * _Mixing;
    }
    else
    {
        _Result = _Render_Background * _Mixing;
    }

    float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

    // Saturation
    _Result.rgb = _Average * (1 - (_Saturation / 50.0)) + _Result.rgb * (_Saturation / 50.0);

    // Shadow
    if(_Average < _ShadowThreshold)
        _Result.rgb *= _Average + (1 - (_ShadowAlpha + _ShadowThreshold));

    // Outline
    if(_Blending_Mode == 0)
    {
        _GradientX = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(fPixelWidth, 0)) * In.Tint - S2D_Image.Sample(S2D_ImageSampler, In.texCoord - float2(fPixelWidth, 0)) * In.Tint;
        _GradientY = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0, fPixelHeight)) * In.Tint - S2D_Image.Sample(S2D_ImageSampler, In.texCoord - float2(0, fPixelHeight)) * In.Tint;
    }
    else
    {
        _GradientX = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(fPixelWidth, 0)) * In.Tint - S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - float2(fPixelWidth, 0)) * In.Tint;
        _GradientY = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0, fPixelHeight)) * In.Tint - S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - float2(0, fPixelHeight)) * In.Tint;       
    }

    float _EdgeDetection = (length(_GradientX.rgb) + length(_GradientY.rgb)) * _OutlineScale;
    float _AntialiasedOutline = smoothstep(_OutlineThreshold - _OutlineAntialiasing, _OutlineThreshold + _OutlineAntialiasing, _EdgeDetection);

    if (_AntialiasedOutline > _OutlineThreshold)
    {
        _Result = lerp(_Result, _OutlineColor, _OutlineAlpha * _AntialiasedOutline);
    }

    // Color Ramp
    _Result = Fun_ColorRamp(_Result, _ColorSteps);

    _Result.a = _Render_Texture.a;

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result, _GradientX, _GradientY = 0;

    if(_Blending_Mode == 0)
    {
        _Result = _Render_Texture * _Mixing;
    }
    else
    {
        _Result = _Render_Background * _Mixing;
    }

    float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

    // Saturation
    _Result.rgb = _Average * (1 - (_Saturation / 50.0)) + _Result.rgb * (_Saturation / 50.0);

    // Shadow
    if(_Average < _ShadowThreshold)
        _Result.rgb *= _Average + (1 - (_ShadowAlpha + _ShadowThreshold));

    // Outline
    if(_Blending_Mode == 0)
    {
        _GradientX = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(fPixelWidth, 0))) * In.Tint - Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord - float2(fPixelWidth, 0))) * In.Tint;
        _GradientY = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0, fPixelHeight))) * In.Tint - Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord - float2(0, fPixelHeight))) * In.Tint;
    }
    else
    {
        _GradientX = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(fPixelWidth, 0)) * In.Tint - S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - float2(fPixelWidth, 0)) * In.Tint;
        _GradientY = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0, fPixelHeight)) * In.Tint - S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - float2(0, fPixelHeight)) * In.Tint;       
    }

    float _EdgeDetection = (length(_GradientX.rgb) + length(_GradientY.rgb)) * _OutlineScale;
    float _AntialiasedOutline = smoothstep(_OutlineThreshold - _OutlineAntialiasing, _OutlineThreshold + _OutlineAntialiasing, _EdgeDetection);

    if (_AntialiasedOutline > _OutlineThreshold)
    {
        _Result = lerp(_Result, _OutlineColor, _OutlineAlpha * _AntialiasedOutline);
    }

    // Color Ramp
    _Result = Fun_ColorRamp(_Result, _ColorSteps);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
