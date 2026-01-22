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
    float _Mixing;
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
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

/*  *NOT* All color calculations are taken from: 
    https://printtechnologies.org/standards/files/pdf-reference-1.6-addendum-blend-modes.pdf */

float Fun_Value(float3 _Result)
{
    return max(_Result.r, max(_Result.g, _Result.b));
}

float3 Fun_ClipColor(float3 _Color)
{
    float _V = Fun_Value(_Color);
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    if(_ColorMin < 0) { _Color = _V + (((_Color - _V) * _V) / (_V - _ColorMin)); }
    if(_ColorMax > 1) { _Color = _V + (((_Color - _V) * (1 - _V)) / max(1e6, _ColorMax - _V)); }

    return _Color;
}

float Fun_Intensity(float3 _Result)
{
    return (_Result.r + _Result.g + _Result.b) / 3.0;
}

float3 Fun_SetIntensity(float3 _Color, float _I)
{
    float _GetIntensity = _I - Fun_Intensity(_Color);
    _Color += _GetIntensity;

    return Fun_ClipColor(_Color);
}

float Fun_Sat(float3 _Color)
{
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    return _ColorMax - _ColorMin;
}

float3 Fun_SetSat(float3 _Color, float _Sat)
{
    float _CurSat = Fun_Sat(_Color);

    if (_CurSat > 0) { _Color = lerp(0.5, _Color, _Sat / _CurSat); }
    else { _Color = 0.5; }
    
    return _Color;
}

/***********************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Render, _Result;
    
    _Render.rgb = Fun_SetIntensity(_Render_Background.rgb, Fun_Intensity(_Render_Texture.rgb));


    _Result.rgb = lerp(_Render_Texture.rgb, _Render.rgb, _Mixing);
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Render, _Result;
    
    _Render.rgb = Fun_SetIntensity(_Render_Background.rgb, Fun_Intensity(_Render_Texture.rgb));

    _Result.rgb = lerp(_Render_Texture.rgb, _Render.rgb, _Mixing);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}