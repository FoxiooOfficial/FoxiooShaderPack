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
/* Varibles */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

/*  All color calculations are taken from: 
    https://printtechnologies.org/standards/files/pdf-reference-1.6-addendum-blend-modes.pdf */

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

float3 Fun_ClipColor(float3 _Color)
{
    float _Y = Fun_Luminance(_Color);
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    float _Div = _ColorMax - _Y;
    if(_Div == 0.0) _Div = 1e7;

    if(_ColorMin < 0.0) { _Color = _Y + (((_Color - _Y) * _Y) / (_Y - _ColorMin)); }
    if(_ColorMax > 1.0) { _Color = _Y + (((_Color - _Y) * (1.0 - _Y)) / _Div); }

    return _Color;
}

float3 Fun_SetLum(float3 _Color, float _Y)
{
    float _GetLum = _Y - Fun_Luminance(_Color);
    _Color += _GetLum;

    return Fun_ClipColor(_Color);
}

float Fun_Sat(float3 _Color)
{
    float _ColorMin = min(_Color.r, min(_Color.g, _Color.b));
    float _ColorMax = max(_Color.r, max(_Color.g, _Color.b));

    return _ColorMax - _ColorMin;
}

float3 Fun_SetSat(float3 _Color, float _Sat)
{
    float _CurSat = Fun_Sat(_Color);

        if (_CurSat > 0.0) { _Color = lerp(0.5, _Color, _Sat / _CurSat); }
        else { _Color = 0.5; }
    
    return _Color;
}

/***********************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Render, _Result;
        
            _Render.rgb = Fun_SetLum(Fun_SetSat(_Render_Texture.rgb, Fun_Sat(_Render_Background.rgb)), Fun_Luminance(_Render_Background.rgb));
            _Result.rgb = lerp(_Render_Texture.rgb, _Render.rgb, _Mixing);
        
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
