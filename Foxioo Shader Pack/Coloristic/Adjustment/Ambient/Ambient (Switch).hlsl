/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (21.11.2025) */
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
    float _Exposure;
    float _Contrast;
    float _Saturation;
    float _Vibrance;
    float _Power;
    float _Time;
    float _Temperature;
    float _Bloom;
    float _BloomThreshold;
    float _Add;
    float4 _AddColor;
    float _Mul;
    float4 _MulColor;
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

    static float3 _Blend[6] = {
        float3(0.2, 0.3, 0.4),
        float3(0.8, 0.5, 0.2),
        float3(1.0, 0.8, 0.6),
        float3(1.0, 1.0, 1.0),
        float3(1.0, 0.9, 0.8),
        float3(0.8, 0.4, 0.2) 
    };

float3 Fun_Saturation(float3 _Color, float _Sat)
{
    float _Lum = dot(_Color, float3(0.2126, 0.7152, 0.0722));
    return lerp(_Lum, _Color, _Sat);
}

float3 Fun_Vibrance(float3 _Color, float _Vib)
{
    float _Max = max(_Color.r, max(_Color.g, _Color.b));
    float _Min = min(_Color.r, min(_Color.g, _Color.b));
    
        float _Sat = _Max - _Min;
    
        float3 _Lum = dot(_Color, float3(0.2126, 0.7152, 0.0722));
        float3 _Coeff = (1.0 - _Vib * _Sat);

    return lerp(_Lum, _Color, _Coeff);
}

float3 Fun_Bloom(float3 _Color, float _Intensity, float _Threshold)
{
    float brightness = dot(_Color, float3(0.2126, 0.7152, 0.0722));
    float _BLOOM = max(0.0, brightness - _Threshold);

    return _Color + _BLOOM * _Intensity;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }

            float _TimeFix = fmod(_Time, 24.0);
            if (_TimeFix < 0) _TimeFix = 24.0 - abs(_TimeFix);

                if (_TimeFix < 4.0) {
                    _Render.rgb *= lerp(_Blend[0], _Blend[1], _TimeFix / 4.0);
                }

                else if (_TimeFix < 6.0) {
                    _Render.rgb *= lerp(_Blend[1], _Blend[2], (_TimeFix - 4.0) / 2.0);
                }

                else if (_TimeFix < 12.0) {
                    _Render.rgb *= lerp(_Blend[2], _Blend[3], (_TimeFix - 6.0) / 6.0);
                }

                else if (_TimeFix < 16.0) {
                    _Render.rgb *= lerp(_Blend[3], _Blend[4], (_TimeFix - 12.0) / 4.0);
                }

                else if (_TimeFix < 18.0) {
                    _Render.rgb *= lerp(_Blend[4], _Blend[5], (_TimeFix - 16.0) / 2.0);
                }

                else {
                    _Render.rgb *= lerp(_Blend[5], _Blend[0], (_TimeFix - 18.0) / 6.0);
                }

        /* Temperature */

            _Render.r = (_Render.r + (_Temperature / 273.15)) * _Mixing;
		    _Render.g = (_Render.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Render.b = (_Render.b) * _Mixing;

        /* Ambient */
            _Render.rgb += _AddColor.rgb * _Add;
            _Render.rgb *= lerp(1.0, _MulColor.rgb, _Mul);

            _Render.rgb *= _Exposure / 100.0; 
            _Render.rgb = (_Render.rgb - 0.5) * (_Contrast / 100.0) + 0.5;
            _Render.rgb = Fun_Saturation(_Render.rgb, _Saturation / 100.0);
            _Render.rgb = Fun_Vibrance(_Render.rgb, _Vibrance / 100.0);

            _Render.rgb = Fun_Bloom(_Render.rgb, _Bloom, _BloomThreshold);

        _Result.rgb = lerp(_Result.rgb, pow(abs(_Render.rgb), _Power), _Mixing);
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

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }
    
            float _TimeFix = fmod(_Time, 24.0);
            if (_TimeFix < 0) _TimeFix = 24.0 - abs(_TimeFix);

                if (_TimeFix < 4.0) {
                    _Render.rgb *= lerp(_Blend[0], _Blend[1], _TimeFix / 4.0);
                }

                else if (_TimeFix < 6.0) {
                    _Render.rgb *= lerp(_Blend[1], _Blend[2], (_TimeFix - 4.0) / 2.0);
                }

                else if (_TimeFix < 12.0) {
                    _Render.rgb *= lerp(_Blend[2], _Blend[3], (_TimeFix - 6.0) / 6.0);
                }

                else if (_TimeFix < 16.0) {
                    _Render.rgb *= lerp(_Blend[3], _Blend[4], (_TimeFix - 12.0) / 4.0);
                }

                else if (_TimeFix < 18.0) {
                    _Render.rgb *= lerp(_Blend[4], _Blend[5], (_TimeFix - 16.0) / 2.0);
                }

                else {
                    _Render.rgb *= lerp(_Blend[5], _Blend[0], (_TimeFix - 18.0) / 6.0);
                }
                
        /* Temperature */

            _Render.r = (_Render.r + (_Temperature / 273.15)) * _Mixing;
		    _Render.g = (_Render.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Render.b = (_Render.b) * _Mixing;

        /* Ambient */
            _Render.rgb += _AddColor.rgb * _Add;
            _Render.rgb *= lerp(1.0, _MulColor.rgb, _Mul);

            _Render.rgb *= _Exposure / 100.0; 
            _Render.rgb = (_Render.rgb - 0.5) * (_Contrast / 100.0) + 0.5;
            _Render.rgb = Fun_Saturation(_Render.rgb, _Saturation / 100.0);
            _Render.rgb = Fun_Vibrance(_Render.rgb, _Vibrance / 100.0);

            _Render.rgb = Fun_Bloom(_Render.rgb, _Bloom, _BloomThreshold);

        _Result.rgb = lerp(_Result.rgb, pow(abs(_Render.rgb), _Power), _Mixing);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;
    Out.Color = _Result;
    return Out;  
}
