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
    float _Hue;
    float _Saturation;
    float _Intensity;
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

#define RAD 180.0 / 3.14159265

#define DEG_60 1.04719755
#define DEG_120 2.09439510
#define DEG_240 4.18879020
#define DEG 3.14159265 / 180.0

float3 RGBtoHSI(float3 _Render)
{
    float _R = _Render.r;
    float _G = _Render.g;
    float _B = _Render.b;

    float _I = (_R + _G + _B) / 3.0;
    float _S = 0.0;
    float _H = 0.0;

    if (_I > 0.0)
    {
        float _CMin = min(_R, min(_G, _B));
        _S = 1.0 - (_CMin / _I);
    }

        float _Num = 0.5 * ((_R - _G) + (_R - _B));
        float _Den = sqrt((_R - _G) * (_R - _G) + (_R - _B) * (_G - _B)) + 1e-6;
        float _Theta = acos(clamp(_Num / _Den, -1.0, 1.0)) * (RAD);

        if (_B > _G)
            _H = 360.0 - _Theta;
        else
            _H = _Theta;

    return float3(_H, _S, _I);
}

float3 HSItoRGB(float _H, float _S, float _I)
{
    float _R, _G, _B;

    _H = fmod(_H, 360.0);
    if (_H < 0.0) _H += 360.0;
    
    float _Rad = _H * DEG;
        
        if (_H < 120.0)
        {
            _B = _I * (1.0 - _S);
            _R = _I * (1.0 + (_S * cos(_Rad)) / cos(DEG_60 - _Rad));
            _G = 3.0 * _I - (_R + _B);
        }
        else if (_H < 240.0)
        {
            _Rad -= DEG_120;
            _R = _I * (1.0 - _S);
            _G = _I * (1.0 + (_S * cos(_Rad)) / cos(DEG_60 - _Rad));
            _B = 3.0 * _I - (_R + _G);
        }
        else
        {
            _Rad -= DEG_240;
            _G = _I * (1.0 - _S);
            _B = _I * (1.0 + (_S * cos(_Rad)) / cos(DEG_60- _Rad));
            _R = 3.0 * _I - (_G + _B);
        }

    return saturate(float3(_R, _G, _B));
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

            float3 _HSI = RGBtoHSI(_Render.rgb);

                _HSI.x = fmod(_HSI.x + _Hue, 360.0);
                    if (_HSI.x < 0.0) _HSI.x += 360.0;
        
                _HSI.y = (_HSI.y * (_Saturation / 50.0));
                _HSI.z = (_HSI.z + (_Intensity - 50.0) / 50.0);

            _Result.rgb = HSItoRGB(_HSI.x, _HSI.y, _HSI.z);

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
