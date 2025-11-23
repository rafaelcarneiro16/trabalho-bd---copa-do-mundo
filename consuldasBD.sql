/*===========================================================
1) Estatísticas de vitórias, empates e derrotas por seleção
===========================================================*/
SELECT 
    t.team_name,
    SUM(CASE WHEN p.team_a_id = t.team_id THEN p.team_a_win 
             WHEN p.team_b_id = t.team_id THEN p.team_b_win END) AS vitorias,
    SUM(CASE WHEN p.draw = 1 THEN 1 ELSE 0 END) AS empates,
    SUM(
        CASE 
            WHEN p.team_a_id = t.team_id AND p.team_b_win = 1 THEN 1
            WHEN p.team_b_id = t.team_id AND p.team_a_win = 1 THEN 1
            ELSE 0 
        END
    ) AS derrotas
FROM TEAMS t
LEFT JOIN PARTIDAS p ON p.team_a_id = t.team_id OR p.team_b_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY vitorias DESC;


/*===========================================================
2) Quantas partidas cada seleção jogou
===========================================================*/
SELECT 
    t.team_name,
    COUNT(*) AS partidas_jogadas
FROM TEAMS t
JOIN PARTIDAS p ON p.team_a_id = t.team_id OR p.team_b_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY partidas_jogadas DESC;


/*===========================================================
3) Seleção que mais marcou gols
===========================================================*/
SELECT 
    t.team_name,
    SUM(CASE WHEN p.team_a_id = t.team_id THEN p.score_a
             WHEN p.team_b_id = t.team_id THEN p.score_b END) AS gols_marcados
FROM TEAMS t
JOIN PARTIDAS p ON p.team_a_id = t.team_id OR p.team_b_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY gols_marcados DESC;


/*===========================================================
4) Seleção que mais sofreu gols
===========================================================*/
SELECT 
    t.team_name,
    SUM(CASE WHEN p.team_a_id = t.team_id THEN p.score_b
             WHEN p.team_b_id = t.team_id THEN p.score_a END) AS gols_sofridos
FROM TEAMS t
JOIN PARTIDAS p ON p.team_a_id = t.team_id OR p.team_b_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY gols_sofridos DESC;


/*===========================================================
5) Vitórias por torneio para cada seleção
===========================================================*/
SELECT 
    tor.year,
    t.team_name,
    COUNT(*) AS vitorias
FROM PARTIDAS p
JOIN TEAMS t 
    ON (p.team_a_id = t.team_id AND p.team_a_win = 1)
    OR (p.team_b_id = t.team_id AND p.team_b_win = 1)
JOIN TORNEIOS tor ON tor.tournament_id = p.tournament_id
GROUP BY tor.year, t.team_name
ORDER BY tor.year, vitorias DESC;


/*===========================================================
6) Seleção que teve mais vice-campeonatos
   (vice = perdedor da partida final)
===========================================================*/
SELECT 
    t.team_name,
    COUNT(*) AS vice_campeonatos
FROM PARTIDAS p
JOIN TORNEIOS tor ON tor.tournament_id = p.tournament_id
JOIN TEAMS t 
    ON (
        -- team A perdeu a final → vice
        (p.stage_name = 'final' AND p.team_a_win = 0 AND p.team_b_win = 1 AND t.team_id = p.team_a_id)
        OR
        -- team B perdeu a final → vice
        (p.stage_name = 'final' AND p.team_b_win = 0 AND p.team_a_win = 1 AND t.team_id = p.team_b_id)
    )
GROUP BY t.team_name
ORDER BY vice_campeonatos DESC;


/*===========================================================
7) Número de títulos por seleção
===========================================================*/
SELECT 
    t.team_name,
    COUNT(*) AS titulos
FROM TEAMS t
JOIN TORNEIOS tor ON tor.winner = t.team_name
GROUP BY t.team_name
ORDER BY titulos DESC;


/*===========================================================
8) Quantas partidas cada estádio recebeu
===========================================================*/
SELECT 
    stadium_name,
    COUNT(*) AS partidas
FROM PARTIDAS
GROUP BY stadium_name
ORDER BY partidas DESC;


/*===========================================================
9) Seleções com mais derrotas
===========================================================*/
SELECT 
    t.team_name,
    SUM(
        CASE 
            WHEN p.team_a_id = t.team_id AND p.team_b_win = 1 THEN 1
            WHEN p.team_b_id = t.team_id AND p.team_a_win = 1 THEN 1
            ELSE 0
        END
    ) AS derrotas
FROM TEAMS t
LEFT JOIN PARTIDAS p 
    ON p.team_a_id = t.team_id OR p.team_b_id = t.team_id
GROUP BY t.team_id, t.team_name
ORDER BY derrotas DESC;


/*===========================================================
10) Maiores goleadas da história da Copa do Mundo
    - Ordena pela maior diferença de gols
    - Desempate pelo maior número total de gols
===========================================================*/
SELECT
    p.tournament_id,
    p.match_id,
    t1.team_name AS time_a,
    t2.team_name AS time_b,
    p.score_a,
    p.score_b,
    ABS(p.score_a - p.score_b) AS diferenca_gols,
    (p.score_a + p.score_b) AS total_gols
FROM PARTIDAS p
JOIN TEAMS t1 ON t1.team_id = p.team_a_id
JOIN TEAMS t2 ON t2.team_id = p.team_b_id
ORDER BY 
    diferenca_gols DESC,
    total_gols DESC;

