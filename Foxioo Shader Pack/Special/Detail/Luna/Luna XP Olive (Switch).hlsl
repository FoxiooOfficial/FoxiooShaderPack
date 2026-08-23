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

static float4 _OverlayTop    = float4(0.55, 0.6, 0.39, 1.0);
static float4 _OverlayBottom = float4(0.35, 0.4, 0.29, 1.0);

static float3 _InnerLight     = float3(0.91, 0.96, 0.75);
static float3 _InnerShadow    = float3(0.55, 0.58, 0.43);

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y * _Result.a;
}

float4 Fun_Border(Texture2D _Texture, SamplerState _Sampler, float2 In, float2 _Off, float4 _Render, float4 _Tint)
{
    float _Up      = Fun_Luminance(_Tint *_Texture.Sample(_Sampler, In + float2(0.0,  _Off.y))) * 1.75;
    float _Down    = Fun_Luminance(_Tint *_Texture.Sample(_Sampler, In + float2(0.0, -_Off.y))) * 1.75;
    float _Left    = Fun_Luminance(_Tint *_Texture.Sample(_Sampler, In + float2( _Off.x, 0.0))) * 1.75;
    float _Right   = Fun_Luminance(_Tint *_Texture.Sample(_Sampler, In + float2(-_Off.x, 0.0))) * 1.75;

        float _Glow = _Render.a - _Up;
        float _Shadow = (_Render.a * 3.0) - (_Down + _Left + _Right);

    float4 _Result = 0.0;
    _Result = lerp(_Result, _OverlayTop, _Glow);
    _Result = lerp(_Result, _OverlayBottom, _Shadow);

    return _Result;
}

float3 Fun_Sharp(Texture2D _Texture, SamplerState _Sampler, float2 In, float2 _Off, float4 _Tint)
{
    float2 _Emboss;

    float4 _NW = _Tint * _Texture.Sample(_Sampler, In + float2(-_Off.x, -_Off.y));
    float4 _N  = _Tint * _Texture.Sample(_Sampler, In + float2(0.0, -_Off.y));
    float4 _NE = _Tint * _Texture.Sample(_Sampler, In + float2(_Off.x, -_Off.y));
    float4 _W  = _Tint * _Texture.Sample(_Sampler, In + float2(-_Off.x, 0.0));
    //float4 _C  = _Texture.Sample(_Sampler, In);
    float4 _E  = _Tint * _Texture.Sample(_Sampler, In + float2(_Off.x, 0.0));
    float4 _SW = _Tint * _Texture.Sample(_Sampler, In + float2(-_Off.x, _Off.y));
    float4 _S  = _Tint * _Texture.Sample(_Sampler, In + float2(0.0, _Off.y));
    float4 _SE = _Tint * _Texture.Sample(_Sampler, In + float2(_Off.x, _Off.y));

        _Emboss.x = (Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW));
        _Emboss.y = (Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE));
        _Emboss.y = -_Emboss.y;

    float3 _Render = normalize(float3(_Emboss.x, _Emboss.y, 0.35));
    _Render = _Render * 0.5 + 0.5;

    return _Render;
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

        float4 _Result, _Render;
        float _Alpha;
        float2 _Offset = _Size * -float2(fPixelWidth, fPixelHeight);

            if(!_Blending_Mode)
            {
                _Result = _Render_Texture;
                _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, _Offset, _Render_Texture, In.Tint);

                float3 _Sharp = float3(Fun_Sharp(S2D_Image, S2D_ImageSampler, In.texCoord, _Offset, In.Tint));
                _Alpha = Fun_Luminance(float4(_Sharp.r, _Sharp.g, _Sharp.b, _Render_Texture.a));
            }
            else
            {
                _Result.rgb = _Render_Background.rgb;
                _Result.a = _Render_Texture.a;

                _Render = Fun_Border(S2D_Background, S2D_BackgroundSampler, In.bgCoord, _Offset, _Render_Background, (float4)1.0);

                float3 _Sharp = float3(Fun_Sharp(S2D_Background, S2D_BackgroundSampler, In.bgCoord, _Offset, (float4)1.0));
                _Alpha = Fun_Luminance(float4(_Sharp.r, _Sharp.g, _Sharp.b, _Render_Texture.a));
            }

                float _InnerMask = saturate((_Alpha * _Alpha) * 2.0) * 0.85;
                float3 _InnerColor = lerp(_InnerShadow, _InnerLight, _InnerMask);

                _InnerColor += (_InnerColor * (abs(In.texCoord.y * 1.3 - 0.75) * _InnerLight)) * 0.25;
                _InnerColor -= pow(abs(In.texCoord.x * 2.0 - 1.0), 3.0) * 0.5 * _InnerShadow;

            _Render.rgb = lerp(_InnerColor, _Render.rgb, _Render.a / 18.0);

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);

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
