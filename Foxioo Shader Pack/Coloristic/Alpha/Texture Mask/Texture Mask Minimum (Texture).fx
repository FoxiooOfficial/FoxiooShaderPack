/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D _Texture : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,

            _PosX, _PosY,
            _RotX,
            _PointX, _PointY,
            _ScaleX, _ScaleY, _Scale;

    int    _Looping_Mode, _Overlay;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_RotationX(float2 In)
{
    float2 _Points = float2(_PointX, _PointY);
    float _RotX_Fix = radians(_RotX);

        float _Sin;
        float _Cos;
        sincos(_RotX_Fix, _Sin, _Cos);

    return _Points + mul(float2x2(_Cos, _Sin, -_Sin, _Cos), In - _Points);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);

    float2 _Pos = float2(_PosX, _PosY);
    float2 _Point = float2(_PointX, _PointY);
    float2 _ScaleEx = float2(_ScaleX, _ScaleY) * _Scale;

            float2  UV = Fun_RotationX((In + _Pos));
            UV = ((UV - _Point) * _ScaleEx) + _Point;

                /* Looping Mode! */
                if (_Looping_Mode == 0)     UV = frac(UV); // REPEAT
                else if(_Looping_Mode == 1) UV = 1.0 - abs(frac(UV / 2.0) * 2.0 - 1.0); // MIRRORED REPEAT
                else if(_Looping_Mode == 2) UV = clamp(UV, 0.0, 1.0); // CLAMP
                else                        UV *= 1.0 - any(UV < 0.0 || UV > 1.0); // BORDER

            float4 _Result = _Render_Texture;
            float4 _Render = tex2D(_Texture, UV);

            float _Alpha = min(_Result.a, _Render.r * _Render.g * _Render.b);
            if(_Overlay)
                _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Alpha);
            else
                _Result.a = _Alpha;
            

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
