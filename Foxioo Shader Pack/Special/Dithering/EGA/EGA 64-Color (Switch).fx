/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (12.04.2026) */
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

    float   _Mixing, _DitheringSize,
            fPixelWidth, fPixelHeight;

    bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float Fun_Quant(float _Color)
{
    return floor(_Color * 3.0 + 0.5) / 3.0;
}

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

float3 Fun_Convert(float3 _Color)
{
    return float3(Fun_Quant(_Color.r), Fun_Quant(_Color.g), Fun_Quant(_Color.b));
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result;
        float4 _Render;

        if(_Blending_Mode == 0) {   _Result = _Render_Texture;      _Render = _Render_Texture;  }
        else                    {   _Result = _Render_Background;   _Render = _Render_Background; }

            int2 _Dith = int2(  fmod(In.x / fPixelWidth, 4.0), 
                                fmod(In.y / fPixelHeight, 4.0)
                            );

                int _Index = _Dith.x + _Dith.y * 4;
                float _DithValue = _Dithering[_Index];
                
                    float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                    _Color = saturate(_Color);

            _Result.rgb = Fun_Convert(_Color);

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_0 Main(); } }
