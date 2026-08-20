/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (18.02.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _Depth, _Buffer;

    struct PS_OUTPUT
    {
        float4 Color : COLOR0;
        float Depth : DEPTH;
    }; 

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT main(in float2 In : TEXCOORD0)
{
    PS_OUTPUT Out;
    /* Test only! */
    float _DepthX = saturate(_Depth - (1.0 - In.y));
    Out.Depth = _DepthX;

    float4 _Render_Texture = tex2D(S2D_Image, In);
    float _Render_Depth = Out.Depth;

        float4 _Result = _Buffer == 1.0 ? _DepthX : _Render_Texture;

    Out.Color = _Result;

    return Out;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
    pass P0 { PixelShader = compile ps_2_0 main(); }
}
