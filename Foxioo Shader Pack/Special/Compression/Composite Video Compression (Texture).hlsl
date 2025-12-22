/***********************************************************/

/* Autor shader: Foxioo */
/* Version shader: 1.0 (22.12.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/
Texture2D<float4> S2D_Image : register(t0);
SamplerState S2D_ImageSampler : register(s0);

//Texture2D<float4> S2D_Background : register(t1);
//SamplerState S2D_BackgroundSampler : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

cbuffer PS_VARIABLES : register(b0)
{
    bool _;
    float _Mixing;
    float _Seed;
    float _Time;
    float _FraqMul;
    float _Hertz;
    float _OffsetX_Pb;
    float _OffsetY_Pb;
    float _OffsetX_Pr;
    float _OffsetY_Pr;
    float _Phase;
    bool __;
};

struct PS_INPUT
{
  float4 Tint : COLOR0;
  float2 texCoord : TEXCOORD0;
};

struct PS_OUTPUT
{
    float4 Color   : SV_TARGET;
};

cbuffer PS_PIXELSIZE : register(b1)
{
	float fPixelWidth;
	float fPixelHeight;
};

/************************************************************/
/* Main */
/************************************************************/

float4 Fun_GetColor(float2 In, Texture2D _Sampler, SamplerState _Texture)
{
    return _Sampler.Sample(_Texture, In);
}

float4 Fun_Interpolation(float2 In, float _Segm, Texture2D _Sampler, SamplerState _Texture, float _Smoothness)
{
    float2 _In_Segment = floor(In * _Segm) / _Segm;
    float2 _In_Segment_Next = (floor(In * _Segm) + 1.0) / _Segm;
    
    float2 _UV = frac(In * _Segm);

        float4 _Render_0X = Fun_GetColor(_In_Segment, _Sampler, _Texture);
        float4 _Render_1X = Fun_GetColor(float2(_In_Segment_Next.x, _In_Segment.y), _Sampler, _Texture);
            
            float4 _Render_X = lerp(_Render_0X, _Render_1X, smoothstep(0.0, _Smoothness, _UV.x));


        float4 _Render_0Y = Fun_GetColor(float2(_In_Segment.x, _In_Segment_Next.y), _Sampler, _Texture);
        float4 _Render_1Y = Fun_GetColor(_In_Segment_Next, _Sampler, _Texture);
       
            float4 _Render_Y = lerp(_Render_0Y, _Render_1Y, smoothstep(0.0, _Smoothness, _UV.x));

    return lerp(_Render_X, _Render_Y, smoothstep(0.0, _Smoothness, _UV.y));
}

float3 Fun_Sharp_Ex(Texture2D _Sampler, SamplerState _Texture, float2 _In, float3 _Color, float _Sharpness_Size)
{
    float3 _Result_Sharpness = 5 * _Color - (
                _Sampler.Sample(_Texture, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            ).rgb;

    return _Color - _Result_Sharpness * 0.1;
}

float Fun_Sharp(Texture2D _Sampler, SamplerState _Texture, float2 _In, float3 _Color, float _Sharpness_Size)
{
    float3 _Result_Sharpness = 5 * _Color - (
                _Sampler.Sample(_Texture, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In + (_Sharpness_Size * float2(fPixelWidth, fPixelHeight))) +
                _Sampler.Sample(_Texture, _In - (_Sharpness_Size * float2(fPixelWidth, fPixelHeight)))
            ).rgb;

    return (_Color.r + _Color.g + _Color.b) / 3.0 * 2.0 - (_Result_Sharpness.r + _Result_Sharpness.g + _Result_Sharpness.b) / 3.0;
}

float Fun_Rand(float2 _UV)
{
    return frac(sin(dot(_UV, float2(12.9898, 78.233))) * 43758.5453);
}

PS_OUTPUT ps_main( in PS_INPUT In )
{
    PS_OUTPUT Out;

    float4 _Render_Texture = S2D_Image.Sample(S2D_ImageSampler, In.texCoord) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    In.texCoord.x -= fmod(In.texCoord.y + _Time, fPixelHeight * 1125.0 / (_Hertz * -10.0 + 1125.0)) * fPixelWidth * _Phase * _Mixing;
    //return float4(In, 0, 1);
    //float4 _Render_Background = tex2D(S2D_Image, In);

        /* Low Quality */
        static const float _Div = 576.0;
        float4 _Result_Pb = Fun_Interpolation(In.texCoord + float2(_OffsetX_Pb * fPixelWidth, _OffsetY_Pb * fPixelHeight), _Div, S2D_Image, S2D_ImageSampler, 1.25);
        float4 _Result_Pr = Fun_Interpolation(In.texCoord + float2(_OffsetX_Pr * fPixelWidth, _OffsetY_Pr * fPixelHeight), _Div, S2D_Image, S2D_ImageSampler, 1.25);
        float4 _Result = S2D_Image.Sample(S2D_ImageSampler, In.texCoord);

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

                float _Edge = Fun_Sharp(S2D_Image, S2D_ImageSampler, In.texCoord, _Result.rgb, 1.0);
                _Y +=     (sin((In.texCoord.x - In.texCoord.y) * 10000.0 * _Edge   + _Time) * _Edge)   * 0.04;
                _PbFix += (sin((In.texCoord.x + In.texCoord.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;
                _PrFix += (cos((In.texCoord.x + In.texCoord.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;

            /* Meow RGB */
            float _R = _Y + 1.402 * _PrFix;
            float _G = _Y - 0.344136 * _PbFix - 0.714136 * _PrFix;
            float _B = _Y + 1.772 * _PbFix;

            float3 _Render = Fun_Sharp_Ex(S2D_Image, S2D_ImageSampler, In.texCoord, float3(_R, _G, _B), 1.0 - _Y);
            //_Render = lerp(_Render, _Render.r * _Render.g * _Render.b, 0.35); 

            float _Rand = Fun_Rand(In.texCoord.x + In.texCoord.y + _Seed) * _Edge;
                _Render.r += abs(sin(_Rand * 5345435.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.g += abs(sin(_Rand * 1204358.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.b += abs(cos(_Rand * 7568234.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);

                _Result.rgb = lerp(_Result.rgb, _Render, _Mixing);
        _Result.a = _Render_Texture.a;

    Out.Color = _Result;
    
    return Out;
}

/************************************************************/
/* Premultiplied Alpha */
/************************************************************/

float4 Demultiply(float4 _Color)
{
	if ( _Color.a != 0 )   _Color.rgb /= _Color.a;
	return _Color;
}

PS_OUTPUT ps_main_pm( in PS_INPUT In ) 
{
    PS_OUTPUT Out;

    float4 _Render_Texture = Demultiply(S2D_Image.Sample(S2D_ImageSampler, In.texCoord)) * In.Tint;
    //float4 _Render_Background = S2D_Background.Sample(S2D_BackgroundSampler, In.texCoord);

    In.texCoord.x -= fmod(In.texCoord.y + _Time, fPixelHeight * 1125.0 / (_Hertz * -10.0 + 1125.0)) * fPixelWidth * _Phase * _Mixing;
    //return float4(In, 0, 1);
    //float4 _Render_Background = tex2D(S2D_Image, In);

        /* Low Quality */
        static const float _Div = 576.0;
        float4 _Result_Pb = Fun_Interpolation(In.texCoord + float2(_OffsetX_Pb * fPixelWidth, _OffsetY_Pb * fPixelHeight), _Div, S2D_Image, S2D_ImageSampler, 1.25);
        float4 _Result_Pr = Fun_Interpolation(In.texCoord + float2(_OffsetX_Pr * fPixelWidth, _OffsetY_Pr * fPixelHeight), _Div, S2D_Image, S2D_ImageSampler, 1.25);
        float4 _Result = S2D_Image.Sample(S2D_ImageSampler, In.texCoord);

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

                float _Edge = Fun_Sharp(S2D_Image, S2D_ImageSampler, In.texCoord, _Result.rgb, 1.0);
                _Y +=     (sin((In.texCoord.x - In.texCoord.y) * 10000.0 * _Edge   + _Time) * _Edge)   * 0.04;
                _PbFix += (sin((In.texCoord.x + In.texCoord.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;
                _PrFix += (cos((In.texCoord.x + In.texCoord.y) * 1000000.0 * _Edge + _Time) * _Edge) * 0.04;

            /* Meow RGB */
            float _R = _Y + 1.402 * _PrFix;
            float _G = _Y - 0.344136 * _PbFix - 0.714136 * _PrFix;
            float _B = _Y + 1.772 * _PbFix;

            float3 _Render = Fun_Sharp_Ex(S2D_Image, S2D_ImageSampler, In.texCoord, float3(_R, _G, _B), 1.0 - _Y);
            //_Render = lerp(_Render, _Render.r * _Render.g * _Render.b, 0.35); 

            float _Rand = Fun_Rand(In.texCoord.x + In.texCoord.y + _Seed) * _Edge;
                _Render.r += abs(sin(_Rand * 5345435.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.g += abs(sin(_Rand * 1204358.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);
                _Render.b += abs(cos(_Rand * 7568234.0 + _Time) * _Edge * _Y) * pow(_Y, 5.0);

                _Result.rgb = lerp(_Result.rgb, _Render, _Mixing);
        _Result.a = _Render_Texture.a;

    _Result.rgb *= _Result.a;

    Out.Color = _Result;
    return Out;
}