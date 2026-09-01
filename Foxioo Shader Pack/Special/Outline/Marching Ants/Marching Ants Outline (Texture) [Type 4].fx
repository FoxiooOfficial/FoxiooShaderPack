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

    float   _Mixing,
            _Size, _Offset,
            fPixelWidth, fPixelHeight;

    float4  _Shadow, _Light;

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

        float _Expanded = _Offset;
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

#define KERNEL 1

float4 Fun_Render(sampler2D _Tex, float2 In) {
    if(any(In <= 0.0 || In >= 1.0))
        return 0.0;
    else
        return tex2D(_Tex, In);
}

float4 ps_main(VS_INPUT In) : COLOR0
{
    float4 _Render_Texture = Fun_Render(S2D_Image, In.texCoord);
    //float4 _Render_Background = tex2D(S2D_Background, In_Background);

        float4 _Result;
        float2 _Pixel = float2(fPixelWidth, fPixelHeight);

        float _Outline = saturate(any(In.texCoord < 0.0 || In.texCoord > 1.0));

        float2 UV = (float2)(int2)ceil(In.texCoord / _Pixel / _Size);
        float _Pattern = saturate(fmod(UV.x + UV.y + 2.0, 2.0));

        UV *= 1.0 / _Pixel / 32.0;
        UV /= _Size;

            _Pattern = round(_Pattern);

                _Result = float4((float3)lerp(_Shadow.rgb, _Light.rgb, _Pattern), _Outline);
                _Result = lerp(_Render_Texture, _Result, _Result.a);

            _Result = lerp(_Render_Texture, _Result, _Mixing);

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
		PixelShader = compile ps_2_a ps_main();
	}
}
