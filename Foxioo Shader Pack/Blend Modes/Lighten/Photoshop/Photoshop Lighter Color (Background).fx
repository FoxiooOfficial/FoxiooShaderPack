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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

/*
float4 ps_main(in PS_INPUT In) : COLOR0
{       
    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
    float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);

        float4 _Result = _Render_Texture;

            const float3 _Lum = float3(0.2126, 0.7152, 0.0722);
            float _Average_Texture = dot(_Render_Texture.rgb, _Lum);
            float _Average_Background = dot(_Render_Background.rgb, _Lum);
                
                float _Threshold = (_Mixing * 2.0) - 1.0; 

        if ((_Average_Texture - _Average_Background) <= _Threshold)
            _Result.rgb = _Render_Background.rgb;

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
        Texture[0] = <T_Image>;                     // sampler2D S2D_Image      : register(s0);
        MinFilter[0] = LINEAR;
        MagFilter[0] = LINEAR;
        MipFilter[0] = LINEAR;
        AddressU[0] = WRAP;
        AddressV[0] = WRAP;

        Texture[2] = <T_Background>;                // sampler2D S2D_Background : register(s1);
        MinFilter[2] = LINEAR;
        MagFilter[2] = LINEAR;
        MipFilter[2] = LINEAR;
        AddressU[2] = WRAP;
        AddressV[2] = WRAP;

        PixelShaderConstant[0] = <_Mixing>;         // c0

        PixelShader = asm
        {
            ps.1.4

            /** Consts **************************************************/    
            def c1, 0.212599993, 0.715200007, 0.0722000003, -1

            /** Samplers ************************************************/
            /*
                r0 -> float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
                r1 -> float4 _Render_Background = tex2D(S2D_Background, In.bgCoord);
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
                add r3.w, -r3.w, r4.w
                add r2.w, r2.w, -r3.w
                cmp r0.xyz, r2.w, r1, r0
            + mov r0.w, r0.w
        };
    }
}