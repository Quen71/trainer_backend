-- Create the favorite_programs table to track user's favorite programs.
CREATE TABLE "public"."favorite_programs" (
    "user_id" uuid NOT NULL,
    "program_id" bigint NOT NULL,
    "created_at" timestamp with time zone NOT NULL DEFAULT now()
);

-- Add foreign key constraints to link to profiles and programs.
ALTER TABLE "public"."favorite_programs" ADD CONSTRAINT "favorite_programs_user_id_fkey" FOREIGN KEY (user_id) REFERENCES "public"."profiles"(id) ON DELETE CASCADE;
ALTER TABLE "public"."favorite_programs" ADD CONSTRAINT "favorite_programs_program_id_fkey" FOREIGN KEY (program_id) REFERENCES "public"."programs"(id) ON DELETE CASCADE;

-- Create a composite primary key to ensure a user can only favorite a program once.
ALTER TABLE "public"."favorite_programs" ADD CONSTRAINT "favorite_programs_pkey" PRIMARY KEY (user_id, program_id);

-- Enable Row Level Security on the new table.
ALTER TABLE "public"."favorite_programs" ENABLE ROW LEVEL SECURITY;

--
-- RLS POLICIES
--
-- Policy: Users can manage their own favorite programs.
-- This policy allows users to select, insert, and delete their own entries
-- in the favorite_programs table, ensuring data privacy and control.
CREATE POLICY "Users can manage their own favorite programs"
ON "public"."favorite_programs"
FOR ALL
USING (auth.uid() = user_id)
WITH CHECK (auth.uid() = user_id);

--
-- RPC FUNCTIONS
--

-- Before creating the new RPC functions, we need a helper function
-- that can fetch a full program object. This avoids duplicating complex JSON
-- building logic across multiple functions.
-- This function will be the single source of truth for what a "full program" is.
CREATE OR REPLACE FUNCTION get_full_program_by_id(p_program_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    RETURN (
        SELECT jsonb_build_object(
            'id', p.id,
            'user_id', p.user_id,
            'name', p.name,
            'description', p.description,
            'created_at', p.created_at,
            'updated_at', p.updated_at,
            'is_favorite', EXISTS (
                SELECT 1
                FROM favorite_programs fp
                WHERE fp.program_id = p.id AND fp.user_id = v_user_id
            ),
            'sessions', (
                SELECT jsonb_agg(
                    jsonb_build_object(
                        'id', s.id,
                        'name', s.name,
                        'order_in_program', s.order_in_program,
                        'type', s.type,
                        'style', s.style,
                        'exercises', (
                            SELECT jsonb_agg(
                                jsonb_build_object(
                                    'id', se.id,
                                    'exercise_id', se.exercise_id,
                                    'order_in_session', se.order_in_session,
                                    'exercise', jsonb_build_object('name', e.name),
                                    'parameters', se.parameters,
                                    'progression', (
                                        SELECT jsonb_agg(ep.*)
                                        FROM exercise_progressions ep
                                        WHERE ep.session_exercise_id = se.id AND ep.user_id = v_user_id
                                    )
                                )
                            )
                            FROM session_exercises se
                            JOIN exercises e ON se.exercise_id = e.id
                            WHERE se.session_id = s.id
                        )
                    )
                    ||
                    CASE
                        WHEN s.type = 'AMRAP' THEN
                            jsonb_build_object('duration', s.parameters->'duration')
                        WHEN s.type IN ('EMOM', 'HIIT') THEN
                            jsonb_build_object('round_number', s.parameters->'round_number')
                        ELSE
                            '{}'::jsonb
                    END
                )
                FROM sessions s
                WHERE s.program_id = p.id
            )
        )
        FROM programs p
        WHERE p.id = p_program_id
    );
END;
$$;


-- Function: add_program_to_favorites
-- Adds a program to the current user's list of favorites and returns the full program object.
CREATE OR REPLACE FUNCTION add_program_to_favorites(p_program_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    -- Verify that the program exists and the user has access to it.
    -- For now, this means the user is the owner.
    -- This will be expanded when sharing is implemented.
    IF NOT EXISTS (
        SELECT 1 FROM programs
        WHERE id = p_program_id AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Program not found or access denied';
    END IF;

    -- Insert the favorite record, ignoring if it already exists.
    INSERT INTO public.favorite_programs (user_id, program_id)
    VALUES (v_user_id, p_program_id)
    ON CONFLICT (user_id, program_id) DO NOTHING;

    -- Return the full, updated program object using the helper function.
    RETURN get_full_program_by_id(p_program_id);
END;
$$;

-- Function: remove_program_from_favorites
-- Removes a program from the current user's list of favorites and returns the full program object.
CREATE OR REPLACE FUNCTION remove_program_from_favorites(p_program_id bigint)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    -- Delete the favorite record. It's safe to run even if the record doesn't exist.
    DELETE FROM public.favorite_programs
    WHERE user_id = v_user_id AND program_id = p_program_id;

    -- Return the full, updated program object using the helper function.
    -- We still check for ownership before returning data.
    IF NOT EXISTS (
        SELECT 1 FROM programs
        WHERE id = p_program_id AND user_id = v_user_id
    ) THEN
        RAISE EXCEPTION 'Program not found or access denied';
    END IF;
    
    RETURN get_full_program_by_id(p_program_id);
END;
$$;
