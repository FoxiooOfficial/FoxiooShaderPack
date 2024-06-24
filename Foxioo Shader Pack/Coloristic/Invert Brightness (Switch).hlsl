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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;
    
        float4 _Result;
        
        if(_Blending_Mode == 0)
        {
            _Result.r = (1 - (_Render_Texture.g + (_Render_Texture.b - _Render_Texture.r))) + (_Mixing * _Render_Texture.r);
            _Result.g = (1 - (_Render_Texture.b + (_Render_Texture.r - _Render_Texture.g))) + (_Mixing * _Render_Texture.g);
            _Result.b = (1 - (_Render_Texture.r + (_Render_Texture.g - _Render_Texture.b))) + (_Mixing * _Render_Texture.b);
        }
        else
        {
            _Result.r = (1 - (_Render_Background.g + (_Render_Background.b - _Render_Background.r))) + (_Mixing * _Render_Background.r);
            _Result.g = (1 - (_Render_Background.b + (_Render_Background.r - _Render_Background.g))) + (_Mixing * _Render_Background.g);
            _Result.b = (1 - (_Render_Background.r + (_Render_Background.g - _Render_Background.b))) + (_Mixing * _Render_Background.b);
        }

        _Result.a = _Render_Texture.a;

    Out.Color = _Result;

    return Out;
}
