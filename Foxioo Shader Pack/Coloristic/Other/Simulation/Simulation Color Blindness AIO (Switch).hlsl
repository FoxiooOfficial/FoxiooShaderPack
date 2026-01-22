/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.10.2025) */
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
    bool _Blending_Mode;
    float _Mixing;
    int _Mode;
    bool __;

	bool _Is_Pre_296_Build;
	bool ___;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            float3x3 _ColorMatrix;

            switch (_Mode)
            {
                case 0:
                    /* The _ColorMatrix variables are taken from: https://github.com/MaPePeR/jsColorblindSimulator */
                    _ColorMatrix = float3x3(
                        0.618, 0.32,  0.062,
                        0.163, 0.775, 0.062,
                        0.163, 0.32,  0.516
                    );
                    break;

                case 1:
                    _ColorMatrix = float3x3(
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114
                    );
                    break;

                case 2:
                    _ColorMatrix = float3x3(
                        0.80,   0.20,   0.0,
                        0.25833, 0.74167, 0.0,
                        0.0,    0.14167, 0.85833
                    );
                    break;

                case 3:
                    _ColorMatrix = float3x3(
                        0.625, 0.375, 0.0,
                        0.70,  0.30,  0.0,
                        0.0,   0.30,  0.70
                    );
                    break;

                case 4:
                    _ColorMatrix = float3x3(
                        0.81667, 0.18333, 0.0,
                        0.33333, 0.66667, 0.0,
                        0.0,     0.125,   0.875
                    );
                    break;

                case 5:
                    _ColorMatrix = float3x3(
                        0.56667, 0.43333, 0.0,
                        0.55833, 0.44167, 0.0,
                        0.0,     0.24167, 0.75833
                    );
                    break;

                case 6:
                    _ColorMatrix = float3x3(
                        0.96667, 0.03333, 0.0,
                        0.0,     0.73333, 0.26667,
                        0.0,     0.18333, 0.81667
                    );
                    break;

                case 7:
                    _ColorMatrix = float3x3(
                        0.95,  0.05,   0.0,
                        0.0,   0.43333, 0.56667,
                        0.0,   0.475,  0.525
                    );
                    break;

                default:
                    _ColorMatrix = float3x3(1.0, 0.0, 0.0,
                                            0.0, 1.0, 0.0,
                                            0.0, 0.0, 1.0);
                    break;
            }

        _Result.rgb = lerp(_Result.rgb, mul(_ColorMatrix, _Result.rgb) * _Mixing, _Mixing);

    _Result.a = _Render_Texture.a;
    Out.Color = _Result;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord) * In.Tint;

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

            float3x3 _ColorMatrix;

            switch (_Mode)
            {
                case 0:
                    /* The _ColorMatrix variables are taken from: https://github.com/MaPePeR/jsColorblindSimulator */
                    _ColorMatrix = float3x3(
                        0.618, 0.32,  0.062,
                        0.163, 0.775, 0.062,
                        0.163, 0.32,  0.516
                    );
                    break;

                case 1:
                    _ColorMatrix = float3x3(
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114
                    );
                    break;

                case 2:
                    _ColorMatrix = float3x3(
                        0.80,   0.20,   0.0,
                        0.25833, 0.74167, 0.0,
                        0.0,    0.14167, 0.85833
                    );
                    break;

                case 3:
                    _ColorMatrix = float3x3(
                        0.625, 0.375, 0.0,
                        0.70,  0.30,  0.0,
                        0.0,   0.30,  0.70
                    );
                    break;

                case 4:
                    _ColorMatrix = float3x3(
                        0.81667, 0.18333, 0.0,
                        0.33333, 0.66667, 0.0,
                        0.0,     0.125,   0.875
                    );
                    break;

                case 5:
                    _ColorMatrix = float3x3(
                        0.56667, 0.43333, 0.0,
                        0.55833, 0.44167, 0.0,
                        0.0,     0.24167, 0.75833
                    );
                    break;

                case 6:
                    _ColorMatrix = float3x3(
                        0.96667, 0.03333, 0.0,
                        0.0,     0.73333, 0.26667,
                        0.0,     0.18333, 0.81667
                    );
                    break;

                case 7:
                    _ColorMatrix = float3x3(
                        0.95,  0.05,   0.0,
                        0.0,   0.43333, 0.56667,
                        0.0,   0.475,  0.525
                    );
                    break;

                default:
                    _ColorMatrix = float3x3(1.0, 0.0, 0.0,
                                            0.0, 1.0, 0.0,
                                            0.0, 0.0, 1.0);
                    break;
            }

        _Result.rgb = lerp(_Result.rgb, mul(_ColorMatrix, _Result.rgb) * _Mixing, _Mixing);

    _Result.a = _Render_Texture.a;
    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}