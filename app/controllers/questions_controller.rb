class QuestionsController < ApplicationController
  before_action :find_question

  def show
  end

  def answer
    service = InterviewerService.new(@question)
    follow_up = service.generate_follow_up(params[:answer])

    @interview = @question.interviews.create!(
      first_answer: params[:answer],
      follow_up_question: follow_up
    )

    session[:interview_id] = @interview.id

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_path(@question) }
    end
  rescue MistralService::ApiError => e
    flash[:error] = e.message
    redirect_to question_path(@question)
  end

  def follow_up_answer
    @interview = @question.interviews.find(params[:interview_id])

    unless session[:interview_id] == @interview.id
      redirect_to question_path(@question) and return
    end

    @interview.update!(follow_up_answer: params[:answer])
    session.delete(:interview_id)

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_path(@question) }
    end
  end

  def request_otp
    phone = Phonelib.parse(params[:phone_number])
    unless phone.valid?
      @phone_error = "Phone number is not valid"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(@question) }
      end
      return
    end

    phone_e164 = phone.e164

    if Contact.exists?(phone: phone_e164)
      @phone_error = "This phone number is already registered"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(@question) }
      end
      return
    end

    plain_code = rand(100_000..999_999).to_s
    salt = Rails.application.secret_key_base
    code_digest = OpenSSL::HMAC.hexdigest("SHA256", salt, plain_code)

    session[:contact_phone] = phone_e164
    session[:contact_otp_digest] = code_digest
    session[:contact_otp_expires_at] = 5.minutes.from_now.to_i

    SmsService.send_otp(phone_e164, plain_code)

    @otp_sent = true
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_path(@question) }
    end
  end

  def verify_otp
    phone = session[:contact_phone]
    otp_digest = session[:contact_otp_digest]
    expires_at = session[:contact_otp_expires_at]

    if phone.blank? || otp_digest.blank?
      @phone_error = "Please request a code first"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(@question) }
      end
      return
    end

    if Time.current.to_i > expires_at.to_i
      @phone_error = "Code has expired, please request a new one"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(@question) }
      end
      return
    end

    salt = Rails.application.secret_key_base
    submitted_digest = OpenSSL::HMAC.hexdigest("SHA256", salt, params[:otp_code].to_s.strip)
    unless ActiveSupport::SecurityUtils.secure_compare(otp_digest, submitted_digest)
      @phone_error = "Incorrect code"
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(@question) }
      end
      return
    end

    Contact.find_or_create_by!(phone: phone)

    session.delete(:contact_phone)
    session.delete(:contact_otp_digest)
    session.delete(:contact_otp_expires_at)

    @phone_verified = true
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_path(@question) }
    end
  end

  private

  def find_question
    @question = Question.find_by!(uuid: params[:id])
  end
end
