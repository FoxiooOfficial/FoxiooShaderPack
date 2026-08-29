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

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing, _Fade, _PosX, _PosY,
            fPixelWidth, fPixelHeight;

    float4  _Color;

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

        float _Expanded = abs(max(_PosX, _PosY));
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

float4 Fun_Render(sampler2D _Tex, float2 In, bool _Ex) {
    if(any(In <= 0.0 || In >= 1.0) || (_Fade < 1.0 - In.y && _Ex))
        return 0.0;
    else
        return tex2D(_Tex, In);
}

float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{   
    float4 _Render_Texture = Fun_Render(S2D_Image, In, false);

    float2 _Off = float2(_PosX, _PosY) * float2(fPixelWidth, fPixelHeight);
        
        float4 _Freeze_Sum;
        _Freeze_Sum.rgb = _Color.rgb;
        _Freeze_Sum.a  = Fun_Render(S2D_Image, In, true).a;
        _Freeze_Sum.a += Fun_Render(S2D_Image, In - _Off, true).a * 0.5;
        _Freeze_Sum.a += Fun_Render(S2D_Image, In + _Off, true).a * 0.5;
        
        _Freeze_Sum.a = saturate(_Freeze_Sum.a);
        _Freeze_Sum *= _Freeze_Sum.a;

           float4 _Result = saturate(_Freeze_Sum + _Render_Texture);
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
		PixelShader = compile ps_2_0 ps_main();
	}
}
