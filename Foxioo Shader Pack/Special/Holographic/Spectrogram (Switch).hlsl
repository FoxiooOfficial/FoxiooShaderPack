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

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Time;
    bool __;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
  float2 bgCoord : TEXCOORD1;
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

float Fun_Lum(float4 _Result) { 
    return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b);
}

float2 Fun_UV(float2 UV, float _Lum) {
    return float2(_Lum * sin(_Lum + UV.x * _Lum * 200.0 * _Mixing + _Time) * 0.01 * _Mixing, _Lum * cos(_Lum + UV.y * 400.0 * _Mixing + sin(UV.x * 10.0 + _Time * _Lum) + _Time) * 0.01 * _Mixing);
}

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

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
                    _Result = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Off);
                }
                else {
                    _Off = Fun_UV(In.bgCoord, _Lum);
                    _Result.rgb = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord + _Off).rgb;
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
