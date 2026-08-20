/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.5 (18.10.2025) */
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
/* Variables */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    bool __;
	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

static const float _Off = 1.0;

float Fun_Luminance(float4 _Result)
{
    static const float _Kr = 0.299;
    static const float _Kg = 0.587;
    static const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y * _Result.a;
}

float4 Fun_AA(Texture2D _Texture2D, SamplerState _SamplerState, float2 In, float4 _Render, float _Alpha)
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
    float4 _NW = _Texture2D.Sample(_SamplerState, In + float2(-_Off, -_Off) * _Size);
    float4 _NE = _Texture2D.Sample(_SamplerState, In + float2( _Off, -_Off) * _Size);
    float4 _SW = _Texture2D.Sample(_SamplerState, In + float2(-_Off,  _Off) * _Size);
    float4 _SE = _Texture2D.Sample(_SamplerState, In + float2( _Off,  _Off) * _Size);

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
        static const float4 _M  = float4(1.0, 0.31, 0.08, 1.0);    /* left -> orange */
        static const float4 _P  = float4(0.16, 0.58, 1.0, 1.0);    /* right -> blue */

            for(uint i = 0; i < 4; i++)
            {
                float _Offset = (float(i) / 3.0 - 0.5);
                float4 _Sample = _Texture2D.Sample(_SamplerState, In + _Dir * _Offset * _Mixing);
                
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, S2D_BackgroundSampler, In.texCoord, _Render_Background, _Render_Texture.a) : Fun_AA(S2D_Image, S2D_ImageSampler, In.texCoord, _Render_Texture, 1.0) * In.Tint;

    Out.Color = _Render;
    
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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, S2D_BackgroundSampler, In.texCoord, _Render_Background, _Render_Texture.a) : Demultiply(Fun_AA(S2D_Image, S2D_ImageSampler, In.texCoord, _Render_Texture, 1.0) * In.Tint);

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}