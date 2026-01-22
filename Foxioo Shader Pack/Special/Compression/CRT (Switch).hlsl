/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (21.01.2026) */
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
    float _Time;
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

float2 Fun_FishEye(float2 In)
{
    float2 _Points = float2(0.5, 0.5);
    float2 _In = In - _Points;

    float _Ray = length(_In);
    float _Theta = atan2(_In.y, _In.x);

        float _ClampedAngle = clamp(_Ray, 0.0, 1.47);
        float _Mode_Rectilinear = tan(_ClampedAngle) * (0.9);

        float2 _UV = float2(cos(_Theta), sin(_Theta)) * _Mode_Rectilinear;

        float2 _Result = lerp(In, _UV + _Points, _Mixing);
        return _Result;
}

float Fun_PatternDot(float2 UV, float _Size, float _Lum, float _Offset)
{
    float2 _UV_Res = UV / float2(fPixelWidth, fPixelHeight);
    float2 _Grid = _UV_Res / _Size;

    float _Row = floor(_Grid.y);
    if (fmod(_Row, 2.0) == 1.0) {   _Grid.x += 0.66;  }

    float _PatternMask = (fmod(abs(floor(_Grid.x + _Row + _Offset)), 3.0) < 0.1) ? 1.0 : 0.0;

    float2 _Cell = frac(_Grid);
    float _Dist = abs(_DotsInvertedPattern - length(_Cell - 0.5)) * _DotsCoverage;

    float _Render = _Lum;
    float _Result = smoothstep(_Render - _DotsAntialiasing, _Render + _DotsAntialiasing, _Dist);

    return (1.0 - _Result * _DotsTranparent) * _PatternMask;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, Fun_FishEye(In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, Fun_FishEye(In.texCoord)) * In.Tint;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result * 0.5;

        float3 _CRT = float3(Fun_PatternDot(In.texCoord, _DotsSize, _Render.r, 0.0), Fun_PatternDot(In.texCoord, _DotsSize, _Render.g, 1.0), Fun_PatternDot(In.texCoord, _DotsSize, _Render.b, 2.0));

                    float2 _L = (_CRT.rg * _CRT.b * 0.01 + sin(In.texCoord.y * 3. + _Time - _CRT.rg * _CRT.b ) * 0.001);
                    float2 UV = In.texCoord - _L * 0.2;
                    _CRT += float3(Fun_PatternDot(UV + 0.2, _DotsSize, _Render.r, 0.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.g, 1.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.b, 2.2));
                    _CRT += float3(Fun_PatternDot(UV + 0.4, _DotsSize, _Render.r, 0.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.g, 1.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.b, 2.4));
                    _CRT += float3(Fun_PatternDot(UV + 0.6, _DotsSize, _Render.r, 0.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.g, 1.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.b, 2.6));
                    //_CRT += float3(Fun_PatternDot(In + 0.8, _DotsSize, _Render.r, 0.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.g, 1.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.b, 2.8));

                    _Render.rgb *= 2.0;

            _Result.rgb = ((_CRT + _CRT * 1.2 * _Render.rgb + _Render.rgb) * (cos(_L.x + _L.y) * 0.1 + 0.5));

        _Result.rgb = lerp(_Render.rgb, abs(_DotsInvertedColors - _Result.rgb), _Mixing);

            float2 _UV = Fun_FishEye(In.texCoord);
            float _Alpha = float(_UV.x > 0.0 && _UV.y > 0.0 && _UV.x < 1.0 && _UV.y < 1.0);
            _Result.a = _Render_Texture.a * _Alpha;

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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, Fun_FishEye(In.texCoord))) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, Fun_FishEye(In.texCoord)) * In.Tint;

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result * 0.5;

        float3 _CRT = float3(Fun_PatternDot(In.texCoord, _DotsSize, _Render.r, 0.0), Fun_PatternDot(In.texCoord, _DotsSize, _Render.g, 1.0), Fun_PatternDot(In.texCoord, _DotsSize, _Render.b, 2.0));

                    float2 _L = (_CRT.rg * _CRT.b * 0.01 + sin(In.texCoord.y * 3. + _Time - _CRT.rg * _CRT.b ) * 0.001);
                    float2 UV = In.texCoord - _L * 0.2;
                    _CRT += float3(Fun_PatternDot(UV + 0.2, _DotsSize, _Render.r, 0.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.g, 1.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.b, 2.2));
                    _CRT += float3(Fun_PatternDot(UV + 0.4, _DotsSize, _Render.r, 0.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.g, 1.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.b, 2.4));
                    _CRT += float3(Fun_PatternDot(UV + 0.6, _DotsSize, _Render.r, 0.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.g, 1.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.b, 2.6));
                    //_CRT += float3(Fun_PatternDot(In + 0.8, _DotsSize, _Render.r, 0.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.g, 1.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.b, 2.8));

                    _Render.rgb *= 2.0;

            _Result.rgb = ((_CRT + _CRT * 1.2 * _Render.rgb + _Render.rgb) * (cos(_L.x + _L.y) * 0.1 + 0.5));

        _Result.rgb = lerp(_Render.rgb, abs(_DotsInvertedColors - _Result.rgb), _Mixing);

            float2 _UV = Fun_FishEye(In.texCoord);
            float _Alpha = float(_UV.x > 0.0 && _UV.y > 0.0 && _UV.x < 1.0 && _UV.y < 1.0);
            _Result.a = _Render_Texture.a * _Alpha;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
