/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _Border,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

static const int SAMPLES_INNER  = 12;
#define PIXELSIZE               float2(fPixelWidth, fPixelHeight)

float Fun_Inner(float2 In)
{
    float _Alpha = 0.0;
    for(int y = 0; y <= SAMPLES_INNER; y++)
    {
        for(int x = 0; x <= SAMPLES_INNER; x++)
        {
            float2 _Offset = (float2(x, y) / (float)SAMPLES_INNER - 0.5);
            float _Render = tex2D(S2D_Image, In + _Offset * _Border * PIXELSIZE).a;

            _Alpha += _Render;
        }
    }
    return _Alpha / float(SAMPLES_INNER * SAMPLES_INNER);
}

float Fun_Lum (float4 _Result) { 
    return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b) * _Result.a;
}

float Fun_Random(float2 In) {
    return frac(sin(dot(In, float2(12.9898, 78.233))) * 43758.5453);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);
        
    float _Rand = Fun_Random(In + _Render_Texture.rb + _Render_Texture.bg + _Render_Background.rg + _Render_Background.br);
    float _Lum = Fun_Lum(_Render_Texture);
    float _Lum_Background = Fun_Lum(_Render_Background);

        float3 _Space = lerp(float3(0.0, 0.0, 0.0), float3(0.15, 0.05, 0.25), _Lum);
        _Space += (_Space * (tex2D(S2D_Background, In_Background + tan(_Lum) * _Lum * 0.25 - tan(_Lum_Background) * 0.25 - _Rand).rgb) * 1.5);
        _Space *= 0.5;

            float3 _Void = tex2D(S2D_Background, In_Background + (_Render_Background * (1.0 - _Render_Texture) + _Rand) * 0.1).rgb;
            _Space = lerp(_Space, _Space + _Void * float3(0.15, 0.05, 0.25), 1.0 - _Lum);

            float4 _Result = _Render_Texture;
            _Result.rgb = lerp( _Render_Texture.rgb, 
                                _Space + pow(Fun_Random(In + _Space.rb + _Space.bg + _Render_Background.rg + _Render_Background.br + _Rand), 255.0), 
                                _Mixing);

            float _Inner = (1.0 - Fun_Inner(In)) * _Render_Texture.a;
            _Result.rgb += ((_Inner / pow(cos(_Lum - _Inner), 6.0)) * saturate(_Mixing)) * 0.05;
            _Result.rgb += saturate(_Inner * _Inner + (1.0 - _Lum) * 0.15) * 4.0;

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
