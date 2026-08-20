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

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _PT, _DPI, _Height,
            _OffsetY, _ScaleY, 

            _PosX, _PosY, _Alpha,
            
            fPixelWidth, fPixelHeight;

    float4  _Light, _Dark, _Shadow;

    #define M_PI 3.14159265358979323846

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Result;
        
        _Result.a = _Render_Texture.a;

        float2 _Res = float2(fPixelWidth, fPixelHeight);
        float _FontSize = _DPI / 72.0 * _PT * _Res.y;

            float _Gradient = cos(((In.y - _OffsetY * _FontSize) * _ScaleY * 2.0) * M_PI / _FontSize * (2.0 / _Height));

                _Result.rgb = lerp(_Dark.rgb, _Light.rgb, _Gradient);

            float2 _ShadowOffset = float2(_PosX, _PosY) * _Res;

                float4 _Render_Shadow = tex2D(S2D_Image, In - _ShadowOffset);
                    _Render_Shadow.rgb = _Shadow.rgb;
                    _Render_Shadow.a *= _Alpha;

            _Result = lerp(_Render_Shadow, _Result, _Result.a);

        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
