class WebsickleException < Exception; end

module WebSickle
  # form_value is used to interface with the current select form
  attr_reader :form_value
  attr_accessor :page
  
  def initialize(options = {})
    @page = nil
    @form_value = HashProxy.new(
      :set => lambda { |identifier, value| set_form_value(identifier, value)}, 
      :get => lambda { |identifier| get_form_value(identifier)}
    )
  end
  
  def click_link(link)
    set_page(agent.click(find_link(link)))
  end
  
  def submit_form(options = {})
    options[:button] = :first unless options.has_key?(:button)
    options[:identified_by] ||= :first
    select_form(options[:identified_by])
    set_form_values(options[:values]) if options[:values]
    submit_form_button(options[:button])
  end

  # select the current form
  def select_form(identifier = {})
    identifier = make_identifier(identifier, [:name, :action, :method])
    @form = find_in_collection(@page.forms, identifier)
    report_error("Couldn't find form on page at #{@page.uri} with attributes #{identifier.inspect}") if @form.nil?
    @form
  end
  
  # submits the current form
  def submit_form_button(button_criteria = nil, options = {})
    button = 
      case button_criteria
      when nil
        nil
      else
        find_button(button_criteria)
      end
    set_page(agent.submit(@form, button))
  end

  # sets the given path to the current page, then opens it using our agent
  def open_page(path, parameters = [], referer = nil)
    set_page(agent.get(path, parameters, referer))
  end

  # uses Hpricot style css selectors to find the elements in the current +page+.
  # Uses Hpricot#/ (or Hpricot#search)
  def select_element(match)
    select_element_in(@page, match)
  end
  
  # uses Hpricot style css selectors to find the element in the given container.  Works with html pages, and file pages that happen to have xml-like content.
  # throws error if can't find a match
  def select_element_in(contents, match)
    result = (contents.respond_to?(:/) ? contents : Hpricot(contents.body)) / match
    if result.blank?
      report_error("Tried to find element matching #{match}, but couldn't")
    else
      result
    end
  end

  # uses Hpricot style css selectors to find the element.  Works with html pages, and file pages that happen to have xml-like content.
  # throws error if can't find a match
  # Uses Hpricot#at
  def detect_element(match)
    result = (@page.respond_to?(:at) ? @page : Hpricot(@page.body)).at(match)
    if result.blank?
      report_error("Tried to find element matching #{match}, but couldn't")
    else
      result
    end
  end
  
  protected
    # our friendly mechinze agent
    def agent
      @agent ||= new_mechanize_agent
    end
    
    def make_identifier(identifier, valid_keys = nil, default_key = :name)
      identifier = {default_key => identifier} unless identifier.is_a?(Hash) || identifier.is_a?(Symbol)
      identifier.assert_valid_keys(valid_keys) if identifier.is_a?(Hash) && valid_keys
      identifier
    end
  
    def find_field(identifier)
      if @form.nil?
        report_error("No form is selected when trying to find field by #{identifier.inspect}")
        return
      end
      identifier = make_identifier(identifier, [:name, :value])
      find_in_collection(@form.radiobuttons + @form.fields + @form.checkboxes + @form.file_uploads, identifier) ||
        report_error("Tried to find field identified by #{identifier.inspect}, but failed.\nForm fields are: #{(@form.radiobuttons + @form.fields + @form.checkboxes + @form.file_uploads).map{|f| f.inspect} * ", \n  "}") 
    end
    
    def find_link(identifier)
      identifier = make_identifier(identifier, [:href, :text], :text)
      find_in_collection(page.links, identifier) ||
        report_error("Tried to find link identified by #{identifier.inspect}, but failed.\nValid links are: #{page.links.map{|f| f.inspect} * ", \n  "}")
    end
  
    # finds a button by parameters.  Throws error if not able to find.
    # example:
    # find_button("btnSubmit") - finds a button named "btnSubmit"
    # find_button(:name => "btnSubmit")
    # find_button(:name => "btnSubmit", :value => /Lucky/) - finds a button named btnSubmit with a value matching /Lucky/
    def find_button(identifier)
      identifier = make_identifier(identifier, [:value, :name])
      find_in_collection(@form.buttons, identifier) ||
        report_error("Tried to find button identified by #{identifier.inspect}, but failed.  Buttons on selected form are: #{@form.buttons.map{|f| f.inspect} * ','}")
    end
  
    # the magic method that powers find_button, find_field.  Does not throw an error if not found
    def find_in_collection(collection, identifier, via = :find)
      return collection.first if identifier == :first
      find_all_in_collection(collection, identifier, :find)
    end
    
    def find_all_in_collection(collection, identifier, via = :select)
      return [collection.first] if identifier == :first
      collection.send(via) do |item|
        identifier.all? { |k, criteria| is_a_match?(criteria, item.send(k)) }
      end
    end

    # sets a form-field's value by identifier.  Throw's error if field does not exist
    def set_form_value(identifier, value)
      field = find_field(identifier)
      case field
      when WWW::Mechanize::Form::CheckBox
        field.checked = value
      when WWW::Mechanize::Form::RadioButton
        radio_collection = find_all_in_collection(@form.radiobuttons, :name => field.name)
        radio_collection.each { |f|; f.checked = false }
        finder = (value.is_a?(Hash) || value.is_a?(Symbol)) ? value : {:value => value}
        find_in_collection(radio_collection, finder).checked = true
      when WWW::Mechanize::Form::SelectList
        if value.is_a?(Hash) || value.is_a?(Symbol)
          field.value = find_in_collection(field.options, value).value
        else
          field.value = value
        end
      else
        field.value = value
      end
    end
  
    def set_form_values(set_pairs = {})
      flattened_value_hash(set_pairs).each do |identifier, value|
        set_form_value(identifier, value)
      end
    end
    
    def flattened_value_hash(hash, parents = [])
      new_hash = {}
      hash.each do |key, value|
        if value.is_a?(Hash) && value.keys.first.is_a?(String)
          new_hash.update(flattened_value_hash(value, [key] + parents))
        else
          parents.each { |parent| key = "#{parent}[#{key}]"}
          new_hash[key] = value
        end
      end
      new_hash
    end

    # sets a form-field's value by identifier.  Throw's error if field does not exist
    def get_form_value(identifier)
      field = find_field(identifier)
      case field
      when WWW::Mechanize::Form::CheckBox
        field.checked
      else
        field.value
      end
    end
    
    def format_error(msg)
      error = "Error encountered: #{msg}."
      begin
        error << "\n\nPage URL:#{@page.uri.to_s}" if @page
      rescue
      end
      error
    end

    def report_error(msg)
      raise WebsickleException, format_error(msg)
      nil
    end
    
  private
    def set_page(p)
      @form = nil
      @page = p
    end

    def is_a_match?(criteria, value)
      case criteria
      when Regexp
        criteria.match(value)
      when String
        criteria == value
      when Array
        criteria.include?(value)
      else
        criteria.to_s == value.to_s
      end
    end
  
    def new_mechanize_agent
      a = WWW::Mechanize.new
      a.read_timeout = 600 # 10 minutes
      a
    end
end
