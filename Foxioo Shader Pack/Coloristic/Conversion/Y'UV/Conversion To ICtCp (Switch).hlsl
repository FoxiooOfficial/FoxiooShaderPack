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

        float3 _CorrectionColor = float3(_Correction * 2.0, 0, 0);

            const float3x3 _LMSConst = float3x3(
                0.3592, 0.6976, -0.0358,
                -0.1922, 1.1004, 0.0755,
                0.0070, 0.0749, 0.8434
            );

            float3 _LMS = mul(_Result.rgb, _LMSConst);

                const float _M1 = 2610.0 / 16384.0;
                const float _M2 = 2523.0 / 32.0;
                const float _C1 = 3424.0 / 4096.0;
                const float _C2 = 2413.0 / 128.0;
                const float _C3 = 2392.0 / 128.0;
                float3 _LMSpq = pow( (_C1 + _C2 * pow(abs(_LMS), _M1)) / (1.0 + _C3 * pow(abs(_LMS), _M1)), _M2 );

            float3x3 _ICtCpConst = float3x3(
                0.5,   0.5,    0.0,
                1.6137, -3.3234, 1.7097,
                4.3780, -4.2455, -0.1325
            );

            float3 _ICtCp = mul(_Result.rgb, _ICtCpConst);

        _Result.rgb = lerp(_Result.rgb, _ICtCp - _CorrectionColor, _Mixing);

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

        float3 _CorrectionColor = float3(_Correction * 2.0, 0, 0);

            const float3x3 _LMSConst = float3x3(
                0.3592, 0.6976, -0.0358,
                -0.1922, 1.1004, 0.0755,
                0.0070, 0.0749, 0.8434
            );

            float3 _LMS = mul(_Result.rgb, _LMSConst);

                const float _M1 = 2610.0 / 16384.0;
                const float _M2 = 2523.0 / 32.0;
                const float _C1 = 3424.0 / 4096.0;
                const float _C2 = 2413.0 / 128.0;
                const float _C3 = 2392.0 / 128.0;
                float3 _LMSpq = pow( (_C1 + _C2 * pow(abs(_LMS), _M1)) / (1.0 + _C3 * pow(abs(_LMS), _M1)), _M2 );

            float3x3 _ICtCpConst = float3x3(
                0.5,   0.5,    0.0,
                1.6137, -3.3234, 1.7097,
                4.3780, -4.2455, -0.1325
            );

            float3 _ICtCp = mul(_Result.rgb, _ICtCpConst);

        _Result.rgb = lerp(_Result.rgb, _ICtCp - _CorrectionColor, _Mixing);
    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}