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
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Phase;
    float _PosX;
    float _PosY;
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

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
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

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;

            float3 _Lum = Fun_Luminance(_Render.rgb);
            _Lum *= _Lum;

                float2 _UV = In.texCoord + float2(_PosX, _PosY);

                    _Lum.r = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.r + _Lum.r * 0.2 + 4.0))) * _Render.r;
                    _Lum.g = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.g + _Lum.g * 0.2 + 2.0))) * _Render.g;
                    _Lum.b = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.b + _Lum.b * 0.2 + 0.0))) * _Render.b;

                //_Lum = abs(_Lum);

        _Render.rgb = lerp(_Render.rgb, pow(abs(_Render.rgb * 0.45 + 0.75 * (_Lum * _Render.rgb * 0.5 + _Lum * 0.5)), 2.2), _Mixing);
    
    _Render.a = _Render_Texture.a;
    return _Render;
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
