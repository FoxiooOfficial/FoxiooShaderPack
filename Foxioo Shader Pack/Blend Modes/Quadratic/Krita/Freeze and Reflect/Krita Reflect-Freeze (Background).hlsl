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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    
        float4 _Reflect = 0;
        float4 _Freeze  = 0;

                _Reflect.rgb = clamp(pow(_Render_Texture.rgb, 2) / (1 - _Render_Background.rgb), 0.0, 1.0);
                _Freeze.rgb  = clamp(1 - pow(1 - _Render_Background.rgb, 2) / _Render_Texture.rgb, 0.0, 1.0);

            float4 _Result = lerp(_Reflect, _Freeze, 0.5);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb * _Mixing, _Mixing);
    
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Reflect = 0;
        float4 _Freeze  = 0;

                _Reflect.rgb = clamp(pow(_Render_Texture.rgb, 2) / (1 - _Render_Background.rgb), 0.0, 1.0);
                _Freeze.rgb  = clamp(1 - pow(1 - _Render_Background.rgb, 2) / _Render_Texture.rgb, 0.0, 1.0);

            float4 _Result = lerp(_Reflect, _Freeze, 0.5);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb * _Mixing, _Mixing);
            
    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
