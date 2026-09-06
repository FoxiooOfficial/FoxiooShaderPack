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

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    bool    _Blending_Mode;

    float   _Mixing,
            _X, _Y,
            _PosX, _PosY,
            
            fPixelWidth, fPixelHeight;

    float4x4    transformMatrix,
                projectionMatrix;

struct VS_INPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    //float2 bgCoord  : TEXCOORD1;
    float4 Position : POSITION;
};

struct VS_OUTPUT
{
    float4 Tint     : COLOR0;
    float2 texCoord : TEXCOORD0;
    //float2 bgCoord  : TEXCOORD1;
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

            float2 _PivotMin = float2(0.0, 0.0) - float2(_PosX, _PosY);
            float2 _PivotMax = float2(1.0, 1.0) - float2(_PosX, _PosY);
            float2 _Pivot = max(abs(_PivotMin), abs(_PivotMax));

        float2 _Expanded = _Pivot * abs(float2(_X, _Y) * _Mixing);
        float2 _PixelPadding = _Expanded;
        float4 _PosExpanded = In.Position;

            _PosExpanded.xy += _DirCorner.xy * _Expanded / float2(fPixelWidth, fPixelHeight);

	Out.Position = mul(_PosExpanded, transformMatrix);
	Out.Position = mul(Out.Position, projectionMatrix);

	Out.Tint = In.Tint;
	Out.texCoord = In.texCoord + _DirCorner.xy * _PixelPadding;
    //Out.bgCoord = In.texCoord.bgCoord;// + _DirCorner.zw * _PixelPadding;

	return Out;
}
        
/************************************************************/
/* Main */
/************************************************************/

float4 Fun_Render(sampler2D _Tex, float2 In) {
    if(any(In <= 0.0 || In >= 1.0))
        return 0.0;
    else
        return tex2D(_Tex, In);
}

float4 ps_main(VS_OUTPUT In) : COLOR0
{   
    float4 _Render_Texture = Fun_Render(S2D_Image, In.texCoord);
    //return float4(In.texCoord.bgCoord.xy, 0.0, 1.0);
   
    float4 _Pivot, _Shear;
    _Pivot.xy = In.texCoord - float2(_PosX, _PosY);
    //_Pivot.zw = In.texCoord.bgCoord - float2(_PosX, _PosY);

    _Shear.xy = _Pivot.yx * float2(_X, _Y) * _Mixing;
    //_Shear.zw = _Pivot.wz * float2(_X, _Y) * _Mixing;

        float4 _Result = Fun_Render(S2D_Image, In.texCoord + _Shear.xy);

        if(_Blending_Mode)
            _Result = Fun_Render(S2D_Background, In.texCoord + _Shear.xy) * float4(1.0, 1.0, 1.0, _Result.a);

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
