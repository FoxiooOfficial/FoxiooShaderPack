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
    float _Phase;
    float _PosX;
    float _PosY;
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

float Fun_Luminance(float3 _Result)
{
    const float _Kr = 0.299;
    const float _Kg = 0.587;
    const float _Kb = 0.114;

    float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;

    return _Y;
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;

            float3 _Lum = Fun_Luminance(_Render.rgb);
            _Lum *= _Lum;

                float2 _UV = In.texCoord + float2(_PosX, _PosY);

                    _Lum.r = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.r + _Lum.r * 0.2 + 4.0))) * _Render.r;
                    _Lum.g = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.g + _Lum.g * 0.2 + 2.0))) * _Render.g;
                    _Lum.b = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.b + _Lum.b * 0.2 + 0.0))) * _Render.b;

                //_Lum = abs(_Lum);

        _Render.rgb = lerp(_Render.rgb, pow(abs(_Render.rgb * 0.45 + 0.75 * (_Lum * _Render.rgb * 0.5 + _Lum * 0.5)), 2.2), _Mixing);
    
    _Render.a = _Render_Texture.a;
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Render =    _Blending_Mode ? _Render_Background : _Render_Texture;

            float3 _Lum = Fun_Luminance(_Render.rgb);
            _Lum *= _Lum;

                float2 _UV = In.texCoord + float2(_PosX, _PosY);

                    _Lum.r = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.r + _Lum.r * 0.2 + 4.0))) * _Render.r;
                    _Lum.g = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.g + _Lum.g * 0.2 + 2.0))) * _Render.g;
                    _Lum.b = 0.5 + 0.5 * sin(_Phase * abs(cos(_UV.x + _Render.b + _Lum.b * 0.2 + 0.0))) * _Render.b;

                //_Lum = abs(_Lum);

        _Render.rgb = lerp(_Render.rgb, pow(abs(_Render.rgb * 0.45 + 0.75 * (_Lum * _Render.rgb * 0.5 + _Lum * 0.5)), 2.2), _Mixing);
    _Render.a = _Render_Texture.a;
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}