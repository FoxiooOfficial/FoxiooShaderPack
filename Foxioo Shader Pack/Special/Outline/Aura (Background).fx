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
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _Offset,
            _Time,

            _Fraq, _FraqEx, _Amp,

            _PointX, _PointY,
            fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

static const float _Pi = 3.14159265359;
static const int _Size = 5;

float4 Fun_Vessel(sampler2D S2D, float2 UV)
{
    float4 _Result = float4(0, 0, 0, 0);
    float2 _Pos = float2(_PointX, _PointY);

        for(float i = 1; i < _Size; i++)  
        {
            float _T = i / float(_Size - 1.0);
                float2 _In = ((UV - _Pos) * frac(_Time + _T)) + _Pos;
                float _Alpha = abs(sin((_Time + _T) * _Pi));

                _Result += tex2D(S2D, frac(lerp(UV, _In + sin(_Time  + _In.y * _Fraq + i * _FraqEx) * _Amp, _Offset))) * _Alpha;
        }
    
    _Result.rgb *= _Result.a;

    return _Result * 0.2;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    In.texCoord = frac(In.texCoord);

    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Render = _Render_Texture;
        float4 _Result = Fun_Vessel(S2D_Image, In.texCoord);

            _Result = lerp(_Render, _Result + _Render_Background * _Result.a, _Mixing * (1.0 - _Render_Texture.a) * _Result.a);

        //if(_Blending_Mode)
        //_Result.a *= _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
