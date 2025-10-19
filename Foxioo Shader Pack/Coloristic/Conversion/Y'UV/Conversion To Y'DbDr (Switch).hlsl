/***********************************************************/

/* Autor shader: Foxioo */
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
    bool _Blending_Mode;
    float _Mixing;
    bool _Correction;
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

        float3 _CorrectionColor = float3(0, _Correction, _Correction) / 2.0;

            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Db = -0.450 * _Result.r - 0.883 * _Result.g + 1.333 * _Result.b;
            float _Dr = -1.333 * _Result.r + 1.116 * _Result.g + 0.217 * _Result.b;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _Db, _Dr) + _CorrectionColor, _Mixing);

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

        float3 _CorrectionColor = float3(0, _Correction, _Correction) / 2.0;

            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Db = -0.450 * _Result.r - 0.883 * _Result.g + 1.333 * _Result.b;
            float _Dr = -1.333 * _Result.r + 1.116 * _Result.g + 0.217 * _Result.b;

        _Result.rgb = lerp(_Result.rgb, float3(_Y, _Db, _Dr) + _CorrectionColor, _Mixing);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}