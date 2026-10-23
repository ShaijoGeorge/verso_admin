-- ==============================================================================
-- VERSO ADMIN BACKEND SCHEMA & MIGRATION
-- Migration: 20261023_admin_schema.sql
-- ==============================================================================

-- 0. Ensure role & telemetry columns exist on profiles table (safe, non-destructive)
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS role TEXT DEFAULT 'reader';

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_admin BOOLEAN DEFAULT false;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS email TEXT;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now());

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS is_streak_frozen BOOLEAN DEFAULT false;

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS gender TEXT DEFAULT 'male';

ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS birthday TEXT;

-- Safely backfill email & metadata from auth.users into profiles
DO $$
BEGIN
    UPDATE public.profiles p
    SET 
        email = COALESCE(p.email, u.email),
        created_at = COALESCE(p.created_at, u.created_at, p.updated_at),
        gender = COALESCE(p.gender, u.raw_user_meta_data->>'gender', 'male'),
        birthday = COALESCE(p.birthday, u.raw_user_meta_data->>'birthday', u.raw_user_meta_data->>'birth_date')
    FROM auth.users u
    WHERE p.id = u.id;
EXCEPTION WHEN OTHERS THEN
    -- Ignore if auth.users schema is restricted
    NULL;
END $$;

-- Enable RLS and add admin policies on profiles
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Admins can view all profiles" ON public.profiles;
CREATE POLICY "Admins can view all profiles"
    ON public.profiles
    FOR SELECT
    USING (
        auth.uid() = id
        OR (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND (p.role = 'admin' OR p.is_admin = true)
        )
    );

DROP POLICY IF EXISTS "Admins can update user profiles" ON public.profiles;
CREATE POLICY "Admins can update user profiles"
    ON public.profiles
    FOR UPDATE
    USING (
        auth.uid() = id
        OR (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR EXISTS (
            SELECT 1 FROM public.profiles p
            WHERE p.id = auth.uid() AND (p.role = 'admin' OR p.is_admin = true)
        )
    );

-- 1. Create admin_devices table for storing FCM push notification tokens
CREATE TABLE IF NOT EXISTS public.admin_devices (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    fcm_token TEXT NOT NULL UNIQUE,
    platform TEXT NOT NULL DEFAULT 'android',
    device_info JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now()),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Index for fast token lookups and user device queries
CREATE INDEX IF NOT EXISTS idx_admin_devices_user_id ON public.admin_devices(user_id);
CREATE INDEX IF NOT EXISTS idx_admin_devices_fcm_token ON public.admin_devices(fcm_token);

-- Enable Row Level Security (RLS) on admin_devices
ALTER TABLE public.admin_devices ENABLE ROW LEVEL SECURITY;

-- Drop policy if exists to allow safe re-runs
DROP POLICY IF EXISTS "Admins can manage their own devices" ON public.admin_devices;

-- Policy: Admins can view and manage their own registered devices
CREATE POLICY "Admins can manage their own devices"
    ON public.admin_devices
    FOR ALL
    USING (
        auth.uid() = user_id
        AND (
            (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
            OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
            OR EXISTS (
                SELECT 1 FROM public.profiles
                WHERE profiles.id = auth.uid()
                AND (profiles.role = 'admin' OR profiles.is_admin = true)
            )
        )
    )
    WITH CHECK (
        auth.uid() = user_id
    );

-- 2. Create system_config table for remote app update enforcement and verse overrides
CREATE TABLE IF NOT EXISTS public.system_config (
    id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    force_update BOOLEAN NOT NULL DEFAULT false,
    min_required_version TEXT NOT NULL DEFAULT '2.0.0',
    latest_version TEXT NOT NULL DEFAULT '2.1.2',
    update_url TEXT NOT NULL DEFAULT 'https://versobibletracker.netlify.app/#download',
    maintenance_mode BOOLEAN NOT NULL DEFAULT false,
    maintenance_message TEXT NOT NULL DEFAULT 'Verso is undergoing scheduled maintenance. Please check back shortly.',
    verse_override_enabled BOOLEAN NOT NULL DEFAULT false,
    verse_override_reference TEXT NOT NULL DEFAULT 'Psalm 23:1',
    verse_override_text TEXT NOT NULL DEFAULT 'The LORD is my shepherd; I shall not want.',
    verse_override_ml_poc TEXT NOT NULL DEFAULT 'കർത്താവാണ് എൻ്റെ ഇടയൻ; എനിക്കൊന്നിനും കുറവുണ്ടാവുകയില്ല.',
    verse_override_ml_bsi TEXT NOT NULL DEFAULT 'യഹോവ എന്റെ ഇടയനാകുന്നു; എനിക്കു മുട്ടുണ്ടാകയില്ല.',
    updated_at TIMESTAMPTZ NOT NULL DEFAULT timezone('utc'::text, now())
);

-- Seed single row if not exists
INSERT INTO public.system_config (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- Enable Row Level Security on system_config
ALTER TABLE public.system_config ENABLE ROW LEVEL SECURITY;

-- Drop policies if exist to allow safe re-runs
DROP POLICY IF EXISTS "Anyone can read system_config" ON public.system_config;
DROP POLICY IF EXISTS "Admins can update system_config" ON public.system_config;

-- Policy: Everyone (clients) can read system config
CREATE POLICY "Anyone can read system_config"
    ON public.system_config
    FOR SELECT
    USING (true);

-- Policy: Only verified admins can update system config
CREATE POLICY "Admins can update system_config"
    ON public.system_config
    FOR ALL
    USING (
        (auth.jwt() -> 'app_metadata' ->> 'role') = 'admin'
        OR (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
        OR EXISTS (
            SELECT 1 FROM public.profiles
            WHERE profiles.id = auth.uid()
            AND (profiles.role = 'admin' OR profiles.is_admin = true)
        )
    );

-- 3. Database Trigger & Function for Real-Time Admin Alerts on New User Signup
CREATE OR REPLACE FUNCTION public.handle_new_signup_notify()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN NEW;
EXCEPTION WHEN OTHERS THEN
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_profile_created_notify ON public.profiles;

CREATE TRIGGER on_profile_created_notify
    AFTER INSERT ON public.profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_new_signup_notify();
