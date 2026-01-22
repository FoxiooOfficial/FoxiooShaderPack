/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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
    float _SegmentSize;
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

float Fun_Lum(float3 _Render) { return (0.2126 * _Render.r + 0.7152 * _Render.g + 0.0722 * _Render.b); }

float4 Fun_Kuwahara(float2 UV, Texture2D<float4> _Texture, SamplerState _Sampler)
{
    const int _R = 4;
    const int _Size = 2 * _R + 1;

    float4  _SumColor[4]    = { float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0) };
    float   _SumLum[4]      = { 0.0, 0.0, 0.0, 0.0 };
    float   _SumLumSq[4]    = { 0.0, 0.0, 0.0, 0.0 };
    int     _Count[4]       = { 0, 0, 0, 0 };

    for (int _Y = -_R; _Y <= _R; _Y++)
    {
        for (int _X = -_R; _X <= _R; _X++)
        {
            float2 _Off = float2(_X * fPixelWidth, _Y * fPixelHeight) * _SegmentSize;
            float4 _Render = _Texture.Sample(_Sampler, UV + _Off);
            float4 _Col = _Render;  float _Lum = Fun_Lum(_Render.rgb);

            int _R = (min(sign(_X), 0) + 1) + max(0, sign(_Y)) * 2;

                _SumColor[_R]   += _Col;
                _SumLum[_R]     += _Lum;
                _SumLumSq[_R]   += _Lum * _Lum;
                _Count[_R]      += 1.0;
        }
    }

    float4 _Mean[4];
    float  _Var[4];
    for (int i = 0; i < 4; i++)
    {
        _Mean[i] = _SumColor[i] / _Count[i];
            float _E = _SumLum[i] / _Count[i];
            float _P = _SumLumSq[i] / _Count[i];

        _Var[i] = max(0.0, _P - _E * _E);
    }

    int _Best = 0;
    float _BVar = _Var[0];
    for (int ii = 1; ii < 4; ii++)
    {
        if (_Var[ii] < _BVar)
        {
            _BVar = _Var[ii];
            _Best = ii;
        }
    }

    return float4(_Mean[_Best]);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Render_Kuwahara, _Result;
    
        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
            _Render_Kuwahara = Fun_Kuwahara(In.texCoord, S2D_Image, S2D_ImageSampler) * In.Tint;
        }
        else
        {
            _Result = _Render_Background;
            _Render_Kuwahara = Fun_Kuwahara(In.texCoord, S2D_Background, S2D_BackgroundSampler);
        }

    _Result = lerp(_Result, _Render_Kuwahara, _Mixing);
    _Result.a *= _Render_Texture.a;

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Render_Kuwahara, _Result;
    
        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
            _Render_Kuwahara = Demultiply(Fun_Kuwahara(In.texCoord, S2D_Image, S2D_ImageSampler)) * In.Tint;
        }
        else
        {
            _Result = _Render_Background;
            _Render_Kuwahara = Fun_Kuwahara(In.texCoord, S2D_Background, S2D_BackgroundSampler);
        }

    _Result = lerp(_Result, _Render_Kuwahara, _Mixing);
    _Result.a *= _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}