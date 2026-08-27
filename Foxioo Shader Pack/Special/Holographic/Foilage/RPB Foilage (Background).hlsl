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
    float _Mixing;
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

        float4 _Result = _Render_Background * float4(0.1, 1.0, 1.0, 1.0);

            float3 _Render = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + sin(Fun_Luminance(_Render_Texture.rgb + _Render_Background.rgb) * 3.14 + Fun_Luminance(_Render_Background.rgb) + Fun_Luminance(_Render_Texture.rgb)) * 0.05).rgb * In.Tint.rgb;

            const float3 _ColorR = float3(255.0, 70.0, 0.0) / 255;
            const float3 _ColorG = float3(128.0, 255.0, 132.0) / 255;
            const float3 _ColorB = float3(128.0, 0.0, 132.0) / 255;

            float3      _RenderO = lerp(_Render.rgb, _ColorR,  _Render.r * _Render.r);
                        _RenderO = lerp(_RenderO.rgb, _ColorG, _Render.g * _Render.g);
                        _RenderO = lerp(_RenderO.rgb, _ColorB, _Render.b * _Render.b);

            _Result.rgb = lerp(_Result.rgb, _RenderO.rgb * 1.2 + (_Result.rgb * _Render_Texture.rgb) * 0.78, Fun_Luminance(_Render.rgb));
            _Result.rgb += lerp(_Result.rgb, _RenderO, Fun_Luminance(_Render.rgb) * 1.5) * 0.25 * Fun_Luminance(_Render.rgb);

            _Result.rgb *= saturate(_Result.rgb + 0.5);

            _Result.rgb = lerp(_Render_Texture.rgb,  _Result.rgb, _Mixing); 
        
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
