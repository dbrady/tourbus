require 'forwardable'
require 'webrat'

module TourRat
  module ClassMethods
    
  end
  
  module InstanceMethods
    
  end
  
  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end

# Webrat::Scope
#  1. attach_file
#  2. check
#  3. choose
#  4. click_area
#  5. click_button
#  6. click_link
#  7. fill_in
#  8. select
#  9. select_date
# 10. select_datetime
# 11. select_time
# 12. set_hidden_field
# 13. submit_form
# 14. uncheck
# 
# 
# Webrat::Session
#  1. automate
#  2. basic_auth
#  3. check_for_infinite_redirects
#  4. click_link_within
#  5. dom
#  6. header
#  7. http_accept
#  8. infinite_redirect_limit_exceeded?
#  9. internal_redirect?
# 10. redirected_to
# 11. reload
# 12. simulate
# 13. visit
# 14. within
# 15. xml_content_type?
# 
# Webrat::HaveTagMatcher
# 1. assert_have_no_tag
# 2. assert_have_tag
# 3. have_tag
# 4. match_tag
# 
# Webrat::Matchers
#  1. assert_contain
#  2. assert_have_no_selector
#  3. assert_have_no_xpath
#  4. assert_have_selector
#  5. assert_have_xpath
#  6. assert_not_contain
#  7. contain
#  8. have_selector
#  9. have_xpath
# 10. match_selector
# 11. match_xpath
