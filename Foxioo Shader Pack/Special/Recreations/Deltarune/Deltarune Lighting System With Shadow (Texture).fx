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
    MinFilter = Point;
    MagFilter = Point;
    MipFilter = Point;
    AddressU = Clamp;
    AddressV = Clamp;
};

//sampler2D S2D_Background : register(s1);
//sampler2D _Texture : register(s1);

/***********************************************************/
/* Variables */
/***********************************************************/

struct PS_INPUT
{
    float4 Tint : COLOR0;
    float2 texCoord : TEXCOORD0;
    float2 bgCoord : TEXCOORD1;
};

    float   _Mixing,
            _PosX, _PosY,
            _OffsetX, _OffsetY,
            _Alpha,
            _Max,
            _Mul,
            _Footer,

            fPixelWidth, fPixelHeight;
    
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

        float2 _Expanded = float(_Alpha > 0.0f) * abs(float2(_OffsetX, _OffsetY)) + abs(float2(_PosX, _PosY)) + float2(64.0, 64.0);
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

float4 ps_main(VS_OUTPUT In) : COLOR0
//float4 ps_main(in PS_INPUT In) : COLOR0
{
    float4 _Render_Texture = Fun_PixelSample(S2D_Image, In.texCoord) * In.Tint;
    float2 _PixelSize = float2(fPixelWidth, fPixelHeight);

    // shadow
    float2 _LightPos = -(float2(_PosX, _PosY)) * _PixelSize;
    float _Anchor = 1.0 - _Footer * _PixelSize.y;

    float2 UV = In.texCoord + float2(_OffsetX, _OffsetY) * _PixelSize;
        UV.y = _Anchor + (_Anchor - UV.y) / _LightPos.y;
        UV.x += (UV.y - _Anchor) * _LightPos.x;

    float4 _Render_Shadow = Fun_PixelSample(S2D_Image, UV);
    _Render_Shadow.rgb = _ColorShadow * _ColorShadow;
    _Render_Shadow.a *= _Alpha  * In.Tint.a;
    
    if(_LightPos.y == 0.0f)
        _Render_Shadow.a = 0.0f;

    // rim light
    float4 _Result = _Render_Texture;

    float2 UVRim = _LightPos;
    //const float _Max = 2.0f;
        UVRim.x = clamp(UVRim.x, -_Max * _PixelSize.x, _Max * _PixelSize.x);
        UVRim.y = clamp(UVRim.y, -_Max * _PixelSize.y, _Max * _PixelSize.y);

    UVRim *= _Mul;

    float _Render_Rim = _Render_Texture.a - (Fun_PixelSample(S2D_Image, In.texCoord - UVRim * sign(_LightPos.y)).a * _LightPos.y)  * In.Tint.a;
        _Result.rgb = lerp( _Render_Texture.rgb * _ColorShadow.rgb, 
                            _Render_Texture.rgb + _ColorLight.rgb,
                            clamp(_Render_Rim, 0.0f, 1.5f));

    // result
        _Result = lerp(_Render_Shadow, _Result, _Render_Texture.a);
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