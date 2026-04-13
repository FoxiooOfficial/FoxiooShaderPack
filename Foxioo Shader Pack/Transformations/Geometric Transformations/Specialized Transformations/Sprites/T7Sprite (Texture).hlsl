/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.02.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Depth;
    float _Buffer;
    bool __;
};

struct PS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color    : SV_TARGET;
    float Depth     : SV_DEPTH;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;
    float _DepthX = saturate(_Depth - (1.0 - In.texCoord.y));
    Out.Depth = _DepthX;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float _Render_Depth = Out.Depth;

    float4 _Result = _Buffer == 1.0 ? _DepthX : _Render_Texture;

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
    Out.Depth = saturate(_Depth - (1.0 - In.texCoord.y));

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float _Render_Depth = Out.Depth;

    float4 _Result = _Render_Texture;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}