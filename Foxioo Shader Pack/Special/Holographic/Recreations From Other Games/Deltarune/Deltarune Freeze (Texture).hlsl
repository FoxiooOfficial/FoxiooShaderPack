/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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
    float4 _Color;
    float _Fade;
    float _PosXFreeze;
    float _PosYFreeze;
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

        float4 _Freeze_0 = float4(_Color.rgb, S2D_Image.Sample(S2D_ImageSampler, In.texCoord).a * In.Tint.a);
        float4 _Freeze_1 = float4(_Color.rgb, S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight))).a * In.Tint.a) * 0.5;
        float4 _Freeze_2 = float4(_Color.rgb, S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight))).a * In.Tint.a) * 0.5;

        float4 _Freeze_Sum = (_Freeze_0 + _Freeze_1 + _Freeze_2);
        if(_Fade < 1.0 - In.texCoord.y) _Freeze_Sum = 0;

        float4 _Result = lerp(_Render_Texture, _Render_Texture + _Freeze_Sum, _Mixing);
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

        float4 _Freeze_0 = S2D_Image.Sample(S2D_ImageSampler, In.texCoord);
        float4 _Freeze_1 = S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight)));
        float4 _Freeze_2 = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight)));

            _Freeze_0 = float4(_Color.rgb, _Freeze_0.a * In.Tint.a);
            _Freeze_1 = float4(_Color.rgb, _Freeze_1.a * In.Tint.a) * 0.5;
            _Freeze_2 = float4(_Color.rgb, _Freeze_2.a * In.Tint.a) * 0.5;

        float4 _Freeze_Sum = (_Freeze_0 + _Freeze_1 + _Freeze_2);
        if(_Fade < 1.0 - In.texCoord.y) _Freeze_Sum = 0;

        float4 _Result = lerp(_Render_Texture, _Render_Texture + _Freeze_Sum, _Mixing);

    _Result.a = saturate(_Result.a);
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}