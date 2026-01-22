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
    float _Mixing;
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


/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * _Mixing;

    float4 _Result = 0;

        _Result.rgb = (255 - (int3(255 - (_Render_Texture.rgb * 255)) | int3(_Render_Background.rgb * 255))) / 255.0;

    _Result.rgb = _Result.rgb * clamp(_Mixing, 0, 1);
    _Result.rgb += _Render_Texture.rgb * (1 - clamp(_Mixing, 0, 1));

    _Result.a = _Render_Texture.a;
    Out.Color = _Result;

    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _color)
{
    float4 color = _color;
    if (color.a != 0)
    {
        color.rgb /= color.a;
    }
    return color;
}

PS_OUTPUT ps_main_pm(in PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * _Mixing;

    float4 _Result = 0;

        _Result.rgb = (255 - (int3(255 - (_Render_Texture.rgb * 255)) | int3(_Render_Background.rgb * 255))) / 255.0;

    _Result.rgb = _Result.rgb * clamp(_Mixing, 0, 1);
    _Result.rgb += _Render_Texture.rgb * (1 - clamp(_Mixing, 0, 1));

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;

    return Out;
}
