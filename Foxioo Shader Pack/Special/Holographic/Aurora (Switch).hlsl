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

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

Texture2D<float4> _Texture : register(t2); 
SamplerState S2D_TextureSampler : register(s2);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Time;
    // sampler2D S2D_Texture;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

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

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;
        
        _Result.a = _Render_Texture.a;

        _Result.rgb = dot(pow(abs(_Result.rgb), 6.0), float3(0.2126, 0.7152, 0.0722));
        float Wave = sin(_Mixing * 10.0);

        for (int i = 1; i < _Max; i++)
        {
            float w = In.texCoord.x;
        
            w += sin((1.0 - In.texCoord.y) * 2.0 + _Time) / 60.0;
            w = abs(sin(-w * 10.0 * i / _Max * 2.0 + _Time / i) / 20. + sin(40.0 * i / _Max + _Time) / 18.0) * 35.0;

                w += ((1.0 - In.texCoord.y) * 2.4 - 1.6);
                w = smoothstep(0.4, 0.7, w / 5.0) / 20.0;

            float _Color = 1.0 - (abs(In.texCoord.y - 0.5)) * 3.0;
            _Color += (In.texCoord.x + 4.0 + Wave * 0.5 + 0.5) * 0.3;

                float3 _Perlin = _Texture.Sample(S2D_TextureSampler, frac(In.texCoord * 0.3 + float2(_Time * i / 100.0, 0.0))).rgb;
                float _Lum = (_Perlin.r + _Perlin.g + _Perlin.b) / 32.0;

            _Result.rgb += (5.0 / _Max) * (Fun_Aurora(0.7 * (_Color + In.texCoord.x + _Time)) * w * 5.0 + Fun_Aurora(_Lum));
        }

        _Result.rgb += Fun_Aurora(1.0 - abs(In.texCoord.y * In.texCoord.y * 2.0 - 0.8)) * In.texCoord.y;
        _Result.rgb = lerp(_Render.rgb, pow(abs(_Result.rgb), 2.0) * 1.8, _Mixing);

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
