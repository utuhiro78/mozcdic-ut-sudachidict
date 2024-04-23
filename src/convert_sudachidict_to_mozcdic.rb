#! /usr/bin/env ruby
# coding: utf-8

# Author: UTUMI Hirosi (utuhiro78 at yahoo dot co dot jp)
# License: Apache License, Version 2.0

require 'open-uri'
require 'nkf'

url = "http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/"
date = URI.open(url).read.split("/core_lex.zip")[0]
date = date.split("'")[-1]

`wget -N http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/#{date}/small_lex.zip`
`wget -N http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/#{date}/core_lex.zip`
`wget -N http://sudachi.s3-website-ap-northeast-1.amazonaws.com/sudachidict-raw/#{date}/notcore_lex.zip`

`rm -f {small_lex.csv,core_lex.csv,notcore_lex.csv}`
`unzip small_lex.zip`
`unzip core_lex.zip`
`unzip notcore_lex.zip`

`cat small_lex.csv core_lex.csv notcore_lex.csv > sudachidict-#{date}.txt`

filename = "sudachidict-" + date + ".txt"
dicname = "mozcdic-ut-sudachidict.txt"

# sudachidict を読み込む
file = File.new(filename, "r")
	lines = file.read.split("\n")
file.close

# Mozc の一般名詞のID
id_mozc = "1843"

l2 = []
p = 0

# sudachidict のエントリから読みと表記を取得
lines.length.times do |i|
	# https://github.com/WorksApplications/Sudachi/blob/develop/docs/user_dict.md
	# 見出し (TRIE 用),左連接ID,右連接ID,コスト,見出し (解析結果表示用),品詞1,品詞2,品詞3,品詞4,品詞 (活用型),品詞 (活用形),読み,正規化表記,辞書形ID,分割タイプ,A単位分割情報,B単位分割情報,※未使用

	# little glee monster,4785,4785,5000,Little Glee Monster,名詞,固有名詞,一般,*,*,*,リトルグリーモンスター,Little Glee Monster,*,A,*,*,*,*
	# アイアンマイケル,5144,4788,9652,アイアンマイケル,名詞,固有名詞,人名,一般,*,*,アイアンマイケル,アイアン・マイケル,*,C,*,*,*,*

	s = lines[i].split(",")

	# 「読み」を読みにする
	yomi = s[11]
	yomi = yomi.tr("=・", "")

	# 「見出し (解析結果表示用)」を表記にする
	hyouki = s[4]

	# 読みが2文字以下の場合はスキップ
	if yomi[2] == nil ||
	# 表記が1文字の場合はスキップ
	hyouki[1] == nil ||
	# 表記が26文字以上の場合はスキップ。候補ウィンドウが大きくなりすぎる
	hyouki[25] != nil ||
	# 名詞以外の場合はスキップ
	s[5] != "名詞" ||
	# 「地名」をスキップ。地名は郵便番号ファイルから生成する
	s[7] == "地名" ||
	# 「名」をスキップ
	s[8] == "名"
		next
	end

	# 読みのカタカナをひらがなに変換
	# 「tr('ァ-ヴ', 'ぁ-ゔ')」よりnkfのほうが速い
	yomi = NKF.nkf("--hiragana -w -W", yomi)
	yomi = yomi.tr('ゐゑ', 'いえ')

	# 読みがひらがな以外を含む場合はスキップ
	if yomi != yomi.scan(/[ぁ-ゔー]/).join
		next
	end

	# 表記が英数字のみで、小文字化した s[0] が表記と同じ場合は、
	# s[0] に表記を入れる
	if hyouki.length == hyouki.bytesize && hyouki.downcase == s[0].downcase
		s[0] = hyouki
	end

	# 表記が s[0] と異なる場合はスキップ
	if hyouki != s[0]
		next
	end

	# [読み, 表記, コスト] の順に並べる
	l2[p] = [yomi, hyouki, s[3].to_i]
	p = p + 1
end

lines = l2.sort
l2 = []

# Mozc 形式で書き出す
dicfile = File.new(dicname, "w")

lines.length.times do |i|
	s1 = lines[i]
	s2 = lines[i - 1]

	# 他の [読み..表記] と重複するエントリをスキップ
	if s1[0..1] == s2[0..1]
		next
	end

	# コストが 0 未満の場合は 0 にする
	if s1[2] < 0
		s1[2] = 0
	end

	# コストが 10000 以上なら 9999 にする
	if s1[2] > 9999
		s1[2] = 9999
	end

	# 全体のコストを 8000 台にする
	s1[2] = 8000 + (s1[2] / 10)

	# [読み, id_mozc, id_mozc, コスト, 表記] の順に並べる
	t = [s1[0], id_mozc, id_mozc, s1[2].to_s, s1[1]]
	dicfile.puts t.join("	")
end

dicfile.close
