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
            _ColorSteps,
            _LumMult,
            _DotsLumSteps,
            _MixingManga,
            _DotsTranparent,
            _DotsCoverage,
            _DotsSize,
            _DotsAntialiasing,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode,
            _DotsInvertedPattern,
            _DotsInvertedColors;

    float4  _ColorLight,
            _ColorShadow;

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Quantize(float3 _Result, float _Steps)
{
    float _Render;

    if (_Steps <= 0.0)  _Render = step(0.5, _Result);
    else                _Render = floor(_Result * _Steps + 0.5) / _Steps;

    return _Render;
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


float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
    float4 _Render = _Result;

        float _Lum = (_Result.r * 0.299 + _Result.g * 0.587 + _Result.b * 0.114) * _LumMult;

            _Result.rgb = Fun_PatternDot(In, _DotsSize, Fun_Quantize(_Lum, _DotsLumSteps).r);
            _Result.rgb = lerp(_Result.rgb, _Result.rgb * Fun_Quantize(_Render.rgb * _LumMult, _ColorSteps), _MixingManga);
            _Result.rgb = abs(_DotsInvertedColors - _Result.rgb);

        _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, (_Result.r * 0.299 + _Result.g * 0.587 + _Result.b * 0.114));
        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

        _Result.a = _Render_Texture.a;
        
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
