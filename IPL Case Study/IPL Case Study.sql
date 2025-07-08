use ipl;

-- SQL Queries for IPL Database Analysis

-- 1. Show the percentage of wins of each bidder in the order of highest to lowest percentage.
SELECT B.BIDDER_ID, B.BIDDER_NAME, 
       COUNT(BD.BIDDER_ID) AS Total_Bids,
       SUM(CASE WHEN BD.BID_STATUS = 'Won' THEN 1 ELSE 0 END) AS Total_Wins,
       ROUND((SUM(CASE WHEN BD.BID_STATUS = 'Won' THEN 1 ELSE 0 END) / NULLIF(COUNT(BD.BIDDER_ID), 0)) * 100, 2) AS Win_Percentage
FROM IPL_BIDDING_DETAILS BD
JOIN IPL_BIDDER_DETAILS B ON BD.BIDDER_ID = B.BIDDER_ID
GROUP BY B.BIDDER_ID, B.BIDDER_NAME
ORDER BY Win_Percentage DESC;


-- 2. Display the number of matches conducted at each stadium with the stadium name and city.
SELECT S.STADIUM_NAME, S.CITY, COUNT(MS.MATCH_ID) AS Matches_Conducted
FROM IPL_MATCH_SCHEDULE MS
JOIN IPL_STADIUM S ON MS.STADIUM_ID = S.STADIUM_ID
GROUP BY S.STADIUM_NAME, S.CITY;

-- 3. In a given stadium, what is the percentage of wins by a team that has won the toss?
SELECT S.STADIUM_NAME,
       ROUND((SUM(CASE WHEN M.TOSS_WINNER = M.MATCH_WINNER THEN 1 ELSE 0 END) / COUNT(*)) * 100, 2) AS Toss_Win_Percentage
FROM IPL_MATCH M
JOIN IPL_MATCH_SCHEDULE MS ON M.MATCH_ID = MS.MATCH_ID
JOIN IPL_STADIUM S ON MS.STADIUM_ID = S.STADIUM_ID
WHERE S.STADIUM_NAME = 'M. Chinnaswamy Stadium'  -- Replace with desired stadium name
GROUP BY S.STADIUM_NAME;

-- 4. Show the total bids along with the bid team and team name.
SELECT BD.BID_TEAM, T.TEAM_NAME, COUNT(*) AS Total_Bids
FROM IPL_BIDDING_DETAILS BD
JOIN IPL_TEAM T ON BD.BID_TEAM = T.TEAM_ID
GROUP BY BD.BID_TEAM, T.TEAM_NAME;

-- 5. Show the team ID who won the match as per the win details.
SELECT DISTINCT MATCH_WINNER AS Winning_Team_ID
FROM IPL_MATCH
WHERE MATCH_WINNER IS NOT NULL;

-- 6. Display the total matches played, total matches won and total matches lost by the team along with its team name.
SELECT T.TEAM_NAME, 
       COUNT(M.MATCH_ID) AS Total_Matches_Played,
       SUM(CASE WHEN T.TEAM_ID = M.MATCH_WINNER THEN 1 ELSE 0 END) AS Total_Matches_Won,
       SUM(CASE WHEN T.TEAM_ID <> M.MATCH_WINNER THEN 1 ELSE 0 END) AS Total_Matches_Lost
FROM IPL_TEAM T
LEFT JOIN IPL_MATCH M 
    ON T.TEAM_ID = M.TEAM_ID1 OR T.TEAM_ID = M.TEAM_ID2
GROUP BY T.TEAM_NAME;

-- 7. Display the bowlers for the Mumbai Indians team.
SELECT P.PLAYER_NAME
FROM IPL_PLAYER P
JOIN IPL_TEAM_PLAYERS TP ON P.PLAYER_ID = TP.PLAYER_ID
JOIN IPL_TEAM T ON TP.TEAM_ID = T.TEAM_ID
WHERE T.TEAM_NAME = 'Mumbai Indians' AND TP.PLAYER_ROLE = 'Bowler';

-- 8. Display teams with more than 4 all-rounders in descending order.
SELECT T.TEAM_NAME, COUNT(P.PLAYER_ID) AS All_Rounder_Count
FROM IPL_PLAYER P
JOIN IPL_TEAM_PLAYERS TP ON P.PLAYER_ID = TP.PLAYER_ID
JOIN IPL_TEAM T ON TP.TEAM_ID = T.TEAM_ID
WHERE TP.PLAYER_ROLE = 'All-Rounder'
GROUP BY T.TEAM_NAME
HAVING All_Rounder_Count > 4
ORDER BY All_Rounder_Count DESC;


SELECT 
    ibd.BID_STATUS, 
    YEAR(ibd.BID_DATE) AS BID_YEAR, 
    SUM(ibp.TOTAL_POINTS) AS TOTAL_BIDDERS_POINTS
FROM 
    IPL_BIDDING_DETAILS ibd
    INNER JOIN IPL_BIDDER_POINTS ibp ON ibd.BIDDER_ID = ibp.BIDDER_ID
GROUP BY 
    ibd.BID_STATUS, 
    YEAR(ibd.BID_DATE)
ORDER BY 
    TOTAL_BIDDERS_POINTS DESC, 
    BID_YEAR;
-- 9. Total bidders' points for each bidding status for bids on CSK when they won at M. Chinnaswamy Stadium.
SELECT 
    ibd.BID_STATUS, 
    YEAR(ibd.BID_DATE) AS BID_YEAR, 
    SUM(ibp.TOTAL_POINTS) AS TOTAL_BIDDERS_POINTS
FROM 
    IPL_BIDDING_DETAILS ibd
    INNER JOIN IPL_MATCH_SCHEDULE ims ON ibd.SCHEDULE_ID = ims.SCHEDULE_ID
    INNER JOIN IPL_MATCH im ON ims.MATCH_ID = im.MATCH_ID
    INNER JOIN IPL_TEAM it ON ibd.BID_TEAM = it.TEAM_ID
    INNER JOIN IPL_STADIUM ist ON ims.STADIUM_ID = ist.STADIUM_ID
    INNER JOIN IPL_BIDDER_POINTS ibp ON ibd.BIDDER_ID = ibp.BIDDER_ID
WHERE 
    ist.STADIUM_NAME LIKE '%Chinnaswamy%'
    AND it.TEAM_NAME LIKE '%CSK%'
    AND im.MATCH_WINNER = it.TEAM_ID
GROUP BY 
    ibd.BID_STATUS, 
    YEAR(ibd.BID_DATE)
ORDER BY 
    TOTAL_BIDDERS_POINTS DESC, 
    BID_YEAR;


-- 10. Extract the Bowlers and All-Rounders that are in the 5 highest number of wickets.
SELECT 
    it.TEAM_NAME, 
    ip.PLAYER_NAME, 
    itp.PLAYER_ROLE,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED) AS wickets
FROM 
    IPL_PLAYER ip
    INNER JOIN IPL_TEAM_PLAYERS itp ON ip.PLAYER_ID = itp.PLAYER_ID
    INNER JOIN IPL_TEAM it ON itp.TEAM_ID = it.TEAM_ID
WHERE 
    itp.PLAYER_ROLE IN ('Bowler', 'All-Rounder')
    AND ip.PERFORMANCE_DTLS LIKE '%Wickets:%'
ORDER BY 
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED) DESC
LIMIT 5;

SELECT 
    it.TEAM_NAME,
    ip.PLAYER_NAME,
    itp.PLAYER_ROLE,
    CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED) AS wickets
FROM 
    IPL_PLAYER ip
    INNER JOIN IPL_TEAM_PLAYERS itp ON ip.PLAYER_ID = itp.PLAYER_ID
    INNER JOIN IPL_TEAM it ON itp.TEAM_ID = it.TEAM_ID
WHERE 
    itp.PLAYER_ROLE IN ('Bowler', 'All-Rounder')
    AND (
        SELECT COUNT(*)
        FROM (
            SELECT DISTINCT CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED) AS w_count
            FROM IPL_PLAYER p
            INNER JOIN IPL_TEAM_PLAYERS tp ON p.PLAYER_ID = tp.PLAYER_ID
            WHERE tp.PLAYER_ROLE IN ('Bowler', 'All-Rounder')
            AND CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(p.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED) > 
                CAST(SUBSTRING_INDEX(SUBSTRING_INDEX(ip.PERFORMANCE_DTLS, 'Wickets:', -1), ' ', 1) AS UNSIGNED)
        ) AS higher_wickets
    ) < 5
ORDER BY 
    wickets DESC, ip.PLAYER_NAME;


-- 11. Show the percentage of toss wins of each bidder in descending order.
SELECT 
    ibd.BIDDER_ID,
    (SELECT BIDDER_NAME FROM IPL_BIDDER_DETAILS WHERE BIDDER_ID = ibd.BIDDER_ID) AS BIDDER_NAME,
    COUNT(*) AS total_bids,
    SUM(CASE WHEN im.TOSS_WINNER = ibd.BID_TEAM THEN 1 ELSE 0 END) AS toss_wins,
    (SUM(CASE WHEN im.TOSS_WINNER = ibd.BID_TEAM THEN 1 ELSE 0 END) / COUNT(*)) * 100 AS toss_win_percentage
FROM 
    IPL_BIDDING_DETAILS ibd
    INNER JOIN IPL_MATCH_SCHEDULE ims ON ibd.SCHEDULE_ID = ims.SCHEDULE_ID
    INNER JOIN IPL_MATCH im ON ims.MATCH_ID = im.MATCH_ID
GROUP BY 
    ibd.BIDDER_ID
ORDER BY 
    toss_win_percentage DESC;

-- 12. Find the IPL season which has a duration and max duration.
SELECT 
    TOURNMT_ID,
    TOURNMT_NAME,
    CONCAT(DATEDIFF(TO_DATE, FROM_DATE), ' days') AS Duration_column,
    DATEDIFF(TO_DATE, FROM_DATE) AS Duration
FROM 
    IPL_TOURNAMENT
WHERE 
    DATEDIFF(TO_DATE, FROM_DATE) = (
        SELECT 
            MAX(DATEDIFF(TO_DATE, FROM_DATE))
        FROM 
            IPL_TOURNAMENT
    );

-- 13. Calculate the total points month-wise for the 2017 bid year (Using Joins).
SELECT 
    ibd.BIDDER_ID,
    ibdet.BIDDER_NAME,
    YEAR(ibd.BID_DATE) AS BID_YEAR,
    MONTH(ibd.BID_DATE) AS BID_MONTH,
    SUM(ibp.TOTAL_POINTS) AS TOTAL_POINTS
FROM 
    IPL_BIDDING_DETAILS ibd
    INNER JOIN IPL_BIDDER_DETAILS ibdet ON ibd.BIDDER_ID = ibdet.BIDDER_ID
    INNER JOIN IPL_BIDDER_POINTS ibp ON ibd.BIDDER_ID = ibp.BIDDER_ID
WHERE 
    YEAR(ibd.BID_DATE) = 2017
GROUP BY 
    ibd.BIDDER_ID,
    ibdet.BIDDER_NAME,
    YEAR(ibd.BID_DATE),
    MONTH(ibd.BID_DATE)
ORDER BY 
    TOTAL_POINTS DESC,
    BID_MONTH ASC;

-- 14. Same as Question 13 but using Sub-queries.
SELECT 
    bd.BIDDER_ID,
    (SELECT BIDDER_NAME FROM IPL_BIDDER_DETAILS WHERE BIDDER_ID = bd.BIDDER_ID) AS BIDDER_NAME,
    YEAR(bd.BID_DATE) AS BID_YEAR,
    MONTH(bd.BID_DATE) AS BID_MONTH,
    (SELECT SUM(TOTAL_POINTS) FROM IPL_BIDDER_POINTS WHERE BIDDER_ID = bd.BIDDER_ID) AS TOTAL_POINTS
FROM 
    IPL_BIDDING_DETAILS bd
WHERE 
    YEAR(bd.BID_DATE) = 2017
GROUP BY 
    bd.BIDDER_ID,
    YEAR(bd.BID_DATE),
    MONTH(bd.BID_DATE)
ORDER BY 
    TOTAL_POINTS DESC,
    BID_MONTH ASC;

-- 15. Top 3 and Bottom 3 Bidders for the 2018 bidding year.
WITH RankedBidders AS (
    SELECT 
        ibp.BIDDER_ID,
        SUM(ibp.TOTAL_POINTS) AS TOTAL_POINTS,
        ibd.BIDDER_NAME,
        RANK() OVER (ORDER BY SUM(ibp.TOTAL_POINTS) DESC) AS rank_desc,
        RANK() OVER (ORDER BY SUM(ibp.TOTAL_POINTS) ASC) AS rank_asc
    FROM 
        IPL_BIDDER_POINTS ibp
        INNER JOIN IPL_BIDDER_DETAILS ibd ON ibp.BIDDER_ID = ibd.BIDDER_ID
        INNER JOIN IPL_BIDDING_DETAILS bd ON ibp.BIDDER_ID = bd.BIDDER_ID
    WHERE 
        YEAR(bd.BID_DATE) = 2018
    GROUP BY 
        ibp.BIDDER_ID, ibd.BIDDER_NAME
)
SELECT 
    rb.BIDDER_ID,
    rb.rank_desc AS 'Rank',
    rb.TOTAL_POINTS,
    CASE WHEN rb.rank_desc <= 3 THEN rb.BIDDER_NAME ELSE NULL END AS Highest_3_Bidders,
    CASE WHEN rb.rank_asc <= 3 THEN rb.BIDDER_NAME ELSE NULL END AS Lowest_3_Bidders
FROM 
    RankedBidders rb
WHERE 
    rb.rank_desc <= 3 OR rb.rank_asc <= 3
ORDER BY 
    rb.rank_desc;


