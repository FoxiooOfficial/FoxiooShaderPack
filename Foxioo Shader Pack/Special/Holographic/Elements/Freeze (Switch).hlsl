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

Texture2D<float4> _Texture_Ice : register(t2);
SamplerState _Texture_Ice_Sampler : register(s2);

Texture2D<float4> _Texture_Mask : register(t3);
SamplerState _Texture_Mask_Sampler : register(s3);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Offset;
    //Texture2D _Texture_Ice;
    //Texture2D _Texture_Mask;
    bool __;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
  float2 bgCoord : TEXCOORD1;
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

float Fun_Luminance(float3 _Result) {
    return 0.299 * _Result.r + 0.587 * _Result.g + 0.114 * _Result.b;
}


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

float4 Main(PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord, false) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);
    float4 _Render_Ice = _Texture_Ice.Sample(_Texture_Ice_Sampler, In.texCoord);
    float4 _Render_Mask = _Texture_Mask.Sample(_Texture_Mask_Sampler, In.texCoord);

        float4 _Result;
        float4 _Render;

            float2 _Size = float2(fPixelWidth, fPixelHeight);
            if(!_Blending_Mode)
            {
                _Result = S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset))) * In.Tint;
                _Render = _Render_Texture;
            }
            else
            {
                _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(In.bgCoord + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
                _Render = _Render_Background;
            }

        _Result.rgb = _Result.rgb * Fun_Luminance(_Render_Ice.rgb) + Fun_Luminance(_Render_Ice.rgb) * 0.75 * _Render_Ice.rgb;
        _Result.rgb += Fun_Luminance(_Render_Ice.rgb) * 0.35;

        _Result = lerp(_Render, _Result, smoothstep(Fun_Luminance(_Render_Ice.rgb) * (1.0 - abs(_Mixing)), Fun_Luminance(_Render_Ice.rgb), abs(_Mixing) * (1.0 - _Render_Mask.r)));
        
        if(_Blending_Mode)
            _Result.a = _Render_Texture.a;

	return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}