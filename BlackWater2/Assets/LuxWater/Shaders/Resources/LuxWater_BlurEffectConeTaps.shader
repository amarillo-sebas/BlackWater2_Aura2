Shader "Lux Water/BlurEffectConeTap" 
{
	Properties { _MainTex ("", any) = "" {} }
	
	CGINCLUDE
		#include "UnityCG.cginc"
		struct v2f {
			float4 pos : SV_POSITION;
			half2 uv : TEXCOORD0;
			half2 taps[4] : TEXCOORD1;
			half2 origuv : TEXCOORD5;
		};
		
		sampler2D _MainTex;
		half4 _MainTex_TexelSize;
		half4 _BlurOffsets;

		sampler2D _UnderWaterTex;

		v2f vert( appdata_img v ) {
			v2f o; 
			o.pos = UnityObjectToClipPos(v.vertex);
			o.uv = v.texcoord - _BlurOffsets.xy * _MainTex_TexelSize.xy;
			o.origuv = v.texcoord;	
			
			/*#ifdef UNITY_SINGLE_PASS_STEREO
				// we need to keep texel size correct after the uv adjustment.
				o.taps[0] = UnityStereoScreenSpaceUVAdjust(o.uv + _MainTex_TexelSize * _BlurOffsets.xy * (1.0f / _MainTex_ST.xy), _MainTex_ST);
				o.taps[1] = UnityStereoScreenSpaceUVAdjust(o.uv - _MainTex_TexelSize * _BlurOffsets.xy * (1.0f / _MainTex_ST.xy), _MainTex_ST);
				o.taps[2] = UnityStereoScreenSpaceUVAdjust(o.uv + _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1) * (1.0f / _MainTex_ST.xy), _MainTex_ST);
				o.taps[3] = UnityStereoScreenSpaceUVAdjust(o.uv - _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1) * (1.0f / _MainTex_ST.xy), _MainTex_ST);
			#else*/

				o.taps[0] = o.uv + _MainTex_TexelSize * _BlurOffsets.xy;
				o.taps[1] = o.uv - _MainTex_TexelSize * _BlurOffsets.xy;
				o.taps[2] = o.uv + _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1);
				o.taps[3] = o.uv - _MainTex_TexelSize * _BlurOffsets.xy * half2(1, -1);
			//#endif
			return o;
		}

		half4 fragDownsample(v2f i) : SV_Target {
			half4 color = tex2D(_MainTex, i.taps[0]);
			color += tex2D(_MainTex, i.taps[1]);
			color += tex2D(_MainTex, i.taps[2]);
			color += tex2D(_MainTex, i.taps[3]);

			color.a = tex2D(_UnderWaterTex, i.taps[0]).a;
			color.a += tex2D(_UnderWaterTex, i.taps[1]).a;
			color.a += tex2D(_UnderWaterTex, i.taps[2]).a;
			color.a += tex2D(_UnderWaterTex, i.taps[3]).a;

			return color * 0.25;
		}

		half4 frag(v2f i) : SV_Target {
			half4 color = tex2D(_MainTex, i.taps[0]);
			color += tex2D(_MainTex, i.taps[1]);
			color += tex2D(_MainTex, i.taps[2]);
			color += tex2D(_MainTex, i.taps[3]);
			
			return color * 0.25;
		}
	ENDCG

	SubShader {
		Pass {
			ZTest Always Cull Off ZWrite Off
			CGPROGRAM
				#pragma vertex vert
				#pragma fragment frag
				#pragma target 2.0
			ENDCG
		}
	}
	Fallback off
}
