require 'proofer/vendor/vendor_base'
require 'svelte'

module Proofer
  module Vendor
    class CanEreg < VendorBase

      def initialize(opts = {})
        super()
        Svelte::Service.create(url: 'https://can-ereg-api.herokuapp.com/v1/swagger.json', module_name: 'CanEreg')
      end

      def submit_answers(question_set, session_id = nil)
      end

      def coerce_vendor_applicant(applicant)
        Proofer::Applicant.new applicant
      end

      def perform_resolution
        check_id = submit_check
        status = nil

        until status == 'SUCCESS' do
          response = get_check(check_id)
          status = response['status']
        end

        if response['result']['registered']
          successful_resolution({ kbv: false }, SecureRandom.uuid)
        else
          failed_resolution({ error: response['result']['message'] }, SecureRandom.uuid)
        end
      end

      def build_question_set(_vendor_resp)
      end

    private

      def submit_check
        response = Svelte::Service::CanEreg::Checks.create_check(
          first_name: applicant.first_name,
          last_name: applicant.last_name,
          birth_date: formatted_date,
          full_address: "#{applicant.address1}, #{applicant.city}, #{applicant.state}"
        )
        check_id = response.env.response_headers['Location'].split('/')[-1]

        check_id
      end

      def get_check(check_id)
        response = Svelte::Service::CanEreg::Checks.get_check(check_id:check_id)

        response.env.body
      end

      def formatted_date
        date = Date.parse(applicant.dob.to_s)
        date.strftime('%Y-%-m-%-d')
      end

    end
  end
end
