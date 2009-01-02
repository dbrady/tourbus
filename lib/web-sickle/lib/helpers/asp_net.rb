module WebSickle::Helpers
module AspNet
  def asp_net_do_postback(options)
    target_element = case
      when options[:button]
        find_button(options[:button])
      when options[:field]
        find_field(options[:field])
      else
        nil
      end
    @form.fields << WWW::Mechanize::Form::Field.new("__EVENTTARGET", target_element ? target_element.name : "") if target_element
    submit_form_button
  end
end
end