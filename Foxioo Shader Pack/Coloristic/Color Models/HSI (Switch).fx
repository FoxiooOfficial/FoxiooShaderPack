/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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

    float   _Hue, _Saturation, _Intensity, _Mixing;
    
    bool    _Blending_Mode;

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


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

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
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
