/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D _Texture_Red : register(s1);
sampler2D _Texture_Green : register(s2);
sampler2D _Texture_Blue : register(s3);
sampler2D _Texture_Alpha : register(s4);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,

            _PosX, _PosY,
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale,

            _Threshold_Red, _Lower_Red, _Upper_Red,
            _Threshold_Green, _Lower_Green, _Upper_Green,
            _Threshold_Blue, _Lower_Blue, _Upper_Blue,
            _Threshold_Alpha, _Lower_Alpha, _Upper_Alpha;

    int    _Looping_Mode;

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
float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

    float2  _Pos = float2(_PosX, _PosY),
            UV = Fun_RotationX((In + _Pos));
            UV = ((UV - float2(_PointX, _PointY)) * float2(_ScaleX, _ScaleY) * _Scale) + float2(_PointX, _PointY);

            if (_Looping_Mode == 0)         {   UV = frac(UV);                          }
            else if(_Looping_Mode == 1)     {   UV = abs(frac(UV / 2.0) * 2.0 - 1.0);   }
            else if(_Looping_Mode == 2)     {   UV = clamp(UV, 0.0, 1.0);               }

        float4 _Render_Mask = float4(   tex2D(_Texture_Red, UV).r, 
                                        tex2D(_Texture_Green, UV).r, 
                                        tex2D(_Texture_Blue, UV).r, 
                                        tex2D(_Texture_Alpha, UV).r
                                    );

        float4 _Result = _Render_Texture;

                float4 _Threshold = float4(_Threshold_Red, _Threshold_Green, _Threshold_Blue, _Threshold_Alpha);
                float4 _Lower = _Threshold - float4(_Lower_Red, _Lower_Green, _Lower_Blue, _Lower_Alpha);
                float4 _Upper = _Threshold + float4(_Upper_Red, _Upper_Green, _Upper_Blue, _Upper_Alpha);

                float4 _Hold = clamp((_Render_Mask - _Lower) / (_Upper - _Lower), 0.0, 1.0);

            _Result *= _Hold;
            if (_Looping_Mode == 3 && any(UV < 0.0 || UV > 1.0))    {   _Result = 0;    }

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
