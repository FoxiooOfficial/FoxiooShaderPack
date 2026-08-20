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
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Offset,
            _Time,

            _PointX, _PointY;
        
    bool    _Blending_Mode;

    int     _Quality;

/************************************************************/
/* Main */
/************************************************************/

static const float _Pi = 3.14159265359;

float4 Fun_Vessel(sampler2D S2D, float2 UV)
{
    float4 _Result = (float4)0.0;
    float2 _Pos = float2(_PointX, _PointY);

        float _Weight = 0.0;
        int i;
        for(i = 0; i < _Quality; i++)  
        {
            float _T = float(i) / float(_Quality);
                float2 _In = ((UV - _Pos) * frac(_Time + _T)) + _Pos;
                float _Alpha = abs(sin((_Time + _T) * _Pi));

                float4 _Render = tex2D(S2D, lerp(UV, _In, _Offset)) * _Alpha;
                _Result += _Render;

                _Weight += _Alpha;
        }

    return _Result / _Weight;
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Blending_Mode ? Fun_Vessel(S2D_Background, In) : Fun_Vessel(S2D_Image, In);

            _Result = lerp(_Render, _Result, _Mixing);

        if(_Blending_Mode)
            _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }
