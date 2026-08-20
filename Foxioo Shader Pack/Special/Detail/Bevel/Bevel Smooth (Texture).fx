/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (07.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Point;
    MagFilter = Point;
    AddressU = Border;
    AddressV = Border;
    BorderColor = float4(0, 0, 1, 0);
};

//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Size,

            _Dir,
            
            fPixelWidth, fPixelHeight;

    float4  _ColorLight, _ColorShadow;

/************************************************************/
/* Main */
/************************************************************/

static const int _Samples = 9;

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    
    float _Alpha = 0.0;
    float2 _Dirr;
    sincos(radians(_Dir), _Dirr.x, _Dirr.y);

    for (int i = 1; i <= _Samples; i++)
    {
        float2 _Offset = _Dirr * float2(fPixelWidth, fPixelHeight) * (float(i) / float(_Samples)) * _Size;
        
            float _Low = tex2D(S2D_Image, In + _Offset).a;
            float _High = tex2D(S2D_Image, In - _Offset).a;
        
        _Alpha += (_Low - _High);
    }

    _Alpha /= _Samples;

        float4 _Render = _Render_Texture;
            _Render.rgb += _Alpha > 0.0 ? _Alpha * _ColorLight.rgb : _Alpha * (1.0 - _ColorShadow.rgb);

        _Render = lerp(_Render_Texture, _Render, _Mixing);
    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
