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

    float _Mixing, _Time;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Lum(float4 _Result) { 
    return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b);
}

float2 Fun_UV(float2 UV, float _Lum) {
    return float2(_Lum * sin(_Lum + UV.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + UV.y * 400.0 * _Mixing + sin(UV.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing);
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

    float4 _Result, _Render;
    
        if(!_Blending_Mode) {   
            _Render = _Render_Texture;

        }
        else {
            _Render.rgb = _Render_Background.rgb;
            _Render.a = _Render_Texture.a;
        }

        _Result = _Render_Texture;

            const float3 _Color0 = float3(1.0, 1.0, 1.0); // Whi
            const float3 _Color1 = float3(1.0, 1.0, 0.0); // Yel
            const float3 _Color2 = float3(1.0, 0.0, 0.0); // Red
            const float3 _Color3 = float3(0.5, 0.0, 0.5); // Pur
            const float3 _Color4 = float3(0.0, 0.0, 0.25); // Blu
            const float3 _Color5 = float3(0.0, 0.0, 0.0); // Blk

                float _Lum = Fun_Lum(_Result);
                float2 _Off;
                    
                if(!_Blending_Mode) {
                    _Off = Fun_UV(In.texCoord, _Lum);
                    _Result = tex2D(S2D_Image, In.texCoord + _Off);
                }
                else {
                    _Off = Fun_UV(In.bgCoord, _Lum);
                    _Result.rgb = tex2D(S2D_Background, In.bgCoord + _Off).rgb;
                    _Result.a = _Render.a;
                }

                    _Lum = Fun_Lum(_Result);
                    if (_Lum < 0.2)         _Result.rgb = lerp(_Color5, _Color4, _Lum / 0.2);
                    else if (_Lum < 0.4)    _Result.rgb = lerp(_Color4, _Color3, (_Lum - 0.2) / 0.2);
                    else if (_Lum < 0.6)    _Result.rgb = lerp(_Color3, _Color2, (_Lum - 0.4) / 0.2);
                    else if (_Lum < 0.8)    _Result.rgb = lerp(_Color2, _Color1, (_Lum - 0.6) / 0.2);
                    else                    _Result.rgb = lerp(_Color1, _Color0, (_Lum - 0.8) / 0.2);

            _Result = lerp(_Render, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
