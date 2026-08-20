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
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Time;

    bool    _Blending_Mode;

    static float3 _Blend[6] = {
        float3(0.2, 0.3, 0.4),
        float3(0.8, 0.5, 0.2),
        float3(1.0, 0.8, 0.6),
        float3(1.0, 1.0, 1.0),
        float3(1.0, 0.9, 0.8),
        float3(0.8, 0.4, 0.2) 
    };


/************************************************************/
/* Main */
/***********************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result, _Render;

            if (!_Blending_Mode) {   
                _Render = _Render_Texture; 
                _Result = _Render_Texture;
            }
            else {
                _Render = _Render_Background; 
                _Result = _Render_Background;
            }

                float _TimeFix = fmod(_Time, 24.0);
                if (_TimeFix < 0.0) _TimeFix = 24.0 - abs(_TimeFix);

                    if (_TimeFix < 4.0)
                        _Render.rgb *= lerp(_Blend[0], _Blend[1], _TimeFix / 4.0);

                    else if (_TimeFix < 6.0)
                        _Render.rgb *= lerp(_Blend[1], _Blend[2], (_TimeFix - 4.0) / 2.0);

                    else if (_TimeFix < 12.0)
                        _Render.rgb *= lerp(_Blend[2], _Blend[3], (_TimeFix - 6.0) / 6.0);

                    else if (_TimeFix < 16.0)
                        _Render.rgb *= lerp(_Blend[3], _Blend[4], (_TimeFix - 12.0) / 4.0);

                    else if (_TimeFix < 18.0)
                        _Render.rgb *= lerp(_Blend[4], _Blend[5], (_TimeFix - 16.0) / 2.0);

                    else
                        _Render.rgb *= lerp(_Blend[5], _Blend[0], (_TimeFix - 18.0) / 6.0);

            _Result.rgb = lerp(_Result.rgb, _Render.rgb, _Mixing);

        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
