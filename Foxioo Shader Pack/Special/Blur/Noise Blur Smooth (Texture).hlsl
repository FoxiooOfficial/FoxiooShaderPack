/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (13.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    bool __;
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

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(sin(dot(_Pos, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(sin(dot(_Pos, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    const int _Size = 12;
    float4 _Render = 0.0;
   
        for(int i = 0; i < _Size; i++)
        {
            float2 _Off = Fun_Hash21(In.texCoord + i);
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2( _Off.x,  _Off.y) * _Mixing));
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(-_Off.x,  _Off.y) * _Mixing)) * 0.25;
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2( _Off.x, -_Off.y) * _Mixing)) * 0.25;
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(-_Off.x, -_Off.y) * _Mixing)) * 0.5;
        }

        _Render /= _Size * 2.0;

       _Render *= In.Tint;

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

    const int _Size = 12;
    float4 _Render = 0.0;
   
        for(int i = 0; i < _Size; i++)
        {
            float2 _Off = Fun_Hash21(In.texCoord + i);
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2( _Off.x,  _Off.y) * _Mixing));
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(-_Off.x,  _Off.y) * _Mixing)) * 0.25;
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2( _Off.x, -_Off.y) * _Mixing)) * 0.25;
            _Render += S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(-_Off.x, -_Off.y) * _Mixing)) * 0.5;
        }

        _Render /= _Size * 2.0;

        _Render = Demultiply(_Render);
        _Render *= In.Tint;

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}