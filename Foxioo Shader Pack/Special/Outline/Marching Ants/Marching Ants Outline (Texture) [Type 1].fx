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
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _Time,
            _Size, _Offset,
            fPixelWidth, fPixelHeight;

    float4  _Shadow, _Light;

/************************************************************/
/* Main */
/************************************************************/

#define KERNEL 1

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result;
        float _Alpha = 0.0, _Weight = 0.0;

            float2 _Pixel = float2(fPixelWidth, fPixelHeight);

                for(int y = -KERNEL; y <= KERNEL; y++)
                {
                    for(int x = -KERNEL; x <= KERNEL; x++)
                    {
                        float2 _Off = float2(x, y) * _Pixel * _Offset;
                        _Alpha += tex2D(S2D_Image, In + _Off).a;
                        _Weight++;
                    }
                }

            _Alpha /= _Weight;
            
        float _Outline = ceil(_Alpha - ceil(_Render_Texture.a) - 1.0 / 255.0);

        float2 UV = (float2)(int2)ceil(In / _Pixel / _Size);
        UV *= 1.0 / _Pixel / 32.0;
        UV /= _Size;

            float _Pattern = sin((UV.x + UV.y) + _Time);
            _Pattern = round(_Pattern);

                _Result = float4((float3)lerp(_Shadow.rgb, _Light.rgb, _Pattern), _Outline);
                _Result = lerp(float4((float3)_Render_Texture.rgb, ceil(_Render_Texture.a)), _Result, _Result.a); // it's overcomplicated...

            _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
