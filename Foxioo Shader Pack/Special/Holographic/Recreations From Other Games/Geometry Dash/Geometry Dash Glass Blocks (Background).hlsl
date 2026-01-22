/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (28.11.2025) */
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
    float _Mul;
    float _Distance;
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * _Mul;

        float4 _Render;
        _Render.rgb = _Render_Texture.rgb + (_Render_Background.rgb * _Render_Background.rgb);
        _Render.a = _Render_Texture.r * _Render_Texture.g * _Render_Texture.b * _Render_Texture.a;

        float4 _RenderClose = _Render * 0.04705;
        float4 _RenderFar   = _Render + lerp(0.43529, 0.164705, In.texCoord.y) * _Render_Texture.a;

        _RenderFar.rgb += _Render_Background.rgb * _RenderFar.rgb;

                
                float _DistanceEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.1);
                float _DistanceExEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.0);
                float _Alpha = max(_DistanceEx, 0.5);
                if(abs(_Distance) >= 1.0) _DistanceEx *= 1.5;

            float4 _Fade = lerp(_RenderClose, _RenderFar * 1.25, saturate(_DistanceEx)) * _Alpha;
            float _Fade_Alpha = _Fade.r * _Fade.g * _Fade.b * _Fade.a;

            float4 _Result = _Fade * _Fade_Alpha + _Render_Background + _Render_Texture * _DistanceExEx * 0.5 + _Fade * _DistanceExEx * 0.5;

            _Result = lerp(_Render_Texture, _Result * _Render_Texture.a, _Mixing);

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * _Mul;

        float4 _Render;
        _Render.rgb = _Render_Texture.rgb + (_Render_Background.rgb * _Render_Background.rgb);
        _Render.a = _Render_Texture.r * _Render_Texture.g * _Render_Texture.b * _Render_Texture.a;

        float4 _RenderClose = _Render * 0.04705;
        float4 _RenderFar   = _Render + lerp(0.43529, 0.164705, In.texCoord.y) * _Render_Texture.a;

        _RenderFar.rgb += _Render_Background.rgb * _RenderFar.rgb;

                
                float _DistanceEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.1);
                float _DistanceExEx = max(1.0 - abs(1.0 - abs(_Distance)), 0.0);
                float _Alpha = max(_DistanceEx, 0.5);
                if(abs(_Distance) >= 1.0) _DistanceEx *= 1.5;

            float4 _Fade = lerp(_RenderClose, _RenderFar * 1.25, saturate(_DistanceEx)) * _Alpha;
            float _Fade_Alpha = _Fade.r * _Fade.g * _Fade.b * _Fade.a;

            float4 _Result = _Fade * _Fade_Alpha + _Render_Background + _Render_Texture * _DistanceExEx * 0.5 + _Fade * _DistanceExEx * 0.5;

            _Result = lerp(_Render_Texture, _Result * _Render_Texture.a, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}