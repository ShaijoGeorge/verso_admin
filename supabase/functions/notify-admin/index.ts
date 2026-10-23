import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

interface WebhookPayload {
  event: string;
  record: Record<string, any>;
}

serve(async (req: Request) => {
  // 1. Handle CORS preflight
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  try {
    const supabaseUrl = Deno.env.get("SUPABASE_URL") ?? "";
    const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? "";
    const fcmServerKey = Deno.env.get("FCM_SERVER_KEY") ?? "";

    if (!supabaseUrl || !supabaseServiceKey) {
      return new Response(
        JSON.stringify({ error: "Missing Supabase service environment variables" }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const supabase = createClient(supabaseUrl, supabaseServiceKey);
    const body: WebhookPayload = await req.json();

    const { event, record } = body;

    // 2. Format alert title & message based on trigger event
    let title = "Verso Admin Alert";
    let message = "A new system event occurred.";

    if (event === "NEW_SIGNUP" || event === "INSERT_PROFILE") {
      const name = record.display_name || record.email || "A new user";
      title = "New Verso Member 🚀";
      message = `${name} just registered on Verso!`;
    } else if (event === "NEW_FEEDBACK") {
      title = `New Feedback: ${record.type?.toUpperCase() ?? "IDEA"}`;
      message = record.message ? record.message.slice(0, 100) : "New user feedback submitted.";
    }

    // 3. Query all registered admin device FCM tokens
    const { data: devices, error: dbError } = await supabase
      .from("admin_devices")
      .select("fcm_token");

    if (dbError) {
      console.error("Failed to query admin devices:", dbError);
      return new Response(
        JSON.stringify({ error: "Database query failed", details: dbError }),
        { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    const tokens: string[] = (devices ?? [])
      .map((d: { fcm_token: string }) => d.fcm_token)
      .filter((t: string) => Boolean(t));

    if (tokens.length === 0) {
      return new Response(
        JSON.stringify({
          success: true,
          message: "No admin devices registered for push notification.",
          dispatchedCount: 0,
        }),
        { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
      );
    }

    // 4. Send FCM Push Notification if FCM key is configured
    let successCount = 0;
    if (fcmServerKey) {
      for (const token of tokens) {
        try {
          const fcmResponse = await fetch(
            "https://fcm.googleapis.com/fcm/send",
            {
              method: "POST",
              headers: {
                "Content-Type": "application/json",
                Authorization: `key=${fcmServerKey}`,
              },
              body: JSON.stringify({
                to: token,
                notification: {
                  title,
                  body: message,
                  sound: "default",
                  badge: 1,
                },
                data: {
                  event,
                  timestamp: new Date().toISOString(),
                },
              }),
            }
          );

          if (fcmResponse.ok) {
            successCount++;
          } else {
            console.warn(`Failed to send to token ${token.slice(0, 10)}...`, await fcmResponse.text());
          }
        } catch (e) {
          console.error("FCM dispatch error:", e);
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        tokensFound: tokens.length,
        dispatchedCount: successCount,
        title,
        message,
      }),
      { status: 200, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  } catch (error) {
    console.error("Unhandled error in notify-admin edge function:", error);
    return new Response(
      JSON.stringify({ error: "Internal Server Error", details: String(error) }),
      { status: 500, headers: { ...corsHeaders, "Content-Type": "application/json" } }
    );
  }
});
