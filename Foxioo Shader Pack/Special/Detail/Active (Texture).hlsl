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

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Size;
    float _Angle;
    float _Threshold;
    float4 _Color;
    float4 _ColorEx;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_Target;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

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

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = saturate(0.1 + (_Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b));

    return saturate(step(_Y * _Result.a, _Threshold));
}

float2 Fun_Border(Texture2D _Texture, SamplerState _Sampler, float2 In, float2 _Off, float _Alpha)
{
    float2 _Result;

    _Result.x = (
        Fun_Luminance(_Texture.Sample(_Sampler, In + _Off)) * 2.0 +
        Fun_Luminance(_Texture.Sample(_Sampler, In - _Off)) * 2.0 
    ) - _Alpha * 2.0;

    _Result.y = (
        Fun_Luminance(_Texture.Sample(_Sampler, In + _Off)) * 2.0 +
        Fun_Luminance(_Texture.Sample(_Sampler, In - _Off)) / 2.0 
    ) - _Alpha;

    return _Result;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);

        float4 _Result;
        float2 _Render;
        float2 _Offset = _Size * (-float2(fPixelWidth, fPixelHeight));

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
            
            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, 5.0 * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y + 0.1), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.2));

            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, float2(-5.0, 5.0), _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.2));
            
            /* ############################# */

            /* ############################# */
            
            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, 4.95 * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y + 0.1), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 1.5));

            float2 _Result_Side_L = _Render;
            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, float2(-4.95, 4.95) * _Offset, _Render_Texture.a);
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb * (_Render.y), saturate((0.25 - saturate(abs(_Render.x * 6.0))) * 0.5));
            
            /* ############################# */

            /* ############################# */
            
            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, 2.0 * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0), saturate(0.5 - saturate(abs(_Render.x * 6.0))));

            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, float2(-2.0, 2.0), _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0),  saturate(0.5 - saturate(abs(_Render.x * 6.0))));
            
            /* ############################# */

            /* ############################# */

            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, 1.85 * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0) + _Result_Side_L.y * 0.1, saturate((1.0 - saturate(abs(_Render.x * 6.0))) - (_Result_Side_L.y * 0.4)));

            _Render = Fun_Border(S2D_Image, S2D_ImageSampler, In.texCoord, float2(-1.85, 1.85) * _Offset, _Render_Texture.a) * 0.3;
            _Result.rgb = lerp(_Result.rgb, _ColorEx.rgb + min(_Render.y - 0.09, 0.0), 1.0 - saturate(abs(_Render.x * 6.0)));
            
            /* ############################# */

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

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
