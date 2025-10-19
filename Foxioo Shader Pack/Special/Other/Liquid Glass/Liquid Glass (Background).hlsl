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

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Intensity;
    float _Distortion;
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

float Fun_Liquid(float2 In, float _Size)
{
    float2 _Dist = min(In, 1.0 - In);
    float _DistMin = min(_Dist.x, _Dist.y);

        return 1.0 - smoothstep(0.0, _Size, _DistMin);
}

float3 Fun_Outline(float2 In, float3 _Color, float _Mul)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = S2D_Image.Sample(S2D_ImageSampler, In).a * _Mul;

    /* Outline DARK! */
    float aL1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x, 0)) .a * _Mul;
    float aR1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x, 0))  .a * _Mul;
    float aU1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y)) .a * _Mul;
    float aD1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y))  .a * _Mul;

    /* Outline LIGHT! */
    float aL2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 2, 0)) .a * _Mul;
    float aR2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x * 2, 0))  .a * _Mul;
    float aU2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y * 2)) .a * _Mul;
    float aD2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y * 2))  .a * _Mul;

    /* no outline. */
    float aL3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 1, 0)) .a * _Mul;
    float aR3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(_PX.x * 1, 0))  .a * _Mul;
    float aU3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, -_PX.y * 1)) .a * _Mul;
    float aD3 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0, _PX.y * 1))  .a * _Mul;

        float _EdgeDark  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _EdgeLight = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    if (_EdgeDark > 0.5)        return - 0.5;
    else if (_EdgeLight > 0.5)  return 2.0;
    else return _Color;
}

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(sin(dot(_Pos, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(sin(dot(_Pos, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

float2 Fun_Noise(float2 _Pos) 
{
    float2 _Noise = Fun_Hash21(_Pos);

    return _Noise;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _Mask = float2(  Fun_Liquid(float2(In.texCoord.x, In.texCoord.x) * _Render_Texture.a, _Intensity * fPixelWidth),
                                Fun_Liquid(float2(In.texCoord.y, In.texCoord.y) * _Render_Texture.a, _Intensity * fPixelHeight));


    float2 _UVB = frac(In.texCoord * 0.5) * 2.0;
    float2 _UVM = abs(_UVB - 1.0);

    float2 _UV = lerp(_UVB, _UVM, _Mask * _Mask * _Distortion);


        float4 _Render_Background = float4(0.0, 0.0, 0.0, 0.0);
        for(int i = 0; i < 36; i++) {
            float _Mul = fmod(float(i), 2.0) ? 1.0 : -1.0;
            _Render_Background += S2D_Background.Sample(S2D_BackgroundSampler, _UV + Fun_Noise(In.texCoord) * (5.0 + float(i)) * _Mul * float2(fPixelWidth, fPixelHeight));
        }
        _Render_Background /= 36.0;

        float3 _Outline = Fun_Outline(In.texCoord, _Render_Background.rgb, In.Tint.a);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, (_Render_Tint.rgb * 0.75 + _Outline.rgb * 0.25) * 0.9, _Mixing), _Render_Texture.a);

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
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _Mask = float2(  Fun_Liquid(float2(In.texCoord.x, In.texCoord.x) * _Render_Texture.a, _Intensity * fPixelWidth),
                                Fun_Liquid(float2(In.texCoord.y, In.texCoord.y) * _Render_Texture.a, _Intensity * fPixelHeight));


    float2 _UVB = frac(In.texCoord * 0.5) * 2.0;
    float2 _UVM = abs(_UVB - 1.0);

    float2 _UV = lerp(_UVB, _UVM, _Mask * _Mask * _Distortion);


        float4 _Render_Background = float4(0.0, 0.0, 0.0, 0.0);
        for(int i = 0; i < 36; i++) {
            float _Mul = fmod(float(i), 2.0) ? 1.0 : -1.0;
            _Render_Background += S2D_Background.Sample(S2D_BackgroundSampler, _UV + Fun_Noise(In.texCoord) * (5.0 + float(i)) * _Mul * float2(fPixelWidth, fPixelHeight));
        }
        _Render_Background /= 36.0;

        float3 _Outline = Fun_Outline(In.texCoord, _Render_Background.rgb, In.Tint.a);
        float4 _Render_Tint = lerp(_Render_Background, _Render_Texture, 0.5);

    float4 _Render = float4(lerp(_Render_Texture.rgb, (_Render_Tint.rgb * 0.75 + _Outline.rgb * 0.25) * 0.9, _Mixing), _Render_Texture.a);
    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}