class WebSickleAssertionException < Exception; end

module WebSickle::Assertions
  def assert_equals(expected, actual, message = nil)
    unless(expected == actual)
      report_error <<-EOF
Error: Expected 
#{expected.inspect}, but got
#{actual.inspect}
#{message}
EOF
    end
  end

  def assert_select(selector, message)
    assert_select_in(@page, selector, message)
  end

  def assert_no_select(selector, message)
    assert_no_select_in(@page, selector, message)
  end

  def assert_select_in(content, selector, message)
    report_error("Error: Expected selector #{selector.inspect} to find a page element, but didn't. #{message}") if (content / selector).blank?
  end

  def assert_no_select_in(content, selector, message)
    report_error("Error: Expected selector #{selector.inspect} to not find a page element, but did. #{message}") unless (content / selector).blank?
  end

  def assert_contains(left, right, message = nil)
    (right.is_a?(Array) ? right : [right]).each do | item |
      report_error("Error: Expected #{left.inspect} to contain #{right.inspect}, but didn't. #{message}") unless left.include?(item)
    end
  end

  def assert(passes, message = nil)
    report_error("Error: expected true, got false.  #{message}") unless passes
  end

  def assert_link_text(link, text)
    case text
    when String
      assert_equals(link.text, text)
    when Regexp
      assert(link.text.match(text))
    else
      raise ArgumentError, "Don't know how to assert an object like #{text.inspect} - expected: Regexp or String"
    end
  end
end
