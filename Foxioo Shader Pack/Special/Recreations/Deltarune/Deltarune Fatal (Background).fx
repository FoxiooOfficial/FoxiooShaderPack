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
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float       _Mixing, _Mul,
                fPixelWidth, fPixelHeight;

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

        float _Expanded = abs(_Mixing * _Mul);
        float2 _PixelPadding = _Expanded * float2(fPixelWidth, fPixelHeight);
        float4 _PosExpanded = In.Position;

            _PosExpanded.xy += _DirCorner * _Expanded;

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner * _PixelPadding;

	return Out;
}

/************************************************************/
/* Main */
/************************************************************/

float Fun_PixelInside(float2 In) {
	return all(In >= 0.0 && In <= 1.0);
}

float4 ps_main(VS_OUTPUT In) : COLOR0
{
    float2 UV = In.texCoord;
    UV.y = floor((1.0 - UV.y - 0.5) * 8.0) / 8.0;
    UV.y += 0.1 + _Mixing * fPixelHeight;
    UV.y *= lerp(1.0, UV.y, 0.5);

    float2 _In = In.texCoord;
    _In.x += max(UV.y * 1.5, 0.0) * -_Mixing * fPixelWidth * _Mul;

	float _Inside = Fun_PixelInside(_In);

    float4 _Render_Border = 0.0;
    float4 _Render_Texture = tex2D(S2D_Image, saturate(_In)) * In.Tint;

        float4 _Result = _Render_Texture;

        float _MixingAbs = abs(_Mixing) * fPixelWidth * 220.0;
        float _Grad = 1.0 - saturate(In.texCoord.y + 1.0 - _MixingAbs / 60.0);

        _Result.rgb *= lerp((float3)1.0, float3(1.0, 0.0, 0.0), _Grad * 3.0);
        _Result.a *= lerp(1.0, 0.0, _Grad);
        
	return lerp(_Render_Border, _Result, _Inside);
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main
{
	pass P0
	{
		VertexShader = compile vs_1_1 vs_main();
		PixelShader = compile ps_2_0 ps_main();
	}
}