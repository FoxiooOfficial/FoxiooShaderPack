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

    float   _Cyan, _Magenta, _Yellow, _Black, _Mixing;
    
    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 RGBtoCMYK(float3 _Render)
{
    float4 _CMYK;

        _CMYK.x = 1.0 - max(_Render.r, max(_Render.g, _Render.b));  /*  Black   */
        _CMYK.y = (1.0 - _Render.r - _CMYK.x) / (1.0 - _CMYK.x);    /*  Cyan    */
        _CMYK.z = (1.0 - _Render.g - _CMYK.x) / (1.0 - _CMYK.x);    /*  Magenta */
        _CMYK.w = (1.0 - _Render.b - _CMYK.x) / (1.0 - _CMYK.x);    /*  Yellow  */
    
    return _CMYK.yzwx;
}

float3 CMYKtoRGB(float4 _CMYK)
{
    float3 _Render;

        _Render.r = (1.0 - _CMYK.r) * (1.0 - _CMYK.w);
        _Render.g = (1.0 - _CMYK.g) * (1.0 - _CMYK.w);
        _Render.b = (1.0 - _CMYK.b) * (1.0 - _CMYK.w);
    
    return _Render;
}

float4 Fun_CMYKMagic(float4 _Result)
{
    float4 _CMYK = RGBtoCMYK(_Result.rgb);
    
    float4  _Value = float4(_Cyan, _Magenta, _Yellow, _Black);
            _Value /= 100.0;

                _CMYK -= _Value;
    
    _Result.rgb = CMYKtoRGB(_CMYK);
    return _Result;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

                _Result = Fun_CMYKMagic(_Result);

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
            _Result.a = _Render_Texture.a;
    
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }