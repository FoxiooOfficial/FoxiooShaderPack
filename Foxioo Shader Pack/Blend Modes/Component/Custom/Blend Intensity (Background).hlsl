/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

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
    float4 Position : SV_POSITION;
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

    float _Div = _ColorMax - _V;
    if(_Div == 0.0) _Div = 1e7;

    if(_ColorMin < 0.0) { _Color = _V + (((_Color - _V) * _V) / (_V - _ColorMin)); }
    if(_ColorMax > 1.0) { _Color = _V + (((_Color - _V) * (1.0 - _V)) / _Div); }

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

/***********************************************************/

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Render, _Result;
        
            _Render.rgb = Fun_SetIntensity(_Render_Background.rgb, Fun_Intensity(_Render_Texture.rgb));
            _Result.rgb = lerp(_Render_Texture.rgb, _Render.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
