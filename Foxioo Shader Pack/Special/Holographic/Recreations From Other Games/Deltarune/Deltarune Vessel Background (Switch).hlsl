/***********************************************************/

/* Shader author: Foxioo */
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
    bool __;
    float _PointX;
    float _PointY;
    bool ___;
    bool _Blending_Mode;
    float _Mixing;
    float _Offset;
    float _Time;
    bool ____;
	bool _Is_Pre_296_Build;
	bool _____;
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

static const float _Pi = 3.14159265359;
static const int _Size = 6;

float4 Fun_Vessel(Texture2D Texture, SamplerState Sampler, float2 UV, float4 _Mul)
{
    float4 _Result = float4(0, 0, 0, 1);
    float2 _Pos = float2(_PointX, _PointY);

        for(float i = 1; i < _Size; i++)  
        {
            float _T = i / float(_Size);
                float2 _In = ((UV - _Pos) * frac(_Time + _T)) + _Pos;
                float _Alpha = abs(sin((_Time + _T) * _Pi));

                _Result += Texture.Sample(Sampler, frac(lerp(UV, _In, _Offset))) * _Alpha * _Mul;
        }

    return _Result * 0.27;
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Blending_Mode ? Fun_Vessel(S2D_Background, S2D_BackgroundSampler, In.texCoord, float4(1.0, 1.0, 1.0, 1.0)) : Fun_Vessel(S2D_Image, S2D_ImageSampler, In.texCoord, In.Tint);

            _Result = lerp(_Render, _Result, _Mixing);

        if(_Blending_Mode)
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

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Blending_Mode ? Fun_Vessel(S2D_Background, S2D_BackgroundSampler, In.texCoord, float4(1.0, 1.0, 1.0, 1.0)) : Fun_Vessel(S2D_Image, S2D_ImageSampler, In.texCoord, In.Tint);

            _Result = lerp(_Render, Demultiply(_Result), _Mixing);

        if(_Blending_Mode)
        _Result.a *= _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}