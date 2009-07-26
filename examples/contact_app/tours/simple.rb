class Simple < Tour
  def test_home
    visit "/"
    assert_contain "If you click this"

    click_link "Enter Contact"
    assert_match /\/contacts/, current_page.url
  end

  def test_contacts
    visit "/contacts"
    
    fill_in "first_name", :with => "Joe"
    fill_in "last_name", :with => "Tester"
    click_button 
    
    assert_contain "Tester, Joe"
  end
end
