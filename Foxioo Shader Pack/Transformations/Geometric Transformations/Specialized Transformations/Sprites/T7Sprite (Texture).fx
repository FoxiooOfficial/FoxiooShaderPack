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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing, _Depth, _Buffer;

    struct PS_OUTPUT
    {
        float4 Color : COLOR0;
        float Depth : DEPTH;
    }; 

/************************************************************/
/* Main */
/************************************************************/

PS_OUTPUT ps_main(in float2 In.texCoord : TEXCOORD0)
{
    PS_OUTPUT Out;
    /* Test only! */
    float _DepthX = saturate(_Depth - (1.0 - In.texCoord.y));
    Out.Depth = _DepthX;

    float4 _Render_Texture = tex2D(S2D_Image, In.texCoord) * In.Tint;
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
    pass P0 { PixelShader = compile ps_2_0 ps_main(); }
}
