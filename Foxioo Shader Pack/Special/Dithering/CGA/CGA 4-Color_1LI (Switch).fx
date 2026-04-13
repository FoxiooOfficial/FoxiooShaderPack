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

#define _Palette_Size 4

static const float3 _Palette[_Palette_Size] = 
{
    float3(0.0, 0.0, 0.0),
    float3(0.14, 0.67, 0.67),
    float3(0.65, 0.0, 0.65),
    float3(0.67, 0.67, 0.67),
};

static const float _Dithering[16] =
{
    0.0 / 16.0,  8.0 / 16.0,  2.0 / 16.0, 10.0 / 16.0,
   12.0 / 16.0,  4.0 / 16.0, 14.0 / 16.0,  6.0 / 16.0,
    3.0 / 16.0, 11.0 / 16.0,  1.0 / 16.0,  9.0 / 16.0,
   15.0 / 16.0,  7.0 / 16.0, 13.0 / 16.0,  5.0 / 16.0
};

float3 Fun_Convert(float3 _Color)
{
    float3 _Low = _Color / 12.92;
    float3 _High = pow((_Color + 0.055) / 1.055, 2.4);

        return lerp(_High, _Low, step(_Color, float3(0.04045, 0.04045, 0.04045)));
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
                
                float _MinDist = 1e9;
                int _IndexC = 0;
                
                for (int i = 0; i < _Palette_Size; i++)
                {
                    float3 _PO = Fun_Convert(_Color);
                    float3 _PL = Fun_Convert(_Palette[i]);
                    
                    float _Dist = distance(_PO, _PL);
                    
                    if (_Dist < _MinDist)   {   _MinDist = _Dist;   _IndexC = i;    }
                }

            _Result.rgb = _Palette[_IndexC];

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
