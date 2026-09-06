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

    float   _Mixing, _Time, _Alpha;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result, _Render;
        _Result.a = _Render_Texture.a;

        if(!_Blending_Mode) {
            _Render = _Render_Texture;
        }
        else {
            _Render = _Render_Background;
        }

        _Result.rgb = lerp(_Render.rgb, float3(0.0, 0.0, 0.0), _Alpha);
        float t = _Time;

        float _Off = cos(In.texCoord.x * 2.0 - t * 0.6
                        + sin(In.texCoord.x * 0.031 - t * 2.0) * 0.1
                        - sin(In.texCoord.x * 4.0 - t * 0.2) * 0.2
                        + cos(In.texCoord.x * 0.0115 - t) * 0.1
                        - cos(In.texCoord.x / 0.1 - t * 2.0) * 0.3
                        + sin(t * 0.02) * 0.1
                    ) * 0.2;

        float2 _UV = float2(In.texCoord + float2(0.0, -0.5 + _Off)) * float2(960.0, 4.0);
        float _High = (1.0 / _Off) / 8.0;

        float _Y =  sin(_UV.x * 0.002 + t) * 160.0 +
                    sin(_UV.x * 0.007 + t) * 80.0 +
                    sin(_UV.x * 0.023 - t) * 40.0 +
                    sin(_UV.x * 0.011 + t) * 20.0 +
                    sin(_UV.x * 0.031 - t) * 10.0;

        _Y /= 310.0;

            float2 _Size = float2(_Y / _High, -_Y / _High);

                float _Min = min(_Size.x, _Size.y);
                float _Max = max(_Size.x, _Size.y);
                float _Lerp = _UV.y - _Off * 2.0;

        float _Hight = 0.02;
        float _Wave = smoothstep(_Min - _Hight, _Min, _Lerp) * smoothstep(_Max + _Hight, _Max, _Lerp);
        float _Gradient = saturate(abs(_Lerp) / _Max);

        static const float3 _Blue = float3(0.0, 0.0, 1.0);
        static const float3 _White = float3(1.0, 1.0, 1.0);

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + lerp(_White, _Blue, _Gradient), _Wave);
        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
