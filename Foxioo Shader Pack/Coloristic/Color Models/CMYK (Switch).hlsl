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
    float _Cyan;
    float _Magenta;
    float _Yellow;
    float _Black;
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

float4 RGBtoCMYK(float3 _Render)
{
    float4 _CMYK;

        _CMYK.x = 1.0 - max(_Render.r, max(_Render.g, _Render.b));  /*  Black   */
        _CMYK.y = (1.0 - _Render.r - _CMYK.x) / (1.0 - _CMYK.x);    /*  Cyan    */
        _CMYK.z = (1.0 - _Render.g - _CMYK.x) / (1.0 - _CMYK.x);    /*  Magenta */
        _CMYK.w = (1.0 - _Render.b - _CMYK.x) / (1.0 - _CMYK.x);    /*  Yellow  */
    
    return _CMYK.yzwx;
}

float3 CMYKtoRGB(float4 _CMYK)
{
    float3 _Render;

        _Render.r = (1.0 - _CMYK.r) * (1.0 - _CMYK.w);
        _Render.g = (1.0 - _CMYK.g) * (1.0 - _CMYK.w);
        _Render.b = (1.0 - _CMYK.b) * (1.0 - _CMYK.w);
    
    return _Render;
}

float4 Fun_CMYKMagic(float4 _Result)
{
    float4 _CMYK = RGBtoCMYK(_Result.rgb);
    
    float4  _Value = float4(_Cyan, _Magenta, _Yellow, _Black);
            _Value /= 100.0;

                _CMYK -= _Value;
    
    _Result.rgb = CMYKtoRGB(_CMYK);
    return _Result;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

                _Result = Fun_CMYKMagic(_Result);

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
            _Result.a = _Render_Texture.a;

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

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

                _Result = Fun_CMYKMagic(_Result);

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
            _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}