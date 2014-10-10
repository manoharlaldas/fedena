class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  helper :all
  helper_method :can_access_request?
  protect_from_forgery  # :secret => '434571160a81b5595319c859d32060c1'
  filter_parameter_logging :password

  before_filter { |c| Authorization.current_user = c.current_user }
  before_filter :message_user
  before_filter :set_user_language
  before_filter :set_variables
  before_filter :login_check

  before_filter :dev_mode
  include CustomInPlaceEditing

  def login_check
  	if session[:user_id].present?
  		unless (controller_name == "user") and ["first_login_change_password","login","logout","forgot_password"].include? action_name 
  			user = User.active.find(session[:user_id])
  			setting = Configuration.get_config_value ('FirstTimeLoginEnable')
  			if setting == "1" and user.is_first_login != false
  				flash[:notice] = "#{t('first_login_attempt')}"
  				redirect_to :controller => "user",:action => "first_login_change_password",:id =>user.username
  			end
  		end
  	end
  end

    def dev_mode
  	    if Rails.env == "development"

        end
    end


  	def set_variables
  		unless @current_user.nil?
  			@attendance_type = Configuration.get_config_value('StudentAttendanceType') unless @current_user.student?
  			@modules = Configuration.available_modules
  		end
  	end

  	def set_language
  	  session[:language] = params[:language]
  	  @current_user.clear_menu_cache
  	  render :update do |page|
  	  page.reload
  	  end
  	end

  	if Rails.env.production?
  		rescue_from ACtiveRecord::RecordNotFound do |exception|
  			flash[:notice] = "#{t('flash_msg2')}, #{{exception}} ."
  			logger.info "[FedenaRescue] AR-Record_Not_Found #{exception.to_s}"
  			log_error exception
  			redirect_to :controller=>:user , :action=>:dashboard
  		end

  		rescue_from NoMethodError do |exception|
  			flash[:notice] = "#{t('flash_msg3')}"
  			logger.info "[FedenaRescue] No Method Error #{exception.to_s}"
  			log_error exception
  			redirect_to :controller=>:user , :action=>:dashboard
  		end

  		rescue_from ActionController::InvalidAuthenticiityToken do |exception|
  			flash[:notice] = "#{t('flash_msg43')}"
  			logger.info "[FedenaRescue] Invalid Authenticiity Token #{exception.to_s}"
  			log_error exception
  			if request.xhr?
  				render(:update) do |page|
  					page.redirect_to :controller => 'user', :action => 'dashboard'
  				end
  			else
  				redirect_to :controller => 'user', :action => 'dashboard'
  			end
  		end
  	end

  	def only_assigned_employee_allowed
  		@privilege = @current_user.privilege.map{|p| p.name}
  		if @current_user.employee?
  			@employee_subjects= @current_user.employee_record.subjects
  			



  		
  			
  		



end
