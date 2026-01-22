/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/*  Special thanks to 小二今天吃啥啊 (Xiao Er Jin Tian Chi Sha A) and No_Tables
    The video from which I took help on how to do this effect: https://www.youtube.com/watch?v=yM5wwLaARUI */

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);
sampler2D S2D_RimMap : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
    
            _NoLightMapStart,   _NoLightMapEnd,     _NoLightMapColorStart,    _NoLightMapColorEnd,
            _FaceShadowStart,     _FaceShadowEnd,     _FaceShadowColorStart,    _FaceShadowColorEnd,

            _FaceShadowThreshold, _ShadowThreshold, _FaceShadowAlpha,
            
            _FaceColorMixing, _LumSize, 
            
            _RimlightSize;

    bool    _Blending_Mode, _NoLightEffect;

    float4  _FaceColor,
            _RimLightColor,
            _ShadowColor,
            _ShadowColorSecond;

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

/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture    = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    float3 _Render_RimMap     = tex2D(S2D_RimMap, In);
    
    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    
    float _Lum = dot(_Result.rgb, float3(0.299, 0.587, 0.114)) * _LumSize;
    
    float3 _BaseColor = Fun_BaseColor(_Lum);
    
    float _FaceShadowMask = Fun_FaceShadows(_Lum);
    float3 _FaceShadowEffect = lerp(_BaseColor, _BaseColor * _ShadowColor.rgb, _FaceShadowMask);
    
    float3 _ShadowEffect = Fun_PlusShadows(_FaceColorMixing / lerp(_Lum, 1, _FaceShadowAlpha), _FaceShadowEffect, _Lum);
    
    float3 _SecondShadowEffect = Fun_SecondShadow(_ShadowThreshold, _ShadowEffect);
    
    float3 _RimLightEffect = Fun_RimLight(In, _Render_RimMap.rg);

    _ShadowEffect = lerp(_RimLightEffect, _SecondShadowEffect, _RimlightSize);
         
    _Result.rgb = lerp(_Result.rgb, _ShadowEffect.rgb, _Mixing);
    _Result.a   = _Render_Texture.a;
    
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
