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
    float _Luminance;
    float _A;
    float _B;
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

/************************************************************/
/* Main */
/************************************************************/

/*  Based on:
    https://gist.github.com/manojpandey/f5ece715132c572c80421febebaf66ae#file-rgb2lab-py-L29]
    https://github.com/antimatter15/rgb-lab/blob/master/color.js
*/

float Fun_NormalizeRGB_In(float _Render)
{
    float _Base;

        if(_Render > 0.04045)
            _Base = pow((abs(_Render) + 0.055) / 1.055, 2.4);
        else
            _Base = _Render / 12.92;
        
    return _Base;
}

float Fun_NormalizeRGB_Out(float _Render)
{
    float _Base;

        if(_Render > 0.0031308)
            _Base = 1.055 * pow(abs(_Render), 1.0 / 2.4) - 0.055;
        else
            _Base = _Render * 12.92;
        
    return _Base;
}

float Fun_NormalizeXYZ_In(float _Render)
{
    float _Base;

        if(_Render > 0.008856)
            _Base = pow(abs(_Render), 1.0 / 3.0);
        else
            _Base = (7.787 * _Render) + (16.0 / 116.0);
    
    return _Base;
}

float Fun_NormalizeXYZ_Out(float _Render)
{
    float _Base;
    float _Cubic = _Render * _Render * _Render;

        if(_Cubic > 0.008856)
            _Base = _Cubic;
        else
            _Base = (_Render - 16.0 / 116.0) / 7.787;

    return _Base;
}

float3 RGBtoLab(float3 _Render)
{
    _Render.r = Fun_NormalizeRGB_In(_Render.r);
    _Render.g = Fun_NormalizeRGB_In(_Render.g);
    _Render.b = Fun_NormalizeRGB_In(_Render.b);

        float3 XYZ;
        XYZ.x = Fun_NormalizeXYZ_In((_Render.r * 0.4124 + _Render.g * 0.3576 + _Render.b * 0.1805) / 0.95047);
        XYZ.y = Fun_NormalizeXYZ_In((_Render.r * 0.2126 + _Render.g * 0.7152 + _Render.b * 0.0722) / 1.00000);
        XYZ.z = Fun_NormalizeXYZ_In((_Render.r * 0.0193 + _Render.g * 0.1192 + _Render.b * 0.9505) / 1.08883);

    float3 _Lab;
    _Lab.x = (116.0 * XYZ.y) - 16.0;
    _Lab.y = 500.0 * (XYZ.x - XYZ.y);
    _Lab.z = 200.0 * (XYZ.y - XYZ.z); 

    return  _Lab;
}

float3 LabtoRGB(float3 _LAB)
{
    float Y = (_LAB.x + 16.0) / 116.0;
    float X = _LAB.y / 500.0 + Y;
    float Z = Y - _LAB.z / 200.0;
        
        X = Fun_NormalizeXYZ_Out(X) * 0.95047;
        Y = Fun_NormalizeXYZ_Out(Y);
        Z = Fun_NormalizeXYZ_Out(Z) * 1.08883;

        float3 _Render;
        _Render.r = Fun_NormalizeRGB_Out(X * 3.2406 + Y * -1.5372 + Z * -0.4986);
        _Render.g = Fun_NormalizeRGB_Out(X * -0.9689 + Y * 1.8758 + Z * 0.0415);
        _Render.b = Fun_NormalizeRGB_Out(X * 0.0557 + Y * -0.2040 + Z * 1.0570);

    return _Render;
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

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Render;

            float3 Lab = RGBtoLab(_Render.rgb);
            
                    Lab.x = (Lab.x + (_Luminance - 50.0) * 2.0);
                    Lab.y += (_A - 50.0) * 2.0;
                    Lab.z += (_B - 50.0) * 2.0;

                _Result.rgb = LabtoRGB(Lab);

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

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
