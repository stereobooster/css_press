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

  it "should minify color" do
    CssPress.press('a{color:#aaaaaa}').should eql 'a{color:#aaa}'
    CssPress.press('a{color:#AaaAaa}').should eql 'a{color:#aaa}'
    CssPress.press('a{color:#ff0000}').should eql 'a{color:red}'
    CssPress.press('a{color:#f00}').should eql 'a{color:red}'
    CssPress.press('#f00{color:#f00}').should eql '#f00{color:red}'
    CssPress.press('a{color:black}').should eql 'a{color:#000}'
    CssPress.press('a{background:black}').should eql 'a{background:#000}'
    CssPress.press('a{border:black}').should eql 'a{border:#000}'
    CssPress.press('a{b:black}').should eql 'a{b:black}'
    CssPress.press('a{color:rgb(0,0,0)}').should eql 'a{color:#000}'
    CssPress.press('a{color:rgb(0%,0%,0%)}').should eql 'a{color:#000}'
    CssPress.press('a{color:rgb(300,0,0)}').should eql 'a{color:rgb(300,0,0)}'
    CssPress.press('a{color:rgb(101%,0%,0%)}').should eql 'a{color:rgb(101%,0%,0%)}'
  end

end