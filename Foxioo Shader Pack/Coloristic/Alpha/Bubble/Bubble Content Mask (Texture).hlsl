/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (02.03.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

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
    float4 _ColorIn;
    float4 _ColorBackground;
    float4 _OutlineColor;
    float _OutlineAlpha;
    float _OutlineOffset;
    bool _OutlineCorner;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

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

    Out.Color = _Result;
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

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

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}