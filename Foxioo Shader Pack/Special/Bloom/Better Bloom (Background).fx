/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.7 (18.10.2025) */
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

    float   _Distance, 
            _Power,
            _Mixing,
            _Alpha,

            fPixelWidth,fPixelHeight;

    int     _Alpha_Mode;

    bool    _Distance_Color;

/* too many float's 2!1!!! @w@ */

#define _BlurSize 30

static const float2 _Blur[_BlurSize] = 
{
    1, -0,
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
    -0.5, -0,
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

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Result_Blur = tex2D(S2D_Background, In);
    
    /* BYPASS LIMIT PIXEL SHADER!!! */ float _Bypass = 1; if(_Distance_Color == 1) {_Bypass = ((_Result_Blur.r + _Result_Blur.g + _Result_Blur.b) / 3.0); }
    
    /* BLUR!!!!! */
    for (int j = 1; j <= 3; j++)
    {
        for (int i = 0; i < _BlurSize; i++)
        {
            _Result_Blur += tex2D(S2D_Background, max(0.0, min(1.0, In + ((_Distance / j * _Bypass) * float2(fPixelWidth, fPixelHeight) * _Blur[i]) / 2.0)));
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
    
    float4 _Result = pow(_Result_Blur, _Power) * _Mixing;

    return  _Result * _Alpha * tex2D(S2D_Image, In);
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }

