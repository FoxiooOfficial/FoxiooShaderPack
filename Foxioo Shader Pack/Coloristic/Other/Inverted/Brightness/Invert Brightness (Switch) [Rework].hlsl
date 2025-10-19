/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.8 (18.10.2025) */
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

/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Lum(float3 _Render)
{
    float Y = 0.299     * _Render.r + 0.587      *_Render.g + 0.114     * _Render.b;
    float U = -0.14713  * _Render.r - 0.28886   * _Render.g + 0.436     * _Render.b;
    float V =  0.615    * _Render.r - 0.51499   * _Render.g - 0.10001   * _Render.b;
    Y = 1.0 - Y;

    float3 _Result;
        _Result.r = Y + 1.13983 * V;
        _Result.g = Y - 0.39465 * U - 0.58060 * V;
        _Result.b = Y + 2.03211 * U;

    return saturate(_Result);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;
    
    float4 _Result = 0;
    float4 _Render = 0;
        
        if(_Blending_Mode == 0)
        {
            _Result.rgb = Fun_Lum(_Render_Texture.rgb);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = Fun_Lum(_Render_Background.rgb);
            _Render = _Render_Background;
        }


    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;
    
    float4 _Result = 0;
    float4 _Render = 0;
        
        if(_Blending_Mode == 0)
        {
            _Result.rgb = Fun_Lum(_Render_Texture.rgb);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = Fun_Lum(_Render_Background.rgb);
            _Render = _Render_Background;
        }

    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}