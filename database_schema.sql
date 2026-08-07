-- Hevjîn Database Schema (Supabase/PostgreSQL)

-- Users/Profiles Table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  phone TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  birth_date DATE NOT NULL,
  gender TEXT CHECK (gender IN ('male', 'female')) NOT NULL,
  bio TEXT,
  city TEXT,
  country TEXT DEFAULT 'DE',
  caste TEXT CHECK (caste IN ('scheich', 'pir', 'murid')) NOT NULL,
  tribe TEXT, -- Ashiret/Stamm
  looking_for TEXT CHECK (looking_for IN ('heirat', 'dating', 'beides')) NOT NULL,
  photos TEXT[] DEFAULT '{}',
  avatar_url TEXT,
  is_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Likes Table
CREATE TABLE likes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  from_user UUID REFERENCES profiles(id) ON DELETE CASCADE,
  to_user UUID REFERENCES profiles(id) ON DELETE CASCADE,
  is_super_like BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(from_user, to_user)
);

-- Matches Table
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user1 UUID REFERENCES profiles(id) ON DELETE CASCADE,
  user2 UUID REFERENCES profiles(id) ON DELETE CASCADE,
  matched_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user1, user2)
);

-- Messages Table
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  is_read BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_likes_to_user ON likes(to_user);
CREATE INDEX idx_likes_from_user ON likes(from_user);
CREATE INDEX idx_messages_match ON messages(match_id, created_at);
CREATE INDEX idx_profiles_caste ON profiles(caste);
CREATE INDEX idx_profiles_gender ON profiles(gender);
CREATE INDEX idx_profiles_active ON profiles(is_active) WHERE is_active = TRUE;

-- Row Level Security (RLS)
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Profiles: Users can read all active profiles, update only their own
CREATE POLICY "Anyone can view active profiles" ON profiles
  FOR SELECT USING (is_active = TRUE);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile" ON profiles
  FOR INSERT WITH CHECK (auth.uid() = id);

-- Likes: Users can insert their own likes, read likes sent to them
CREATE POLICY "Users can like" ON likes
  FOR INSERT WITH CHECK (auth.uid() = from_user);

CREATE POLICY "Users can see likes to them" ON likes
  FOR SELECT USING (auth.uid() = to_user OR auth.uid() = from_user);

-- Matches: Users can see their own matches
CREATE POLICY "Users can see own matches" ON matches
  FOR SELECT USING (auth.uid() = user1 OR auth.uid() = user2);

-- Messages: Users can read/write in their matches
CREATE POLICY "Users can read match messages" ON messages
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM matches
      WHERE matches.id = messages.match_id
      AND (matches.user1 = auth.uid() OR matches.user2 = auth.uid())
    )
  );

CREATE POLICY "Users can send messages in matches" ON messages
  FOR INSERT WITH CHECK (
    auth.uid() = sender_id AND
    EXISTS (
      SELECT 1 FROM matches
      WHERE matches.id = match_id
      AND (matches.user1 = auth.uid() OR matches.user2 = auth.uid())
    )
  );
