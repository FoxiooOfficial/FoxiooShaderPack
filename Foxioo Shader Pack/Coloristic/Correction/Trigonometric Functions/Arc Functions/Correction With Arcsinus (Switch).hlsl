/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.4 (18.10.2025) */
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
    float _Mul;
    bool __;
	bool _Is_Pre_296_Build;
	int _Render_Switch;
	bool ___;
};


struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
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

#define M_PI 3.14159265359

float3 Fun_Asin(float3 _Color, int _Case)
{   
    float3 _Render = asin(_Color);

    if(_Case == 0) // Native
        return _Render;

    else if(_Case == 1) // D3D9
    { 
        float a = -1.0 / M_PI * 1.07596;
        float p = -M_PI;

        if(any(_Color < -1.0))
            return a * pow((_Color - p), 2.0);

        else if(any(_Color > 1.0))
            return -a * pow((-_Color - p), 2.0);

        else
            return _Render;
    }

    else if(_Case == 2) // D3D11, OGL
        return (any(abs(_Render > 1.0))) ? _Color <= 1.0f : _Render;

    else return float3(0.0f, 0.0f, 0.0f);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = 0;
        float4 _Render;

        if(_Blending_Mode == 0)
        {
            _Result.rgb = Fun_Asin(_Render_Texture.rgb * _Mul, _Render_Switch);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = Fun_Asin(_Render_Background.rgb * _Mul, _Render_Switch);
            _Render = _Render_Background;
        }

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

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = 0;
        float4 _Render;

        if(_Blending_Mode == 0)
        {
            _Result.rgb = Fun_Asin(_Render_Texture.rgb * _Mul, _Render_Switch);
            _Render = _Render_Texture;
        }
        else
        {
            _Result.rgb = Fun_Asin(_Render_Background.rgb * _Mul, _Render_Switch);
            _Render = _Render_Background;
        }

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
