/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (05.04.2026) */
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
	float2 bgCoord : TEXCOORD1;
    float4 Position : SV_POSITION;
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture;
    float4 _Render_Background;

    uint2 _Pixel = float2((uint)(In.texCoord.x / fPixelWidth), (uint)(In.texCoord.y / fPixelHeight));

        float4 _Result = 0.0;
    
            _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(fPixelWidth, fPixelHeight)) * In.Tint;
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(fPixelWidth, fPixelHeight));
            float4 _RenderOff2 = _Blending_Mode ? _Render_Background : _Render_Texture;

            _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
            float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

            /* x-axis */
            if ((_Pixel.x % 3) == 0)    _Result.rgb = float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.x % 3) == 1)    _Result.rgb = float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb = float3(_RenderOff2.r, 0.0, _Render.b);

            /* y-axis */
            if ((_Pixel.y % 3) == 0)    _Result.rgb += float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.y % 3) == 1)    _Result.rgb += float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb += float3(_RenderOff2.r, 0.0, _Render.b);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
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

    float4 _Render_Texture;
    float4 _Render_Background;

    uint2 _Pixel = float2((uint)(In.texCoord.x / fPixelWidth), (uint)(In.texCoord.y / fPixelHeight));

        float4 _Result = 0.0;
    
            _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + float2(fPixelWidth, fPixelHeight))) * In.Tint;
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + float2(fPixelWidth, fPixelHeight));
            float4 _RenderOff2 = _Blending_Mode ? _Render_Background : _Render_Texture;

            _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint);            
            _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
            float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

            /* x-axis */
            if ((_Pixel.x % 3) == 0)    _Result.rgb = float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.x % 3) == 1)    _Result.rgb = float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb = float3(_RenderOff2.r, 0.0, _Render.b);

            /* y-axis */
            if ((_Pixel.y % 3) == 0)    _Result.rgb += float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.y % 3) == 1)    _Result.rgb += float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb += float3(_RenderOff2.r, 0.0, _Render.b);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}