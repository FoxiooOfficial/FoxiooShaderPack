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
    float _YLevels;
    float _CLevels;
    float _BlurScale;
    float _Segments;
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

float Fun_Y(float _R, float _G, float _B)   {   return 0.299* _R + 0.587 * _G + 0.114 * _B;    }

float Fun_Cb(float _b, float _Y)            {   return 0.5 + (_b - _Y) * 0.564;    }
float Fun_Cr(float _r, float _Y)            {   return 0.5 + (_r - _Y) * 0.713;    }

float3 Fun_YCbCr(float _Y, float _Cb, float _Cr)
{
    return float3(
        _Y + 1.402 * (_Cr - 0.5),
        _Y - 0.344 * (_Cb - 0.5) - 0.714 * (_Cr - 0.5),
        _Y + 1.772 * (_Cb - 0.5)
    );
    
}

float4 Fun_GetColor(float2 In, Texture2D _Texture, SamplerState _Sampler)  {    return _Texture.Sample(_Sampler, In); }

float4 Fun_Interpolation(float2 In, float _Segm, Texture2D _Texture, SamplerState _Sampler, float _Smoothness)
{
    float2 _In_Segment = floor(In * _Segm) / _Segm;
    float2 _In_Segment_Next = (floor(In * _Segm) + 1.0) / _Segm;
    
    float2 _UV = frac(In * _Segm);

        float4 _Render_0X = Fun_GetColor(_In_Segment, _Texture, _Sampler);
        float4 _Render_1X = Fun_GetColor(float2(_In_Segment_Next.x, _In_Segment.y), _Texture, _Sampler);
            
            float4 _Render_X = lerp(_Render_0X, _Render_1X, smoothstep(0.0, _Smoothness, _UV.x));


        float4 _Render_0Y = Fun_GetColor(float2(_In_Segment.x, _In_Segment_Next.y), _Texture, _Sampler);
        float4 _Render_1Y = Fun_GetColor(_In_Segment_Next, _Texture, _Sampler);
       
            float4 _Render_Y = lerp(_Render_0Y, _Render_1Y, smoothstep(0.0, _Smoothness, _UV.x));

    return lerp(_Render_X, _Render_Y, smoothstep(0.0, _Smoothness, _UV.y));
}

float Quantize(float _V, float _Levels, float _Mixing)
{
    float _Quantize = round(_V * _Levels) / _Levels;
    return lerp(_V, _Quantize, _Mixing);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float _Div = (_Segments * _Mixing * fPixelWidth) == 0 ? 0.00001 : (_Segments * _Mixing * fPixelWidth);
    float __Segments = 1.0 / _Div;

        float4 _Result = _Blending_Mode ? Fun_Interpolation(In.texCoord, __Segments, S2D_Background, S2D_BackgroundSampler, _BlurScale) : Fun_Interpolation(In.texCoord, __Segments, S2D_Image, S2D_ImageSampler, _BlurScale) * In.Tint;
        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

    float Y  = Fun_Y(_Result.r, _Result.g, _Result.b);
    float Cb = Fun_Cb(_Result.b, Y);
    float Cr = Fun_Cr(_Result.r, Y);
    float Yq  = Quantize(Y,  _YLevels, _Mixing);
    float Cbq = Quantize(Cb, _CLevels, _Mixing);
    float Crq = Quantize(Cr, _CLevels, _Mixing);

    _Result.rgb = Fun_YCbCr(Yq, Cbq, Crq);
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

    float _Div = (_Segments * _Mixing * fPixelWidth) == 0 ? 0.00001 : (_Segments * _Mixing * fPixelWidth);
    float __Segments = 1.0 / _Div;

        float4 _Result = _Blending_Mode ? Fun_Interpolation(In.texCoord, __Segments, S2D_Background, S2D_BackgroundSampler, _BlurScale) : Fun_Interpolation(In.texCoord, __Segments, S2D_Image, S2D_ImageSampler, _BlurScale) * In.Tint;
        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

        _Result = Demultiply(_Result);

    float Y  = Fun_Y(_Result.r, _Result.g, _Result.b);
    float Cb = Fun_Cb(_Result.b, Y);
    float Cr = Fun_Cr(_Result.r, Y);
    float Yq  = Quantize(Y,  _YLevels, _Mixing);
    float Cbq = Quantize(Cb, _CLevels, _Mixing);
    float Crq = Quantize(Cr, _CLevels, _Mixing);

    _Result.rgb = Fun_YCbCr(Yq, Cbq, Crq);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}