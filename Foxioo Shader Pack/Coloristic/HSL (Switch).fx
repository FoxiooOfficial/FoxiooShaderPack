
/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (24.06.2024) */
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

    float4 _Render = tex2D(S2D_Image, In);
    float4 _Render_Texture;

    if(_Blending_Mode == 0)
    {
        _Render_Texture = tex2D(S2D_Image, In) * _Mixing;
    }
    else
    {
        _Render_Texture = tex2D(S2D_Background, In) * _Mixing;
    }

    /* Hue */

        _Hue /= 120.0;

        _Hue = _Hue % 3;

        if (_Hue < 0) _Hue = 3 - abs(_Hue);

        if (_Hue >= 0 && _Hue < 1)
        {
            _Render.r = _Render_Texture.r + (_Render_Texture.g - _Render_Texture.r) * _Hue;
            _Render.g = _Render_Texture.g + (_Render_Texture.b - _Render_Texture.g) * _Hue;
            _Render.b = _Render_Texture.b + (_Render_Texture.r - _Render_Texture.b) * _Hue;
        }

        else if (_Hue >= 1 && _Hue < 2)
        {
            _Render.r = _Render_Texture.g + (_Render_Texture.b - _Render_Texture.g) * (_Hue - 1);
            _Render.g = _Render_Texture.b + (_Render_Texture.r - _Render_Texture.b) * (_Hue - 1);
            _Render.b = _Render_Texture.r + (_Render_Texture.g - _Render_Texture.r) * (_Hue - 1);
        }

        else if (_Hue >= 2 && _Hue < 3)
        {
            _Render.r = _Render_Texture.b + (_Render_Texture.r - _Render_Texture.b) * (_Hue - 2);
            _Render.g = _Render_Texture.r + (_Render_Texture.g - _Render_Texture.r) * (_Hue - 2);
            _Render.b = _Render_Texture.g + (_Render_Texture.b - _Render_Texture.g) * (_Hue - 2);
        }

    /* Saturation */

    float _Color = (_Render.r + _Render.g + _Render.b) / 3.0;

        _Render.rgb = _Color * (1 - (_Saturation / 50.0)) + _Render.rgb * (_Saturation / 50.0);

    /* Lightness */

    _Render.rgb += (_Lightness - 50) / 50.0;
    
    return _Render;

}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
