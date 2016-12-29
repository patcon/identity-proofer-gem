require 'proofer/vendor/vendor_base'
require 'httparty'

module Proofer
  module Vendor
    class CanEregClient
      include HTTParty
      base_uri 'can-ereg-api.herokuapp.com'

      def initialize(api_key: nil)
        @options = {}

        if api_key
          @options[:headers] ={
            'Authorization' => api_key,
          }
        end
      end

      def create_check(**params)
        @options.merge!({ body:params })

        self.class.post("/v1/checks", @options)
      end

      def get_check(check_id:)
        self.class.get("/v1/checks/#{check_id}", @options)
      end
    end

    class CanEreg < VendorBase

      def initialize(opts = {})
        super()
        @client = CanEregClient.new(api_key: ENV['CAN_EREG_API_KEY'])
      end

      def submit_answers(question_set, session_id = nil)
      end

      def coerce_vendor_applicant(applicant)
        Proofer::Applicant.new applicant
      end

      def perform_resolution
        body = submit_check
        check_id = body['check_id']
        status = nil

        until status == 'SUCCESS' do
          sleep(10)
          body = get_check(check_id)
          puts body
          status = body['status']
        end

        if body['registered']
          successful_resolution({ kbv: false }, SecureRandom.uuid)
        else
          failed_resolution({ error: body['raw_message'] }, SecureRandom.uuid)
        end
      end

      def build_question_set(_vendor_resp)
      end

    private

      def submit_check
        response = @client.create_check(
          first_name: applicant.first_name,
          last_name: applicant.last_name,
          birth_date: formatted_date,
          full_address: "#{applicant.address1}, #{applicant.city}, #{applicant.state}"
        )
        puts response

        JSON.parse(response.body)
      end

      def get_check(check_id)
        response = @client.get_check(check_id:check_id)

        JSON.parse(response.body)
      end

      def formatted_date
        date = Date.parse(applicant.dob.to_s)
        date.strftime('%Y-%-m-%-d')
      end

    end
  end
end
