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

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, _Fade, _PosXFreeze, _PosYFreeze,
            fPixelWidth, fPixelHeight;

    float4  _Color;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));

        float4 _Freeze_0 = float4(_Color.rgb, tex2D(S2D_Image, In).a);
        float4 _Freeze_1 = float4(_Color.rgb, tex2D(S2D_Image, In - (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight))).a) * 0.5;
        float4 _Freeze_2 = float4(_Color.rgb, tex2D(S2D_Image, In + (float2(_PosXFreeze, _PosYFreeze) * float2(fPixelWidth, fPixelHeight))).a) * 0.5;

        float4 _Freeze_Sum = (_Freeze_0 + _Freeze_1 + _Freeze_2);
        if(_Fade < 1.0 - In.y) _Freeze_Sum = 0;
        
           float4 _Result = lerp(_Render_Texture, _Render_Texture + _Freeze_Sum, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
