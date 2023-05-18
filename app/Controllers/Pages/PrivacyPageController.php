<?php

declare(strict_types=1);

namespace App\Controllers\Pages;

class PrivacyPageController
{
    function index()
    {
        $_css = ['site_header_10', 'site_footer_6', 'room_list_12', 'terms'];
        $_meta = meta()->setTitle('プライバシーポリシー');
        return view('statistics/privacy_content', compact('_meta', '_css'));
    }
}
