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
sampler2D _Texture_Ice : register(s2);
sampler2D _Texture_Mask : register(s3);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _Offset,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Luminance(float3 _Result) {
    return 0.299 * _Result.r + 0.587 * _Result.g + 0.114 * _Result.b;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);
    float4 _Render_Ice = tex2D(_Texture_Ice, In);
    float4 _Render_Mask = tex2D(_Texture_Mask, In);

        float4 _Result;
        float4 _Render;

            float2 _Size = float2(fPixelWidth, fPixelHeight);
            if(!_Blending_Mode)
            {
                _Result = tex2D(S2D_Image, frac(In + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
                _Render = _Render_Texture;
            }
            else
            {
                _Result = tex2D(S2D_Background, frac(In_Background + _Size * (float2(_Render_Ice.rb - 0.5) * _Render_Ice.b * _Offset)));
                _Render = _Render_Background;
            }

        _Result.rgb = _Result.rgb * Fun_Luminance(_Render_Ice.rgb) + Fun_Luminance(_Render_Ice.rgb) * 0.75 * _Render_Ice.rgb;
        _Result.rgb += Fun_Luminance(_Render_Ice.rgb) * 0.35;

        _Result = lerp(_Render, _Result, smoothstep(Fun_Luminance(_Render_Ice.rgb) * (1.0 - abs(_Mixing)), Fun_Luminance(_Render_Ice.rgb), abs(_Mixing) * (1.0 - _Render_Mask.r)));
        
        if(_Blending_Mode)
            _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
