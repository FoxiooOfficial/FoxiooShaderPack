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
            _ColorAlpha,
            _Size,
            _PosX,
            _PosY,

            _AlphaMul,
            _AlphaBack,

            fPixelWidth, fPixelHeight;

    float4 _Color, _ColorAccent;

    float4x4    transformMatrix,
                projectionMatrix; 

static const int _Samples = 16;

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

        float _Expanded = abs(max(_PosX + 1.0, _PosY + 1.0) * _Size);
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

float4 Fun_Render(sampler2D _Tex, float2 In) {
    if(any(In <= 0.0 || In >= 1.0))
        return 0.0;
    else
        return tex2D(_Tex, In);
}

float4 ps_main(VS_OUTPUT In) : COLOR0
{
    float4 _Render_Texture = Fun_Render(S2D_Image, In.texCoord);
    
    float _Alpha = 0.0;
    for(int y = 0; y <= _Samples; y++)
    {
        for(int x = 0; x <= _Samples; x++)
        {
            float2 _Offset = (float2(x, y) / (float)_Samples - 0.5) * _Size;
            
            _Offset = float2(fPixelWidth, fPixelHeight) * (_Offset + float2(_PosX, _PosY));
            _Alpha += Fun_Render(S2D_Image, In.texCoord + _Offset).a;
        }
    }
    
    _Alpha /= float(_Samples * _Samples);

    float _Outer = saturate(_Alpha * _AlphaMul) * (1.0 - _Render_Texture.a);
    //float _Inner = saturate((1.0 - _Alpha) * _AlphaMul) * _Render_Texture.a;

        float _Strength = saturate(_Outer);
        float _Mask = saturate((1.0 - _Render_Texture.a) + _AlphaBack);

        float4 _Render_Color = lerp(_ColorAccent, _Color, _Strength);
        _Render_Color.a = _Strength * _Mask * _ColorAlpha * _Mixing;

            float4 _Render = _Render_Texture;
            _Render.a *= _AlphaBack;

            float4 _Result;

        _Result.a = _Render_Color.a + _Render.a * (1.0 - _Render_Color.a);
        _Result.rgb = lerp(_Render.rgb, _Render_Color.rgb, _Render_Color.a / _Result.a);
        
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
