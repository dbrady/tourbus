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

  def submit_form(options_hash)
    action = options_hash[:identified_by][:action]
    raise "You must provide an action!" unless action
    action_regexp = action.is_a?(Regexp) ? action : Regexp.new("#{action}$")
    form = page.forms.detect {|f| f.action =~ action_regexp }
    raise "Could not find form with matching action: #{action_regexp}" unless form
    method = options_hash[:method] || 'post'
    url = "http://#{@host}#{form.action}"
    session.request_page(url, method, options_hash[:values])
  end

  def page
    session.response
  end

  private

  def session
    @session ||= Webrat::MechanizeSession.new
  end

  def select_form(identifier = {})
    identifier = make_identifier(identifier, [:name, :action, :method])
    @form = find_in_collection(@page.forms, identifier)
    unless @form
      valid_forms = @page.forms.map {|f| "name: #{f.name}, method: #{f.method}, action: #{f.action}"} * "\n"
      report_error("Couldn't find form on page at #{@page.uri} with attributes #{identifier.inspect}. Valid forms on this page are: \n#{valid_forms}")
    end
    @form
  end
 


end
