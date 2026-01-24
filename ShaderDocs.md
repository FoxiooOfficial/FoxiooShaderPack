# Unofficial documentation on shaders in Clickteam Fusion

### This is an information library designed to organize what works and what doesn't work in Clickteam Fusion.
All information is based on:
- [My knowledge and experiments](https://github.com/FoxiooOfficial/)
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

Shaders written for Direct3D 8 are written in **assembler**, the code should be located in the .fx file in which we also write shaders for Direct3D 9, if a shader works for D3D8, it will also work for D3D9, but this is one-way compatibility, i.e. D3D8 does not fully support the HLSL language.

For the D3D8 effect to work, you must also insert `dx8>yes</dx8>` in the **.xml** file

[Example code](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Release/Unused%20or%20Experimental/D3D8Test%20(Texture).zip):
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

Asembler pixel shader składa się z zestawu instrukcji, które działają na danych pikseli zawartych w rejestrach. 
Operacje wyrażane są jako instrukcje składające się z operatora i jednego lub większej liczby operandów. 
Instrukcje wykorzystują rejestry do przesyłania danych do i z shadera piksele ALU. Niektóre instrukcje mogą również wykorzystywać rejestry do przechowywania wyników tymczasowych.

<br>

Każda wersja obsługuje inną liczbę maksymalnych slotów instrukcji.

**Pixel Shader Versions**
| **Type**  | **Version**  | **Works** | **Dependent<br>texture<br>limit** | **Texture <br>instruction<br>limit** | **Arithmetic<br>instruction<br>limit** | **Position<br>register** | **Instruction<br>slots** | **Executed<br>instructions** | **Texture<br>indirections** | **Interpolated<br>registers** | **Instruction<br>predication** | **Index<br>input<br>registers** | **Temp<br>registers** | **Constant<br>registers** | **Arbitrary<br>swizzling** | **Gradient<br>instructions** | **Loop <br>count <br>register** | **Face<br>register** | **Dynamic<br>flow<br>control** | **Bitwise<br>Operators** | **Native<br>Integers** | **Note** |
|-------|----------|-------|-------------------------------|----------------------------------|------------------------------------|----------------------|----------------------|--------------------------|-------------------------|---------------------------|----------------------------|-----------------------------|-------------------|-----------------------|------------------------|--------------------------|-----------------------------|------------------|----------------------------|----------------------|--------------------|-------------------------------------------------------------------------------------------------------------------------------|
| `asm` | `ps.1.0` | ❔     | 4                             | 4                                | 8                                  | ❌                    | 8                    | 8                        | 4                       | 2 + 4                     | ❌                          | ❌                           | 2                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  | It's possible that the compiler forces the use of `ps.1.1`                                                                    |
| `asm` | `ps.1.1` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 2 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.2` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.3` | ✅     | 4                             | 4                                | 8                                  | ❌                    | 8 + 4                | 8 + 4                    | 4                       | 2 + 4                     | ❌                          | ❌                           | 3 + 4             | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  |                                                                                                                               |
| `asm` | `ps.1.4` | ✅     | 6                             | 6 * 2                            | 8 * 2                              | ❌                    | (8 + 6) * 2          | (8 + 6) * 2              | 4                       | 2 + 8                     | ❌                          | ❌                           | 6                 | 8                     | ❌                      | ❌                        | ❌                           | ❌                | ❌                          | ❌                    | ❌                  | Texture declaration is different compared to `ps.1.0`, `ps.1.1`, `ps.1.2`, and `ps.1.3`. |

`(8 + 6) * 2` for **Executed instructions** means:
- *8 texture instructions and 6 arithmetic instructions in 2 phases*.
- i.e. total of *16 texture instructions and 12 arithmetic instructions*.

<br>

Programowalny moduł cieniujący wierzchołki składa się z zestawu instrukcji działających na danych wierzchołków.
Rejestry przesyłają dane do i z jednostki ALU.
Można zastosować dodatkową kontrolę w celu modyfikacji instrukcji, wyników lub tego, jakie dane zostaną zapisane.

<br>

Każda wersja obsługuje różną liczbę maksymalnych slotów instrukcji.

**Vertex Shader Versions**
| **Type**  | **Version**  | **Works** | **Number of<br>instruction<br>slots** | **Max<br>number of<br>instructions<br>executed** | **Instruction<br>predication** | **Temp<br>register** | **Number<br>constant<br>registers** | **Address<br>register** | **Static<br>flow<br>control** | **Dynamic<br>flow<br>control** | **Dynamic<br>flow<br>control<br>depth** | **Vertex<br>texture<br>fetch** | **Number of<br>texture<br>samplers** | **Geometry<br>instancing<br>support** | **Bitwise<br>operators** | **Native<br>integers** | **Note** |
|-------|----------|-------|-----------------------------------|----------------------------------------------|----------------------------|------------------|---------------------------------|---------------------|---------------------------|----------------------------|-------------------------------------|----------------------------|----------------------------------|-----------------------------------|----------------------|--------------------|---------------------------------------------------------------------------------|
| `asm` | `vs.1.0` | ❌     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ❌                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  | The compiler throws a warning about lack of support for `vs.1.0` and uses `vs.1.1`. |
| `asm` | `vs.1.1` | ✅     | 128                               | 128                                          | ❌                          | 12               | >= 96                           | ✅                   | ❌                         | ❌                          | 0                                   | ❌                          | 0                                | ❌                                 | ❌                    | ❌                  |                                                                                 |

---

### Input/Output registers for Pixel Shader [(Source)](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx9-graphics-reference-asm-ps-registers-ps-1-x)
**Dla Pixel Shader od 1.0 do 1.4, opierają się na rejestrach w celu:**
- Pobierania danych wierzchołkowych
- Wyprowadzania danych pikselowych
- Przechowywania tymczasowych wyników podczas obliczeń
- Dentyfikowania etapów próbkowania tekstur

<br>

**Legenda:**
- W kolumnie Register jest opisany jak wygląda, w miejscu `#` powinna być wartość, przykład: `c0`, `t1`, `r0`, `v2`. W opisie jest napisane do czego służy rejestr.
- Read Port Limit opisuje ograniczenia dotyczące korzystania z wielu rejestrów w jednej instrukcji.
- Read-Only lub Read/Write opisuje, które rejestry mogą być używane do odczytu, zapisu lub obu.
- Zakres opisuje zakres danych komponentu *(W Fusion 2.5 nie wiadomo jaka jest wartość `PixelShader1xMaxValue` i `MaxTextureRepeat`)*

**Constant register:**
- Zawierają stałe dane. Dane można załadować do rejestru stałego za pomocą instrukcji `def`. Rejestry stałe nie nadają się do wykorzystania w instrukcjach adresowania tekstur. Jedynym wyjątkiem jest instrukcja `texm3x3spec`, która wykorzystuje stały rejestr do dostarczenia wektora promieniowania oka.

**Temporary register:**
- Służą do przechowywania wyników pośrednich. `r0` służy dodatkowo jako wyjście shadera pikseli. Wartość w r0 na końcu shadera to kolor piksela dla shadera.

**Texture register**
- W przypadku shaderów pikseli w wersjach od `ps.1.1` do `ps.1.3` rejestry tekstur zawierają dane tekstur lub współrzędne tekstur.<br>
  Dane tekstury są ładowane do rejestru tekstur podczas próbkowania tekstury.<br>
  Próbkowanie tekstury wykorzystuje współrzędne tekstury do wyszukiwania lub próbkowania wartości koloru na określonych współrzędnych *(U'V, W'Q)*, biorąc pod uwagę atrybuty stanu etapu tekstury.<br>
  Dane współrzędnych tekstury są **interpolowane** z danych współrzędnych tekstury wierzchołka i są powiązane z określonym etapem tekstury.<br>
  Istnieje domyślne powiązanie jeden do jednego pomiędzy numerem etapu tekstury a kolejnością deklaracji współrzędnych tekstury.<br>
  Domyślnie pierwszy zestaw współrzędnych tekstury zdefiniowanych w formacie wierzchołka jest powiązany z etapem tekstury 0.<br>

- W przypadku tych wersji shaderów pikseli rejestry tekstur zachowują się tak samo jak rejestry tymczasowe, gdy są używane przez instrukcje arytmetyczne.

- W przypadku Pixel Shader w wersji `ps.1.4` rejestry tekstur `(t#)` zawierają dane współrzędnych tekstur tylko do odczytu.<br>
  Oznacza to, że zestaw współrzędnych tekstury i numer etapu tekstury są od siebie niezależne. Numer etapu tekstury *(z którego można pobrać próbkę tekstury)* jest określany przez numer rejestru docelowego **(r0 do r5)**.<br>
  W przypadku instrukcji `texld` zestaw współrzędnych tekstury jest określany przez rejestr źródłowy **(t0 do t5)**, dzięki czemu zestaw współrzędnych tekstury można odwzorować na dowolny etap tekstury.<br>
  Ponadto rejestr źródłowy *(określający współrzędne tekstury)* dla `texld` może być również rejestrem tymczasowym `(r#)`, w którym to przypadku zawartość rejestru tymczasowego jest używana jako współrzędne tekstury.<br>

**Color register:**
- Służą do przekazywania danych z Vertex Shadera do Pixel Shadera.

<br>

**Read limit:**
- Limit portu odczytu określa liczbę różnych rejestrów każdego typu rejestru, które mogą być użyte jako rejestr źródłowy w jednej instrukcji.

<br>

**Read-Only and Read/Write:**
- Typy rejestrów są identyfikowane zgodnie z możliwością tylko do odczytu **(Read-Only)** lub możliwością odczytu/zapisu **(Read/Write)**. Rejestry tylko do odczytu mogą być używane tylko jako rejestry źródłowe w instrukcji; nigdy nie mogą być używane jako rejestr docelowy.

<br>

**Range:**
- Zakres to maksymalna i minimalna wartość danych rejestru. Zakresy różnią się w zależności od rodzaju rejestru.
- Wczesny sprzęt do cieniowania pikseli reprezentuje dane w rejestrach przy użyciu liczby stałoprzecinkowej. Ogranicza to precyzję do maksymalnie około ośmiu bitów dla ułamkowej części liczby.

<br>

| **Type** | **Register** | **Description**    | ``ps.1.0`` | ``ps.1.1``                                                                                                            | ``ps.1.2``                                                                                                                | ``ps.1.3``                                                                                                                | ``ps.1.4``                                                                                                                | **Note** |
|----------|--------------|--------------------|---------|--------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------|----------|
| ``asm``  | `c#`         | Constant register  | ❔     | Count: **8**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **-1 to 1**                                          | Count: **8**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **-1 to 1**                                          | Count: **8**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **-1 to 1**                                          | Count: **8**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **-1 to 1**                                          |          |
| ``asm``  | `r#`         | Temporary register | ❔     | Count: **2**<br>Read limit: **2**<br><br>**Read/Write**<br><br>Range: **-PixelShader1xMaxValue to PixelShader1xMaxValue** | Count: **2**<br>Read limit: **2**<br><br>**Read/Write**<br><br>Range: **-PixelShader1xMaxValue to PixelShader1xMaxValue** | Count: **2**<br>Read limit: **2**<br><br>**Read/Write**<br><br>Range: **-PixelShader1xMaxValue to PixelShader1xMaxValue** | Count: **6**<br>Read limit: **3**<br><br>**Read/Write**<br><br>Range: **-PixelShader1xMaxValue to PixelShader1xMaxValue** |          |
| ``asm``  | `t#`         | Texture register   | ❔     | Count: **4**<br>Read limit: **2**<br><br>**Read/Write**<br><br>Range: **-MaxTextureRepeat to MaxTextureRepeat**           | Count: **4**<br>Read limit: **3**<br><br>**Read/Write**<br><br>Range: **-MaxTextureRepeat to MaxTextureRepeat**           | Count: **4**<br>Read limit: **3**<br><br>**Read/Write**<br><br>Range: **-MaxTextureRepeat to MaxTextureRepeat**           | Count: **6**<br>Read limit: **1**<br><br>-<br><br>Range: **-MaxTextureRepeat to MaxTextureRepeat**                        |          |
| ``asm``  | `v#`         | Color register     | ❔     | Count: **4**<br>Read limit: **2**<br><br>**Read/Write**<br><br>Range: **0 to 1**                                          | Count: **2**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **0 to 1**                                           | Count: **2**<br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **0 to 1**                                           | Count: **2** in **phase 2**<br><br>Read limit: **2**<br><br>**Read-Only**<br><br>Range: **0 to 1**                        |          |

### Input/Output registers for Vertex Shader [(Source)](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx9-graphics-reference-asm-vs-registers-vs-1-1)

| **Type** | **Register** | **Description**             | **Input / Output** | ``vs.1.0`` | ``vs.1.1``                                                                                                                                                                                                                                                      | **Note**                                                                                                                                     |
|----------|--------------|-----------------------------|--------------------|------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------|
| ``asm``  | `a#`         | Address Register            | `Input`            | ❔          | Count: **1**<br><br>**Read/Write**<br><br>Read limit: **1**<br>Reads inst: **Unlimited**<br><br>Dimension: *Only .x channel is available*<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                          |                                                                                                                                              |
| ``asm``  | `c#`         | Constant Float Register     | `Input`            | ❔          | Count: *Equal to D3DCAPS9.MaxVertexShaderConst (at least 96 for vs_1_1).*<br><br>**Read-Only**<br><br>Read limit: **1**<br>Reads inst: **Unlimited**<br><br>Dimension: 4<br>Default Value **(0, 0, 0, 0)**<br><br>RelAddr: **a0.x**<br><br>Requires DCL: **No** | We don't know the value of `D3DCAPS9.MaxVertexShaderConst` in Fusion, it's probably **96**                                                   |
| ``asm``  | `v#`         | Constant Float Register     | `Input`            | ❔          | Count: **16**<br><br>**Read-Only**<br><br>Read limit: **1**<br>Reads inst: **Unlimited**<br><br>Dimension: 4<br>Default Value *Check Note*<br><br>RelAddr: **No**<br><br>Requires DCL: **Yes**                                                                  | For default value: <br>Partial (0, 0, 0, 1) - If only a subset of channels are updated, the remaining channels will default to (0, 0, 0, 1). |
| ``asm``  | `r#`         | Temporary Register          | `Input`            | ❔          | Count: **12**<br><br>**Read/Write**<br><br>Read limit: **3**<br>Reads inst: **Unlimited**<br><br>Dimension: **4**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                  |                                                                                                                                              |
| ``asm``  | `oPos`       | Position Register           | `Output`           | ❔          | Count: **1**<br><br>**Write-Only**<br><br>Read limit: **0**<br>Reads inst: **0**<br><br>Dimension: **4**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                           |                                                                                                                                              |
| ``asm``  | `oFog`       | Fog Register                | `Output`           | ❔          | Count: **1**<br><br>**Write-Only**<br><br>Read limit: **0**<br>Reads inst: **0**<br><br>Dimension: **1**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                           |                                                                                                                                              |
| ``asm``  | `oPts`       | Point Size Register         | `Output`           | ❔          | Count: **1**<br><br>**Write-Only**<br><br>Read limit: **0**<br>Reads inst: **0**<br><br>Dimension: **1**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                           |                                                                                                                                              |
| ``asm``  | `oD#`        | Color Register              | `Output`           | ❔          | Count: **2**<br><br>**Write-Only**<br><br>Read limit: **0**<br>Reads inst: **0**<br><br>Dimension: **4**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                           | `oD0` is the diffuse color output; `oD1` is the specular color output.                                                                       |
| ``asm``  | `oT#`        | Texture Coordinate Register | `Output`           | ❔          | Count: **8**<br><br>**Write-Only**<br><br>Read limit: **0**<br>Reads inst: **0**<br><br>Dimension: **4**<br>Default Value **None**<br><br>RelAddr: **No**<br><br>Requires DCL: **No**                                                                           |                                                                                                                                              |

---


### Instruction Set [(Source 1)](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx9-graphics-reference-asm-ps-instructions-ps-1-x) [(Source 2)](https://web.archive.org/web/20120911164630/https://user.xmission.com/~legalize/book/download/13-Pixel%20Shaders.pdf)

This section contains reference information for the pixel shader version `ps.1.x` instructions.
There are several types of pixel shader instructions, as shown in the following table.

**Instruction set for Pixel Shader**
| **Type** | **Instruction**        | **Description**                                                               | **Instruction slots** | ``ps.1.0`` | ``ps.1.1`` | ``ps.1.2`` | ``ps.1.3`` | ``ps.1.4`` | **Note**                                                                                                                                                                                          |
|----------|------------------------|-------------------------------------------------------------------------------|-----------------------|---------|---------|---------|---------|---------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| ``asm``  | `ps`                   | Version number                                                                | 0                     | ✅       | ✅       | ✅       | ✅       | ✅       | Used at the beginning of the assembler, it defines the version of the effect that is being written for. Example:<br>`ps.1.1` -> Uses Pixel Shader version 1.1                                     |
|          |                        | ***Constant instructions***                                                   |                       |         |         |         |         |         |                                                                                                                                                                                                   |
| **Type** | **Instruction**        | **Description**                                                               | **Instruction slots** | ``1.0`` | ``1.1`` | ``1.2`` | ``1.3`` | ``1.4`` | **Note**                                                                                                                                                                                          |
| ``asm``  | `def`                  | Define constants                                                              | 0                     | ✅       | ✅       | ✅       | ✅       | ✅       | It declares constant values. The syntax looks like this: `def c#, r, g, b, a`. Example:<br>`def c0, 1.0, 0.5, 0.0, 1.0` -> Declares a constant vector whose color is orange with no transparency. |
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

`1¹` for **Instruction slots** means:
- The number `1` indicates that the instruction occupies 1 instruction slot in the pixel shader limit.
- The number `¹` means that in different versions of the pixel shader, the number of instructions may vary.

**Instruction set for Vertex Shader**

This section contains reference information for the vertex shader version `ps.1.1` instructions.

There are several types of vertex shader instructions, as shown in the table. Columns to the right mean the following:
- **Instruction slots** - Number of instruction slots used by each instruction.
- **Setup** - Non-arithmetic instructions. Every shader must have a version instruction and it must be the first instruction.
- **Arithmetic** - These instructions provide the mathematical operations in a shader.

| **Type** | **Instruction** | **Description**                | **Instruction slots** | **Setup** | **Arithmetic** | ``vs.1.0`` | ``vs.1.1`` | **Note** |
|----------|-----------------|--------------------------------|-----------------------|-----------|----------------|------------|------------|----------|
| ``asm``  | `add`           | Add two vectors                | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `dcl_usage`     | Declare input vertex registers | 0                     | ☑️         |                | ❔          | ✅          |          |
| ``asm``  | `def`           | Define constants               | 0                     | ☑️         |                | ❔          | ✅          |          |
| ``asm``  | `dp3`           | Three-component dot product    | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `dp4`           | Four-component dot product     | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `dst`           | Calculate the distance vector  | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `exp`           | Full precision 2^x             | 10                    |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `expp`          | Partial precision 2^x          | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `frc`           | Fractional component           | 3                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `lit`           | Partial lighting calculation   | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `log`           | Full precision log₂(x)         | 10                    |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `logp`          | Partial precision log₂(x)      | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `m3x2`          | 3x2 multiply                   | 2                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `m3x3`          | 3x3 multiply                   | 3                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `m3x4`          | 3x4 multiply                   | 4                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `m4x3`          | 4x3 multiply                   | 3                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `m4x4`          | 4x4 multiply                   | 4                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `mad`           | Multiply and add               | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `max`           | Maximum                        | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `min`           | Minimum                        | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `mov`           | Move                           | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `mul`           | Multiply                       | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `nop`           | No operation                   | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `rcp`           | Reciprocal square root         | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `sge`           | Greater than or equal compare  | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `sit`           | Less than compare              | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `sub`           | Subtract                       | 1                     |           | ☑️              | ❔          | ✅          |          |
| ``asm``  | `vs`            | Declare vertex shader version  | 0                     | ☑️         |                | ❔          | ✅          |          |

---

### Modifiers Set [(Source)](https://learn.microsoft.com/en-us/windows/win32/direct3dhlsl/dx9-graphics-reference-asm-ps-instructions-modifiers-ps-1-x)
| **Type** | **Modifier** | **Description**               | **Syntax**          | ``ps.1.0`` | ``ps.1.1`` | ``ps.1.2`` | ``ps.1.3`` | ``ps.1.4`` | **Note** |
|----------|--------------|-------------------------------|---------------------|---------|---------|---------|---------|---------|----------|
| ``asm``  | `_x2`        | Multiply by 2                 | `#instruction#_x2`  | ❔       | ✅       | ✅       | ✅       | ✅       |          |
| ``asm``  | `_x4`        | Multiply by 4                 | `#instruction#_x4`  | ❔       | ✅       | ✅       | ✅       | ✅       |          |
| ``asm``  | `_x8`        | Multiply by 8                 | `#instruction#_x8`  | ❔       | ❌       | ❌       | ❌       | ✅       |          |
| ``asm``  | `_d2`        | Divide by 2                   | `#instruction#_d2`  | ❔       | ✅       | ✅       | ✅       | ✅       |          |
| ``asm``  | `_d4`        | Divide by 4                   | `#instruction#_d4`  | ❔       | ✅       | ✅       | ✅       | ✅       |          |
| ``asm``  | `_d8`        | Divide by 8                   | `#instruction#_d8`  | ❔       | ❌       | ❌       | ❌       | ✅       |          |
| ``asm``  | `_sat`       | Saturate (clamp from 0 and 1) | `#instruction#_sat` | ❔       | ✅       | ✅       | ✅       | ✅       |          |

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
