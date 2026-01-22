/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.2 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

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
        _SegmentSize,
        fPixelWidth, fPixelHeight;

bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

static const int _BlurSize = 8;
const float2 _Blur[_BlurSize] =
{
    float2(-1.0, -1.0),
    float2(0.0, -1.0),
    float2(1.0, -1.0),
    float2(-1.0, 0.0),
    float2(1.0, 0.0),
    float2(-1.0, 1.0),
    float2(0.0, 1.0),
    float2(1.0, 1.0)
};

float4 Fun_Kuwahara(float2 UV, sampler2D S2D)
{
    float4 _SumColor[4] = { float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0) };
    float4 _SumLumSq[4] = { float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0), float4(0.0, 0.0, 0.0, 0.0) };
    int _Count[4] = { 0, 0, 0, 0 };

    float2 _SegmentSizeFix = float2(fPixelWidth, fPixelHeight);

    for (int j = 0; j < _BlurSize; j++)
    {
        float2 _OffsetPos = UV + _Blur[j] * _SegmentSizeFix * _SegmentSize;
        float4 _Render = tex2D(S2D, _OffsetPos);

        int idx = j < 4 ? j : j - 4;
        _SumColor[idx] += _Render;
        _SumLumSq[idx] += _Render * _Render;
        _Count[idx] += 1;
    }

    float4 _Mean[4], _Var[4];
    for (int k = 0; k < 4; k++)
    {
        if (_Count[k] > 0) 
        {
            _Mean[k] = _SumColor[k] / _Count[k];
            _Var[k] = (_SumLumSq[k] / _Count[k]) - (_Mean[k] * _Mean[k]);
        }
    }

    int _BestIdx = 0;
    float _MinVariance = dot(_Var[0].xyz, float3(0.3, 0.59, 0.11));
    for (int l = 0; l < 4; l++)
    {
        float _Variance = dot(_Var[l].xyz, float3(0.3, 0.59, 0.11));
        if (_Variance < _MinVariance)
        {
            _MinVariance = _Variance;
            _BestIdx = l;
        }
    }

    return _Mean[_BestIdx];
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Render_Kuwahara, _Result;

    if(_Blending_Mode == 0)
    {
        _Result = _Render_Texture;
        _Render_Kuwahara = Fun_Kuwahara(In, S2D_Image);
    }
    else
    {
        _Result = _Render_Background;
        _Render_Kuwahara = Fun_Kuwahara(In, S2D_Background);
    }

    _Result = lerp(_Result, _Render_Kuwahara, _Mixing);
    _Result.a *= _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }