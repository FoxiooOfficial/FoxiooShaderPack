/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (13.04.2026) */
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

    float   _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Hash21(float2 _Pos) 
{ 
    float2 _Noise;
    _Noise.x = frac(sin(dot(_Pos, float2(12.9898, 78.233))) * 43758.5453) - 0.5;
    _Noise.y = frac(sin(dot(_Pos, float2(63.7264, 10.873))) * 73156.8473) - 0.5;
    return _Noise;
}

float4 ps_main(in PS_INPUT In) : COLOR0
{
    const int _Size = 10;
    float4 _Render = 0.0;
   
        for(int i = 0; i < _Size; i++)
        {
            float2 _Off = Fun_Hash21(In.texCoord + i);
            _Render.rgb += tex2D(S2D_Background, frac(In.texCoord + float2( _Off.x,  _Off.y) * _Mixing)).rgb;
            _Render.rgb += tex2D(S2D_Background, frac(In.texCoord + float2(-_Off.x,  _Off.y) * _Mixing)).rgb * 0.25;
            _Render.rgb += tex2D(S2D_Background, frac(In.texCoord + float2( _Off.x, -_Off.y) * _Mixing)).rgb * 0.25;
            _Render.rgb += tex2D(S2D_Background, frac(In.texCoord + float2(-_Off.x, -_Off.y) * _Mixing)).rgb * 0.5;
        }

        _Render.rgb /= _Size * 2.0;

       _Render.a = tex2D(S2D_Image, In.texCoord).a;

    return _Render;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
