module HomeHelper
  def convert_state(state)
    byebug
    abbr = state.split("-")[1]
    CS.states(:us)[abbr.to_sym] unless abbr.nil?
  end
end