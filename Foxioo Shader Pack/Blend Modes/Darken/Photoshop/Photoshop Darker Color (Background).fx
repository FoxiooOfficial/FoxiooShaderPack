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

texture T_Image;
texture T_Background;

/***********************************************************/
/* Variables */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

/*
float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{       
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result;
        _Result.rgb = _Render_Background.rgb;
        _Result.a = _Render_Texture.a;

            const float3 _Lum = float3(0.2126, 0.7152, 0.0722);
            float _Average_Texture = dot(_Render_Texture.rgb, _Lum);
            float _Average_Background = dot(_Render_Background.rgb, _Lum);
                
                float _Threshold = (_Mixing * 2.0) - 1.0; 

        if ((_Average_Background - _Average_Texture) > _Threshold)
            _Result.rgb = _Render_Texture.rgb;

    return _Result;
}
*/

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
    pass P0
    {
        Texture[0] = <T_Image>;
        MinFilter[0] = LINEAR;
        MagFilter[0] = LINEAR;
        MipFilter[0] = LINEAR;
        AddressU[0] = WRAP;
        AddressV[0] = WRAP;

        Texture[2] = <T_Background>;
        MinFilter[2] = LINEAR;
        MagFilter[2] = LINEAR;
        MipFilter[2] = LINEAR;
        AddressU[2] = WRAP;
        AddressV[2] = WRAP;

        PixelShaderConstant[0] = <_Mixing>;

        PixelShader = asm
        {
            ps.1.4

            /** Consts **************************************************/
            def c1, 0.212599993, 0.715200007, 0.0722000003, -1

            /** Samplers ************************************************/
            /*
                t0 -> float4 _Render_Texture = tex2D(S2D_Image, In);
                t1 -> float4 _Render_Background = tex2D(S2D_Background, In_Background);
            */
            texld r1, t1

            /** Assembly ************************************************/

                add r0.w, c0.x, c0.x
                add r0.w, r0.w, c1.w
                mov r2.x, r0.w
                phase
                texld r0, t0
                mov r2.w, r2.x
                dp3 r3.w, r1, c1
                dp3 r4.w, r0, c1
                add r3.w, r3.w, -r4.w
                add r2.w, r2.w, -r3.w
                cmp r0.xyz, r2.w, r1, r0
            + mov r0.w, r0.w
        };
    }
}