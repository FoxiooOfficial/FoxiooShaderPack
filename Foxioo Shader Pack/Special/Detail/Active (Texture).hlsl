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

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Sharpness_Size;
    bool __;
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

float2 Fun_Border(float2 In, float2 _Size, float _Alpha)
{
    _Size *= float2(fPixelWidth, fPixelHeight) * _Sharpness_Size;

    float2 _Result;
    _Result.x = (
        S2D_Image.Sample(S2D_ImageSampler, (In + _Size) ).a * 2.0 +
        S2D_Image.Sample(S2D_ImageSampler, (In - _Size) ).a * 2.0 
    ) - _Alpha * 2.0;

    _Result.y = (
        S2D_Image.Sample(S2D_ImageSampler, (In + _Size) ).a * 2.0 +
        S2D_Image.Sample(S2D_ImageSampler, (In - _Size) ).a / 2.0 
    ) - _Alpha;

    return _Result;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Result;
    float2 _Result_Sharpness;

        //_Result_Sharpness = Fun_Border(In, 3.5, _Render_Texture.a);
        _Result.rgb = float3(0.0, 0.5, 0.5);// - _Result_Sharpness.x * 0.3999;
        
        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 5., _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-5., 5.), _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 4.95, _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 1.5));

        float2 _Result_Side_L = _Result_Sharpness;
        _Result_Sharpness = Fun_Border(In.texCoord, float2(-4.95, 4.95), _Render_Texture.a);
        float2 _Result_Side_R = _Result_Sharpness;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.5));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 2.0, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-2.0, 2.0), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0),  saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 1.85, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0) + _Result_Side_L.y * 0.1, saturate((1.0 - saturate(abs(_Result_Sharpness.x * 6.0))) - (_Result_Side_L.y * 0.4)));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-1.85, 1.85), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), 1.0 - saturate(abs(_Result_Sharpness.x * 6.0)));
        /* ############################# */

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a =  _Render_Texture.a;

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
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float4 _Result;
    float2 _Result_Sharpness;

        //_Result_Sharpness = Fun_Border(In, 3.5, _Render_Texture.a);
        _Result.rgb = float3(0.0, 0.5, 0.5);// - _Result_Sharpness.x * 0.3999;
        
        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 5., _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-5., 5.), _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 4.95, _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 1.5));

        float2 _Result_Side_L = _Result_Sharpness;
        _Result_Sharpness = Fun_Border(In.texCoord, float2(-4.95, 4.95), _Render_Texture.a);
        float2 _Result_Side_R = _Result_Sharpness;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.5));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 2.0, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-2.0, 2.0), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0),  saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In.texCoord, 1.85, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0) + _Result_Side_L.y * 0.1, saturate((1.0 - saturate(abs(_Result_Sharpness.x * 6.0))) - (_Result_Side_L.y * 0.4)));

        _Result_Sharpness = Fun_Border(In.texCoord, float2(-1.85, 1.85), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), 1.0 - saturate(abs(_Result_Sharpness.x * 6.0)));
        /* ############################# */

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a =  _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
