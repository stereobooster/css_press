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
    CssPress.press('a { b: c ; }').should eql 'a{b:c}'
    # CssPress.press('a { b : c ; }').should eql 'a{b:c}'
  end

  # it "should remove unnecessary quotes from urls" do
    # CssPress.press('a{b:url( "i.gif" )}').should eql 'a{b:url(i.gif)}'
    # CssPress.press('a{b:url( " i.gif" )}').should eql 'a{b:url(" i.gif")}'
  # end

  it "should remove unnecessary quotes from attributes" do
    CssPress.press('a[d="e"]{b:c}').should eql 'a[d=e]{b:c}'
    CssPress.press('a[d="e f"]{b:c}').should eql 'a[d="e f"]{b:c}'
  end

  # it "should minify class attributes" do
    # CssPress.press('a[class="x y z"]{b:c}').should eql 'a.x.y.z{b:c}'
    # CssPress.press('a[class="x.y z"]{b:c}').should eql 'a[class="x.y z"]{b:c}'
  # end

  it "should minify color" do
    CssPress.press('a{color:#aaaaaa}').should eql 'a{color:#aaa}'
    CssPress.press('a{color:#AaaAaa}').should eql 'a{color:#aaa}'
    CssPress.press('a{color:#ff0000}').should eql 'a{color:red}'
    CssPress.press('a{color:#f00}').should eql 'a{color:red}'
    CssPress.press('#f00{color:#f00}').should eql '#f00{color:red}'
    CssPress.press('a{color:black}').should eql 'a{color:#000}'
    CssPress.press('a{background:black}').should eql 'a{background:#000}'
    CssPress.press('a{border:black}').should eql 'a{border:#000}'
    CssPress.press('a{background-color:black}').should eql 'a{background-color:#000}'
    CssPress.press('a{border-top:black}').should eql 'a{border-top:#000}'
    CssPress.press('a{b:black}').should eql 'a{b:black}'
    CssPress.press('a{color:rgb(0,0,0)}').should eql 'a{color:#000}'
    CssPress.press('a{color:rgb(0%,0%,0%)}').should eql 'a{color:#000}'
    CssPress.press('a{color:rgb(300,0,0)}').should eql 'a{color:rgb(300,0,0)}'
    CssPress.press('a{color:rgb(101%,0%,0%)}').should eql 'a{color:rgb(101%,0,0)}'
  end

  it "should remove comments" do
    CssPress.press('/* cooment*/a{b:c}').should eql 'a{b:c}'
    CssPress.press('a/* cooment*/{b:c}').should eql 'a{b:c}'
    CssPress.press('a{/* cooment*/b:c}').should eql 'a{b:c}'
    CssPress.press('a{b:/* cooment */c}').should eql 'a{b:c}'
    CssPress.press('a{b:c/* cooment */}').should eql 'a{b:c}'
    CssPress.press('a{b:c/* cooment \*/}').should eql 'a{b:c}'
    CssPress.press('a{b:"\"}\""/* cooment */}').should eql 'a{b:"\"}\""}'     
  end

  it "should remove units from 0" do
    CssPress.press('a{padding:0px}').should eql 'a{padding:0}'
  end

  it "should remove leading/trailing zeros from decimals" do
    CssPress.press('a{padding:0.1%}').should eql 'a{padding:.1%}'
    CssPress.press('a{padding:1.0%}').should eql 'a{padding:1%}'
    CssPress.press('a{margin:-1.0%}').should eql 'a{margin:-1%}'
    CssPress.press('a{margin:-0.1%}').should eql 'a{margin:-.1%}'
    CssPress.press('a{margin:-0.0%}').should eql 'a{margin:0}'
  end

  it "should change none to 0" do
    CssPress.press('a{border:none}').should eql 'a{border:0}'
    CssPress.press('a{border-bottom:none}').should eql 'a{border-bottom:0}'
  end

  it "should remove duplicate rules" do
    CssPress.press('a{x:y;x:z}').should eql 'a{x:z}'
    CssPress.press('a{x:y1;b:b;x:z}').should eql 'a{b:b;x:z}'
    CssPress.press('a{c:c;x:y;b:b;x:z}').should eql 'a{c:c;b:b;x:z}'
    CssPress.press('a{c:c;x:y;b:b;x:z;d:d;x:x}').should eql 'a{c:c;b:b;d:d;x:x}'
    CssPress.press('a{c:c;x:y;b:b;x:z;c:c;x:x}').should eql 'a{b:b;c:c;x:x}'
  end

  # it "should remove unnecessary values from padding/margin" do
    # CssPress.press('a{padding:0 0 0 0}').should eql 'a{padding:0}'
    # CssPress.press('a{padding:0 0 10px 0}').should eql 'a{padding:0 0 10px}'
    # CssPress.press('a{padding:0 auto 0 auto}').should eql 'a{padding:0 auto}'
    # CssPress.press('a{background-position:0 0}').should eql 'a{background-position:0 0}'
  # end

  # it "should remove empty rules" do
    # CssPress.press('a{}').should eql ''
    # CssPress.press('a{;}').should eql ''
    # CssPress.press('a{/*b:c*/}').should eql ''
    # CssPress.press('@media print{a{}b{c:d}}').should eql '@media print{b{c:d}}'
    # CssPress.press('@media print{a{}}').should eql ''
  # end

  # it "should combine all background related properties" do
    # css_in = 'a{
    #   background-color: #fff;
    #   background-image: url(image.gif);
    #   background-repeat: repeat-x; 
    #   background-attachment: fixed; 
    #   background-position: 0 0}'
    # css_out = 'a{background:#fff url(image.gif) repeat-x fixed 0 0}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine all border related properties" do
    # css_in = 'a{
    #   border-left-color: #000;
    #   border-left-style: solid;
    #   border-left-width: 2px;
    #   border-right-color: #000;
    #   border-right-style: solid;
    #   border-right-width: 2px;
    #   border-top-color: #000;
    #   border-top-style: solid;
    #   border-top-width: 3px}'
    # css_out = 'a{border:solid #000;border-width:3px 2px 0}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine all border-radius related properties" do
    # -moz- -webkit- -o-
  # end

  # it "should combine all font related properties" do
    # css_in = 'a{
    #   font-style: italic;
    #   font-variant: small-caps;
    #   font-weight: 500;
    #   font-size: 1em;
    #   line-height: 24px;
    #   font-family: arial,sans-serif}'
    # css_out = 'a{font:italic small-caps 500 1em/24px arial,sans-serif}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should minimize font-family" do
  # end

  # it "should combine all list related properties" do
    # css_in = 'a{
    #   list-style-type: circle;
    #   list-style-position: inside;
    #   list-style-image: url(bullet.gif)}'
    # css_out = 'a{list-style:inside circle url(bullet.gif)}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine all outline related properties" do
    # css_in = 'a{
    #   outline-color: #fff;
    #   outline-style: dotted;
    #   outline-width: 1px}'
    # css_out = 'a{outline:#fff dotted 1px}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine all margin/padding related properties" do
    # css_in = 'a{margin-top:1px;margin-bottom:2px;margin-right:3px;margin-left:0px}'
    # css_out = 'a{margin:1px 3px 2px 0}'
    # CssPress.press(css_in).should eql css_out

    # css_in = 'a{margin-top:1px;margin-bottom:1px;margin-right:1px;margin-left:1px}'
    # css_out = 'a{margin:1px}'
    # CssPress.press(css_in).should eql css_out

    # css_in = 'a{padding-top:1px;padding-bottom:2px;padding-right:3px;padding-left:0px}'
    # css_out = 'a{padding:1px 3px 2px 0}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine rules with the same selectors" do
    # css_in = 'a{color:red}a{text-decoration:none}'
    # css_out = 'a{color:red;text-decoration:none}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should combine rules with the same rulesets" do
    # css_in = 'a{color:red}b{color:red}'
    # css_out = 'a,b{color:red}'
    # CssPress.press(css_in).should eql css_out
  # end

  # it "should inline import" do
  # end

  # it "should inline small images" do
  # end

end
