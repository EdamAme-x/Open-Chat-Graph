# Open-Chat-Graph
https://openchat-review.me

## プロジェクトの概要
サイトの目的は、各オープンチャットのメンバー数を収集し、グラフとしてサイト上で表示することです。  
ユーザーが投稿したオープンチャットのURLがデータベースに記録され、そのURLにクローラーがアクセスして更新内容を収集します。  
これにより、オープンチャットの成長傾向を把握し、比較することができ、トークルームの運営に役立ちます。　　

## ランキング表示のアルゴリズム
トップページには、登録されているオープンチャットのメンバー数上昇ランキングが表示されます。  
メンバー数が10人以上のオープンチャットが対象となります。  
バックグラウンドジョブでランク付けの点数を算出し、順位の更新を行います。    
ランキングの並び順はランク付けの点数が高い順となります。  
* ランキングの順位を決める計算式  
過去7日間の増加数: `(現在のメンバー数 - 過去7日間で最小のメンバー数)`  
ランク付けの点数: `過去7日間の増加数 + (過去7日間の増加数 / 過去7日間で最小のメンバー数) * 10`  
同じ増加数であれば、元々のメンバー数が少ないオープンチャットであるほど増加率が高くなり上位に上がります。

* ランキング更新処理のクラス  
https://github.com/pika-0203/Open-Chat-Graph/blob/main/app/Models/Repositories/StatisticsRankingUpdaterRepository.php

## クローリングのアルゴリズム
バックグラウンドジョブでは、データベース内の最終更新日時から8時間以上経過したレコードを更新します。  
ジョブは60分ごとに呼び出され、最大200件のレコードを一度に処理します。  
各URLへのアクセス間隔は3秒で設定されています。  

* バックグラウンドジョブクラス  
https://github.com/pika-0203/Open-Chat-Graph/blob/main/app/Services/OpenChat/Cron.php
* レコード更新処理のクラス  
https://github.com/pika-0203/Open-Chat-Graph/blob/main/app/Services/OpenChat/UpdateOpenChat.php
* クローラー本体のクラス  
https://github.com/pika-0203/Open-Chat-Graph/blob/main/app/Services/OpenChat/Crawler/OpenChatCrawler.php
* Symfony Crawlerラッパークラス
https://github.com/pika-0203/Open-Chat-Graph/blob/main/app/Services/Crawler/CrawlerFactory.php
