/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (21.01.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;

    AddressU = BORDER;
    AddressV = BORDER;
    AddressW = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    MipFilter = LINEAR;
    MinFilter = LINEAR;
    MagFilter = LINEAR;

    AddressU = BORDER;
    AddressV = BORDER;
    AddressW = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _DotsTranparent,
            _DotsCoverage,
            _DotsSize,
            _DotsAntialiasing,
            _Time,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode,
            _DotsInvertedPattern,
            _DotsInvertedColors;

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, Fun_FishEye(In));
    float4 _Render_Background = tex2D(S2D_Background, Fun_FishEye(In));

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result * 0.5;

            float3 _CRT = float3(Fun_PatternDot(In, _DotsSize, _Render.r, 0.0), Fun_PatternDot(In, _DotsSize, _Render.g, 1.0), Fun_PatternDot(In, _DotsSize, _Render.b, 2.0));

            float2 _L = (_CRT.rg * _CRT.b * 0.01 + sin(In.y * 3. + _Time - _CRT.rg * _CRT.b ) * 0.001);
            float2 UV = In - _L * 0.2;
            _CRT += float3(Fun_PatternDot(UV + 0.2, _DotsSize, _Render.r, 0.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.g, 1.2), Fun_PatternDot(UV + 0.2, _DotsSize, _Render.b, 2.2));
            _CRT += float3(Fun_PatternDot(UV + 0.4, _DotsSize, _Render.r, 0.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.g, 1.4), Fun_PatternDot(UV + 0.4, _DotsSize, _Render.b, 2.4));
            _CRT += float3(Fun_PatternDot(UV + 0.6, _DotsSize, _Render.r, 0.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.g, 1.6), Fun_PatternDot(UV + 0.6, _DotsSize, _Render.b, 2.6));
            //_CRT += float3(Fun_PatternDot(In + 0.8, _DotsSize, _Render.r, 0.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.g, 1.8), Fun_PatternDot(In + 0.8, _DotsSize, _Render.b, 2.8));

            _Render.rgb *= 2.0;
        _Result.rgb = ((_CRT + _CRT * 1.2 * _Render.rgb + _Render.rgb) * (cos(_L.x + _L.y) * 0.1 + 0.5));

        _Result.rgb = lerp(_Render.rgb, abs(_DotsInvertedColors - _Result.rgb), _Mixing);

        _Result.a = _Render_Texture.a;
        
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
