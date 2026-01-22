/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Texture_Red : register(t1);
SamplerState S2D_TextureSampler_Red : register(s1);

Texture2D<float4> S2D_Texture_Green : register(t2);
SamplerState S2D_TextureSampler_Green : register(s2);

Texture2D<float4> S2D_Texture_Blue : register(t3);
SamplerState S2D_TextureSampler_Blue : register(s3);

Texture2D<float4> S2D_Texture_Alpha : register(t4);
SamplerState S2D_TextureSampler_Alpha : register(s4);

// Texture2D<float4> S2D_Background : register(t1);
// SamplerState S2D_BackgroundSampler : register(s1);

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
    float _RotX;
    bool ____;
    float _PointX;
    float _PointY;
    bool _____;
    float _Scale;
    float _ScaleX;
    float _ScaleY;
    bool ______;
    int _Looping_Mode;
    float _Mixing;

    Texture2D _Texture_Red;
    float _Threshold_Red;
    float _Lower_Red;
    float _Upper_Red;

    Texture2D _Texture_Green;
    float _Threshold_Green;
    float _Lower_Green;
    float _Upper_Green;

    Texture2D _Texture_Blue;
    float _Threshold_Blue;
    float _Lower_Blue;
    float _Upper_Blue;

    Texture2D _Texture_Alpha;
    float _Threshold_Alpha;
    float _Lower_Alpha;
    float _Upper_Alpha;
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

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float _RotX_Fix = _RotX * (3.14159265 / 180);

        In = _Points + mul(float2x2(cos(_RotX_Fix), sin(_RotX_Fix), -sin(_RotX_Fix), cos(_RotX_Fix)), In - _Points);

    return In;
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

    float2  _Pos = float2(_PosX, _PosY),
            UV = Fun_RotationX((In.texCoord + _Pos));
            UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

            if (_Looping_Mode == 0)         {   UV = frac(UV);                          }
            else if(_Looping_Mode == 1)     {   UV = abs(frac(UV / 2.0) * 2.0 - 1.0);   }
            else if(_Looping_Mode == 2)     {   UV = clamp(UV, 0.0, 1.0);               }

        float4 _Render_Mask = float4(   S2D_Texture_Red.Sample(S2D_TextureSampler_Red, UV).r,
                                        S2D_Texture_Green.Sample(S2D_TextureSampler_Green, UV).r,
                                        S2D_Texture_Blue.Sample(S2D_TextureSampler_Blue, UV).r,
                                        S2D_Texture_Alpha.Sample(S2D_TextureSampler_Alpha, UV).r
                                    );

        float4 _Result = _Render_Texture;

                float4 _Threshold = float4(_Threshold_Red, _Threshold_Green, _Threshold_Blue, _Threshold_Alpha);
                float4 _Lower = _Threshold - float4(_Lower_Red, _Lower_Green, _Lower_Blue, _Lower_Alpha);
                float4 _Upper = _Threshold + float4(_Upper_Red, _Upper_Green, _Upper_Blue, _Upper_Alpha);

                float4 _Hold = clamp((_Render_Mask - _Lower) / (_Upper - _Lower), 0.0, 1.0);

            _Result *= _Hold;
            if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))    {   _Result = 0;    }

        _Result = lerp(_Render_Texture, _Result, _Mixing);

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

    float2  _Pos = float2(_PosX, _PosY),
            UV = Fun_RotationX((In.texCoord + _Pos));
            UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

            if (_Looping_Mode == 0)         {   UV = frac(UV);                          }
            else if(_Looping_Mode == 1)     {   UV = abs(frac(UV / 2.0) * 2.0 - 1.0);   }
            else if(_Looping_Mode == 2)     {   UV = clamp(UV, 0.0, 1.0);               }

        float4 _Render_Mask = float4(   S2D_Texture_Red.Sample(S2D_TextureSampler_Red, UV).r,
                                        S2D_Texture_Green.Sample(S2D_TextureSampler_Green, UV).r,
                                        S2D_Texture_Blue.Sample(S2D_TextureSampler_Blue, UV).r,
                                        S2D_Texture_Alpha.Sample(S2D_TextureSampler_Alpha, UV).r
                                    );

        float4 _Result = _Render_Texture;

                float4 _Threshold = float4(_Threshold_Red, _Threshold_Green, _Threshold_Blue, _Threshold_Alpha);
                float4 _Lower = _Threshold - float4(_Lower_Red, _Lower_Green, _Lower_Blue, _Lower_Alpha);
                float4 _Upper = _Threshold + float4(_Upper_Red, _Upper_Green, _Upper_Blue, _Upper_Alpha);

                float4 _Hold = clamp((_Render_Mask - _Lower) / (_Upper - _Lower), 0.0, 1.0);

            _Result *= _Hold;
            if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))    {   _Result = 0;    }

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;  
}
