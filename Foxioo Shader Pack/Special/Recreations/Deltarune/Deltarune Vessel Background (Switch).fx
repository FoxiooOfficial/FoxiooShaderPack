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

sampler2D S2D_Image : register(s0);
sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,
            _Offset,
            _Time,
            fPixelWidth, fPixelHeight,

            _PointX, _PointY;
        
    bool    _Blending_Mode;

    int     _Quality;


    float4x4    transformMatrix,
                projectionMatrix;

struct VS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : POSITION;
};

struct VS_OUTPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    float4 Position : POSITION;
};


/************************************************************/
/* Vertex Shader */
/************************************************************/

VS_OUTPUT vs_main(VS_INPUT In)
{
	VS_OUTPUT Out;

	float2 _PixelSize = float2(fPixelWidth, fPixelHeight);
	float2 _DirCorner = sign(In.texCoord - 0.5);

        float _Expand = 0.0;

        float2 _PixelPadding = _Expand * float2(fPixelWidth, fPixelHeight);
        float4 _PosExpanded = In.Position;

            _PosExpanded.xy += _DirCorner * _Expand;

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner * _PixelPadding;

	return Out;
}

/************************************************************/
/* Main */
/************************************************************/

static const float _Pi = 3.14159265359;

float Fun_PixelInside(float2 In) {
	return all(In >= 0.0 && In <= 1.0);
}

float4 Fun_Vessel(sampler2D S2D, float2 UV)
{
    float4 _Result = (float4)0.0;
    float2 _Pos = float2(_PointX, _PointY);

        float _Inside;
        float _Weight = 0.0;
        int i;
        for(i = 0; i < _Quality; i++)  
        {
            float _T = float(i) / float(_Quality);
                float2 _In = ((UV - _Pos) * frac(_Time + _T)) + _Pos;
                float _Alpha = abs(sin((_Time + _T) * _Pi));

                _Inside = Fun_PixelInside(_In);
                float4 _Render = tex2D(S2D, saturate(lerp(UV, _In, _Offset))) * _Alpha;

                _Result += _Render;
                _Weight += _Alpha;
        }

        float4 _Render_Border = 0.0;

    return lerp(_Render_Border, _Result / _Weight, _Inside);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Render = _Blending_Mode ? _Render_Background : _Render_Texture;
        float4 _Result = _Blending_Mode ? Fun_Vessel(S2D_Background, In_Background) : Fun_Vessel(S2D_Image, In);

            _Result = lerp(_Render, _Result, _Mixing);

        if(_Blending_Mode)
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
		VertexShader = compile vs_1_1 vs_main();
        PixelShader = compile ps_3_0 ps_main();
    }
}
