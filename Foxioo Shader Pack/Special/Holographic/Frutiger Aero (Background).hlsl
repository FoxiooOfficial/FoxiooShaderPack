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
    float4 _ColorLight;
    float4 _Color;
    float4 _ColorShadow;
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

float Fun_Lum (float4 _Result) { return (0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b); }

float3 Fun_Outline(float2 In, float3 _Color, float _Tint)
{
    float2 _PX = float2(fPixelWidth, fPixelHeight);
    float _Alpha = S2D_Image.Sample(S2D_ImageSampler, In).a * _Tint;

    float aL1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x, 0.0)).a * _Tint;
    float aR1 = S2D_Image.Sample(S2D_ImageSampler, In + float2( _PX.x, 0.0)).a * _Tint;
    float aU1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0, -_PX.y)).a * _Tint;
    float aD1 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0,  _PX.y)).a * _Tint;

    float aL2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(-_PX.x * 2.0, 0.0)).a * _Tint;
    float aR2 = S2D_Image.Sample(S2D_ImageSampler, In + float2( _PX.x * 2.0, 0.0)).a * _Tint;
    float aU2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0, -_PX.y * 2.0)).a * _Tint;
    float aD2 = S2D_Image.Sample(S2D_ImageSampler, In + float2(0.0,  _PX.y * 2.0)).a * _Tint;

        float _Edge1  = step(0.01, abs(aL1 - _Alpha) + abs(aR1 - _Alpha) + abs(aU1 - _Alpha) + abs(aD1 - _Alpha));
        float _Edge2 = step(0.01, abs(aL2 - _Alpha) + abs(aR2 - _Alpha) + abs(aU2 - _Alpha) + abs(aD2 - _Alpha));

    return lerp(_Color, _Color + _Color * 0.25, _Edge1 * _Alpha) + _Edge2 * 0.15;
}


PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float _Lum = pow(Fun_Lum(_Render_Texture), 2);
        float _Lum_Background = pow(Fun_Lum(_Render_Background), 2);

        float4 _Result;

            _Result.rgb = lerp(_ColorShadow.rgb, lerp(_ColorLight.rgb, _Color.rgb, _Lum * _Lum), _Lum);

                float2 _Center_Off = float2(0.5, 1.0 - 0.2);
                float2 _Center = float2(0.5, 0.5);

                float _Dist = distance(In.texCoord, _Center_Off);
                float _Dist_Cen = distance(In.texCoord, _Center);

                        _Result.rgb += saturate(1.0 - (_Dist / 0.25)) * 0.15;
                        _Result.rgb += saturate(1.0 - (_Dist / 0.75)) * 0.35;

                    _Result.rgb += saturate((_Dist_Cen / 0.75)) * 0.15;

                    /* Arc */
                        float _Inside = step(_Dist, 0.75);

                        float _Arc_Out = smoothstep(0.75 + 0.15, 0.75, _Dist);
                        _Result.rgb += _Arc_Out * (1.0 - _Inside) * 0.15;

                        float _Arc_In = smoothstep(0.75 - 0.4, 0.75, _Dist);
                        _Result.rgb += _Arc_In * (_Inside) * 0.15;

                    _Result.rgb = (Fun_Outline(In.texCoord, _Result.rgb, In.Tint.a));

                float _Lum_Aero = Fun_Lum(float4(_Result.rgb, 1.0));
                float4 _Render_Background_Ex = (S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Lum_Aero * 0.25) + 0.125));

            _Result.rgb += _Render_Background_Ex.rgb * _Lum * _Lum;
            _Result.rgb = lerp(_Result.rgb, _Result.rgb * _Result.rgb * lerp(1.0, _Result.rgb * _Lum, 0.5), 0.85);

        _Result.a = _Render_Texture.a;
        _Result = lerp(_Render_Texture, _Result * lerp(1.0, _Lum, 0.1 * (1.0 - _Lum)), _Mixing);

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

        float _Lum = pow(Fun_Lum(_Render_Texture), 2);
        float _Lum_Background = pow(Fun_Lum(_Render_Background), 2);

        float4 _Result;

            _Result.rgb = lerp(_ColorShadow.rgb, lerp(_ColorLight.rgb, _Color.rgb, _Lum * _Lum), _Lum);

                float2 _Center_Off = float2(0.5, 1.0 - 0.2);
                float2 _Center = float2(0.5, 0.5);

                float _Dist = distance(In.texCoord, _Center_Off);
                float _Dist_Cen = distance(In.texCoord, _Center);

                        _Result.rgb += saturate(1.0 - (_Dist / 0.25)) * 0.15;
                        _Result.rgb += saturate(1.0 - (_Dist / 0.75)) * 0.35;

                    _Result.rgb += saturate((_Dist_Cen / 0.75)) * 0.15;

                    /* Arc */
                        float _Inside = step(_Dist, 0.75);

                        float _Arc_Out = smoothstep(0.75 + 0.15, 0.75, _Dist);
                        _Result.rgb += _Arc_Out * (1.0 - _Inside) * 0.15;

                        float _Arc_In = smoothstep(0.75 - 0.4, 0.75, _Dist);
                        _Result.rgb += _Arc_In * (_Inside) * 0.15;

                    _Result.rgb = Fun_Outline(In.texCoord, _Result.rgb, In.Tint.a);

                float _Lum_Aero = Fun_Lum(float4(_Result.rgb, 1.0));
                float4 _Render_Background_Ex = (S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Lum_Aero * 0.25) + 0.125));

            _Result.rgb += _Render_Background_Ex.rgb * _Lum * _Lum;
            _Result.rgb = lerp(_Result.rgb, _Result.rgb * _Result.rgb * lerp(1.0, _Result.rgb * _Lum, 0.5), 0.85);

        _Result.a = _Render_Texture.a;
        _Result = lerp(_Render_Texture, _Result * lerp(1.0, _Lum, 0.1 * (1.0 - _Lum)), _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}