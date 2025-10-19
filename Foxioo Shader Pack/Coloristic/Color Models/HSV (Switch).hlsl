/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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
    bool _Blending_Mode;
    float _Mixing;
    float _Hue;
    float _Saturation;
    float _Value;
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

/************************************************************/
/* Main */
/************************************************************/

float3 RGBtoHSV(float3 _Render)
{
    float _CMax = max(_Render.r, max(_Render.g, _Render.b));
    float _CMin = min(_Render.r, min(_Render.g, _Render.b));
    float _Delta = _CMax - _CMin;

    float _H = 0.0;
    float _S = 0.0;
    float _V = _CMax;

    if (_Delta > 0.0)
    {
        _S = (_V > 0.0) ? (_Delta / _V) : 0.0;

        if (_CMax == _Render.r)
        {
            _H = 60.0 * fmod(((_Render.g - _Render.b) / _Delta), 6.0);
        }
        else if (_CMax == _Render.g)
        {
            _H = 60.0 * (((_Render.b - _Render.r) / _Delta) + 2.0);
        }
        else
        {
            _H = 60.0 * (((_Render.r - _Render.g) / _Delta) + 4.0);
        }
    }

    if (_H < 0.0) { _H += 360.0; }
    return float3(_H, _S, _V);
}

float3 HSVtoRGB(float _H, float _S, float _V)
{
    float _C = _V * _S;
    float _X = _C * (1.0 - abs(fmod(_H / 60.0, 2.0) - 1.0));
    float _M = _V - _C;

    float3 _Render =    (_H < 60.0)   ? float3(_C, _X, 0) :
                        (_H < 120.0)  ? float3(_X, _C, 0) :
                        (_H < 180.0)  ? float3(0, _C, _X) :
                        (_H < 240.0)  ? float3(0, _X, _C) :
                        (_H < 300.0)  ? float3(_X, 0, _C) :
                                        float3(_C, 0, _X);

    return (_Render + _M);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

    /* Hue Adjustment */
        float3 _HSV = RGBtoHSV(_Render.rgb);
            _HSV.x = fmod(_HSV.x + _Hue, 360.0);
            if (_HSV.x < 0.0) { _HSV.x += 360.0; }

    /* Saturation Adjustment */
        _HSV.y = (_HSV.y * (_Saturation / 50.0));

    /* Value Adjustment */
        _HSV.z = (_HSV.z + (_Value - 50.0) / 50.0);

    /* Back to RGB */
        _Render.rgb = HSVtoRGB(_HSV.x, _HSV.y, _HSV.z);

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
    
    _Render.a = _Render_Texture.a;
    Out.Color = _Render;
    
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

    /* Hue Adjustment */
        float3 _HSV = RGBtoHSV(_Render.rgb);
            _HSV.x = fmod(_HSV.x + _Hue, 360.0);
            if (_HSV.x < 0.0) { _HSV.x += 360.0; }

    /* Saturation Adjustment */
        _HSV.y = (_HSV.y * (_Saturation / 50.0));

    /* Value Adjustment */
        _HSV.z = (_HSV.z + (_Value - 50.0) / 50.0);

    /* Back to RGB */
        _Render.rgb = HSVtoRGB(_HSV.x, _HSV.y, _HSV.z);

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);;
    
    _Render.a = _Render_Texture.a;
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}