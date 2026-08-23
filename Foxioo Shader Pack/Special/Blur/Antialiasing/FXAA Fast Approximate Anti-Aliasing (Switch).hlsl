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
    float _Threshold;
    float _Relative;
    //float _SubPixelBlending;
    float _Off;
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

float4 Fun_AA(Texture2D _Texture2D, SamplerState _SamplerState, float2 In, float4 _Render, float _Alpha)
{
    float2 _Size = float2(fPixelWidth, fPixelHeight);

    /* kinda emboss

        based on FXAA
        this helps: https://catlikecoding.com/unity/tutorials/custom-srp/fxaa/ :3
    */
    float4 _N = _Texture2D.Sample(_SamplerState, In + float2( 0.0,   _Off) * _Size);
    float4 _E = _Texture2D.Sample(_SamplerState, In + float2( _Off,   0.0) * _Size);
    float4 _S = _Texture2D.Sample(_SamplerState, In + float2( 0.0,  -_Off) * _Size);
    float4 _W = _Texture2D.Sample(_SamplerState, In + float2(-_Off,   0.0) * _Size);

    float4 _NW = _Texture2D.Sample(_SamplerState, In + float2(-_Off,  _Off) * _Size);
    float4 _NE = _Texture2D.Sample(_SamplerState, In + float2( _Off,  _Off) * _Size);
    float4 _SW = _Texture2D.Sample(_SamplerState, In + float2(-_Off, -_Off) * _Size);
    float4 _SE = _Texture2D.Sample(_SamplerState, In + float2( _Off, -_Off) * _Size);

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

                float4 _EdgeColor = _Texture2D.Sample(_SamplerState, _UV_Final) * 0.75 + (_S + _W + _N + _E) / 4.0 * 0.25;

    return lerp(_Render, _EdgeColor, saturate(_Factor * _Mixing)) * _Alpha;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.bgCoord);

        float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, S2D_BackgroundSampler, In.bgCoord, _Render_Background, _Render_Texture.a) : Fun_AA(S2D_Image, S2D_ImageSampler, In.texCoord, _Render_Texture, 1.0) * In.Tint;

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

        float4 _Render = _Blending_Mode ? Fun_AA(S2D_Background, S2D_BackgroundSampler, In.bgCoord, _Render_Background, _Render_Texture.a) : Demultiply(Fun_AA(S2D_Image, S2D_ImageSampler, In.texCoord, _Render_Texture, 1.0)) * In.Tint;

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}