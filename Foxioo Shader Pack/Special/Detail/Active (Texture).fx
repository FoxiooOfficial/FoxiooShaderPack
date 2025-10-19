/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.1 (18.10.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0) = sampler_state
{
    AddressU = BORDER;
    AddressV = BORDER;
    BorderColor = float4(0, 0, 0, 0);
};
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float   _Mixing,
            _Sharpness_Size,

            fPixelWidth, fPixelHeight;

    //bool    _Blending_Mode;

/************************************************************/
/* Main */
/************************************************************/

float2 Fun_Border(float2 In, float2 _Size, float _Alpha)
{
    _Size *= float2(fPixelWidth, fPixelHeight) * _Sharpness_Size;

    float2 _Result;
    _Result.x = (
        tex2D(S2D_Image, (In + _Size) ).a * 2.0 +
        tex2D(S2D_Image, (In - _Size) ).a * 2.0 
    ) - _Alpha * 2.0;

    _Result.y = (
        tex2D(S2D_Image, (In + _Size) ).a * 2.0 +
        tex2D(S2D_Image, (In - _Size) ).a / 2.0 
    ) - _Alpha;

    return _Result;
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = tex2D(S2D_Image, In);
    //float4 _Render_Background = tex2D(S2D_Background, In);

    float4 _Result;
    float2 _Result_Sharpness;

        //_Result_Sharpness = Fun_Border(In, 3.5, _Render_Texture.a);
        _Result.rgb = float3(0.0, 0.5, 0.5);// - _Result_Sharpness.x * 0.3999;
        
        /* ############################# */
        _Result_Sharpness = Fun_Border(In, 5., _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));

        _Result_Sharpness = Fun_Border(In, float2(-5., 5.), _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.2));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In, 4.95, _Render_Texture.a);
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y + 0.1), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 1.5));

        float2 _Result_Side_L = _Result_Sharpness;
        _Result_Sharpness = Fun_Border(In, float2(-4.95, 4.95), _Render_Texture.a);
        float2 _Result_Side_R = _Result_Sharpness;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 * (_Result_Sharpness.y), saturate((0.25 - saturate(abs(_Result_Sharpness.x * 6.0))) * 0.5));
        
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In, 2.0, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));

        _Result_Sharpness = Fun_Border(In, float2(-2.0, 2.0), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0),  saturate(0.5 - saturate(abs(_Result_Sharpness.x * 6.0))));
        /* ############################# */

        /* ############################# */
        _Result_Sharpness = Fun_Border(In, 1.85, _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0) + _Result_Side_L.y * 0.1, saturate((1.0 - saturate(abs(_Result_Sharpness.x * 6.0))) - (_Result_Side_L.y * 0.4)));

        _Result_Sharpness = Fun_Border(In, float2(-1.85, 1.85), _Render_Texture.a) * 0.3;
        _Result.rgb = lerp(_Result.rgb, float3(184.0, 219.0, 219.0) / 255.0 + min(_Result_Sharpness.y - 0.09, 0.0), 1.0 - saturate(abs(_Result_Sharpness.x * 6.0)));
        /* ############################# */

        _Result.rgb = lerp(_Render_Texture.rgb, _Result.rgb, _Mixing);
        _Result.a =  _Render_Texture.a;
    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
