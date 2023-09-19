require 'test_helper'
require 'minitest/autorun'

module Coaster
  class TestString < Minitest::Test
    def test_string
      # hiragana -> katakana (to_katakana)
      hiragana_seq = 'ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖゝゞ'
      katakana_seq = 'ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヽヾ'
      not_japanese_seq='안녕하세요_hello~world!_一二三'
      mixed_str = hiragana_seq + not_japanese_seq
      # 히라가나 -> 카타카나 1:1 변환 가능한가?
      assert_equal hiragana_seq.to_katakana, katakana_seq
      # 히라가나 -> 카타카나 -> 히라가나 변환시, 원래 string 유지되는가?
      assert_equal hiragana_seq.to_katakana.to_hiragana, hiragana_seq
      # 일본어가 아닌 string은 카타카나 변환 시도시 원본이 유지되는가?
      assert_equal not_japanese_seq.to_katakana, not_japanese_seq
      # 일본어와 아닌것이 섞여있는 문장에서, 히라가나'만' 카타카나로 변환되는가?
      assert_equal mixed_str.to_katakana, katakana_seq + not_japanese_seq
      # 일본어와 아닌것이 섞여있는 문장에서, 히라가나 -> 카타카나 -> 히라가나 변환시, 원래 string 유지되는가?
      assert_equal mixed_str.to_katakana.to_hiragana, mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      assert_equal ''.to_katakana, ''

      # katakana -> hiragana (to_hiragana)
      katakana_seq = 'ァアィイゥウェエォオカガキギクグケゲコゴサザシジスズセゼソゾタダチヂッツヅテデトドナニヌネノハバパヒビピフブプヘベペホボポマミムメモャヤュユョヨラリルレロヮワヰヱヲンヴヵヶヽヾ'
      hiragana_seq = 'ぁあぃいぅうぇえぉおかがきぎくぐけげこごさざしじすずせぜそぞただちぢっつづてでとどなにぬねのはばぱひびぴふぶぷへべぺほぼぽまみむめもゃやゅゆょよらりるれろゎわゐゑをんゔゕゖゝゞ'
      not_japanese_seq='안녕하세요_hello~world!_一二三'
      mixed_str = katakana_seq + not_japanese_seq
      # 카타카나 -> 히라가나 1:1 변환 가능한가?
      assert_equal katakana_seq.to_hiragana, hiragana_seq
      # 카타카나 -> 히라가나 -> 카타카나 변환시, 원래 string 유지되는가?
      assert_equal katakana_seq.to_hiragana.to_katakana, katakana_seq
      # 일본어가 아닌 string은 히라가나 변환 시도시 원본이 유지되는가?
      assert_equal not_japanese_seq.to_hiragana, not_japanese_seq
      # 일본어와 아닌것이 섞여있는 문장에서, 카타카나'만' 히라가나로 변환되는가?
      assert_equal mixed_str.to_hiragana, hiragana_seq + not_japanese_seq
      # 일본어와 아닌것이 섞여있는 문장에서, 카타카나 -> 히라가나 -> 카타카나 변환시, 원래 string 유지되는가?
      assert_equal mixed_str.to_hiragana.to_katakana, mixed_str
      # 공백문자열에 다른게 추가되지는 않는가?
      assert_equal ''.to_hiragana, ''

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

      # strips tags correctly
      # 알라딘 "독거소녀 삐삐" 중 contents
      old_str = "<p>목차<BR>\r\n\n<BR>\r\n\n<B>1부  괜찮아 사람이 되어도</B><BR>\r\n\n<BR>\r\n\n거절학개론 - 이 필수 교양서의 목차를 지운다 19<BR>\r\n\n소프트아이스크림 20<BR>\r\n\n말과 투구와 노새와 랩 22<BR>\r\n\n헝거 문Hunger Moon 24<BR>\r\n\n술병은 비고 스파이는 떠나요 25<BR>\r\n\n눈사람 소년 28<BR>\r\n\n유리로 망치를 깨서 탈출할까요 30<BR>\r\n\n목단꽃 무늬 접시 32<BR>\r\n\n포도 잎 일곱 장 33<BR>\r\n\n프랑스 자수가 놓인 식탁보 34<BR>\r\n\n흰 시간 검은 시간 36<BR>\r\n\n맑음 37<BR>\r\n\n해피 어스 데이 투 유Happy Earth Day to You 40<BR>\r\n\n아득한 아카펠라 42<BR>\r\n\n일기예보 45 <BR>\r\n\n<BR>\r\n\n<B>2부 농담의 힘을 믿고 끝까지</B><BR>\r\n\n<BR>\r\n\n지그시 51<BR>\r\n\n드디어 52<BR>\r\n\n아마도 53<BR>\r\n\n공중사원 56<BR>\r\n\n6월 60<BR>\r\n\n피노키오 62<BR>\r\n\n고군분투 63<BR>\r\n\n한 번도 본 적 없는 목소리가 손을 흔들면 64<BR>\r\n\n볕멍 67<BR>\r\n\n판탈롱 68<BR>\r\n\n만화소녀시대 70<BR>\r\n\n아침은 맑음, 오후는 모르겠어요 73<BR>\r\n\n뜨거운 취미 76<BR>\r\n\n눈물광대 80<BR>\r\n\n막막광대 81<BR>\r\n\n회의광대 84<BR>\r\n\n위임광대 86<BR>\r\n\n<BR>\r\n\n<B>3부 환하고 말랑말랑한</B><BR>\r\n\n<BR>\r\n\n소녀들이 소풍을 가요 91<BR>\r\n\n무적 92<BR>\r\n\n올리브 vs 올리브 96<BR>\r\n\n사슴뿔선인장 97<BR>\r\n\n달려라 하니 100<BR>\r\n\n버뮤다 제라늄 102<BR>\r\n\n독거소녀 삐삐 104<BR>\r\n\n초승달편의점 105<BR>\r\n\n반상회 508 108<BR>\r\n\n반상회 401 110<BR>\r\n\n후크선장 112<BR>\r\n\n사포 115<BR>\r\n\n사십 계단에서 훔쳐 온 사과 116<BR>\r\n\n검은 모자를 쓴 책상 118<BR>\r\n\n십자뜨기 119<BR>\r\n\n목련 부메랑 120<BR>\r\n\n숨도둑 122<BR>\r\n\n눈의 결정을 뜨개질하는 소녀들 124<BR>\r\n\n<BR>\r\n\n<B>4부 놀이의 각도</B><BR>\r\n\n<BR>\r\n\n혼자 살아요 129<BR>\r\n\n지구력 130<BR>\r\n\n무희들 132<BR>\r\n\n신문지 놀이 134<BR>\r\n\n해바라기 137<BR>\r\n\n묘지지도 138<BR>\r\n\n뽁뽁이Bubble Wrap 140<BR>\r\n\n우수의 이차방정식 143<BR>\r\n\n셀카Selfie 144<BR>\r\n\n마리오네뜨의 동선 146<BR>\r\n\n빵과 칼의 거리 148<BR>\r\n\n단골이 되기에 너무 늦은 술집은 없다 150<BR>\r\n\n도마뱀이 나타난 저녁 153<BR>\r\n\n무 154<BR>\r\n\n전사의 시 157<BR>\r\n\n<BR>\r\n\n<B>부록 </B><BR>\r\n\n<BR>\r\n\n울음의 이정표 159<BR>\r\n\n숨죽여 우는 사람 160<BR>\r\n\n프롤로고스 161<BR>\r\n\n<BR>\r\n\n해설 _ 발랄과 우울, 그리고 그 사이 - 최정란 시집 &#56194;&#56404;독거소녀 삐삐&#56194;&#56405; 읽기 163<BR>\r\n\n오민석(문학평론가·단국대 교수)</p>"
      new_str = old_str.strip_tags
      assert_equal new_str.is_utf8?, true
    end
  end
end
