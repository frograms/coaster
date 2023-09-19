require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestString < Minitest::Test
    def test_string
      # half -> full width (to_full_characters)
      half_seq = ' 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      full_seq = '　０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
      not_target_half_seq = ((33..255).map { |c| c.chr('UTF-8') }.join.chars - half_seq.chars).join + '일이삼いちにさんイチニサン一二三'
      mixed_str = half_seq + not_target_half_seq
      # half -> full 1:1 잘 변환되는가?
      assert_equal half_seq.to_full_characters, full_seq
      # half -> full -> half 변환 시, 원래 string 유지되는가?
      assert_equal half_seq.to_full_characters.to_half_characters, half_seq
      # not_target string은 to full 변환 시도시 원본이 유지되는가?
      assert_equal not_target_half_seq.to_full_characters, not_target_half_seq
      # target / not_target이 섞여있는 문장에서, target'만' full로 변환되는가?
      assert_equal mixed_str.to_full_characters, full_seq + not_target_half_seq
      # target / not_target이 섞여있는 문장에서, half -> full -> half 변환시, 원래 string 유지되는가?
      assert_equal mixed_str.to_full_characters.to_half_characters, mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      assert_equal ''.to_full_characters, ''

      # half -> full width (to_full_characters with symbol)
      half_seq = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
      full_seq = '　！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～'
      not_target_half_seq = ((33..255).map { |c| c.chr('UTF-8') }.join.chars - half_seq.chars).join + '일이삼いちにさんイチニサン一二三'
      mixed_str = half_seq + not_target_half_seq
      # half -> full 1:1 잘 변환되는가?
      assert_equal half_seq.to_full_characters(symbol: true), full_seq
      # half -> full -> half 변환 시, 원래 string 유지되는가?
      assert_equal half_seq.to_full_characters(symbol: true).to_half_characters(symbol: true), half_seq
      # not_target string은 to full 변환 시도시 원본이 유지되는가?
      assert_equal not_target_half_seq.to_full_characters(symbol: true), not_target_half_seq
      # target / not_target이 섞여있는 문장에서, target'만' full로 변환되는가?
      assert_equal mixed_str.to_full_characters(symbol: true), full_seq + not_target_half_seq
      # target / not_target이 섞여있는 문장에서, half -> full -> half 변환시, 원래 string 유지되는가?
      assert_equal mixed_str.to_full_characters(symbol: true).to_half_characters(symbol: true), mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      assert_equal ''.to_full_characters, ''

      # full -> half width (to_half_characters)
      half_seq = ' 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
      full_seq = '　０１２３４５６７８９ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ'
      not_target_full_seq = ((33..255).map { |c| (c + 0xfee0).chr('UTF-8') }.join.chars - full_seq.chars).join + '일이삼いちにさんイチニサン一二三'
      mixed_str = full_seq + not_target_full_seq
      # full -> half 1:1 잘 변환되는가?
      assert_equal full_seq.to_half_characters, half_seq
      # full -> half -> full 변환 시, 원래 string 유지되는가?
      assert_equal full_seq.to_half_characters.to_full_characters, full_seq
      # not_target string은 to half 변환 시도시 원본이 유지되는가?
      assert_equal not_target_full_seq.to_half_characters, not_target_full_seq
      # target / not_target이 섞여있는 문장에서, target'만' half로 변환되는가?
      assert_equal mixed_str.to_half_characters, half_seq + not_target_full_seq
      # target / not_target이 섞여있는 문장에서, full -> half -> full 변환시, 원래 string 유지되는가?
      assert_equal mixed_str.to_half_characters.to_full_characters, mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      assert_equal ''.to_half_characters, ''

      # full -> half width (to_half_characters with symbol)
      half_seq = ' !"#$%&\'()*+,-./0123456789:;<=>?@ABCDEFGHIJKLMNOPQRSTUVWXYZ[\]^_`abcdefghijklmnopqrstuvwxyz{|}~'
      full_seq = '　！＂＃＄％＆＇（）＊＋，－．／０１２３４５６７８９：；＜＝＞？＠ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ［＼］＾＿｀ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ｛｜｝～'
      not_target_full_seq = ((33..255).map { |c| (c + 0xfee0).chr('UTF-8') }.join.chars - full_seq.chars).join + '일이삼いちにさんイチニサン一二三'
      mixed_str = full_seq + not_target_full_seq
      # full -> half 1:1 잘 변환되는가?
      expect(full_seq.to_half_characters(symbol: true)).to eq half_seq
      assert_equal full_seq.to_half_characters(symbol: true), half_seq
      # full -> half -> full 변환 시, 원래 string 유지되는가?
      expect(full_seq.to_half_characters(symbol: true).to_full_characters(symbol: true)).to eq full_seq
      assert_equal full_seq.to_half_characters(symbol: true).to_full_characters(symbol: true), full_seq
      # not_target string은 to half 변환 시도시 원본이 유지되는가?
      expect(not_target_full_seq.to_half_characters(symbol: true)).to eq not_target_full_seq
      assert_equal not_target_full_seq.to_half_characters(symbol: true), not_target_full_seq
      # target / not_target이 섞여있는 문장에서, target'만' half로 변환되는가?
      expect(mixed_str.to_half_characters(symbol: true)).to eq half_seq + not_target_full_seq
      assert_equal mixed_str.to_half_characters(symbol: true), half_seq + not_target_full_seq
      # target / not_target이 섞여있는 문장에서, full -> half -> full 변환시, 원래 string 유지되는가?
      expect(mixed_str.to_half_characters(symbol: true).to_full_characters(symbol: true)).to eq mixed_str
      assert_equal mixed_str.to_half_characters(symbol: true).to_full_characters(symbol: true), mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      expect(''.to_half_characters(symbol: true)).to eq ''
      assert_equal ''.to_half_characters(symbol: true), ''
    end
  end
end
