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
    float _OffsetX;
    float _OffsetY;
    float _OffsetZ;
    float _PosX;
    float _PosY;
    bool ___;
    bool _Blending_Mode;
    float _Mixing;
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
    float4 Color : SV_TARGET;
};

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{   
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(_PosX, _PosY))) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, frac(In.texCoord + float2(_PosX, _PosY))) * In.Tint;

    float2 UV = In.texCoord;

    float4 _Result = 0;
    float4 _Render = 0;

    if(_Blending_Mode == 1) 
    { 
        UV.x += (_Render_Texture.r + (_Render_Texture.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Texture.g + (_Render_Texture.b * _OffsetZ)) * _OffsetY;
        _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(UV)); 

        _Render = _Render_Texture;
    }
    else
    { 
        UV.x += (_Render_Background.r + (_Render_Background.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Background.g + (_Render_Background.b * _OffsetZ)) * _OffsetY;
        _Result = S2D_Image.Sample(S2D_ImageSampler, frac(UV)) * In.Tint;

        _Render = _Render_Background;
    }
    
    _Result = lerp(_Render, _Result, _Mixing);
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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, frac(In.texCoord + float2(_PosX, _PosY)))) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, frac(In.texCoord + float2(_PosX, _PosY))) * In.Tint;

    float2 UV = In.texCoord;

    float4 _Result = 0;
    float4 _Render = 0;

    if(_Blending_Mode == 1) 
    { 
        UV.x += (_Render_Texture.r + (_Render_Texture.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Texture.g + (_Render_Texture.b * _OffsetZ)) * _OffsetY;
        _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(UV)); 

        _Render = _Render_Texture;
    }
    else
    { 
        UV.x += (_Render_Background.r + (_Render_Background.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Background.g + (_Render_Background.b * _OffsetZ)) * _OffsetY;
        _Result = Demultiply(S2D_Image.Sample(S2D_ImageSampler, frac(UV))) * In.Tint;

        _Render = _Render_Background;
    }
    
    _Result = lerp(_Render, _Result, _Mixing);
    
    _Result.a *= _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}