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

static const int _Samples = 16;

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
        float _PosX;
        float _PosY;
        float _Size;
        float4 _Color;
        float4 _ColorAccent;
        float _ColorAlpha;
        float _AlphaMul;
        float _AlphaBack;
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
        float _PosX;
        float _PosY;
        float _Size;
        float4 _Color;
        float4 _ColorAccent;
        float _ColorAlpha;
        float _AlphaMul;
        float _AlphaBack;
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

        float _Expanded = abs(max(_PosX + 1.0, _PosY + 1.0) * _Size);
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

float4 Main(PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(Fun_Render(S2D_Image, S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);

    float _Alpha = 0.0;
    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            _Alpha += Fun_Render(S2D_Image, S2D_ImageSampler, In.texCoord + _Offset).a;
        }
    }
    
    _Alpha /= float(_Samples * _Samples);

    float _Outer = saturate(_Alpha * _AlphaMul) * (1.0 - _Render_Texture.a);
    //float _Inner = saturate((1.0 - _Alpha) * _AlphaMul) * _Render_Texture.a;

        float _Strength = saturate(_Outer);
        float _Mask = saturate((1.0 - _Render_Texture.a) + _AlphaBack);

        float4 _Render_Color = lerp(_ColorAccent, _Color, _Strength);
        _Render_Color.a = _Strength * _Mask * _ColorAlpha * _Mixing;

            float4 _Render = _Render_Texture;
            _Render.a *= _AlphaBack;

            float4 _Result;

        _Result.a = _Render_Color.a + _Render.a * (1.0 - _Render_Color.a);
        _Result.rgb = lerp(_Render.rgb, _Render_Color.rgb, _Render_Color.a / _Result.a);
        
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