require 'webrat'
require 'webrat/mechanize'

module WebSickleWebratAdapter

  def open_page(url)
    session.visit(url)
  end

  def click_link(options)
    raise "This adapter only works with the :text option!" unless options[:text]
    session.click_link(options[:text])
  end

  def submit_form_with_options(options_hash)
    action = options_hash[:identified_by][:action]
    raise "You must provide an action!" unless action
    action_regexp = action.is_a?(Regexp) ? action : Regexp.new("#{action}$")
    form = page.forms.detect {|f| f.action =~ action_regexp }
    raise "Could not find form with matching action: #{action_regexp}" unless form
    method = options_hash[:method] || 'post'
    session.request_page(form.action, method, options_hash[:values])
  end

  def page
    session.response
  end
  
  # def visit(url)
  #   session.visit(url)
  # end

  private

  def session
    @session ||= Webrat::MechanizeSession.new
  end


end
