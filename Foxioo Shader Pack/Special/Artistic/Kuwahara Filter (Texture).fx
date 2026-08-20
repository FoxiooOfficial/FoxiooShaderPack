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
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Size,

            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

#define RADIUS 4
#define ZERO 0.0

float4 Fun_Kuwahara(float2 UV, sampler2D _Sampler)
{
    float4 _SumColor[4] = { (float4)ZERO, (float4)ZERO, (float4)ZERO, (float4)ZERO };
    float _SumLum[4] = { ZERO, ZERO, ZERO, ZERO };
    float _SumLumSq[4] = { ZERO, ZERO, ZERO, ZERO };
    int _Count[4] = { ZERO, ZERO, ZERO, ZERO };

    float2 _Offset = float2(fPixelWidth, fPixelHeight) * _Size;

        for (int _Y = -RADIUS; _Y <= RADIUS; _Y++)
        {
            for (int _X = -RADIUS; _X <= RADIUS; _X++)
            {
                float2 _Off = float2(_X, _Y) * _Offset;
                float4 _Render = tex2D(_Sampler, UV + _Off);

                float _Lum = dot(_Render.rgb, float3(0.2126, 0.7152, 0.0722));

                int _R = (min(sign(_X), 0) + 1) + max(0, sign(_Y)) * 2;

                _SumColor[_R] += _Render;
                _SumLum[_R] += _Lum;
                _SumLumSq[_R] += _Lum * _Lum;
                _Count[_R] += 1;
            }
        }

    float4 _Mean[4];
    float _Var[4];

        for (int i = 0; i < 4; i++)
        {
            if (_Count[i] > 0)
            {
                float _Invert = 1.0 / _Count[i];
                _Mean[i] = _SumColor[i] * _Invert;

                float _E = _SumLum[i] * _Invert;
                float _P = _SumLumSq[i] * _Invert - _E * _E;

                _Var[i] = max(0.0, _P);
            }
            else
            {
                _Mean[i] = (float4)ZERO;
                _Var[i] = 0.0;
            }
        }

    int _Best = 0;
    float _BVar = _Var[0];

        for (int ii = 1; ii < 4; ii++)
        {
            if (_Var[ii] < _BVar)
            {
                _BVar = _Var[ii];
                _Best = ii;
            }
        }

    return _Mean[_Best];
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result = Fun_Kuwahara(In, S2D_Image);

            _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_3_0 ps_main(); } }