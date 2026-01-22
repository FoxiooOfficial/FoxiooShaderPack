/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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
            _ShadowThreshold,
            _ShadowAlpha,
            _OutlineThreshold,
            _OutlineAlpha,
            _OutlineScale,
            _OutlineAntialiasing,
            _ColorSteps,
            _Saturation,

            fPixelWidth, fPixelHeight;

    float4  _OutlineColor;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_ColorRamp(float4 _Color, float _Steps)
{
    _Color.rgb = floor(_Color.rgb * _Steps) / _Steps;
    return _Color;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result, _GradientX, _GradientY;

    if(_Blending_Mode == 0)
    {
        _Result = tex2D(S2D_Image, In) * _Mixing;
    }
    else
    {
        _Result = tex2D(S2D_Background, In) * _Mixing;
    }

    float _Average = (_Result.r + _Result.g + _Result.b) / 3.0;

    // Saturation
    _Result.rgb = _Average * (1 - (_Saturation / 50.0)) + _Result.rgb * (_Saturation / 50.0);

    // Shadow
    if(_Average < _ShadowThreshold)
        _Result.rgb *= _Average + (1 - (_ShadowAlpha + _ShadowThreshold));

    // Outline
    if(_Blending_Mode == 0)
    {
        _GradientX = tex2D(S2D_Image, In + float2(fPixelWidth, 0)) - tex2D(S2D_Image, In - float2(fPixelWidth, 0));
        _GradientY = tex2D(S2D_Image, In + float2(0, fPixelHeight)) - tex2D(S2D_Image, In - float2(0, fPixelHeight));
    }
    else
    {
        _GradientX = tex2D(S2D_Background, In + float2(fPixelWidth, 0)) - tex2D(S2D_Background, In - float2(fPixelWidth, 0));
        _GradientY = tex2D(S2D_Background, In + float2(0, fPixelHeight)) - tex2D(S2D_Background, In - float2(0, fPixelHeight));       
    }

    float _EdgeDetection = (length(_GradientX.rgb) + length(_GradientY.rgb)) * _OutlineScale;
    float _AntialiasedOutline = smoothstep(_OutlineThreshold - _OutlineAntialiasing, _OutlineThreshold + _OutlineAntialiasing, _EdgeDetection);

    if (_AntialiasedOutline > _OutlineThreshold)
    {
        _Result = lerp(_Result, _OutlineColor, _OutlineAlpha * _AntialiasedOutline);
    }

    // Color Ramp
    _Result = Fun_ColorRamp(_Result, _ColorSteps);

    _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
