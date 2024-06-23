/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.4 (21.06.2024) */
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
    float _Distance;
    int _Quality;
    bool ___;
    float _Power;
    float _Mixing;
    float _Alpha;
    int _Alpha_Mode;
    bool ____;
};

cbuffer PS_PIXELSIZE : register(b1)
{
    float fPixelWidth;
    float fPixelHeight;
};

/* too many float's 2!1!!! @w@ */

#define _BlurSize 30

static const float2 _Blur[_BlurSize] =
{
    1, 0.000001,
    0.489074, -0.103956,
    0.913545, -0.406737,
    0.404509, -0.293893,
    0.669131, -0.743145,
    0.25, -0.433013,
    0.309017, -0.951057,
    0.0522642, -0.497261,
    -0.104529, -0.994522,
    -0.154509, -0.475528,
    -0.5, -0.866025,
    -0.334565, -0.371572,
    -0.809017, -0.587785,
    -0.456773, -0.203368,
    -0.978148, -0.207912,
    -0.5, 0.000001,
    -0.978148, 0.207912,
    -0.456773, 0.203368,
    -0.809017, 0.587786,
    -0.334565, 0.371572,
    -0.5, 0.866025,
    -0.154509, 0.475528,
    -0.104528, 0.994522,
    0.0522642, 0.497261,
    0.309017, 0.951056,
    0.25, 0.433013,
    0.669131, 0.743145,
    0.404508, 0.293893,
    0.913546, 0.406736,
    0.489074, 0.103956,
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color : SV_Target;
};


/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(PS_INPUT In)
{
    PS_OUTPUT Out;

    float4 _Result_Blur = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    /* BLUR!!!!! */
    /* Destroy my graphics card!!!!!!!!!! */
    for (int j = 1; j < _Quality; j++)
    {
        for (int i = 0; i < _BlurSize; i++)
        {
            float2 offset = max(0.0, min(1.0, In.texCoord + ((_Distance / j) * float2(fPixelWidth, fPixelHeight) * _Blur[i]) / 2.0));
            _Result_Blur += S2D_Background.Sample(S2D_BackgroundSampler, offset);
        }
        _Result_Blur /= _BlurSize + 1;
    }

    if (_Alpha_Mode == 1)
    {
        _Result_Blur.a *= ((_Result_Blur.r + _Result_Blur.g + _Result_Blur.b) / 3.0);
    }
    else if (_Alpha_Mode == 2)
    {
        _Result_Blur.a *= 1 - ((_Result_Blur.r + _Result_Blur.g + _Result_Blur.b) / 3.0);
    }

    float4 _Result = pow(abs(_Result_Blur), _Power) * _Mixing;

    Out.Color = _Result * _Alpha * S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;

    return Out;
}