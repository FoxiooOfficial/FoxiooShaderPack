/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (11.04.2026) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing, _PixelSize,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);
    _Render_Background.a = _Render_Texture.a;

    int2 _Pixel = float2((int)(In.x / fPixelWidth), (int)(In.y / fPixelHeight));

    float _PixelSizeFix = _PixelSize == 0.0 ? 0.0001 : _PixelSize;
    float2 _Size = float2(1.0 / fPixelWidth, 1.0 / fPixelHeight) / _PixelSizeFix;

    float2 _UV = float2(ceil(In.x * _Size.x) / _Size.x, ceil(In.y * _Size.y) / _Size.y);


        float4 _Render_Texture_Ex = tex2D(S2D_Image, float2(_UV.x, _UV.y));
        float4 _Render_Background_Ex = tex2D(S2D_Background, float2(_UV.x, _UV.y));
        _Render_Background_Ex.a = _Render_Texture.a;

            float4 _Result = _Blending_Mode ? _Render_Background_Ex : _Render_Texture_Ex;
            float4 _Render = _Blending_Mode ? _Render_Background    : _Render_Texture;

            if ((_Pixel.x % 3) == 0)    _Result.rgb += float3(_Result.r, 0.0, 0.0);
            if ((_Pixel.x % 3) == 1)    _Result.rgb += float3(0.0, _Result.g, 0.0);
            else                        _Result.rgb += float3(0.0, 0.0, _Result.b);

        _Result = lerp(_Render, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 ps_main(); } }
