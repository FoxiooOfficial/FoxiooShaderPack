/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
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
            _Seed,
            
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;


/************************************************************/
/* Main */
/************************************************************/

float3 Fun_Hash21(float3 _Color) 
{ 
    float3 _Noise;
    _Noise.x = frac(_Seed + sin(((_Color.x - _Seed) * 12.9898 + 78.233)) * 43758.5453);
    _Noise.y = frac(_Seed + sin(((_Color.y - _Seed) * 63.7264 + 10.873)) * 73156.8473);
    _Noise.z = frac(_Seed + sin(((_Color.z - _Seed) * 43.5276 + 37.735)) * 12931.5923);
    return _Noise;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Render;

            _Result.rgb = Fun_Hash21(_Result.rgb);
            _Result.rgb = Fun_Hash21(1.0 - _Result.rgb);

                    int _Pixel = (int)(In.x / fPixelWidth);
                    
                    if((_Pixel % 2) == 0) _Result.rgb = _Result.gbr;
                    if((_Pixel % 3) == 0) _Result.rgb = _Result.brg;

                    _Result.rgb = Fun_Hash21(1.0 - _Result.rgb);

                    _Result.rgb = 1.0 - _Result.gbr;

            _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing);
            _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
