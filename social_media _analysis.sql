-- ==============================================================
-- SQL + GenAI Mini Project : Social Media Analytics
-- Dataset : Social_Media
-- Student Name : ______________________
-- ==============================================================

-- 🚀 SETUP INSTRUCTIONS (MUST DO FIRST)
-- ==============================================================
-- Before solving this project, make sure you create and load the dataset.
--
-- STEP 1: Open your SQL client (MySQL Workbench, DBeaver, or SQLite Studio).
-- STEP 2: Run the provided dataset file:
--         social_media_analytics_dataset.sql
--
-- This script will:
--   ✅ Create a new database named `Social_Media`
--   ✅ Create all 7 tables (users, posts, comments, likes, followers, hashtags, post_hashtags)
--   ✅ Insert ~7,000 synthetic rows for analysis
--
-- STEP 3: After successful execution, Your Code the database:
--         USE Social_Media;
--
-- STEP 4: Verify the tables:
--         SHOW TABLES;
--         Your Code COUNT(*) FROM users;
--         Your Code COUNT(*) FROM posts;
--
-- Once you confirm the data is loaded, you can proceed to attempt all project queries.
-- ==============================================================

USE Social_Media;

-- ==============================================================
-- IMPORTANT: BEFORE USING GenAI FOR QUERY GENERATION
-- ==============================================================
-- To help the AI generate accurate SQL, you MUST first share your schema.
-- Paste the following context into ChatGPT (or any GenAI tool) BEFORE you ask your prompts:

/*
You are an expert SQL assistant.  
Before answering any question, refer strictly to the database schema provided below.  
All SQL queries, joins, and analyses must be based ONLY on this schema — table names, column names, and relationships mentioned here.  
Do not assume any extra tables or columns unless explicitly stated.  
If a question is ambiguous, clarify it using the schema context rather than inventing new fields.  
Once you understand the schema, wait for my analytical question and generate the most accurate SQL query for it.

Tables and Key Columns:
  1. users(user_id, username, join_date, country)
  2. posts(post_id, user_id, content, created_at)
  3. comments(comment_id, post_id, user_id, comment_text, created_at)
  4. likes(like_id, post_id, user_id, created_at)
  5. followers(follower_id, user_id, follower_user_id, follow_date)
  6. hashtags(hashtag_id, tag_name, category)
  7. post_hashtags(id, post_id, hashtag_id)

Relationships:
  • Each user can create multiple posts.
  • Each post can have multiple likes and comments.
  • Users can follow each other (self-join in followers table).
  • Posts can be tagged with multiple hashtags (many-to-many via post_hashtags).
*/

-- Once you paste the schema, THEN use prompts like:
--   "Generate SQL to find top 10 active users combining posts and comments."
--   "Find trending hashtags used in more than 20 posts."
-- ==============================================================




-- ==============================================================
-- Q1. Most Active Users (Posts + Comments)
-- ==============================================================
-- Objective : Find top 10 users based on combined number of posts and comments.
-- Example GenAI Prompt :
--   "Write SQL to find top 10 active users combining posts and comments count."
-- Write your query below 👇
-- --------------------------------------------------------------
-- Your Code ...

SELECT 
    u.user_id,
    u.username,
    COUNT(DISTINCT p.post_id) AS post_count,
    COUNT(DISTINCT c.comment_id) AS comment_count,
    COUNT(DISTINCT p.post_id) + COUNT(DISTINCT c.comment_id) AS total_activity
FROM users AS u
LEFT JOIN posts AS p 
    ON u.user_id = p.user_id
LEFT JOIN comments AS c 
    ON u.user_id = c.user_id
GROUP BY u.user_id, u.username
ORDER BY total_activity DESC
LIMIT 10;

-- Solution Summary --
-- The top score is just 9, and 7 out of 10 users and rest tie at 6, means there's no clear "super-user" tier pulling ahead of rest of the users.
-- Behaviour analysis of the users :
-- Post-heavy users: masonhenderson leads with 6 posts / 1 comment. nsantana, john37, and pedrowilson follow with 4 posts / 2 comments each.
-- Comment-heavy users: whitney74 has the most comments (6), while amoore and nathandean are the most comment-driven (5 comments / 1 post).
-- Balanced user: johnjames is the only closely balanced user with 3 posts / 4 comments.

-- ==============================================================
-- Q2. Most Liked Posts and Creators
-- ==============================================================
-- Objective : Identify posts with maximum likes along with their creator.
-- Example GenAI Prompt :
--   "Show top 10 posts with most likes and username."
-- --------------------------------------------------------------
-- Your Code ...

SELECT 
    p.post_id, u.username, COUNT(l.like_id) AS total_likes
FROM
    posts AS p
        JOIN
    users AS u ON p.user_id = u.user_id
        JOIN
    likes AS l ON p.post_id = l.post_id
GROUP BY p.post_id , u.username
ORDER BY total_likes DESC
LIMIT 10;


-- Solution Summary -- 
-- The full range across top 10 is only 4–6 likes, only a 2-point spread/difference.
-- The best post only got 6 likes, and even that's shared by 3 people — so there is not a one clear winner. The top post is not a clear standout it's a 3-way tie which means there is no single hit post.
-- Tier composition :
 -- Tier 1 (6 likes): 3 posts — This is the actual "most-liked" post, 30% of the list but delivering 37.5% of total likes.– 
-- Tier 2 (5 likes): 2 posts — 20%, of the list contributing 20.8% of total likes.
-- Tier 3 (4 likes): 5 posts —  Makes up 50% of the entire top 10. This is the largest chunk from the top 10 (half the list), all tied at the same value contributing 41.7% of total likes. So,the "top 10" is really "3 strong performers + 2 mid + 5 borderline ties."

-- ==============================================================
-- Q3. Top Countries by Average Engagement
-- ==============================================================
-- Objective : Find countries with the highest average likes per post.
-- Example GenAI Prompt :
--   "Which countries have highest average likes per post?"
-- --------------------------------------------------------------
-- Your Code ...

SELECT u.country , 
	count(u.user_id) as users , 
	count(DISTINCT p.post_id) as posts , 
	count(l.like_id) / count( DISTINCT p.post_id) as likes_per_post
FROM users u
LEFT JOIN posts AS p
ON u.user_id = p.user_id
LEFT JOIN likes AS l
ON p.post_id = l.post_id
GROUP BY u.country
ORDER BY likes_per_post DESC
LIMIT 5;

-- Solution Summary -- 
-- Mexico had the most likes per post on average — about 3 likes per post. Bahrain and Malta came next, both around 2.5 likes per post. 
-- But there's a catch: these countries only have a handful of posts each (Mexico has just 2, Bahrain has 4). 
-- So , these results are based on very little data, and could easily change once more people post.
-- It's an early sign, not a solid conclusion — worth watching, but not something to build big decisions on yet.

-- ==============================================================
-- Q4. Trending Hashtags (Used in >20 Posts)
-- ==============================================================
-- Objective : Find hashtags that appear in more than 20 posts.
-- Example GenAI Prompt :
--   "Find hashtags used in more than 20 posts."
-- --------------------------------------------------------------
-- Your Code ...

SELECT h.tag_name, 
	COUNT(ph.post_id) AS post_count
FROM hashtags h
JOIN post_hashtags ph 
    ON h.hashtag_id = ph.hashtag_id
GROUP BY h.tag_name
HAVING COUNT(ph.post_id) > 20
ORDER BY post_count DESC;


-- Solution Summary -- 
-- None of the hashtags in this dataset are used in more than 20 post.
-- That suggests the 20-post threshold from the question doesn't really fit this dataset's scale — it might be worth lowering the bar 
-- (we can ask more than 5 or 10 posts) to get a meaningful "trending" list at all.

-- ==============================================================
-- Q5. Top Influencers (Users with Most Followers)
-- ==============================================================
-- Objective : List users with the highest follower count.
-- Example GenAI Prompt :
--   "Find users with maximum followers."
-- --------------------------------------------------------------
-- Your Code ...

SELECT 
      u.user_id, 
      u.username, 
      COUNT(f.follower_id) AS follower_count
FROM users u
JOIN followers f 
      ON u.user_id = f.user_id
GROUP BY u.user_id, u.username
ORDER BY follower_count DESC
LIMIT 10;

-- Solution Summary -- 
-- At the moment, the difference between #1 and #10 is only 2 followers. 
-- Gap analysis:
-- Drop from rank 1→2 is just 1 follower away from (6→5); drop from rank 3→4 is also just 1 follower away (5→4). No sharp cliffs anywhere — distribution is nearly flat.
-- The platform’s most followed user is vthomas with 6 followers, followed by corey63 and christy26 with 5. After that, though, the 
-- leaderboard is pretty flat — another seven users are tied with exactly 4 followers each.
-- With numbers this close and this low, there really is not a standout “influencer” yet.

-- ==============================================================
-- Q6. Followers Who Never Interacted
-- ==============================================================
-- Objective : Identify users who follow others but have never liked or commented.
-- Example GenAI Prompt :
--   "Show users who follow others but never interacted."
-- --------------------------------------------------------------
-- Your Code ...

SELECT 
      DISTINCT u.user_id, 
      u.username
FROM users u
JOIN followers f 
      ON u.user_id = f.follower_user_id   -- they are following someone
WHERE NOT EXISTS (SELECT 1 FROM likes l WHERE l.user_id = u.user_id)
  AND NOT EXISTS (SELECT 1 FROM comments c WHERE c.user_id = u.user_id);


-- Solution Summary -- 
-- Among the 637 users who follow at least one person, 85 — or roughly 13% — have never liked or commented on anything themselves.
-- Roughly 1 in 8 user are acting purely one-directionally, they’re happy to follow but they’re not willing to interact. 
-- Some of this group might be turned into real participants by a little nudge, like a notification that someone they follow has posted something new.

-- ==============================================================
-- Q7. Hashtags with Highest Engagement
-- ==============================================================
-- Objective : Calculate total engagement (likes + comments) for each hashtag.
-- Example GenAI Prompt :
--   "Calculate engagement score per hashtag."
-- --------------------------------------------------------------
-- Your Code ...

SELECT h.tag_name,
    COUNT(DISTINCT l.like_id) AS total_likes,
    COUNT(DISTINCT c.comment_id) AS total_comments,
    COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS engagement
FROM hashtags h
JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
LEFT JOIN likes l ON ph.post_id = l.post_id
LEFT JOIN comments c ON ph.post_id = c.post_id
GROUP BY h.tag_name
ORDER BY engagement DESC
LIMIT 10;

-- Solution Summary -- 
-- #year leads clearly 23 total engagement, the strongest performer — and notably balanced (11 likes, 12 comments), meaning it drives both approval and conversation equally.
-- #identify is a close second (22), also perfectly balanced (11/11) — these two tags stand out as genuine engagement drivers as compared to the rest of the hashtags.
-- Engagement drops steadily from 23→13 across the top 10, with no sharp drop-off — a healthy, evenly distributed spread rather than one outlier tag dominating.
-- #year and #identify are the top hashtags candidates for both like and comments,But, #worker and #history tags are worth using when the goal is likes over pure overall reach.

-- ==============================================================
-- Q8. Busiest Posting Hours or Days
-- ==============================================================
-- Objective : Find which hour/day sees most posting activity.
-- Example GenAI Prompt :
--   "Write SQL to show which hour or weekday sees most posts."
-- --------------------------------------------------------------
-- Your Code ...

SELECT HOUR(created_at) AS post_hour,
       COUNT(*) AS total_posts
FROM posts
GROUP BY post_hour
ORDER BY total_posts DESC
LIMIT 10;

-- By day of week
SELECT DAYNAME(created_at) AS post_day,
       COUNT(*) AS total_posts
FROM posts
GROUP BY post_day
ORDER BY total_posts DESC;

-- Solution Summary -- 
-- Odd concentration at off-peak hours: The top 2 hours (5 AM and 3 AM) are both outside typical "active" daytime hours — this looks more like 
-- random/synthetic data distribution than real human behavior, since organic platforms usually peak in evenings (6–10 PM) when people are off work.
 -- The behaviour of the outcome shows that the data is randomly generated data rather than an organic usage pattern. If this were a real platform data 
 -- then, we'd expect sharper peaks (e.g., lunch hours, evenings) that aren't present here.
-- If Marketing is looking to time announcements or promoted content, Tuesday and Saturday have a slight edge but there is not one single day that clearly stands out.

-- ==============================================================
-- Q9. Inactive Users
-- ==============================================================
-- Objective : Find users who have never posted, liked, or commented.
-- Example GenAI Prompt :
--   "Find users who have never posted, liked, or commented."
-- --------------------------------------------------------------
-- Your Code ...


SELECT
    u.user_id,
    u.username,
    u.country
FROM users u
LEFT JOIN posts p
    ON u.user_id = p.user_id
LEFT JOIN likes l
    ON u.user_id = l.user_id
LEFT JOIN comments c
    ON u.user_id = c.user_id
WHERE p.post_id IS NULL
  AND l.like_id IS NULL
  AND c.comment_id IS NULL;

-- Solution Summary -- 
-- 4.7% of the user (47/1,000) has never engaged at all — no posts, likes, or comments. 
-- No country concentration: Spread thinly across 40+ countries (max 2 per country) — this is a behavioral segment, not regional.
-- Some users are totally inactive, no post, like, comment, or even follow. 
-- While some users are "lurkers"  they follow people but still never post/like/comment. These users are the better re-engagement 
-- target as (they've shown some intent by following). A nudge like “ say hi ! To your new friend” could be a natural re-engagement trigger.

-- ==============================================================
-- Q10. Top Countries with Most Influencers
-- ==============================================================
-- Objective : Identify countries with the highest number of influencers.
-- Example GenAI Prompt :
--   "Generate SQL to find countries that have the most followed users."
-- --------------------------------------------------------------
-- Your Code ...

 SELECT
    u.country,
    COUNT(*) AS influencer_count
FROM users u
JOIN followers f
    ON u.user_id = f.user_id
GROUP BY u.country
ORDER BY influencer_count DESC
LIMIT 10;

-- Solution Summary -- 
-- Gambia leads by a wide margin 18 follows received i.e; 50% more than the next tier (12), making it the clearest standout in this case.
-- Next there is a three-way tie at (12) Seychelles, French Polynesia, and Brunei Darussalam are equally weighted.
-- Steady taper, no cliff: From 18 down to 9, the drop is gradual (18→12→12→12→11→10→10→9→9→9) — a smooth decline rather than a sharp drop-off.
-- Since, here it counts total follow-relationships per country (not unique influential users), a country's rank can be driven either by
-- one or two heavily-followed users, or by many users each with a couple of followers.

-- ==============================================================
-- BONUS CHALLENGES
-- ==============================================================
-- 1. Engagement rate = (likes + comments) / posts

SELECT u.user_id, u.username,
       COUNT(DISTINCT p.post_id) AS total_posts,
       COUNT(DISTINCT l.like_id) AS total_likes,
       COUNT(DISTINCT c.comment_id) AS total_comments,
       (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) / COUNT(DISTINCT p.post_id) AS engagement_rate
FROM users u
JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY u.user_id, u.username
ORDER BY engagement_rate DESC
LIMIT 10;

-- Solution Summary --
-- turnermichelle leads with an 8.0 engagement rate (6 likes + 2 comments / 1 post) the highest score in the list, driven almost entirely by likes (75% of her engagement).
-- catherinebarrera is arguably the most interesting case here — zero likes but the highest comment count in the list, meaning her content is provoking real discussion,
--  not just passive scrolling approval, despite a “quieter” surface-level score.
-- Because engagement_rate divides by post count, a user with 1 post and 6 likes (rate=6) looks identical in "quality" to a hypothetical user with 10 posts and 60 likes — 
-- this ranking rewards single lucky hits over consistent performers, since none of these top 10 have more than one post to prove repeatability.

-- 2. Mutual followers

SELECT f1.user_id AS user_a, f1.follower_user_id AS user_b
FROM followers f1
JOIN followers f2
  ON f1.user_id = f2.follower_user_id
  AND f1.follower_user_id = f2.user_id
WHERE f1.user_id < f1.follower_user_id;

-- Solution Summary --
-- Only 1 mutual follower pair found, all other follow relationships are one-way
-- Mutual follows are essentially nonexistent on this platform out of 1,000 total follow relationships, only 1 pair (2 relationships) is reciprocal — that's
-- just 0.2% of all follows being mutual.
-- The vast majority of follows here are asymmetric (A follows B, but B doesn't follow back) That's a clear indication that this isn't a close-community 
-- where individuals follow their friends back, rather, it functions more like a broadcast/audience-building platform where following tends to flow one way 
-- (to producers or influencers) rather than reciprocating relationships.

-- 3. Most used hashtags by top 5 influencers

SELECT h.tag_name, COUNT(*) AS usage_count
FROM hashtags h
JOIN post_hashtags ph ON h.hashtag_id = ph.hashtag_id
JOIN posts p ON ph.post_id = p.post_id
JOIN (
    SELECT u.user_id
    FROM users u
    JOIN followers f ON u.user_id = f.user_id
    GROUP BY u.user_id
    ORDER BY COUNT(f.follower_id) DESC
    LIMIT 5
) AS top5 ON p.user_id = top5.user_id
GROUP BY h.tag_name
ORDER BY usage_count DESC;

-- Solution Summary --
-- This result indicates that the top influencers post on very different topic from one another. 
-- The tags themselves are unrelated in topic (entertainment, general nouns, numbers) — there’s no cluster (e.g., no repeated category like #tech or #sports appearing multiple times).
-- Every hashtag ties at usage_count = 1,  with 6 tags all appearing exactly once, there’s no repeated hashtag among the top 5 influencers posts. This means each --
-- hashtag was used in a single post, one time, by one of these users.
-- Since all values tie at 1, this strongly suggests each of the top 5 influencers posted very few times.

-- 4. Country-wise engagement leaderboard

SELECT u.country,
       COUNT(DISTINCT p.post_id) AS total_posts,
       COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id) AS total_engagement,
       (COUNT(DISTINCT l.like_id) + COUNT(DISTINCT c.comment_id)) / COUNT(DISTINCT p.post_id) AS engagement_per_post
FROM users u
JOIN posts p ON u.user_id = p.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY u.country
ORDER BY engagement_per_post DESC
LIMIT 10;

-- Solution Summary --
-- Guinea and Myanmar tie for the top score (4.00), but they arrived there very differently.Guinea's number is based on a single data, so it's less statistically
--  reliable as it could be one lucky post versus a repeated pattern.
-- Mozambique has the most posts (6) and the highest raw engagement (20) within the entire top 10, yet ranks last on a per-post basis (3.33) — its 
-- total output is impressive, but each individual post is doing comparatively less work than Guinea's or Ghana’s. Hence, volume vs. efficiency trade-off is  clearly visible.
-- 6 of the top 10 countries have 4 or fewer posts total, meaning a single well-performing post can swing a country's ranking significantly.
-- If we want a stable leaderboard, Ghana/Belarus/Bahrain (4 posts, 15 engagement, 3.75 rate) are more trustworthy than Guinea or Myanmar's top spot,
-- since they've proven the pattern across more posts rather than one or two lucky hit posts.

-- -----------------------------------------------------------------------------------------------------------------------------------------------------------------------