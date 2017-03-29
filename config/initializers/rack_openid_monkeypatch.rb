module Rack
  class OpenID
    def add_attribute_exchange_fields(oidreq, fields)
      axreq = ::OpenID::AX::FetchRequest.new

      required = Array(fields['required']).select(&URL_FIELD_SELECTOR)
      optional = Array(fields['optional']).select(&URL_FIELD_SELECTOR)

      if required.any? || optional.any?
        required.each do |field|
          axreq.add(::OpenID::AX::AttrInfo.new(field, nil, true, 99))
        end

        optional.each do |field|
          axreq.add(::OpenID::AX::AttrInfo.new(field, nil, false, 99))
        end

        oidreq.add_extension(axreq)
      end
    end
  end
end