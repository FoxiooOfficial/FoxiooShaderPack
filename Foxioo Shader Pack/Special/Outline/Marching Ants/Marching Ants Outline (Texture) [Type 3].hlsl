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
    float _Mixing;
    float _Time;
    float _Size;
    float _Offset;
    float4 _Light;
    float4 _Shadow;
    bool __;
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
        float _Mixing;
        float _Time;
        float _Size;
        float _Offset;
        float4 _Light;
        float4 _Shadow;
        bool __;
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

        float _Expanded = _Offset;
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

float4 Fun_Render(Texture2D _Tex, SamplerState _TexSampler, float2 In) {
    if(any(In <= 0.0 || In >= 1.0))
        return 0.0;
    else
        return _Tex.Sample(_TexSampler, In);
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
    float4 _Render_Texture = Demultiply(Fun_Render(S2D_Image, S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Result;
        float2 _Pixel = float2(fPixelWidth, fPixelHeight);

        float _Outline = saturate(any(In.texCoord < 0.0 || In.texCoord > 1.0));

        float2 UV = (float2)(int2)ceil(In.texCoord / _Pixel / _Size);
        UV *= 1.0 / _Pixel / 32.0;
        UV /= _Size;

            float _Pattern = sin((UV.x + UV.y) + _Time);
            _Pattern = round(_Pattern);

                _Result = float4((float3)lerp(_Shadow.rgb, _Light.rgb, _Pattern), _Outline);
                _Result = lerp(_Render_Texture, _Result, _Result.a);

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

#endif // FUSION_PIXEL_SHADER