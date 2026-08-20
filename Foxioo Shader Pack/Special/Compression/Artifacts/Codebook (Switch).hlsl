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
    bool _Blending_Mode;
    float _Mixing;
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

float3 Fun_Hash21(float3 _Color) 
{ 
    float3 _Noise;
    _Noise.x = frac(_Seed + sin(((_Color.x - _Seed) * 12.9898 + 78.233)) * 43758.5453);
    _Noise.y = frac(_Seed + sin(((_Color.y - _Seed) * 63.7264 + 10.873)) * 73156.8473);
    _Noise.z = frac(_Seed + sin(((_Color.z - _Seed) * 43.5276 + 37.735)) * 12931.5923);
    return _Noise;
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

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Render;

            _Result.rgb = Fun_Hash21(_Result.rgb);
            _Result.rgb = Fun_Hash21(1.0 - _Result.rgb);

                    uint _Pixel = (uint)(In.texCoord.x / fPixelWidth);
                    
                    if((_Pixel % 2) == 0) _Result.rgb = _Result.gbr;
                    if((_Pixel % 3) == 0) _Result.rgb = _Result.brg;

                    _Result.rgb = Fun_Hash21(1.0 - _Result.rgb);

                    _Result.rgb = 1.0 - _Result.gbr;

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
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
