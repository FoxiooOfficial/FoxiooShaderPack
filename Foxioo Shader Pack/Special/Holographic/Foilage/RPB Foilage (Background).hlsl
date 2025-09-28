/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (12.08.2025) */
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

        float4 _Result = _Render_Background * float4(0.1, 1.0, 1.0, 1.0);

            float3 _Render = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + sin(Fun_Luminance(_Render_Texture.rgb + _Render_Background.rgb) * 3.14 + Fun_Luminance(_Render_Background.rgb) + Fun_Luminance(_Render_Texture.rgb)) * 0.05).rgb * In.Tint.rgb;

            const float3 _ColorR = float3(255.0, 70.0, 0.0) / 255;
            const float3 _ColorG = float3(128.0, 255.0, 132.0) / 255;
            const float3 _ColorB = float3(128.0, 0.0, 132.0) / 255;

            float3      _RenderO = lerp(_Render.rgb, _ColorR,  _Render.r * _Render.r);
                        _RenderO = lerp(_RenderO.rgb, _ColorG, _Render.g * _Render.g);
                        _RenderO = lerp(_RenderO.rgb, _ColorB, _Render.b * _Render.b);

            _Result.rgb = lerp(_Result.rgb, _RenderO.rgb * 1.2 + (_Result.rgb * _Render_Texture.rgb) * 0.78, Fun_Luminance(_Render.rgb));
            _Result.rgb += lerp(_Result.rgb, _RenderO, Fun_Luminance(_Render.rgb) * 1.5) * 0.25 * Fun_Luminance(_Render.rgb);

            _Result.rgb *= saturate(_Result.rgb + 0.5);

            _Result.rgb = lerp(_Render_Texture.rgb,  _Result.rgb, _Mixing); 
        
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

        float4 _Result = _Render_Background * float4(0.1, 1.0, 1.0, 1.0);

            float3 _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + sin(Fun_Luminance(_Render_Texture.rgb + _Render_Background.rgb) * 3.14 + Fun_Luminance(_Render_Background.rgb) + Fun_Luminance(_Render_Texture.rgb)) * 0.05)).rgb * In.Tint.rgb;

            const float3 _ColorR = float3(255.0, 70.0, 0.0) / 255;
            const float3 _ColorG = float3(128.0, 255.0, 132.0) / 255;
            const float3 _ColorB = float3(128.0, 0.0, 132.0) / 255;

            float3      _RenderO = lerp(_Render.rgb, _ColorR,  _Render.r * _Render.r);
                        _RenderO = lerp(_RenderO.rgb, _ColorG, _Render.g * _Render.g);
                        _RenderO = lerp(_RenderO.rgb, _ColorB, _Render.b * _Render.b);

            _Result.rgb = lerp(_Result.rgb, _RenderO.rgb * 1.2 + (_Result.rgb * _Render_Texture.rgb) * 0.78, Fun_Luminance(_Render.rgb));
            _Result.rgb += lerp(_Result.rgb, _RenderO, Fun_Luminance(_Render.rgb) * 1.5) * 0.25 * Fun_Luminance(_Render.rgb);

            _Result.rgb *= saturate(_Result.rgb + 0.5);

            _Result.rgb = lerp(_Render_Texture.rgb,  _Result.rgb, _Mixing); 

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}