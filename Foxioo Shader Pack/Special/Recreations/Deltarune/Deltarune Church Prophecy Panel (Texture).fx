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
sampler2D _Texture : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

    float   _Mixing,
            _PosX, _PosY,
            _Scale, _ScaleX, _ScaleY,

            _OffsetX, _OffsetY,

            fPixelWidth, fPixelHeight;

    bool    _Color;
    
    float4  _ColorLight, _ColorShadow;

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

        float2 _Expanded = abs(float2(_OffsetX, _OffsetY) * 2.0);
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
/* Pixel Shader */
/************************************************************/

float Fun_PixelInside(float2 In) {
	return all(In >= 0.0 && In <= 1.0);
}

float4 Fun_PixelSample(sampler2D _Sampler, float2 In) {
	return tex2D(_Sampler, saturate(In)) * Fun_PixelInside(In);
}

float Fun_Lum(float4 _Result) {
    return dot(_Result.rgb, float3(0.2126, 0.7152, 0.0722)) * _Result.a;
}

float4 ps_main(VS_OUTPUT In) : COLOR0
//float4 ps_main(in float2 In : TEXCOORD0, in float2 In_Background : TEXCOORD1) : COLOR0
{
    float4 _Render_Texture = Fun_PixelSample(S2D_Image, In.texCoord);

        /* main panel */
        float2 UV = In.texCoord + float2(_PosX, _PosY);
        UV = (UV * float2(_ScaleX, _ScaleY) * _Scale) / 256.0;
        UV /= float2(fPixelWidth, fPixelHeight);
        UV = UV - floor(UV); // frac(UV)?

            float _Render_Texture_Lum = Fun_Lum(_Render_Texture);
            float4 _Texture_UV = Fun_PixelSample(_Texture, UV);

            float4 _Result = _Texture_UV;
            float _Result_Lum = Fun_Lum(_Result);

            _Result.a *= _Render_Texture_Lum;

            // sub panels
            float2 _UV_Echo = float2(_OffsetX, _OffsetY) * float2(fPixelWidth, fPixelHeight);
            
                float4 _Echo1 = Fun_PixelSample(S2D_Image, In.texCoord + _UV_Echo);
                    _Result.a += Fun_Lum(_Echo1) / 2.0;

                float4 _Echo2 = Fun_PixelSample(S2D_Image, In.texCoord + _UV_Echo * 2.0);
                    _Result.a += Fun_Lum(_Echo2) / 3.0;

        /* End */
            if(_Color)
                _Result.rgb = lerp(_ColorShadow.rgb, _ColorLight.rgb, _Result_Lum);

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
        PixelShader = compile ps_2_0 ps_main();
        VertexShader = compile vs_1_1 vs_main();
    }
}