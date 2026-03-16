-- Enums
CREATE TYPE appointment_status AS ENUM ('pending', 'confirmed', 'cancelled', 'completed');

-- Users Profile (extends auth.users)
CREATE TABLE public.users (
  id uuid references auth.users on delete cascade not null primary key,
  full_name text,
  phone text,
  avatar_url text,
  created_at timestamptz default now() not null
);

-- Roles Management
CREATE TABLE public.roles (
  id text primary key,
  description text
);

INSERT INTO public.roles (id, description) VALUES 
('admin', 'Administrator with full access'),
('user', 'Standard customer');

CREATE TABLE public.user_roles (
  user_id uuid references public.users(id) on delete cascade not null,
  role_id text references public.roles(id) on delete restrict not null,
  created_at timestamptz default now() not null,
  PRIMARY KEY (user_id, role_id)
);

-- Admin Check Function
CREATE OR REPLACE FUNCTION public.is_admin(user_id uuid)
RETURNS boolean AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1 FROM public.user_roles
    WHERE user_roles.user_id = $1 AND role_id = 'admin'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Barbers
CREATE TABLE public.barbers (
  id uuid default gen_random_uuid() primary key,
  name text not null,
  bio text,
  avatar_url text,
  is_active boolean default true not null,
  created_at timestamptz default now() not null
);

-- Services
CREATE TABLE public.services (
  id uuid default gen_random_uuid() primary key,
  title text not null,
  description text,
  duration_minutes integer not null,
  price numeric(10,2) not null,
  is_active boolean default true not null,
  created_at timestamptz default now() not null
);

-- Appointments
CREATE TABLE public.appointments (
  id uuid default gen_random_uuid() primary key,
  user_id uuid references public.users(id) on delete cascade not null,
  barber_id uuid references public.barbers(id) on delete restrict not null,
  service_id uuid references public.services(id) on delete restrict not null,
  start_time timestamptz not null,
  end_time timestamptz not null,
  status appointment_status default 'pending' not null,
  notes text,
  created_at timestamptz default now() not null
);

-- RLS Enforcement
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.barbers ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.services ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

-- users policies
CREATE POLICY "Users can view their own profile." ON public.users FOR SELECT USING (auth.uid() = id OR public.is_admin(auth.uid()));
CREATE POLICY "Users can update own profile." ON public.users FOR UPDATE USING (auth.uid() = id);

-- roles policies (Read-only for all)
CREATE POLICY "Roles are selectable by everyone." ON public.roles FOR SELECT USING (true);

-- user_roles policies
CREATE POLICY "Users can view their own roles." ON public.user_roles FOR SELECT USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- barbers policies
CREATE POLICY "Barbers are viewable by everyone." ON public.barbers FOR SELECT USING (true);
CREATE POLICY "Only admins can insert barbers." ON public.barbers FOR INSERT WITH CHECK (public.is_admin(auth.uid()));
CREATE POLICY "Only admins can update barbers." ON public.barbers FOR UPDATE USING (public.is_admin(auth.uid()));

-- services policies
CREATE POLICY "Services are viewable by everyone." ON public.services FOR SELECT USING (true);
CREATE POLICY "Only admins can insert services." ON public.services FOR INSERT WITH CHECK (public.is_admin(auth.uid()));
CREATE POLICY "Only admins can update services." ON public.services FOR UPDATE USING (public.is_admin(auth.uid()));

-- appointments policies
CREATE POLICY "Users can view their own appointments." ON public.appointments FOR SELECT USING (auth.uid() = user_id OR public.is_admin(auth.uid()));
CREATE POLICY "Users can create their own appointments." ON public.appointments FOR INSERT WITH CHECK (auth.uid() = user_id);
-- users can cancel their appointments (update status to cancelled)
CREATE POLICY "Users can update their appointments." ON public.appointments FOR UPDATE USING (auth.uid() = user_id OR public.is_admin(auth.uid()));

-- trigger to auto-create public.users on auth.users insert
CREATE OR REPLACE FUNCTION public.handle_new_user() 
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.users (id)
  VALUES (new.id);
  
  -- assign default role 'user'
  INSERT INTO public.user_roles (user_id, role_id)
  VALUES (new.id, 'user');
  
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Drop trigger if exists to allow re-running easily
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE public.handle_new_user();
