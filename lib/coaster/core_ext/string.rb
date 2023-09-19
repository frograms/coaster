# frozen_string_literal: true

# :nodoc:
class String
  # @note 반각 문자 -> 전각 문자
  # @param [TrueClass, FalseClass] alpha
  # @param [TrueClass, FalseClass] number
  # @param [TrueClass, FalseClass] symbol
  # @return [String]
  def to_full_characters(alpha: true, number: true, symbol: false)
    result = String.new
    return result if self.blank?

    (0...self.size).each do |i|
      half_ord = self[i].ord
      full_ord = half_ord + 0xfee0
      char_ord = case half_ord
                 when 0x20 then 0x3000
                 when ('0'.ord)..('9'.ord) then number ? full_ord : half_ord
                 when ('A'.ord)..('Z'.ord) then alpha ? full_ord : half_ord
                 when ('a'.ord)..('z'.ord) then alpha ? full_ord : half_ord
                 when ('!'.ord)..('~'.ord) then symbol ? full_ord : half_ord
                 else half_ord
                 end
      result << char_ord.chr('UTF-8')
    end
    result
  end

  # @note 전각 문자 -> 반각 문자
  # @param [TrueClass, FalseClass] alpha
  # @param [TrueClass, FalseClass] number
  # @param [TrueClass, FalseClass] symbol
  # @return [String]
  def to_half_characters(alpha: true, number: true, symbol: false)
    result = String.new
    return result if self.blank?

    (0...self.size).each do |i|
      full_ord = self[i].ord
      half_ord = full_ord - 0xfee0
      char_ord = case full_ord
                 when 0x3000 then 0x20
                 when ('0'.ord + 0xfee0)..('9'.ord + 0xfee0) then number ? half_ord : full_ord
                 when ('A'.ord + 0xfee0)..('Z'.ord + 0xfee0) then alpha ? half_ord : full_ord
                 when ('a'.ord + 0xfee0)..('z'.ord + 0xfee0) then alpha ? half_ord : full_ord
                 when ('!'.ord + 0xfee0)..('~'.ord + 0xfee0) then symbol ? half_ord : full_ord
                 else full_ord
                 end
      result << char_ord.chr('UTF-8')
    end
    result
  end
end
