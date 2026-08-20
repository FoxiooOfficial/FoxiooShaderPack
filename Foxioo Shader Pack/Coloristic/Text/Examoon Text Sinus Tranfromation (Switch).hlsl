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

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing; 
    float _PT;
    float _DPI; 
    float _Height;
    bool __;
    float _OffsetY;
    float _ScaleY;
    float4 _Light;
    float4 _Dark;
    bool ___;
    float _PosX;
    float _PosY;
    float4 _Shadow;
    float _Alpha;
    bool ____;
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

#define M_PI 3.14159265358979323846

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

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Result;

        _Result.a = _Render_Texture.a;

        float2 _Res = float2(fPixelWidth, fPixelHeight);
        float _FontSize = _DPI / 72.0 * _PT * _Res.y;

                _Result.rg = floor(In.texCoord.xy * _FontSize) / _FontSize;
                _Result.b = 0.0;

            //float2 _ShadowOffset = float2(_PosX, _PosY) * _Res;

            //    float4 _Render_Shadow = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord - _ShadowOffset) * In.Tint, _Premultiplied);
            //        _Render_Shadow.rgb = _Shadow.rgb;
            //       _Render_Shadow.a *= _Alpha;

            //_Result = lerp(_Render_Shadow, _Result, _Result.a);

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
