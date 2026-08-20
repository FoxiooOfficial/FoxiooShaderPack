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
    float _Size;
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

#define RADIUS 4
#define ZERO 0.0

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

float4 Fun_Kuwahara(float2 UV, Texture2D<float4> _Texture, SamplerState _Sampler)
{
    float4 _SumColor[4] = { (float4)ZERO, (float4)ZERO, (float4)ZERO, (float4)ZERO };
    float _SumLum[4] = { ZERO, ZERO, ZERO, ZERO };
    float _SumLumSq[4] = { ZERO, ZERO, ZERO, ZERO };
    int _Count[4] = { ZERO, ZERO, ZERO, ZERO };

    float2 _Offset = float2(fPixelWidth, fPixelHeight) * _Size;

        for (int _Y = -RADIUS; _Y <= RADIUS; _Y++)
        {
            for (int _X = -RADIUS; _X <= RADIUS; _X++)
            {
                float2 _Off = float2(_X, _Y) * _Offset;
                float4 _Render = _Texture.Sample(_Sampler, UV + _Off);

                float _Lum = dot(_Render.rgb, float3(0.2126, 0.7152, 0.0722));

                int _R = (min(sign(_X), 0) + 1) + max(0, sign(_Y)) * 2;

                _SumColor[_R] += _Render;
                _SumLum[_R] += _Lum;
                _SumLumSq[_R] += _Lum * _Lum;
                _Count[_R] += 1;
            }
        }

    float4 _Mean[4];
    float _Var[4];

        for (int i = 0; i < 4; i++)
        {
            if (_Count[i] > 0)
            {
                float _Invert = 1.0 / _Count[i];
                _Mean[i] = _SumColor[i] * _Invert;

                float _E = _SumLum[i] * _Invert;
                float _P = _SumLumSq[i] * _Invert - _E * _E;

                _Var[i] = max(0.0, _P);
            }
            else
            {
                _Mean[i] = (float4)ZERO;
                _Var[i] = 0.0;
            }
        }

    int _Best = 0;
    float _BVar = _Var[0];

        for (int ii = 1; ii < 4; ii++)
        {
            if (_Var[ii] < _BVar)
            {
                _BVar = _Var[ii];
                _Best = ii;
            }
        }

    return _Mean[_Best];
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Result = Fun_Kuwahara(In.texCoord, S2D_Background, S2D_BackgroundSampler);

            _Result.rgb = lerp(_Render_Background.rgb, _Result.rgb, _Mixing);
            _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
