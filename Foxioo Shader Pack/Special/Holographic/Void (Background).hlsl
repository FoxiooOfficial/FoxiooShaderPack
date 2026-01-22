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
    float _Border;
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

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b) * _Result.a; }

float Fun_OuterOutline(float2 In, float _Tint)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = S2D_Image.Sample(S2D_ImageSampler, In).a * _Tint;

    float aL = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * _Border, 0.0)).a * _Tint;
    float aR = S2D_Image.Sample(S2D_ImageSampler, In + float2( _PX.x * _Border, 0.0)).a * _Tint;
    float aU = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0, -_PX.y * _Border)).a * _Tint;
    float aD = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0,  _PX.y * _Border)).a * _Tint;

    return step(0.01, aL + aR + aU + aD) * (1.0 - _Alpha) * ( (aL + aR + aU + aD));
}

float3 Fun_Outline(float2 In, float3 _Color, float _Tint)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = S2D_Image.Sample(S2D_ImageSampler, In).a * _Tint;

    float aL1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * _Border, 0.0)).a * _Tint;
    float aR1 = S2D_Image.Sample(S2D_ImageSampler, In + float2( _PX.x * _Border, 0.0)).a * _Tint;
    float aU1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0, -_PX.y * _Border)).a * _Tint;
    float aD1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0,  _PX.y * _Border)).a * _Tint;

    float aL2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 2.0 * _Border, 0.0)).a * _Tint;
    float aR2 = S2D_Image.Sample(S2D_ImageSampler, In + float2( _PX.x * 2.0 * _Border, 0.0)).a * _Tint;
    float aU2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0, -_PX.y * 2.0 * _Border)).a * _Tint;
    float aD2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0,  _PX.y * 2.0 * _Border)).a * _Tint;

        float _Edge1  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _Edge2 = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    return lerp(_Color * 0.5, float3(1.0, 1.0, 1.0), _Edge1 * _Alpha) + _Edge2 * 0.25;
}

float Fun_Random(float2 In)
{
    return frac(sin(dot(In, float2(12.9898, 78.233))) * 43758.5453);
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float _Rand = Fun_Random(In.texCoord + _Render_Texture.rb + _Render_Texture.bg + _Render_Background.rg + _Render_Background.br);

            float _Lum = Fun_Lum(_Render_Texture);
            float _Lum_Background = Fun_Lum(_Render_Background);

            float3 _Space = lerp(float3(0.0, 0.0, 0.0), float3(0.15, 0.05, 0.25), _Lum);
            _Space += (_Space * (S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + tan(_Lum) * _Lum * 0.25 - tan(_Lum_Background) * 0.25 - _Rand).rgb) * 1.5);
            _Space *= 0.5;

                float _Render_Background_Void_R = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.r * (1.0 - _Render_Texture.r) + _Rand) * 0.1).r;
                float _Render_Background_Void_G = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.g * (1.0 - _Render_Texture.g) + _Rand) * 0.1).b;
                float _Render_Background_Void_B = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.b * (1.0 - _Render_Texture.b) + _Rand) * 0.1).b;

                _Space = lerp(_Space, _Space + float3(_Render_Background_Void_R, _Render_Background_Void_G, _Render_Background_Void_B) * float3(0.15, 0.05, 0.25), 1.0 - _Lum);


            float4 _Result = _Render_Texture;
            _Result.rgb = lerp(_Render_Texture.rgb, _Space + pow(Fun_Random(In.texCoord + _Space.rb + _Space.bg + _Render_Background.rg + _Render_Background.br + _Rand), 255.0), _Mixing);
            _Result.rgb += (Fun_Outline(In.texCoord, _Space, In.Tint.a) + pow(_Lum, 6.0)) * saturate(_Mixing);

            float3 _Cosmos = pow(Fun_Random(In.texCoord), 128.0) * 0.5;
            _Result = lerp(float4(_Cosmos.rgb, 1.0), _Result, 1.0 - pow(Fun_OuterOutline(In.texCoord, In.Tint.a), 4.0));

            _Result = lerp(_Render_Texture, _Result, _Mixing);

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

    float _Rand = Fun_Random(In.texCoord + _Render_Texture.rb + _Render_Texture.bg + _Render_Background.rg + _Render_Background.br);

            float _Lum = Fun_Lum(_Render_Texture);
            float _Lum_Background = Fun_Lum(_Render_Background);

            float3 _Space = lerp(float3(0.0, 0.0, 0.0), float3(0.15, 0.05, 0.25), _Lum);
            _Space += (_Space * (S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + tan(_Lum) * _Lum * 0.25 - tan(_Lum_Background) * 0.25 - _Rand).rgb) * 1.5);
            _Space *= 0.5;

                float _Render_Background_Void_R = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.r * (1.0 - _Render_Texture.r) + _Rand) * 0.1).r;
                float _Render_Background_Void_G = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.g * (1.0 - _Render_Texture.g) + _Rand) * 0.1).b;
                float _Render_Background_Void_B = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Render_Background.b * (1.0 - _Render_Texture.b) + _Rand) * 0.1).b;

                _Space = lerp(_Space, _Space + float3(_Render_Background_Void_R, _Render_Background_Void_G, _Render_Background_Void_B) * float3(0.15, 0.05, 0.25), 1.0 - _Lum);


            float4 _Result = _Render_Texture;
            _Result.rgb = lerp(_Render_Texture.rgb, _Space + pow(Fun_Random(In.texCoord + _Space.rb + _Space.bg + _Render_Background.rg + _Render_Background.br + _Rand), 255.0), _Mixing);
            _Result.rgb += (Fun_Outline(In.texCoord, _Space, In.Tint.a) + pow(_Lum, 6.0)) * saturate(_Mixing);

            float3 _Cosmos = pow(Fun_Random(In.texCoord), 128.0) * 0.5;
            _Result = lerp(float4(_Cosmos.rgb, 1.0), _Result, 1.0 - pow(Fun_OuterOutline(In.texCoord, In.Tint.a), 4.0));

            _Result = lerp(_Render_Texture, _Result, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}