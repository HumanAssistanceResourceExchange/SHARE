class DonationApplicationPdf < FillablePdfForm

  def initialize(args = {})
    @user = args[:user]
    @listing = args[:listing]
    @user_questionnaire = Questionnaire.find_by(name: @user.account_type)
    address = args[:address]
    contact = args[:contact]
    @address = get_sanitized_attributes(address, Address.new)
    @contact = get_sanitized_attributes(contact, ContactInfo.new)
    @contact_name = "#{@contact[:first_name]} #{@contact[:last_name]}".titleize
    super()
  end

  protected

    def fill_out
      not_applicable = 'N/A'

      fill :donation_request, @listing.description
      fill :email, @user.email.downcase
      fill :title, @contact.title.titleize
      fill :applicant_name, @contact_name

      [:sign_date, :application_date].each do |field|
        fill field, Date.today.to_s
      end

      fill :address, (@address.street_address_1.titleize + ' ' + @address.street_address_2.titleize).strip

      fill :city, @address.city.titleize

      [:phone, :fax].each do |field|
        fill field, @contact.send(field)
      end

      state_zip_code = @address.state.titleize + ' ' + @address.zip_code
      fill :state_zip, state_zip_code

      if @user.account_type.downcase == 'organization'
        fill :name, @user.entity_name || @contact_name || ''
        fill :contact_name,  @contact_name || ''

        fill :public_benefits, 'No'

        fill :tax_exempt, case @user_questionnaire.questions.find_by(question_text: 'Are you exempt from taxation pursuant to 26 U.S.C 501 ( c )(3)?').response
                            when nil then
                              'No'
                            else
                              if @user_questionnaire.questions.find_by(question_text: 'Are you exempt from taxation pursuant to 26 U.S.C 501 ( c )(3)?').response.response_text.to_s.downcase == 'yes'
                                'Yes'
                              else
                                'No'
                              end
                          end

        fill :school_district_name, case @user_questionnaire.questions.find_by(question_text: 'School District Name').response
                                      when nil then
                                        'N/A'
                                      else
                                        @user_questionnaire.questions.find_by(question_text: 'School District Name').response.response_text
                                    end

        fill :school_district, case @user_questionnaire.questions.find_by(question_text: 'Are you a School District?').response
                                 when nil then
                                   'No'
                                 else
                                   if @user_questionnaire.questions.find_by(question_text: 'Are you a School District?').response.response_text.to_s.downcase == 'yes'
                                     'Yes'
                                   else
                                     'No'
                                   end
                               end

        fill :special_district_name, case @user_questionnaire.questions.find_by(question_text: 'Special District Name').response
                                       when nil then
                                         'N/A'
                                       else
                                         @user_questionnaire.questions.find_by(question_text: 'Special District Name').response.response_text
                                     end

        fill :special_district, case @user_questionnaire.questions.find_by(question_text: 'Are you a Special District?').response
                                  when nil then
                                    'No'
                                  else
                                    if @user_questionnaire.questions.find_by(question_text: 'Are you a Special District?').response.response_text.to_s.downcase == 'yes'
                                      'Yes'
                                    else
                                      'No'
                                    end
                                end

      elsif @user.account_type.downcase == 'individual'

        fill :name, @contact_name

        [:contact_name, :school_district_name, :special_district_name].each do |field|
          fill field, not_applicable
        end

        [:tax_exempt_no, :school_district_no, :special_district_no].each do |field|
          fill field, 'No'
        end

        [:tax_exempt_yes, :school_district_yes, :special_district_yes].each do |field|
          fill field, 'Off'
        end

        public_benefits = 'No'

        # check each public benefits question
        if !@user_questionnaire.questions.find_by(question_text: 'Are you receiving CalFresh benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving CalFresh benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        elsif !@user_questionnaire.questions.find_by(question_text: 'Are you receiving CalWORKS benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving CalWORKS benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        elsif !@user_questionnaire.questions.find_by(question_text: 'Are you receiving County Relief benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving County Relief benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        elsif !@user_questionnaire.questions.find_by(question_text: 'Are you receiving General Relief benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving General Relief benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        elsif !@user_questionnaire.questions.find_by(question_text: 'Are you receiving General Assistance benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving General Assistance benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        elsif !@user_questionnaire.questions.find_by(question_text: 'Are you receiving MediCal benefits?').response.nil? and
            @user_questionnaire.questions.find_by(question_text: 'Are you receiving MediCal benefits?').response.response_text == 'yes'
          public_benefits = 'Yes'
        end

        fill :public_benefits, public_benefits
      end

      true
    end

    private

    def get_sanitized_attributes(object_in, expected_object)
      ar_obj = object_in || expected_object

      ar_obj.attributes.each do |k, v|
        v ||= ''

        ar_obj.send("#{k}=", v)
      end

      ar_obj
    end

end
