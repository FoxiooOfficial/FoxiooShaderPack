/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (08.08.2024) */
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result, _Result_Sharpness;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;

            _Result_Sharpness = 5 * _Render_Texture - (
                S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            );
        }
        else
        {
            _Result = _Render_Background;

            _Result_Sharpness = 5 * _Render_Background - (
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            );
        }

        _Result = lerp(_Result, _Result_Sharpness, _Mixing);

    _Result.a *= _Render_Texture.a;

    Out.Color = _Result;

    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _color)
{
	float4 color = _color;
	if ( color.a != 0 )
		color.rgb /= color.a;
	return color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
        PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

    float4 _Result, _Result_Sharpness;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;

            _Result_Sharpness = 5 * _Render_Texture - (
                Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))) +
                Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))) +
                Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))) +
                Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))))
            );
        }
        else
        {
            _Result = _Render_Background;

            _Result_Sharpness = 5 * _Render_Background - (
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            );
        }

        _Result = lerp(_Result, _Result_Sharpness, _Mixing);

    _Result.a *= _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}
