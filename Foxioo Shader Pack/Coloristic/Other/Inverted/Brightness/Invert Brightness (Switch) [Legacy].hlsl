/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.7 (18.10.2025) */
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

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;
    
    float4 _Result = 0;
    float4 _Render = 0;
        
        if(_Blending_Mode == 0)
        {
            _Result.r = (1 - (_Render_Texture.g + (_Render_Texture.b - _Render_Texture.r))) + ((_Mixing - 1) * _Render_Texture.r);
            _Result.g = (1 - (_Render_Texture.b + (_Render_Texture.r - _Render_Texture.g))) + ((_Mixing - 1) * _Render_Texture.g);
            _Result.b = (1 - (_Render_Texture.r + (_Render_Texture.g - _Render_Texture.b))) + ((_Mixing - 1) * _Render_Texture.b);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.r = (1 - (_Render_Background.g + (_Render_Background.b - _Render_Background.r))) + ((_Mixing - 1) * _Render_Background.r);
            _Result.g = (1 - (_Render_Background.b + (_Render_Background.r - _Render_Background.g))) + ((_Mixing - 1) * _Render_Background.g);
            _Result.b = (1 - (_Render_Background.r + (_Render_Background.g - _Render_Background.b))) + ((_Mixing - 1) * _Render_Background.b);
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
            _Result.r = (1 - (_Render_Texture.g + (_Render_Texture.b - _Render_Texture.r))) + ((_Mixing - 1) * _Render_Texture.r);
            _Result.g = (1 - (_Render_Texture.b + (_Render_Texture.r - _Render_Texture.g))) + ((_Mixing - 1) * _Render_Texture.g);
            _Result.b = (1 - (_Render_Texture.r + (_Render_Texture.g - _Render_Texture.b))) + ((_Mixing - 1) * _Render_Texture.b);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.r = (1 - (_Render_Background.g + (_Render_Background.b - _Render_Background.r))) + ((_Mixing - 1) * _Render_Background.r);
            _Result.g = (1 - (_Render_Background.b + (_Render_Background.r - _Render_Background.g))) + ((_Mixing - 1) * _Render_Background.g);
            _Result.b = (1 - (_Render_Background.r + (_Render_Background.g - _Render_Background.b))) + ((_Mixing - 1) * _Render_Background.b);
            _Render = _Render_Background;
        }

    _Result.a = _Render_Texture.a;
    _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}