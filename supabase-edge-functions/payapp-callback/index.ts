import { serve } from "https://deno.land/std/http/server.ts";
import { initializeApp, cert } from "https://esm.sh/firebase-admin@12.0.0/app";
import { getFirestore } from "https://esm.sh/firebase-admin@12.0.0/firestore";

// Firebase Admin SDK 초기화 (환경변수에서 서비스 계정 키 로드)
const serviceAccount = JSON.parse(
  Deno.env.get("FIREBASE_SERVICE_ACCOUNT") || "{}"
);

const app = initializeApp({
  credential: cert(serviceAccount),
});

const db = getFirestore(app);

const corsHeaders = {
  "Access-Control-A`llow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    // PayApp이 feedbackurl로 보내는 콜백 데이터 파싱
    // PayApp은 form-urlencoded 또는 query string으로 전달
    let params: Record<string, string> = {};

    const contentType = req.headers.get("content-type") || "";

    if (contentType.includes("application/x-www-form-urlencoded")) {
      const text = await req.text();
      text.split("&").forEach((pair) => {
        const [key, ...rest] = pair.split("=");
        params[decodeURIComponent(key)] = decodeURIComponent(rest.join("="));
      });
    } else if (contentType.includes("application/json")) {
      params = await req.json();
    } else {
      // URL query string fallback
      const url = new URL(req.url);
      url.searchParams.forEach((value, key) => {
        params[key] = value;
      });
    }

    console.log("PayApp callback received:", JSON.stringify(params));

    const mulNo = params.mul_no;
    const state = params.state; // 1=대기, 2=결제완료, 4=취소
    const userId = params.var1; // 결제 요청 시 var1에 userId를 넣었음

    if (!mulNo) {
      return new Response(
        JSON.stringify({ success: false, message: "mul_no is required" }),
        {
          headers: { ...corsHeaders, "Content-Type": "application/json" },
          status: 400,
        }
      );
    }

    // 결제 완료인 경우 Firestore 업데이트
    if (state === "2") {
      // cases 컬렉션에서 paymentMulNo가 일치하는 문서 찾기
      const casesRef = db.collection("cases");
      const snapshot = await casesRef
        .where("paymentMulNo", "==", mulNo)
        .limit(1)
        .get();

      if (!snapshot.empty) {
        const doc = snapshot.docs[0];
        await doc.ref.update({
          isPaid: true,
          paidAt: new Date().toISOString(),
        });
        console.log(`Case ${doc.id} marked as paid (mul_no: ${mulNo})`);
      } else {
        // mulNo로 못 찾으면 userId(var1)로 최근 케이스 찾기
        if (userId) {
          const userCases = await casesRef
            .where("userId", "==", userId)
            .where("isPaid", "==", false)
            .orderBy("createdAt", "desc")
            .limit(1)
            .get();

          if (!userCases.empty) {
            const doc = userCases.docs[0];
            await doc.ref.update({
              isPaid: true,
              paidAt: new Date().toISOString(),
              paymentMulNo: mulNo,
            });
            console.log(
              `Case ${doc.id} marked as paid via userId (mul_no: ${mulNo})`
            );
          }
        }
      }
    }

    // PayApp에 OK 응답 (필수)
    return new Response(JSON.stringify({ success: true, state }), {
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  } catch (e) {
    console.error("PayApp Callback Error:", e);
    return new Response(
      JSON.stringify({ success: false, message: "서버 오류가 발생했습니다." }),
      {
        headers: { ...corsHeaders, "Content-Type": "application/json" },
        status: 500,
      }
    );
  }
});
