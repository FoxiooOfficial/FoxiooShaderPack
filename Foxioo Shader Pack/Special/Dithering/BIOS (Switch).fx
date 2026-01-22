/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (19.10.2026) */
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

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 16

static const float3 _Palette[16] = 
{
    float3(0.0, 0.0, 0.0),
    float3(0.0, 0.0705882353, 0.6509803922),
    float3(0.1686274510, 0.6666666667, 0.1450980392),
    float3(0.1411764706, 0.6705882353, 0.6666666667),
    float3(0.6549019608, 0.0, 0.0039215686),
    float3(0.6470588235, 0.0039215686, 0.6509803922),
    float3(0.6588235294, 0.3215686275, 0.0549019608),
    float3(0.6666666667, 0.6666666667, 0.6666666667),
    float3(0.3333333333, 0.3333333333, 0.3333333333),
    float3(0.3058823529, 0.3568627451, 0.9803921569),
    float3(0.4196078431, 1.0, 0.4),
    float3(0.3960784314, 1.0, 1.0),
    float3(0.9803921569, 0.3098039216, 0.3333333333),
    float3(0.9764705882, 0.3333333333, 0.9803921569),
    float3(1.0, 0.9921568627, 0.4039215686),
    float3(1.0, 1.0, 1.0),
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

            float3 _Lin = Fun_Convert(_Result.rgb);
            float _Min = 1e9;   int   _Final = 0;

            for (int i = 0; i < _Palette_Size; ++i)
            {
                float3 _LinP = Fun_Convert(_Palette[i]);
                float _Dist = dot(_Lin - _LinP, _Lin - _LinP);

                if (_Dist < _Min) { _Min = _Dist; _Final = i; }
            }

            _Result.rgb = _Palette[_Final];

        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
