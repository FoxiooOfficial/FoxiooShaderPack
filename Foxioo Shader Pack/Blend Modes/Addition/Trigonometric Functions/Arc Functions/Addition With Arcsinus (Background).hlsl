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
    float _Mixing;
    float _Mul;
    int _Render_Switch;
	bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
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

#define M_PI 3.14159265359

/************************************************************/
/* Main */
/************************************************************/

// fusion-fx-preview: allow-fxc-warnings
#define M_PI 3.14159265359
#define M_PI_2 1.57079632679
#define M_NAN sqrt(-1.0)

float3 Fun_Real(float3 _Color, float3 _Render)
{   
    float NaN = _Mixing < 0.0 ? M_NAN : 0.0;
    return lerp(_Render, (float3)NaN, abs(_Color) > (float3)1.0);
}

float3 Fun_Asin(float3 _Color, int _Case)
{   
    float3 _Render = asin(_Color);
    float3 _Real = Fun_Real(_Color, _Render);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9 simulated
    { 
        float a = -1.0 / M_PI * 1.07596f;
        float3 _Out = 0.0;

        float3 _Neg = a * pow(_Color + M_PI, (float3)2.0);
        float3 _Pos = -a * pow(-_Color + M_PI, (float3)2.0);

        _Out = lerp(_Out, _Neg, _Color < (float3)-1.0);
        _Out = lerp(_Out, _Pos, _Color > (float3)1.0);

        return saturate(_Out / (M_PI * 0.43)) + saturate(_Real);
    }

    else if(_Case == 2) // D3D11, OGL simulated
        return _Real;
        
    else return (float3)0.0;
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

		float4 _Result = _Render_Texture + (_Render_Background * _Mul);

            _Result.rgb = Fun_Asin(_Result.rgb, _Render_Switch);
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
