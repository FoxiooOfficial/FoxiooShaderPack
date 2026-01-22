/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.10.2025) */
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

    float _Mixing;

    int _Mode;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = 0;

        if(_Blending_Mode == 0)
        {
            _Result = tex2D(S2D_Image, In);
        }
        else
        {
            _Result = tex2D(S2D_Background, In);
        }

            float3x3 _ColorMatrix;

            if(_Mode == 0)
            {
                /* The _ColorMatrix variables are taken from: https://github.com/MaPePeR/jsColorblindSimulator */
                _ColorMatrix = float3x3(
                        0.618, 0.32,  0.062,
                        0.163, 0.775, 0.062,
                        0.163, 0.32,  0.516
                );
            }
            else if(_Mode == 1)
            {
                _ColorMatrix = float3x3(
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114,
                        0.299, 0.567,  0.114
                    );
            }
            else if(_Mode == 2)
            {
                _ColorMatrix = float3x3(
                        0.80,   0.20,   0.0,
                        0.25833, 0.74167, 0.0,
                        0.0,    0.14167, 0.85833
                    );
            }
            else if(_Mode == 3)
            {
                _ColorMatrix = float3x3(
                        0.625, 0.375, 0.0,
                        0.70,  0.30,  0.0,
                        0.0,   0.30,  0.70
                    );
            }
            else if(_Mode == 4)
            {
                _ColorMatrix = float3x3(
                        0.81667, 0.18333, 0.0,
                        0.33333, 0.66667, 0.0,
                        0.0,     0.125,   0.875
                    );
            }
            else if(_Mode == 5)
            {
                _ColorMatrix = float3x3(
                        0.56667, 0.43333, 0.0,
                        0.55833, 0.44167, 0.0,
                        0.0,     0.24167, 0.75833
                    );
            }
            else if(_Mode == 6)
            {
                _ColorMatrix = float3x3(
                        0.96667, 0.03333, 0.0,
                        0.0,     0.73333, 0.26667,
                        0.0,     0.18333, 0.81667
                    );
            }
            else if(_Mode == 7)
            {
                _ColorMatrix = float3x3(
                        0.95,  0.05,   0.0,
                        0.0,   0.43333, 0.56667,
                        0.0,   0.475,  0.525
                    );
            }

        _Result.a = _Render_Texture.a;

        _Result.rgb = lerp(_Result.rgb, mul(_ColorMatrix, _Result.rgb) * _Mixing, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
