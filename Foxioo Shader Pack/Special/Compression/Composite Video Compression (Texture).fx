/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (22.12.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
//sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mixing, _FraqMul, _Seed, _Time, _Hertz, _OffsetX_Pb, _OffsetY_Pb, _OffsetX_Pr, _OffsetY_Pr, _Phase,
    
    fPixelWidth, fPixelHeight;

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_GetColor(float2 In, sampler2D _Texture)
{
    return tex2D(_Texture, In);
}

float4 Fun_Interpolation(float2 In, float _Segm, sampler2D _Texture, float _Smoothness)
{
    float2 _In_Segment = floor(In * _Segm) / _Segm;
    float2 _In_Segment_Next = (floor(In * _Segm) + 1.0) / _Segm;
    
    float2 _UV = frac(In * _Segm);

        float4 _Render_0X = Fun_GetColor(_In_Segment, _Texture);
        float4 _Render_1X = Fun_GetColor(float2(_In_Segment_Next.x, _In_Segment.y), _Texture);
            
            float4 _Render_X = lerp(_Render_0X, _Render_1X, smoothstep(0.0, _Smoothness, _UV.x));


        float4 _Render_0Y = Fun_GetColor(float2(_In_Segment.x, _In_Segment_Next.y), _Texture);
        float4 _Render_1Y = Fun_GetColor(_In_Segment_Next, _Texture);
       
            float4 _Render_Y = lerp(_Render_0Y, _Render_1Y, smoothstep(0.0, _Smoothness, _UV.x));

    return lerp(_Render_X, _Render_Y, smoothstep(0.0, _Smoothness, _UV.y));
}

float3 Fun_Sharp_Ex(sampler2D _Sampler, float2 _In, float3 _Color, float _Sharpness_Size)
{
    float3 _Result_Sharpness = 5 * _Color - (
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            ).rgb;

    return _Color - _Result_Sharpness * 0.1;
}

float Fun_Sharp(sampler2D _Sampler, float2 _In, float3 _Color, float _Sharpness_Size)
{
    float3 _Result_Sharpness = 5 * _Color - (
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                tex2D(_Sampler, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            ).rgb;

    return (_Color.r + _Color.g + _Color.b) / 3.0 * 2.0 - (_Result_Sharpness.r + _Result_Sharpness.g + _Result_Sharpness.b) / 3.0;
}

float Fun_Rand(float2 _UV)
{
    return frac(sin(dot(_UV, float2(12.9898, 78.233))) * 43758.5453);
}

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    In.x -= fmod(In.y + _Time, fPixelHeight * 1125.0 / (_Hertz * -10.0 + 1125.0)) * fPixelWidth * _Phase * _Mixing;
    //return float4(In, 0, 1);
    //float4 _Render_Background = tex2D(S2D_Image, In);

        /* Low Quality */
        static const float _Div = 576.0;
        float4 _Result_Pb = Fun_Interpolation(In + float2(_OffsetX_Pb * fPixelWidth, _OffsetY_Pb * fPixelHeight), _Div, S2D_Image, 1.25);
        float4 _Result_Pr = Fun_Interpolation(In + float2(_OffsetX_Pr * fPixelWidth, _OffsetY_Pr * fPixelHeight), _Div, S2D_Image, 1.25);
        float4 _Result = tex2D(S2D_Image, In);

            /* RGB -> Y'UV (Y'PbPr) */
            const float _Kr = 0.299;
            const float _Kg = 0.587;
            const float _Kb = 0.114;

            float _Y = _Kr * _Result.r + _Kg * _Result.g + _Kb * _Result.b;
            float _Pb = -0.168736 * _Result_Pb.r - 0.331264 * _Result_Pb.g + 0.5 * _Result_Pb.b;
            float _Pr = 0.5 * _Result_Pr.r - 0.418688 * _Result_Pr.g - 0.081312 * _Result_Pr.b;

                /* Multiplex */
                //static const float _NTSC = 2.0 * 3.14159265359 * 3579545;
                //static const float _PAL = 2.0 * 3.14159265359 * 4433618.75;

               float _Omega = 2.0 * 3.14159265359 * (3579545.0 + (_Hertz - 59.94) * ((4433618.75 - 3579545.0) / (50.0 - 59.94)));

                        float _Chroma_1 = _Pb * cos((_Omega * _FraqMul)) + _Pr * sin((_Omega * _FraqMul));
                        float _Chroma_2 = _Pb * cos((_Omega * _FraqMul) - 2.0) + _Pr * sin((_Omega * _FraqMul) - 2.0);
                        float _Chroma_3 = _Pb * cos((_Omega * _FraqMul) + 2.0) + _Pr * sin((_Omega * _FraqMul) + 2.0);

                /* Demultiplex */
                float _PbFix = (( _Chroma_2 * cos((_Omega * _FraqMul) - 2.0)) + ( _Chroma_1 * cos((_Omega * _FraqMul))) + ( _Chroma_3 * cos((_Omega * _FraqMul) + 2.0))) / 3.0;
                float _PrFix = (( _Chroma_2 * sin((_Omega * _FraqMul) - 2.0)) + ( _Chroma_1 * sin((_Omega * _FraqMul))) + ( _Chroma_3 * sin((_Omega * _FraqMul) + 2.0))) / 3.0;

                float _Edge = Fun_Sharp(S2D_Image, In, _Result.rgb, 1.0);
                _Y +=     (sin((In.x - In.y) * 10000.0 * _Edge   + _Time) * _Edge)   * 0.04;
                _PbFix += (sin((In.x + In.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;
                _PrFix += (cos((In.x + In.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;

            /* Meow RGB */
            float _R = _Y + 1.402 * _PrFix;
            float _G = _Y - 0.344136 * _PbFix - 0.714136 * _PrFix;
            float _B = _Y + 1.772 * _PbFix;

            float3 _Render = Fun_Sharp_Ex(S2D_Image, In, float3(_R, _G, _B), 1.0 - _Y);
            //_Render = lerp(_Render, _Render.r * _Render.g * _Render.b, 0.35); 

            float _Rand = Fun_Rand(In.x + In.y + _Seed) * _Edge;
                _Render.r += abs(sin(_Rand * 5345435.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.g += abs(sin(_Rand * 1204358.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.b += abs(cos(_Rand * 7568234.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);

                _Result.rgb = lerp(_Result.rgb, _Render, _Mixing);
        _Result.a = _Render_Texture.a;

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_b Main(); } }
