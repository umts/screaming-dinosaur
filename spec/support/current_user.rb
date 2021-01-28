# frozen_string_literal: true

def when_current_user_is(user)
  current_user =
    case user
    when User then user
    when :whoever, :anyone then create :user
    else raise ArgumentError
    end
  set_user(current_user)
end
alias set_current_user when_current_user_is

def set_user(user)
  case self.class.metadata[:type]
  when :system
    page.set_rack_session user_id: user.id
  when :controller
    session[:user_id] = user.id
  when :view
    assign :current_user, user
  end
end

