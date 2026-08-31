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
    float4 _ColorIn;
    float4 _ColorBackground;
    float4 _OutlineColor;
    float _OutlineAlpha;
    float _OutlineOffset;
    bool _OutlineCorner;
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

#define _SIZE 1

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

float4 Main(PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

    float4 _Result;
    float _Inside;
    if(all(_Render_Background.rgb == _ColorIn.rgb))
    {   
        /* inside */
        _Result.rgb = _Render_Texture.rgb;
        _Result.a = 1.0;
        _Inside = 1.0;

        _Result.rgb = lerp(_ColorBackground.rgb, _Render_Texture.rgb, _Render_Texture.a);
    }
    else
    {   
        /* outside!!! */
        _Result = float4(0.0, 0.0, 0.0, 0.0);
        _Inside = 0.0;
    }

        /* outline !! */
        float _Outline = 0.0;
        for(int y = -_SIZE; y <= _SIZE; y++)
        {
            for(int x = -_SIZE; x <= _SIZE; x++)
            {
                bool _Test = (x == 0) != (y == 0);
                bool _Include = _OutlineCorner ? true : _Test;

                if (_Include)
                {
                    float2 _Off = float2(fPixelWidth, fPixelHeight) * float2(x, y) * _OutlineOffset;
                    bool _Comp = all(S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + _Off).rgb == _ColorIn.rgb);

                    _Outline += (float)_Comp;
                }
            }
        }
            _Outline = saturate(_Outline);
            _Inside = saturate(_Inside);

        _Result = lerp(float4(_OutlineColor.rgb, _OutlineAlpha), _Result, 1.0 - (_Outline - _Inside));
        _Result = lerp(_Render_Texture, _Result, _Mixing);

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