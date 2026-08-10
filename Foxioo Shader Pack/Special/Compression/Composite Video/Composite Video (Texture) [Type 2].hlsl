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

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Time;
    float _CrossLuma;
    float _CrossColor;
    float _Distortion;
    float _Size;
    int _Quality;
    bool __;
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

static const float3 _L = float3(0.299, 0.587, 0.114);

#define M_PI        3.14159265358979323846

#define MHZ_CROMA   4.43361875
#define MHZ_LUM     13.5
#define MHZ_LIFT    283.75

#define FPS         50
#define SAMPLES     720
#define LINES       576

float3 Fun_RGB2YUV(float3 _Render)
{
    float Y = dot(_L, _Render);
    float U = 0.492 * (_Render.b - Y);
    float V = 0.877 * (_Render.r - Y);

    return float3(Y, U, V);
}

float3 Fun_YUV2RGB(float3 _YUV)
{
    float Y = _YUV.r;
    float U = _YUV.g;
    float V = _YUV.b;

    float R = Y + 1.13983 * V;
    float G = Y - 0.39465 * U - 0.58060 * V;
    float B = Y + 2.03211 * U;

    return float3(R, G, B);
}

float3 Fun_Blur(Texture2D _Texture, SamplerState _Sampler, float2 In, float _Offset)
{
    float3 _Result = 0.0;
    int x, y;
    float _W = 0.0;

    for(y = 0; y < _Quality; y++)
    {
        for(x = 0; x < _Quality; x++)
        {
            float2 _Off = float2(x, y);
            _Off -= floor(_Quality / 2.0);
            _Result += _Texture.Sample(_Sampler, In + (float2(fPixelWidth, fPixelHeight) * _Off * _Offset * _Size) / _Quality).rgb;
            _W += 1.0;
        }
    }

    return _Result / _W;
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
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float2 _Pos = float2(floor(In.texCoord.x * SAMPLES), floor(In.texCoord.y * LINES + (_Time * FPS)));

        float _Vert = fmod(_Pos.y, 2.0) < 1.0 ? 1.0 : -1.0;
        float2 _Cycle = float2(MHZ_CROMA / MHZ_LUM, MHZ_LIFT);
        float _Noise = _Distortion * sin(_Pos.y * 6.0 * _Distortion - _Time + 1.0 / cos(_Time * 15.0));
        float _Phase = 2.0 * M_PI * ((_Pos.x * _Cycle.x) + (_Pos.y * _Cycle.y)) + _Noise;

        float2 _UV = 0.5 * lerp(float2(sin(_Phase + _Noise) * _Distortion * (1.0 / SAMPLES), 0.0), 5.0 * (In.texCoord.yy / (_Noise / _Phase) * _Vert * _Distortion), _Distortion);
        if(_Distortion == 0.0) _UV = 0.0;
        
            // Luma
            float4 _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _UV) * In.Tint, _Premultiplied);
            float _Luma = Fun_RGB2YUV(_Result.rgb).x;

                _Result.rgb = Fun_Blur(S2D_Image, S2D_ImageSampler, In.texCoord + _UV, 0.85) * In.Tint.rgb;
                float3 _Render = Fun_RGB2YUV(_Result.rgb);
                float Y = _Render.x;

            // Chroma
            _Result.rgb = Fun_Blur(S2D_Image, S2D_ImageSampler, In.texCoord + float2(0.0, 2.0 * (_Vert / LINES)) * Y + _UV, 4.0) * In.Tint.rgb;

                _Render = Fun_RGB2YUV(_Result.rgb);
                float U = _Render.y;
                float V = _Render.z;

            // Rainbowing
            float _Sin, _Cos;
            sincos(_Phase, _Sin, _Cos);

                _Luma = (Y - _Luma) * _CrossColor;
                U += _Luma * _Cos;
                V += _Luma * _Sin * _Vert;

                float _Chroma = (U * _Cos) + (V * _Vert * _Sin);

                // Cross-luma
                Y += (_Chroma * _CrossLuma);

            // Out
            _Result.rgb = Fun_YUV2RGB(float3(Y, U, V));
            _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

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
