/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (14.09.2025) */
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

Texture2D<float4> S2D_Texture_B : register(t2);
SamplerState S2D_Texture_BSampler : register(s2);

Texture2D<float4> S2D_Texture_C : register(t3);
SamplerState S2D_Texture_CSampler : register(s3);

Texture2D<float4> S2D_Texture_D : register(t4);
SamplerState S2D_Texture_DSampler : register(s4);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    bool _B_Mode;
    float _B;
    Texture2D _Texture_B;
    bool _C_Mode;
    float _C;
    Texture2D _Texture_C;
    bool _D_Mode;
    float _D;
    Texture2D _Texture_D;
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Render = _Result;

        /* (A - B) * C + D */
        //_Render =  _A_Mode ? tex2D(S2D_A, In) : _A;
        _Render -= _B_Mode ? S2D_Texture_B.Sample(S2D_Texture_BSampler, In.texCoord) * _B : _B;
        _Render *= _C_Mode ? S2D_Texture_C.Sample(S2D_Texture_CSampler, In.texCoord) * _C : _C;
        _Render += _D_Mode ? S2D_Texture_D.Sample(S2D_Texture_DSampler, In.texCoord) * _B : _D;

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing); 
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
        float4 _Render = _Result;

        /* (A - B) * C + D */
        //_Render =  _A_Mode ? tex2D(S2D_A, In) : _A;
        _Render -= _B_Mode ? S2D_Texture_B.Sample(S2D_Texture_BSampler, In.texCoord) * _B : _B;
        _Render *= _C_Mode ? S2D_Texture_C.Sample(S2D_Texture_CSampler, In.texCoord) * _C : _C;
        _Render += _D_Mode ? S2D_Texture_D.Sample(S2D_Texture_DSampler, In.texCoord) * _B : _D;

        _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;
    
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
