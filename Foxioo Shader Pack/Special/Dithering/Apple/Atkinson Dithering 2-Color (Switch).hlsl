/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (13.04.2026) */
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

Texture2D<float4> _Texture_Dithering : register(t2);
SamplerState _Texture_Dithering_Sampler : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    //Texture2D _Texture_Dithering;
    float4 _Color;
    float4 _ColorShadow;
    float _Threshold;
    bool __;
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

        if(!_Blending_Mode)
        {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }
            
            float _Lum = dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722)) * 63.0;
            _Lum = floor(_Lum);

                float2 _UV = frac(In.texCoord / float2(fPixelWidth, fPixelHeight) / 32.0); 

                    _UV.x *= 32.0 / 2048.0;
                    _UV.x += _Lum * 32.0 / 2048.0;
                    
                float3 _Dither = _Texture_Dithering.Sample(_Texture_Dithering_Sampler, _UV).rgb;
                _Result.rgb = _Dither;

            _Result.rgb = (_Lum * _Dither.r / 63.0 >= _Threshold) ? _Color.rgb : _ColorShadow.rgb;

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

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
