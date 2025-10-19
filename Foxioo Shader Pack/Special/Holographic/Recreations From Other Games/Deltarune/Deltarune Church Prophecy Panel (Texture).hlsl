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

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

Texture2D<float4> S2D_Texture : register(t1);
SamplerState S2D_TextureSampler : register(s1);


/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool __;
    float _PosX;
    float _PosY;
    float _PosXEcho;
    float _PosYEcho;
    bool ___;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ____;
    float _Mixing;
    Texture2D _Texture;
    bool _Color;
    float4 _ColorLight;
    float4 _ColorShadow;
    bool _____;

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

float Fun_Lum (float4 _Result) { return 0.2126 * _Result.r + 0.7152 * _Result.g + 0.0722 * _Result.b; }

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    /* Main Overlay */
        float2 _UV = ((In.texCoord * 0.0025 + float2(_PosX, _PosY)) / float2(fPixelWidth, fPixelHeight)) * float2(_ScaleX, _ScaleY) * _Scale;
        _UV = frac(_UV);

            float4 _Result = S2D_Texture.Sample(S2D_TextureSampler, _UV);
            float _Lum = Fun_Lum(_Result);
            _Result.a = _Render_Texture.a;

            /* Sub Texture 1 */
            float4 _Echo1 = S2D_Texture.Sample(S2D_TextureSampler, _UV) * S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXEcho, _PosYEcho) * float2(fPixelWidth, fPixelHeight))) * In.Tint;
                _Echo1.a = Fun_Lum(_Echo1);
                _Result += _Echo1;

            /* Sub Texture 2 */
            float4 _Echo2 = S2D_Texture.Sample(S2D_TextureSampler, _UV) * S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXEcho * 2.0, _PosYEcho * 2.0) * float2(fPixelWidth, fPixelHeight))) * In.Tint;
                _Echo2.a = Fun_Lum(_Echo2);
                _Result += _Echo2 * 0.5;

        /* End */
        if(_Color) _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Lum);

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
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    /* Main Overlay */
        float2 _UV = ((In.texCoord * 0.0025 + float2(_PosX, _PosY)) / float2(fPixelWidth, fPixelHeight)) * float2(_ScaleX, _ScaleY) * _Scale;
        _UV = frac(_UV);

            float4 _Result = Demultiply(S2D_Texture.Sample(S2D_TextureSampler, _UV));
            float _Lum = Fun_Lum(_Result);
            _Result.a = _Render_Texture.a;

            /* Sub Texture 1 */
            float4 _Echo1 = Demultiply(S2D_Texture.Sample(S2D_TextureSampler, _UV)) * Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXEcho, _PosYEcho) * float2(fPixelWidth, fPixelHeight)))) * In.Tint;
                _Echo1.a = Fun_Lum(_Echo1);
                _Result += _Echo1;

            /* Sub Texture 2 */
            float4 _Echo2 = Demultiply(S2D_Texture.Sample(S2D_TextureSampler, _UV)) * Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord + (float2(_PosXEcho * 2.0, _PosYEcho * 2.0) * float2(fPixelWidth, fPixelHeight)))) * In.Tint;
                _Echo2.a = Fun_Lum(_Echo2);
                _Result += _Echo2 * 0.5;

        /* End */
        if(_Color) _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Lum);

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}