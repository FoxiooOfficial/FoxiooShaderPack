/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (25.03.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

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

    float   _Mixing,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

const float _Off = 1.0;

float Fun_Luminance(float4 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y * _Result.a;
}

float4 Fun_AA(sampler2D _Sampler, float2 In, float4 _Render, float _Alpha)
{
    float2 _Size = float2(fPixelWidth, fPixelHeight);

    /* kinda emboss
        NE -> 45*    (+X, +Y);
        SE -> 135*   (-X, +Y);
        SW -> 225*   (+X, -Y);
        NW -> 315*   (-X, -Y);

        based on FXAA
        this helps: https://catlikecoding.com/unity/tutorials/custom-srp/fxaa/ :3
    */
    float4 _NW = tex2D(_Sampler, In + float2(-_Off, -_Off) * _Size);
    float4 _NE = tex2D(_Sampler, In + float2( _Off, -_Off) * _Size);
    float4 _SW = tex2D(_Sampler, In + float2(-_Off,  _Off) * _Size);
    float4 _SE = tex2D(_Sampler, In + float2( _Off,  _Off) * _Size);

        /* give me luminance!!! */
        float _LumNW = Fun_Luminance(_NW);
        float _LumNE = Fun_Luminance(_NE);
        float _LumSW = Fun_Luminance(_SW);
        float _LumSE = Fun_Luminance(_SE);
        float _LumM  = Fun_Luminance(_Render);

        /* offset 
            dir -> difference between the x and y offsets
        */
        float2 _Dir = float2(  -((_LumNW + _LumNE) - (_LumSW + _LumSE)),
                                ((_LumNW + _LumSW) - (_LumNE + _LumSE))
                            );

        float _DirNorm = max((_LumNW + _LumNE + _LumSW + _LumSE) / 32.0, 1.0 / 128);
        float _DirInv = 1.0 / (min(abs(_Dir.x), abs(_Dir.y)) + _DirNorm);
    
            _Dir = clamp(_Dir * _DirInv, float2(-8.0, -8.0), float2(8.0, 8.0)) * _Size;

        float4 _Result = _Render * 0.5;
        float4 _ClearType = 0.0;
        float4 _SampleSum = 0.0;
    
        /* super cleantype colors! */
        const float4 _M  = float4(1.0, 0.31, 0.08, 1.0);    /* left -> orange */
        const float4 _P  = float4(0.16, 0.58, 1.0, 1.0);    /* right -> blue */

            for(int i = 0; i < 4; i++)
            {
                float _Offset = (float(i) / 3.0 - 0.5);
                float4 _Sample = tex2D(_Sampler, In + _Dir * _Offset * _Mixing);
                
                float4 _Mul = (lerp(_P, _M, clamp((_Dir.y / _Size.y), -1.0, 1.0)));
                
                _Result += _Sample * 0.25;
                _ClearType += _Sample * _Mul;
                _SampleSum += _Sample;
            }

            _SampleSum /= 4.0;
            _ClearType /= 4.0;

            _ClearType = lerp(_ClearType, _Render, _SampleSum.r * _SampleSum.g * _SampleSum.b * _SampleSum.a);
    
    return lerp(_Render, _ClearType, _Mixing) * _Alpha;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

    float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, In_Background, _Render_Background, _Render_Texture.a) : Fun_AA(S2D_Image, In, _Render_Texture, 1.0);
    return _Render;
}
/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
