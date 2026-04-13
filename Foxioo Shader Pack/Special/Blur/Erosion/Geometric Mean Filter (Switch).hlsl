/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (07.04.2026) */
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
    float _Size;
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

static const int _Offset = 8;

/*  Special thanks to Envy24!
    https://www.shadertoy.com/view/ssySDh */

float3 Fun_Filter(Texture2D _Texture, SamplerState _SamplerState, float2 In)
{
    float3 _Result = 1.0;
    float _Sum = 0.0;

    for(int y = -_Offset; y <= _Offset; y++)
    {
        for(int x = -_Offset; x <= _Offset; x++)
        {
            float3 _Render = _Texture.Sample(_SamplerState, In + (float2(x, y) / _Offset) * float2(fPixelWidth, fPixelHeight) * _Size).rgb;
            
            _Result += log(abs(_Render));
            _Sum++;
        }
    }

    return exp(_Result / _Sum);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, S2D_BackgroundSampler, In.texCoord) : Fun_Filter(S2D_Image, S2D_ImageSampler, In.texCoord) * In.Tint.rgb;

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;

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

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, S2D_BackgroundSampler, In.texCoord) : Fun_Filter(S2D_Image, S2D_ImageSampler, In.texCoord) * In.Tint.rgb;

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;
        
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}