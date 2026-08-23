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
    float _Distortion;
    float _Seed;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
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

float2 Fun_Rand(float2 In)
{
    float2 _Rand = float2(  frac(sin(dot(In.xy + _Seed, float2(12.9898,78.233)))* 43758.5453123),
                            frac(cos(dot(In.xy + _Seed, float2(67.4684,18.467)))* 3463456.95546)
                        );
    return _Rand;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float2 _Pixel = float2(fPixelWidth, fPixelHeight);
        float2 _Block = float2(4.0, 8.0);
        float4 _Result = (float4)0.0;
        float4 _Render = (float4)0.0;

            float2 _Art = floor(In.texCoord / _Pixel / _Block) * _Pixel * _Block;
            if(any(abs(Fun_Rand(_Art).xy) > _Distortion))
                _Art = _Blending_Mode ? In.bgCoord : In.texCoord;
            else
                _Art = In.texCoord + Fun_Rand(_Art) * 0.5 - 0.25;

                if(_Blending_Mode)
                {
                    _Result = S2D_Background.Sample(S2D_BackgroundSampler, _Art);
                    _Render.rgb = _Render_Background.rgb;
                    _Result.a = _Render_Texture.a;
                }
                else
                {
                    _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _Art) * In.Tint, _Premultiplied);
                    _Render = _Render_Texture;
                    
                }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

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
