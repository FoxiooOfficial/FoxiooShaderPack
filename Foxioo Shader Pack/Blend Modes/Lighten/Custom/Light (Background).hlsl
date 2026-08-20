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
    float _Threshold;
    float _Mixing_Brightness;
    float _Brightness;
    float _Mixing;
    float _Alpha;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;};

cbuffer PS_PIXELSIZE : register(b1)
{
    float fPixelWidth;
    float fPixelHeight;
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

/************************************************************/
/* Main */
/************************************************************/

    // TODO: rewrite this nightmare.

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

    _Render_Texture.rgb *= _Alpha * _Render_Texture.a;

    float4 _Result = _Render_Texture;
    _Result.rgb *= _Brightness + (_Render_Background.rgb * _Mixing_Brightness);
    _Result.rgb += 1;

    if (_Result.a > _Threshold)
    {
        float _Alpha_Temp = ((_Result.r + _Result.g + _Result.b) / 3.0 - _Threshold) / (1.0 - _Threshold);
        float4 _Lerp = lerp(_Render_Background, float4(1, 1, 1, _Result.a * 2), _Alpha_Temp);
        _Result.rgb *= _Lerp.rgb;
    }

    _Result.rgb *= (_Render_Texture.rgb * _Mixing) + _Render_Background.rgb;

    _Result.a = _Render_Texture.a * _Alpha * _Render_Texture.a;

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
