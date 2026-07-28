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
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : SV_POSITION;
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

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        _Result.a = _Render_Texture.a;

        /* The _ColorMatrix variables are taken from: https://github.com/MaPePeR/jsColorblindSimulator */
        float3x3 _ColorMatrix;

            switch (_Mode)
            {
                case 0: // Achromatomal
                {
                    _ColorMatrix = float3x3(
                        0.618, 0.32,  0.062,
                        0.163, 0.775, 0.062,
                        0.163, 0.32,  0.516
                    );
                    break;
                }
                case 1: // Achromatopsia
                {
                    _ColorMatrix = float3x3(
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114
                    );
                    break;
                }
                case 2: // Deuteranomaly
                {
                    _ColorMatrix = float3x3(
                        0.80,   0.20,   0.0,
                        0.25833, 0.74167, 0.0,
                        0.0,    0.14167, 0.85833
                    );
                    break;
                }
                case 3: // Deuteranopia
                {
                    _ColorMatrix = float3x3(
                        0.625, 0.375, 0.0,
                        0.70,  0.30,  0.0,
                        0.0,   0.30,  0.70
                    );
                    break;
                }
                case 4: // Protanomaly
                {
                    _ColorMatrix = float3x3(
                        0.81667, 0.18333, 0.0,
                        0.33333, 0.66667, 0.0,
                        0.0,     0.125,   0.875
                    );
                    break;
                }
                case 5: // Protanopia
                {
                    _ColorMatrix = float3x3(
                        0.56667, 0.43333, 0.0,
                        0.55833, 0.44167, 0.0,
                        0.0,     0.24167, 0.75833
                    );
                    break;
                }
                case 6: // Tritanomaly
                {
                    _ColorMatrix = float3x3(
                        0.96667, 0.03333, 0.0,
                        0.0,     0.73333, 0.26667,
                        0.0,     0.18333, 0.81667
                    );
                    break;
                }
                case 7: // Tritanopia
                {
                    _ColorMatrix = float3x3(
                        0.95,  0.05,   0.0,
                        0.0,   0.43333, 0.56667,
                        0.0,   0.475,  0.525
                    );
                    break;
                }
                default:
                {
                    _ColorMatrix = float3x3(1.0, 0.0, 0.0,
                                            0.0, 1.0, 0.0,
                                            0.0, 0.0, 1.0);
                    break;
                }
            }

        _Result.rgb = lerp(_Result.rgb, mul(_ColorMatrix, _Result.rgb), _Mixing);

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET{
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
