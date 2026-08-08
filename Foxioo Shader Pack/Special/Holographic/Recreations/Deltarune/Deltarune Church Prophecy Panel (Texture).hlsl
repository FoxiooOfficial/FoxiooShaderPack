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

Texture2D<float4> S2D_Texture : register(t1);
SamplerState S2D_TextureSampler : register(s1);


/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    float _OffsetX;
    float _OffsetY;
    bool ___;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ____;
    float _Mixing;
    //Texture2D _Texture;
    bool _Color;
    float4 _ColorLight;
    float4 _ColorShadow;
    bool _____;

};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
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

float Fun_Lum(float4 _Result) {
    return dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722)) * _Result.a;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);

        /* main panel */
        float2 UV = In.texCoord + float2(_PosX, _PosY);
        UV = (UV * float2(_ScaleX, _ScaleY) * _Scale) / 256.0;
        UV /= float2(fPixelWidth, fPixelHeight);
        UV = UV - floor(UV); // frac(UV)?

            float _Render_Texture_Lum = Fun_Lum(_Render_Texture);
            float4 _Texture_UV = S2D_Texture.Sample(S2D_TextureSampler, UV);

            float4 _Result = _Texture_UV;
            float _Result_Lum = Fun_Lum(_Result);

            _Result.a *= _Render_Texture_Lum;

            // sub panels
            float2 _UV_Echo = float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);
            
                float4 _Echo1 = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _UV_Echo) * In.Tint, _Premultiplied);
                    _Result.a += Fun_Lum(_Echo1) / 2.0;

                float4 _Echo2 = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _UV_Echo * 2.0) * In.Tint, _Premultiplied);
                    _Result.a += Fun_Lum(_Echo2) / 3.0;

        /* End */
            if(_Color)
                _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Result_Lum);

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
