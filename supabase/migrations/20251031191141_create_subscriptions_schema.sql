-- Create subscription_status enum
CREATE TYPE public.subscription_status AS ENUM (
  'active',
  'trialing',
  'in_grace',
  'paused',
  'cancelled',
  'expired'
);

-- Create entitlements table
-- Stores the different subscription entitlements (Premium, Pro, etc.)
CREATE TABLE public.entitlements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  entitlement_key text UNIQUE NOT NULL,
  name text NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Create products table
-- Stores products from stores (App Store, Play Store, Stripe, etc.)
CREATE TABLE public.products (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id text UNIQUE NOT NULL,
  vendor text NOT NULL,
  period_interval text,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Create entitlement_products junction table
-- Links entitlements to products (many-to-many relationship)
CREATE TABLE public.entitlement_products (
  entitlement_id uuid NOT NULL REFERENCES public.entitlements(id) ON DELETE CASCADE,
  product_id uuid NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  PRIMARY KEY (entitlement_id, product_id)
);

-- Create subscription_limits table
-- Defines feature limits for each entitlement
CREATE TABLE public.subscription_limits (
  entitlement_id uuid PRIMARY KEY REFERENCES public.entitlements(id) ON DELETE CASCADE,
  max_programs int,
  max_sessions_per_program int,
  history_days int,
  max_exercises int,
  can_export_data boolean NOT NULL DEFAULT false,
  can_share_programs boolean NOT NULL DEFAULT false,
  metadata jsonb NOT NULL DEFAULT '{}'
);

-- Create subscriptions table
-- Stores user subscription information
CREATE TABLE public.subscriptions (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  entitlement_id uuid NOT NULL REFERENCES public.entitlements(id) ON DELETE CASCADE,
  product_id uuid REFERENCES public.products(id) ON DELETE SET NULL,
  vendor_transaction_id text,
  status public.subscription_status NOT NULL,
  started_at timestamptz NOT NULL DEFAULT now(),
  expires_at timestamptz,
  is_trial boolean NOT NULL DEFAULT false,
  raw_receipt jsonb,
  metadata jsonb NOT NULL DEFAULT '{}',
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT subscriptions_user_entitlement_unique UNIQUE (user_id, entitlement_id) DEFERRABLE INITIALLY IMMEDIATE
);

-- Create subscription_events table (ledger)
-- Stores all subscription-related events for audit and debugging
CREATE TABLE public.subscription_events (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  subscription_id uuid REFERENCES public.subscriptions(id) ON DELETE SET NULL,
  user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  event_type text NOT NULL,
  vendor_event_id text UNIQUE,
  event_time timestamptz NOT NULL,
  event_payload jsonb NOT NULL,
  created_at timestamptz NOT NULL DEFAULT now()
);

-- Create indexes for performance
CREATE INDEX subscriptions_user_id_idx ON public.subscriptions(user_id);
CREATE INDEX subscriptions_expires_at_idx ON public.subscriptions(expires_at);
CREATE UNIQUE INDEX subscriptions_vendor_transaction_id_idx ON public.subscriptions(vendor_transaction_id) WHERE vendor_transaction_id IS NOT NULL;
CREATE INDEX subscription_events_user_id_idx ON public.subscription_events(user_id);
CREATE INDEX subscription_events_subscription_id_idx ON public.subscription_events(subscription_id);

-- Enable Row Level Security
ALTER TABLE public.entitlements ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.entitlement_products ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_limits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.subscription_events ENABLE ROW LEVEL SECURITY;

-- RLS Policies for entitlements (public read access)
CREATE POLICY "Entitlements are viewable by authenticated users"
ON public.entitlements
FOR SELECT
TO authenticated
USING (true);

-- RLS Policies for products (public read access)
CREATE POLICY "Products are viewable by authenticated users"
ON public.products
FOR SELECT
TO authenticated
USING (true);

-- RLS Policies for entitlement_products (public read access)
CREATE POLICY "Entitlement products are viewable by authenticated users"
ON public.entitlement_products
FOR SELECT
TO authenticated
USING (true);

-- RLS Policies for subscription_limits (public read access)
CREATE POLICY "Subscription limits are viewable by authenticated users"
ON public.subscription_limits
FOR SELECT
TO authenticated
USING (true);

-- RLS Policies for subscriptions
CREATE POLICY "Users can view their own subscriptions"
ON public.subscriptions
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- RLS Policies for subscription_events
CREATE POLICY "Users can view their own subscription events"
ON public.subscription_events
FOR SELECT
TO authenticated
USING (auth.uid() = user_id);

-- Create trigger to update updated_at timestamp
CREATE OR REPLACE FUNCTION public.update_subscriptions_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

CREATE TRIGGER subscriptions_updated_at
  BEFORE UPDATE ON public.subscriptions
  FOR EACH ROW
  EXECUTE FUNCTION public.update_subscriptions_updated_at();

