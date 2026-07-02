const { createClient } = require('@supabase/supabase-js');
const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });

const supabaseUrl = process.env.SUPABASE_URL;
const supabaseAnonKey = process.env.SUPABASE_ANON_KEY;
const supabaseServiceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

if (!supabaseUrl || !supabaseAnonKey) {
  throw new Error('SUPABASE_URL and SUPABASE_ANON_KEY must be provided in .env');
}

// Compatible options for Node.js < 22 WebSocket
let options = {
  auth: {
    persistSession: false
  }
};
try {
  const ws = require('ws');
  options.realtime = {
    transport: ws
  };
} catch (e) {
  // ws not installed or not supported, fall back
}

// Client for general operations (uses service key if available to bypass RLS in backend)
const supabase = createClient(supabaseUrl, supabaseServiceKey || supabaseAnonKey, options);

// Admin client for special administrative operations
const supabaseAdmin = createClient(supabaseUrl, supabaseServiceKey || supabaseAnonKey, options);

module.exports = {
  supabase,
  supabaseAdmin
};
