/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (06.08.2024) */
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Cb = -0.168736 * _Result.r - 0.331264 * _Result.g + 0.5 * _Result.b + 0.5;
            float _Cr = 0.5 * _Result.r - 0.418688 * _Result.g - 0.081312 * _Result.b + 0.5;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _Cb, _Cr) * _Mixing, min(_Mixing, 1));

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
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Cb = -0.168736 * _Result.r - 0.331264 * _Result.g + 0.5 * _Result.b + 0.5;
            float _Cr = 0.5 * _Result.r - 0.418688 * _Result.g - 0.081312 * _Result.b + 0.5;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _Cb, _Cr) * _Mixing, min(_Mixing, 1));

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}