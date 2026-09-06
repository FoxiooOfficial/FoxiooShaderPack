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
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

#ifdef FUSION_PIXEL_SHADER

    cbuffer PS_VARIABLES : register(b0)
    {
        bool _;
        bool __;
        float _PosX;
        float _PosY;    
        bool ___;
        float _Scale;
        float _ScaleX;
        float _ScaleY;
        bool ____;
        float _Mixing;
        float _Alpha;
        float _Offset;
        float _OffsetDistortion;
        float _Seed;
        float4 _ColorLight; 
        float4 _Color; 
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
	float2 bgCoord : TEXCOORD1;
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
        bool ___;
        float _Scale;
        float _ScaleX;
        float _ScaleY;
        bool ____;
        float _Mixing;
        float _Alpha;
        float _Offset;
        float _OffsetDistortion;
        float _Seed;
        float4 _ColorLight; 
        float4 _Color; 
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

// fusion-fx-preview: allow-fxc-warnings
PS_INPUT vs_main(VS_INPUT In)
{
	PS_INPUT Out;

	float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
	float2 _DirCorner = sign(In.texCoord - 0.5);

        float _Expanded = abs(_Offset + _OffsetDistortion);
        float2 _PixelPadding = _Expanded * float2(fPixelWidth, fPixelHeight);
        float4 _PosExpanded = float4(In.Position, 1.0);

            _PosExpanded.xy += _DirCorner * _Expanded;

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner * _PixelPadding;
    Out.bgCoord = In.bgCoord;

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

static const float2 _OffsetEx[8] = 
{
    float2(-1.0,  0.0),
    float2( 1.0,  0.0),
    float2( 0.0, -1.0),
    float2( 0.0,  1.0),

    float2(-1.0, -1.0),
    float2(-1.0,  1.0),
    float2( 1.0, -1.0),
    float2( 1.0,  1.0) 
};

float Fun_Hash21(float2 _Pos) { 
    return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453);
}

float Fun_Noise(float2 _Pos)
{
    float2 _I = floor(_Pos + _Seed);
    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float3 Fun_NoiseGradient(float2 _UV, float3 _Color_1, float3 _Color_2, float3 _Color_3)
{
    float _Noise = Fun_Noise(_UV * 4.0);

    float3 _Render_1  = lerp(_Color_1, _Color_2, smoothstep(0.0, 0.5, _Noise));
    float3 _Render_2 = lerp(_Render_1, _Color_3, smoothstep(0.5, 1.0, _Noise));

    return _Render_2;
}

float3 Fun_NoiseSat(float3 _Color, float _Sat)
{
    float _Lum = dot(_Color, float3(0.299, 0.587, 0.114));

    return lerp(float3(_Lum, _Lum, _Lum), _Color, _Sat);
}

float4 Main(PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(Fun_Render(S2D_Image, S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = Fun_Render(S2D_Background, S2D_BackgroundSampler, In.bgCoord);

        float2 _UV = (In.texCoord + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = _Color;

            _Result.rgb = Fun_NoiseGradient(_UV, _Color.rgb, _ColorShadow.rgb, _ColorLight.rgb);

                float _Noise = Fun_Noise(_UV * 8.0);
                float _Sat = lerp(0.5, 2.5, _Noise);

                _Result.rgb = Fun_NoiseSat(_Result.rgb, _Sat);

                    float _Mask = _Render_Texture.a;

                    for (int i = 0; i < 8; i++)
                    {
                        _Mask += Fun_Render(S2D_Image, S2D_ImageSampler, In.texCoord + _OffsetEx[i] * float2(fPixelWidth, fPixelHeight) * (_Offset + sin(In.texCoord + _Noise) * _OffsetDistortion)).a * In.Tint.a;
                        _Mask = saturate(_Mask);
                    }
                
                    _Result.a = _Mask;

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, _Mixing);
        float4 _Render = lerp(_Result, _Render_Texture, _Render_Texture.a * _Alpha);

	return _Render;
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