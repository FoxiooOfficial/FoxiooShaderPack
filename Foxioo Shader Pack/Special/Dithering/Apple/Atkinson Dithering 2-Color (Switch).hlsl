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

Texture2D<float4> S2D_Dither : register(t2);
SamplerState S2D_DitherSampler : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    Texture2D _Texture_Dithering;
    float4 _Color;
    float4 _ColorShadow;
    float _Threshold;
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


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }

            float _Lum = ((0.2126 * _Render.r + 0.7152 * _Render.g + 0.0722 * _Render.b) * 63.0);
            _Lum = floor(_Lum);
            //_Lum /= 15.0;

                float2 _UV = frac(In.texCoord / float2(fPixelWidth, fPixelHeight) / 32.0); 

                    _UV.x *= (32.0 / 2048.0);
                    _UV.x += (_Lum * 32.0 / 2048.0);
                    
                float3 _Dither = S2D_Dither.Sample(S2D_DitherSampler, _UV).rgb;
                _Result.rgb = _Dither;

            _Result.rgb = (_Lum * _Dither.r / 63.0 >= _Threshold) ? _Color.rgb : _ColorShadow.rgb;

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

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }

            float _Lum = ((0.2126 * _Render.r + 0.7152 * _Render.g + 0.0722 * _Render.b) * 63.0);
            _Lum = floor(_Lum);
            //_Lum /= 15.0;

                float2 _UV = frac(In.texCoord / float2(fPixelWidth, fPixelHeight) / 32.0); 

                    _UV.x *= (32.0 / 2048.0);
                    _UV.x += (_Lum * 32.0 / 2048.0);
                    
                float3 _Dither = S2D_Dither.Sample(S2D_DitherSampler, _UV).rgb;
                _Result.rgb = _Dither;

            _Result.rgb = (_Lum * _Dither.r / 63.0 >= _Threshold) ? _Color.rgb : _ColorShadow.rgb;

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 

    _Result.a = _Render_Texture.a;
    
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
