/***********************************************************/

/* Autor shader: Foxioo */
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
/* Varibles */
/***********************************************************/

    float   _Mixing;

    bool    _Blending_Mode,
            _Correction;

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
            _Result = _Render_Texture;
        }
        else
        {
            _Result = _Render_Background;
        }

        float3 _CorrectionColor = float3(_Correction * 2.0, 0, 0);

            const float3x3 _LMSConst = float3x3(
                0.3592, 0.6976, -0.0358,
                -0.1922, 1.1004, 0.0755,
                0.0070, 0.0749, 0.8434
            );

            float3 _LMS = mul(_Result.rgb, _LMSConst);

                const float _M1 = 2610.0 / 16384.0;
                const float _M2 = 2523.0 / 32.0;
                const float _C1 = 3424.0 / 4096.0;
                const float _C2 = 2413.0 / 128.0;
                const float _C3 = 2392.0 / 128.0;
                float3 _LMSpq = pow( (_C1 + _C2 * pow(_LMS, _M1)) / (1.0 + _C3 * pow(_LMS, _M1)), _M2 );

            float3x3 _ICtCpConst = float3x3(
                0.5,   0.5,    0.0,
                1.6137, -3.3234, 1.7097,
                4.3780, -4.2455, -0.1325
            );

            float3 _ICtCp = mul(_Result.rgb, _ICtCpConst);

        _Result.rgb = lerp(_Result.rgb, _ICtCp - _CorrectionColor, _Mixing);

    _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
