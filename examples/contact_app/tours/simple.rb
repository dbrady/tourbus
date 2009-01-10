class Simple < Tour
  def test_home
    open_site_page "/"
    click_link :text => /Enter Contact/
    assert_page_uri_matches "/contacts"
  end

  def test_contacts
    open_site_page "contacts"
    submit_form(
                :identified_by => { :action => %r{/contacts} },
                :values => {
                  'first_name' => "Joe",
                  'last_name' => "Tester"
                }
                )
    assert_page_uri_matches "/contacts"
    assert_page_body_contains "Tester, Joe"
  end
end
