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
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _Mul;
    bool __;
	bool _Is_Pre_296_Build;
    int _Render_Switch;
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

#define M_PI 3.14159265359

float3 Fun_Asin(float3 _Color, int _Case)
{   
    float3 _Render = asin(_Color);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9 simulated
    { 
        float a = -1.0 / M_PI * 1.07596f;
        float p = -M_PI;

        if(any(_Color < -1.0))
            return a * pow((_Color - p), 2.0f);

        else if(any(_Color > 1.0))
            return -a * pow((-_Color - p), 2.0f);

        else
            return _Render;
    }

    else if(_Case == 2) // D3D11, OGL simulated
    {
        float NaN = _Mixing < 0.0f ? 0x7FC00000 : 0.0f;

        float3 _Result;

            _Result.r = abs(_Color.r) > 1.0f ? NaN : _Render.r;
            _Result.g = abs(_Color.g) > 1.0f ? NaN : _Render.g;
            _Result.b = abs(_Color.b) > 1.0f ? NaN : _Render.b;
            //_Result.a = abs(_Color.a) > 1.0 ? NaN : _Render.a;

        return _Result;
    }

    else return float3(0.0f, 0.0f, 0.0f);
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result, _Render;

            if(!_Blending_Mode) { _Result.rgb = Fun_Asin(_Render_Texture.rgb / (_Render_Background.rgb * _Mul), _Render_Switch); _Render = _Render_Texture; }
            else                { _Result.rgb = Fun_Asin((_Render_Background.rgb * _Mul) / _Render_Texture.rgb, _Render_Switch); _Render = _Render_Background; } 
 
            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
                if(_Mixing == 0.0) _Result.rgb = _Render.rgb;

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
