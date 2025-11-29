/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (21.11.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Add, _Mul,
            _Exposure, _Contrast, _Saturation, 
            _Vibrance,
            _Power,
            _Bloom, _BloomThreshold,
            _Time, _Temperature;

    bool    _Blending_Mode;

    float4  _AddColor, _MulColor;

    static float3 _Blend[6] = {
        float3(0.2, 0.3, 0.4),
        float3(0.8, 0.5, 0.2),
        float3(1.0, 0.8, 0.6),
        float3(1.0, 1.0, 1.0),
        float3(1.0, 0.9, 0.8),
        float3(0.8, 0.4, 0.2) 
    };


/************************************************************/
/* Main */
/***********************************************************/

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

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

        /* Time */
        
        // 😭🙏 What I wrote here
        _Time = fmod(_Time, 24.0);
        if (_Time < 0) _Time = 24.0 - abs(_Time);

            if (_Time < 4.0) {
                _Render.rgb *= lerp(_Blend[0], _Blend[1], _Time / 4.0);
            }
            else if (_Time < 6.0) {
                _Render.rgb *= lerp(_Blend[1], _Blend[2], (_Time - 4.0) / 2.0);
            }
            else if (_Time < 12.0) {
                _Render.rgb *= lerp(_Blend[2], _Blend[3], (_Time - 6.0) / 6.0);
            }
            else if (_Time < 16.0) {
                _Render.rgb *= lerp(_Blend[3], _Blend[4], (_Time - 12.0) / 4.0);
            }
            else if (_Time < 18.0) {
                _Render.rgb *= lerp(_Blend[4], _Blend[5], (_Time - 16.0) / 2.0);
            }
            else {
                _Render.rgb *= lerp(_Blend[5], _Blend[0], (_Time - 18.0) / 6.0);
            }

        /* Temperature */

            _Render.r = (_Render.r + (_Temperature / 273.15)) * _Mixing;
		    _Render.g = (_Render.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Render.b = (_Render.b) * _Mixing;

        /* Ambient */
            _Render.rgb += _AddColor * _Add;
            _Render.rgb *= lerp(1.0, _MulColor.rgb, _Mul);

            _Render.rgb *= _Exposure / 100.0; 
            _Render.rgb = (_Render.rgb - 0.5) * (_Contrast / 100.0) + 0.5;
            _Render.rgb = Fun_Saturation(_Render.rgb, _Saturation / 100.0);
            _Render.rgb = Fun_Vibrance(_Render.rgb, _Vibrance / 100.0);

            _Render.rgb = Fun_Bloom(_Render.rgb, _Bloom, _BloomThreshold);

        
    _Result.rgb = lerp(_Result.rgb, pow(_Render.rgb, _Power), _Mixing);
    _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
