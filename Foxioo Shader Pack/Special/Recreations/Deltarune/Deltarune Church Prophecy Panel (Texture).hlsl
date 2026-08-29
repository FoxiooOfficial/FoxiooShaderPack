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
SamplerState _Texture_SamplerStare : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	//float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

#ifdef FUSION_PIXEL_SHADER

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
        bool _Color;
        float4 _ColorLight;
        float4 _ColorShadow;
        bool _____;
    };

    cbuffer PS_PIXELSIZE : register(b1)
    {
        float fPixelWidth;
        float fPixelHeight;
    };

#endif // FUSION_PIXEL_SHADER

/***********************************************************/

struct VS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
	//float2 bgCoord : TEXCOORD1;
    float3 Position : SV_POSITION;
};

#ifdef FUSION_VERTEX_SHADER

	cbuffer VS_MATRICES : register(b0)
	{
		row_major float4x4 transformMatrix;
		row_major float4x4 projectionMatrix;
	};

    cbuffer VS_VARIABLES : register(b1)
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
        bool _Color;
        float4 _ColorLight;
        float4 _ColorShadow;
        bool _____;
    };

    cbuffer VS_PIXELSIZE : register(b2)
    {
        float fPixelWidth;
        float fPixelHeight;
    };

#endif // FUSION_VERTEX_SHADER

/************************************************************/
/* Vertex Shader */
/************************************************************/

#ifdef FUSION_VERTEX_SHADER

PS_INPUT vs_main(VS_INPUT In)
{
	PS_INPUT Out;

	float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
	float2 _DirCorner = sign(In.texCoord - 0.5);

        float2 _Expanded = abs(float2(_OffsetX, _OffsetY) * 2.0);
        float2 _PixelPadding = _Expanded * float2(fPixelWidth, fPixelHeight);
        float4 _PosExpanded = float4(In.Position, 1.0);

            _PosExpanded.xy += _DirCorner * _Expanded;

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner * _PixelPadding;

	return Out;
}

#endif // FUSION_VERTEX_SHADER

/************************************************************/
/* Main */
/************************************************************/

#ifdef FUSION_PIXEL_SHADER
    
float Fun_PixelInside(float2 In) {
	return all(In >= 0.0 && In <= 1.0);
}

float4 Fun_PixelSample(Texture2D _Sampler, SamplerState _SamplerSampler, float2 In) {
	return _Sampler.Sample(_SamplerSampler, saturate(In)) * Fun_PixelInside(In);
}

float Fun_Lum(float4 _Result) {
    return dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722)) * _Result.a;
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

float4 Main(PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Fun_PixelSample(S2D_Image, S2D_ImageSampler, In.texCoord);

        /* main panel */
        float2 UV = In.texCoord + float2(_PosX, _PosY);
        UV = (UV * float2(_ScaleX, _ScaleY) * _Scale) / 256.0;
        UV /= float2(fPixelWidth, fPixelHeight);
        UV = UV - floor(UV); // frac(UV)?

            float _Render_Texture_Lum = Fun_Lum(_Render_Texture);
            float4 _Texture_UV = Fun_PixelSample(_Texture, _Texture_SamplerStare, UV);

            float4 _Result = _Texture_UV;
            float _Result_Lum = Fun_Lum(_Result);

            _Result.a *= _Render_Texture_Lum;

            // sub panels
            float2 _UV_Echo = float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);
            
                float4 _Echo1 = Fun_PixelSample(S2D_Image, S2D_ImageSampler, In.texCoord + _UV_Echo);
                    _Result.a += Fun_Lum(_Echo1) / 2.0;

                float4 _Echo2 = Fun_PixelSample(S2D_Image, S2D_ImageSampler, In.texCoord + _UV_Echo * 2.0);
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

float4 ps_main(PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}

#endif // FUSION_PIXEL_SHADER