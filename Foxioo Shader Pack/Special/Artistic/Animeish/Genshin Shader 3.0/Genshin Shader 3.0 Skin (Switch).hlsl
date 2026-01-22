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

Texture2D<float4> S2D_RimMap : register(t2);
SamplerState S2D_RimMapSampler : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    bool _Blending_Mode;
    float _Mixing;
    float _NoLightEffect;
    float _NoLightMapStart;
    float _NoLightMapEnd;
    float _NoLightMapColorStart;
    float _NoLightMapColorEnd;
    bool ___;
    float _LumSize;  
    float _FaceColorMixing; 
    float4 _FaceColor;         
    float4 _ShadowColor;  
    float4 _ShadowColorSecond;      
    float _FaceShadowThreshold;
    float _FaceShadowAlpha;
    float _ShadowThreshold;
    float _FaceShadowStart;
    float _FaceShadowEnd;
    float _FaceShadowColorStart;
    float _FaceShadowColorEnd;
    Texture2D _RimLightTexture;
    float4 _RimLightColor;
    float _RimlightSize; 
    bool ____;
	bool _Is_Pre_296_Build;
	bool _____;
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

float3 Fun_Gradient(float _Lum, float _RampStart, float _RampEnd, float3 _ColorStart, float3 _ColorEnd)
{
    return lerp(_ColorStart, _ColorEnd, saturate((_Lum - _RampStart) / (_RampEnd - _RampStart)));
}

/* If no lightmp */
float3 Fun_NoLightMap(float _Lum)
{
    return Fun_Gradient(_Lum, _NoLightMapStart, _NoLightMapEnd, _NoLightMapColorStart, _NoLightMapColorEnd);
}

/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; */

/* Base kolor */
float3 Fun_BaseColor(float _Lum)
{
    return Fun_Gradient(_Lum, _FaceShadowStart, _FaceShadowEnd, _FaceShadowColorStart, _FaceShadowColorEnd) * _FaceColor.rgb;
}

/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; */
    
/* Rim Light */

float3 Fun_RimLight(float2 In, float2 rimCoords)
{
    float rimMask = step(_RimlightSize * _RimlightSize, dot(rimCoords, rimCoords));
    return rimMask * _RimLightColor.rgb;
}

/* ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; */

/* Face Shadows */
float Fun_FaceShadows(float _Lum)
{
    return 1.0 - step(_FaceShadowThreshold, _Lum);
}

/* +Shadows */
float3 Fun_PlusShadows(float _Mix, float3 _Color, float _Lum)
{
    float3 _Render = _NoLightEffect ? Fun_NoLightMap(_Lum).rgb : _ShadowColor.rgb;
    return lerp(_Color, _Color * _Render, _Mix);
}

float3 Fun_SecondShadow(float _Mix, float3 _Color)
{
    return lerp(_Color, _Color * _ShadowColorSecond.rgb, _Mix);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;
    float4 _Render_RimMap = S2D_RimMap.Sample(S2D_RimMapSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

        float _Lum = dot(_Result.rgb, float3(0.299, 0.587, 0.114)) * _LumSize;

            float3 _BaseColor = Fun_BaseColor(_Lum);
    
        float _FaceShadowMask = Fun_FaceShadows(_Lum);
        float3 _FaceShadowEffect = lerp(_BaseColor, _BaseColor * _ShadowColor.rgb, _FaceShadowMask);
    
        float3 _ShadowEffect = Fun_PlusShadows(_FaceColorMixing / lerp(_Lum, 1, _FaceShadowAlpha), _FaceShadowEffect, _Lum);
    
        float3 _SecondShadowEffect = Fun_SecondShadow(_ShadowThreshold, _ShadowEffect);
    
        float3 _RimLightEffect = Fun_RimLight(In.texCoord, _Render_RimMap.rg);

        _ShadowEffect = lerp(_RimLightEffect, _SecondShadowEffect, _RimlightSize);
         
        _Result.rgb = lerp(_Result.rgb, _ShadowEffect.rgb, _Mixing);
        _Result.a   = _Render_Texture.a;

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
    float4 _Render_RimMap = Demultiply(S2D_RimMap.Sample(S2D_RimMapSampler, In.texCoord));


        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

        float _Lum = dot(_Result.rgb, float3(0.299, 0.587, 0.114)) * _LumSize;

            float3 _BaseColor = Fun_BaseColor(_Lum);
    
        float _FaceShadowMask = Fun_FaceShadows(_Lum);
        float3 _FaceShadowEffect = lerp(_BaseColor, _BaseColor * _ShadowColor.rgb, _FaceShadowMask);
    
        float3 _ShadowEffect = Fun_PlusShadows(_FaceColorMixing / lerp(_Lum, 1, _FaceShadowAlpha), _FaceShadowEffect, _Lum);
    
        float3 _SecondShadowEffect = Fun_SecondShadow(_ShadowThreshold, _ShadowEffect);
    
        float3 _RimLightEffect = Fun_RimLight(In.texCoord, _Render_RimMap.rg);

        _ShadowEffect = lerp(_RimLightEffect, _SecondShadowEffect, _RimlightSize);
         
        _Result.rgb = lerp(_Result.rgb, _ShadowEffect.rgb, _Mixing);
        _Result.a   = _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
