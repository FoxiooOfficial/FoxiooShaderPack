/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.5 (18.10.2025) */
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
    float _Temperature;
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
        float4 _Render = 0;

        if(_Blending_Mode == 0)
        {
            _Result.r = (_Render_Texture.r + (_Temperature / 273.15)) * _Mixing;
		    _Result.g = (_Render_Texture.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Result.b = (_Render_Texture.b) * _Mixing;
            _Render = _Render_Texture;
        }
        else
        {
            _Result.r = (_Render_Background.r + (_Temperature / 273.15)) * _Mixing;
		    _Result.g = (_Render_Background.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Result.b = (_Render_Background.b) * _Mixing;
            _Render = _Render_Background;
        }

    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

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
        float4 _Render = 0;

        if(_Blending_Mode == 0)
        {
            _Result.r = (_Render_Texture.r + (_Temperature / 273.15)) * _Mixing;
		    _Result.g = (_Render_Texture.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Result.b = (_Render_Texture.b) * _Mixing;
            _Render = _Render_Texture;
        }
        else
        {
            _Result.r = (_Render_Background.r + (_Temperature / 273.15)) * _Mixing;
		    _Result.g = (_Render_Background.g + (_Temperature / 273.15) / 2.0) * _Mixing;
		    _Result.b = (_Render_Background.b) * _Mixing;
            _Render = _Render_Background;
        }

    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}