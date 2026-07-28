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
sampler2D _Texture : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Time, _Mixing;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Aurora(float _Noise)
{
    const float3 _Light_Hight = float3(0.3882, 0.8039, 0.9059);
    const float3 _Light_Medium = float3(0.06, 0.7, 0.62);
    const float3 _Light_Low = float3(0.0392, 0.4863, 0.3882);
    const float3 _Light_Null = float3(0.0,0.0, 0.0);


    float3 _Aurora = lerp(_Light_Null, _Light_Low, smoothstep(0.0, 0.33, _Noise));
    _Aurora = lerp(_Aurora, _Light_Medium, smoothstep(0.33, 1.0, _Noise));
    _Aurora = lerp(_Aurora, _Light_Hight,  smoothstep(1.0, 2.0, _Noise));

    return _Aurora;
}

static const float _Max = 25.0;

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;
        
        _Result.a = _Render_Texture.a;

        _Result.rgb = dot(pow(abs(_Result.rgb), 6.0), float3(0.2126, 0.7152, 0.0722));
        float Wave = sin(_Mixing * 10.0);

        for (int i = 1; i < _Max; i++)
        {
            float w = In.x;
        
            w += sin((1.0 - In.y) * 2.0 + _Time) / 60.0;
            w = abs(sin(-w * 10.0 * i / _Max * 2.0 + _Time / i) / 20. + sin(40.0 * i / _Max + _Time) / 18.0) * 35.0;

                w += ((1.0 - In.y) * 2.4 - 1.6);
                w = smoothstep(0.4, 0.7, w / 5.0) / 20.0;

            float _Color = 1.0 - (abs(In.y - 0.5)) * 3.0;
            _Color += (In.x + 4.0 + Wave * 0.5 + 0.5) * 0.3;

                float3 _Perlin = tex2D(_Texture, frac(In * 0.3 + float2(_Time * i / 100.0, 0.0))).rgb;
                float _Lum = (_Perlin.r + _Perlin.g + _Perlin.b) / 32.0;

            _Result.rgb += (5.0 / _Max) * (Fun_Aurora(0.7 * (_Color + In.x + _Time)) * w * 5.0 + Fun_Aurora(_Lum));
        }

        _Result.rgb += Fun_Aurora(1.0 - abs(In.y * In.y * 2.0 - 0.8)) * In.y;
        _Result.rgb = lerp(_Render.rgb, pow(abs(_Result.rgb), 2.0) * 1.8, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 Main(); } }
