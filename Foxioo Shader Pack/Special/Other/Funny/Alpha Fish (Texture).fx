/***********************************************************/

/* Shader author: Foxioo */
/* Version shader: 1.0 (25.12.2025) */
/* My GitHub: https://github.com/FoxiooOfficial */

/***********************************************************/

/* ####################################################### */

/***********************************************************/
/* Samplers */
/***********************************************************/

sampler2D S2D_Image : register(s0);
// sampler2D S2D_Background : register(s1);

/***********************************************************/
/* Varibles */
/***********************************************************/

    float _Mixing;

/************************************************************/
/* Main */
/************************************************************/

float4 Main(in float2 In : TEXCOORD0) : COLOR0
{
    float4 _Render_Texture = (tex2D(S2D_Image, In));
    //float4 _Render_Background = tex2D(S2D_Background, In);
        
        In *= 1.12;
        In.x -= 0.05;
        float4 _Result = float4(In, 0.0, 1.0);

        float2 _Center = float2(In * 2.0) - 1.2;
        float _Cirl = sqrt(_Center.x * _Center.x + _Center.y * _Center.y);

        
        float2 _CenterTopShadow = float2(In * 2.0) - float2(1.5, 0.3);
            float _CenterTopShadowCirl = sqrt(_CenterTopShadow.x * _CenterTopShadow.x + _CenterTopShadow.y * _CenterTopShadow.y);

        float2 _CenterBottomShadow = float2(In * 2.0) - float2(1.5, 1.3);
            float _CenterBottomShadowCirl = sqrt(_CenterBottomShadow.x * _CenterBottomShadow.x + _CenterBottomShadow.y * _CenterBottomShadow.y);

        if(In.y > 0.55) 
        _Cirl *= lerp(0.96, 1.0, 1.0 - pow(In.y - 0.55, 0.2));

            float3 _TopColor = lerp(float3(0.9921, 0.79215, 0.0), float3(0.69803, 0.56078, 0.0), _CenterTopShadowCirl * _CenterTopShadowCirl);
            float _Depth = pow(abs(0.55 - In.y), 3);
            float3 _BottomColor = lerp(float3(1.0, 0.9176, 0.0), float3(0.70196, 0.64313, 0.0), (_CenterBottomShadowCirl));
            _BottomColor *= pow(_Depth, 0.001);

            _Result.a = _Cirl < 0.90;
            _Result.rgb = lerp(_TopColor, _BottomColor * 1.1, In.y > 0.55);

            float2 _Fish1In = In;
                _Fish1In.x -= 0.27;
                _Fish1In.y += 0.65;
                _Fish1In.x *= 1.1;
                float _Fish1 = ((_Fish1In.y + (pow(_Fish1In.x, 0.15 - pow(_Fish1In.x, 3.0)) * (1.0 - _Fish1In.x * 1.2)) * 0.5) * 0.5 > 0.5) * (_Fish1In.x > 0.0) * (_Fish1In.y < 1.0) * (_Fish1In.x < 0.6);
                _Result = lerp(_Result,float4(_TopColor, 1.0), _Fish1);

            //////////////////////////////////////
            float2 _Center2 = ((float2(In * 2.0) - 1.1) / float2(0.2, 0.3)) + float2(4.3, 0.0);
            _Center2.x += In.y;
            float2 _CenterTailDist = ((float2(In * 2.0) - 1.1) / float2(0.2, 0.3)) + float2(4.3, 0.5);
            float _CenterTail = sqrt(_CenterTailDist.x * _CenterTailDist.x + _CenterTailDist.y * _CenterTailDist.y);
            float4 _TailColor = lerp(float4(0.69803, 0.56078, 0.0, 1.0), float4(1.0, 0.9176, 0.0, 1.0), 1.0 - _CenterTail * 0.5);

            float _Fish2 = sqrt(_Center2.x * _Center2.x + _Center2.y * _Center2.y) < 0.9;
            _Result = lerp(_Result, _TailColor, _Fish2);

            //////////////////////////////////////
            float2 _Center3 = ((float2(In * 2.0) - 1.1) / float2(0.4 / In.y * 0.5, 0.3)) + float2(0.35, In.x * 0.5 - 0.5);
            float _Fish3 = sqrt(_Center3.x * _Center3.x + _Center3.y * _Center3.y);

            float2 _Center3Mid = _Center3 - float2(0.1, -0.2);
            float _FishMid = sqrt(_Center3Mid.x * _Center3Mid.x + _Center3Mid.y * _Center3Mid.y);
            float3 _MidColor = lerp(float3(0.9921, 0.79215, 0.0), float3(0.69803, 0.56078, 0.0), _FishMid * _FishMid);
            _Result.rgb = lerp(_Result.rgb, _MidColor, _Fish3 < 0.9);
    
            //////////////////////////////////////
            float2 _EyeCenter = (float2(In * 2.0) - 1.1) + float2(-0.57, 0.2);
            float _Eye = sqrt(_EyeCenter.x * _EyeCenter.x + _EyeCenter.y * _EyeCenter.y);

            float2 _EyeBloomCenter = (float2(In * 2.0) - 1.1) + float2(-0.54, 0.23);
            float _EyeBloomCirl = sqrt(_EyeBloomCenter.x * _EyeBloomCenter.x + _EyeBloomCenter.y * _EyeBloomCenter.y) * 7.0;

                float3 _EyeBloom = lerp(float3( 0.6, 0.6, 0.6), float3(0.1137, 0.1137, 0.1137), pow(_EyeBloomCirl, 0.25));
                _Result.rgb = lerp(_Result.rgb, _EyeBloom, _Eye < 0.11);
        
        _Result.a *= _Render_Texture.a;
        _Result = lerp(_Render_Texture, _Result, _Mixing);

    return _Result;
}

/************************************************************/
/* Tech Main */
/************************************************************/

technique tech_main { pass P0 { PixelShader = compile ps_2_a Main(); } }
