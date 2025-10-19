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
    bool _Blending_Mode;
    float _Mixing;
    float _Emboss_Size;
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
    float4 Color : SV_Target;
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

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _Off = _Emboss_Size * float2(fPixelWidth, fPixelHeight);
    float _Scale = _Mixing * max(1.0, _Emboss_Size);
    
        float2 _Emboss;

    if(_Blending_Mode == 0)
    {
        float3 _NW = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,  -_Off.y)).rgb * In.Tint.rgb;
        float3 _N  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0.0,      -_Off.y)).rgb * In.Tint.rgb;
        float3 _NE = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,  -_Off.y)).rgb * In.Tint.rgb;
        float3 _W  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,   0.0))   .rgb * In.Tint.rgb;
        float3 _C  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord)                            .rgb * In.Tint.rgb;
        float3 _E  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,   0.0))   .rgb * In.Tint.rgb;
        float3 _SW = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,  _Off.y)) .rgb * In.Tint.rgb;
        float3 _S  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0.0,      _Off.y)) .rgb * In.Tint.rgb;
        float3 _SE = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,  _Off.y)) .rgb * In.Tint.rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }
    else
    {
        float3 _NW = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,  -_Off.y)).rgb;
        float3 _N  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0.0,      -_Off.y)).rgb;
        float3 _NE = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,  -_Off.y)).rgb;
        float3 _W  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,   0.0))   .rgb;
        float3 _C  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord)                            .rgb;
        float3 _E  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,   0.0))   .rgb;
        float3 _SW = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,  _Off.y)) .rgb;
        float3 _S  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0.0,      _Off.y)) .rgb;
        float3 _SE = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }

            float _Diff = (_Emboss.x + _Emboss.y) * 0.5;
            float _Render_Emboss = saturate(0.5 + _Diff * _Scale);

        _Result.rgb = lerp(_Result.rgb, float3(_Render_Emboss, _Render_Emboss, _Render_Emboss), clamp(abs(_Mixing), 0.0, 1.0));
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

    float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;

    float2 _Off = _Emboss_Size * float2(fPixelWidth, fPixelHeight);
    float _Scale = _Mixing * max(1.0, _Emboss_Size);
    
        float2 _Emboss;

    if(_Blending_Mode == 0)
    {
        float3 _NW = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,  -_Off.y)).rgb * In.Tint.rgb;
        float3 _N  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0.0,      -_Off.y)).rgb * In.Tint.rgb;
        float3 _NE = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,  -_Off.y)).rgb * In.Tint.rgb;
        float3 _W  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,   0.0))   .rgb * In.Tint.rgb;
        float3 _C  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord)                            .rgb * In.Tint.rgb;
        float3 _E  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,   0.0))   .rgb * In.Tint.rgb;
        float3 _SW = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(-_Off.x,  _Off.y)) .rgb * In.Tint.rgb;
        float3 _S  = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(0.0,      _Off.y)) .rgb * In.Tint.rgb;
        float3 _SE = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2( _Off.x,  _Off.y)) .rgb * In.Tint.rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }
    else
    {
        float3 _NW = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,  -_Off.y)).rgb;
        float3 _N  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0.0,      -_Off.y)).rgb;
        float3 _NE = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,  -_Off.y)).rgb;
        float3 _W  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,   0.0))   .rgb;
        float3 _C  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord)                            .rgb;
        float3 _E  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,   0.0))   .rgb;
        float3 _SW = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(-_Off.x,  _Off.y)) .rgb;
        float3 _S  = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(0.0,      _Off.y)) .rgb;
        float3 _SE = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2( _Off.x,  _Off.y)) .rgb;

        _Emboss.x = ( Fun_Luminance(_NE) + 2.0 * Fun_Luminance(_E) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_W) + Fun_Luminance(_SW) );
        _Emboss.y = ( Fun_Luminance(_SW) + 2.0 * Fun_Luminance(_S) + Fun_Luminance(_SE) ) - ( Fun_Luminance(_NW) + 2.0 * Fun_Luminance(_N) + Fun_Luminance(_NE) );
    }

            float _Diff = (_Emboss.x + _Emboss.y) * 0.5;
            float _Render_Emboss = saturate(0.5 + _Diff * _Scale);

        _Result.rgb = lerp(_Result.rgb, float3(_Render_Emboss, _Render_Emboss, _Render_Emboss), clamp(abs(_Mixing), 0.0, 1.0));
        _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
