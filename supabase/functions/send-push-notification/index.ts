import { serve } from "https://deno.land/std@0.177.0/http/server.ts"
import { createClient } from "https://esm.sh/@supabase/supabase-js@2"

// Use jose for JWT signing (for Google Auth)
import * as jose from "https://deno.land/x/jose@v4.14.4/index.ts"

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const payload = await req.json()
    const { record, table } = payload

    if (!record) {
      return new Response(JSON.stringify({ error: 'No record provided' }), { status: 400 })
    }

    const supabase = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    let tokens: string[] = []
    let title = "New Message"
    let body = ""
    let data: any = {}

    if (table === 'messages') {
      // 1-on-1 Message
      const receiverId = record.receiver_id
      const senderId = record.sender_id
      
      const { data: profile } = await supabase
        .from('profile')
        .select('fcm_token, name')
        .eq('user_id', receiverId)
        .single()
      
      if (profile?.fcm_token) {
        tokens.push(profile.fcm_token)
      }

      const { data: sender } = await supabase
        .from('profile')
        .select('name')
        .eq('user_id', senderId)
        .single()

      title = sender?.name ?? "New Message"
      body = record.content || record.message_text || "You received a new message"
      data = {
        type: 'chat',
        sender_id: senderId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    } else if (table === 'group_messages') {
      // Group Message
      const groupId = record.group_id
      const senderId = record.sender_id

      const { data: group } = await supabase
        .from('groups')
        .select('name')
        .eq('id', groupId)
        .single()

      const { data: members } = await supabase
        .from('group_members')
        .select('user_id, profile:user_id(fcm_token)')
        .eq('group_id', groupId)
        .neq('user_id', senderId)

      tokens = members?.map((m: any) => m.profile?.fcm_token).filter((t: any) => !!t) || []

      const { data: sender } = await supabase
        .from('profile')
        .select('name')
        .eq('user_id', senderId)
        .single()

      title = `${group?.name ?? 'Group'}`
      body = `${sender?.name ?? 'Someone'}: ${record.message_text || "New message"}`
      data = {
        type: 'group_chat',
        group_id: groupId.toString(),
        sender_id: senderId,
        click_action: 'FLUTTER_NOTIFICATION_CLICK'
      }
    }

    if (tokens.length === 0) {
      return new Response(JSON.stringify({ success: true, message: 'No tokens to send' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    // FCM Send Logic
    const serviceAccountContent = await Deno.readTextFile('./firebase-auth.json')
    const serviceAccount = JSON.parse(serviceAccountContent)
    if (!serviceAccount.project_id) {
      return new Response(JSON.stringify({ error: 'FIREBASE_SERVICE_ACCOUNT secret not set or invalid' }), {
        status: 500,
        headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      })
    }

    const accessToken = await getGoogleAccessToken(serviceAccount)

    const results = await Promise.all(tokens.map(token => 
      sendFCM(serviceAccount.project_id, accessToken, token, title, body, data)
    ))

    return new Response(JSON.stringify({ success: true, results }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })

  } catch (err: any) {
    console.error(err)
    return new Response(JSON.stringify({ error: err.message }), {
      status: 500,
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
    })
  }
})

async function getGoogleAccessToken(serviceAccount: any) {
  const jwt = await new jose.SignJWT({
    iss: serviceAccount.client_email,
    sub: serviceAccount.client_email,
    aud: "https://oauth2.googleapis.com/token",
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 3600,
    scope: "https://www.googleapis.com/auth/cloud-platform",
  })
    .setProtectedHeader({ alg: "RS256" })
    .sign(await jose.importPKCS8(serviceAccount.private_key, "RS256"))

  const res = await fetch("https://oauth2.googleapis.com/token", {
    method: "POST",
    headers: { "Content-Type": "application/x-www-form-urlencoded" },
    body: new URLSearchParams({
      grant_type: "urn:ietf:params:oauth:grant-type:jwt-bearer",
      assertion: jwt,
    }),
  })
  const data = await res.json()
  return data.access_token
}

async function sendFCM(projectId: string, accessToken: string, token: string, title: string, body: string, data: any) {
  const res = await fetch(
    `https://fcm.googleapis.com/v1/projects/${projectId}/messages:send`,
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${accessToken}`,
      },
      body: JSON.stringify({
        message: {
          token: token,
          notification: { title, body },
          data: data,
          android: {
            priority: 'high',
            notification: {
              sound: 'default',
              channel_id: 'chat_messages'
            }
          },
          apns: {
            payload: {
              aps: {
                sound: 'default',
                badge: 1
              }
            }
          }
        },
      }),
    }
  )
  return res.json()
}
