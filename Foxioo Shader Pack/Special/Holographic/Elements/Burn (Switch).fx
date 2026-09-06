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
sampler2D _Texture_Fire : register(s2);
sampler2D _Texture_Mask : register(s3);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing, _Offset,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);
    float4 _Render_Ice = tex2D(_Texture_Fire, In.texCoord);
    float4 _Render_Mask = tex2D(_Texture_Mask, In.texCoord);

        float4 _Result;
        float4 _Render;

            float2 _Size = float2(fPixelWidth, fPixelHeight);
            if(!_Blending_Mode)
            {
                _Result = tex2D(S2D_Image, frac(In.texCoord + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
                _Render = _Render_Texture;
            }
            else
            {
                _Result = tex2D(S2D_Background, frac(In.texCoord + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
                _Render = _Render_Background;
            }

        float _StepAlpha = smoothstep(1.0, 0.0, pow((_Mixing - _Render_Mask.r), 10.0));
        float3 _ColorFire = _Render_Ice.rgb * _Render_Ice.rgb * 2.0 + _Render_Ice.rgb + pow(distance(_Render_Mask.r, _Mixing + 0.1), 10.0) * float3(0.8, 0.7, 0.0);

        _Result.rgb = lerp(_Render.rgb, 0, saturate(pow(distance(_Render_Mask.r, max(0, _Mixing) + 0.2), _Offset) * 40.0));
        _Result.rgb = lerp(_Result.rgb, _ColorFire, pow(distance(_Render_Mask.r, max(0, _Mixing) + 0.2), _Offset));
        _Result.a = lerp(_Result.a, _Result.a * _StepAlpha, saturate(_Mixing));

            _Result.rgb += _Render_Background.rgb * _StepAlpha * pow(distance(_Render_Mask.r, _Mixing + 0.2), _Offset);
        
        _Result = lerp(_Render, _Result, clamp(_Mixing, 0.0, 1.0));
        _Result.a *= _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
