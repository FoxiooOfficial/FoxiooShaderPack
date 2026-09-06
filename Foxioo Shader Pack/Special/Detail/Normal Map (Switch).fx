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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _Size,
            _Angle,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}

float3 Fun_Sharp(sampler2D _Sampler, float2 In, float2 _Off)
{
    float2 _Emboss;

    float3 _NW = tex2D(_Sampler, In + float2(-_Off.x,  -_Off.y)).rgb;
    float3 _N  = tex2D(_Sampler, In + float2(0.0,      -_Off.y)).rgb;
    float3 _NE = tex2D(_Sampler, In + float2( _Off.x,  -_Off.y)).rgb;
    float3 _W  = tex2D(_Sampler, In + float2(-_Off.x,   0.0))   .rgb;
    float3 _C  = tex2D(_Sampler, In)                            .rgb;
    float3 _E  = tex2D(_Sampler, In + float2( _Off.x,   0.0))   .rgb;
    float3 _SW = tex2D(_Sampler, In + float2(-_Off.x,  _Off.y)) .rgb;
    float3 _S  = tex2D(_Sampler, In + float2(0.0,      _Off.y)) .rgb;
    float3 _SE = tex2D(_Sampler, In + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = (Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW));
        _Emboss.y = (Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE)) - (Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE));
        //_Emboss.y = -_Emboss.y;

    float3 _Render = normalize(float3(_Emboss.x, _Emboss.y, 1.0 / _Mixing * max(1.0, _Size)));
    _Render = _Render * 0.5 + 0.5;

    return _Render;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);
    
        float4 _Result, _Render;
        float2 _Offset = _Size * -float2(fPixelWidth, fPixelHeight);

        float _Sin;
        float _Cos;
        sincos(radians(_Angle), _Sin, _Cos);
        _Offset = float2(
            _Offset.x * _Cos - _Offset.y * _Sin,
            _Offset.x * _Sin + _Offset.y * _Cos
        );

            if(!_Blending_Mode)
            {
                _Result.rgb = _Render_Texture.rgb;
                _Render.rgb = Fun_Sharp(S2D_Image, In.texCoord, _Offset);
            }
            else
            {
                _Result.rgb = _Render_Background.rgb;
                _Render.rgb = Fun_Sharp(S2D_Background, In.bgCoord, _Offset);

            }

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
