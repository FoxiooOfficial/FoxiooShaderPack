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

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

/*  *NOT* All color calculations are taken from: 
    https://printtechnologies.org/standards/files/pdf-reference-1.6-addendum-blend-modes.pdf */

float Fun_Value(float3 _Result) {
    return max(_Result.r, max(_Result.g, _Result.b));
}

float3 Fun_ClipColor(float3 _Color)
{
    float _V = Fun_Value(_Color);
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    float _Div = _ColorMax - _V;
    if(_Div == 0.0) _Div = 1e7;

    if(_ColorMin < 0.0) { _Color = _V + (((_Color - _V) * _V) / (_V - _ColorMin)); }
    if(_ColorMax > 1.0) { _Color = _V + (((_Color - _V) * (1.0 - _V)) / _Div); }

    return _Color;
}

float Fun_Intensity(float3 _Result) {
    return (_Result.r + _Result.g + _Result.b) / 3.0;
}

float3 Fun_SetIntensity(float3 _Color, float _I)
{
    float _GetIntensity = _I - Fun_Intensity(_Color);
    _Color += _GetIntensity;

    return Fun_ClipColor(_Color);
}

/***********************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Render, _Result;
        
            _Render.rgb = Fun_SetIntensity(_Render_Background.rgb, Fun_Intensity(_Render_Texture.rgb));

        _Result.rgb = lerp(_Render_Texture.rgb, _Render.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
