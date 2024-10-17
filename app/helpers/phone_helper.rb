# frozen_string_literal: true

module PhoneHelper
  def formatted_phone(phone)
    Phonelib.parse(phone).national
  end

  def full_phone(phone)
    Phonelib.parse(phone).full_e164
  end
end
