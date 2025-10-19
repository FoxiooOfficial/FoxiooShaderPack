/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
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

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }

        _Result.rgb *= float3(0.02, 0.01, 0.5);
        _Result.r = lerp(0, 1, _Result.b / 2.0);

            float3 _ColorRed = float3(1.0, 0.2, 0.5);
                _Result.r += lerp(0, _ColorRed.r, (_Render.r - 0.75) / (1.0 - 0.75));

            float3 _ColorGreen = float3(0.6, 1, 0.1);
                _Result.g += lerp(0, _ColorGreen.g, (_Render.g - 0.75) / (1.0 - 0.75));

            float3 _ColorBlue = float3(0.2, 1, 0.8);
                _Result.b += lerp(0, _ColorBlue.b, (_Render.b - 0.75) / (1.0 - 0.75));

        _Result.rgb = pow(abs(_Result.rgb), 1.0 / 2.2); 

        _Result = lerp(_Render, _Result, _Mixing);
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

    float4 _Result, _Render;

        if (_Blending_Mode == 0)
        {   
            _Render = _Render_Texture; 
            _Result = _Render_Texture;
        }
        else
        {
            _Render = _Render_Background; 
            _Result = _Render_Background;
        }
    
        _Result.rgb *= float3(0.02, 0.01, 0.5);
        _Result.r = lerp(0, 1, _Result.b / 2.0);

            float3 _ColorRed = float3(1.0, 0.2, 0.5);
                _Result.r += lerp(0, _ColorRed.r, (_Render.r - 0.75) / (1.0 - 0.75));

            float3 _ColorGreen = float3(0.6, 1, 0.1);
                _Result.g += lerp(0, _ColorGreen.g, (_Render.g - 0.75) / (1.0 - 0.75));

            float3 _ColorBlue = float3(0.2, 1, 0.8);
                _Result.b += lerp(0, _ColorBlue.b, (_Render.b - 0.75) / (1.0 - 0.75));

        _Result.rgb = pow(abs(_Result.rgb), 1.0 / 2.2); 

        _Result = lerp(_Render, _Result, _Mixing);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;
    Out.Color = _Result;
    return Out;  
}
