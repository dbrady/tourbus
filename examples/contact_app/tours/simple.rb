class Simple < Tourist
  def tour_home
    visit "#{@host}/"
    assert_contain "If you click this"

    click_link "Enter Contact"
    assert_match /\/contacts/, current_url
  end

  def tour_contacts
    visit "/contacts"
    
    fill_in "first_name", :with => "Joe"
    fill_in "last_name", :with => "Tester"
    click_button 
    
    assert_contain "Tester, Joe"
  end
end
