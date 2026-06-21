# Foxioo Shader Pack

<div align="center">
   <a href="https://github.com/FoxiooOfficial/FoxiooShaderPack">
       <img src="Resources/Logo/FSP.png" alt="Logo">
   </a>
</div>

Foxioo Shader Pack *(aka. "FSP")* is a huge, free and open-source shader pack created for Clickteam Fusion 2.5 to make your projects even more beautiful!

## Contents

- [About The Project](#about-the-project)
- [Technical Specifications](#technical-specifications)
- [Tools Used](#tools-used)
- [Special Thanks](#special-thanks)
- [Installation](#installation)
- [Configuration](#configuration)
- [Support and Social Media](#support-and-social-media)
- [License](#license)

## About The Project

**Foxioo Shader Pack is a project I’ve been developing since 2024, and its goal is to "fill in" the gaps in many effects within the Fusion community also i made it for a hobby and learning purposes;**

- In 2022/2023, I began experimenting with effects, learning the basics of HLSL, and modifying and building upon effects created by Looki *(Interestingly, I still have those effects on my hard drive from that time, and they haven’t been published in FSP-maybe I’ll publish them, but in improved versions)*.

Over the past year, I’ve realized that I’ve accomplished a lot, **but is it enough?**

- I want the effects to be available on every Fusion runtime; I’ve learned GLSL and delved deeper into HLSL, discovering cool things I can do.

**How long will I continue to support FSP?**

- As long as possible, adding new effects and improving the old ones, because even when Fusion 3 comes out, FSP will be updated to support the newer version of Fusion *(while continuing to support Fusion 2.5)*.

Shaders are amazing; thanks to them, I created another project called [Tails7](https://github.com/FoxiooOfficial/Tails7), which also replaces the outdated MMF2-era extension (namely [Mode7Ex](https://github.com/marcello3d/mode7ex)) with a framework/engine that runs on any runtime that supports effects, runs much faster, and adds support for simple polygons.

## Technical Specifications

- FSP currently has **420** effects;
- Description was last updated on **June 21, 2026**
- Effects were last updated on **June 21, 2026**
- Latest full release is from **[April 13, 2026](https://github.com/FoxiooOfficial/FoxiooShaderPack/releases/)**
- Supported Fusion version in FSP:
   - Minimum: **Build 295.10** *(Due to the `_Is_Pre_296_Build` flag, but starting with Fusion build 297, support will be removed and the target version-along with the minimum-will be the latest; if you are using old Fusion build, why?)*
   - Target: **Build 296.9**

**Effect Categories:**
| Category               | Description                                                                                                                                                                            |
|------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Blend Modes`            | Various effects called blending modes that you will find in graphics programs. They use colors from the object's texture and transform them in various ways using background colors. |
| `Coloristic`             | Effects in this category can manipulate the colors of your object's texture or background. They include colors that can transform hue, brightness, mask color, and similar effects.  |
| `Special`                | Effects in this category are intended to simulate a given thing or replicate shaders from other games.                                                                               |
| `Transformations`        | Effects in this category transform texCoords to scale, rotate, and offsets pixels from the texture.                                                                                  |
| `Unused or Experimental` | Effects that are only for testing purposes.                                                                                                                                          |

**Number of effects from 3 different types:**
| Type                                    | Description                                                                                                                            | Sum |
|-----------------------------------------|----------------------------------------------------------------------------------------------------------------------------------------|-----|
| `Background`                              | These shaders use the object texture and the background texture for calculations **OR** only background texture.                     | 208 |
| `Switch`                                  | These shaders use either the object texture **OR** the background texture depending on the setting of the `_Blending_Mode` variable. | 153 |
| `Texture`                                 | These shaders use **ONLY** the object texture **OR** object with external texture                                                    | 59  |
|                                           | **Number of all effects**                                                                                                            | 420 |

**Platform Support**
| Platform                | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         |
|-------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `Windows (Direct3D 8)`  | A very old API that supports up to Pixel Shader 1.4; shaders written in assembly language with very significant limitations; I know how to write effects for Direct3D 8, but it’s not worth it right now-why?<br>The `.fx` file is shared by Direct3D 8 and Direct3D 9, so if I write an effect for D3D8, I limit the effect for D3D9; if only the files weren’t shared and D3D8 had a file format like, for example, `.fxasm`, I’d be more than happy to support it; I can only hope that Clickteam changes this.<br>It’s interesting that I’ve probably written the only working effect for D3D8 over the years-looking by various forums and information, no one else has created anything for D3D8 for CTF/MMF2 |
| `Windows (Direct3D 9)`  | This is the basis for the effects in CTF/MMF2! Of course it supports them!<br>*(Not counting those more advanced effects that don't look the way they should or are "worse")*                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       |
| `Windows (Direct3D 11)` | Supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `Android`               | Supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `iOS`                   | Supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `macOS`                 | Supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          |
| `HTML5`                 | Not supported because the HTML5 Runtime **CURRENTLY** does not allow it; I'm are waiting for HTML5 Runtime V2, at which point it will be supported.                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| `Haxe`                  | *It hasn't come out yet, so how am I supposed to support something that hasn't come out yet???*        

## Tools Used

- [Clickteam Fusion 2.5](https://store.steampowered.com/app/248170/Clickteam_Fusion_25/)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Microsoft DirectX SDK Summber 2004](https://archive.org/details/dxsdk_sum2004)
- [Microsoft DirectX SDK November 2008](https://archive.org/details/dxsdk_nov08)
- [GLSL Editor](https://thebookofshaders.com/edit.php)
- [GLSLangValidator](https://github.com/KhronosGroup/glslang/releases)
- [Fusion 2.5+ DX11 Shader Compile Tool](https://github.com/defisym/OpenFusionExamples/tree/master/Tools/DX11%20Shader%20Compile%20Tool/EN_US)
- [Fusion FX: Shader Previewer for VS Code](https://discord.com/invite/R3WuvF3mHr)
---

## Special Thanks
| Person(s)                                                  | Description of how they helped me                                                      |
|------------------------------------------------------------|----------------------------------------------------------------------------------------|
| <a href="https://github.com/NaitorStudios">NaitorStudios</a>                                              | Help in explaining how to rewrite shaders for D3D11 Non-premultiplied Alpha to D3D11 Premultiplied Alpha also shared his knowledge about shaders also, special thanks for making amazing Fusion FX tool.          |
| <a href="https://linktr.ee/just_andrimal">Andrimal</a>                                                   | He composed the music for the trailer.                                                 |
| [Acerola](https://www.youtube.com/@Acerola_t)                                                    | Explanation in videos of how shaders work.                                             |
| [KYwoo](https://linktr.ee/KYwoo.socialss)                                                      | She helps create the Mangaish shader.                                                             |
| [Cazra](https://github.com/Cazra)                                                     | She created/modified/participated in the creation of some of the shaders that I modify. |
| [fnkycoldmadeanr](https://github.com/fnkycoldmadeanr)                                            | He created/modified/participated in the creation of some of the shaders that I modify. |
| [Looki](https://community.clickteam.com/user/5742-looki/)                                                      | He created/modified/participated in the creation of some of the shaders that I modify. |
| [gsueberland, JargeZ, r9m89git, SergeyMC9730, zhuker, constanton](https://github.com/JargeZ/ntscqt) | They created the ntscqt project, which helped me make the VHS shader.                  |
| [Toby Fox](https://x.com/tobyfox)                                                   | He created several effects for his game, which I recreated.                            |
| [Daniel Ilett](https://www.youtube.com/dilett07)                                               | He explained how to make a Minecraft Glint shader.                                     |
| [Adam Hawker (aka Sketchy / MuddyMole)](https://community.clickteam.com/user/7947-muddymole/)                      | He created/modified/participated in the creation of some of the shaders that I modify. |
| [Clickteam](https://www.youtube.com/@ClickteamLLC)                                                  | For creating the Fusion 2.5 engine.                                                    |
| [gsuberland](https://forums.getpaint.net/topic/30276-glitch-effect-plugin-polyglitch-v14b/)                                                 | He created the "Codebook" effect, which I recreated.                                   |
| [The Cherno](https://www.youtube.com/@TheCherno)                                                 | He explained how Unity Bloom works, which I recreated.                                 |
| [EriNixie](https://godotshaders.com/shader/actionlines-comic-anime/)                                                   | He created the "Actionlines Comic – Anime" effect, which I ported.                  |
| [MaPePeR](https://github.com/MaPePeR/jsColorblindSimulator)                                                    | He created the “jsColorblindSimulator” project, which helped me port several shaders.  |
| [小二今天吃啥啊](https://space.bilibili.com/437528440)                                              | He created a shader that mimics the skin of characters from the game Genshin Impact.   |

## Installation
1. Click on the **"Code"** button then **"Download ZIP"**.<br><br>
![Alt text](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Resources/Installaton/1.png?raw=true)<br>
2. Open Clickteam Fusion, go to the **"Tools"** tab and click **"Windows Explorer"**. **This will show you a window where Clickteam Fusion is installed.**<br><br>
![Alt text](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Resources/Installaton/2.png?raw=true)<br>
3. When the window where Clickteam Fusion is installed shows up, **open the ZIP file you downloaded before and in this ZIP file go to the "FoxiooShaderPack-main" folder.** In this folder, **copy the "Foxioo Shader Pack" folder and paste it in the "Effects" folder where Clickteam Fusion is installed.**<br><br>
![Alt text](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Resources/Installaton/3.png?raw=true)<br>

## Configuration

1. After the installation process, go to the **"Workspace Toolbar"** window, **select your application** and click **"Properties"**.<br><br>
![Alt text](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Resources/Usage/1.png?raw=true).<br>
2. Go to **"Runtime options"** and make sure **"Display Mode"** is set to **"Direct3D 11"** or **"Direct3D 9"**.<br><br>
![Alt text](https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/Resources/Usage/2.png?raw=true).<br>

## Support and Social Media
You can support the project or me by making a donation on [Kofi](https://ko-fi.com/foxioo)<br>
Here you can find my [social media accounts](https://foxiooofficial.github.io/links.html)

It’s thanks to ALL OF YOU that FSP has gained so much attention.<br>
*If you’re using this project and you like it, please leave a star! :3*

<details>
  <summary><b>Star History Chart</b></summary>
  <p align="center">
    <a href="https://star-history.com">
      <img src="https://api.star-history.com/svg?repos=FoxiooOfficial/FoxiooShaderPack&type=date" alt="Star History Chart" width="100%">
    </a>
  </p>
</details>

---

## License
This project is available under the terms of the **MIT** license

**TL;DR**:
- **You may:** use this code commercially, modify it, distribute it, and sublicense it.
- **You must:** include the original copyright notice with any copy of the project.
- **The author assumes no liability:** the code is provided "as is", without any warranty.

<details>
<summary><b>License Details</b></summary>

```text
MIT License

Copyright (c) 2024 Foxioo

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
 ```
</details>
