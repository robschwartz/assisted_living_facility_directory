class ProviderController < ActionController::Base
  layout 'application'

  def root
    @states = CS.states(:us)
    set_title_tag
  end

  def home
    @states = CS.states(:us)
    set_title_tag
  end

  def search
    @state = params['search']
    abbr = @state.split("-")[1]
    state_name = CS.states(:us)[abbr.to_sym]
    render json: {state: state_name}
    # redirect_to location_url(location: @state, home_type: params['home_type']) and return
  end

  def req_info
    # Send data from the form to our data-bucket
    ForwardData.send_to_bucket(params)
    redirect_to thank_you_path
  end

  def send_contact_form
    ContactUsMailer.contact(params).deliver_now
  end

  def location_results
    @home_type = params['home_type']
    @state = params['state']
    @location = params['location'].split.map(&:capitalize).join(' ')

    results = Provider.location_translator(@location, params['state'], params['home_type'])

    if !@home_type.blank?
      @homes = results[:homes].where(home_type: @home_type).order("city ASC")
    else
      @homes = results[:homes].order("city ASC")
    end

    @loc_type = results[:loc_type]

    if @loc_type == "State"
      @cities = results[:city_list]
    end

    if @homes.empty?
      flash[:error] = "Sorry! Your search returned 0 results. Please enter a new search."
      redirect_to home_path
    end
    set_title_tag
  end

  def show
    @home = Provider.find_by_name(params['name'])
    @state = CS.states(:us)[@home.state.to_sym]
    set_title_tag
  end


  private

  def convert_state
    abbr = @state.split("-")[1]
    CS.states(:us)[abbr.to_sym]
  end


  def set_title_tag
    @title =  if !@location.blank?
                "Find Nursing Homes, Assisted Living Facilities, Intermediate Care Near #{@location}"
              elsif !@state.blank?
                "Find Nursing Homes, Assisted Living Facilities, Intermediate Care Near #{@state}"
              else
                "Find Nursing Homes, Assisted Living Facilities, Intermediate Care Near you"
              end
  end


end
