// Supabase Edge Function: purge-raw-footage
// Periodically deletes actual storage objects from 'tributes-raw' after the 90-day retention window.

import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

Deno.serve(async (req) => {
  try {
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? ''
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''

    const supabase = createClient(supabaseUrl, supabaseServiceKey)

    // Call the database procedure to get and nullify expired raw media
    const { data: purgeResult, error: dbError } = await supabase.rpc('purge_expired_raw_media')
    if (dbError) {
      return new Response(JSON.stringify({ error: dbError.message }), {
        status: 500,
        headers: { 'Content-Type': 'application/json' },
      })
    }

    // Retrieve un-deleted storage purge logs
    const { data: logs, error: logError } = await supabase
      .from('storage_purge_logs')
      .select('id, purged_raw_url')
      .limit(100)

    if (logError) {
      return new Response(JSON.stringify({ error: logError.message }), { status: 500 })
    }

    let deletedCount = 0
    if (logs && logs.length > 0) {
      for (const entry of logs) {
        if (entry.purged_raw_url) {
          // Extract file path from URL or relative path
          const path = entry.purged_raw_url.replace(/.*\/tributes-raw\//, '')
          await supabase.storage.from('tributes-raw').remove([path])
          deletedCount++
        }
      }
    }

    return new Response(
      JSON.stringify({
        success: true,
        tributes_purged_in_db: purgeResult?.[0]?.tributes_purged ?? 0,
        storage_objects_deleted: deletedCount,
      }),
      { headers: { 'Content-Type': 'application/json' } }
    )
  } catch (err) {
    return new Response(JSON.stringify({ error: String(err) }), { status: 500 })
  }
})
