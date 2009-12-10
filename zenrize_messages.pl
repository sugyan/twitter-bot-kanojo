#!perl
use strict;
use warnings;

use YAML qw/DumpFile LoadFile/;
use Text::MeCab;

my $messages = LoadFile('messages.yaml');
for my $key (qw/auto return/) {
    for my $index (0..$#{$messages->{$key}}) {
        my $message = $messages->{$key}[$index];
        $messages->{$key}[$index] = zenrize_all($message);
    };
}
DumpFile('zenra_messages.yaml', $messages);


# テキスト全体を全裸にする
sub zenrize_all {
    my $text = shift;

    my $result = '';
    for my $sentence (split/(\s+)/, $text) {
        $result .= $sentence =~ /\s+/ ?
          $sentence : zenrize($sentence);
    }
    return $result;
}

# 日本語の文章を全裸にする
sub zenrize {
    my $sentence = shift;

    my $zenra  = '全裸で';
    my $mecab  = Text::MeCab->new();
    my $result = '';
    my $n = $mecab->parse($sentence);

    # 末尾まで進める
    $n = $n->next while ($n->next);

    my $flg = 0;
    # 末尾からさかのぼる
    while (($n = $n->prev)->prev) {
        # フラグがたっていれば「全裸で」を挿入
        # ただし、名詞／副詞／動詞のときはまだ挿入しない
        if ($flg) {
            my $insert = 1;
            if ($n->feature =~ / \A (名詞|副詞|動詞) /xms) {
                $insert = 0;
            }
            # また、連用形の動詞→助(動)詞の場合も挿入しない
            elsif ($n->feature =~ / \A 助(動)?詞 /xms &&
                       (split(/,/, $n->prev->feature))[5] =~ / 連用 /xms) {
                $insert = 0;
            }
            if ($insert) {
                $result = $zenra . $result;
                $flg = 0;
            }
        }
        # 出力の連結
        $result = $n->surface . $result;
        # 動詞を検出してフラグをたてる
        if ($n->feature =~ / \A 動詞 /xms) {
            $flg = 1;
        }
    }
    # 先頭のチェック
    if ($flg) {
        $result = $zenra . $result;
    }

    return $result;
}
