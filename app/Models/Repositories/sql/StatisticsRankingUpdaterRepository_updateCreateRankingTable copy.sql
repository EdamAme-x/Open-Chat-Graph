/*
 * 昨日〜7日前の平均メンバー数と、最新メンバー数を比較して、差と増減%をランキングテーブルに挿入する。
 * 差 + (増減% / 10) を`index1`カラムに挿入する。
 * メンバー１０人以上のオープンチャットが対象
 */
INSERT INTO
    statistics_ranking_temp (
        open_chat_id,
        diff_member,
        percent_increase,
        index1
    )
SELECT
    t1.open_chat_id,
    t1.member - t2.member AS diff_member,
    ((t1.member - t2.member) / t2.member) * 100 AS percent_increase,
    (
        (t1.member - t2.member) + (((t1.member - t2.member) / t2.member) * 10)
    ) AS index1
FROM
    (
        SELECT
            st.open_chat_id,
            (
                SELECT
                    st2.member
                FROM
                    statistics AS st2
                WHERE
                    st2.open_chat_id = st.open_chat_id
                ORDER BY
                    `date` DESC
                LIMIT
                    1
            ) AS member
        FROM
            statistics AS st
        WHERE
            st.member >= 10
        GROUP BY
            st.open_chat_id
    ) t1
    JOIN (
        SELECT
            st3.open_chat_id,
            AVG(st3.member) AS member
        FROM
            statistics AS st3
        WHERE
            `date` >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
            AND `date` <= (
                SELECT
                    DATE_SUB(MAX(st4.date), INTERVAL 1 DAY)
                FROM
                    statistics AS st4
                WHERE
                    st4.open_chat_id = st3.open_chat_id
            )
            AND st3.member >= 10
        GROUP BY
            st3.open_chat_id
    ) t2 ON t1.open_chat_id = t2.open_chat_id;

/*
 * `index1`カラムを降順でソートして、statistics_rankingに挿入する。
 */
DELETE FROM
    statistics_ranking;

SET
    @row_number := 0;

INSERT INTO
    statistics_ranking (
        id,
        open_chat_id,
        diff_member,
        percent_increase,
        index1
    )
SELECT
    (@row_number := @row_number + 1),
    statistics_ranking_temp.*
FROM
    statistics_ranking_temp
ORDER BY
    CASE
        WHEN index1 > 0 THEN 1 -- index1が0より上のグループ
        WHEN index1 = 0 THEN 2 -- index1が0のグループ
        ELSE 3 -- index1が0未満のグループ
    END,
    CASE
        WHEN index1 = 0 THEN open_chat_id -- open_chat_idで降順ソート
        ELSE index1
    END DESC;

DELETE FROM
    statistics_ranking_temp;