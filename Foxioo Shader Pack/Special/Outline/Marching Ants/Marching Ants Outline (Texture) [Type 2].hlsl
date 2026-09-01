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

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Size;
    float _Offset;
    float4 _Light;
    float4 _Shadow;
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

#define KERNEL 1

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Result;
        float _Alpha = 0.0, _Weight = 0.0;

            float2 _Pixel = float2(fPixelWidth, fPixelHeight);

                for(int y = -KERNEL; y <= KERNEL; y++)
                {
                    for(int x = -KERNEL; x <= KERNEL; x++)
                    {
                        float2 _Off = float2(x, y) * _Pixel * _Offset;
                        _Alpha += S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Off).a * In.Tint.a;
                        _Weight++;
                    }
                }

            _Alpha /= _Weight;
            
        float _Outline = ceil(_Alpha - ceil(_Render_Texture.a) - 1.0 / 255.0);

        float2 UV = (float2)(int2)ceil(In.texCoord / _Pixel / _Size);
        float _Pattern = fmod(UV.x + UV.y, 2.0);

        UV *= 1.0 / _Pixel / 32.0;
        UV /= _Size;

            _Pattern = round(_Pattern);

                _Result = float4((float3)lerp(_Shadow.rgb, _Light.rgb, _Pattern), _Outline);
                _Result = lerp(float4((float3)_Render_Texture.rgb, ceil(_Render_Texture.a)), _Result, _Result.a); // it's overcomplicated...

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
