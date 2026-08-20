/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (05.04.2026) */
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

    float   _Mixing,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture;
    float4 _Render_Background;

    int2 _Pixel = float2((int)(In.x / fPixelWidth), (int)(In.y / fPixelHeight));

            float4 _Result = 0.0;   

                _Render_Texture = tex2D(S2D_Image, In + float2(fPixelWidth, fPixelHeight));
                _Render_Background = tex2D(S2D_Background, In + (fPixelWidth, fPixelHeight));
                float4 _RenderOff2 = _Blending_Mode ? _Render_Background : _Render_Texture;
                
                _Render_Texture = tex2D(S2D_Image, In);
                _Render_Background = tex2D(S2D_Background, In);
                float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;

            /* x-axis */
            if ((_Pixel.x % 3) == 0)    _Result.rgb = float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.x % 3) == 1)    _Result.rgb = float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb = float3(_RenderOff2.r, 0.0, _Render.b);

            /* y-axis */
            if ((_Pixel.y % 3) == 0)    _Result.rgb += float3(_Render.r, _RenderOff2.g, 0.0);
            if ((_Pixel.y % 3) == 1)    _Result.rgb += float3(0.0, _Render.g, _RenderOff2.b);
            else                        _Result.rgb += float3(_RenderOff2.r, 0.0, _Render.b);


        _Result.rgb = lerp(_Render.rgb, _Result.rgb / 2.0, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a ps_main(); } }
