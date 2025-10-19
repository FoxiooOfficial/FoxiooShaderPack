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
    int _Looping_Mode;
    float _Seed;
    float _Dimension;
    float _Angle;
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

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(_Seed + sin(dot(_Pos - _Seed, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(_Seed + sin(dot(_Pos - _Seed, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

float2 Fun_Noise(float2 _Pos) 
{
    float2 _Noise = Fun_Hash21(_Pos);
    float2 _Dir = float2(cos(_Angle * (3.14159265 / 180.0)), sin(_Angle * (3.14159265 / 180.0)));

    _Noise = lerp(float2(_Noise.x, _Noise.x) * _Dir, _Noise, _Dimension);

    return _Noise;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = In.texCoord;
        _UV += Fun_Noise(In.texCoord) * _Mixing;

        if (_Looping_Mode == 0) {
            _UV = frac(_UV);
        }
            else if(_Looping_Mode == 1)
            {
                _UV /= 2;
                _UV = frac(_UV);
                _UV = abs(_UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                _UV = clamp(_UV, 0.0, 1.0);
            }

        float4 _Result = 0.0;

            float4 _Render_Texture_Noise = S2D_Image.Sample(S2D_ImageSampler, _UV) * In.Tint;
            float4 _Render_Background_Noise = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

        float4 _Render = _Blending_Mode ? _Render_Background_Noise : _Render_Texture_Noise;
        if(_Blending_Mode)  _Render.a = _Render_Texture.a;

        if (_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))
        {
            _Render = 0;
        }

    Out.Color = _Render;
    
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

        float2 _UV = In.texCoord;
        _UV += Fun_Noise(In.texCoord) * _Mixing;

        if (_Looping_Mode == 0) {
            _UV = frac(_UV);
        }
            else if(_Looping_Mode == 1)
            {
                _UV /= 2;
                _UV = frac(_UV);
                _UV = abs(_UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                _UV = clamp(_UV, 0.0, 1.0);
            }

        float4 _Result = 0.0;

            float4 _Render_Texture_Noise = Demultiply(S2D_Image.Sample(S2D_ImageSampler, _UV)) * In.Tint;
            float4 _Render_Background_Noise = S2D_Background.Sample(S2D_BackgroundSampler, _UV);

        float4 _Render = _Blending_Mode ? _Render_Background_Noise : _Render_Texture_Noise;
        if(_Blending_Mode)  _Render.a = _Render_Texture.a;

        if (_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))
        {
            _Render = 0;
        }

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}