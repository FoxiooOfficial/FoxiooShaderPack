/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (23.06.2024) */
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);
    float4 _Result = _Render_Texture;

            if(_Blending_Mode == 0)
            {
                _Result.rgb = atan(((_Render_Background.rgb * _Mixing) / _Render_Texture.rgb) / 3.14159265359) * 2; 
            }
            else
            {
                _Result.rgb = atan((_Render_Texture.rgb / (_Render_Background.rgb * _Mixing)) / 3.14159265359) * 2; 
            }
    
    _Result.a *= _Render_Texture.a;

    Out.Color = _Result;

    return Out;
}
