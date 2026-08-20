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

Texture2D<float4> _Texture : register(t1);
SamplerState _TextureSampler : register(s1);

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _RotX;
    bool ____;
    float _PointX;
    float _PointY;
    bool _____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ______;
    int _Looping_Mode;
    float _Mixing;
    //Texture2D _Texture_Mask;
    bool _Overlay;
    bool _______;
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

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float _RotX_Fix = radians(_RotX);

        float _Sin;
        float _Cos;
        sincos(_RotX_Fix, _Sin, _Cos);

    return _Points + mul(float2x2(_Cos, _Sin, -_Sin, _Cos), In - _Points);
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);

    float2 _Pos = float2(_PosX, _PosY);
    float2 _Point = float2(_PointX, _PointY);
    float2 _ScaleEx = float2(_ScaleX, _ScaleY) * _Scale;

            float2  UV = Fun_RotationX((In.texCoord + _Pos));
            UV = ((UV - _Point) * _ScaleEx) + _Point;

                /* Looping Mode! */
                if (_Looping_Mode == 0)     UV = frac(UV); // REPEAT
                else if(_Looping_Mode == 1) UV = 1.0 - abs(frac(UV / 2.0) * 2.0 - 1.0); // MIRRORED REPEAT
                else if(_Looping_Mode == 2) UV = clamp(UV, 0.0, 1.0); // CLAMP
                else                        UV *= 1.0 - any(UV < 0.0 || UV > 1.0); // BORDER

            float4 _Result = _Render_Texture;
            float4 _Render = _Texture.Sample(_TextureSampler, UV);

            float _Alpha = min(_Result.a, _Render.r * _Render.g * _Render.b);
            if(_Overlay)
                _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Alpha);
            else
                _Result.a = _Alpha;
                
        _Result = lerp(_Render_Texture, _Result, _Mixing);

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

