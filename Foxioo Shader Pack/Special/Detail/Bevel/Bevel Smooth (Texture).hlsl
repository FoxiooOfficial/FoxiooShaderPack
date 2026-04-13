/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (07.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Dir;
    float _Size;
    float4 _ColorLight;
    float4 _ColorShadow;
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

static const int _Samples = 24;

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

    float _Alpha = 0.0;
    float2 _Dirr;
    sincos(radians(_Dir), _Dirr.x, _Dirr.y);

    for(int i = 0; i <= _Samples; i++)
    {
        float2 _Offset = _Dirr * float2(fPixelWidth, fPixelHeight) * (float(i) / float(_Samples)) * _Size;

            float _Low = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Offset).a;
            float _High = S2D_Image.Sample(S2D_ImageSampler, In.texCoord - _Offset).a;

        _Alpha += (_Low - _High);
    }
    
    _Alpha /= float(_Samples);

        float4 _Render = _Render_Texture;
            _Render.rgb += _Alpha > 0.0 ? _Alpha * _ColorLight.rgb : _Alpha * (1.0 - _ColorShadow.rgb);

        _Render = lerp(_Render_Texture, _Render, _Mixing);

    Out.Color = _Render;
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

    float _Alpha = 0.0;
    float2 _Dirr;
    sincos(radians(_Dir), _Dirr.x, _Dirr.y);

    for(int i = 0; i <= _Samples; i++)
    {
        float2 _Offset = _Dirr * float2(fPixelWidth, fPixelHeight) * (float(i) / float(_Samples)) * _Size;

            float _Low = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _Offset).a;
            float _High = S2D_Image.Sample(S2D_ImageSampler, In.texCoord - _Offset).a;

        _Alpha += (_Low - _High);
    }
    
    _Alpha /= float(_Samples);

        float4 _Render = _Render_Texture;
            _Render.rgb += _Alpha > 0.0 ? _Alpha * _ColorLight.rgb : _Alpha * (1.0 - _ColorShadow.rgb);

        _Render = lerp(_Render_Texture, _Render, _Mixing);
        
    _Render.rgb *= _Render.a;
    Out.Color = _Render;
    return Out;
}