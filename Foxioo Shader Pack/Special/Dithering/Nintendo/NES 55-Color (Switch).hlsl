/***********************************************************/

/* Copyright (c) 2024-2026 Foxioo */
/* Project repository page: https://github.com/FoxiooOfficial/FoxiooShaderPack */
/* MIT License; for more details, see: https://github.com/FoxiooOfficial/FoxiooShaderPack/blob/main/LICENSE */
/* Information about the shader version can be found in the effect's .xml file */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

Texture2D<float4> S2D_Background : register(t1);
SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    bool _Blending_Mode;
    float _Mixing;
    float _DitheringSize; 
    float _Add;
    float _Mul;
    bool __;
};

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : SV_POSITION;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

#define _Palette_Size 55

static const float3 _Palette[_Palette_Size] = 
{
    float3(0.4, 0.4, 0.4),
    float3(0.0, 0.164706, 0.533333),
    float3(0.078431, 0.070588, 0.658824),
    float3(0.231373, 0.0, 0.643137),
    float3(0.360784, 0.0, 0.494118),
    float3(0.431373, 0.0, 0.250980),
    float3(0.423529, 0.027451, 0.0),
    float3(0.341176, 0.113725, 0.0),
    float3(0.203922, 0.207843, 0.0),
    float3(0.047059, 0.286275, 0.0),
    float3(0.0, 0.321569, 0.0),
    float3(0.0, 0.309804, 0.031373),
    float3(0.0, 0.250980, 0.305882),
    float3(0.0, 0.0, 0.0),
    float3(0.682353, 0.682353, 0.682353),
    float3(0.082353, 0.372549, 0.854902),
    float3(0.258824, 0.250980, 0.996078),
    float3(0.462745, 0.152941, 1.0),
    float3(0.631373, 0.105882, 0.803922),
    float3(0.721569, 0.117647, 0.486275),
    float3(0.709804, 0.196078, 0.125490),
    float3(0.600000, 0.309804, 0.0),
    float3(0.423529, 0.431373, 0.0),
    float3(0.219608, 0.529412, 0.0),
    float3(0.050980, 0.580392, 0.0),
    float3(0.0, 0.564706, 0.196078),
    float3(0.0, 0.486275, 0.556863),
    float3(0.996078, 0.996078, 0.996078),
    float3(0.392157, 0.690196, 0.996078),
    float3(0.576471, 0.564706, 0.996078),
    float3(0.780392, 0.466667, 0.996078),
    float3(0.952941, 0.415686, 0.996078),
    float3(0.996078, 0.431373, 0.803922),
    float3(0.996078, 0.509804, 0.439216),
    float3(0.921569, 0.623529, 0.137255),
    float3(0.741176, 0.749020, 0.0),
    float3(0.537255, 0.850980, 0.0),
    float3(0.364706, 0.898039, 0.188235),
    float3(0.270588, 0.882353, 0.509804),
    float3(0.282353, 0.807843, 0.874510),
    float3(0.309804, 0.309804, 0.309804),
    float3(0.996078, 0.996078, 0.996078),
    float3(0.756863, 0.878431, 0.996078),
    float3(0.831373, 0.827451, 0.996078),
    float3(0.913725, 0.784314, 0.996078),
    float3(0.984314, 0.764706, 0.996078),
    float3(0.996078, 0.772549, 0.921569),
    float3(0.996078, 0.803922, 0.776471),
    float3(0.968627, 0.850980, 0.650980),
    float3(0.898039, 0.901961, 0.584314),
    float3(0.815686, 0.941176, 0.592157),
    float3(0.745098, 0.960784, 0.670588),
    float3(0.705882, 0.952941, 0.803922),
    float3(0.709804, 0.925490, 0.952941),
    float3(0.721569, 0.721569, 0.721569)
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
    float3 _High = pow(abs((_Color + 0.055) / 1.055), 2.4);

        return lerp(_High, _Low, step(_Color, float3(0.04045, 0.04045, 0.04045)));
}

float4 Demultiply(float4 _Render, bool _Premultiplied)
{
    if(_Premultiplied)
    {
	    if ( _Render.a != 0.0 ) {
            _Render.rgb /= _Render.a;
        }
    }

	return _Render;
}

float4 Main(in PS_INPUT In, bool _Premultiplied) : SV_TARGET
{
    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint, _Premultiplied);
    float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    _Render_Texture.rgb = _Render_Texture.rgb * _Mul + _Add;
    _Render_Background.rgb = _Render_Background.rgb * _Mul + _Add;

        float4 _Result, _Render;

        if(!_Blending_Mode) {
            _Result = _Render_Texture;
            _Render = _Render_Texture;
        }
        else {
            _Result.rgb = _Render_Background.rgb;
            _Result.a = _Render_Texture.a;
            
            _Render = _Render_Background;
        }

        int2 _Dith = int2(fmod(In.texCoord / float2(fPixelWidth, fPixelHeight), 4.0));

        int _Index = _Dith.x + _Dith.y * 4;
        float _DithValue = _Dithering[_Index];
                
            float3 _Color = _Result.rgb + (_DithValue - 0.5) * _DitheringSize;
                
            float _MinDist = 1e9;
            int _IndexC = 0;
            
                float3 _PO = Fun_Convert(_Color);
                for (int i = 0; i < _Palette_Size; i++)
                {
                    float3 _PL = Fun_Convert(_Palette[i]);
                    float3 _Diff = _PO - _PL;
                    float _Dist = dot(_Diff, _Diff);
                        
                    if (_Dist < _MinDist)
                    {
                        _MinDist = _Dist;
                        _IndexC = i;
                    }
                }

        _Result.rgb = _Palette[_IndexC];
        _Result.rgb = lerp(_Render.rgb, _Result.rgb, _Mixing); 

    return _Result;
}

/************************************************************/
/* Render */
/************************************************************/

float4 ps_main(in PS_INPUT In) : SV_TARGET { 
    float4 _Render = Main(In, false);
    return _Render;
}

float4 ps_main_pm(in PS_INPUT In) : SV_TARGET
{
    float4 _Render = Main(In, true);
    _Render.rgb *= _Render.a;

    return _Render;
}
