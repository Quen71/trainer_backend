-- Migration: Create function to create test users
-- Description: Creates a function to create users directly in auth.users with all required fields properly initialized
-- This function is used by the create_user.dart script for creating test users

CREATE OR REPLACE FUNCTION public.create_test_user(
  p_email text,
  p_password text,
  p_username text
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path TO 'public', 'auth', 'extensions'
AS $$
DECLARE
  v_user_id uuid;
  v_sub_id text;
BEGIN
  -- Generate UUIDs
  v_user_id := gen_random_uuid();
  v_sub_id := gen_random_uuid()::text;

  -- Insert user into auth.users with all required fields properly initialized
  INSERT INTO auth.users (
    instance_id,
    id,
    aud,
    role,
    email,
    encrypted_password,
    email_confirmed_at,
    confirmation_token,
    confirmation_sent_at,
    recovery_token,
    email_change_token_new,
    email_change,
    email_change_token_current,
    reauthentication_token,
    phone_change,
    phone_change_token,
    raw_app_meta_data,
    raw_user_meta_data,
    is_sso_user,
    is_anonymous,
    created_at,
    updated_at
  ) VALUES (
    '00000000-0000-0000-0000-000000000000',
    v_user_id,
    'authenticated',
    'authenticated',
    p_email,
    extensions.crypt(p_password, extensions.gen_salt('bf')),
    now(),
    '',
    now(),
    '',
    '',
    '',
    '',
    '',
    '',
    '',
    '{"provider": "email", "providers": ["email"]}'::jsonb,
    jsonb_build_object(
      'sub', v_sub_id,
      'email', p_email,
      'username', p_username,
      'email_verified', true,
      'phone_verified', false
    ),
    false,
    false,
    now(),
    now()
  );

  -- The profile should be created automatically by the trigger handle_new_user()
  -- But let's ensure it exists in case the trigger didn't fire
  INSERT INTO public.profiles (id, username, role, created_at, updated_at)
  VALUES (v_user_id, p_username, 'standard', now(), now())
  ON CONFLICT (id) DO NOTHING;

  -- Return user info
  RETURN jsonb_build_object(
    'id', v_user_id,
    'email', p_email,
    'username', p_username,
    'created_at', now()
  );
END;
$$;

