class Simple < Tour
  def test_home
    visit "http://localhost:4567"
    assert_contain "If you click this"

    click_link "Enter Contact"
  end

  def test_contacts
    visit "http://localhost:4567/contacts"
    
    fill_in "first_name", :with => "Joe"
    fill_in "last_name", :with => "Tester"
    click_button 
    
    assert_contain "Tester, Joe"
  end
end
