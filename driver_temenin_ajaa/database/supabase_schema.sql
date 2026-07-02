-- SQL Schema for Temenin Ajaa Standalone Database
-- Run this in the Supabase SQL Editor

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop tables if they exist
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS drivers CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Create users table
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT UNIQUE NOT NULL,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    phone TEXT,
    role TEXT DEFAULT 'client', -- 'client', 'driver', 'admin'
    balance NUMERIC DEFAULT 0,
    points INTEGER DEFAULT 0,
    avatar_url TEXT,
    is_verified BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create drivers table
CREATE TABLE drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE UNIQUE NOT NULL,
    vehicle_type TEXT NOT NULL,
    vehicle_name TEXT NOT NULL,
    plate_number TEXT NOT NULL,
    price_per_hour NUMERIC DEFAULT 50000,
    rating NUMERIC(3,2) DEFAULT 5.00,
    total_rides INTEGER DEFAULT 0,
    is_available BOOLEAN DEFAULT true,
    status TEXT DEFAULT 'approved', -- 'pending', 'approved', 'rejected'
    experience_years INTEGER DEFAULT 0,
    id_card_number TEXT,
    driver_license_number TEXT,
    vehicle_stnk TEXT,
    registration_date TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    approved_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()),
    latitude NUMERIC,
    longitude NUMERIC,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Create bookings table
CREATE TABLE bookings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE NOT NULL,
    driver_id UUID REFERENCES drivers(id) ON DELETE SET NULL,
    status TEXT DEFAULT 'pending', -- 'pending', 'ongoing', 'completed', 'cancelled'
    pickup_location TEXT,
    dropoff_location TEXT,
    pickup_latitude NUMERIC,
    pickup_longitude NUMERIC,
    dropoff_latitude NUMERIC,
    dropoff_longitude NUMERIC,
    duration INTEGER, -- in minutes
    total_price NUMERIC,
    booking_date TIMESTAMP WITH TIME ZONE,
    additional_details JSONB, -- Flexible column for addons, services, notes
    created_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Disable Row Level Security (RLS) for testing or enable permissive access
ALTER TABLE users DISABLE ROW LEVEL SECURITY;
ALTER TABLE drivers DISABLE ROW LEVEL SECURITY;
ALTER TABLE bookings DISABLE ROW LEVEL SECURITY;
