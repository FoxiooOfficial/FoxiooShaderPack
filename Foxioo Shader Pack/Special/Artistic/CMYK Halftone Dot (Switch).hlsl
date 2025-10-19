/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

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
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _DotsAntialiasing;
    float _DotsTranparent;
    float _DotsSize;
    float _DotsCoverage;
    bool _DotsInvertedPattern;
    bool _DotsInvertedColors;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_Target;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float Fun_Quantize(float _Value, float _Steps)
{
    if (_Steps <= 0.0)  
        return step(0.5, _Value);
    else                
        return floor(_Value * _Steps + 0.5) / _Steps;
}

float3 Fun_Quantize_3(float3 _Value, float _Steps)
{
    return float3(
        Fun_Quantize(_Value.r, _Steps),
        Fun_Quantize(_Value.g, _Steps),
        Fun_Quantize(_Value.b, _Steps)
    );
}

float Fun_PatternDot(float2 UV, float _Size, float _Lum)
{
    float2 _UV_Res = UV / float2(fPixelWidth, fPixelHeight);
    float2 _Grid = _UV_Res / _Size;

    float _Row = floor(_Grid.y);
    if (fmod(_Row, 2.0) == 1.0) {   _Grid.x += 0.5;  }

    float2 _Cell = frac(_Grid);
    float _Dist = abs(_DotsInvertedPattern - length(_Cell - 0.5)) * _DotsCoverage;

    float _Render = _Lum;
    float _Result = smoothstep(_Render - _DotsAntialiasing, _Render + _DotsAntialiasing, _Dist);

    return 1.0 - _Result * _DotsTranparent;
}

float2 Fun_RotationX(float2 In, float _RotX)
{
    float2 _Points = float2(0.5, 0.5);
    float _RotX_Fix = _RotX * (3.14159265 / 180.);

        In = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), In - _Points);

    return In;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result;

        float _K = 1.0 - max(_Result.r, max(_Result.g, _Result.b));     float _InvK = 1.0 - _K;
        float _C = _InvK > 0.001 ? (1.0 - _Result.r - _K) / _InvK : 0.0;
        float _M = _InvK > 0.001 ? (1.0 - _Result.g - _K) / _InvK : 0.0;
        float _Y = _InvK > 0.001 ? (1.0 - _Result.b - _K) / _InvK : 0.0;

            float _YellowDot    = Fun_PatternDot(Fun_RotationX(In.texCoord,  0.0), _DotsSize, _Y);
            float _CyanDot      = Fun_PatternDot(Fun_RotationX(In.texCoord, 15.0), _DotsSize, _C);
            float _MagentaDot   = Fun_PatternDot(Fun_RotationX(In.texCoord, 75.0), _DotsSize, _M);
            float _BlackDot     = Fun_PatternDot(Fun_RotationX(In.texCoord, 45.0), _DotsSize, _K);

                    float3 _YellowRender    = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 1.0, 0.0), _YellowDot);
                    float3 _CyanRender      = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 1.0, 1.0), _CyanDot);
                    float3 _MagentaRender   = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 0.0, 1.0), _MagentaDot);
                    float3 _BlackRender     = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0), _BlackDot);

        _Result.rgb = _YellowRender * _CyanRender * _MagentaRender * _BlackRender;
        _Result.rgb = lerp(_Render.rgb, abs(float(_DotsInvertedColors) - _Result.rgb), _Mixing);

        _Result.a = _Render_Texture.a;

    Out.Color = _Result;

    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
        PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result;

        float _K = 1.0 - max(_Result.r, max(_Result.g, _Result.b));     float _InvK = 1.0 - _K;
        float _C = _InvK > 0.001 ? (1.0 - _Result.r - _K) / _InvK : 0.0;
        float _M = _InvK > 0.001 ? (1.0 - _Result.g - _K) / _InvK : 0.0;
        float _Y = _InvK > 0.001 ? (1.0 - _Result.b - _K) / _InvK : 0.0;

            float _YellowDot    = Fun_PatternDot(Fun_RotationX(In.texCoord,  0.0), _DotsSize, _Y);
            float _CyanDot      = Fun_PatternDot(Fun_RotationX(In.texCoord, 15.0), _DotsSize, _C);
            float _MagentaDot   = Fun_PatternDot(Fun_RotationX(In.texCoord, 75.0), _DotsSize, _M);
            float _BlackDot     = Fun_PatternDot(Fun_RotationX(In.texCoord, 45.0), _DotsSize, _K);

                    float3 _YellowRender    = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 1.0, 0.0), _YellowDot);
                    float3 _CyanRender      = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 1.0, 1.0), _CyanDot);
                    float3 _MagentaRender   = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 0.0, 1.0), _MagentaDot);
                    float3 _BlackRender     = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0), _BlackDot);

        _Result.rgb = _YellowRender * _CyanRender * _MagentaRender * _BlackRender;
        _Result.rgb = lerp(_Render.rgb, abs(float(_DotsInvertedColors) - _Result.rgb), _Mixing);

        _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
