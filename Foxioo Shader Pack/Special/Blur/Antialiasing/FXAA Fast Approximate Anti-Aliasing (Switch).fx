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

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _Threshold,
            _Relative,
            //_SubPixelBlending,
            _Off,

            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_ShouldProcess(float _Range, float _MaxLum)
{
    float _ActualThreshold = max(_Threshold, _Relative * _MaxLum);
    return _Range >= _ActualThreshold; 
}

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return sqrt(_Y) * _Result.a;
}

float4 Fun_AA(sampler2D _Sampler, float2 In, float4 _Render, float _Alpha)
{
    float2 _Size = float2(fPixelWidth, fPixelHeight);

    /* kinda emboss

        based on FXAA
        this helps: https://catlikecoding.com/unity/tutorials/custom-srp/fxaa/ :3
    */
    float4 _N = tex2D(_Sampler, In + float2( 0.0,   _Off) * _Size);
    float4 _E = tex2D(_Sampler, In + float2( _Off,   0.0) * _Size);
    float4 _S = tex2D(_Sampler, In + float2( 0.0,  -_Off) * _Size);
    float4 _W = tex2D(_Sampler, In + float2(-_Off,   0.0) * _Size);

    float4 _NW = tex2D(_Sampler, In + float2(-_Off,  _Off) * _Size);
    float4 _NE = tex2D(_Sampler, In + float2( _Off,  _Off) * _Size);
    float4 _SW = tex2D(_Sampler, In + float2(-_Off, -_Off) * _Size);
    float4 _SE = tex2D(_Sampler, In + float2( _Off, -_Off) * _Size);

        /* give me luminance!!! */
        float _LumN = Fun_Luminance(_N);
        float _LumE = Fun_Luminance(_E);
        float _LumS = Fun_Luminance(_S);
        float _LumW = Fun_Luminance(_W);

        float _LumNW = Fun_Luminance(_NW);
        float _LumNE = Fun_Luminance(_NE);
        float _LumSW = Fun_Luminance(_SW);
        float _LumSE = Fun_Luminance(_SE);

        float _LumM = Fun_Luminance(_Render);

        /* high and low */
        float   _High = max(max(max(max(_LumM, _LumN), _LumE), _LumS), _LumW);
                _High = max(_High, max(max(_LumNW, _LumNE), max(_LumSW, _LumSE)));

        float   _Low = min(min(min(min(_LumM, _LumN), _LumE), _LumS), _LumW);
                _Low = min(_Low, min(min(_LumNW, _LumNE), min(_LumSW, _LumSE)));

            float _Range = _High - _Low;
            float _Mul = Fun_ShouldProcess(_Range, _High);
            
            float _Horizontal = 
                    abs(_LumN + _LumS - 2.0 * _LumM) * 2.0 +
                    abs(_LumNW + _LumSW - 2.0 * _LumW) +
                    abs(_LumNE + _LumSE - 2.0 * _LumE);
        
            float _Vertical = 
                abs(_LumE + _LumW - 2.0 * _LumM) * 2.0 +
                abs(_LumNE + _LumNW - 2.0 * _LumN) +
                abs(_LumSE + _LumSW - 2.0 * _LumS);

            bool _IsHorizontal = _Horizontal >= _Vertical;

                float _L1 = _IsHorizontal ? _LumN : _LumE;
                float _L2 = _IsHorizontal ? _LumS : _LumW;
                
                float _G1 = abs(_L1 - _LumM);
                float _G2 = abs(_L2 - _LumM);
                
                float _PixelOffset = _IsHorizontal ? _Size.y : _Size.x;
                if (_G2 > _G1) _PixelOffset = -_PixelOffset;

                float2 _UV_Final = In;
                if (_IsHorizontal) _UV_Final.y += _PixelOffset;
                else               _UV_Final.x += _PixelOffset;

                float   _SubPixel = 2.0 * (_LumN + _LumE + _LumS + _LumW);
                        _SubPixel += (_LumNW + _LumNE + _LumSW + _LumSE);
                        _SubPixel *= (1.0 / 12.0);
                        _SubPixel = abs(_SubPixel - _LumM);
                        _SubPixel = saturate(_SubPixel / _Range);

                float _Factor = smoothstep(0, 1, _SubPixel);
                _Factor *= _Factor * _Mul;

                float4 _EdgeColor = tex2D(_Sampler, _UV_Final) * 0.75 + (_S + _W + _N + _E) / 4.0 * 0.25;

    return lerp(_Render, _EdgeColor, saturate(_Factor * _Mixing)) * _Alpha;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

    float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, In.bgCoord, _Render_Background, _Render_Texture.a) : Fun_AA(S2D_Image, In.texCoord, _Render_Texture, 1.0);
    return _Render;
}
/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
