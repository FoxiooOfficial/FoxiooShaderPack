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
        bool _Blending_Mode;
        float _Mixing;
        float _X;
        float _Y;
        float _PosX;
        float _PosY;
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
        bool _Blending_Mode;
        float _Mixing;
        float _X;
        float _Y;
        float _PosX;
        float _PosY;
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

// fusion-fx-preview: allow-fxc-warnings
PS_INPUT vs_main(VS_INPUT In)
{
	PS_INPUT Out;

	float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
	float2 _DirCorner = sign(In.texCoord - 0.5);

        float2 _Pivot = float2(_PosX, _PosY);

        float2 _Min = abs(float2(0.0, 0.0) - _Pivot);
        float2 _Max = abs(float2(1.0, 1.0) - _Pivot);
        float _Rad = length(max(_Min, _Max));

        float2 _Dist = float2(-_Mixing, _Mixing) * float2(_X, _Y)  * 0.35;

        float2 _Expanded = (_Rad * 2.0) * abs(_Dist);
        float2 _PixelPadding = _Expanded;
        float4 _PosExpanded = float4(In.Position, 1.0);

            //if(!_Blending_Mode)
                _PosExpanded.xy += _DirCorner.xy * _Expanded / float2(fPixelWidth, fPixelHeight);
            //else
            //    _PosExpanded.xy += _DirCorner.zw * _Expanded / float2(fPixelWidth, fPixelHeight);

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner.xy * _PixelPadding;
    //Out.bgCoord = In.bgCoord + _DirCorner.zw * _PixelPadding;

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

float2 Fun_Squeeze(float2 In)
{
    float2 _Center = float2(_PosX, _PosY);
    float2 _Rel = In - _Center;
    float _Distance = length(_Rel);
    float _Theta = atan2(_Rel.y, _Rel.x);

        float2 _Dist = float2(-_Mixing, _Mixing) * float2(_X, _Y)  * 0.35;

        float2 _Squeeze = _Distance + (_Distance * _Dist * _Distance);
        float2 UV = float2(cos(_Theta), sin(_Theta)) * _Squeeze;

    return UV + _Center;
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
    //return float4(In.bgCoord.xy, 0.0, 1.0);

    float2 UV = Fun_Squeeze(In.texCoord);

        float4 _Result = Demultiply(Fun_Render(S2D_Image, S2D_ImageSampler, UV) * In.Tint, _Premultiplied);

        if(_Blending_Mode)
            _Result = Fun_Render(S2D_Background, S2D_BackgroundSampler, UV) * float4(1.0, 1.0, 1.0, _Result.a);

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