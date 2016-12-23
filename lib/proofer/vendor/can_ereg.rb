require 'proofer/vendor/vendor_base'

module Proofer
  module Vendor
    class CanEreg < VendorBase

      def submit_answers(question_set, session_id = nil)
      end

      def coerce_vendor_applicant(applicant)
        Proofer::Applicant.new applicant
      end

      def perform_resolution
        if applicant.first_name =~ /Bad/i
          failed_resolution({ error: 'bad first name' }, SecureRandom.uuid)
        elsif applicant.ssn == '6666'
          failed_resolution({ error: 'bad SSN' }, SecureRandom.uuid)
        else
          successful_resolution({ kbv: 'some questions here' }, SecureRandom.uuid)
        end
      end

      def build_question_set(_vendor_resp)
      end
    end
  end
end
