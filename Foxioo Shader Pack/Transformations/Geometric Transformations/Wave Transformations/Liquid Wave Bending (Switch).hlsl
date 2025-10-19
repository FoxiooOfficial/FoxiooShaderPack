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
    float _PointX;
    float _PointY;
    bool ____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool _____;
    int _Looping_Mode;
    bool _Blending_Mode;
    float _Mixing;
    float _Seed;
    float _OffsetX;
    float _OffsetY;
    bool ______;
	bool _Is_Pre_296_Build;
    bool _______;
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

float Fun_Hash21(float2 _Pos) { return frac(sin(dot(_Pos, float2(12.9898,78.233))) * 43758.5453); }
float Fun_Noise(float2 _Pos, float _SeedPlus)
{
    float2 _I = floor(_Pos + _Seed + _SeedPlus);    float2 _F = frac(_Pos);

        float _A = Fun_Hash21(_I + float2(0.0, 0.0) + _Seed + _SeedPlus);
        float _B = Fun_Hash21(_I + float2(1.0, 0.0) + _Seed + _SeedPlus);
        float _C = Fun_Hash21(_I + float2(0.0, 1.0) + _Seed + _SeedPlus);
        float _D = Fun_Hash21(_I + float2(1.0, 1.0) + _Seed + _SeedPlus);

    float2 _UV = _F * _F * (3.0 - 2.0 *_F);

    return lerp(lerp(_A, _B, _UV.x), lerp(_C, _D, _UV.x), _UV.y);
}

float2 Fun_Noise_Replay(float2 _Pos, float2 _Off)
{
    _Pos = Fun_Noise(_Pos + _Off + Fun_Noise(_Pos + _Off * 0.5 + Fun_Noise(_Pos + _Off * 0.25, 1), 2), 3);

    return _Pos;
}
PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float2 _UV = ((In.texCoord + float2(_PosX, _PosY) - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY); 
        
        float2 _Off = float2(_OffsetX, _OffsetY);
        _UV = lerp(_UV, Fun_Noise_Replay(_UV, _Off), _Mixing);
        
        if(_Looping_Mode == 0)      {   _UV = frac(_UV);    }
        else if(_Looping_Mode == 1) {   _UV = abs(frac(_UV / 2) * 2.0 - 1.0); }
        else if(_Looping_Mode == 2) {   _UV = clamp(_UV, 0.0, 1.0); }

            float4 _Result = _Blending_Mode ? S2D_Background.Sample(S2D_BackgroundSampler, _UV) : S2D_Image.Sample(S2D_ImageSampler, _UV) * In.Tint;
            if(_Blending_Mode) _Result.a *= _Render_Texture.a;

            if(_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))   _Result = 0;

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

        float2 _UV = ((In.texCoord + float2(_PosX, _PosY) - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY); 
        
        float2 _Off = float2(_OffsetX, _OffsetY);
        _UV = lerp(_UV, Fun_Noise_Replay(_UV, _Off), _Mixing);
        
        if(_Looping_Mode == 0)      {   _UV = frac(_UV);    }
        else if(_Looping_Mode == 1) {   _UV = abs(frac(_UV / 2) * 2.0 - 1.0); }
        else if(_Looping_Mode == 2) {   _UV = clamp(_UV, 0.0, 1.0); }

            float4 _Result = _Blending_Mode ? S2D_Background.Sample(S2D_BackgroundSampler, _UV) : Demultiply(S2D_Image.Sample(S2D_ImageSampler, _UV)) * In.Tint;
            if(_Blending_Mode) _Result.a *= _Render_Texture.a;

            if(_Looping_Mode == 3 && any(_UV < 0.0 || _UV > 1.0))   _Result = 0;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}