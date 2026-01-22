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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float _Lum = Fun_Luminance(_Render_Texture.rgb);
        float _LumBg = Fun_Luminance(_Render_Background.rgb);
        float _Render_Texture_Lum = Fun_Luminance(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Lum * 0.1 - _LumBg * 0.0025)).rgb);

        float2 CD = In.texCoord - 0.5 - _Lum * 0.1;
        float _Dist = length(CD);
        CD = smoothstep(0.5, 0, length(float2(CD.x - 0.5, CD.y)) * 0.1 + cos(CD.y) * 0.1);
        CD = frac(CD / 2.0);
        CD = abs(CD * 2.0 - 1.0);
        
        static const float _Frag = 6.28318;
        float4 _CDOffset = float4(
            sin(_Frag * CD.x + CD.y) * 0.5 + 0.5, 
            sin(_Frag * CD.x + CD.y + 2.0) * 0.5 + 0.5,
            sin(_Frag * CD.x + CD.y + 4.0) * 0.5 + 0.5, 
            1);

            float4 _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + CD * 0.1);
            _Result.rgb = lerp(float3(0.529, 0.541, 0.568) * _Result.rgb * 0.15, float3(0.529, 0.541, 0.568) + _Result.rgb * 0.5, Fun_Luminance(_Result.rgb));
            _Result.rgb = lerp(_Result.rgb, _Render_Texture_Lum * 0.5, 0.95 + _Lum * 0.05);

        float3 _CDRainbow = float3(
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg))) * 0.5 + 0.5, 
            sin(_Frag * atan(((In.texCoord.x + In.texCoord.y) + (CD.x - CD.y) * 0.1 - _LumBg) * 1.2) + 2.0) * 0.5 + 0.5,
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg) * 1.4) + 4.0) * 0.5 + 0.5
            );

            _Result.rgb += _CDRainbow * 0.1;

        float _OrFreq = lerp(300.0, 1000.0, _Dist * _LumBg);
        float _OrPtr = sin(_Dist * _OrFreq) * 0.5 + 0.5;
        _OrPtr = smoothstep(0.3, 0.7, _OrPtr);

                float _Angle = atan2((In.texCoord.y + _OrPtr * 0.01) - 0.5, (In.texCoord.x + _OrPtr * 0.01) - 0.5);
                float _RayPattern = abs(sin(_Angle + (1.0 - (_LumBg - _Lum))));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, 0.5 * saturate(_RayPattern * _Lum * 0.25 * abs(_LumBg - atan2((In.texCoord.y + _OrPtr * 0.01), _LumBg - (In.texCoord.x + _OrPtr * 0.01)))));
                
                    _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 2.0);

                _RayPattern = abs(sin(_Angle * 2 + (_LumBg - _Lum)));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, saturate(_RayPattern * _Lum * 0.25 * abs(atan2((_OrPtr * 0.01 - CD.y), (_OrPtr * 0.01 - CD.x)))));

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 3.0);

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb * 1.5 * _Dist, _OrPtr * 0.05);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

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

        float _Lum = Fun_Luminance(_Render_Texture.rgb);
        float _LumBg = Fun_Luminance(_Render_Background.rgb);
        float _Render_Texture_Lum = Fun_Luminance(Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Lum * 0.1 - _LumBg * 0.0025))).rgb);

        float2 CD = In.texCoord - 0.5 - _Lum * 0.1;
        float _Dist = length(CD);
        CD = smoothstep(0.5, 0, length(float2(CD.x - 0.5, CD.y)) * 0.1 + cos(CD.y) * 0.1);
        CD = frac(CD / 2.0);
        CD = abs(CD * 2.0 - 1.0);
        
        static const float _Frag = 6.28318;
        float4 _CDOffset = float4(
            sin(_Frag * CD.x + CD.y) * 0.5 + 0.5, 
            sin(_Frag * CD.x + CD.y + 2.0) * 0.5 + 0.5,
            sin(_Frag * CD.x + CD.y + 4.0) * 0.5 + 0.5, 
            1);

            float4 _Result = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + CD * 0.1);
            _Result.rgb = lerp(float3(0.529, 0.541, 0.568) * _Result.rgb * 0.15, float3(0.529, 0.541, 0.568) + _Result.rgb * 0.5, Fun_Luminance(_Result.rgb));
            _Result.rgb = lerp(_Result.rgb, _Render_Texture_Lum * 0.5, 0.95 + _Lum * 0.05);

        float3 _CDRainbow = float3(
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg))) * 0.5 + 0.5, 
            sin(_Frag * atan(((In.texCoord.x + In.texCoord.y) + (CD.x - CD.y) * 0.1 - _LumBg) * 1.2) + 2.0) * 0.5 + 0.5,
            sin(_Frag * atan(((In.texCoord.x - In.texCoord.y) + (CD.x + CD.y) * 0.1 - _LumBg) * 1.4) + 4.0) * 0.5 + 0.5
            );

            _Result.rgb += _CDRainbow * 0.1;

        float _OrFreq = lerp(300.0, 1000.0, _Dist * _LumBg);
        float _OrPtr = sin(_Dist * _OrFreq) * 0.5 + 0.5;
        _OrPtr = smoothstep(0.3, 0.7, _OrPtr);

                float _Angle = atan2((In.texCoord.y + _OrPtr * 0.01) - 0.5, (In.texCoord.x + _OrPtr * 0.01) - 0.5);
                float _RayPattern = abs(sin(_Angle + (1.0 - (_LumBg - _Lum))));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, 0.5 * saturate(_RayPattern * _Lum * 0.25 * abs(_LumBg - atan2((In.texCoord.y + _OrPtr * 0.01), _LumBg - (In.texCoord.x + _OrPtr * 0.01)))));
                
                    _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 2.0);

                _RayPattern = abs(sin(_Angle * 2 + (_LumBg - _Lum)));
                _RayPattern = smoothstep(0.0, 3.0 * _Lum, saturate(_RayPattern * _Lum * 0.25 * abs(atan2((_OrPtr * 0.01 - CD.y), (_OrPtr * 0.01 - CD.x)))));

                _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb + _CDRainbow.rgb * 1.2, _RayPattern * 3.0);

        _Result.rgb = lerp(_Result.rgb, _Result.rgb + _CDOffset.rgb * 1.5 * _Dist, _OrPtr * 0.05);

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}