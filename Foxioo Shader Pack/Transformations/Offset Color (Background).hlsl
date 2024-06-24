/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (24.06.2024) */
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

    if(_Blending_Mode == 0) 
    { 
        UV.x += (_Render_Texture.r + (_Render_Texture.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Texture.g + (_Render_Texture.b * _OffsetZ)) * _OffsetY;
        _Result = S2D_Background.Sample(S2D_BackgroundSampler, frac(UV)); 
    }
    else
    { 
        UV.x += (_Render_Background.r + (_Render_Background.b * _OffsetZ)) * _OffsetX;
        UV.y += (_Render_Background.g + (_Render_Background.b * _OffsetZ)) * _OffsetY;
        _Result = S2D_Image.Sample(S2D_ImageSampler, frac(UV)); 
    }
    
    _Result *= _Mixing;

    _Result.a *= _Render_Texture.a;

    Out.Color = _Result;

    return Out;
}