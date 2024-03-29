<?php

declare(strict_types=1);

namespace App\Services\Statistics;

use App\Models\Repositories\OpenChatListRepositoryInterface;
use App\Services\Traits\TraitPaginationRecordsCalculator;

class OpenChatStatisticsRanking
{
    use TraitPaginationRecordsCalculator;

    private OpenChatListRepositoryInterface $openChatListRepository;

    function __construct(OpenChatListRepositoryInterface $openChatListRepository)
    {
        $this->openChatListRepository = $openChatListRepository;
    }

    /**
     * @return array `['pageNumber' => int, 'maxPageNumber' => int, 'openChatList' => array, 'totalRecords' => int]`
     */
    function get(int $pageNumber, int $limit)
    {
        // ページの最大数を取得する
        $totalRecords = $this->openChatListRepository->getRankingRecordCount();
        $maxPageNumber = $this->calcMaxPages($totalRecords, $limit);

        if ($pageNumber > $maxPageNumber) {
            // 現在のページ番号が最大ページ番号を超えている場合
            return false;
        }

        // ランキングを取得する
        $openChatList = $this->openChatListRepository->findMemberStatsRanking(
            $this->calcOffset($pageNumber, $limit),
            $limit * $pageNumber
        );

        // 説明文を半角140文字以内にする
        foreach ($openChatList as &$oc) {
            $oc['description'] = mb_strimwidth($oc['description'], 0, 140, '…',);
        }

        return compact('pageNumber', 'maxPageNumber', 'openChatList', 'totalRecords');
    }
}
