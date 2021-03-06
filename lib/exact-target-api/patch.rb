module ET
  class Patch < ET::Constructor
    def initialize(client, obj_type, props = nil)
      response = make_request(client, obj_type, props)
      if @token_expired
        client.refresh_token(true)
        response = make_request(client, obj_type, props)
      end
      response
    end

    def make_request(client, obj_type, props)
      @results = []
      begin
        client.refresh_token
        if props.is_a?(Array)
          obj = { 'Objects' => [] }
          props.each do |p|
            obj['Objects'] << p.merge('@xsi:type' => 'tns:' + obj_type)
          end
        else
          obj = { 'Objects' => props.merge('@xsi:type' => 'tns:' + obj_type) }
        end
        response = client.auth.call(:update, message: obj)
      ensure
        super(response)
        if @status
          @status = false if @body[:update_response][:overall_status] != 'OK'
          if !@body[:update_response][:results].is_a?(Hash)
            @results += @body[:update_response][:results]
          else
            @results.push(@body[:update_response][:results])
          end
        end
      end
    end
  end
end
