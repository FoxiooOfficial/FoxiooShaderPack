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

sampler2D S2D_Image : register(s0) = sampler_state
{
    MinFilter = Linear;
    MagFilter = Linear;
};

sampler2D S2D_Background : register(s1) = sampler_state
{
    MinFilter = Linear;
    MagFilter = Linear;
};

/***********************************************************/
/* Varibles */
/***********************************************************/

/*
float4x4 transformMatrix;
float4x4 projectionMatrix;

struct VS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : POSITION;
};

struct PS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : POSITION;
};
*/

    float   _Size, _Mixing,
            
            fPixelWidth, fPixelHeight;
    int    _Quality;

    bool    _Blending_Mode;

/************************************************************/
/* Vertex Shader */
/************************************************************/

/*
    Based on "Blur (outside rect)"
    Created by: Sphax - Flavien Clermont / NaitorStudios
*/
/*
PS_INPUT Fun_VertexExpand(VS_INPUT input, float2 InOff)
{
	PS_INPUT _Output;

	float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
	float2 _DirCorner = sign(input.texCoord - 0.5);
    
	    float2 _PixelPadding = InOff / _PixelSize; // Radius
	    float4 _PosExpanded = input.Position;

	        _PosExpanded.xy += _DirCorner * _PixelPadding;

	_Output.Position = mul(_PosExpanded, transformMatrix);
	_Output.Position = mul(_Output.Position, projectionMatrix);
    
    _Output.Tint = input.Tint;
	_Output.texCoord = input.texCoord + _DirCorner * InOff;

	return _Output;
}

PS_INPUT vs_main(VS_INPUT input)
{
	return Fun_VertexExpand(input, _Size * float2(fPixelWidth, fPixelHeight));
}
*/

/************************************************************/
/* Pixel Shader */
/************************************************************/

/*
float Fun_PixelInside(float2 In) {
	return all(In >= 0.0 && In <= 1.0);
}

float4 Fun_PixelSample(sampler2D _Sampler, float2 In) {
	return tex2D(_Sampler, saturate(In)) * Fun_PixelInside(In);
}
*/


float3 Fun_Filter(sampler2D _Sampler, float2 In, float3 _Render)
{
    float3 _Result = _Render;

    float _Center = (float(_Quality) - 1.0) / 2.0;
    float2 _SizePixel = _Size * float2(fPixelWidth,  fPixelHeight) / float(_Quality);

    float3 _Min = (float3)1.0;
    float3 _Max = (float3)0.0;

    int x; int y;
    for(y = 0; y < _Quality; y++)
    {  
        for(x = 0; x < _Quality; x++)
        {
            float xx = float(x) - _Center;
            float yy = float(y) - _Center;

            float2 UV = In + float2(xx, yy) * _SizePixel;

            _Result = tex2D(_Sampler, UV).rgb;
            _Min = min(_Result.rgb, _Min);
            _Max = max(_Result.rgb, _Max);
        }
    }

    return _Max - _Min;
}

//float4 ps_main(PS_INPUT In) : COLOR0
float4 ps_main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In);

        float4 _Result = _Blending_Mode ? _Render_Background : _Render_Texture;
        float3 _Filter = _Blending_Mode ? Fun_Filter(S2D_Background, In, _Render_Background.rgb)
                                        : Fun_Filter(S2D_Image, In, _Render_Texture.rgb);

        _Result.rgb = lerp(_Result.rgb, _Filter, _Mixing);
        _Result.a = _Render_Texture.a;
    
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
    pass P0
    {
        PixelShader = compile ps_3_0 ps_main();
        VertexShader = NULL;
    }
}