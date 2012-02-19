# encoding: UTF-8

require_relative "../lib/css_press"

describe CssPress do
  before :each do
  end

  it "should raise error on malformed css" do
    css_with_error = 'a { b: c';
    expect { CssPress.press(css_with_error) }.to raise_error(Racc::ParseError)
  end

  it "should remove unnecessary spaces" do
    CssPress.press('a { b: c; }').should eql 'a{b:c}'
  end

  it "should remove unnecessary quotes from attributes" do
    CssPress.press('a[d="e"]{b:c;}').should eql 'a[d=e]{b:c}'
    CssPress.press('a[d="e f"]{b:c;}').should eql 'a[d="e f"]{b:c}'
  end

end