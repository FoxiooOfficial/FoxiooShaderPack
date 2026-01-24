# Technical documentation on shaders for Clickteam Fusion 2.5 (Not official)

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

Shadery pisane dla Direct3D 8 są pisane w **asemblerze**, dany kod powinien się znajdować w pliku **.fx** w którym też piszemy shadery dla Direct3D 9, jeśli shader pod D3D8 działa, również zadziała pod D3D9, jednak to jest kompatybiliność w jedną stronę tz. D3D8 nie wspiera języka HLSL w pełni.

Aby efekt ten musiał zadziałać, należy również w pliku **.xml** wstawić `dx8>yes</dx8>`

[Przykładowy kod](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Release/Unused%20or%20Experimental/D3D8Test%20(Texture).zip) efektu działającego pod D3D8:
```hlsl
texture T_Image;                            // <- Main texture

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
```

---

### Pixel Shader and Vertex Shader Version Differences [(Source)](https://en.wikipedia.org/wiki/High-Level_Shader_Language#Pixel_shader_comparison)

**Pixel Shader Versions**
| **Type**  | **Version**  | **Works** | **Dependent<br>texture<br>limit** | **Texture <br>instruction<br>limit** | **Arithmetic<br>instruction<br>limit** | **Position<br>register** | **Instruction<br>slots** | **Executed<br>instructions** | **Texture<br>indirections** | **Interpolated<br>registers** | **Instruction<br>predication** | **Index<br>input<br>registers** | **Temp<br>registers** | **Constant<br>registers** | **Arbitrary<br>swizzling** | **Gradient<br>instructions** | **Loop <br>count <br>register** | **Face<br>register** | **Dynamic<br>flow<br>control** | **Bitwise<br>Operators** | **Native<br>Integers** | **Note**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|-------|----------|-------|-------------------------------|----------------------------------|------------------------------------|----------------------|----------------------|--------------------------|-------------------------|---------------------------|----------------------------|-----------------------------|-------------------|-----------------------|------------------------|--------------------------|-----------------------------|------------------|----------------------------|----------------------|--------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `asm` | `ps.1.0` | ❔     | 4                             | 4                                | 8                                  | ❌                    | 8                    | 8                        | 4                       | 2 + 4                     | ❌                          | ❌                           | 2                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  | It's possible that the compiler forces the use of `ps.1.1`                                                                    |
| `asm` | `ps.1.1` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 2 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.2` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.3` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.4` | ✅     | 6                             | 6 * 2                            | 8 * 2                              | ❌                    | (8 + 6) * 2          | (8 + 6) * 2              | 4                       | 2 + 8                     | ❌                          | ❌                           | 6                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  | Texture declaration is different compared to `ps.1.0`, `ps.1.1`, `ps.1.2`, and `ps.1.3`. |

`(8 + 6) * 2` for **Executed instructions** means:
- *8 texture instructions and 6 arithmetic instructions in 2 phases*.
- i.e. total of *16 texture instructions and 12 arithmetic instructions*.

**Vertex Shader Versions**
| **Type**  | **Version**  | **Works** | **Number of<br>instruction<br>slots** | **Max<br>number of<br>instructions<br>executed** | **Instruction<br>predication** | **Temp<br>register** | **Number<br>constant<br>registers** | **Address<br>register** | **Static<br>flow<br>control** | **Dynamic<br>flow<br>control** | **Dynamic<br>flow<br>control<br>depth** | **Vertex<br>texture<br>fetch** | **Number of<br>texture<br>samplers** | **Geometry<br>instancing<br>support** | **Bitwise<br>operators** | **Native<br>integers** | **Note**&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; |
|-------|----------|-------|-----------------------------------|----------------------------------------------|----------------------------|------------------|---------------------------------|---------------------|---------------------------|----------------------------|-------------------------------------|----------------------------|----------------------------------|-----------------------------------|----------------------|--------------------|---------------------------------------------------------------------------------|
| `asm` | `vs.1.0` | ❌     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ❌                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  | The compiler throws a warning about lack of support for `vs.1.0` and uses `vs.1.1`. |
| `asm` | `vs.1.1` | ✅     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ✅                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  |                                                                                 |

---

### Instruction Set [(Source 1)](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx9-graphics-reference-asm-ps-instructions-ps-1-x) [(Source 2)](https://web.archive.org/web/20120911164630/https://user.xmission.com/~legalize/book/download/13-Pixel%20Shaders.pdf)

**Instruction set for Pixel Shader**
| **Type** | **Instruction**        | **Description**                                                               | **Instruction slots** | ``1.0`` | ``1.1`` | ``1.2`` | ``1.3`` | ``1.4`` | **Note**                                                                                                                                                                                          |
|----------|------------------------|-------------------------------------------------------------------------------|-----------------------|---------|---------|---------|---------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ``asm``  | `ps`                   | Version number                                                                | 0                     | ✅       | ✅       | ✅       | ✅       | ✅       | Used at the beginning of the assembler, it defines the version of the effect that is being written for. Example:<br>`ps.1.1` -> Uses Pixel Shader version 1.1                                     |
|          |                        | ***Constant instructions***                                                   |                       |         |         |         |         |         |                                                                                                                                                                                                   |
| **Type** | **Instruction**        | **Description**                                                               | **Instruction slots** | ``1.0`` | ``1.1`` | ``1.2`` | ``1.3`` | ``1.4`` | **Note**                                                                                                                                                                                          |
| ``asm``  | `def`                  | Define constants                                                              | 0                     | ✅       | ✅       | ✅       | ✅       | ✅       | It declares constant values. The syntax looks like this: `def c#, r, g, b, a`. Example:<br>`def c0, 0.5, 1.0, 0.0, 1.0` -> Declares a constant vector whose color is orange with no transparency. |
|          |                        | ***Phase instructions***                                                      |                       |         |         |         |         |         |                                                                                                                                                                                                   |
| **Type** | **Phase instructions** | **Description**                                                               | **Instruction slots** | ``1.0`` | ``1.1`` | ``1.2`` | ``1.3`` | ``1.4`` | **Note**                                                                                                                                                                                          |
| ``asm``  | `phase`                | Transition between phase 1 and phase 2                                        | 0                     | ❌       | ❌       | ❌       | ❌       | ✅       |                                                                                                                                                                                                   |
|          |                        | ***Arithmetic instructions***                                                 |                       |         |         |         |         |         |                                                                                                                                                                                                   |
| **Type** | **Instruction**        | **Description**                                                               | **Instruction slots** | ``1.0`` | ``1.1`` | ``1.2`` | ``1.3`` | ``1.4`` | **Note**                                                                                                                                                                                          |
| ``asm``  | `add`                  | Add two vectors                                                               | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       | An instruction that assigns the addition of two values, for example:<br>`add r0, t0, t1` -> Assigns the value: ``(result0 = texture0 + texture1)``                                                |
| ``asm``  | `bem`                  | Apply a fake bump environment-map transform                                   | 2                     | ❌       | ❌       | ❌       | ❌       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `cmp`                  | Compare source to 0                                                           | 1¹                    | ❌       | ❌       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `cnd`                  | Compare source to 0.5                                                         | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `dp3`                  | Three-component dot product                                                   | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `dp4`                  | Four-component dot product                                                    | 1¹                    | ❌       | ❌       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `lrp`                  | Linear interpolate                                                            | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `mad`                  | Multiply and add                                                              | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `mov`                  | Move                                                                          | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `mul`                  | Multiply                                                                      | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       | An instruction that assigns the multiplication of two values, example:<br>`mul r0, t0, t1` -> Assigns the value: ``(result0 = texture0 * texture1)``                                              |
| ``asm``  | `nop`                  | No operation                                                                  | 0                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `sub`                  | Subtract                                                                      | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       | An instruction that assigns the subtraction of two values, example:<br>`sub r0, t0, t1` -> Assigns the value: ``(result0 = texture0 - texture1)``                                                 |
|          |                        | ***Texture instructions***                                                    |                       |         |         |         |         |         |                                                                                                                                                                                                   |
| ``asm``  | `tex`                  | Sample a texture                                                              | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texbem`               | Apply a fake bump environment-map transform                                   | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texbeml`              | Apply a fake bump environment-map transform with luminance correction         | 1+1²                  | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texcoord`             | Interpret texture coordinate data as color data                               | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texcrd`               | Copy texture coordinate data as color data                                    | 1                     | ❌       | ❌       | ❌       | ❌       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `texdepth`             | Calculate depth values                                                        | 1                     | ❌       | ❌       | ❌       | ❌       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `texdp3`               | Three-component dot product between texture data and the texture coordinates  | 1                     | ❌       | ❌       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texdp3tex`            | Three-component dot product and 1D texture lookup                             | 1                     | ❌       | ❌       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texkill`              | Cancels rendering of pixels based on a comparison                             | 1                     | ✅       | ✅       | ✅       | ✅       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `texld`                | Sample a texture                                                              | 1                     | ❌       | ❌       | ❌       | ❌       | ✅       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x2depth`         | Calculate per-pixel depth values                                              | 1                     | ❌       | ❌       | ❌       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x2pad`           | First row matrix multiply of a two-row matrix multiply                        | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x2tex`           | Final row matrix multiply of a two-row matrix multiply                        | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x3`              | 3x3 matrix multiply                                                           | 1                     | ❌       | ❌       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x3pad`           | First or second row multiply of a three-row matrix multiply                   | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x3spec`          | Final row multiply of a three-row matrix multiply                             | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x3tex`           | Texture look up using a 3x3 matrix multiply                                   | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texm3x3vspec`         | Texture look up using a 3x3 matrix multiply, with non-constant eye-ray vector | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texreg2ar`            | Sample a texture using the alpha and red components                           | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texreg2gb`            | Sample a texture using the green and blue components                          | 1                     | ✅       | ✅       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |
| ``asm``  | `texreg2rgb`           | Sample a texture using the red, green and blue components                     | 1                     | ❌       | ❌       | ✅       | ✅       | ❌       |                                                                                                                                                                                                   |

---

## Direct3D 9

## Direct3D 11

# Android

Android in different display modes uses the same GLSL version or none at all, this was confirmed by Naitor when he tested the final color result in the test shader using `#if __VERSION__ >= 330 ... #elif __VERSION__ >= 300` etc.
| **Display Mode**   | **GLSL Version**   | **Note**                         |
|--------------------|--------------------|----------------------------------|
| `OpenGL ES 1.1`    | `None`             | Shaders don't work with this API |
| `OpenGL ES 2.0`    | `GLSL 100`         |                                  |
| `OpenGL ES 3.0`    | `GLSL 100`         |                                  |

## Android OpenGL ES


# iOS and macOS

iOS and macOS use different versions of GLSL, this was confirmed by Naitor when he tested with Linky the final color result in a test shader using `#if __VERSION__ >= 330 ... #elif __VERSION__ >= 300` etc.
| **Runtime** | **GLSL Version**   | **Note** |
|-------------|--------------------|----------|
| `iOS`       | `GLSL 300`         |          |
| `macOS`     | `GLSL 150`         |          |

## iOS OpenGL ES

## macOS OpenGL ES

# HTML5
