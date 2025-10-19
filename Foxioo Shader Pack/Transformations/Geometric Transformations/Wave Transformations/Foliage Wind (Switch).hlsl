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
    bool __;
    float _PosX;
    float _PosY;
    bool ___;
    float _ScaleX;
    float _ScaleY;
    float _Scale;
    bool ____;
    int _Looping_Mode;
    bool _Blending_Mode;
    float _Mixing;
    bool _____;

	bool _Is_Pre_296_Build;
	bool ______;
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

float Fun_Fade(float _Times)    { return _Times * _Times * _Times * (_Times * (_Times * 6.0 - 15.0) + 10.0); }
float Fun_Hash(float2 _Pos)     {  return frac(sin(dot(_Pos, float2(127.1, 311.7))) * 43758.5453); }
float Fun_PerlinNoise(float2 _Pos)
{
    float2 _I = floor(_Pos);
    float2 _F = frac(_Pos);

    float _A = Fun_Hash(_I);
    float _B = Fun_Hash(_I + float2(1.0, 0.0));
    float _C = Fun_Hash(_I + float2(0.0, 1.0));
    float _D = Fun_Hash(_I + float2(1.0, 1.0));

    float2 _UV = float2(Fun_Fade(_F.x), Fun_Fade(_F.y));

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float2 Fun_Offset(float2 _Pos)
{
    float2 _UV = _Pos * 0.5;

    float _OffsetX = Fun_PerlinNoise(_UV + sin(_PosX + _UV));
    float _OffsetY = Fun_PerlinNoise(_UV + cos(_PosX + _UV));

        _OffsetX = (_OffsetX * 2.0 - 1.0) * 0.1;
        _OffsetY = (_OffsetY * 2.0 - 1.0) * 0.1;

    return float2(_OffsetX, _OffsetY);
}


PS_OUTPUT ps_main( in PS_INPUT In )
{ 
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float2 UV = lerp(In.texCoord, In.texCoord + Fun_PerlinNoise(In.texCoord * float2(_ScaleX, _ScaleY) * _Scale + float2(_PosX, _PosY)), _Mixing);

    float4 _Render = 0;

            if(_Looping_Mode == 0)
            {
                UV = frac(UV);
            }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = S2D_Image.Sample(S2D_ImageSampler, UV) * In.Tint; }
    else {                      _Render = float4(S2D_Background.Sample(S2D_BackgroundSampler, UV).rgb, _Render_Texture.a);    }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
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
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    float2 UV = lerp(In.texCoord, In.texCoord + Fun_PerlinNoise(In.texCoord * float2(_ScaleX, _ScaleY) * _Scale + float2(_PosX, _PosY)), _Mixing);

    float4 _Render = 0;

            if(_Looping_Mode == 0)
            {
                UV = frac(UV);
            }
            else if(_Looping_Mode == 1)
            {
                UV /= 2;
                UV = frac(UV);
                UV = abs(UV * 2.0 - 1.0);
            }
            else if(_Looping_Mode == 2)
            {
                UV = clamp(UV, 0.0, 1.0);
            }

    if(_Blending_Mode == 0) {   _Render = Demultiply(S2D_Image.Sample(S2D_ImageSampler, UV)) * In.Tint; }
    else {                      _Render = float4(S2D_Background.Sample(S2D_BackgroundSampler, UV).rgb, _Render_Texture.a);    }

        if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))
        {
            _Render = 0;
        }

    _Render.rgb *= _Render.a;

    Out.Color = _Render;
    return Out;
}
