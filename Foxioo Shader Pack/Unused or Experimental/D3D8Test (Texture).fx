/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (22.01.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

texture T_Image;    // <- Main Texture

technique tech_main
{
    pass P0
    {
        Texture[0] = <T_Image>;
        PixelShader = asm
        {
            ps.1.3                          // <- Pixel Shader Version (ps.1.0, ps.1.1, ps.1.2, ps.1.3 or ps.1.4)
            def c0, 1.0, 1.0, 1.0, 0.0      // <- Constant value declaration (Red: 1.0, Green: 1.0, Blue: 1.0, Alpha: 0.0)

            tex t0;                         // <- Load the T_Image texture
            
            mov r0, t0                      // <- Assigning colors from the texture to the result.
            sub r0, c0, t0                  // <- Subtract colors (c0.rgba - t0.rgba)

            mov r0.a, t0.a                  // <- Assigning alpha color from texture
        };
    }
}