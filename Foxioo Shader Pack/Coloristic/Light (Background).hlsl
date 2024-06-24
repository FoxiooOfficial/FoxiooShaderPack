/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.5 (21.06.2024) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D__Render_Backgroundr : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Threshold;
    float _Mixing_Brightness;
    float _Brightness;
    float _Mixing;
    float _Alpha;
    bool __;
};

cbuffer PS_PIXELSIZE : register(b1)
{
    float fPixelWidth;
    float fPixelHeight;
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

PS_OUTPUT ps_main(PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D__Render_Backgroundr, In.texCoord);

    _Render_Texture.rgb *= _Alpha * In.Tint.a;

    float4 _Result = _Render_Texture;
    _Result.rgb *= _Brightness + (_Render_Background.rgb * _Mixing_Brightness);
    _Result.rgb += 1;

    if (_Result.a > _Threshold)
    {
        float _Alpha_Temp = ((_Result.r + _Result.g + _Result.b) / 3.0 - _Threshold) / (1.0 - _Threshold);
        float4 _Lerp = lerp(_Render_Background, float4(1, 1, 1, _Result.a * 2), _Alpha_Temp);
        _Result.rgb *= _Lerp.rgb;
    }
 
    _Result.rgb *= (_Render_Texture.rgb * _Mixing * In.Tint.rgb) + _Render_Background.rgb;

    _Result.a = _Render_Texture.a * _Alpha * In.Tint.a;

        //_Result += pow(_Render_Texture * In.Tint, 2);

    Out.Color = _Result;

    return Out;
}