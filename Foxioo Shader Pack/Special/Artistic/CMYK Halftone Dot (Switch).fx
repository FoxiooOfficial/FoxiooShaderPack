/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _DotsTranparent,
            _DotsCoverage,
            _DotsSize,
            _DotsAntialiasing,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode,
            _DotsInvertedPattern,
            _DotsInvertedColors;

/************************************************************/
/* Main */
/************************************************************/

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

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result;

        float _K = 1.0 - max(_Result.r, max(_Result.g, _Result.b));     float _InvK = 1.0 - _K;
        float _C = _InvK > 0.001 ? (1.0 - _Result.r - _K) / _InvK : 0.0;
        float _M = _InvK > 0.001 ? (1.0 - _Result.g - _K) / _InvK : 0.0;
        float _Y = _InvK > 0.001 ? (1.0 - _Result.b - _K) / _InvK : 0.0;

            float _YellowDot    = Fun_PatternDot(Fun_RotationX(In,  0.0), _DotsSize, _Y);
            float _CyanDot      = Fun_PatternDot(Fun_RotationX(In, 15.0), _DotsSize, _C);
            float _MagentaDot   = Fun_PatternDot(Fun_RotationX(In, 75.0), _DotsSize, _M);
            float _BlackDot     = Fun_PatternDot(Fun_RotationX(In, 45.0), _DotsSize, _K);

                    float3 _YellowRender    = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 1.0, 0.0), _YellowDot);
                    float3 _CyanRender      = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 1.0, 1.0), _CyanDot);
                    float3 _MagentaRender   = lerp(float3(1.0, 1.0, 1.0), float3(1.0, 0.0, 1.0), _MagentaDot);
                    float3 _BlackRender     = lerp(float3(1.0, 1.0, 1.0), float3(0.0, 0.0, 0.0), _BlackDot);

        _Result.rgb = _YellowRender * _CyanRender * _MagentaRender * _BlackRender;
        _Result.rgb = lerp(_Render.rgb, abs(_DotsInvertedColors - _Result.rgb), _Mixing);

        _Result.a = _Render_Texture.a;
        
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
