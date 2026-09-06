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
//sampler2D S2D_Background : register(s1);

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
            _Threshold,

            fPixelWidth, fPixelHeight;

    float4 _ColorEx, _Color;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = saturate(0.1 + (_Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b));

    return saturate(step(_Y * _Result.a, _Threshold));
}

float2 Fun_Sharp(sampler2D _Sampler, float2 In, float2 _Off, float _Alpha)
{
    float2 _Result;

    _Result.x = (
        Fun_Luminance(tex2D(_Sampler, In + _Off)) * 2.0 +
        Fun_Luminance(tex2D(_Sampler, In - _Off)) * 2.0 
    ) - _Alpha * 2.0;

    _Result.y = (
        Fun_Luminance(tex2D(_Sampler, In + _Off)) * 2.0 +
        Fun_Luminance(tex2D(_Sampler, In - _Off)) / 2.0 
    ) - _Alpha;

    return _Result;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    
        float4 _Result;
        float2 _Render;
        float2 _Offset = _Size * -float2(fPixelWidth, fPixelHeight);

        float _Sin;
        float _Cos;
        sincos(radians(_Angle), _Sin, _Cos);
        _Offset = float2(
            _Offset.x * _Cos - _Offset.y * _Sin,
            _Offset.x * _Sin + _Offset.y * _Cos
        );

            _Result.rgb = _Color.rgb;
            // float3(184.0, 219.0, 219.0)

            /* ############################# */

            _Render = Fun_Sharp(S2D_Image, In.texCoord, 5.0 * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y + 0.1), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.2));

            _Render = Fun_Sharp(S2D_Image, In.texCoord, float2(-5.0, 5.0) * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * _Render.y, saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.2));
            
            /* ############################# */

            /* ############################# */

            _Render = Fun_Sharp(S2D_Image, In.texCoord, 4.95 * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y + 0.1), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 1.5));

            float2 _Result_Side_L = _Render;
            _Render = Fun_Sharp(S2D_Image, In.texCoord, float2(-4.95, 4.95) * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * _Render.y, saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.5));
            
            /* ############################# */

            /* ############################# */

            _Render = Fun_Sharp(S2D_Image, In.texCoord, 2.0 * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0), saturate(0.5 - saturate(abs(_Render.x * 6.0))));

            _Render = Fun_Sharp(S2D_Image, In.texCoord, float2(-2.0, 2.0) * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0),  saturate(0.5 - saturate(abs(_Render.x * 6.0))));
            
            /* ############################# */

            /* ############################# */

            _Render = Fun_Sharp(S2D_Image, In.texCoord, 1.85 * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0) + _Result_Side_L.y * 0.1, saturate((1.0 - saturate(abs(_Render.x * 6.0))) - (_Result_Side_L.y * 0.4)));

            _Render = Fun_Sharp(S2D_Image, In.texCoord, float2(-1.85, 1.85) * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0), 1.0 - saturate(abs(_Render.x * 6.0)));
            
            /* ############################# */

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
