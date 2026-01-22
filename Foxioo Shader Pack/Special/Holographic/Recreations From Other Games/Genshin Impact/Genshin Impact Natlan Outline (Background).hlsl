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
    bool __;
    float _PosX;
    float _PosY;    
    bool ___;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ____;
    float _Mixing;
    float _Alpha;
    float _Offset;
    float _OffsetDistortion;
    float _Seed;
    float4 _ColorLight; 
    float4 _Color; 
    float4 _ColorShadow; 
    bool _____;
	bool _Is_Pre_296_Build;
    bool ______;
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

static const float2 _OffsetEx[8] = 
{
    float2(-1.0,  0.0),
    float2( 1.0,  0.0),
    float2( 0.00001, -1.0),
    float2( 0.00001,  1.0),

    float2(-1.0, -1.0),
    float2(-1.0,  1.0),
    float2( 1.0, -1.0),
    float2( 1.0,  1.0) 
};

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos)
{
    float2 _I = floor(_Pos + _Seed);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float3 Fun_NoiseGradient(float2 _UV, float3 _Color_1, float3 _Color_2, float3 _Color_3)
{
    float _Noise = Fun_Noise(_UV * 4.0);

    float3 _Render_1  = lerp(_Color_1, _Color_2, smoothstep(0.0, 0.5, _Noise));
    float3 _Render_2 = lerp(_Render_1, _Color_3, smoothstep(0.5, 1.0, _Noise));

    return _Render_2;
}

float3 Fun_NoiseSat(float3 _Color, float _Sat)
{
    float _Lum = dot(_Color, float3(0.299, 0.587, 0.114));

    return lerp(float3(_Lum, _Lum, _Lum), _Color, _Sat);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = (In.texCoord + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = _Color;

            _Result.rgb = Fun_NoiseGradient(_UV, _Color.rgb, _ColorShadow.rgb, _ColorLight.rgb);

                float _Noise = Fun_Noise(_UV * 8.0);     float _Sat = lerp(0.5, 2.5, _Noise);
                _Result.rgb = Fun_NoiseSat(_Result.rgb, _Sat);

                    float _Mask = _Render_Texture.a;

                    for (int i = 0; i < 8; i++)
                    {
                        _Mask += S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _OffsetEx[i] * float2(fPixelWidth, fPixelHeight) * (_Offset + sin(In.texCoord + _Noise) * _OffsetDistortion)).a * In.Tint.a;
                        _Mask = saturate(_Mask);
                    }
                
                    _Result.a = _Mask;

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, _Mixing);
                float4 _Render = lerp(_Result, _Render_Texture, _Render_Texture.a * _Alpha);

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = (In.texCoord + float2(_PosX, _PosY)) * float2(_ScaleX, _ScaleY) * _Scale; 
        float4 _Result = _Color;

            _Result.rgb = Fun_NoiseGradient(_UV, _Color.rgb, _ColorShadow.rgb, _ColorLight.rgb);

                float _Noise = Fun_Noise(_UV * 8.0);     float _Sat = lerp(0.5, 2.5, _Noise);
                _Result.rgb = Fun_NoiseSat(_Result.rgb, _Sat);

                    float _Mask = _Render_Texture.a;

                    for (int i = 0; i < 8; i++)
                    {
                        _Mask += S2D_Image.Sample(S2D_ImageSampler, In.texCoord + _OffsetEx[i] * float2(fPixelWidth, fPixelHeight) * (_Offset + sin(In.texCoord + _Noise) * _OffsetDistortion)).a * In.Tint.a;
                        _Mask = saturate(_Mask);
                    }
                
                    _Result.a = _Mask;

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _Render_Background.rgb, _Mixing);
                float4 _Render = lerp(_Result, _Render_Texture, _Render_Texture.a * _Alpha);

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}