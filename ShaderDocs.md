# Technical documentation on shaders in Clickteam Fusion 2.5

### This is an information library designed to organize what works and what doesn't work in Clickteam Fusion.
All information is based on:
- My knowledge and experiments
- [Naitor's knowledge and experiments](https://github.com/NaitorStudios)
- Official [HLSL](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx-graphics-hlsl) and *GLSL documentation websites
- Numerous online forums on shaders
- [Official Clickteam forum
](https://community.clickteam.com/search/?q=shader&type=com.woltlab.wbb.post&sortField=relevance&sortOrder=DESC&findThreads=1)

**This page will be updated. If there are sections in Polish, it means that this section is still incomplete (English is not my native language, I need to use a translator, so I prefer to write something in Polish first and then translate it).**

---

# Table of contents

- [XML File](#xml-file)
- [Windows](#windows)
  - [Direct3D 8](#direct3d-8)
  - [Direct3D 9](#direct3d-9)
  - [Direct3D 11](#direct3d-11)
- [Android](#android)
  - [Android OpenGL ES](#android-opengl-es)
- [iOS and macOS](#ios-and-macos)
  - [iOS OpenGL ES](#ios-opengl-es)
  - [macOS OpenGL ES](#macos-opengl-es)
- [HTML5](#html5)


# XML File

# Windows

## Direct3D 8

Shadery pisane dla Direct3D 8 są pisane w asemblerze, dany kod powinien się znajdować w pliku .fx w którym też piszemy shadery dla Direct3D 9, jeśli shader pod D3D8 działa, również zadziała pod D3D9.

**Wersje Pixel Shader** [(Źródło)](https://en.wikipedia.org/wiki/High-Level_Shader_Language)
| Type  | Version  | Works | Dependent<br>texture<br>limit | Texture <br>instruction<br>limit | Arithmetic<br>instruction<br>limit | Position<br>register | Instruction<br>slots | Executed<br>instructions | Texture<br>indirections | Interpolated<br>registers | Instruction<br>predication | Index<br>input<br>registers | Temp<br>registers | Constant<br>registers | Arbitrary<br>swizzling | Gradient<br>instructions | Loop <br>count <br>register | Face<br>register | Dynamic<br>flow<br>control | Bitwise<br>Operators | Native<br>Integers | Note&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|-------|----------|-------|-------------------------------|----------------------------------|------------------------------------|----------------------|----------------------|--------------------------|-------------------------|---------------------------|----------------------------|-----------------------------|-------------------|-----------------------|------------------------|--------------------------|-----------------------------|------------------|----------------------------|----------------------|--------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `asm` | `ps.1.0` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8                    | 8                        | 4                       | 2 + 4                     | ❌                          | ❌                           | 2                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.1` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 2 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.2` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.3` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.4` | ✅     | 6                             | 6 * 2                            | 8 * 2                              | ❌                    | (8 + 6) * 2          | (8 + 6) * 2              | 4                       | 2 + 8                     | ❌                          | ❌                           | 6                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  | The best version in terms of limits, but the texture declaration is different compared to ps.1.0, ps.1.1, ps.1.2, and ps.1.3. |

`(8 + 6) * 2` for **Executed instructions** means:
- *8 texture instructions and 6 arithmetic instructions in 2 phases*.
- i.e. total of *16 texture instructions and 12 arithmetic instructions*.

**Wersje Vertex Shader** [(Źródło)](https://en.wikipedia.org/wiki/High-Level_Shader_Language)
| Type  | Version  | Works | Number of<br>instruction<br>slots | Max<br>number of<br>instructions<br>executed | Instruction<br>predication | Temp<br>register | Number<br>constant<br>registers | Address<br>register | Static<br>flow<br>control | Dynamic<br>flow<br>control | Dynamic<br>flow<br>control<br>depth | Vertex<br>texture<br>fetch | Number of<br>texture<br>samplers | Geometry<br>instancing<br>support | Bitwise<br>operators | Native<br>integers | Note&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|-------|----------|-------|-----------------------------------|----------------------------------------------|----------------------------|------------------|---------------------------------|---------------------|---------------------------|----------------------------|-------------------------------------|----------------------------|----------------------------------|-----------------------------------|----------------------|--------------------|---------------------------------------------------------------------------------|
| `asm` | `vs.1.0` | ❌     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ❌                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  | The compiler throws a warning about lack of support for vs.1.0 and uses vs.1.1. |
| `asm` | `vs.1.1` | ✅     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ✅                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  |                                                                                 |

Przykładowy kod:
```hlsl
texture T_Image;                            // <- Main texture

technique tech_main
{
    pass P0
    {
        Texture[0] = <T_Image>;
        PixelShader = asm
        {
            ps.1.1                          // <- Pixel Shader Version (ps.1.0, ps.1.1, ps.1.2, ps.1.3 or ps.1.4)
            def c0, 1.0, 1.0, 1.0, 0.0      // <- Constant value declaration (Red: 1.0, Green: 1.0, Blue: 1.0, Alpha: 0.0)

            tex t0;                         // <- Load the T_Image texture
            
            mov r0, t0                      // <- Assigning colors from the texture to the result.
            sub r0, c0, t0                  // <- Subtract colors (c0.rgba - t0.rgba)

            mov r0.a, t0.a                  // <- Assigning alpha color from texture
        };
    }
}
```

## Direct3D 9

## Direct3D 11

# Android

## Android OpenGL ES

# iOS and macOS

## iOS OpenGL ES

## macOS OpenGL ES

# HTML5
