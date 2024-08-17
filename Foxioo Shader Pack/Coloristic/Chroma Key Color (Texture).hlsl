/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (08.08.2024) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float4 _ColorKey;
    float _PowerKey;
    bool __;
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

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

        float4 _Result = _Render_Texture;

        float3 _Difference = abs(_Result.rgb - _ColorKey.rgb);
        float _KeyAlpha = max(_Difference.r, max(_Difference.g, _Difference.b));

        _Result.a = _Render_Texture.a * (1 + (_KeyAlpha - 1) * _PowerKey);

    Out.Color = _Result;
    
    return Out;
}
/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;

        float4 _Result = _Render_Texture;

        float3 _Difference = abs(_Result.rgb - _ColorKey.rgb);
        float _KeyAlpha = max(_Difference.r, max(_Difference.g, _Difference.b));

        _Result.a = _Render_Texture.a * (1 + (_KeyAlpha - 1) * _PowerKey);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
