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

//Texture2D<float4> _Texture : register(t1);
//SamplerState _Texture_SamplerStare : register(s1);

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
        float _PosX;
        float _PosY;
        float _OffsetX;
        float _OffsetY;
        float _Footer;
        float4 _ColorLight;
        float4 _ColorShadow;
        float _Alpha;
        float _Max;
        float _Mul;
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
        float _OffsetX;
        float _OffsetY;
        float _Footer;
        float4 _ColorLight;
        float4 _ColorShadow;
        float _Alpha;
        float _Max;
        float _Mul;
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

        float2 _Expanded = float(_Alpha > 0.0f) * abs(float2(_OffsetX, _OffsetY)) + abs(float2(_PosX, _PosY)) + float2(64.0, 64.0);
        float2 _PixelPadding = _Expanded * _PixelSize;
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
    float4 _Render_Texture = Demultiply(Fun_PixelSample(S2D_Image, S2D_ImageSampler, In.texCoord), _Premultiplied)  * In.Tint;
    float2 _PixelSize = float2(fPixelWidth, fPixelHeight);

    // shadow
    float2 _LightPos = -(float2(_PosX, _PosY)) * _PixelSize;
    float _Anchor = 1.0 - _Footer * _PixelSize.y;

    float2 UV = In.texCoord + float2(_OffsetX, _OffsetY) * _PixelSize;
        UV.y = _Anchor + (_Anchor - UV.y) / _LightPos.y;
        UV.x += (UV.y - _Anchor) * _LightPos.x;

    float4 _Render_Shadow = Demultiply(Fun_PixelSample(S2D_Image, S2D_ImageSampler, UV), _Premultiplied);
    _Render_Shadow.rgb = _ColorShadow.rgb * _ColorShadow.rgb;
    _Render_Shadow.a *= _Alpha * In.Tint.a;
    
    if(_LightPos.y == 0.0f)
        _Render_Shadow.a = 0.0f;

    // rim light
    float4 _Result = _Render_Texture;

    float2 UVRim = _LightPos;
    //const float _Max = 2.0f;
        UVRim.x = clamp(UVRim.x, -_Max * _PixelSize.x, _Max * _PixelSize.x);
        UVRim.y = clamp(UVRim.y, -_Max * _PixelSize.y, _Max * _PixelSize.y);

    UVRim *= _Mul;

    float _Render_Rim = _Render_Texture.a - (Fun_PixelSample(S2D_Image, S2D_ImageSampler, In.texCoord - UVRim * sign(_LightPos.y)).a * _LightPos.y) * In.Tint.a;
        _Result.rgb = lerp( _Render_Texture.rgb * _ColorShadow.rgb, 
                            _Render_Texture.rgb + _ColorLight.rgb,
                            clamp(_Render_Rim, 0.0f, 1.5f));

    // result
        _Result = lerp(_Render_Shadow, _Result, _Render_Texture.a);
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