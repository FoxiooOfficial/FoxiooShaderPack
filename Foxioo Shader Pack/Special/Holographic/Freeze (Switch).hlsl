/***********************************************************/

/* Shader author: Foxioo */
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

Texture2D<float4> S2D_Ice : register(t2);
SamplerState S2D_IceSampler : register(s2);

Texture2D<float4> S2D_Mask : register(t3);
SamplerState S2D_MaskSampler : register(s3);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Offset;
    Texture2D _Texture_Ice;
    Texture2D _Texture_Mask;
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

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    float4 _Render_Ice = S2D_Ice.Sample(S2D_IceSampler, In.texCoord);
    float4 _Render_Mask = S2D_Mask.Sample(S2D_MaskSampler, In.texCoord);

        float4 _Result;
        float4 _Render;

        float2 _Pix = float2(fPixelWidth, fPixelHeight);

        if(_Blending_Mode == 0)
        {
            _Result = S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + _Pix * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset))) * In.Tint;
            _Render = _Render_Texture;
        }
        else
        {
            _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(In.texCoord + _Pix * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
            _Render = _Render_Background;
        }

        _Result.rgb = _Result.rgb * Fun_Luminance(_Render_Ice.rgb) + Fun_Luminance(_Render_Ice.rgb) * 0.75 * _Render_Ice.rgb;
        _Result.rgb += Fun_Luminance(_Render_Ice.rgb) * 0.35;

        _Result = lerp(_Render, _Result, smoothstep(Fun_Luminance(_Render_Ice.rgb) * (1.0 - abs(_Mixing)), Fun_Luminance(_Render_Ice.rgb), abs(_Mixing) * (1.0 - _Render_Mask.r)));
        if(_Blending_Mode) _Result.a = _Render_Texture.a;

    /*_Result.a = _Render_Texture.a;*/
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
    float4 _Render_Ice = S2D_Ice.Sample(S2D_IceSampler, In.texCoord);
    float4 _Render_Mask = S2D_Mask.Sample(S2D_MaskSampler, In.texCoord);

        float4 _Result;
        float4 _Render;

        float2 _Pix = float2(fPixelWidth, fPixelHeight);

        if(_Blending_Mode == 0)
        {
            _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + _Pix * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)))) * In.Tint;
            _Render = _Render_Texture;
        }
        else
        {
            _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(In.texCoord + _Pix * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
            _Render = _Render_Background;
        }

        _Result.rgb = _Result.rgb * Fun_Luminance(_Render_Ice.rgb) + Fun_Luminance(_Render_Ice.rgb) * 0.75 * _Render_Ice.rgb;
        _Result.rgb += Fun_Luminance(_Render_Ice.rgb) * 0.35;

        _Result = lerp(_Render, _Result, smoothstep(Fun_Luminance(_Render_Ice.rgb) * (1.0 - abs(_Mixing)), Fun_Luminance(_Render_Ice.rgb), abs(_Mixing) * (1.0 - _Render_Mask.r)));
        if(_Blending_Mode) _Result.a = _Render_Texture.a;

    /*_Result.a = _Render_Texture.a;*/
    
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
