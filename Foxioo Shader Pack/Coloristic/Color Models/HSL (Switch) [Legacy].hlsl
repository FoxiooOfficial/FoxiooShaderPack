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
    float _Hue;
    float _Saturation;
    float _Lightness;
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

    // this code is bullshit.
        float4 _Render;
        float4 _Result;

            if(!_Blending_Mode)
            {
                _Render = _Render_Texture;
                _Result = _Render_Texture;
            }
            else
            {
                _Render = _Render_Background;
                _Result = _Render_Background;
            }

        /* Hue */
        float _Hue_Temp = fmod(_Hue / 120.0, 3.0);
        if (_Hue_Temp < 0.0) _Hue_Temp = 3.0 - abs(_Hue_Temp);

                if (_Hue_Temp >= 0.0 && _Hue_Temp < 1.0)
                {
                    _Render.r = _Result.r + (_Result.g - _Result.r) * _Hue_Temp;
                    _Render.g = _Result.g + (_Result.b - _Result.g) * _Hue_Temp;
                    _Render.b = _Result.b + (_Result.r - _Result.b) * _Hue_Temp;
                }

                else if (_Hue_Temp >= 1.0 && _Hue_Temp < 2.0)
                {
                    _Render.r = _Result.g + (_Result.b - _Result.g) * (_Hue_Temp - 1.0);
                    _Render.g = _Result.b + (_Result.r - _Result.b) * (_Hue_Temp - 1.0);
                    _Render.b = _Result.r + (_Result.g - _Result.r) * (_Hue_Temp - 1.0);
                }

                else if (_Hue_Temp >= 2.0 && _Hue_Temp < 3.0)
                {
                    _Render.r = _Result.b + (_Result.r - _Result.b) * (_Hue_Temp - 2.0);
                    _Render.g = _Result.r + (_Result.g - _Result.r) * (_Hue_Temp - 2.0);
                    _Render.b = _Result.g + (_Result.b - _Result.g) * (_Hue_Temp - 2.0);
                }

        float _Color = (_Render.r + _Render.g + _Render.b) / 3.0;

            _Render.rgb = _Color * (1.0 - (_Saturation / 50.0)) + _Render.rgb * (_Saturation / 50.0);

        _Render.rgb += (_Lightness - 50.0) / 50.0;

    _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
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
