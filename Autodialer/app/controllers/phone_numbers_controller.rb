class PhoneNumbersController < ApplicationController
  before_action :ensure_simulation_mode
  before_action :set_phone_number, only: [:show, :edit, :update, :destroy, :make_call]
  before_action :check_limit, only: [:create, :bulk_upload, :paste_numbers]
  
  def index
    @phone_numbers = PhoneNumber.includes(:call_logs)
                                .order(params[:sort] || 'created_at DESC')
                                .page(params[:page])
                                .per(25)
    
    # Filter by status if specified
    @phone_numbers = @phone_numbers.where(status: params[:status]) if params[:status].present?
    
    @stats = {
      total: PhoneNumber.count,
      pending: PhoneNumber.pending.count,
      completed: PhoneNumber.completed.count,
      failed: PhoneNumber.failed.count
    }
    
    respond_to do |format|
      format.html
      format.json { render json: @phone_numbers }
    end
  end
  
  def show
    @call_logs = @phone_number.call_logs.recent.limit(10)
  end
  
  def new
    @phone_number = PhoneNumber.new
  end
  
  def create
    @phone_number = PhoneNumber.new(phone_number_params.merge(source: 'manual'))
    
    if @phone_number.save
      flash[:success] = "Phone number #{@phone_number.formatted_number} added successfully."
      redirect_to phone_numbers_path
    else
      flash.now[:error] = @phone_number.errors.full_messages.join(', ')
      render :new
    end
  end
  
  def edit
  end
  
  def update
    if @phone_number.update(phone_number_params)
      flash[:success] = "Phone number updated successfully."
      redirect_to @phone_number
    else
      flash.now[:error] = @phone_number.errors.full_messages.join(', ')
      render :edit
    end
  end
  
  def destroy
    @phone_number.destroy
    flash[:success] = "Phone number deleted successfully."
    redirect_to phone_numbers_path
  end
  
  def bulk_upload
    unless params[:file].present?
      flash[:error] = "Please select a file to upload."
      redirect_to phone_numbers_path
      return
    end
    
    begin
      file_content = params[:file].read
      numbers = parse_phone_numbers(file_content)
      
      if numbers.empty?
        flash[:error] = "No valid phone numbers found in the file."
        redirect_to phone_numbers_path
        return
      end
      
      result = process_phone_numbers(numbers, 'upload')
      
      flash[:success] = "Successfully added #{result[:added]} phone numbers. #{result[:skipped]} duplicates skipped."
      flash[:warning] = result[:errors].join(', ') if result[:errors].any?
      
    rescue => e
      flash[:error] = "Error processing file: #{e.message}"
    end
    
    redirect_to phone_numbers_path
  end
  
  def paste_numbers
    unless params[:numbers_text].present?
      flash[:error] = "Please enter phone numbers to add."
      redirect_to phone_numbers_path
      return
    end
    
    numbers = parse_phone_numbers(params[:numbers_text])
    
    if numbers.empty?
      flash[:error] = "No valid phone numbers found in the text."
      redirect_to phone_numbers_path
      return
    end
    
    result = process_phone_numbers(numbers, 'paste')
    
    flash[:success] = "Successfully added #{result[:added]} phone numbers. #{result[:skipped]} duplicates skipped."
    flash[:warning] = result[:errors].join(', ') if result[:errors].any?
    
    redirect_to phone_numbers_path
  end
  
  def clear_all
    count = PhoneNumber.count
    PhoneNumber.destroy_all
    
    flash[:success] = "Cleared #{count} phone numbers and their call logs."
    redirect_to phone_numbers_path
  end
  
  def make_call
    unless @phone_number.can_be_called?
      flash[:error] = "This phone number cannot be called (status: #{@phone_number.status})."
      redirect_to @phone_number
      return
    end
    
    # Create call log and start simulation
    call_log = @phone_number.call_logs.create!(
      status: 'queued',
      to_number: @phone_number.number,
      simulation: true
    )
    
    # Trigger background job for the call
    SingleCallJob.perform_async(@phone_number.id)
    
    flash[:success] = "Call initiated to #{@phone_number.formatted_number}. Check call logs for progress."
    redirect_to @phone_number
  end
  
  private
  
  def set_phone_number
    @phone_number = PhoneNumber.find(params[:id])
  end
  
  def phone_number_params
    params.require(:phone_number).permit(:number, :notes)
  end
  
  def check_limit
    current_count = PhoneNumber.count
    max_limit = SystemSetting['max_phone_numbers'] || 100
    
    if current_count >= max_limit
      flash[:error] = "Maximum limit of #{max_limit} phone numbers reached. Please delete some numbers first."
      redirect_to phone_numbers_path
    end
  end
  
  def parse_phone_numbers(content)
    # Extract potential phone numbers from text
    content.to_s.scan(/(?:\+91|91|0)?[6-9]\d{9}|1800\d{6,7}/).uniq
  end
  
  def process_phone_numbers(numbers, source)
    added = 0
    skipped = 0
    errors = []
    max_limit = SystemSetting['max_phone_numbers'] || 100
    
    numbers.each do |number|
      break if PhoneNumber.count >= max_limit
      
      next unless PhoneNumber.indian_phone_number?(number)
      
      phone_number = PhoneNumber.new(number: number, source: source)
      
      if phone_number.save
        added += 1
      elsif phone_number.errors[:number]&.include?("has already been taken")
        skipped += 1
      else
        errors << "#{number}: #{phone_number.errors.full_messages.join(', ')}"
      end
    end
    
    { added: added, skipped: skipped, errors: errors }
  end
end