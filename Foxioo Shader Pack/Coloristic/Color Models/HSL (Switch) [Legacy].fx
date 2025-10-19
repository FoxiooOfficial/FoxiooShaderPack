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
/* Varibles */
/***********************************************************/

    float   _Hue, _Saturation, _Lightness, _Mixing;
    
    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{

    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Render;
    float4 _Result;

    if(!_Blending_Mode)
    {
        _Render = _Render_Texture;
        _Result = _Render_Texture;
    }
    else
    {
        _Render = _Render_Background;
        _Result = _Render_Background;
    }


    /* Hue */

    float _Hue_Temp = fmod(_Hue / 120.0, 3.0);
    if (_Hue_Temp < 0.0) _Hue_Temp = 3.0 - abs(_Hue_Temp);

        if (_Hue_Temp >= 0.0 && _Hue_Temp < 1.0)
        {
            _Render.r = _Result.r + (_Result.g - _Result.r) * _Hue_Temp;
            _Render.g = _Result.g + (_Result.b - _Result.g) * _Hue_Temp;
            _Render.b = _Result.b + (_Result.r - _Result.b) * _Hue_Temp;
        }

        else if (_Hue_Temp >= 1.0 && _Hue_Temp < 2.0)
        {
            _Render.r = _Result.g + (_Result.b - _Result.g) * (_Hue_Temp - 1.0);
            _Render.g = _Result.b + (_Result.r - _Result.b) * (_Hue_Temp - 1.0);
            _Render.b = _Result.r + (_Result.g - _Result.r) * (_Hue_Temp - 1.0);
        }

        else if (_Hue_Temp >= 2.0 && _Hue_Temp < 3.0)
        {
            _Render.r = _Result.b + (_Result.r - _Result.b) * (_Hue_Temp - 2.0);
            _Render.g = _Result.r + (_Result.g - _Result.r) * (_Hue_Temp - 2.0);
            _Render.b = _Result.g + (_Result.b - _Result.g) * (_Hue_Temp - 2.0);
        }


    /* Saturation */

    float _Color = (_Render.r + _Render.g + _Render.b) / 3.0;

        _Render.rgb = _Color * (1.0 - (_Saturation / 50.0)) + _Render.rgb * (_Saturation / 50.0);

    _Render.rgb += (_Lightness - 50.0) / 50.0;

    _Render.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
    _Render.a = _Render_Texture.a;
    
    return _Render;

}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
