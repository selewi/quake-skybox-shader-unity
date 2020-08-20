/**
* Author: Tomás Esconjaureguy (a.k.a selewi)
**/
Shader "Retro/QuakeSkybox"
{
	Properties
	{
		_MainTex("Texture", 2D) = "white" {}
		_MainTexSpeed("Texture Speed", Float) = 2
		_SecondaryTex("Secondary Texture", 2D) = "white" {}
		_SecondaryTexSpeed("Texture Speed", Float) = 5
		_CutOff("Cutoff", Range(0, 1)) = 0
		_SphereSize("Sphere Size", Range(0, 10)) = 5
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" }
		ZWrite On ZTest Lequal
		Blend SrcAlpha OneMinusSrcAlpha

		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
			};

			struct v2f
			{
				float3 worldView : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldView = -WorldSpaceViewDir(v.vertex);
				return o;
			}

			sampler2D _MainTex;
			float4 _MainTex_ST;
			float _MainTexSpeed;
			sampler2D _SecondaryTex;
			float4 _SecondaryTex_ST;
			float _SecondaryTexSpeed;
			float _CutOff;
			float _SphereSize;

			fixed4 frag(v2f i) : SV_Target
			{
				float3 dir = normalize(float3(i.worldView.x / _SphereSize, i.worldView.y, i.worldView.z / _SphereSize));
				float2 secondaryTexUV = float2(dir.z, dir.x);
					
				secondaryTexUV.x *= _SecondaryTex_ST.x;
				secondaryTexUV.y *= _SecondaryTex_ST.y;
				secondaryTexUV.x += _Time * _SecondaryTexSpeed;

				fixed4 col = tex2D(_SecondaryTex, secondaryTexUV);

				if (col.a < _CutOff) {
					float2 mainTexUV = float2(dir.z, dir.x);

					mainTexUV.x *= _MainTex_ST.x;
					mainTexUV.y *= _MainTex_ST.y;
					mainTexUV.x += _Time * _MainTexSpeed;

					col = tex2D(_MainTex, mainTexUV);
				}

				return col;
			}
			ENDCG
		}
	}
}