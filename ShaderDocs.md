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
- [Shader Model & Language Support](#shader-model--language-support)
  - [Windows](#windows)
    - [Direct3D 8](#direct3d-8)
    - [Direct3D 9](#direct3d-9)
    - [Direct3D 11](#direct3d-11)
  - [Android](#android)
    - [OpenGL ES](#android-opengl-es)
  - [iOS & macOS](#ios-and-macos)
    - [iOS OpenGL ES](#ios-opengl-es)
    - [macOS OpenGL ES](#macos-opengl-es)
  - [HTML5](#html5)
