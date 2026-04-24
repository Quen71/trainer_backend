// @deno-types="https://esm.sh/@supabase/functions-js/src/edge-runtime.d.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2.39.3';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
};

interface RevenueCatWebhookEvent {
  event: {
    id: string;
    type: string;
    app_user_id: string;
    product_id: string;
    period_type?: string;
    purchased_at_ms?: number;
    expiration_at_ms?: number;
    is_trial_period?: boolean;
    store?: string;
    transaction_id?: string;
    original_transaction_id?: string;
    environment?: string;
    entitlement_ids?: string[];
    presented_offering_id?: string;
    presented_offering_context?: {
      offering_id: string;
      placement_id?: string;
    };
    [key: string]: unknown;
  };
}

function jsonResponse(
  body: Record<string, unknown>,
  status: number,
): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...corsHeaders, 'Content-Type': 'application/json' },
  });
}

async function getEntitlementIdByKey(
  supabase: ReturnType<typeof createClient>,
  entitlementKey: string,
): Promise<string | null> {
  const { data } = await supabase
    .from('entitlements')
    .select('id')
    .eq('entitlement_key', entitlementKey)
    .single();

  return data?.id ?? null;
}

Deno.serve(async (req: Request) => {
  // Handle CORS preflight
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    // Get the webhook secret from Supabase secrets
    // This should match the authorization header value configured in RevenueCat dashboard
    const webhookSecret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
    if (!webhookSecret) {
      console.error('REVENUECAT_WEBHOOK_SECRET not configured');
      return jsonResponse({ error: 'Webhook secret not configured' }, 500);
    }

    // Validate authorization header (recommended by RevenueCat)
    // RevenueCat sends the authorization header value configured in the dashboard
    const authHeader = req.headers.get('authorization');
    if (!authHeader) {
      console.error('Missing Authorization header');
      return jsonResponse({ error: 'Missing authorization header' }, 401);
    }

    // Compare authorization header with configured secret
    // RevenueCat sends the header exactly as configured (may include "Bearer " prefix or not)
    // We normalize both values to handle different formats
    const normalizedAuth = authHeader.trim();
    const normalizedSecret = webhookSecret.trim();
    
    // Check if the header matches (with or without Bearer prefix)
    // RevenueCat sends the value exactly as you configured it in the dashboard
    if (
      normalizedAuth !== normalizedSecret &&
      normalizedAuth !== `Bearer ${normalizedSecret}` &&
      normalizedAuth.replace(/^Bearer\s+/, '') !== normalizedSecret
    ) {
      console.error('Invalid authorization header');
      return jsonResponse({ error: 'Invalid authorization header' }, 401);
    }

    // Parse the webhook payload
    const rawBody = await req.text();
    const payload: RevenueCatWebhookEvent = JSON.parse(rawBody);
    const event = payload.event;

    // Create Supabase client
    const supabaseUrl = Deno.env.get('SUPABASE_URL') ?? '';
    const supabaseServiceKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';
    const supabase = createClient(supabaseUrl, supabaseServiceKey);

    // Map app_user_id to user_id (they should be the same - auth.uid())
    const userId = event.app_user_id;

    // Determine event type
    const eventType = event.type.toUpperCase();
    const isCancellation = eventType === 'CANCELLATION';
    const isExpiration = eventType === 'EXPIRATION';

    // STEP 1: Get or create product FIRST (before finding entitlement)
    // This ensures the product exists when we try to find the entitlement via product_id
    let productId: string | null = null;
    const { data: existingProduct } = await supabase
      .from('products')
      .select('id')
      .eq('product_id', event.product_id)
      .single();

    if (existingProduct) {
      productId = existingProduct.id;
      console.log(`[${eventType}] Product found: ${event.product_id} -> ${productId}`);
    } else {
      // Create product if it doesn't exist
      console.log(`[${eventType}] Creating product: ${event.product_id}`);
      const { data: newProduct, error: productError } = await supabase
        .from('products')
        .insert({
          product_id: event.product_id,
          vendor: event.store || 'unknown',
          period_interval: event.period_type || null,
          metadata: {},
        })
        .select('id')
        .single();

      if (productError) {
        console.error(`[${eventType}] Error creating product:`, productError);
      } else if (newProduct) {
        productId = newProduct.id;
        console.log(`[${eventType}] Product created: ${event.product_id} -> ${productId}`);
      }
    }

    // STEP 2: Get entitlement_id from RevenueCat entitlement_ids (highest priority)
    let entitlementId: string | null = null;
    if (event.entitlement_ids && event.entitlement_ids.length > 0) {
      console.log(`[${eventType}] Looking for entitlement via entitlement_ids:`, event.entitlement_ids);
      // Find the entitlement by looking up the entitlement_key
      const { data: entitlementData } = await supabase
        .from('entitlements')
        .select('id')
        .in('entitlement_key', event.entitlement_ids)
        .single();

      if (entitlementData) {
        entitlementId = entitlementData.id;
        console.log(`[${eventType}] Entitlement found via entitlement_ids: ${event.entitlement_ids[0]} -> ${entitlementId}`);
      }
    }

    // STEP 3: If no entitlement found from event, try to find by product_id
    // Now that the product exists, we can safely look it up
    if (!entitlementId && productId) {
      console.log(`[${eventType}] Looking for entitlement via product_id: ${productId}`);
      const { data: entitlementProductData } = await supabase
        .from('entitlement_products')
        .select('entitlement_id')
        .eq('product_id', productId)
        .single();

      if (entitlementProductData) {
        entitlementId = entitlementProductData.entitlement_id;
        console.log(`[${eventType}] Entitlement found via product_id: ${productId} -> ${entitlementId}`);
      } else if (productId && !existingProduct) {
        // Product was just created, link it to Premium entitlement by default
        console.log(`[${eventType}] No entitlement link found for new product, linking to Premium`);
        const premiumEntitlementId = await getEntitlementIdByKey(
          supabase,
          'Premium',
        );

        if (premiumEntitlementId) {
          entitlementId = premiumEntitlementId;
          // Create the link
          const { error: linkError } = await supabase.from('entitlement_products').insert({
            entitlement_id: entitlementId,
            product_id: productId,
          });
          if (linkError) {
            console.error(`[${eventType}] Error linking product to entitlement:`, linkError);
          } else {
            console.log(`[${eventType}] Product linked to Premium entitlement`);
          }
        }
      }
    }

    // STEP 4: If still no entitlement found, default to Premium (for backward compatibility)
    if (!entitlementId) {
      console.log(`[${eventType}] Using fallback: Premium entitlement`);
      const premiumEntitlementId = await getEntitlementIdByKey(
        supabase,
        'Premium',
      );

      if (premiumEntitlementId) {
        entitlementId = premiumEntitlementId;
        console.log(`[${eventType}] Fallback entitlement found: Premium -> ${entitlementId}`);
      }
    }

    if (!entitlementId) {
      console.error(`[${eventType}] Could not find entitlement for product:`, event.product_id);
      return jsonResponse({ error: 'Entitlement not found' }, 400);
    }

    // Determine subscription status
    let status = 'active';
    if (isExpiration || isCancellation) {
      status = isCancellation ? 'cancelled' : 'expired';
    } else if (event.is_trial_period) {
      status = 'trialing';
    }

    // Calculate dates
    const startedAt = event.purchased_at_ms
      ? new Date(event.purchased_at_ms).toISOString()
      : new Date().toISOString();
    const expiresAt = event.expiration_at_ms
      ? new Date(event.expiration_at_ms).toISOString()
      : null;

    // Upsert subscription (transaction)
    console.log(`[${eventType}] Calling handle_subscription_webhook RPC:`, {
      user_id: userId,
      entitlement_id: entitlementId,
      product_id: productId,
      product_id_store: event.product_id,
      status: status,
      started_at: startedAt,
      expires_at: expiresAt,
    });

    const { data: subscription, error: subscriptionError } = await supabase.rpc(
      'handle_subscription_webhook',
      {
        p_user_id: userId,
        p_entitlement_id: entitlementId,
        p_product_id: productId,
        p_vendor_transaction_id: event.transaction_id || event.original_transaction_id || null,
        p_status: status,
        p_started_at: startedAt,
        p_expires_at: expiresAt,
        p_is_trial: event.is_trial_period || false,
        p_raw_receipt: event,
      },
    );

    if (subscriptionError) {
      console.error(`[${eventType}] Error upserting subscription:`, subscriptionError);
      // Try direct upsert if RPC doesn't exist
      const { error: directError } = await supabase
        .from('subscriptions')
        .upsert(
          {
            user_id: userId,
            entitlement_id: entitlementId,
            product_id: productId,
            vendor_transaction_id: event.transaction_id || event.original_transaction_id || null,
            status,
            started_at: startedAt,
            expires_at: expiresAt,
            is_trial: event.is_trial_period || false,
            raw_receipt: event,
          },
          {
            onConflict: 'user_id,entitlement_id',
          },
        );

      if (directError) {
        console.error(`[${eventType}] Direct upsert error:`, directError);
        return jsonResponse({ error: 'Failed to update subscription' }, 500);
      } else {
        console.log(`[${eventType}] Direct upsert succeeded (fallback)`);
      }
    } else {
      console.log(`[${eventType}] RPC succeeded, subscription ID:`, subscription?.id);
    }

    // Get subscription ID for event logging
    let subscriptionId: string | null = null;
    if (subscription && subscription.length > 0) {
      subscriptionId = subscription[0].id;
      console.log(`[${eventType}] Subscription ID from RPC:`, subscriptionId);
    } else {
      // Fetch the subscription we just created/updated
      const { data: subData } = await supabase
        .from('subscriptions')
        .select('id, product_id, status')
        .eq('user_id', userId)
        .eq('entitlement_id', entitlementId)
        .single();

      if (subData) {
        subscriptionId = subData.id;
        console.log(`[${eventType}] Subscription fetched:`, {
          id: subscriptionId,
          product_id: subData.product_id,
          status: subData.status,
        });
      } else {
        console.warn(`[${eventType}] Could not find subscription after upsert`);
      }
    }

    // Insert event into ledger (with idempotence on vendor_event_id)
    const { error: eventError } = await supabase
      .from('subscription_events')
      .insert({
        subscription_id: subscriptionId,
        user_id: userId,
        event_type: eventType,
        vendor_event_id: event.id,
        event_time: startedAt,
        event_payload: event,
      })
      .select()
      .single();

    if (eventError) {
      // If duplicate, that's fine (idempotence)
      if (!eventError.message.includes('duplicate') && !eventError.message.includes('unique')) {
        console.error('Error inserting event:', eventError);
      }
    }

    return jsonResponse({ success: true, event_type: eventType }, 200);
  } catch (error) {
    console.error('Webhook processing error:', error);
    return jsonResponse({ error: error.message }, 500);
  }
});

