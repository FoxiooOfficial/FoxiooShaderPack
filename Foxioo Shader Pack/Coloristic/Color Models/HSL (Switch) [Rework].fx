/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.8 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Hue, _Saturation, _Lightness, _Mixing;
    
    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float3 RGBtoHSL(float3 _Render)
{
    float _CMax = max(_Render.r, max(_Render.g, _Render.b));
    float _CMin = min(_Render.r, min(_Render.g, _Render.b));
    float _Delta = _CMax - _CMin;

        float _H = 0.0;
        float _S = 0.0;
        float _L = (_CMax + _CMin) * 0.5;

    if (_Delta != 0.0)
    {
        _S = _Delta / (1.0 - abs(2.0 * _L - 1.0));

        if (_CMax == _Render.r)
        {
            _H = 60.0 * ((_Render.g - _Render.b) / _Delta);
        }
        else if (_CMax == _Render.g)
        {
            _H = 60.0 * ((_Render.b - _Render.r) / _Delta + 2.0);
        }
        else
        {
            _H = 60.0 * ((_Render.r - _Render.g) / _Delta + 4.0);
        }

        if (_H < 0.0) _H += 360.0;
    }
    
    return float3(_H, _S, _L);
}

float3 HSLtoRGB(float _H, float _S, float _L)
{
    float _C = (1.0 - abs(2.0 * _L - 1.0)) * _S;
    float _X = _C * (1.0 - abs((fmod(_H / 60.0, 2.0)) - 1.0));
    float _M = _L - _C * 0.5;
    
    float3 _Render =    (_H < 60.0) ? float3(_C, _X,  0) :
                        (_H < 120.0) ? float3(_X, _C,  0) :
                        (_H < 180.0) ? float3( 0, _C, _X) :
                        (_H < 240.0) ? float3( 0, _X, _C) :
                        (_H < 300.0) ? float3(_X,  0, _C) :
                        float3(_C, 0, _X);
    
    return (_Render + _M);
}


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result =    _Render;

    /* Hue Adjustment */
        float3 _HSL = RGBtoHSL(_Render.rgb);
            _HSL.x = fmod(_HSL.x + _Hue, 360.0);

            if (_HSL.x < 0.0) { _HSL.x += 360.0; }

        _Render.rgb = HSLtoRGB(_HSL.x, _HSL.y, _HSL.z);

    /* Saturation Adjustment */
        float _Color = (_Render.r + _Render.g + _Render.b) / 3.0;
            _Render.rgb = lerp(_Color, _Render.rgb, _Saturation / 50.0);

    /* Lightness Adjustment */
        _Render.rgb += (_Lightness - 50.0) / 50.0;

    /* Mixing */
        _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
    
    _Render.a = _Render_Texture.a;
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }