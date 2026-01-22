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
            fPixelWidth, fPixelHeight;

    bool _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 20

static const float3 _Palette[20] = 
{
    float3(0.0, 0.0, 0.0),
    float3(1.0, 1.0, 1.0),

    float3(0.5019608, 0.5019608, 0.5019608),
    float3(0.7529412, 0.7529412, 0.7529412),

    float3(0.4901961, 0.0, 0.0),
    float3(0.9803922, 0.0, 0.0),

    float3(0.5058824, 0.4980392, 0.0),
    float3(1.0, 0.9921569, 0.2352941),

    float3(0.1176471, 0.5019608, 0.09803922),
    float3(0.2745098, 1.0, 0.2352941),

    float3(0.09803922, 0.5058824, 0.5019608),
    float3(0.2352941, 1.0, 1.0),

    float3(0.0, 0.04313726, 0.4901961),
    float3(0.0, 0.1294118, 0.9803922),

    float3(0.4862745, 0.0, 0.4901961),
    float3(0.972549, 0.0, 0.9803922),

    float3(0.5058824, 0.4980392, 0.2705882),
    float3(1.0, 0.9960784, 0.5372549),

    //float3(0.03137, 0.25098, 0.25098),
    //float3(0.26666, 1.0, 0.53725),

    float3(0.0, 0.5176471, 0.9843137),
    float3(0.5372549, 1.0, 1.0),

    //float3(0.0, 0.25882, 0.49411),
    //float3(0.49019, 0.51372, 0.98431),

    //float3(0.2, 0.12549, 0.98039),
    //float3(0.98039, 0.51372, 0.49019),

    //float3(0.4941176, 0.2431373, 0.03137255),
    //float3(0.9843137, 0.4862745, 0.2705882),
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
