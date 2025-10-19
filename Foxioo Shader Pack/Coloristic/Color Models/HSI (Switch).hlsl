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
    float _Intensity;
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

float3 Fun_RGBtoHSI(float3 _Render)
{
    float _Num = 0.5 * ((_Render.r - _Render.g) + (_Render.r - _Render.b));
    float _Den = sqrt((_Render.r - _Render.g) * (_Render.r - _Render.g) + (_Render.r - _Render.b)*(_Render.g - _Render.b));

    float _Theta = acos(saturate(_Num / _Den)) * 180.0 / 3.14159265;

        float _H        = (_Render.b <= _Render.g) ? _Theta : 360.0 - _Theta;

            float _Min    = min(_Render.r, min(_Render.g, _Render.b));
            float _Sum    = _Render.r + _Render.g + _Render.b;

        float _S = 1.0 - (3.0 * _Min / _Sum);
        float _I = _Sum / 3.0;

    return float3(_H, _S, _I);
}

float3 Fun_HSItoRGB(float _H, float _S, float _I)
{
    float3 _Render;

    float _Rad = _H * 3.14159265 / 180.0;

    if (_H < 120.0)
    {
        _Render.b = _I * (1.0 - _S);
        _Render.r = _I * (1.0 + (_S * cos(_Rad)) / cos(3.14159265 / 3.0 - _Rad));
        _Render.g = 3.0 * _I - (_Render.r + _Render.b);
    }
    else if (_H < 240.0)
    {
        _H = _H - 120.0;

            _Rad = _H * 3.14159265 / 180.0;

        _Render.r = _I * (1.0 - _S);
        _Render.g = _I * (1.0 + (_S * cos(_Rad)) / cos(3.14159265 / 3.0 - _Rad));
        _Render.b = 3.0 * _I - (_Render.r + _Render.g);
    }
    else
    {
        _H = _H - 240.0;

            _Rad = _H * 3.14159265 / 180.0;

        _Render.g = _I * (1.0 - _S);
        _Render.b = _I * (1.0 + (_S * cos(_Rad)) / cos(3.14159265 / 3.0 - _Rad));
        _Render.r = 3.0 * _I - (_Render.g + _Render.b);
    }

    return (_Render);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

    /* Hue Adjustment */
        float3 _HSI = Fun_RGBtoHSI(_Render.rgb);
            _HSI.x = fmod(_HSI.x + _Hue, 360.0);
            if (_HSI.x < 0.0) { _HSI.x += 360.0; }

    /* Saturation Adjustment */
        _HSI.y = (_HSI.y * (_Saturation / 50.0));

    /* Intensity Adjustment */
        _HSI.z = (_HSI.z + (_Intensity - 50.0) / 50.0);

    /* Back to RGB */
        _Render.rgb = Fun_HSItoRGB(_HSI.x, _HSI.y, _HSI.z);

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
        float3 _HSI = Fun_RGBtoHSI(_Render.rgb);
            _HSI.x = fmod(_HSI.x + _Hue, 360.0);
            if (_HSI.x < 0.0) { _HSI.x += 360.0; }

    /* Saturation Adjustment */
        _HSI.y = (_HSI.y * (_Saturation / 50.0));

    /* Intensity Adjustment */
        _HSI.z = (_HSI.z + (_Intensity - 50.0) / 50.0);

    /* Back to RGB */
        _Render.rgb = Fun_HSItoRGB(_HSI.x, _HSI.y, _HSI.z);

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
    
    _Render.a = _Render_Texture.a;
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}