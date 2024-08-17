/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (06.08.2024) */
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

            float _K = 1.0 - max(_Result.r, max(_Result.g, _Result.b));
            float _C = (1.0 - _Result.r - _K) / (1.0 - _K);
            float _M = (1.0 - _Result.g - _K) / (1.0 - _K);
            float _Y = (1.0 - _Result.b - _K) / (1.0 - _K);

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, float3(_C, _M, _Y) * _Mixing, min(_Mixing, 1));


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

            float _K = 1.0 - max(_Result.r, max(_Result.g, _Result.b));
            float _C = (1.0 - _Result.r - _K) / (1.0 - _K);
            float _M = (1.0 - _Result.g - _K) / (1.0 - _K);
            float _Y = (1.0 - _Result.b - _K) / (1.0 - _K);

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, float3(_C, _M, _Y) * _Mixing, min(_Mixing, 1));

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}